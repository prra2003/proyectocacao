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
  late LoteRepository registros;
  late ApiRemotaFalsa api;
  late SyncService sync;
  late String usuarioId;
  late String productorId;
  late String fincaId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    usuarioId = await db.syncDao.identidadLocal();
    perfil = PerfilRepository(db, usuarioId: usuarioId);
    registros = LoteRepository(db);
    api = ApiRemotaFalsa();
    sync = SyncService(baseDatos: db, apiRemota: api, usuarioLocal: usuarioId);

    productorId = await perfil.guardarProductor(nombreCompleto: 'Diego Parra');
    fincaId = await perfil.guardarFinca(
      productorId: productorId,
      nombre: 'La Esperanza',
      municipio: 'Rionegro',
      departamento: 'Santander',
    );
  });
  tearDown(() => db.close());

  Future<String> loteLocal({String nombre = 'Lote 1'}) => perfil.guardarLote(
    fincaId: fincaId,
    nombre: nombre,
    areaSembradaHa: 2.5,
    variedadCacao: 'CCN-51',
    fechaSiembra: DateTime(2020, 3, 15),
  );

  Future<Lote> loteEnBase() => db.select(db.lotes).getSingle();

  FilaRemota filaLote(
    String id,
    String finca, {
    String nombre = 'Lote remoto',
    DateTime? borrado,
  }) => {
    'id': id,
    'finca_id': finca,
    'nombre': nombre,
    'area_sembrada_ha': 3.0,
    'variedad_cacao': 'ICS-95',
    'fecha_siembra': DateTime.utc(2019, 5, 10).toIso8601String(),
    'created_at': DateTime.utc(2026).toIso8601String(),
    'deleted_at': borrado?.toUtc().toIso8601String(),
  };

  FilaRemota filaFinca(String id, String productor, {DateTime? borrada}) => {
    'id': id,
    'productor_id': productor,
    'nombre': 'La Esperanza',
    'latitud': null,
    'longitud': null,
    'municipio': 'Rionegro',
    'departamento': 'Santander',
    'created_at': DateTime.utc(2026).toIso8601String(),
    'deleted_at': borrada?.toUtc().toIso8601String(),
  };

  /// Deja el árbol local completo y ya sincronizado.
  Future<String> arbolSincronizado() async {
    final loteId = await loteLocal();
    await registros.registrarCosecha(
      loteId: loteId,
      fecha: DateTime(2026, 3, 1),
      cantidadKg: 50,
    );
    await registros.registrarActividad(
      loteId: loteId,
      tipo: TipoActividad.poda,
      fecha: DateTime(2026, 2, 1),
    );
    await sync.sincronizar();
    // Actividades y cosechas entran en E3-E5; hasta entonces se marcan a mano
    // para poder observar solo el efecto de las cascadas.
    await db.customUpdate("UPDATE cosechas SET sync_status = 'synced'");
    await db.customUpdate(
      "UPDATE actividades_agricolas SET sync_status = 'synced'",
    );
    return loteId;
  }

  group('ciclo completo', () {
    test('crear: nace pendiente y sube sellado, después del productor y la finca',
        () async {
      await loteLocal();
      expect((await loteEnBase()).syncStatus, SyncStatus.pending);

      final resultado = await sync.sincronizar();

      expect(resultado.ok, isTrue);
      expect(resultado.subidos, 3);
      final fila = await loteEnBase();
      expect(fila.syncStatus, SyncStatus.synced);
      expect(fila.serverUpdatedAt, isA<DateTime>());

      final selloProductor =
          api.filasDe('productores').single['updated_at']! as String;
      final selloFinca = api.filasDe('fincas').single['updated_at']! as String;
      final selloLote = api.filasDe('lotes').single['updated_at']! as String;
      expect(selloProductor.compareTo(selloFinca) < 0, isTrue);
      expect(selloFinca.compareTo(selloLote) < 0, isTrue);
    });

    test('editar y volver a sincronizar actualiza la misma fila remota',
        () async {
      final loteId = await loteLocal();
      await sync.sincronizar();
      final selloPrimero = (await loteEnBase()).serverUpdatedAt;

      await perfil.guardarLote(
        id: loteId,
        fincaId: fincaId,
        nombre: 'Lote 1 ampliado',
        areaSembradaHa: 4,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020, 3, 15),
      );
      final resultado = await sync.sincronizar();

      expect(resultado.subidos, 1);
      expect(api.filasDe('lotes'), hasLength(1));
      expect(api.filasDe('lotes').single['nombre'], 'Lote 1 ampliado');
      expect(
        (await loteEnBase()).serverUpdatedAt!.isAfter(selloPrimero!),
        isTrue,
      );
    });

    test('el borrado local viaja como deleted_at', () async {
      final loteId = await loteLocal();
      await sync.sincronizar();

      await perfil.borrarLote(loteId);
      await sync.sincronizar();

      expect(api.filasDe('lotes').single['deleted_at'], isA<String>());
      expect((await loteEnBase()).syncStatus, SyncStatus.synced);
    });

    test('repetir la sincronización no duplica ni deja pendientes', () async {
      await loteLocal();
      await sync.sincronizar();
      await sync.sincronizar();
      await sync.sincronizar();

      expect(api.filasDe('lotes'), hasLength(1));
      expect(await db.select(db.lotes).get(), hasLength(1));
      expect((await loteEnBase()).syncStatus, SyncStatus.synced);
    });

    test('tras un fallo de red sigue pendiente y el reintento lo sube',
        () async {
      await loteLocal();
      api.fallosProgramados = 1;

      expect((await sync.sincronizar()).ok, isFalse);
      expect((await loteEnBase()).syncStatus, SyncStatus.pending);

      expect((await sync.sincronizar()).ok, isTrue);
      expect((await loteEnBase()).syncStatus, SyncStatus.synced);
    });
  });

  group('descarga y dependencias', () {
    test('un lote remoto entra si su finca ya está aquí', () async {
      await sync.sincronizar();
      api.sembrar('lotes', filaLote('lote-remoto', fincaId));

      final resultado = await sync.sincronizar();

      expect(resultado.bajados, 1);
      final fila = await loteEnBase();
      expect(fila.id, 'lote-remoto');
      expect(fila.variedadCacao, 'ICS-95');
      expect(fila.syncStatus, SyncStatus.synced);
      expect(fila.deletedAt, isNull);
    });

    test('un lote que llega antes que su finca se aplaza y no mueve el cursor',
        () async {
      api.sembrar('lotes', filaLote('lote-huerfano', 'finca-que-no-esta'));

      final resultado = await sync.sincronizar();

      expect(resultado.ok, isTrue);
      expect(await db.select(db.lotes).get(), isEmpty);
      final conflicto = resultado.conflictos.singleWhere(
        (c) => c.entidad == 'lotes',
      );
      expect(conflicto.motivo, motivoPadreAusente);
      expect((await db.syncDao.cursor('lotes')).sello, isNull);
    });

    test('cuando la finca llega, el lote aplazado se aplica solo y sin duplicar',
        () async {
      api.sembrar('lotes', filaLote('lote-huerfano', 'finca-remota'));
      await sync.sincronizar();
      await sync.sincronizar();
      expect(await db.select(db.lotes).get(), isEmpty);

      // Ahora aparece la finca padre (de este mismo productor).
      api.sembrar('fincas', filaFinca('finca-remota', productorId));
      final resultado = await sync.sincronizar();

      expect(resultado.bajados, 2);
      expect(await db.select(db.lotes).get(), hasLength(1));
      expect((await db.syncDao.cursor('lotes')).id, 'lote-huerfano');

      // Y no se vuelve a aplicar.
      expect((await sync.sincronizar()).bajados, 0);
      expect(await db.select(db.lotes).get(), hasLength(1));
    });

    test('un lote vivo cuya finca ya está borrada entra muerto, sin revivirla',
        () async {
      await sync.sincronizar();
      // Otro dispositivo borró la finca.
      api.sembrar(
        'fincas',
        filaFinca(fincaId, productorId, borrada: DateTime.utc(2026, 6)),
      );
      await sync.sincronizar();
      expect((await db.select(db.fincas).getSingle()).deletedAt, isA<DateTime>());

      // Y ahora llega un lote vivo de esa finca.
      api.sembrar('lotes', filaLote('lote-tardio', fincaId));
      final resultado = await sync.sincronizar();

      final lote = await loteEnBase();
      expect(lote.id, 'lote-tardio');
      expect(lote.deletedAt, isA<DateTime>(), reason: 'entra ya borrado');
      expect(lote.syncStatus, SyncStatus.synced);
      // La finca sigue borrada: no se revive por la llegada de un hijo.
      expect((await db.select(db.fincas).getSingle()).deletedAt, isA<DateTime>());
      expect(
        resultado.conflictos.singleWhere((c) => c.id == 'lote-tardio').motivo,
        motivoPadreBorrado,
      );
    });

    test('varias filas con el mismo updated_at se bajan todas, paginando de a una',
        () async {
      await sync.sincronizar();
      final mismoSello = DateTime.utc(2026, 7, 1, 12);
      for (final id in ['lote-a', 'lote-b', 'lote-c']) {
        api.sembrar('lotes', filaLote(id, fincaId), sello: mismoSello);
      }
      final unaPorPagina = SyncService(
        baseDatos: db,
        apiRemota: api,
        usuarioLocal: usuarioId,
        tamanoPagina: 1,
      );

      final resultado = await unaPorPagina.sincronizar();

      expect(resultado.bajados, 3);
      expect(await db.select(db.lotes).get(), hasLength(3));
      final cursor = await db.syncDao.cursor('lotes');
      expect(cursor.sello, mismoSello.toLocal());
      expect(cursor.id, 'lote-c');
      // Y una segunda pasada no vuelve a traerlas.
      expect((await unaPorPagina.sincronizar()).bajados, 0);
    });
  });

  group('conflictos', () {
    test('edición concurrente: gana el último en sincronizar', () async {
      final loteId = await loteLocal();
      await sync.sincronizar();
      // El otro dispositivo edita y sincroniza primero.
      api.sembrar(
        'lotes',
        filaLote(loteId, fincaId, nombre: 'Nombre del servidor'),
      );
      // Este edita después y sincroniza: push va antes que pull.
      await perfil.guardarLote(
        id: loteId,
        fincaId: fincaId,
        nombre: 'Nombre local',
        areaSembradaHa: 2.5,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020, 3, 15),
      );

      await sync.sincronizar();

      expect((await loteEnBase()).nombre, 'Nombre local');
      expect(api.filasDe('lotes').single['nombre'], 'Nombre local');
    });

    test('un cambio local pendiente no lo pisa la descarga y queda anotado',
        () async {
      final loteId = await loteLocal();
      await sync.sincronizar();
      api.sembrar(
        'lotes',
        filaLote(loteId, fincaId, nombre: 'Nombre del servidor'),
      );
      await perfil.guardarLote(
        id: loteId,
        fincaId: fincaId,
        nombre: 'Nombre local',
        areaSembradaHa: 2.5,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020, 3, 15),
      );

      final soloDescarga = SyncService(
        baseDatos: db,
        apiRemota: ApiSinSubida(api),
        usuarioLocal: usuarioId,
      );
      final resultado = await soloDescarga.sincronizar();

      expect((await loteEnBase()).nombre, 'Nombre local');
      expect(
        resultado.conflictos.singleWhere((c) => c.entidad == 'lotes').motivo,
        motivoLocalPendiente,
      );
    });
  });

  group('cascadas remotas', () {
    test('Caso A: finca borrada en el servidor arrastra lote y registros',
        () async {
      await arbolSincronizado();

      api.sembrar(
        'fincas',
        filaFinca(fincaId, productorId, borrada: DateTime.utc(2026, 6)),
      );
      await sync.sincronizar();

      final lote = await loteEnBase();
      expect(lote.deletedAt, isA<DateTime>());
      expect(lote.syncStatus, SyncStatus.synced);
      for (final estado in await _estadosDeRegistros(db)) {
        expect(estado.borrado, isA<DateTime>());
        expect(estado.sync, SyncStatus.synced);
      }
      // Nada quedó pendiente: no se sube un borrado que no decidimos aquí.
      expect(await _hayPendientes(db), isFalse);
    });

    test('Caso B: lote borrado en el servidor arrastra sus registros',
        () async {
      final loteId = await arbolSincronizado();

      api.sembrar(
        'lotes',
        filaLote(loteId, fincaId, borrado: DateTime.utc(2026, 6)),
      );
      await sync.sincronizar();

      expect((await loteEnBase()).deletedAt, isA<DateTime>());
      for (final estado in await _estadosDeRegistros(db)) {
        expect(estado.borrado, isA<DateTime>());
        expect(estado.sync, SyncStatus.synced);
      }
      expect(await _hayPendientes(db), isFalse);
      // La finca no se toca: la cascada solo baja.
      expect((await db.select(db.fincas).getSingle()).deletedAt, isNull);
    });

    test('Caso C: registros locales pendientes se descartan pero se anotan',
        () async {
      final loteId = await arbolSincronizado();
      // Un registro con cambios locales sin subir.
      await registros.registrarCosecha(
        loteId: loteId,
        fecha: DateTime(2026, 5, 1),
        cantidadKg: 12,
      );

      api.sembrar(
        'lotes',
        filaLote(loteId, fincaId, borrado: DateTime.utc(2026, 6)),
      );
      final resultado = await sync.sincronizar();

      expect(
        resultado.conflictos.where((c) => c.motivo == motivoPadreBorradoRemoto),
        hasLength(1),
      );
      expect(await _hayPendientes(db), isFalse);
      for (final estado in await _estadosDeRegistros(db)) {
        expect(estado.borrado, isA<DateTime>());
        expect(estado.sync, SyncStatus.synced);
      }
    });

    test('lote local pendiente + finca borrada remotamente: manda el borrado',
        () async {
      final loteId = await arbolSincronizado();
      await perfil.guardarLote(
        id: loteId,
        fincaId: fincaId,
        nombre: 'Editado sin subir',
        areaSembradaHa: 9,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020, 3, 15),
      );
      expect((await loteEnBase()).syncStatus, SyncStatus.pending);

      api.sembrar(
        'fincas',
        filaFinca(fincaId, productorId, borrada: DateTime.utc(2026, 6)),
      );
      final resultado = await sync.sincronizar();

      final lote = await loteEnBase();
      expect(lote.deletedAt, isA<DateTime>());
      expect(lote.syncStatus, SyncStatus.synced);
      expect((await db.select(db.fincas).getSingle()).deletedAt, isA<DateTime>());
      expect(
        resultado.conflictos.singleWhere((c) => c.id == loteId).motivo,
        motivoPadreBorradoRemoto,
      );
      // Ni el lote ni sus registros vuelven a la cola de subida.
      expect(await _hayPendientes(db), isFalse);
    });
  });
}

Future<List<({DateTime? borrado, SyncStatus sync})>> _estadosDeRegistros(
  AppDatabase db,
) async {
  final actividades = await db.select(db.actividadesAgricolas).get();
  final cosechas = await db.select(db.cosechas).get();
  return [
    for (final a in actividades) (borrado: a.deletedAt, sync: a.syncStatus),
    for (final c in cosechas) (borrado: c.deletedAt, sync: c.syncStatus),
  ];
}

Future<bool> _hayPendientes(AppDatabase db) async {
  final filas = await db
      .customSelect(
        "SELECT 1 FROM lotes WHERE sync_status = 'pending' "
        "UNION ALL SELECT 1 FROM actividades_agricolas "
        "WHERE sync_status = 'pending' "
        "UNION ALL SELECT 1 FROM cosechas WHERE sync_status = 'pending'",
      )
      .get();
  return filas.isNotEmpty;
}
