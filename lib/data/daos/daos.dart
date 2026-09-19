import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/enums.dart';
import '../local/tables.dart';

part 'daos.g.dart';

/// Valores que toda escritura debe refrescar para que el registro vuelva a
/// entrar en la cola de sincronización.
DateTime _ahora() => ahora();

@DriftAccessor(tables: [Productores, Asociaciones])
class ProductoresDao extends DatabaseAccessor<AppDatabase>
    with _$ProductoresDaoMixin {
  ProductoresDao(super.db);

  /// El productor de esta instalación: el que pertenece a [usuarioId].
  ///
  /// Antes se tomaba "el primer productor vivo", que deja de ser válido en
  /// cuanto la base recibe productores de otras instalaciones.
  Stream<Productor?> watchProductorDe(String usuarioId) {
    return (select(productores)
          ..where((p) => p.usuarioId.equals(usuarioId))
          ..where((p) => p.deletedAt.isNull()))
        .watch()
        .map((filas) => filas.isEmpty ? null : filas.first);
  }

  Future<Productor?> porId(String id) {
    return (select(
      productores,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<String> guardar({
    String? id,
    required String usuarioId,
    required String nombreCompleto,
    String? telefono,
    String? email,
    String? asociacionId,
    TipoDocumento? tipoDocumento,
    String? numeroDocumento,
  }) async {
    final idFinal = id ?? nuevoId();
    await into(productores).insertOnConflictUpdate(
      ProductoresCompanion.insert(
        id: Value(idFinal),
        usuarioId: Value(usuarioId),
        nombreCompleto: nombreCompleto,
        telefono: Value(telefono),
        email: Value(email),
        asociacionId: Value(asociacionId),
        tipoDocumento: Value(tipoDocumento),
        numeroDocumento: Value(numeroDocumento),
        updatedAt: Value(_ahora()),
        syncStatus: const Value(SyncStatus.pending),
      ),
    );
    return idFinal;
  }

  Future<Asociacion?> asociacionPorId(String id) => (select(
    asociaciones,
  )..where((a) => a.id.equals(id))).getSingleOrNull();

  /// Crea una asociación que no estaba en el catálogo ("Otra, especificar" en
  /// el formulario del productor). Nace `pending` para que viaje al servidor
  /// y quede visible para las demás instalaciones.
  Future<String> crearAsociacion(String nombre) async {
    final id = nuevoId();
    await into(asociaciones).insert(
      AsociacionesCompanion.insert(
        id: Value(id),
        nombre: nombre,
        municipio: '',
        departamento: '',
        updatedAt: Value(_ahora()),
        syncStatus: const Value(SyncStatus.pending),
      ),
    );
    return id;
  }

  Future<List<Asociacion>> asociacionesPendientes() {
    return (select(asociaciones)
          ..where((a) => a.syncStatus.equalsValue(SyncStatus.pending))
          ..orderBy([(a) => OrderingTerm(expression: a.updatedAt)]))
        .get();
  }

  Future<void> marcarAsociacionSincronizada(String id, DateTime selloServidor) {
    return (update(asociaciones)..where((a) => a.id.equals(id))).write(
      AsociacionesCompanion(
        syncStatus: const Value(SyncStatus.synced),
        serverUpdatedAt: Value(selloServidor),
        syncError: const Value(null),
      ),
    );
  }

  Future<void> aplicarAsociacionRemota(AsociacionesCompanion fila) {
    return into(asociaciones).insertOnConflictUpdate(fila);
  }

  /// Filas que faltan por subir, borradas incluidas: el borrado también viaja.
  Future<List<Productor>> pendientes(String usuarioId) {
    return (select(productores)
          ..where((p) => p.usuarioId.equals(usuarioId))
          ..where((p) => p.syncStatus.equalsValue(SyncStatus.pending))
          ..orderBy([(p) => OrderingTerm(expression: p.updatedAt)]))
        .get();
  }

  Future<void> marcarSincronizado(String id, DateTime selloServidor) {
    return (update(productores)..where((p) => p.id.equals(id))).write(
      ProductoresCompanion(
        syncStatus: const Value(SyncStatus.synced),
        serverUpdatedAt: Value(selloServidor),
        syncError: const Value(null),
      ),
    );
  }

  Future<void> marcarError(String id, String motivo) {
    return (update(productores)..where((p) => p.id.equals(id))).write(
      ProductoresCompanion(
        syncStatus: const Value(SyncStatus.error),
        syncError: Value(motivo),
      ),
    );
  }

  /// Escribe una fila que llegó del servidor, ya en estado sincronizado.
  Future<void> aplicarRemoto(ProductoresCompanion fila) {
    return into(productores).insertOnConflictUpdate(fila);
  }

  Stream<List<Asociacion>> watchAsociaciones() {
    return (select(asociaciones)
          ..where((a) => a.deletedAt.isNull())
          ..orderBy([(a) => OrderingTerm(expression: a.nombre)]))
        .watch();
  }
}

@DriftAccessor(tables: [Fincas, Lotes])
class FincasDao extends DatabaseAccessor<AppDatabase> with _$FincasDaoMixin {
  FincasDao(super.db);

  Stream<List<Finca>> watchFincasDe(String productorId) {
    return (select(fincas)
          ..where((f) => f.productorId.equals(productorId))
          ..where((f) => f.deletedAt.isNull())
          ..orderBy([(f) => OrderingTerm(expression: f.nombre)]))
        .watch();
  }

  /// La Fase 1 asume una finca por productor; devuelve null hasta que la cree.
  Stream<Finca?> watchFincaPrincipal(String productorId) {
    return watchFincasDe(productorId)
        .map((filas) => filas.isEmpty ? null : filas.first);
  }

  Future<String> guardar({
    String? id,
    required String productorId,
    required String nombre,
    required String municipio,
    required String departamento,
    double? latitud,
    double? longitud,
  }) async {
    final idFinal = id ?? nuevoId();
    await into(fincas).insertOnConflictUpdate(
      FincasCompanion.insert(
        id: Value(idFinal),
        productorId: productorId,
        nombre: nombre,
        municipio: municipio,
        departamento: departamento,
        latitud: Value(latitud),
        longitud: Value(longitud),
        updatedAt: Value(_ahora()),
        syncStatus: const Value(SyncStatus.pending),
      ),
    );
    return idFinal;
  }

  /// Arrastra lotes, actividades, cosechas y diagnósticos: si no, quedarían
  /// vivos apuntando a una finca borrada.
  Future<void> borrar(String id) => borrarFincaEnCascada(attachedDatabase, id);

  Future<Finca?> porId(String id) =>
      (select(fincas)..where((f) => f.id.equals(id))).getSingleOrNull();

  /// Fincas por subir del usuario, borradas incluidas. El join con productores
  /// evita mandar al servidor fincas que no son de esta instalación.
  Future<List<Finca>> pendientes(String usuarioId) {
    final consulta =
        select(fincas).join([
            innerJoin(
              attachedDatabase.productores,
              attachedDatabase.productores.id.equalsExp(fincas.productorId),
            ),
          ])
          ..where(
            attachedDatabase.productores.usuarioId.equals(usuarioId) &
                fincas.syncStatus.equalsValue(SyncStatus.pending),
          )
          ..orderBy([OrderingTerm(expression: fincas.updatedAt)]);
    return consulta.map((fila) => fila.readTable(fincas)).get();
  }

  Future<void> marcarSincronizado(String id, DateTime selloServidor) {
    return (update(fincas)..where((f) => f.id.equals(id))).write(
      FincasCompanion(
        syncStatus: const Value(SyncStatus.synced),
        serverUpdatedAt: Value(selloServidor),
        syncError: const Value(null),
      ),
    );
  }

  Future<void> marcarError(String id, String motivo) {
    return (update(fincas)..where((f) => f.id.equals(id))).write(
      FincasCompanion(
        syncStatus: const Value(SyncStatus.error),
        syncError: Value(motivo),
      ),
    );
  }

  Future<void> aplicarRemoto(FincasCompanion fila) =>
      into(fincas).insertOnConflictUpdate(fila);
}

@DriftAccessor(tables: [Lotes])
class LotesDao extends DatabaseAccessor<AppDatabase> with _$LotesDaoMixin {
  LotesDao(super.db);

  Stream<List<Lote>> watchLotesDe(String fincaId) {
    return (select(lotes)
          ..where((l) => l.fincaId.equals(fincaId))
          ..where((l) => l.deletedAt.isNull())
          ..orderBy([(l) => OrderingTerm(expression: l.nombre)]))
        .watch();
  }

  Future<String> guardar({
    String? id,
    required String fincaId,
    required String nombre,
    required double areaSembradaHa,
    required String variedadCacao,
    required DateTime fechaSiembra,
  }) async {
    final idFinal = id ?? nuevoId();
    await into(lotes).insertOnConflictUpdate(
      LotesCompanion.insert(
        id: Value(idFinal),
        fincaId: fincaId,
        nombre: nombre,
        areaSembradaHa: areaSembradaHa,
        variedadCacao: variedadCacao,
        fechaSiembra: fechaSiembra,
        updatedAt: Value(_ahora()),
        syncStatus: const Value(SyncStatus.pending),
      ),
    );
    return idFinal;
  }

  /// Arrastra las actividades, cosechas y diagnósticos del lote.
  Future<void> borrar(String id) => borrarLoteEnCascada(attachedDatabase, id);

  Future<Lote?> porId(String id) =>
      (select(lotes)..where((l) => l.id.equals(id))).getSingleOrNull();

  /// Lotes por subir del usuario, borrados incluidos. Se sube por la cadena
  /// lote -> finca -> productor para no mandar datos de otra instalación.
  Future<List<Lote>> pendientes(String usuarioId) {
    final fincas = attachedDatabase.fincas;
    final productores = attachedDatabase.productores;
    final consulta =
        select(lotes).join([
            innerJoin(fincas, fincas.id.equalsExp(lotes.fincaId)),
            innerJoin(
              productores,
              productores.id.equalsExp(fincas.productorId),
            ),
          ])
          ..where(
            productores.usuarioId.equals(usuarioId) &
                lotes.syncStatus.equalsValue(SyncStatus.pending),
          )
          ..orderBy([OrderingTerm(expression: lotes.updatedAt)]);
    return consulta.map((fila) => fila.readTable(lotes)).get();
  }

  Future<void> marcarSincronizado(String id, DateTime selloServidor) {
    return (update(lotes)..where((l) => l.id.equals(id))).write(
      LotesCompanion(
        syncStatus: const Value(SyncStatus.synced),
        serverUpdatedAt: Value(selloServidor),
        syncError: const Value(null),
      ),
    );
  }

  Future<void> marcarError(String id, String motivo) {
    return (update(lotes)..where((l) => l.id.equals(id))).write(
      LotesCompanion(
        syncStatus: const Value(SyncStatus.error),
        syncError: Value(motivo),
      ),
    );
  }

  Future<void> aplicarRemoto(LotesCompanion fila) =>
      into(lotes).insertOnConflictUpdate(fila);
}

@DriftAccessor(
  tables: [
    ActividadesAgricolas,
    Cosechas,
    Diagnosticos,
    Lotes,
    Fincas,
    Productores,
  ],
)
class RegistrosDao extends DatabaseAccessor<AppDatabase>
    with _$RegistrosDaoMixin {
  RegistrosDao(super.db);

  Stream<List<ActividadAgricola>> watchActividadesDe(String loteId) {
    return (select(actividadesAgricolas)
          ..where((a) => a.loteId.equals(loteId))
          ..where((a) => a.deletedAt.isNull())
          ..orderBy([
            (a) => OrderingTerm(expression: a.fecha, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<String> registrarActividad({
    required String loteId,
    required TipoActividad tipo,
    required DateTime fecha,
    String? observaciones,
  }) async {
    final id = nuevoId();
    await into(actividadesAgricolas).insert(
      ActividadesAgricolasCompanion.insert(
        id: Value(id),
        loteId: loteId,
        tipoActividad: tipo,
        fecha: fecha,
        observaciones: Value(observaciones),
      ),
    );
    return id;
  }

  Stream<List<Cosecha>> watchCosechasDe(String loteId) {
    return (select(cosechas)
          ..where((c) => c.loteId.equals(loteId))
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([
            (c) => OrderingTerm(expression: c.fecha, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<String> registrarCosecha({
    required String loteId,
    required DateTime fecha,
    required double cantidadKg,
    String? observaciones,
  }) async {
    final id = nuevoId();
    await into(cosechas).insert(
      CosechasCompanion.insert(
        id: Value(id),
        loteId: loteId,
        fecha: fecha,
        cantidadKg: cantidadKg,
        observaciones: Value(observaciones),
      ),
    );
    return id;
  }

  /// Producción anual del lote, para el resumen del perfil.
  Future<double> kgCosechadosEn(String loteId, int anio) async {
    final filas =
        await (select(cosechas)
              ..where((c) => c.loteId.equals(loteId))
              ..where((c) => c.deletedAt.isNull())
              ..where(
                (c) =>
                    c.fecha.isBetweenValues(DateTime(anio), DateTime(anio + 1)),
              ))
            .get();
    return filas.fold<double>(0, (suma, c) => suma + c.cantidadKg);
  }

  Future<int> borrarActividad(String id) =>
      borrarSuave(attachedDatabase, actividadesAgricolas, id);

  Future<int> borrarCosecha(String id) =>
      borrarSuave(attachedDatabase, cosechas, id);

  Future<int> borrarDiagnostico(String id) =>
      borrarSuave(attachedDatabase, diagnosticos, id);

  // --- Sincronización de las tres hojas del árbol ---
  //
  // Las tres cuelgan de un lote, así que comparten la misma consulta de
  // pendientes: subir por la cadena registro -> lote -> finca -> productor
  // evita mandar al servidor datos de otra instalación.

  Expression<bool> _esDelUsuario(
    GeneratedColumn<String> loteIdColumna,
    String usuarioId,
  ) {
    return loteIdColumna.isInQuery(
      selectOnly(lotes)
        ..addColumns([lotes.id])
        ..join([
          innerJoin(fincas, fincas.id.equalsExp(lotes.fincaId)),
          innerJoin(productores, productores.id.equalsExp(fincas.productorId)),
        ])
        ..where(productores.usuarioId.equals(usuarioId)),
    );
  }

  Future<ActividadAgricola?> actividadPorId(String id) => (select(
    actividadesAgricolas,
  )..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<List<ActividadAgricola>> actividadesPendientes(String usuarioId) {
    return (select(actividadesAgricolas)
          ..where((a) => a.syncStatus.equalsValue(SyncStatus.pending))
          ..where((a) => _esDelUsuario(a.loteId, usuarioId))
          ..orderBy([(a) => OrderingTerm(expression: a.updatedAt)]))
        .get();
  }

  Future<void> marcarActividadSincronizada(String id, DateTime sello) {
    return (update(actividadesAgricolas)..where((a) => a.id.equals(id))).write(
      ActividadesAgricolasCompanion(
        syncStatus: const Value(SyncStatus.synced),
        serverUpdatedAt: Value(sello),
        syncError: const Value(null),
      ),
    );
  }

  Future<void> aplicarActividadRemota(ActividadesAgricolasCompanion fila) =>
      into(actividadesAgricolas).insertOnConflictUpdate(fila);

  Future<Cosecha?> cosechaPorId(String id) =>
      (select(cosechas)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<List<Cosecha>> cosechasPendientes(String usuarioId) {
    return (select(cosechas)
          ..where((c) => c.syncStatus.equalsValue(SyncStatus.pending))
          ..where((c) => _esDelUsuario(c.loteId, usuarioId))
          ..orderBy([(c) => OrderingTerm(expression: c.updatedAt)]))
        .get();
  }

  Future<void> marcarCosechaSincronizada(String id, DateTime sello) {
    return (update(cosechas)..where((c) => c.id.equals(id))).write(
      CosechasCompanion(
        syncStatus: const Value(SyncStatus.synced),
        serverUpdatedAt: Value(sello),
        syncError: const Value(null),
      ),
    );
  }

  Future<void> aplicarCosechaRemota(CosechasCompanion fila) =>
      into(cosechas).insertOnConflictUpdate(fila);

  Stream<List<Diagnostico>> watchDiagnosticosDe(String loteId) {
    return (select(diagnosticos)
          ..where((d) => d.loteId.equals(loteId))
          ..where((d) => d.deletedAt.isNull())
          ..orderBy([
            (d) => OrderingTerm(expression: d.fecha, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<Diagnostico?> diagnosticoPorId(String id) =>
      (select(diagnosticos)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<List<Diagnostico>> diagnosticosPendientes(String usuarioId) {
    return (select(diagnosticos)
          ..where((d) => d.syncStatus.equalsValue(SyncStatus.pending))
          ..where((d) => _esDelUsuario(d.loteId, usuarioId))
          ..orderBy([(d) => OrderingTerm(expression: d.updatedAt)]))
        .get();
  }

  Future<void> marcarDiagnosticoSincronizado(String id, DateTime sello) {
    return (update(diagnosticos)..where((d) => d.id.equals(id))).write(
      DiagnosticosCompanion(
        syncStatus: const Value(SyncStatus.synced),
        serverUpdatedAt: Value(sello),
        syncError: const Value(null),
      ),
    );
  }

  Future<void> aplicarDiagnosticoRemoto(DiagnosticosCompanion fila) =>
      into(diagnosticos).insertOnConflictUpdate(fila);

  /// Kilos cosechados en un lote durante un año, como stream para que el
  /// resumen se repinte solo al registrar una cosecha.
  Stream<double> watchKgDeLote(String loteId, int anio) {
    final suma = cosechas.cantidadKg.sum();
    final consulta = selectOnly(cosechas)
      ..addColumns([suma])
      ..where(
        cosechas.loteId.equals(loteId) &
            cosechas.deletedAt.isNull() &
            cosechas.fecha.isBetweenValues(DateTime(anio), DateTime(anio + 1)),
      );
    return consulta.watchSingle().map((fila) => fila.read(suma) ?? 0);
  }

  /// Lo mismo pero para toda la finca, uniendo por lote.
  Stream<double> watchKgDeFinca(String fincaId, int anio) {
    final suma = cosechas.cantidadKg.sum();
    final consulta =
        selectOnly(cosechas)
            .join([innerJoin(lotes, lotes.id.equalsExp(cosechas.loteId))])
          ..addColumns([suma])
          ..where(
            lotes.fincaId.equals(fincaId) &
                lotes.deletedAt.isNull() &
                cosechas.deletedAt.isNull() &
                cosechas.fecha.isBetweenValues(
                  DateTime(anio),
                  DateTime(anio + 1),
                ),
          );
    return consulta.watchSingle().map((fila) => fila.read(suma) ?? 0);
  }

  Future<String> registrarDiagnostico({
    required String loteId,
    required DateTime fecha,
    required EstadoFenologico estado,
    String? fotoPath,
    String? notas,
  }) async {
    final id = nuevoId();
    await into(diagnosticos).insert(
      DiagnosticosCompanion.insert(
        id: Value(id),
        loteId: loteId,
        fecha: fecha,
        estadoFenologico: estado,
        fotoPath: Value(fotoPath),
        notas: Value(notas),
      ),
    );
    return id;
  }
}

/// Identidad de la instalación y cursores de descarga.
@DriftAccessor(tables: [Sesion, SyncMeta])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  /// Devuelve la identidad local, creándola en el primer arranque.
  ///
  /// Se genera sin red a propósito: la app tiene que poder crear el perfil del
  /// productor aunque nunca haya visto internet.
  Future<String> identidadLocal() async {
    final fila = await (select(
      sesion,
    )..where((s) => s.id.equals(1))).getSingleOrNull();
    if (fila != null) return fila.usuarioId;
    final id = nuevoId();
    await into(sesion).insert(SesionCompanion.insert(usuarioId: id));
    return id;
  }

  /// Guarda el `auth.uid()` de la sesión anónima de Supabase. La identidad
  /// local no cambia: este id solo viaja al servidor.
  Future<void> guardarAuthUid(String authUid) async {
    await identidadLocal();
    await (update(sesion)..where((s) => s.id.equals(1))).write(
      SesionCompanion(authUid: Value(authUid)),
    );
  }

  /// Estado de la cuenta, para que la interfaz sepa qué ofrecer.
  Stream<SesionLocal?> watchSesion() {
    return (select(sesion)..where((s) => s.id.equals(1))).watchSingleOrNull();
  }

  Future<SesionLocal?> sesionActual() {
    return (select(sesion)..where((s) => s.id.equals(1))).getSingleOrNull();
  }

  Future<void> guardarCorreo(String correo) async {
    await identidadLocal();
    await (update(sesion)..where((s) => s.id.equals(1))).write(
      SesionCompanion(correo: Value(correo)),
    );
  }

  /// Marca que se está entrando con una cuenta existente: hasta que la primera
  /// descarga termine, la app no debe dejar crear un perfil nuevo.
  Future<void> guardarCorreoConfirmado({required bool confirmado}) async {
    await identidadLocal();
    await (update(sesion)..where((s) => s.id.equals(1))).write(
      SesionCompanion(correoConfirmado: Value(confirmado)),
    );
  }

  /// Olvida la cuenta, **conservando la identidad de la instalación**: este
  /// teléfono sigue siendo el mismo, solo deja de estar ligado a una cuenta.
  Future<void> olvidarCuenta() async {
    await (update(sesion)..where((s) => s.id.equals(1))).write(
      const SesionCompanion(
        authUid: Value(null),
        correo: Value(null),
        correoConfirmado: Value(false),
        descargaInicial: Value(true),
      ),
    );
  }

  Future<void> empezarDescargaInicial() async {
    await identidadLocal();
    await (update(sesion)..where((s) => s.id.equals(1))).write(
      const SesionCompanion(descargaInicial: Value(false)),
    );
  }

  Future<void> terminarDescargaInicial() async {
    await (update(sesion)..where((s) => s.id.equals(1))).write(
      const SesionCompanion(descargaInicial: Value(true)),
    );
  }

  Future<String?> authUid() async {
    final fila = await (select(
      sesion,
    )..where((s) => s.id.equals(1))).getSingleOrNull();
    return fila?.authUid;
  }

  /// Cuántos cambios locales están esperando subir, en todo el árbol.
  ///
  /// Es lo que la app muestra como "2 cambios sin subir": el productor tiene
  /// que ver que lo suyo quedó guardado aquí aunque no haya señal.
  Stream<int> watchPendientes() {
    const pendiente = "sync_status = 'pending'";
    return customSelect(
      'SELECT (SELECT COUNT(*) FROM productores WHERE $pendiente) '
      '+ (SELECT COUNT(*) FROM fincas WHERE $pendiente) '
      '+ (SELECT COUNT(*) FROM lotes WHERE $pendiente) '
      '+ (SELECT COUNT(*) FROM actividades_agricolas WHERE $pendiente) '
      '+ (SELECT COUNT(*) FROM cosechas WHERE $pendiente) '
      '+ (SELECT COUNT(*) FROM diagnosticos WHERE $pendiente) AS total',
      readsFrom: {
        attachedDatabase.productores,
        attachedDatabase.fincas,
        attachedDatabase.lotes,
        attachedDatabase.actividadesAgricolas,
        attachedDatabase.cosechas,
        attachedDatabase.diagnosticos,
      },
    ).watchSingle().map((fila) => fila.read<int>('total'));
  }

  /// Dónde se quedó la última descarga de [entidad]: `(updated_at, id)`.
  Future<({DateTime? sello, String? id})> cursor(String entidad) async {
    final fila = await (select(
      syncMeta,
    )..where((m) => m.entidad.equals(entidad))).getSingleOrNull();
    return (sello: fila?.lastSyncAt, id: fila?.lastSyncId);
  }

  Future<void> guardarCursor(String entidad, DateTime sello, String id) {
    return into(syncMeta).insertOnConflictUpdate(
      SyncMetaCompanion.insert(
        entidad: entidad,
        lastSyncAt: Value(sello),
        lastSyncId: Value(id),
      ),
    );
  }
}
