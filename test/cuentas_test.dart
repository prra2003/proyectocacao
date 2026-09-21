import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/sync_result.dart';
import 'package:cacao_app/data/sync/sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

/// Una instalación de la app: su base local, su identidad y su cliente.
typedef Instalacion = ({
  AppDatabase db,
  String usuarioId,
  PerfilRepository perfil,
  LoteRepository lotes,
  ApiRemotaFalsa api,
  SyncService sync,
});

void main() {
  late ServidorFalso servidor;

  setUp(() => servidor = ServidorFalso());

  /// Instala la app "en un teléfono": base nueva, identidad local nueva, y un
  /// cliente propio contra el **mismo** servidor.
  Future<Instalacion> instalar() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final usuarioId = await db.syncDao.identidadLocal();
    final api = ApiRemotaFalsa.deServidor(servidor);
    return (
      db: db,
      usuarioId: usuarioId,
      perfil: PerfilRepository(db, usuarioId: usuarioId),
      lotes: LoteRepository(db),
      api: api,
      sync: SyncService(
        baseDatos: db,
        apiRemota: api,
        usuarioLocal: usuarioId,
      ),
    );
  }

  /// Deja el árbol completo creado en [i] y devuelve los ids.
  Future<({String productor, String finca, String lote})> sembrarFinca(
    Instalacion i,
  ) async {
    final productor = await i.perfil.guardarProductor(
      nombreCompleto: 'Diego Parra',
      telefono: '3001234567',
    );
    final finca = await i.perfil.guardarFinca(
      productorId: productor,
      nombre: 'La Esperanza',
      municipio: 'San Vicente de Chucurí',
      departamento: 'Santander',
    );
    final lote = await i.perfil.guardarLote(
      fincaId: finca,
      nombre: 'Lote 1',
      areaSembradaHa: 2.5,
      variedadCacao: 'CCN-51',
      fechaSiembra: DateTime(2020, 3, 15),
    );
    await i.lotes.registrarActividad(
      loteId: lote,
      tipo: TipoActividad.poda,
      fecha: DateTime(2026, 2, 1),
      observaciones: 'Poda de formación',
    );
    await i.lotes.registrarCosecha(
      loteId: lote,
      fecha: DateTime(2026, 3, 1),
      cantidadKg: 125.5,
    );
    await i.db.registrosDao.registrarDiagnostico(
      loteId: lote,
      fecha: DateTime(2026, 4, 1),
      estado: EstadoFenologico.floracion,
      notas: 'Buena floración',
    );
    return (productor: productor, finca: finca, lote: lote);
  }

  group('entrar con Google', () {
    test('sin cuenta no se sube nada; al entrar, todo queda a su nombre',
        () async {
      final a = await instalar();
      await sembrarFinca(a);

      // Antes de entrar no hay servidor que valga: el trabajo se queda en el
      // teléfono. Esto es lo que cambió al salir de Supabase, donde una sesión
      // anónima respaldaba sin que nadie entrara.
      final sinCuenta = await a.sync.sincronizar();
      expect(sinCuenta.ok, isFalse);
      expect(a.api.uid, isNull);
      expect(a.api.filasDe('productores'), isEmpty);

      final resultado = await a.sync.entrarConGoogle();
      expect(resultado.ok, isTrue);

      final uid = a.api.uid;
      expect(uid, isNotNull);
      // Lo anotado antes de entrar no se pierde: sube con la primera
      // sincronización y queda a nombre de la cuenta.
      expect(a.api.filasDe('productores'), hasLength(1));
      expect(
        servidor.duenoDe(
          'productores',
          a.api.filasDe('productores').single['id']! as String,
        ),
        uid,
      );
      expect(
        servidor.duenoDe(
          'fincas',
          a.api.filasDe('fincas').single['id']! as String,
        ),
        uid,
      );

      final sesion = await a.db.syncDao.sesionActual();
      expect(sesion!.authUid, uid);
      expect(sesion.correo, 'productor@gmail.com');
      // El token se guarda: sin él habría que pedir la cuenta en cada arranque.
      expect(sesion.tokenNube, isNotNull);
    });

    test('la misma cuenta desde otro teléfono es la misma cuenta', () async {
      final a = await instalar();
      await sembrarFinca(a);
      await a.sync.entrarConGoogle();

      final b = await instalar();
      await b.sync.entrarConGoogle();

      // Mismo correo de Google, misma identidad: es lo que hace posible
      // recuperar los datos en un equipo nuevo.
      expect(b.api.uid, a.api.uid);
    });

    test('si la persona cierra la ventana de Google, no cambia nada', () async {
      final a = await instalar();
      await sembrarFinca(a);
      a.api.googleCancela = true;

      final resultado = await a.sync.entrarConGoogle();

      expect(resultado.ok, isFalse);
      expect(resultado.error, contains('canceló'));
      expect((await a.db.syncDao.sesionActual())!.authUid, isNull);
      expect(a.api.filasDe('productores'), isEmpty);
    });
  });

  group('teléfono nuevo con cuenta existente', () {
    test('baja todo el árbol y lo adopta con su propia identidad', () async {
      final a = await instalar();
      final ids = await sembrarFinca(a);
      await a.sync.sincronizar();
      await a.sync.entrarConGoogle();

      final b = await instalar();
      // Antes de entrar, el teléfono B no sabe nada.
      expect(await b.perfil.watchProductor().first, isNull);

      final resultado = await b.sync.entrarConGoogle();

      expect(resultado.ok, isTrue);
      expect(b.api.uid, a.api.uid, reason: 'la misma cuenta remota');
      expect(
        b.usuarioId,
        isNot(a.usuarioId),
        reason: 'pero otra identidad de instalación',
      );

      // Los mismos ids de fila: no se reescribió ninguna clave.
      final productor = await b.perfil.watchProductor().first;
      expect(productor!.id, ids.productor);
      expect(productor.nombreCompleto, 'Diego Parra');
      // Y adoptados por la instalación B.
      expect(productor.usuarioId, b.usuarioId);

      final finca = await b.perfil.watchFinca(productor.id).first;
      expect(finca!.id, ids.finca);
      final lotes = await b.perfil.watchLotes(finca.id).first;
      expect(lotes.single.id, ids.lote);
      expect(await b.lotes.watchActividades(ids.lote).first, hasLength(1));
      expect(await b.lotes.watchCosechas(ids.lote).first, hasLength(1));
      expect(await b.lotes.watchDiagnosticos(ids.lote).first, hasLength(1));
      expect(await b.lotes.watchKgDelAnio(ids.lote, 2026).first, 125.5);
    });

    test('mientras baja, la app no puede ofrecer crear un perfil', () async {
      final a = await instalar();
      await sembrarFinca(a);
      await a.sync.sincronizar();
      await a.sync.entrarConGoogle();

      final b = await instalar();
      // Instalación normal: nada bloquea.
      expect((await b.db.syncDao.sesionActual())!.descargaInicial, isTrue);

      // Si la descarga falla, el bloqueo se mantiene: no se puede registrar
      // hasta saber si la cuenta ya tenía datos.
      b.api.fallosEnDescarga = 1;
      final fallido = await b.sync.entrarConGoogle();
      expect(fallido.ok, isFalse);
      expect((await b.db.syncDao.sesionActual())!.descargaInicial, isFalse);
      expect(await b.perfil.watchProductor().first, isNull);

      // Al reintentar y salir bien, se levanta el bloqueo y ya hay datos.
      await b.sync.sincronizar();
      expect((await b.db.syncDao.sesionActual())!.descargaInicial, isTrue);
      expect(await b.perfil.watchProductor().first, isNotNull);
    });

    test('si Google no deja entrar, el registro no queda bloqueado', () async {
      final b = await instalar();
      b.api.googleCancela = true;
      final resultado = await b.sync.entrarConGoogle();

      expect(resultado.ok, isFalse);
      final sesion = await b.db.syncDao.sesionActual();
      expect(sesion!.correo, isNull);
      expect(sesion.descargaInicial, isTrue);
    });

    test('sincronizar después de entrar mantiene la misma cuenta', () async {
      final a = await instalar();
      await sembrarFinca(a);
      await a.sync.sincronizar();
      await a.sync.entrarConGoogle();

      final b = await instalar();
      await b.sync.entrarConGoogle();
      final uidTrasEntrar = b.api.uid;

      await b.sync.sincronizar();

      expect(b.api.uid, uidTrasEntrar);
      expect(b.api.uid, a.api.uid);
    });
  });

  group('dos dispositivos, una cuenta', () {
    late Instalacion a;
    late Instalacion b;
    late ({String productor, String finca, String lote}) ids;

    setUp(() async {
      a = await instalar();
      ids = await sembrarFinca(a);
      await a.sync.sincronizar();
      await a.sync.entrarConGoogle();
      b = await instalar();
      await b.sync.entrarConGoogle();
    });

    test('A crea una cosecha y B la recibe', () async {
      await a.lotes.registrarCosecha(
        loteId: ids.lote,
        fecha: DateTime(2026, 5, 1),
        cantidadKg: 40,
      );
      await a.sync.sincronizar();

      final resultado = await b.sync.sincronizar();

      expect(resultado.bajados, 1);
      expect(await b.lotes.watchCosechas(ids.lote).first, hasLength(2));
      expect(await b.lotes.watchKgDelAnio(ids.lote, 2026).first, 165.5);
    });

    test('B crea una labor y A la recibe', () async {
      await b.lotes.registrarActividad(
        loteId: ids.lote,
        tipo: TipoActividad.fertilizacion,
        fecha: DateTime(2026, 6, 1),
        observaciones: 'Abono orgánico',
      );
      await b.sync.sincronizar();

      await a.sync.sincronizar();

      final actividades = await a.lotes.watchActividades(ids.lote).first;
      expect(actividades, hasLength(2));
      expect(actividades.first.tipoActividad, TipoActividad.fertilizacion);
    });

    test('lo anotado sin señal llega cuando vuelve la conexión', () async {
      a.api.fallosProgramados = 1;
      await a.lotes.registrarCosecha(
        loteId: ids.lote,
        fecha: DateTime(2026, 7, 1),
        cantidadKg: 12,
      );

      final sinRed = await a.sync.sincronizar();
      expect(sinRed.ok, isFalse);
      expect(await a.db.syncDao.watchPendientes().first, 1);

      await a.sync.sincronizar();
      expect(await a.db.syncDao.watchPendientes().first, 0);

      await b.sync.sincronizar();
      expect(await b.lotes.watchCosechas(ids.lote).first, hasLength(2));
    });

    test('A borra un lote y B recibe el borrado con su cascada', () async {
      await a.perfil.borrarLote(ids.lote);
      await a.sync.sincronizar();

      await b.sync.sincronizar();

      final finca = (await b.perfil.watchFinca(
        (await b.perfil.watchProductor().first)!.id,
      ).first)!;
      expect(await b.perfil.watchLotes(finca.id).first, isEmpty);
      expect(await b.lotes.watchActividades(ids.lote).first, isEmpty);
      expect(await b.lotes.watchCosechas(ids.lote).first, isEmpty);
      expect(await b.lotes.watchDiagnosticos(ids.lote).first, isEmpty);
      // Nada quedó pendiente en B: el borrado lo decidió A.
      expect(await b.db.syncDao.watchPendientes().first, 0);
    });

    test('conflicto: gana el último en sincronizar y queda anotado', () async {
      // B edita y sincroniza primero.
      await b.perfil.guardarLote(
        id: ids.lote,
        fincaId: ids.finca,
        nombre: 'Nombre de B',
        areaSembradaHa: 3,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020, 3, 15),
      );
      await b.sync.sincronizar();

      // A edita sin señal y sincroniza después: su push va antes del pull.
      await a.perfil.guardarLote(
        id: ids.lote,
        fincaId: ids.finca,
        nombre: 'Nombre de A',
        areaSembradaHa: 4,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020, 3, 15),
      );
      await a.sync.sincronizar();

      final enA = await a.perfil.watchLotes(ids.finca).first;
      expect(enA.single.nombre, 'Nombre de A');

      // Y B recibe la versión de A en su siguiente pasada.
      await b.sync.sincronizar();
      final enB = await b.perfil.watchLotes(ids.finca).first;
      expect(enB.single.nombre, 'Nombre de A');
    });

    test('un cambio local pendiente no lo pisa la descarga y se anota',
        () async {
      await b.perfil.guardarLote(
        id: ids.lote,
        fincaId: ids.finca,
        nombre: 'Nombre de B',
        areaSembradaHa: 3,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020, 3, 15),
      );
      await b.sync.sincronizar();

      await a.perfil.guardarLote(
        id: ids.lote,
        fincaId: ids.finca,
        nombre: 'Nombre local de A',
        areaSembradaHa: 4,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020, 3, 15),
      );
      final soloDescarga = SyncService(
        baseDatos: a.db,
        apiRemota: ApiSinSubida(a.api),
        usuarioLocal: a.usuarioId,
      );
      final resultado = await soloDescarga.sincronizar();

      expect(
        (await a.perfil.watchLotes(ids.finca).first).single.nombre,
        'Nombre local de A',
      );
      expect(
        resultado.conflictos.singleWhere((c) => c.entidad == 'lotes').motivo,
        motivoLocalPendiente,
      );
    });
  });

  group('aislamiento entre cuentas', () {
    test('otra cuenta no ve ni puede pisar los datos ajenos', () async {
      final a = await instalar();
      final ids = await sembrarFinca(a);
      await a.sync.sincronizar();
      await a.sync.entrarConGoogle();

      // Una instalación de otra persona: otra cuenta de Google, otro correo.
      final ajena = await instalar();
      ajena.api.correoDeGoogle = 'vecina@gmail.com';
      await ajena.sync.entrarConGoogle();

      // No baja nada de la cuenta de Diego.
      final resultado = await ajena.sync.sincronizar();
      expect(resultado.bajados, 0);
      expect(await ajena.perfil.watchProductor().first, isNull);
      expect(await ajena.db.select(ajena.db.lotes).get(), isEmpty);

      // Y si intenta escribir sobre una fila ajena, el servidor la rechaza.
      await expectLater(
        ajena.api.subir(
          entidad: 'lotes',
          filas: [
            {
              'id': ids.lote,
              'finca_id': ids.finca,
              'nombre': 'Robado',
              'area_sembrada_ha': 1.0,
              'variedad_cacao': 'X',
              'fecha_siembra': DateTime.utc(2020).toIso8601String(),
              'created_at': DateTime.utc(2026).toIso8601String(),
              'deleted_at': null,
            },
          ],
        ),
        throwsA(isA<Object>()),
      );
      // La fila del dueño no cambió.
      final lote = a.api.filasDe('lotes').firstWhere((f) => f['id'] == ids.lote);
      expect(lote['nombre'], 'Lote 1');
    });
  });

  group('cerrar sesión', () {
    test('borra los datos del teléfono pero conserva su identidad', () async {
      final a = await instalar();
      await sembrarFinca(a);
      await a.sync.sincronizar();
      await a.sync.entrarConGoogle();

      await a.sync.cerrarSesion();

      // Local: sin datos y sin cuenta...
      expect(await a.perfil.watchProductor().first, isNull);
      expect(await a.db.select(a.db.lotes).get(), isEmpty);
      expect(await a.db.select(a.db.cosechas).get(), isEmpty);
      final sesion = await a.db.syncDao.sesionActual();
      expect(sesion!.correo, isNull);
      expect(sesion.authUid, isNull);
      // ...pero la identidad de la instalación no cambia: es de este teléfono.
      expect(sesion.usuarioId, a.usuarioId);
      // Y el cursor vuelve a cero, para que la próxima entrada baje todo.
      expect((await a.db.syncDao.cursor('productores')).sello, isNull);
    });

    test('lo del servidor sigue ahí y se recupera al volver a entrar',
        () async {
      final a = await instalar();
      final ids = await sembrarFinca(a);
      await a.sync.sincronizar();
      await a.sync.entrarConGoogle();

      await a.sync.cerrarSesion();
      expect(await a.perfil.watchProductor().first, isNull);

      final vuelta = await a.sync.entrarConGoogle();

      expect(vuelta.ok, isTrue);
      final productor = await a.perfil.watchProductor().first;
      expect(productor!.id, ids.productor);
      final finca = await a.perfil.watchFinca(productor.id).first;
      expect((await a.perfil.watchLotes(finca!.id).first).single.id, ids.lote);
    });
  });

  group('cambiar de cuenta en un teléfono con datos', () {
    test('si Google no deja entrar, no se borra nada', () async {
      final a = await instalar();
      await sembrarFinca(a);
      a.api.googleCancela = true;

      final resultado = await a.sync.entrarConGoogle(reemplazarDatosLocales: true);

      expect(resultado.ok, isFalse);
      // Lo local sigue intacto: el borrado ocurre después de autenticarse.
      expect(await a.perfil.watchProductor().first, isNotNull);
      expect(await a.db.select(a.db.lotes).get(), hasLength(1));
    });

    test('al entrar bien, lo local se reemplaza por lo de la cuenta', () async {
      // Un teléfono con la cuenta y sus datos.
      final dueno = await instalar();
      final ids = await sembrarFinca(dueno);
      await dueno.sync.sincronizar();
      await dueno.sync.entrarConGoogle();

      // Otro teléfono que ya venía usándose sin cuenta.
      final otro = await instalar();
      final suyos = await sembrarFinca(otro);
      expect(suyos.lote, isNot(ids.lote));

      final resultado = await otro.sync.entrarConGoogle(reemplazarDatosLocales: true);

      expect(resultado.ok, isTrue);
      final productor = await otro.perfil.watchProductor().first;
      expect(productor!.id, ids.productor);
      final finca = await otro.perfil.watchFinca(productor.id).first;
      final lotes = await otro.perfil.watchLotes(finca!.id).first;
      // Solo están los de la cuenta; los anteriores se fueron.
      expect(lotes.single.id, ids.lote);
      expect(await otro.db.select(otro.db.lotes).get(), hasLength(1));
    });
  });
}
