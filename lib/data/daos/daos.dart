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

  Future<Asociacion?> asociacionPorId(String id) =>
      (select(asociaciones)..where((a) => a.id.equals(id))).getSingleOrNull();

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

  Stream<List<Lote>> watchLotesDeProductor(String productorId) {
    final consulta =
        select(lotes)
            .join([innerJoin(fincas, fincas.id.equalsExp(lotes.fincaId))])
          ..where(fincas.productorId.equals(productorId))
          ..where(lotes.deletedAt.isNull())
          ..where(fincas.deletedAt.isNull());
    return consulta.watch().map(
      (filas) => [for (final fila in filas) fila.readTable(lotes)],
    );
  }
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
    String? codigo,
    required double areaSembradaHa,
    required String variedadCacao,
    required DateTime fechaSiembra,
    Value<String?> fotoPath = const Value.absent(),
  }) async {
    final idFinal = id ?? nuevoId();
    await into(lotes).insertOnConflictUpdate(
      LotesCompanion.insert(
        id: Value(idFinal),
        fincaId: fincaId,
        nombre: nombre,
        // Sin código se deja el que ya tenía: editar un lote viejo desde un
        // sitio que no conoce el código no debe borrarlo.
        codigo: codigo == null ? const Value.absent() : Value(codigo),
        fotoPath: fotoPath,
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
    String? responsable,
    double? costo,
    String? fotoPath,
    int? arbolesSembrados,
    int? edadPlantulaMeses,
    String? insumos,
    String? resultadoEsperado,
    String? subtipoLabor,
    int? arbolesAfectados,
    int? edadCultivoAnios,
    String? producto,
    String? cantidadAplicada,
    String? incidencia,
  }) async {
    final id = nuevoId();
    await into(actividadesAgricolas).insert(
      ActividadesAgricolasCompanion.insert(
        id: Value(id),
        loteId: loteId,
        tipoActividad: tipo,
        fecha: fecha,
        observaciones: Value(observaciones),
        responsable: Value(responsable),
        costo: Value(costo),
        fotoPath: Value(fotoPath),
        arbolesSembrados: Value(arbolesSembrados),
        edadPlantulaMeses: Value(edadPlantulaMeses),
        insumos: Value(insumos),
        resultadoEsperado: Value(resultadoEsperado),
        subtipoLabor: Value(subtipoLabor),
        arbolesAfectados: Value(arbolesAfectados),
        edadCultivoAnios: Value(edadCultivoAnios),
        producto: Value(producto),
        cantidadAplicada: Value(cantidadAplicada),
        incidencia: Value(incidencia),
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
    String? tipoProducto,
    String? fotoPath,
  }) async {
    final id = nuevoId();
    await into(cosechas).insert(
      CosechasCompanion.insert(
        id: Value(id),
        loteId: loteId,
        fecha: fecha,
        cantidadKg: cantidadKg,
        observaciones: Value(observaciones),
        tipoProducto: Value(tipoProducto),
        fotoPath: Value(fotoPath),
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
  Stream<double> watchKgDeFinca(String fincaId, int anio) =>
      watchKgDeFincaEntre(fincaId, DateTime(anio), DateTime(anio + 1));

  /// Kilos de la finca cosechados en `[desde, hasta)`.
  Stream<double> watchKgDeFincaEntre(
    String fincaId,
    DateTime desde,
    DateTime hasta,
  ) {
    final suma = cosechas.cantidadKg.sum();
    final consulta =
        selectOnly(cosechas)
            .join([innerJoin(lotes, lotes.id.equalsExp(cosechas.loteId))])
          ..addColumns([suma])
          ..where(
            lotes.fincaId.equals(fincaId) &
                lotes.deletedAt.isNull() &
                cosechas.deletedAt.isNull() &
                cosechas.fecha.isBiggerOrEqualValue(desde) &
                cosechas.fecha.isSmallerThanValue(hasta),
          );
    return consulta.watchSingle().map((fila) => fila.read(suma) ?? 0);
  }

  /// Todas las labores vivas de los lotes vivos de una finca, la más reciente
  /// primero. Es lo que miran los recordatorios.
  Stream<List<ActividadAgricola>> watchActividadesDeFinca(String fincaId) {
    final consulta =
        select(actividadesAgricolas).join([
            innerJoin(
              lotes,
              lotes.id.equalsExp(actividadesAgricolas.loteId),
              useColumns: false,
            ),
          ])
          ..where(
            lotes.fincaId.equals(fincaId) &
                lotes.deletedAt.isNull() &
                actividadesAgricolas.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm(
              expression: actividadesAgricolas.fecha,
              mode: OrderingMode.desc,
            ),
          ]);
    return consulta.watch().map(
      (filas) => [for (final f in filas) f.readTable(actividadesAgricolas)],
    );
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

  /// Historial consolidado de la finca: labores, cosechas y diagnósticos de
  /// **todos** sus lotes, en una sola línea de tiempo.
  ///
  /// Se arma con una consulta SQL (UNION) en vez de combinar tres streams de
  /// Drift por separado: así el orden cronológico sale de la base, no de
  /// mezclar listas ya ordenadas en Dart, y una sola consulta cubre las tres
  /// tablas con los índices que ya existen.
  Stream<List<EventoHistorial>> watchHistorialDeFinca(String fincaId) {
    final consulta = customSelect(
      '''
      SELECT a.id AS id, 'actividad' AS evento, a.lote_id AS lote_id,
             l.nombre AS lote_nombre, a.fecha AS fecha,
             a.tipo_actividad AS subtipo, a.observaciones AS detalle,
             NULL AS cantidad_kg, NULL AS foto_path
      FROM actividades_agricolas a
      JOIN lotes l ON l.id = a.lote_id
      WHERE a.deleted_at IS NULL AND l.finca_id = ?1

      UNION ALL

      SELECT c.id, 'cosecha', c.lote_id, l.nombre, c.fecha,
             NULL, c.observaciones, c.cantidad_kg, NULL
      FROM cosechas c
      JOIN lotes l ON l.id = c.lote_id
      WHERE c.deleted_at IS NULL AND l.finca_id = ?1

      UNION ALL

      SELECT d.id, 'diagnostico', d.lote_id, l.nombre, d.fecha,
             d.estado_fenologico, d.notas, NULL, d.foto_path
      FROM diagnosticos d
      JOIN lotes l ON l.id = d.lote_id
      WHERE d.deleted_at IS NULL AND l.finca_id = ?1

      ORDER BY fecha DESC
      ''',
      variables: [Variable(fincaId)],
      readsFrom: {actividadesAgricolas, cosechas, diagnosticos, lotes},
    );
    return consulta.watch().map(
      (filas) => [for (final fila in filas) EventoHistorial.desdeFila(fila)],
    );
  }

  /// Igual que [watchHistorialDeFinca], pero de **todas** las fincas del
  /// productor a la vez, y con el nombre de la finca de cada evento. Es lo
  /// que usa Reportes en su vista "Todas mis fincas".
  Stream<List<EventoHistorial>> watchHistorialDeProductor(String productorId) {
    final consulta = customSelect(
      '''
      SELECT a.id AS id, 'actividad' AS evento, a.lote_id AS lote_id,
             l.nombre AS lote_nombre, f.id AS finca_id, f.nombre AS finca_nombre,
             a.fecha AS fecha, a.tipo_actividad AS subtipo,
             a.observaciones AS detalle, NULL AS cantidad_kg, NULL AS foto_path
      FROM actividades_agricolas a
      JOIN lotes l ON l.id = a.lote_id
      JOIN fincas f ON f.id = l.finca_id
      WHERE a.deleted_at IS NULL AND l.deleted_at IS NULL AND f.deleted_at IS NULL
        AND f.productor_id = ?1

      UNION ALL

      SELECT c.id, 'cosecha', c.lote_id, l.nombre, f.id, f.nombre,
             c.fecha, NULL, c.observaciones, c.cantidad_kg, NULL
      FROM cosechas c
      JOIN lotes l ON l.id = c.lote_id
      JOIN fincas f ON f.id = l.finca_id
      WHERE c.deleted_at IS NULL AND l.deleted_at IS NULL AND f.deleted_at IS NULL
        AND f.productor_id = ?1

      UNION ALL

      SELECT d.id, 'diagnostico', d.lote_id, l.nombre, f.id, f.nombre,
             d.fecha, d.estado_fenologico, d.notas, NULL, d.foto_path
      FROM diagnosticos d
      JOIN lotes l ON l.id = d.lote_id
      JOIN fincas f ON f.id = l.finca_id
      WHERE d.deleted_at IS NULL AND l.deleted_at IS NULL AND f.deleted_at IS NULL
        AND f.productor_id = ?1

      ORDER BY fecha DESC
      ''',
      variables: [Variable(productorId)],
      readsFrom: {actividadesAgricolas, cosechas, diagnosticos, lotes, fincas},
    );
    return consulta.watch().map(
      (filas) => [
        for (final fila in filas) EventoHistorial.desdeFilaConFinca(fila),
      ],
    );
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

  /// Guarda el identificador de la cuenta de Google. La identidad
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
  /// Guarda quién entró y con qué sesión del servidor.
  Future<void> guardarSesionRemota({
    required String usuarioRemoto,
    required String correo,
    String? token,
    String? nombre,
  }) async {
    await (update(sesion)..where((s) => s.id.equals(1))).write(
      SesionCompanion(
        authUid: Value(usuarioRemoto),
        correo: Value(correo),
        tokenNube: Value(token),
        nombreCuenta: Value(nombre),
        // Con Google la cuenta llega confirmada: no hay correo que abrir.
        correoConfirmado: const Value(true),
      ),
    );
  }

  /// ¿Este teléfono ya tiene datos propios?
  ///
  /// Sirve para decidir si hay que avisar antes de entrar con una cuenta: si
  /// el teléfono está vacío no hay nada que reemplazar y la pregunta sobra.
  Future<bool> hayDatosLocales() async {
    // Consulta directa: `SyncDao` solo tiene declaradas sus dos tablas, y
    // declarar `productores` aquí solo para contar sería peor.
    final fila = await customSelect(
      'select count(*) as n from productores where deleted_at is null',
      readsFrom: {},
    ).getSingle();
    return fila.read<int>('n') > 0;
  }

  Future<String?> tokenNube() async {
    final fila = await sesionActual();
    return fila?.tokenNube;
  }

  Future<void> olvidarCuenta() async {
    await (update(sesion)..where((s) => s.id.equals(1))).write(
      const SesionCompanion(
        authUid: Value(null),
        correo: Value(null),
        tokenNube: Value(null),
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

/// Tipo de evento dentro del historial consolidado.
enum TipoEvento { actividad, cosecha, diagnostico }

/// Una fila del historial: puede ser una labor, una cosecha o un diagnóstico.
///
/// Es una sola clase para las tres cosas a propósito: la pantalla de
/// historial no necesita saber de tablas de Drift, solo pintar una lista
/// ordenada por fecha con lo que aplique según [tipo].
class EventoHistorial {
  const EventoHistorial({
    required this.id,
    required this.tipo,
    required this.loteId,
    required this.loteNombre,
    required this.fecha,
    this.fincaId,
    this.fincaNombre,
    this.subtipo,
    this.detalle,
    this.cantidadKg,
    this.fotoPath,
  });

  final String id;
  final TipoEvento tipo;
  final String loteId;
  final String loteNombre;
  final DateTime fecha;

  /// Solo vienen con datos cuando el historial es de **todas** las fincas del
  /// productor (ver [RegistrosDao.watchHistorialDeProductor]); en el
  /// historial de una sola finca no hace falta repetirlo.
  final String? fincaId;
  final String? fincaNombre;

  /// El tipo de labor (para actividades) o el estado fenológico (para
  /// diagnósticos), guardado como texto crudo del enum de la tabla.
  final String? subtipo;

  /// Observaciones o notas, según el tipo de evento.
  final String? detalle;

  /// Solo presente en cosechas.
  final double? cantidadKg;

  /// Solo presente en diagnósticos con foto.
  final String? fotoPath;

  factory EventoHistorial.desdeFila(QueryRow fila) {
    return EventoHistorial(
      id: fila.read<String>('id'),
      tipo: switch (fila.read<String>('evento')) {
        'cosecha' => TipoEvento.cosecha,
        'diagnostico' => TipoEvento.diagnostico,
        _ => TipoEvento.actividad,
      },
      loteId: fila.read<String>('lote_id'),
      loteNombre: fila.read<String>('lote_nombre'),
      fecha: fila.read<DateTime>('fecha'),
      subtipo: fila.readNullable<String>('subtipo'),
      detalle: fila.readNullable<String>('detalle'),
      cantidadKg: fila.readNullable<double>('cantidad_kg'),
      fotoPath: fila.readNullable<String>('foto_path'),
    );
  }

  factory EventoHistorial.desdeFilaConFinca(QueryRow fila) {
    return EventoHistorial(
      id: fila.read<String>('id'),
      tipo: switch (fila.read<String>('evento')) {
        'cosecha' => TipoEvento.cosecha,
        'diagnostico' => TipoEvento.diagnostico,
        _ => TipoEvento.actividad,
      },
      loteId: fila.read<String>('lote_id'),
      loteNombre: fila.read<String>('lote_nombre'),
      fincaId: fila.read<String>('finca_id'),
      fincaNombre: fila.read<String>('finca_nombre'),
      fecha: fila.read<DateTime>('fecha'),
      subtipo: fila.readNullable<String>('subtipo'),
      detalle: fila.readNullable<String>('detalle'),
      cantidadKg: fila.readNullable<double>('cantidad_kg'),
      fotoPath: fila.readNullable<String>('foto_path'),
    );
  }
}

/// Identidad de la instalación y cursores de descarga.
