import 'package:drift/drift.dart' show Value;

import '../daos/daos.dart';
import '../local/database.dart';
import '../local/enums.dart';
import 'recordatorios.dart';

/// Todo lo que pasa dentro de un lote: labores culturales y cosechas.
class LoteRepository {
  LoteRepository(AppDatabase db)
    : _registros = db.registrosDao,
      _lotes = db.lotesDao;

  final RegistrosDao _registros;
  final LotesDao _lotes;

  Stream<Lote?> watchLote(String fincaId, String loteId) {
    return _lotes.watchLotesDe(fincaId).map((lotes) {
      for (final lote in lotes) {
        if (lote.id == loteId) return lote;
      }
      return null;
    });
  }

  /// Borra el lote y, en cascada, sus labores, cosechas y diagnósticos.
  Future<void> borrarLote(String loteId) => _lotes.borrar(loteId);

  /// Crea un lote nuevo, o edita uno existente si se pasa [id].
  Future<String> guardarLote({
    String? id,
    required String fincaId,
    required String nombre,
    String? codigo,
    required double areaSembradaHa,
    required String variedadCacao,
    required DateTime fechaSiembra,
    Value<String?> fotoPath = const Value.absent(),
  }) {
    return _lotes.guardar(
      id: id,
      fincaId: fincaId,
      nombre: nombre,
      codigo: codigo,
      areaSembradaHa: areaSembradaHa,
      variedadCacao: variedadCacao,
      fechaSiembra: fechaSiembra,
      fotoPath: fotoPath,
    );
  }

  Stream<List<ActividadAgricola>> watchActividades(String loteId) =>
      _registros.watchActividadesDe(loteId);

  Future<String> registrarActividad({
    required String loteId,
    required TipoActividad tipo,
    required DateTime fecha,
    String? observaciones,
    String? responsable,
    double? costo,
    String? fotoPath,
    String? subtipoLabor,
    String? producto,
    String? cantidadAplicada,
    String? incidencia,
    int? arbolesAfectados,
    int? edadCultivoAnios,
    int? arbolesSembrados,
    int? edadPlantulaMeses,
    String? insumos,
    String? resultadoEsperado,
  }) {
    return _registros.registrarActividad(
      loteId: loteId,
      tipo: tipo,
      fecha: fecha,
      observaciones: observaciones,
      responsable: responsable,
      costo: costo,
      fotoPath: fotoPath,
      subtipoLabor: subtipoLabor,
      producto: producto,
      cantidadAplicada: cantidadAplicada,
      incidencia: incidencia,
      arbolesAfectados: arbolesAfectados,
      edadCultivoAnios: edadCultivoAnios,
      arbolesSembrados: arbolesSembrados,
      edadPlantulaMeses: edadPlantulaMeses,
      insumos: insumos,
      resultadoEsperado: resultadoEsperado,
    );
  }

  /// Corrige una labor **que todavía está incompleta**.
  ///
  /// Una vez la labor quedó bien llena deja de poderse cambiar, y este método
  /// no escribe nada (devuelve 0). La ventana de corrección existe para
  /// terminar lo que se anotó a la carrera, no para reescribir el historial:
  /// si el dato ya está completo, cambiarlo después haría que el reporte del
  /// técnico y el del SENA dejaran de ser confiables.
  ///
  /// La comprobación vive aquí y no solo en la pantalla: una regla que
  /// sostiene la confianza en los datos no puede depender de que la interfaz
  /// se acuerde de aplicarla.
  Future<int> actualizarActividad({
    required String id,
    required TipoActividad tipo,
    required DateTime fecha,
    String? observaciones,
    String? responsable,
    double? costo,
    String? fotoPath,
    String? subtipoLabor,
    String? producto,
    String? cantidadAplicada,
    String? incidencia,
    int? arbolesAfectados,
    int? edadCultivoAnios,
    int? arbolesSembrados,
    int? edadPlantulaMeses,
    String? insumos,
    String? resultadoEsperado,
  }) async {
    final actual = await _registros.actividadPorId(id);
    if (actual == null || faltaLlenarEn(actual).isEmpty) return 0;
    return _registros.actualizarActividad(
      id: id,
      tipo: tipo,
      fecha: fecha,
      observaciones: observaciones,
      responsable: responsable,
      costo: costo,
      fotoPath: fotoPath,
      subtipoLabor: subtipoLabor,
      producto: producto,
      cantidadAplicada: cantidadAplicada,
      incidencia: incidencia,
      arbolesAfectados: arbolesAfectados,
      edadCultivoAnios: edadCultivoAnios,
      arbolesSembrados: arbolesSembrados,
      edadPlantulaMeses: edadPlantulaMeses,
      insumos: insumos,
      resultadoEsperado: resultadoEsperado,
    );
  }

  Future<int> borrarActividad(String id) => _registros.borrarActividad(id);

  Stream<List<Cosecha>> watchCosechas(String loteId) =>
      _registros.watchCosechasDe(loteId);

  Future<String> registrarCosecha({
    required String loteId,
    required DateTime fecha,
    required double cantidadKg,
    String? observaciones,
    String? tipoProducto,
    String? fotoPath,
  }) {
    return _registros.registrarCosecha(
      loteId: loteId,
      fecha: fecha,
      cantidadKg: cantidadKg,
      observaciones: observaciones,
      tipoProducto: tipoProducto,
      fotoPath: fotoPath,
    );
  }

  Future<int> borrarCosecha(String id) => _registros.borrarCosecha(id);

  Stream<double> watchKgDelAnio(String loteId, int anio) =>
      _registros.watchKgDeLote(loteId, anio);

  Stream<List<Diagnostico>> watchDiagnosticos(String loteId) =>
      _registros.watchDiagnosticosDe(loteId);

  Future<String> registrarDiagnostico({
    required String loteId,
    required DateTime fecha,
    required EstadoFenologico estado,
    String? fotoPath,
    String? notas,
  }) {
    return _registros.registrarDiagnostico(
      loteId: loteId,
      fecha: fecha,
      estado: estado,
      fotoPath: fotoPath,
      notas: notas,
    );
  }

  Future<int> borrarDiagnostico(String id) => _registros.borrarDiagnostico(id);
}
