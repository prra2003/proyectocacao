import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../tema.dart';

/// Ubicar el departamento y el municipio en el mapa, y comprobar que el punto
/// que marcó el productor sí queda donde dijo.
///
/// Usa Nominatim, el buscador gratuito de OpenStreetMap (el mismo mapa que ya
/// usa la app). Necesita internet; sin señal no se puede comprobar nada y la
/// app sigue igual, sin estorbar: el campo no puede quedarse esperando.

const _servidor = 'nominatim.openstreetmap.org';

/// OpenStreetMap exige que cada app se identifique.
const _cabeceras = {
  'User-Agent': 'RedCacaoApp/1.2 (com.redcacao.cacao_app)',
  'Accept-Language': 'es',
};

// ---------------------------------------------------------------------------
// Centro aproximado de cada departamento (sin internet)
// ---------------------------------------------------------------------------

/// Centro aproximado y zoom de cada departamento. No necesita internet: sirve
/// para abrir el mapa ya en el departamento aunque no haya señal.
const Map<String, ({double lat, double lon, double zoom})> _centros = {
  'Amazonas': (lat: -1.5, lon: -71.5, zoom: 6.5),
  'Antioquia': (lat: 7.0, lon: -75.5, zoom: 7.5),
  'Arauca': (lat: 6.55, lon: -71.0, zoom: 8),
  'Atlántico': (lat: 10.7, lon: -74.95, zoom: 9.5),
  'Bogotá, D.C.': (lat: 4.65, lon: -74.1, zoom: 10),
  'Bolívar': (lat: 8.6, lon: -74.3, zoom: 7.5),
  'Boyacá': (lat: 5.5, lon: -73.0, zoom: 8),
  'Caldas': (lat: 5.3, lon: -75.3, zoom: 9),
  'Caquetá': (lat: 0.9, lon: -73.8, zoom: 7),
  'Casanare': (lat: 5.3, lon: -71.6, zoom: 8),
  'Cauca': (lat: 2.5, lon: -76.8, zoom: 8),
  'Cesar': (lat: 9.35, lon: -73.6, zoom: 8),
  'Chocó': (lat: 5.7, lon: -76.65, zoom: 7.5),
  'Cundinamarca': (lat: 4.9, lon: -74.1, zoom: 8),
  'Córdoba': (lat: 8.3, lon: -75.6, zoom: 8),
  'Guainía': (lat: 2.6, lon: -68.8, zoom: 7),
  'Guaviare': (lat: 1.9, lon: -72.4, zoom: 7.5),
  'Huila': (lat: 2.5, lon: -75.6, zoom: 8),
  'La Guajira': (lat: 11.35, lon: -72.5, zoom: 8),
  'Magdalena': (lat: 10.2, lon: -74.2, zoom: 8),
  'Meta': (lat: 3.3, lon: -73.1, zoom: 7.5),
  'Nariño': (lat: 1.3, lon: -77.6, zoom: 8),
  'Norte de Santander': (lat: 7.95, lon: -72.9, zoom: 8),
  'Putumayo': (lat: 0.5, lon: -76.3, zoom: 8),
  'Quindío': (lat: 4.45, lon: -75.7, zoom: 10),
  'Risaralda': (lat: 5.0, lon: -75.9, zoom: 9),
  'San Andrés y Providencia': (lat: 12.55, lon: -81.72, zoom: 11),
  'Santander': (lat: 6.8, lon: -73.3, zoom: 8),
  'Sucre': (lat: 9.0, lon: -75.1, zoom: 8.5),
  'Tolima': (lat: 4.0, lon: -75.2, zoom: 8),
  'Valle del Cauca': (lat: 3.8, lon: -76.5, zoom: 8),
  'Vaupés': (lat: 0.6, lon: -70.3, zoom: 7.5),
  'Vichada': (lat: 4.9, lon: -69.5, zoom: 7),
};

