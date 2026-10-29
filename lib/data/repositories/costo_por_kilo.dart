import '../local/database.dart';
import '../local/enums.dart';

/// Lo que cuesta producir un kilo, sacado de lo que el productor ya anotó.
///
/// No guarda nada: toma las labores y las cosechas de un lote en un período y
/// hace la cuenta. El precio de venta se escribe en la pantalla y se pierde al
/// salir, porque todavía no hay dónde guardarlo.
///
/// **Dos decisiones que sostienen que el número no mienta.**
///
/// La primera: los kilos **no se suman entre productos distintos**. Un kilo de
/// cacao en baba no es un kilo de cacao seco —hacen falta del orden de dos
/// kilos y medio de baba para sacar uno seco—, así que sumarlos y dividir
/// daría un costo por kilo que no significa nada. Aquí se agrupa por tipo de
/// producto y se cuesta uno a la vez.
///
/// La segunda: se cuenta cuántas labores quedaron **sin costo anotado**. Si de
/// doce labores solo tres tienen costo, el costo por kilo que salga está
/// contando una parte del gasto y no todo. Quien lo lea tiene derecho a
/// saberlo, así que ese número viaja junto al resultado y la pantalla lo
/// muestra.
class CuentaDelLote {
  const CuentaDelLote({
    required this.costoTotal,
    required this.costoPorLabor,
    required this.laboresConCosto,
    required this.laboresSinCosto,
    required this.kilosPorProducto,
    required this.producto,
    required this.kilos,
    this.precioPorKilo,
  });

  /// Suma de los costos anotados en el período. Lo que no tiene costo no suma.
  final double costoTotal;

  /// El mismo total, repartido por tipo de labor: dónde se fue la plata.
  final Map<TipoActividad, double> costoPorLabor;

  final int laboresConCosto;

  /// Labores del período a las que no se les anotó el costo. Mientras este
  /// número no sea cero, el costo por kilo va por debajo de lo real.
  final int laboresSinCosto;

  /// Kilos cosechados en el período, por tipo de producto. Nunca se suman
  /// entre sí.
  final Map<String, double> kilosPorProducto;

  /// El tipo de producto que se está costeando. `null` si no hay cosechas.
  final String? producto;

  /// Kilos de ese producto en el período.
  final double kilos;

  /// Lo que le pagan por kilo. No se guarda; se escribe para ver la cuenta.
  final double? precioPorKilo;

  bool get hayCosechas => kilos > 0;

  /// Cuántos tipos de producto distintos se cosecharon. Más de uno significa
  /// que el productor tiene que escoger cuál costear.
  bool get variosProductos => kilosPorProducto.length > 1;

  /// Lo que cuesta producir un kilo. `null` si no hay cosechas: dividir por
  /// cero no es "cero", es que la pregunta todavía no se puede responder.
  double? get costoPorKilo => hayCosechas ? costoTotal / kilos : null;

  /// Lo que queda por cada kilo después de pagar lo que costó producirlo.
  double? get margenPorKilo {
    final costo = costoPorKilo;
    if (costo == null || precioPorKilo == null) return null;
    return precioPorKilo! - costo;
  }

  /// Lo que entró por esa cosecha.
  double? get ventaEstimada =>
      precioPorKilo == null || !hayCosechas ? null : kilos * precioPorKilo!;

  /// Lo que quedó: lo que entró menos lo que costó.
  double? get utilidad {
    final venta = ventaEstimada;
    return venta == null ? null : venta - costoTotal;
  }

  /// ¿La cuenta está completa, o le faltan costos por anotar?
  bool get completa => laboresSinCosto == 0 && laboresConCosto > 0;
}

/// ¿La fecha cae en el período, contando los dos días del borde?
///
/// Vive aquí y no dentro de la cuenta porque la pantalla también lo necesita:
/// la lista de gastos que el productor ve y edita tiene que ser exactamente
/// la misma que se sumó. Si cada una filtrara por su lado, un día de más o de
/// menos haría que los gastos de la lista no den el total de arriba.
bool enPeriodo(DateTime fecha, DateTime desde, DateTime hasta) {
  final inicio = DateTime(desde.year, desde.month, desde.day);
  final fin = DateTime(hasta.year, hasta.month, hasta.day, 23, 59, 59, 999);
  return !fecha.isBefore(inicio) && !fecha.isAfter(fin);
}

/// Hace la cuenta con lo anotado entre [desde] y [hasta], ambos incluidos.
///
/// [producto] escoge cuál tipo de cacao costear. Si no se pasa, toma el que
/// más kilos tenga en el período.
CuentaDelLote calcularCostoPorKilo({
  required List<ActividadAgricola> actividades,
  required List<Cosecha> cosechas,
  required DateTime desde,
  required DateTime hasta,
  String? producto,
  double? precioPorKilo,
}) {
  bool dentro(DateTime fecha) => enPeriodo(fecha, desde, hasta);

  var costoTotal = 0.0;
  var conCosto = 0;
  var sinCosto = 0;
  final porLabor = <TipoActividad, double>{};

  for (final actividad in actividades) {
    if (!dentro(actividad.fecha)) continue;
    final costo = actividad.costo;
    if (costo == null || costo <= 0) {
      sinCosto++;
      continue;
    }
    costoTotal += costo;
    conCosto++;
    porLabor[actividad.tipoActividad] =
        (porLabor[actividad.tipoActividad] ?? 0) + costo;
  }

  final porProducto = <String, double>{};
  for (final cosecha in cosechas) {
    if (!dentro(cosecha.fecha)) continue;
    // Una cosecha sin tipo anotado se agrupa aparte en vez de mezclarla con
    // el cacao seco: no sabemos cuál es, y suponerlo falsearía el resultado.
    final tipo = cosecha.tipoProducto ?? 'Sin especificar';
    porProducto[tipo] = (porProducto[tipo] ?? 0) + cosecha.cantidadKg;
  }

  String? elegido = producto;
  if (elegido == null || !porProducto.containsKey(elegido)) {
    elegido = porProducto.isEmpty
        ? null
        : (porProducto.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;
  }

  return CuentaDelLote(
    costoTotal: costoTotal,
    costoPorLabor: porLabor,
    laboresConCosto: conCosto,
    laboresSinCosto: sinCosto,
    kilosPorProducto: porProducto,
    producto: elegido,
    kilos: elegido == null ? 0 : (porProducto[elegido] ?? 0),
    precioPorKilo: precioPorKilo,
  );
}
