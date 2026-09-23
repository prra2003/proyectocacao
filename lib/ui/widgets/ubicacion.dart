import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'comunes.dart';

/// Pide la ubicación actual al GPS del teléfono.
///
/// El GPS funciona sin señal de celular: basta con estar en la finca. Si la
/// ubicación está apagada o no hay permiso, lo dice con palabras y devuelve
/// `null`, sin dejar al productor adivinando qué pasó.
Future<LatLng?> ubicacionActual(BuildContext context) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (context.mounted) avisar(context, 'Active la ubicación del teléfono');
      return null;
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      if (context.mounted) {
        avisar(context, 'Sin permiso para usar la ubicación');
      }
      return null;
    }
    final posicion = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    return LatLng(posicion.latitude, posicion.longitude);
  } on Exception {
    if (context.mounted) avisar(context, 'No se pudo obtener la ubicación');
    return null;
  }
}
