import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/api_remota.dart';
import 'package:cacao_app/data/sync/sync_result.dart';
import 'package:cacao_app/data/sync/sync_service.dart';
import 'package:cacao_app/data/sync/sync_state.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

void main() {
  late AppDatabase db;
  late PerfilRepository repo;
  late ApiRemotaFalsa api;
  late SyncService sync;
  late String usuarioId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    usuarioId = await db.syncDao.identidadLocal();
    repo = PerfilRepository(db, usuarioId: usuarioId);
    api = ApiRemotaFalsa();
    sync = SyncService(baseDatos: db, apiRemota: api, usuarioLocal: usuarioId);
    // Sin cuenta no hay servidor: estos tests ejercitan la sincronización, así
    // que entran una vez y ya.
    await sync.entrarConGoogle();
  });
  tearDown(() => db.close());

  Future<Productor> productorLocal() => db.select(db.productores).getSingle();

  /// Una fila como la que dejaría otro dispositivo en el servidor.
  FilaRemota filaRemota(String id, String nombre, {DateTime? borrado}) => {
    'id': id,
    'usuario_id': 'auth-de-otro-dispositivo',
    'nombre_completo': nombre,
    'telefono': null,
    'email': null,
    'asociacion_id': null,
    'created_at': DateTime.utc(2026).toIso8601String(),
    'deleted_at': borrado?.toUtc().toIso8601String(),
  };

  group('subida', () {
    test(
      'un productor nuevo nace pendiente y se sube sellado por el servidor',
      () async {
        await repo.guardarProductor(nombreCompleto: 'Diego Parra');

        final antes = await productorLocal();
        expect(antes.syncStatus, SyncStatus.pending);
        expect(antes.serverUpdatedAt, isNull);

        final resultado = await sync.sincronizar();

        expect(resultado.ok, isTrue);
        expect(resultado.subidos, 1);

        final despues = await productorLocal();
        expect(despues.syncStatus, SyncStatus.synced);
        expect(despues.serverUpdatedAt, isNotNull);
        expect(despues.syncError, isNull);

        // Lo que llegó al servidor: sin estado local, con el uid de la sesión.
        final remoto = api.filasDe('productores').single;
        expect(remoto['nombre_completo'], 'Diego Parra');
        expect(remoto['usuario_id'], api.uid);
        expect(remoto.containsKey('sync_status'), isFalse);
        expect(remoto.containsKey('sync_error'), isFalse);
      },
    );

    test(
      'editar vuelve a dejarlo pendiente y la segunda subida lo actualiza',
      () async {
        final id = await repo.guardarProductor(nombreCompleto: 'Diego');
        await sync.sincronizar();
        final selloPrimero = (await productorLocal()).serverUpdatedAt;

        await repo.guardarProductor(id: id, nombreCompleto: 'Diego Parra');
        expect((await productorLocal()).syncStatus, SyncStatus.pending);

        final resultado = await sync.sincronizar();

        expect(resultado.subidos, 1);
        final fila = await productorLocal();
        expect(fila.syncStatus, SyncStatus.synced);
        expect(fila.serverUpdatedAt!.isAfter(selloPrimero!), isTrue);
        expect(
          api.filasDe('productores').single['nombre_completo'],
          'Diego Parra',
        );
        // Sigue siendo la misma fila remota, no una copia.
        expect(api.filasDe('productores'), hasLength(1));
      },
    );

    test(
      'el borrado suave viaja como deleted_at, no como un borrado físico',
      () async {
        final id = await repo.guardarProductor(nombreCompleto: 'Diego');
        await sync.sincronizar();

        await borrarProductorEnCascada(db, id);
        final borrado = await productorLocal();
        expect(borrado.deletedAt, isNotNull);
        expect(borrado.syncStatus, SyncStatus.pending);

        await sync.sincronizar();

        final remoto = api.filasDe('productores').single;
        expect(remoto['deleted_at'], isNotNull);
        expect((await productorLocal()).syncStatus, SyncStatus.synced);
        // La fila sigue en el servidor para que otros dispositivos se enteren.
        expect(api.filasDe('productores'), hasLength(1));
      },
    );
  });

  group('descarga', () {
    test(
      'un productor creado en otro dispositivo llega a la base local',
      () async {
        api.sembrar('productores', filaRemota('remoto-1', 'Ana Gómez'));

        final resultado = await sync.sincronizar();

        expect(resultado.bajados, 1);
        final fila = await productorLocal();
        expect(fila.id, 'remoto-1');
        expect(fila.nombreCompleto, 'Ana Gómez');
        expect(fila.syncStatus, SyncStatus.synced);
        expect(fila.serverUpdatedAt, isNotNull);
        // Se adopta con la identidad de esta instalación.
        expect(fila.usuarioId, usuarioId);
      },
    );

    test(
      'la descarga es incremental: la segunda pasada no vuelve a aplicar',
      () async {
        api.sembrar('productores', filaRemota('remoto-1', 'Ana'));
        final primera = await sync.sincronizar();
        expect(primera.bajados, 1);

        final segunda = await sync.sincronizar();

        expect(segunda.bajados, 0);
        expect(await db.select(db.productores).get(), hasLength(1));
      },
    );

    test('repetir la sincronización no duplica ni deja pendientes', () async {
      await repo.guardarProductor(nombreCompleto: 'Diego');
      api.sembrar('productores', filaRemota('remoto-1', 'Ana'));

      await sync.sincronizar();
      await sync.sincronizar();
      await sync.sincronizar();

      final filas = await db.select(db.productores).get();
      expect(filas, hasLength(2));
      expect(filas.every((f) => f.syncStatus == SyncStatus.synced), isTrue);
      expect(api.filasDe('productores'), hasLength(2));
    });

    test(
      'trae todas las páginas cuando hay más filas que el tamaño de página',
      () async {
        for (var i = 1; i <= 3; i++) {
          api.sembrar('productores', filaRemota('remoto-$i', 'Persona $i'));
        }
        final porPaginas = SyncService(
          baseDatos: db,
          apiRemota: api,
          usuarioLocal: usuarioId,
          tamanoPagina: 1,
        );

        final resultado = await porPaginas.sincronizar();

        expect(resultado.bajados, 3);
        expect(await db.select(db.productores).get(), hasLength(3));
      },
    );
  });

  group('conflictos', () {
    test(
      'un cambio local pendiente no lo pisa la descarga y queda anotado',
      () async {
        // El mismo id existe en los dos lados con contenido distinto.
        final id = await repo.guardarProductor(nombreCompleto: 'Diego');
        await sync.sincronizar();
        api.sembrar('productores', filaRemota(id, 'Version del servidor'));
        await repo.guardarProductor(id: id, nombreCompleto: 'Version local');

        // Se descarga sin subir antes, para forzar el choque.
        final soloDescarga = SyncService(
          baseDatos: db,
          apiRemota: ApiSinSubida(api),
          usuarioLocal: usuarioId,
        );
        final resultado = await soloDescarga.sincronizar();

        expect((await productorLocal()).nombreCompleto, 'Version local');
        expect(resultado.bajados, 0);
        expect(resultado.conflictos, hasLength(1));
        expect(resultado.conflictos.single.id, id);
        expect(resultado.conflictos.single.motivo, motivoLocalPendiente);
      },
    );

    test('gana el último en sincronizar: push va antes que pull', () async {
      final id = await repo.guardarProductor(nombreCompleto: 'Diego');
      await sync.sincronizar();
      // Otro dispositivo escribió primero.
      api.sembrar('productores', filaRemota(id, 'Version del servidor'));
      // Este dispositivo edita después y sincroniza.
      await repo.guardarProductor(id: id, nombreCompleto: 'Version local');

      await sync.sincronizar();

      expect((await productorLocal()).nombreCompleto, 'Version local');
      expect(
        api.filasDe('productores').single['nombre_completo'],
        'Version local',
      );
    });
  });

  group('errores', () {
    test(
      'si la API falla, el registro sigue pendiente y se sube al reintentar',
      () async {
        await repo.guardarProductor(nombreCompleto: 'Diego');
        api.fallosProgramados = 1;

        final fallida = await sync.sincronizar();

        expect(fallida.ok, isFalse);
        expect(fallida.error, 'sin conexión');
        expect(sync.estado.value.estado, EstadoSync.error);
        expect((await productorLocal()).syncStatus, SyncStatus.pending);

        final buena = await sync.sincronizar();

        expect(buena.ok, isTrue);
        expect(buena.subidos, 1);
        expect((await productorLocal()).syncStatus, SyncStatus.synced);
        expect(sync.estado.value.estado, EstadoSync.ok);
      },
    );

    test('el cursor no avanza si la descarga se interrumpe', () async {
      api.sembrar('productores', filaRemota('remoto-1', 'Ana'));
      api.sembrar('productores', filaRemota('remoto-2', 'Luis'));
      api.fallosEnDescarga = 1;

      final fallida = await sync.sincronizar();

      expect(fallida.ok, isFalse);
      expect((await db.syncDao.cursor('productores')).sello, isNull);

      final buena = await sync.sincronizar();

      expect(buena.bajados, 2);
      expect((await db.syncDao.cursor('productores')).sello, isA<DateTime>());
    });
  });

  test('la identidad local se crea una vez y no cambia', () async {
    expect(await db.syncDao.identidadLocal(), usuarioId);
    await sync.sincronizar();
    // La sesión anónima se guarda aparte, sin tocar la identidad local.
    expect(await db.syncDao.authUid(), api.uid);
    expect(await db.syncDao.identidadLocal(), usuarioId);
  });

  test('solo se ve el productor de esta instalación', () async {
    await repo.guardarProductor(nombreCompleto: 'Diego');
    await db
        .into(db.productores)
        .insert(
          ProductoresCompanion.insert(
            usuarioId: const Value('otra-instalacion'),
            nombreCompleto: 'Productor ajeno',
          ),
        );

    expect((await repo.watchProductor().first)!.nombreCompleto, 'Diego');
    expect(await db.select(db.productores).get(), hasLength(2));
  });
}
