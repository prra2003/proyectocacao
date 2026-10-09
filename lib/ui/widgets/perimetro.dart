import 'package:latlong2/latlong.dart';

/// Hasta dónde puede quedar un lote respecto al punto de su finca.
///
/// Un lote es parte de la finca: si alguien lo marca en otro municipio, o a
/// veinte kilómetros, es un error de dedo — y un error así echa a perder el
/// dato justo para lo que más sirve, que es demostrarle al comprador de dónde
/// salió el cacao.
///
/// **De dónde sale el radio.** Se toma el caso peor de una finca cuadrada:
///
///  1. Una finca de `A` hectáreas, vista como un cuadrado, mide
///     `√(A · 10 000)` metros de lado. Veinte hectáreas son 447 m.
///  2. La esquina más lejana está a la **diagonal**, `lado · √2`. Son 632 m.
///     Ese es el caso peor: la casa —el punto que marcó el productor— en una
///     punta y el lote en la contraria.
///  3. Se le suma un [_margen] del 20%, porque una finca real no es un
///     cuadrado perfecto. Quedan 759 m.
///
/// Se usa un círculo y no un cuadrado por una razón concreta: **un cuadrado
/// habría que orientarlo**, y nadie sabe si la finca va norte-sur o siguiendo
/// la quebrada. El círculo es la única forma que no exige conocer la
/// dirección.
///
/// Donde esta regla se queda corta es en una finca larga y angosta —una faja
/// siguiendo una cañada—: el lote del extremo puede quedar más lejos que la
/// diagonal de un cuadrado de la misma área. La solución de fondo no es
/// estirar el radio sino **caminar el lindero con el GPS y guardar el
/// polígono real** (ver `docs/DOCUMENTACION_TECNICA.md`, Fase 2), que además
/// es lo que pide el comprador europeo para predios de más de 4 hectáreas.
///
/// Nunca baja de [_minimoMetros] ni pasa de [_maximoMetros]. Lo primero es por
/// las fincas pequeñas y por el error normal del GPS; lo segundo porque más
/// allá de eso ya no es holgura, es otro sitio.
double radioPermitidoMetros(double hectareas) {
  if (hectareas <= 0) return _minimoMetros;
  final lado = _raiz(hectareas * 10000);
  final diagonal = lado * _raizDeDos;
  final conMargen = diagonal * _margen;
  if (conMargen < _minimoMetros) return _minimoMetros;
  if (conMargen > _maximoMetros) return _maximoMetros;
  return conMargen;
}

const _raizDeDos = 1.4142135623730951;

/// Una finca real no es un cuadrado perfecto: un quinto más de holgura.
const _margen = 1.2;

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
