import '../daos/daos.dart';
import '../local/database.dart';

/// Resumen de indicadores de gestión de una finca: lo que responde "¿cómo va
/// la finca en total?", a diferencia del inicio que responde "¿cómo va cada
/// lote hoy?".
class IndicadoresFinca {
  const IndicadoresFinca({
    required this.produccionTotalKg,
    required this.actividadesRealizadas,
    required this.cosechasRegistradas,
    required this.rendimientoPorLote,
  });

  /// Suma de todas las cosechas registradas, en todos los lotes, sin límite
  /// de año: el histórico completo de la finca.
  final double produccionTotalKg;

  /// Cuántas labores (poda, fertilización, riego, control fitosanitario...)
  /// se han registrado en total.
  final int actividadesRealizadas;

  /// Cuántas entregas de cosecha se han anotado (no los kilos, el número de
  /// registros).
  final int cosechasRegistradas;

  /// Kilos por hectárea de cada lote: `kg cosechados / área sembrada`.
  /// Es la forma estándar de comparar el rendimiento entre lotes de tamaño
  /// distinto.
  final List<RendimientoLote> rendimientoPorLote;
}

class RendimientoLote {
  const RendimientoLote({
    required this.loteId,
    required this.loteNombre,
    required this.kgTotales,
    required this.areaHa,
    this.fincaNombre,
  });

  final String loteId;
  final String loteNombre;
  final double kgTotales;
  final double areaHa;

  /// Nombre de la finca a la que pertenece el lote. Solo viene con datos en
  /// la vista "Todas mis fincas" ([ReportesRepository.watchIndicadoresProductor]):
  /// en el resumen de una sola finca no hace falta repetirlo.
  final String? fincaNombre;

  /// kg/ha. Cero cuando el lote no tiene área o no tiene cosechas todavía,
  /// para no dividir por cero ni mostrar `NaN` en pantalla.
  double get kgPorHectarea => areaHa <= 0 ? 0 : kgTotales / areaHa;
}

/// Historial consolidado e indicadores, tanto de una finca puntual como de
/// **todas** las fincas del productor a la vez (vista "Todas mis fincas" de
/// Reportes). Es una fachada aparte de [LoteRepository] porque mira varios
/// lotes —o varias fincas— a la vez, no uno solo.
class ReportesRepository {
  ReportesRepository(AppDatabase db)
      : _registros = db.registrosDao,
        _lotes = db.lotesDao,
        _fincas = db.fincasDao;

  final RegistrosDao _registros;
  final LotesDao _lotes;
  final FincasDao _fincas;

  /// Labores, cosechas y diagnósticos de todos los lotes de la finca,
  /// ordenados del más reciente al más antiguo. El filtrado por tipo, lote o
  /// rango de fechas se hace en la pantalla sobre esta misma lista: para el
  /// volumen de datos de un productor (cientos de registros, no miles), es
  /// más simple que reconsultar la base por cada combinación de filtros y
  /// sigue respondiendo al instante.
  Stream<List<EventoHistorial>> watchHistorial(String fincaId) =>
      _registros.watchHistorialDeFinca(fincaId);

  /// Igual que [watchHistorial], pero de todas las fincas del productor a la
  /// vez, para la vista "Todas mis fincas" de Reportes.
  Stream<List<EventoHistorial>> watchHistorialProductor(String productorId) =>
      _registros.watchHistorialDeProductor(productorId);

  /// Indicadores de gestión de la finca, calculados sobre el historial
  /// completo y el área de cada lote.
  Stream<IndicadoresFinca> watchIndicadores(String fincaId) {
    return watchHistorial(fincaId).asyncMap(
          (eventos) async =>
          _resumir(eventos, await _lotes.watchLotesDe(fincaId).first),
    );
  }

  /// Igual que [watchIndicadores], pero sumando los lotes de todas las
  /// fincas del productor, y con el nombre de la finca de cada lote (para
  /// distinguirlos en la lista de rendimiento).
  Stream<IndicadoresFinca> watchIndicadoresProductor(String productorId) {
    return watchHistorialProductor(productorId).asyncMap((eventos) async {
      final lotes = await _fincas.watchLotesDeProductor(productorId).first;
      final fincas = await _fincas.watchFincasDe(productorId).first;
      final nombrePorFincaId = {for (final f in fincas) f.id: f.nombre};
      return _resumir(eventos, lotes, nombrePorFincaId: nombrePorFincaId);
    });
  }

  IndicadoresFinca _resumir(
      List<EventoHistorial> eventos,
      List<Lote> lotes, {
        Map<String, String>? nombrePorFincaId,
      }) {
    var produccionTotal = 0.0;
    var actividades = 0;
    var cosechas = 0;
    final kgPorLote = <String, double>{};

    for (final evento in eventos) {
      switch (evento.tipo) {
        case TipoEvento.actividad:
          actividades++;
        case TipoEvento.cosecha:
          cosechas++;
          final kg = evento.cantidadKg ?? 0;
          produccionTotal += kg;
          kgPorLote[evento.loteId] = (kgPorLote[evento.loteId] ?? 0) + kg;
        case TipoEvento.diagnostico:
          break;
      }
    }

    final rendimiento = [
      for (final lote in lotes)
        RendimientoLote(
          loteId: lote.id,
          loteNombre: lote.nombre,
          kgTotales: kgPorLote[lote.id] ?? 0,
          areaHa: lote.areaSembradaHa,
          fincaNombre: nombrePorFincaId?[lote.fincaId],
        ),
    ]..sort((a, b) => b.kgPorHectarea.compareTo(a.kgPorHectarea));

    return IndicadoresFinca(
      produccionTotalKg: produccionTotal,
      actividadesRealizadas: actividades,
      cosechasRegistradas: cosechas,
      rendimientoPorLote: rendimiento,
    );
  }
}