import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../daos/daos.dart';
import 'asociaciones_semilla.dart';
import 'enums.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Asociaciones,
    Productores,
    Fincas,
    Lotes,
    ActividadesAgricolas,
    Cosechas,
    Diagnosticos,
    Sesion,
    SyncMeta,
  ],
  daos: [ProductoresDao, FincasDao, LotesDao, RegistrosDao, SyncDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _conexion());

  /// En Android/iOS es un archivo SQLite; en el navegador, el mismo SQLite
  /// compilado a WebAssembly, guardado por el navegador. Los archivos
  /// `sqlite3.wasm` y `drift_worker.js` viven en `web/` y se sirven junto a la
  /// aplicación: sin ellos, la versión web no arranca.
  static QueryExecutor _conexion() {
    return driftDatabase(
      name: 'cacao_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, desde, hasta) async {
      if (desde < 13) {
        await m.addColumn(lotes, lotes.fotoPath);
        await m.addColumn(sesion, sesion.nombreCuenta);
      }
      // v8 a v12: lo que trajo el módulo de reportes. Van numeradas encima de
      // la v7 de este repositorio; en la copia del equipo tenían otros
      // números porque partieron de la v5.
      if (desde < 12) {
        await m.addColumn(cosechas, cosechas.tipoProducto);
        await m.addColumn(cosechas, cosechas.fotoPath);
      }
      if (desde < 11) {
        await m.addColumn(actividadesAgricolas, actividadesAgricolas.producto);
        await m.addColumn(
          actividadesAgricolas,
          actividadesAgricolas.cantidadAplicada,
        );
        await m.addColumn(
          actividadesAgricolas,
          actividadesAgricolas.incidencia,
        );
      }
      if (desde < 10) {
        await m.addColumn(
          actividadesAgricolas,
          actividadesAgricolas.subtipoLabor,
        );
        await m.addColumn(
          actividadesAgricolas,
          actividadesAgricolas.arbolesAfectados,
        );
        await m.addColumn(
          actividadesAgricolas,
          actividadesAgricolas.edadCultivoAnios,
        );
        await m.addColumn(
          actividadesAgricolas,
          actividadesAgricolas.resultadoEsperado,
        );
      }
      if (desde < 9) {
        await m.addColumn(
          actividadesAgricolas,
          actividadesAgricolas.responsable,
        );
        await m.addColumn(actividadesAgricolas, actividadesAgricolas.costo);
        await m.addColumn(actividadesAgricolas, actividadesAgricolas.fotoPath);
        await m.addColumn(
          actividadesAgricolas,
          actividadesAgricolas.arbolesSembrados,
        );
        await m.addColumn(
          actividadesAgricolas,
          actividadesAgricolas.edadPlantulaMeses,
        );
        await m.addColumn(actividadesAgricolas, actividadesAgricolas.insumos);
      }
      if (desde < 8) {
        await m.addColumn(lotes, lotes.codigo);
      }
      // A diferencia de `sesion`/`syncMeta` (que nacen ya completas en la rama
      // `desde < 2` porque `createTable` usa la definición actual), la tabla
      // `productores` existe desde la v1: cualquier versión anterior a esta le
      // falta este par de columnas, sin excepción.
      // La sesión del servidor reemplaza a la de Supabase: hay que guardarla
      // en algún lado o el productor tendría que entrar con Google cada vez.
      if (desde < 7 && desde >= 2) {
        await m.addColumn(sesion, sesion.tokenNube);
      }
      if (desde < 6) {
        await m.addColumn(productores, productores.tipoDocumento);
        await m.addColumn(productores, productores.numeroDocumento);
      }
      if (desde < 5 && desde >= 2) {
        await m.addColumn(sesion, sesion.correoConfirmado);
      }
      if (desde < 4 && desde >= 2) {
        await m.addColumn(sesion, sesion.correo);
        await m.addColumn(sesion, sesion.descargaInicial);
      }
      if (desde < 3 && desde >= 2) {
        await m.addColumn(syncMeta, syncMeta.lastSyncId);
      }
      if (desde < 2) {
        // Columnas de sincronización en todas las tablas de datos.
        await m.addColumn(asociaciones, asociaciones.serverUpdatedAt);
        await m.addColumn(asociaciones, asociaciones.syncError);
        await m.addColumn(productores, productores.serverUpdatedAt);
        await m.addColumn(productores, productores.syncError);
        await m.addColumn(productores, productores.usuarioId);
        await m.addColumn(fincas, fincas.serverUpdatedAt);
        await m.addColumn(fincas, fincas.syncError);
        await m.addColumn(lotes, lotes.serverUpdatedAt);
        await m.addColumn(lotes, lotes.syncError);
        await m.addColumn(
          actividadesAgricolas,
          actividadesAgricolas.serverUpdatedAt,
        );
        await m.addColumn(actividadesAgricolas, actividadesAgricolas.syncError);
        await m.addColumn(cosechas, cosechas.serverUpdatedAt);
        await m.addColumn(cosechas, cosechas.syncError);
        await m.addColumn(diagnosticos, diagnosticos.serverUpdatedAt);
        await m.addColumn(diagnosticos, diagnosticos.syncError);

        await m.createTable(sesion);
        await m.createTable(syncMeta);

        // Los datos que ya existían pertenecen a esta instalación.
        final identidad = nuevoId();
        await customInsert(
          'INSERT INTO sesion (id, usuario_id) VALUES (1, ?)',
          variables: [Variable(identidad)],
        );
        await customUpdate(
          'UPDATE productores SET usuario_id = ? WHERE usuario_id IS NULL',
          variables: [Variable(identidad)],
          updates: {productores},
        );
      }
    },
    beforeOpen: (details) async {
      // SQLite no aplica las llaves foráneas si no se activan por conexión.
      await customStatement('PRAGMA foreign_keys = ON');
      await _sembrarAsociaciones(this);
    },
  );
}

