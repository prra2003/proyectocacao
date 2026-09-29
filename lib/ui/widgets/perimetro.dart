import 'package:latlong2/latlong.dart';

/// Hasta dónde puede quedar un lote respecto al punto de su finca.
///
/// Un lote es parte de la finca: si alguien lo marca en otro municipio, o a
/// veinte kilómetros, es un error de dedo — y un error así echa a perder el
/// dato justo para lo que más sirve, que es demostrarle al comprador de dónde
/// salió el cacao.
///
/// El radio sale de las hectáreas registradas, como pidió el productor:
///
///  1. Una superficie de `A` hectáreas cabe en un círculo de radio
///     `√(A · 10 000 / π)` metros. Diez hectáreas son 178 metros.
///  2. Ese radio se multiplica por [_holgura]. Una finca no es un círculo
///     perfecto y la casa —que es el punto que marcó— suele estar en una
///     esquina, no en el centro.
///  3. Nunca baja de [_minimoMetros] ni pasa de [_maximoMetros]. Lo primero
///     es por las fincas pequeñas y por el error normal del GPS; lo segundo
///     porque más allá de eso ya no es holgura, es otro sitio.
double radioPermitidoMetros(double hectareas) {
  if (hectareas <= 0) return _minimoMetros;
  final radioExacto = _raiz(hectareas * 10000 / 3.141592653589793);
  final conHolgura = radioExacto * _holgura;
  if (conHolgura < _minimoMetros) return _minimoMetros;
  if (conHolgura > _maximoMetros) return _maximoMetros;
  return conHolgura;
}

const _holgura = 3.0;
const _minimoMetros = 300.0;
const _maximoMetros = 5000.0;

double _raiz(double valor) {
  var x = valor;
  for (var i = 0; i < 40; i++) {
    x = (x + valor / x) / 2;
  }
  return x;
}

/// Metros en línea recta entre dos puntos.
double metrosEntre(LatLng a, LatLng b) =>
    const Distance().as(LengthUnit.Meter, a, b);

/// ¿El punto cae dentro del perímetro de la finca?
///
/// Sin punto de finca no hay contra qué comparar, así que se deja pasar: es
/// preferible un lote sin verificar a un productor que no puede registrarlo.
bool dentroDelPerimetro({
  required LatLng punto,
  LatLng? centroFinca,
  required double hectareas,
}) {
  if (centroFinca == null) return true;
  return metrosEntre(centroFinca, punto) <= radioPermitidoMetros(hectareas);
}

/// "1,2 km" o "480 m", para decírselo al productor sin decimales inútiles.
String distanciaEnPalabras(double metros) {
  if (metros >= 1000) {
    final km = metros / 1000;
    return '${km.toStringAsFixed(km >= 10 ? 0 : 1).replaceAll('.', ',')} km';
  }
  return '${metros.round()} m';
}
