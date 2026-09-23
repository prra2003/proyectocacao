import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/api_remota.dart';
import 'package:cacao_app/data/sync/mapeadores_registros.dart';
import 'package:cacao_app/data/sync/sync_result.dart';
import 'package:cacao_app/data/sync/sync_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

/// Estado de una fila hoja, visto igual para las tres entidades.
typedef EstadoFila = ({DateTime? borrado, SyncStatus estado, DateTime? sello});

/// Lo que cambia entre actividades, cosechas y diagnósticos. El resto del ciclo
/// es idéntico, así que los tests se escriben una vez y se corren tres.
typedef CasoHoja = ({
  String entidad,
  Future<String> Function(String loteId) crear,
  Future<void> Function(String id, String loteId) editar,
  Future<void> Function(String id) borrar,
  FilaRemota Function(String id, String loteId, {DateTime? borrado}) fila,
  Future<EstadoFila?> Function(String id) leer,
  Future<int> Function() contar,
});

void main() {
  late AppDatabase db;
  late PerfilRepository perfil;
  late LoteRepository registros;
  late ApiRemotaFalsa api;
  late SyncService sync;
  late String usuarioId;
  late String fincaId;
  late String loteId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    usuarioId = await db.syncDao.identidadLocal();
    perfil = PerfilRepository(db, usuarioId: usuarioId);
    registros = LoteRepository(db);
    api = ApiRemotaFalsa();
    sync = SyncService(baseDatos: db, apiRemota: api, usuarioLocal: usuarioId);
    // Sin cuenta no hay servidor: estos tests ejercitan la sincronización, así
    // que entran una vez y ya.
    await sync.entrarConGoogle();

    final productorId = await perfil.guardarProductor(
      nombreCompleto: 'Diego Parra',
    );
    fincaId = await perfil.guardarFinca(
      productorId: productorId,
      nombre: 'La Esperanza',
      municipio: 'Rionegro',
      departamento: 'Santander',
    );
    loteId = await perfil.guardarLote(
      fincaId: fincaId,
      nombre: 'Lote 1',
      areaSembradaHa: 2.5,
      variedadCacao: 'CCN-51',
      fechaSiembra: DateTime(2020, 3, 15),
    );
  });
  tearDown(() => db.close());

  FilaRemota comunes(String id, String lote, DateTime? borrado) => {
    'id': id,
    'lote_id': lote,
    'created_at': DateTime.utc(2026).toIso8601String(),
    'deleted_at': borrado?.toUtc().toIso8601String(),
  };

  List<CasoHoja> casos() => [
    (
      entidad: 'actividades_agricolas',
      crear: (lote) => registros.registrarActividad(
        loteId: lote,
        tipo: TipoActividad.poda,
        fecha: DateTime(2026, 2, 1),
        observaciones: 'Poda de formación',
      ),
      editar: (id, lote) => db.customUpdate(
        "UPDATE actividades_agricolas SET observaciones = 'Editada', "
        "sync_status = 'pending', updated_at = ? WHERE id = ?",
        variables: [Variable(DateTime.now()), Variable(id)],
        updates: {db.actividadesAgricolas},
      ),
      borrar: (id) => registros.borrarActividad(id),
      fila: (id, lote, {borrado}) => {
        ...comunes(id, lote, borrado),
        'tipo_actividad': 'fertilizacion',
        'fecha': DateTime.utc(2026, 4, 1).toIso8601String(),
        'observaciones': 'Del otro dispositivo',
      },
      leer: (id) async {
        final f = await db.registrosDao.actividadPorId(id);
        return f == null
            ? null
            : (
                borrado: f.deletedAt,
                estado: f.syncStatus,
                sello: f.serverUpdatedAt,
              );
      },
      contar: () async =>
          (await db.select(db.actividadesAgricolas).get()).length,
    ),
    (
      entidad: 'cosechas',
      crear: (lote) => registros.registrarCosecha(
        loteId: lote,
        fecha: DateTime(2026, 3, 1),
        cantidadKg: 50,
      ),
      editar: (id, lote) => db.customUpdate(
        "UPDATE cosechas SET cantidad_kg = 99, sync_status = 'pending', "
        'updated_at = ? WHERE id = ?',
        variables: [Variable(DateTime.now()), Variable(id)],
        updates: {db.cosechas},
      ),
      borrar: (id) => registros.borrarCosecha(id),
      fila: (id, lote, {borrado}) => {
        ...comunes(id, lote, borrado),
        'fecha': DateTime.utc(2026, 4, 1).toIso8601String(),
        'cantidad_kg': 80.5,
        'observaciones': null,
      },
      leer: (id) async {
        final f = await db.registrosDao.cosechaPorId(id);
        return f == null
            ? null
            : (
                borrado: f.deletedAt,
                estado: f.syncStatus,
                sello: f.serverUpdatedAt,
              );
      },
      contar: () async => (await db.select(db.cosechas).get()).length,
    ),
    (
      entidad: 'diagnosticos',
      crear: (lote) => db.registrosDao.registrarDiagnostico(
        loteId: lote,
        fecha: DateTime(2026, 4, 10),
        estado: EstadoFenologico.floracion,
        notas: 'Buena floración',
      ),
      editar: (id, lote) => db.customUpdate(
        "UPDATE diagnosticos SET notas = 'Editado', sync_status = 'pending', "
        'updated_at = ? WHERE id = ?',
        variables: [Variable(DateTime.now()), Variable(id)],
        updates: {db.diagnosticos},
      ),
      borrar: (id) => db.registrosDao.borrarDiagnostico(id),
      fila: (id, lote, {borrado}) => {
        ...comunes(id, lote, borrado),
        'fecha': DateTime.utc(2026, 5, 1).toIso8601String(),
        'foto_path': null,
        'estado_fenologico': 'maduracion',
        'notas': 'Del otro dispositivo',
      },
      leer: (id) async {
        final f = await db.registrosDao.diagnosticoPorId(id);
        return f == null
            ? null
            : (
                borrado: f.deletedAt,
                estado: f.syncStatus,
                sello: f.serverUpdatedAt,
              );
      },
      contar: () async => (await db.select(db.diagnosticos).get()).length,
    ),
  ];

  test(
    'los datos completos de la labor viajan al servidor y vuelven',
    () async {
      // El documento del SENA pide responsable, costo, producto y lo propio de
      // la siembra. De nada sirve guardarlos si se quedan en el teléfono.
      final id = await registros.registrarActividad(
        loteId: loteId,
        tipo: TipoActividad.siembra,
        fecha: DateTime(2026, 3, 1),
        responsable: 'Juan Pérez',
        costo: 350000,
        arbolesSembrados: 200,
        edadPlantulaMeses: 4,
        insumos: 'Bolsas biodegradables',
        producto: 'NPK 15-15-15',
        cantidadAplicada: '25 kg',
      );

      await sync.sincronizar();

      final subida = api
          .filasDe('actividades_agricolas')
          .firstWhere((f) => f['id'] == id);
      expect(subida['tipo_actividad'], 'siembra');
      expect(subida['responsable'], 'Juan Pérez');
      expect(subida['costo'], 350000);
      expect(subida['arboles_sembrados'], 200);
      expect(subida['producto'], 'NPK 15-15-15');

      // Y de vuelta: un teléfono nuevo que baje esa fila la reconstruye igual.
      final traida = MapeadorActividad.deRemoto(subida);
      expect(traida.responsable.value, 'Juan Pérez');
      expect(traida.costo.value, 350000);
      expect(traida.arbolesSembrados.value, 200);
      expect(traida.insumos.value, 'Bolsas biodegradables');
    },
  );

  test(
    'una columna que el servidor no tiene no borra lo del teléfono',
    () async {
      // Pasó de verdad: la hoja de cálculo todavía no tenía las columnas
      // nuevas, la fila volvió sin ellas y la copia remota pisó con vacíos lo
      // que el productor había escrito. Ausente no es lo mismo que vacío.
      final id = await registros.registrarActividad(
        loteId: loteId,
        tipo: TipoActividad.poda,
        fecha: DateTime(2026, 4, 1),
        subtipoLabor: 'Formación',
        arbolesAfectados: 35,
      );
      await sync.sincronizar();

      // El servidor devuelve la fila **sin** esas columnas.
      final comoLaDevuelveUnServidorViejo =
          Map<String, Object?>.from(
            api
                .filasDe('actividades_agricolas')
                .firstWhere((f) => f['id'] == id),
          )..removeWhere(
            (clave, _) =>
                clave == 'subtipo_labor' || clave == 'arboles_afectados',
          );

      final aplicada = MapeadorActividad.deRemoto(
        comoLaDevuelveUnServidorViejo,
      );
      expect(aplicada.subtipoLabor, const Value<String?>.absent());
      expect(aplicada.arbolesAfectados, const Value<int?>.absent());

      // Y si la columna viene vacía, entonces sí es un nulo de verdad.
      final conColumnaVacia = Map<String, Object?>.from(
        comoLaDevuelveUnServidorViejo,
      )..['subtipo_labor'] = null;
      expect(
        MapeadorActividad.deRemoto(conColumnaVacia).subtipoLabor,
        const Value<String?>(null),
      );
    },
  );

  for (final caso in casos()) {
    group(caso.entidad, () {
      test('crear: nace pendiente y sube sellado después de su lote', () async {
        final id = await caso.crear(loteId);
        expect((await caso.leer(id))!.estado, SyncStatus.pending);

        final resultado = await sync.sincronizar();

        expect(resultado.ok, isTrue);
        // Productor, finca, lote y el registro.
        expect(resultado.subidos, 4);
        final fila = (await caso.leer(id))!;
        expect(fila.estado, SyncStatus.synced);
        expect(fila.sello, isA<DateTime>());

        final selloLote = api.filasDe('lotes').single['updated_at']! as String;
        final selloHoja =
            api.filasDe(caso.entidad).single['updated_at']! as String;
        expect(selloLote.compareTo(selloHoja) < 0, isTrue);
      });

      test(
        'editar vuelve a dejarlo pendiente y lo actualiza sin duplicar',
        () async {
          final id = await caso.crear(loteId);
          await sync.sincronizar();
          final selloPrimero = (await caso.leer(id))!.sello;

          await caso.editar(id, loteId);
          expect((await caso.leer(id))!.estado, SyncStatus.pending);

          final resultado = await sync.sincronizar();

          expect(resultado.subidos, 1);
          expect(api.filasDe(caso.entidad), hasLength(1));
          expect((await caso.leer(id))!.sello!.isAfter(selloPrimero!), isTrue);
        },
      );

      test('el borrado local viaja como deleted_at', () async {
        final id = await caso.crear(loteId);
        await sync.sincronizar();

        await caso.borrar(id);
        await sync.sincronizar();

        expect(api.filasDe(caso.entidad).single['deleted_at'], isA<String>());
        expect((await caso.leer(id))!.estado, SyncStatus.synced);
      });

      test('repetir la sincronización no duplica ni deja pendientes', () async {
        final id = await caso.crear(loteId);
        await sync.sincronizar();
        await sync.sincronizar();
        await sync.sincronizar();

        expect(api.filasDe(caso.entidad), hasLength(1));
        expect(await caso.contar(), 1);
        expect((await caso.leer(id))!.estado, SyncStatus.synced);
      });

      test(
        'tras un fallo de red sigue pendiente y el reintento lo sube',
        () async {
          final id = await caso.crear(loteId);
          api.fallosProgramados = 1;

          expect((await sync.sincronizar()).ok, isFalse);
          expect((await caso.leer(id))!.estado, SyncStatus.pending);

          expect((await sync.sincronizar()).ok, isTrue);
          expect((await caso.leer(id))!.estado, SyncStatus.synced);
        },
      );

      test('un registro remoto entra si su lote ya está aquí', () async {
        await sync.sincronizar();
        api.sembrar(caso.entidad, caso.fila('remoto-1', loteId));

        final resultado = await sync.sincronizar();

        expect(resultado.bajados, 1);
        final fila = (await caso.leer('remoto-1'))!;
        expect(fila.estado, SyncStatus.synced);
        expect(fila.borrado, isNull);
      });

      test('un registro que llega antes que su lote se aplaza y no mueve el cursor', () async {
        api.sembrar(caso.entidad, caso.fila('huerfano', 'lote-que-no-esta'));

        final resultado = await sync.sincronizar();

        expect(await caso.contar(), 0);
        expect(
          resultado.conflictos
              .singleWhere((c) => c.entidad == caso.entidad)
              .motivo,
          motivoPadreAusente,
        );
        expect((await db.syncDao.cursor(caso.entidad)).sello, isNull);
      });

      test('cuando el lote llega, el registro aplazado se aplica solo', () async {
        api.sembrar(caso.entidad, caso.fila('huerfano', loteId));
        // El lote todavía no está en el servidor ni sincronizado aquí... sí lo
        // está localmente, así que se aplica en la misma pasada.
        final resultado = await sync.sincronizar();

        expect(resultado.bajados, 1);
        expect(await caso.contar(), 1);
        expect((await db.syncDao.cursor(caso.entidad)).id, 'huerfano');
        expect((await sync.sincronizar()).bajados, 0);
      });

      test('un registro vivo cuyo lote ya está borrado entra muerto', () async {
        await sync.sincronizar();
        // Otro dispositivo borró el lote.
        api.sembrar('lotes', {
          'id': loteId,
          'finca_id': fincaId,
          'nombre': 'Lote 1',
          'area_sembrada_ha': 2.5,
          'variedad_cacao': 'CCN-51',
          'fecha_siembra': DateTime.utc(2020, 3, 15).toIso8601String(),
          'created_at': DateTime.utc(2026).toIso8601String(),
          'deleted_at': DateTime.utc(2026, 6).toIso8601String(),
        });
        await sync.sincronizar();

        api.sembrar(caso.entidad, caso.fila('tardio', loteId));
        final resultado = await sync.sincronizar();

        final fila = (await caso.leer('tardio'))!;
        expect(fila.borrado, isA<DateTime>());
        expect(fila.estado, SyncStatus.synced);
        expect(
          resultado.conflictos.singleWhere((c) => c.id == 'tardio').motivo,
          motivoPadreBorrado,
        );
      });

      test(
        'un cambio local pendiente no lo pisa la descarga y queda anotado',
        () async {
          final id = await caso.crear(loteId);
          await sync.sincronizar();
          api.sembrar(caso.entidad, caso.fila(id, loteId));
          await caso.editar(id, loteId);

          final soloDescarga = SyncService(
            baseDatos: db,
            apiRemota: ApiSinSubida(api),
            usuarioLocal: usuarioId,
          );
          final resultado = await soloDescarga.sincronizar();

          expect((await caso.leer(id))!.estado, SyncStatus.pending);
          expect(
            resultado.conflictos
                .singleWhere((c) => c.entidad == caso.entidad)
                .motivo,
            motivoLocalPendiente,
          );
        },
      );
    });
  }

  group('árbol completo', () {
    test(
      'borrar el lote localmente sube el borrado de los tres registros',
      () async {
        final actividadId = await registros.registrarActividad(
          loteId: loteId,
          tipo: TipoActividad.riego,
          fecha: DateTime(2026, 2, 1),
        );
        final cosechaId = await registros.registrarCosecha(
          loteId: loteId,
          fecha: DateTime(2026, 3, 1),
          cantidadKg: 10,
        );
        final diagnosticoId = await db.registrosDao.registrarDiagnostico(
          loteId: loteId,
          fecha: DateTime(2026, 4, 1),
          estado: EstadoFenologico.cuajado,
        );
        await sync.sincronizar();

        await perfil.borrarLote(loteId);
        final resultado = await sync.sincronizar();

        // El lote y sus tres registros.
        expect(resultado.subidos, 4);
        for (final entidad in [
          'lotes',
          'actividades_agricolas',
          'cosechas',
          'diagnosticos',
        ]) {
          expect(
            api.filasDe(entidad).single['deleted_at'],
            isA<String>(),
            reason: 'el borrado de $entidad tiene que llegar al servidor',
          );
        }
        for (final id in [actividadId, cosechaId, diagnosticoId]) {
          expect(id, isNotEmpty);
        }
      },
    );

    test('el orden de subida respeta todo el árbol', () async {
      await registros.registrarCosecha(
        loteId: loteId,
        fecha: DateTime(2026, 3, 1),
        cantidadKg: 10,
      );
      await sync.sincronizar();

      final sellos = [
        for (final entidad in ['productores', 'fincas', 'lotes', 'cosechas'])
          api.filasDe(entidad).single['updated_at']! as String,
      ];
      final ordenados = [...sellos]..sort();
      expect(sellos, ordenados);
    });
  });
}
