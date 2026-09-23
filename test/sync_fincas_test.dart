import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/api_remota.dart';
import 'package:cacao_app/data/sync/sync_result.dart';
import 'package:cacao_app/data/sync/sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

void main() {
  late AppDatabase db;
  late PerfilRepository perfil;
  late LoteRepository lotes;
  late ApiRemotaFalsa api;
  late SyncService sync;
  late String usuarioId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    usuarioId = await db.syncDao.identidadLocal();
    perfil = PerfilRepository(db, usuarioId: usuarioId);
    lotes = LoteRepository(db);
    api = ApiRemotaFalsa();
    sync = SyncService(baseDatos: db, apiRemota: api, usuarioLocal: usuarioId);
    // Sin cuenta no hay servidor: estos tests ejercitan la sincronización, así
    // que entran una vez y ya.
    await sync.entrarConGoogle();
  });
  tearDown(() => db.close());

  Future<String> productorLocal() =>
      perfil.guardarProductor(nombreCompleto: 'Diego Parra');

  Future<String> fincaLocal(String productorId) => perfil.guardarFinca(
    productorId: productorId,
    nombre: 'La Esperanza',
    municipio: 'Rionegro',
    departamento: 'Santander',
  );

  Future<Finca> fincaEnBase() => db.select(db.fincas).getSingle();

  /// Fila como la que dejaría otro dispositivo en el servidor.
  FilaRemota filaFinca(
    String id,
    String productorId, {
    String nombre = 'Finca remota',
    DateTime? borrada,
  }) => {
    'id': id,
    'productor_id': productorId,
    'nombre': nombre,
    'latitud': null,
    'longitud': null,
    'municipio': 'Rionegro',
    'departamento': 'Santander',
    'created_at': DateTime.utc(2026).toIso8601String(),
    'deleted_at': borrada?.toUtc().toIso8601String(),
  };

  group('ciclo completo', () {
    test('crear: nace pendiente y sube sellada por el servidor', () async {
      final productorId = await productorLocal();
      await fincaLocal(productorId);

      expect((await fincaEnBase()).syncStatus, SyncStatus.pending);
      expect((await fincaEnBase()).serverUpdatedAt, isNull);

      final resultado = await sync.sincronizar();

      expect(resultado.ok, isTrue);
      // Un productor y una finca.
      expect(resultado.subidos, 2);
      final fila = await fincaEnBase();
      expect(fila.syncStatus, SyncStatus.synced);
      expect(fila.serverUpdatedAt, isA<DateTime>());
      expect(fila.syncError, isNull);

      final remota = api.filasDe('fincas').single;
      expect(remota['nombre'], 'La Esperanza');
      expect(remota['productor_id'], productorId);
      expect(remota.containsKey('sync_status'), isFalse);
    });

    test('el productor sube antes que su finca', () async {
      final productorId = await productorLocal();
      await fincaLocal(productorId);

      await sync.sincronizar();

      final selloProductor = api.filasDe('productores').single['updated_at']!;
      final selloFinca = api.filasDe('fincas').single['updated_at']!;
      expect(
        (selloProductor as String).compareTo(selloFinca as String) < 0,
        isTrue,
        reason: 'el servidor selló primero al padre',
      );
    });

    test(
      'editar vuelve a dejarla pendiente y la segunda subida la actualiza',
      () async {
        final productorId = await productorLocal();
        final fincaId = await fincaLocal(productorId);
        await sync.sincronizar();
        final selloPrimero = (await fincaEnBase()).serverUpdatedAt;

        await perfil.guardarFinca(
          id: fincaId,
          productorId: productorId,
          nombre: 'La Esperanza Alta',
          municipio: 'Rionegro',
          departamento: 'Santander',
        );
        expect((await fincaEnBase()).syncStatus, SyncStatus.pending);

        final resultado = await sync.sincronizar();

        expect(resultado.subidos, 1);
        final fila = await fincaEnBase();
        expect(fila.syncStatus, SyncStatus.synced);
        expect(fila.serverUpdatedAt!.isAfter(selloPrimero!), isTrue);
        expect(api.filasDe('fincas'), hasLength(1));
        expect(api.filasDe('fincas').single['nombre'], 'La Esperanza Alta');
      },
    );

    test('el borrado suave viaja como deleted_at', () async {
      final productorId = await productorLocal();
      final fincaId = await fincaLocal(productorId);
      await sync.sincronizar();

      await db.fincasDao.borrar(fincaId);
      expect((await fincaEnBase()).syncStatus, SyncStatus.pending);

      await sync.sincronizar();

      expect(api.filasDe('fincas').single['deleted_at'], isA<String>());
      expect((await fincaEnBase()).syncStatus, SyncStatus.synced);
    });

    test('repetir la sincronización no duplica ni deja pendientes', () async {
      final productorId = await productorLocal();
      await fincaLocal(productorId);

      await sync.sincronizar();
      await sync.sincronizar();
      await sync.sincronizar();

      expect(api.filasDe('fincas'), hasLength(1));
      expect(await db.select(db.fincas).get(), hasLength(1));
      expect((await fincaEnBase()).syncStatus, SyncStatus.synced);
    });

    test(
      'tras un fallo de red la finca sigue pendiente y el reintento la sube',
      () async {
        final productorId = await productorLocal();
        await fincaLocal(productorId);
        api.fallosProgramados = 1;

        final fallida = await sync.sincronizar();

        expect(fallida.ok, isFalse);
        expect((await fincaEnBase()).syncStatus, SyncStatus.pending);

        final buena = await sync.sincronizar();

        expect(buena.ok, isTrue);
        expect((await fincaEnBase()).syncStatus, SyncStatus.synced);
        expect(api.filasDe('fincas'), hasLength(1));
      },
    );
  });

  group('descarga', () {
    test(
      'una finca de otro dispositivo entra si su productor ya está aquí',
      () async {
        final productorId = await productorLocal();
        await sync.sincronizar();
        api.sembrar('fincas', filaFinca('finca-remota', productorId));

        final resultado = await sync.sincronizar();

        expect(resultado.bajados, 1);
        final fila = await fincaEnBase();
        expect(fila.id, 'finca-remota');
        expect(fila.nombre, 'Finca remota');
        expect(fila.syncStatus, SyncStatus.synced);
        expect(fila.serverUpdatedAt, isA<DateTime>());
      },
    );

    test('la segunda pasada no vuelve a aplicar lo ya bajado', () async {
      final productorId = await productorLocal();
      await sync.sincronizar();
      api.sembrar('fincas', filaFinca('finca-remota', productorId));

      expect((await sync.sincronizar()).bajados, 1);
      expect((await sync.sincronizar()).bajados, 0);
      expect(await db.select(db.fincas).get(), hasLength(1));
    });

    test(
      'un cambio local pendiente no lo pisa la descarga y queda anotado',
      () async {
        final productorId = await productorLocal();
        final fincaId = await fincaLocal(productorId);
        await sync.sincronizar();
        api.sembrar(
          'fincas',
          filaFinca(fincaId, productorId, nombre: 'Nombre del servidor'),
        );
        await perfil.guardarFinca(
          id: fincaId,
          productorId: productorId,
          nombre: 'Nombre local',
          municipio: 'Rionegro',
          departamento: 'Santander',
        );

        final soloDescarga = SyncService(
          baseDatos: db,
          apiRemota: ApiSinSubida(api),
          usuarioLocal: usuarioId,
        );
        final resultado = await soloDescarga.sincronizar();

        expect((await fincaEnBase()).nombre, 'Nombre local');
        final conflicto = resultado.conflictos.singleWhere(
          (c) => c.entidad == 'fincas',
        );
        expect(conflicto.id, fincaId);
        expect(conflicto.motivo, motivoLocalPendiente);
      },
    );
  });

  group('hijo antes que el padre', () {
    test('se aplaza, se anota y el cursor no avanza', () async {
      api.sembrar('fincas', filaFinca('finca-huerfana', 'productor-fantasma'));

      final resultado = await sync.sincronizar();

      expect(resultado.ok, isTrue);
      expect(resultado.bajados, 0);
      expect(await db.select(db.fincas).get(), isEmpty);
      final conflicto = resultado.conflictos.single;
      expect(conflicto.id, 'finca-huerfana');
      expect(conflicto.motivo, motivoPadreAusente);
      // Sin cursor guardado, la próxima pasada vuelve a intentarlo.
      expect((await db.syncDao.cursor('fincas')).sello, isNull);
    });

    test('cuando el padre llega, la siguiente pasada la aplica sola', () async {
      api.sembrar('fincas', filaFinca('finca-huerfana', 'productor-remoto'));
      await sync.sincronizar();

      api.sembrar('productores', {
        'id': 'productor-remoto',
        'usuario_id': 'auth-de-otro',
        'nombre_completo': 'Ana Gómez',
        'telefono': null,
        'email': null,
        'asociacion_id': null,
        'created_at': DateTime.utc(2026).toIso8601String(),
        'deleted_at': null,
      });

      final resultado = await sync.sincronizar();

      expect(resultado.bajados, 2);
      expect((await fincaEnBase()).id, 'finca-huerfana');
      expect(resultado.conflictos, isEmpty);
      expect((await db.syncDao.cursor('fincas')).id, 'finca-huerfana');
    });
  });

  group('borrado remoto de la finca', () {
    late String productorId;
    late String fincaId;
    late String loteId;

    setUp(() async {
      productorId = await productorLocal();
      fincaId = await fincaLocal(productorId);
      loteId = await perfil.guardarLote(
        fincaId: fincaId,
        nombre: 'Lote 1',
        areaSembradaHa: 2,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020),
      );
      await lotes.registrarCosecha(
        loteId: loteId,
        fecha: DateTime(2026, 3, 1),
        cantidadKg: 50,
      );
      await sync.sincronizar();
      // Los hijos aún no se sincronizan (E2 en adelante): se dejan en un estado
      // ya sincronizado para aislar el efecto de la cascada remota.
      await db.customUpdate("UPDATE lotes SET sync_status = 'synced'");
      await db.customUpdate("UPDATE cosechas SET sync_status = 'synced'");
    });

    test(
      'arrastra lotes e hijos, y los deja como recibidos, no pendientes',
      () async {
        api.sembrar(
          'fincas',
          filaFinca(fincaId, productorId, borrada: DateTime.utc(2026, 6)),
        );

        final resultado = await sync.sincronizar();

        expect(resultado.bajados, 1);
        final lote = await db.select(db.lotes).getSingle();
        expect(lote.deletedAt, isA<DateTime>());
        // Clave: si quedara pendiente, este dispositivo subiría un borrado que
        // en realidad no decidió, y podría ganar un conflicto por accidente.
        expect(lote.syncStatus, SyncStatus.synced);

        final cosecha = await db.select(db.cosechas).getSingle();
        expect(cosecha.deletedAt, isA<DateTime>());
        expect(cosecha.syncStatus, SyncStatus.synced);

        expect(await perfil.watchLotes(fincaId).first, isEmpty);
      },
    );

    test(
      'si un hijo tenía cambios locales, se descartan pero queda anotado',
      () async {
        await perfil.guardarLote(
          id: loteId,
          fincaId: fincaId,
          nombre: 'Lote 1 renombrado',
          areaSembradaHa: 3,
          variedadCacao: 'CCN-51',
          fechaSiembra: DateTime(2020),
        );
        expect(
          (await db.select(db.lotes).getSingle()).syncStatus,
          SyncStatus.pending,
        );

        api.sembrar(
          'fincas',
          filaFinca(fincaId, productorId, borrada: DateTime.utc(2026, 6)),
        );
        final resultado = await sync.sincronizar();

        final conflicto = resultado.conflictos.singleWhere(
          (c) => c.motivo == motivoPadreBorradoRemoto,
        );
        expect(conflicto.id, loteId);
        final lote = await db.select(db.lotes).getSingle();
        expect(lote.deletedAt, isA<DateTime>());
        expect(lote.syncStatus, SyncStatus.synced);
      },
    );
  });
}
