import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'enums.dart';

const _uuid = Uuid();

/// Genera el UUID de un registro nuevo en el dispositivo.
///
/// Es publico porque el codigo generado por Drift copia esta referencia dentro
/// de `database.g.dart`.
String nuevoId() => _uuid.v4();

/// Reloj unico de la app. Todas las marcas locales salen de aqui: si unas
/// columnas usaran el reloj de SQLite y otras el de Dart, una fila recien
/// creada puede aparecer modificada antes de existir.
DateTime ahora() => DateTime.now();

/// Columnas que van en todas las tablas para poder sincronizar con Supabase.
///
/// El [id] es un UUID generado en el dispositivo (no autoincremental) para que
/// dos celulares que crean registros sin internet no choquen al sincronizar, y
/// el borrado es suave ([deletedAt]) para que la eliminación sí se propague.
mixin SyncColumns on Table {
  TextColumn get id => text().clientDefault(nuevoId)();

  DateTimeColumn get createdAt => dateTime().clientDefault(ahora)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(ahora)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Sello que puso el servidor la ultima vez que vio esta fila. Es el unico
  /// reloj comparable entre dispositivos: [updatedAt] es el del telefono.
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();

  TextColumn get syncStatus =>
      textEnum<SyncStatus>().withDefault(const Constant('pending'))();

  /// Motivo por el que la ultima subida fallo; null cuando no hay problema.
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Asociacion')
class Asociaciones extends Table with SyncColumns {
  TextColumn get nombre => text()();
  TextColumn get municipio => text()();
  TextColumn get departamento => text()();
}

@DataClassName('Productor')
class Productores extends Table with SyncColumns {
  /// Dueño del registro: la identidad local de esta instalación (ver [Sesion]).
  /// Es lo que sustituye al viejo "toma el primer productor vivo" y lo que se
  /// traduce al `auth.uid()` de Supabase al subir.
  TextColumn get usuarioId => text().nullable()();

  TextColumn get nombreCompleto => text()();
  TextColumn get telefono => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get asociacionId =>
      text().nullable().references(Asociaciones, #id)();
}

@DataClassName('Finca')
class Fincas extends Table with SyncColumns {
  TextColumn get productorId => text().references(Productores, #id)();
  TextColumn get nombre => text()();
  RealColumn get latitud => real().nullable()();
  RealColumn get longitud => real().nullable()();

  /// Se guardan aparte de lat/long para poder pedir el clima por municipio sin
  /// tener que hacer geocoding inverso.
  TextColumn get municipio => text()();
  TextColumn get departamento => text()();
}

@DataClassName('Lote')
class Lotes extends Table with SyncColumns {
  TextColumn get fincaId => text().references(Fincas, #id)();
  TextColumn get nombre => text()();
  RealColumn get areaSembradaHa => real()();
  TextColumn get variedadCacao => text()();

  /// Se guarda la fecha de siembra, no la edad: la edad se calcula en la app y
  /// así el dato no se desactualiza solo.
  DateTimeColumn get fechaSiembra => dateTime()();
}

@DataClassName('ActividadAgricola')
class ActividadesAgricolas extends Table with SyncColumns {
  TextColumn get loteId => text().references(Lotes, #id)();
  TextColumn get tipoActividad => textEnum<TipoActividad>()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get observaciones => text().nullable()();
}

@DataClassName('Cosecha')
class Cosechas extends Table with SyncColumns {
  TextColumn get loteId => text().references(Lotes, #id)();
  DateTimeColumn get fecha => dateTime()();
  RealColumn get cantidadKg => real()();
  TextColumn get observaciones => text().nullable()();
}

@DataClassName('Diagnostico')
class Diagnosticos extends Table with SyncColumns {
  TextColumn get loteId => text().references(Lotes, #id)();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get fotoPath => text().nullable()();
  TextColumn get estadoFenologico => textEnum<EstadoFenologico>()();
  TextColumn get notas => text().nullable()();
}

/// Identidad de esta instalación, una sola fila.
///
/// [usuarioId] se genera en el primer arranque y **nunca cambia**: es la clave
/// con la que la app encuentra "su" productor aunque en la base haya varios.
/// [authUid] es el id de la sesión anónima de Supabase, que solo existe cuando
/// hubo red alguna vez; se guarda aparte para que la identidad local no dependa
/// de haber tenido conexión.
@DataClassName('SesionLocal')
class Sesion extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get usuarioId => text()();
  TextColumn get authUid => text().nullable()();

  /// Correo de la cuenta, cuando la sesión anónima ya se vinculó a una.
  TextColumn get correo => text().nullable()();

  /// ¿El correo de la cuenta ya fue confirmado en el servidor?
  ///
  /// Con la confirmación activada, vincular el correo **no** lo aplica hasta
  /// que la persona abre el enlace del mensaje. Hasta entonces la cuenta no
  /// sirve para entrar desde otro teléfono, y la app no debe decir que los
  /// datos están respaldados.
  BoolColumn get correoConfirmado =>
      boolean().withDefault(const Constant(false))();

  /// ¿Ya terminó la primera descarga tras entrar con una cuenta existente?
  ///
  /// Arranca en `true` porque una instalación normal no espera nada. Solo
  /// `entrarConCuenta` lo pone en `false`: mientras esté así, la app no puede
  /// ofrecer "crear perfil", o el productor acabaría con un productor
  /// duplicado bajo la misma cuenta.
  BoolColumn get descargaInicial =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cursor de descarga por entidad.
///
/// Guarda las **dos** partes de la clave `(updated_at, id)`: con el sello solo
/// no se puede continuar sin arriesgarse a repetir o a saltarse filas que
/// compartan `updated_at`.
@DataClassName('CursorSync')
class SyncMeta extends Table {
  TextColumn get entidad => text()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get lastSyncId => text().nullable()();

  @override
  Set<Column> get primaryKey => {entidad};
}