/// Código oficial (ISO 3166-2) de cada departamento. Es lo más seguro para
/// comparar, porque no depende de cómo esté escrito el nombre.
const Map<String, String> _codigos = {
  'Amazonas': 'CO-AMA',
  'Antioquia': 'CO-ANT',
  'Arauca': 'CO-ARA',
  'Atlántico': 'CO-ATL',
  'Bogotá, D.C.': 'CO-DC',
  'Bolívar': 'CO-BOL',
  'Boyacá': 'CO-BOY',
  'Caldas': 'CO-CAL',
  'Caquetá': 'CO-CAQ',
  'Casanare': 'CO-CAS',
  'Cauca': 'CO-CAU',
  'Cesar': 'CO-CES',
  'Chocó': 'CO-CHO',
  'Cundinamarca': 'CO-CUN',
  'Córdoba': 'CO-COR',
  'Guainía': 'CO-GUA',
  'Guaviare': 'CO-GUV',
  'Huila': 'CO-HUI',
  'La Guajira': 'CO-LAG',
  'Magdalena': 'CO-MAG',
  'Meta': 'CO-MET',
  'Nariño': 'CO-NAR',
  'Norte de Santander': 'CO-NSA',
  'Putumayo': 'CO-PUT',
  'Quindío': 'CO-QUI',
  'Risaralda': 'CO-RIS',
  'San Andrés y Providencia': 'CO-SAP',
  'Santander': 'CO-SAN',
  'Sucre': 'CO-SUC',
  'Tolima': 'CO-TOL',
  'Valle del Cauca': 'CO-VAC',
  'Vaupés': 'CO-VAU',
  'Vichada': 'CO-VID',
};

/// Dónde abrir el mapa para un departamento, sin internet.
({LatLng centro, double zoom})? centroDepartamento(String? departamento) {
  final c = _centros[departamento];
  if (c == null) return null;
  return (centro: LatLng(c.lat, c.lon), zoom: c.zoom);
}

// ---------------------------------------------------------------------------
// Buscar el municipio (con internet)
// ---------------------------------------------------------------------------

