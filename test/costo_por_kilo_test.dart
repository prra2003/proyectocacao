import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/costo_por_kilo.dart';
import 'package:flutter_test/flutter_test.dart';

/// Las cuentas de esta pantalla deciden si un productor sigue trabajando un
/// lote o lo renueva. Si están mal, el daño es de plata, así que se prueban
/// con números a mano.
void main() {
  final enero = DateTime(2026, 1, 1);
  final diciembre = DateTime(2026, 12, 31);

  ActividadAgricola labor({
    required DateTime fecha,
    double? costo,
    TipoActividad tipo = TipoActividad.poda,
  }) {
    final ahora = DateTime(2026);
    return ActividadAgricola(
      id: 'a${fecha.millisecondsSinceEpoch}${costo ?? -1}$tipo',
      loteId: 'lote',
      tipoActividad: tipo,
      fecha: fecha,
      costo: costo,
      createdAt: ahora,
      updatedAt: ahora,
      syncStatus: SyncStatus.pending,
    );
  }

  Cosecha cosecha({
    required DateTime fecha,
    required double kg,
    String? tipoProducto = 'Cacao seco',
  }) {
    final ahora = DateTime(2026);
    return Cosecha(
      id: 'c${fecha.millisecondsSinceEpoch}$kg$tipoProducto',
      loteId: 'lote',
      fecha: fecha,
      cantidadKg: kg,
      tipoProducto: tipoProducto,
      createdAt: ahora,
      updatedAt: ahora,
      syncStatus: SyncStatus.pending,
    );
  }

  CuentaDelLote cuenta({
    List<ActividadAgricola> labores = const [],
    List<Cosecha> cosechas = const [],
    String? producto,
    double? precio,
    DateTime? desde,
    DateTime? hasta,
  }) {
    return calcularCostoPorKilo(
      actividades: labores,
      cosechas: cosechas,
      desde: desde ?? enero,
      hasta: hasta ?? diciembre,
      producto: producto,
      precioPorKilo: precio,
    );
  }

  test('el costo por kilo es el gasto dividido entre los kilos', () {
    final r = cuenta(
      labores: [
        labor(fecha: DateTime(2026, 3, 10), costo: 400000),
        labor(fecha: DateTime(2026, 6, 10), costo: 200000),
      ],
      cosechas: [cosecha(fecha: DateTime(2026, 9, 1), kg: 150)],
    );

    expect(r.costoTotal, 600000);
    expect(r.costoPorKilo, 4000);
  });

  test('con precio de venta sale el margen y la utilidad', () {
    final r = cuenta(
      labores: [labor(fecha: DateTime(2026, 3, 10), costo: 600000)],
      cosechas: [cosecha(fecha: DateTime(2026, 9, 1), kg: 150)],
      precio: 12000,
    );

    expect(r.margenPorKilo, 8000);
    expect(r.ventaEstimada, 1800000);
    expect(r.utilidad, 1200000);
  });

  test('sin precio de venta, el costo por kilo igual se calcula', () {
    final r = cuenta(
      labores: [labor(fecha: DateTime(2026, 3, 10), costo: 600000)],
      cosechas: [cosecha(fecha: DateTime(2026, 9, 1), kg: 150)],
    );

    expect(r.costoPorKilo, 4000);
    expect(r.margenPorKilo, isNull);
    expect(r.utilidad, isNull);
  });

  test('sin cosechas no hay costo por kilo, y no es cero', () {
    final r = cuenta(
      labores: [labor(fecha: DateTime(2026, 3, 10), costo: 600000)],
    );

    expect(r.costoTotal, 600000);
    expect(
      r.costoPorKilo,
      isNull,
      reason: 'Dividir entre cero no da cero: da que la pregunta no se puede '
          'responder todavía.',
    );
  });

  test('nunca suma kilos de productos distintos', () {
    final r = cuenta(
      labores: [labor(fecha: DateTime(2026, 3, 10), costo: 600000)],
      cosechas: [
        cosecha(fecha: DateTime(2026, 9, 1), kg: 150),
        cosecha(
          fecha: DateTime(2026, 9, 2),
          kg: 300,
          tipoProducto: 'Cacao en baba',
        ),
      ],
    );

    expect(r.kilosPorProducto, {'Cacao seco': 150, 'Cacao en baba': 300});
    expect(r.variosProductos, isTrue);
    expect(
      r.kilos,
      300,
      reason: 'Sin escoger, toma el producto con más kilos; nunca los 450.',
    );
    expect(r.costoPorKilo, 2000);
  });

  test('se puede escoger qué producto costear', () {
    final r = cuenta(
      labores: [labor(fecha: DateTime(2026, 3, 10), costo: 600000)],
      cosechas: [
        cosecha(fecha: DateTime(2026, 9, 1), kg: 150),
        cosecha(
          fecha: DateTime(2026, 9, 2),
          kg: 300,
          tipoProducto: 'Cacao en baba',
        ),
      ],
      producto: 'Cacao seco',
    );

    expect(r.kilos, 150);
    expect(r.costoPorKilo, 4000);
  });

  test('avisa cuántas labores quedaron sin costo anotado', () {
    final r = cuenta(
      labores: [
        labor(fecha: DateTime(2026, 3, 10), costo: 300000),
        labor(fecha: DateTime(2026, 4, 10)),
        labor(fecha: DateTime(2026, 5, 10), costo: 0),
      ],
      cosechas: [cosecha(fecha: DateTime(2026, 9, 1), kg: 100)],
    );

    expect(r.laboresConCosto, 1);
    expect(
      r.laboresSinCosto,
      2,
      reason: 'Un costo en cero no es un costo anotado: es uno que falta.',
    );
    expect(r.completa, isFalse);
    expect(r.costoTotal, 300000);
  });

  test('la cuenta se da por completa solo si no falta ningún costo', () {
    final r = cuenta(
      labores: [labor(fecha: DateTime(2026, 3, 10), costo: 300000)],
      cosechas: [cosecha(fecha: DateTime(2026, 9, 1), kg: 100)],
    );

    expect(r.completa, isTrue);
  });

  test('deja fuera lo que no cae en el período', () {
    final r = cuenta(
      labores: [
        labor(fecha: DateTime(2025, 12, 31), costo: 999999),
        labor(fecha: DateTime(2026, 6, 10), costo: 500000),
        labor(fecha: DateTime(2027, 1, 1), costo: 888888),
      ],
      cosechas: [
        cosecha(fecha: DateTime(2026, 9, 1), kg: 100),
        cosecha(fecha: DateTime(2027, 2, 1), kg: 500),
      ],
    );

    expect(r.costoTotal, 500000);
    expect(r.kilos, 100);
  });

  test('los bordes del período entran, de un extremo al otro', () {
    final r = cuenta(
      labores: [
        labor(fecha: DateTime(2026, 1, 1), costo: 100000),
        labor(fecha: DateTime(2026, 12, 31, 23, 50), costo: 100000),
      ],
      cosechas: [cosecha(fecha: DateTime(2026, 12, 31, 18), kg: 50)],
    );

    expect(r.costoTotal, 200000, reason: 'Ambos días son del período.');
    expect(r.kilos, 50);
  });

  test('reparte el gasto por tipo de labor', () {
    final r = cuenta(
      labores: [
        labor(fecha: DateTime(2026, 3, 1), costo: 300000),
        labor(fecha: DateTime(2026, 4, 1), costo: 100000),
        labor(
          fecha: DateTime(2026, 5, 1),
          costo: 250000,
          tipo: TipoActividad.fertilizacion,
        ),
      ],
      cosechas: [cosecha(fecha: DateTime(2026, 9, 1), kg: 100)],
    );

    expect(r.costoPorLabor[TipoActividad.poda], 400000);
    expect(r.costoPorLabor[TipoActividad.fertilizacion], 250000);
  });

  test('una cosecha sin tipo no se cuela como cacao seco', () {
    final r = cuenta(
      cosechas: [
        cosecha(fecha: DateTime(2026, 9, 1), kg: 100),
        cosecha(fecha: DateTime(2026, 9, 2), kg: 40, tipoProducto: null),
      ],
    );

    expect(r.kilosPorProducto['Cacao seco'], 100);
    expect(r.kilosPorProducto['Sin especificar'], 40);
  });
}