/// Ids fijos y ya `synced`: son el mismo catálogo en toda instalación y en
/// el servidor (ver `backend/Codigo.gs`), así que no hay nada que subir por
/// esto y `insertOrIgnore` lo vuelve seguro de repetir en cada arranque.
Future<void> _sembrarAsociaciones(AppDatabase db) async {
  final momento = ahora();
  for (final semilla in asociacionesSemilla) {
    await db
        .into(db.asociaciones)
        .insert(
          AsociacionesCompanion.insert(
            id: Value(semilla.id),
            nombre: semilla.nombre,
            municipio: '',
            departamento: '',
            updatedAt: Value(momento),
            syncStatus: const Value(SyncStatus.synced),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }
}

/// Borra **todos los datos** de esta instalación, dejando la identidad local.
///
/// Es lo que hay detrás de "cerrar sesión": los datos siguen en el servidor a
/// nombre de la cuenta y se recuperan volviendo a entrar. La identidad de la
/// instalación no se toca —es de este teléfono, no de la cuenta—, así que los
/// repositorios que ya la tienen en memoria siguen siendo válidos.
Future<void> borrarDatosLocales(AppDatabase db) {
  return db.transaction(() async {
    // De abajo hacia arriba, para no chocar con las llaves foráneas.
    for (final tabla in <TableInfo<Table, dynamic>>[
      db.diagnosticos,
      db.cosechas,
      db.actividadesAgricolas,
      db.lotes,
      db.fincas,
      db.productores,
      db.asociaciones,
      db.syncMeta,
    ]) {
      await db.delete(tabla).go();
    }
  });
}

/// Marca un registro como borrado sin sacarlo de la base: la fila queda con
/// `deleted_at` y vuelve a estado pendiente para que el borrado se sincronice.
Future<int> borrarSuave(
  AppDatabase db,
  TableInfo<Table, dynamic> tabla,
  String id,
) {
  return db.customUpdate(
    'UPDATE ${tabla.actualTableName} '
    'SET deleted_at = ?, updated_at = ?, sync_status = ? '
    'WHERE id = ? AND deleted_at IS NULL',
    variables: [..._marcasBorrado(), Variable(id)],
    updates: {tabla},
  );
}

/// Borra en cascada hacia abajo, dentro de una transacción.
///
/// Cada hijo necesita su propia fila con `deleted_at` y `pending`: un
/// `ON DELETE CASCADE` de Postgres borraría físicamente y los demás
/// dispositivos nunca se enterarían de que esos hijos murieron. El
/// `deleted_at IS NULL` de cada sentencia hace la operación idempotente y evita
/// pisar la fecha de algo que ya estaba borrado.
Future<void> borrarLoteEnCascada(AppDatabase db, String loteId) {
  return db.transaction(() async {
    for (final hija in ['actividades_agricolas', 'cosechas', 'diagnosticos']) {
      await db.customUpdate(
        'UPDATE $hija SET deleted_at = ?, updated_at = ?, sync_status = ? '
        'WHERE lote_id = ? AND deleted_at IS NULL',
        variables: [..._marcasBorrado(), Variable(loteId)],
        updates: {db.actividadesAgricolas, db.cosechas, db.diagnosticos},
      );
    }
    await borrarSuave(db, db.lotes, loteId);
  });
}

Future<void> borrarFincaEnCascada(AppDatabase db, String fincaId) {
  return db.transaction(() async {
    for (final hija in ['actividades_agricolas', 'cosechas', 'diagnosticos']) {
      await db.customUpdate(
        'UPDATE $hija SET deleted_at = ?, updated_at = ?, sync_status = ? '
        'WHERE deleted_at IS NULL AND lote_id IN '
        '(SELECT id FROM lotes WHERE finca_id = ?)',
        variables: [..._marcasBorrado(), Variable(fincaId)],
        updates: {db.actividadesAgricolas, db.cosechas, db.diagnosticos},
      );
    }
    await db.customUpdate(
      'UPDATE lotes SET deleted_at = ?, updated_at = ?, sync_status = ? '
      'WHERE finca_id = ? AND deleted_at IS NULL',
      variables: [..._marcasBorrado(), Variable(fincaId)],
      updates: {db.lotes},
    );
    await borrarSuave(db, db.fincas, fincaId);
  });
}

/// Cascada disparada por un borrado que **llegó del servidor**.
///
/// Los hijos se marcan como `synced`, no como `pending`: este dispositivo no ha
/// decidido nada, solo está reflejando lo que ya decidió otro. Si quedaran
/// pendientes, volverían a subir y podrían ganar un conflicto contra el
/// servidor por un cambio que en realidad nunca hizo nadie aquí.
///
/// Devuelve los ids de hijos que **sí** tenían cambios locales sin subir: esos
/// cambios se pierden porque su padre ya no existe, y quien llama lo anota como
/// conflicto en vez de tragárselo en silencio.
Future<List<String>> aplicarBorradoRemotoDeFinca(
  AppDatabase db,
  String fincaId,
  DateTime borradoEn,
) {
  return db.transaction(() async {
    final pendientesPisados = await _hijosPendientesDeFinca(db, fincaId);
    for (final hija in ['actividades_agricolas', 'cosechas', 'diagnosticos']) {
      await db.customUpdate(
        'UPDATE $hija SET deleted_at = ?, updated_at = ?, sync_status = ? '
        'WHERE deleted_at IS NULL AND lote_id IN '
        '(SELECT id FROM lotes WHERE finca_id = ?)',
        variables: [..._marcasRecibidas(borradoEn), Variable(fincaId)],
        updates: {db.actividadesAgricolas, db.cosechas, db.diagnosticos},
      );
    }
    await db.customUpdate(
      'UPDATE lotes SET deleted_at = ?, updated_at = ?, sync_status = ? '
      'WHERE finca_id = ? AND deleted_at IS NULL',
      variables: [..._marcasRecibidas(borradoEn), Variable(fincaId)],
      updates: {db.lotes},
    );
    return pendientesPisados;
  });
}

/// Cascada de un borrado de lote que **llegó del servidor**: los registros del
/// lote quedan borrados y `synced`, nunca `pending` (ver
/// [aplicarBorradoRemotoDeFinca]).
///
/// Devuelve los ids de hijos que tenían cambios locales sin subir, para que
/// quien llama los anote como conflicto.
Future<List<String>> aplicarBorradoRemotoDeLote(
  AppDatabase db,
  String loteId,
  DateTime borradoEn,
) {
  return db.transaction(() async {
    final pendientesPisados = await _hijosPendientesDeLote(db, loteId);
    for (final hija in ['actividades_agricolas', 'cosechas', 'diagnosticos']) {
      await db.customUpdate(
        'UPDATE $hija SET deleted_at = ?, updated_at = ?, sync_status = ? '
        'WHERE lote_id = ? AND deleted_at IS NULL',
        variables: [..._marcasRecibidas(borradoEn), Variable(loteId)],
        updates: {db.actividadesAgricolas, db.cosechas, db.diagnosticos},
      );
    }
    return pendientesPisados;
  });
}

Future<List<String>> _hijosPendientesDeLote(
  AppDatabase db,
  String loteId,
) async {
  final filas = await db
      .customSelect(
        'SELECT id FROM actividades_agricolas '
        'WHERE lote_id = ?1 AND deleted_at IS NULL AND sync_status = ?2 '
        'UNION ALL SELECT id FROM cosechas '
        'WHERE lote_id = ?1 AND deleted_at IS NULL AND sync_status = ?2 '
        'UNION ALL SELECT id FROM diagnosticos '
        'WHERE lote_id = ?1 AND deleted_at IS NULL AND sync_status = ?2',
        variables: [Variable(loteId), Variable(SyncStatus.pending.name)],
      )
      .get();
  return [for (final fila in filas) fila.read<String>('id')];
}

Future<List<String>> _hijosPendientesDeFinca(
  AppDatabase db,
  String fincaId,
) async {
  final filas = await db
      .customSelect(
        'SELECT id FROM lotes '
        'WHERE finca_id = ?1 AND deleted_at IS NULL AND sync_status = ?2 '
        'UNION ALL SELECT id FROM actividades_agricolas '
        'WHERE deleted_at IS NULL AND sync_status = ?2 AND lote_id IN '
        '(SELECT id FROM lotes WHERE finca_id = ?1) '
        'UNION ALL SELECT id FROM cosechas '
        'WHERE deleted_at IS NULL AND sync_status = ?2 AND lote_id IN '
        '(SELECT id FROM lotes WHERE finca_id = ?1) '
        'UNION ALL SELECT id FROM diagnosticos '
        'WHERE deleted_at IS NULL AND sync_status = ?2 AND lote_id IN '
        '(SELECT id FROM lotes WHERE finca_id = ?1)',
        variables: [Variable(fincaId), Variable(SyncStatus.pending.name)],
      )
      .get();
  return [for (final fila in filas) fila.read<String>('id')];
}

/// Marcas de un borrado recibido: la fila queda ya sincronizada.
List<Variable<Object>> _marcasRecibidas(DateTime borradoEn) => [
  Variable(borradoEn),
  Variable(borradoEn),
  Variable(SyncStatus.synced.name),
];

Future<void> borrarProductorEnCascada(AppDatabase db, String productorId) {
  return db.transaction(() async {
    final fincas = await (db.select(
      db.fincas,
    )..where((f) => f.productorId.equals(productorId))).get();
    for (final finca in fincas) {
      await borrarFincaEnCascada(db, finca.id);
    }
    await borrarSuave(db, db.productores, productorId);
  });
}

/// `deleted_at`, `updated_at` y `sync_status` de un borrado suave.
List<Variable<Object>> _marcasBorrado() {
  final momento = ahora();
  return [
    Variable(momento),
    Variable(momento),
    Variable(SyncStatus.pending.name),
  ];
}