/// El recuadro que ocupa el municipio en el mapa. `null` si no hay internet o
/// no se encontró.
Future<({LatLng sur, LatLng norte, LatLng centro})?> buscarMunicipio({
  required String departamento,
  required String municipio,
}) async {
  try {
    final consulta = '${_limpiarParaBuscar(municipio)}, '
        '${_limpiarParaBuscar(departamento)}, Colombia';
    final url = Uri.https(_servidor, '/search', {
      'q': consulta,
      'format': 'jsonv2',
      'countrycodes': 'co',
      'addressdetails': '1',
      'limit': '5',
    });
    final respuesta = await http
        .get(url, headers: kIsWeb ? null : _cabeceras)
        .timeout(const Duration(seconds: 8));
    if (respuesta.statusCode != 200) return null;
    final lista = jsonDecode(respuesta.body) as List<dynamic>;
    if (lista.isEmpty) return null;

    // Se prefiere el límite del municipio (todo su territorio) a un punto
    // suelto como el parque principal.
    final elegido = lista.cast<Map<String, dynamic>>().firstWhere(
          (r) => r['category'] == 'boundary' || r['class'] == 'boundary',
      orElse: () => lista.first as Map<String, dynamic>,
    );
    final caja = (elegido['boundingbox'] as List<dynamic>)
        .map((v) => double.parse(v.toString()))
        .toList();
    // Nominatim entrega [sur, norte, oeste, este].
    return (
    sur: LatLng(caja[0], caja[2]),
    norte: LatLng(caja[1], caja[3]),
    centro: LatLng(
      double.parse(elegido['lat'].toString()),
      double.parse(elegido['lon'].toString()),
    ),
    );
  } on Object {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Comprobar el punto (con internet)
// ---------------------------------------------------------------------------

/// Qué departamento y municipio hay de verdad en un punto del mapa.
class LugarDelPunto {
  const LugarDelPunto({this.codigo, this.departamento, this.municipio});

  final String? codigo;
  final String? departamento;
  final String? municipio;
}

/// `null` si no hay internet o el servidor no contestó.
Future<LugarDelPunto?> lugarDelPunto(LatLng punto) async {
  try {
    final url = Uri.https(_servidor, '/reverse', {
      'lat': punto.latitude.toString(),
      'lon': punto.longitude.toString(),
      'format': 'jsonv2',
      'zoom': '10',
      'addressdetails': '1',
    });
    final respuesta = await http
        .get(url, headers: kIsWeb ? null : _cabeceras)
        .timeout(const Duration(seconds: 8));
    if (respuesta.statusCode != 200) return null;
    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
    final direccion = datos['address'] as Map<String, dynamic>?;
    if (direccion == null) return null;
    String? leer(List<String> claves) {
      for (final clave in claves) {
        final valor = direccion[clave];
        if (valor is String && valor.trim().isNotEmpty) return valor;
      }
      return null;
    }

    return LugarDelPunto(
      codigo: leer(['ISO3166-2-lvl4']),
      departamento: leer(['state', 'region']),
      municipio: leer(['municipality', 'city', 'town', 'county', 'village']),
    );
  } on Object {
    return null;
  }
}

/// Pasa todo a minúsculas y sin tildes, y quita palabras de relleno, para
/// comparar "Bogotá, D.C." con "Bogotá Distrito Capital".
String _normalizar(String texto) {
  const conTilde = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sinTilde = 'aaaaeeeeiiiioooouuuun';
  var t = texto.toLowerCase();
  for (var i = 0; i < conTilde.length; i++) {
    t = t.replaceAll(conTilde[i], sinTilde[i]);
  }
  t = t
      .replaceAll(RegExp(r'\bd\.?\s?c\.?\b'), ' ')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(
    RegExp(
      r'\b(municipio|departamento|distrito|capital|de|del|la|el|y|'
      r'area metropolitana|metropolitana)\b',
    ),
    ' ',
  )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return t;
}

String _limpiarParaBuscar(String texto) =>
    texto.replaceAll(RegExp(r',?\s*D\.C\.'), '').trim();

bool _mismoNombre(String a, String b) {
  final x = _normalizar(a);
  final y = _normalizar(b);
  if (x.isEmpty || y.isEmpty) return false;
  return x == y || x.contains(y) || y.contains(x);
}

/// Revisa el punto contra el departamento y el municipio que eligió el
/// productor. Si no concuerdan, le avisa y le deja escoger.
///
/// Devuelve `true` si se puede usar el punto: concuerda, no se pudo comprobar
/// (sin internet), o el productor decidió usarlo de todas formas.
Future<bool> confirmarUbicacion(
    BuildContext context, {
      required LatLng punto,
      required String? departamento,
      required String? municipio,
    }) async {
  if (departamento == null) return true;
  final lugar = await lugarDelPunto(punto);
  if (lugar == null) return true; // Sin internet: no se estorba.
  if (!context.mounted) return false;

  final codigoEsperado = _codigos[departamento];
  final bool departamentoBien;
  if (lugar.codigo != null && codigoEsperado != null) {
    departamentoBien = lugar.codigo == codigoEsperado;
  } else if (lugar.departamento != null) {
    departamentoBien = _mismoNombre(lugar.departamento!, departamento);
  } else {
    departamentoBien = true; // No se sabe: no se acusa.
  }

  // En Bogotá el "municipio" es la ciudad misma: basta con el departamento.
  final bool municipioBien;
  if (municipio == null ||
      lugar.municipio == null ||
      departamento == 'Bogotá, D.C.') {
    municipioBien = true;
  } else {
    municipioBien = _mismoNombre(lugar.municipio!, municipio);
  }

  if (departamentoBien && municipioBien) return true;

  final dondeQueda = [
    ?lugar.municipio,
    ?lugar.departamento,
  ].join(', ');
  final loQueDigito = [
    ?municipio,
    departamento,
  ].join(', ');

  final usar = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      icon: const Icon(
        Icons.wrong_location_outlined,
        color: PaletaCacao.cafe,
        size: 40,
      ),
      title: const Text('La ubicación no concuerda'),
      content: Text(
        'La ubicación no concuerda con lo que digitó en el departamento y el '
            'municipio.\n\n'
            'Usted digitó: $loQueDigito\n'
            '${dondeQueda.isEmpty ? '' : 'El punto queda en: $dondeQueda\n'}\n'
            'Revise el punto en el mapa, o corrija el departamento y el municipio.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contexto).pop(true),
          child: const Text('Usar de todas formas'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(contexto).pop(false),
          child: const Text('Corregir'),
        ),
      ],
    ),
  );
  return usar ?? false;
}