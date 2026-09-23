import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'tema.dart';
import 'widgets/ubicacion.dart';

/// Elegir la ubicación de la finca sobre el mapa.
///
/// Dos formas de fijar el punto, porque en campo mandan condiciones distintas:
/// el **GPS** funciona sin datos (es lo normal en la finca) y el **mapa**
/// necesita internet para descargar las imágenes, pero permite ajustar el punto
/// con precisión desde casa.
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key, this.inicial});

  /// Punto de partida: lo que ya tenía la finca, si tenía algo.
  final LatLng? inicial;

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  /// Centro de Colombia: si no hay nada, se arranca en el país.
  static const _colombia = LatLng(4.6, -74.08);

  final _mapa = MapController();
  late LatLng _punto = widget.inicial ?? _colombia;
  var _buscandoGps = false;

  Future<void> _usarMiUbicacion() async {
    setState(() => _buscandoGps = true);
    final aqui = await ubicacionActual(context);
    if (!mounted) return;
    setState(() => _buscandoGps = false);
    if (aqui == null) return;
    setState(() => _punto = aqui);
    _mapa.move(aqui, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cabeceraCacao(titulo: const Text('Ubicación de la finca')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapa,
            options: MapOptions(
              initialCenter: _punto,
              initialZoom: widget.inicial == null ? 6 : 16,
              onTap: (_, punto) => setState(() => _punto = punto),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.redcacao.cacao_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _punto,
                    width: 56,
                    height: 56,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on,
                      size: 56,
                      color: PaletaCacao.cafe,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Toque el mapa para marcar la finca.\n'
                  '${_punto.latitude.toStringAsFixed(5)}, '
                  '${_punto.longitude.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: PaletaCacao.verde,
                  ),
                  onPressed: _buscandoGps ? null : _usarMiUbicacion,
                  icon: _buscandoGps
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.my_location, size: 28),
                  label: Text(_buscandoGps ? 'Buscando…' : 'Estoy en la finca'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(_punto),
                  icon: const Icon(Icons.check, size: 28),
                  label: const Text('Usar este punto'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
