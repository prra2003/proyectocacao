import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'tema.dart';
import 'widgets/comunes.dart';
import 'widgets/perimetro.dart';
import 'widgets/ubicacion.dart';
import 'widgets/verificar_ubicacion.dart';

/// Elegir la ubicación de la finca sobre el mapa.
///
/// Dos formas de fijar el punto, porque en campo mandan condiciones distintas:
/// el **GPS** funciona sin datos (es lo normal en la finca) y el **mapa**
/// necesita internet para descargar las imágenes, pero permite ajustar el punto
/// con precisión desde casa.
///
/// Si ya se eligió el departamento y el municipio, el mapa abre directamente
/// sobre ellos (primero el departamento, que no necesita internet, y luego el
/// municipio en cuanto lo encuentra). Al tocar "Usar este punto" se revisa que
/// el punto sí quede en ese municipio y departamento.
class MapaScreen extends StatefulWidget {
  const MapaScreen({
    super.key,
    this.inicial,
    this.departamento,
    this.municipio,
    this.centroPermitido,
    this.radioPermitido,
  });

  /// Punto de partida: lo que ya tenía la finca, si tenía algo.
  final LatLng? inicial;

  /// Lo que eligió el productor en el formulario de la finca.
  final String? departamento;
  final String? municipio;

  /// Cuando se marca un **lote**, el punto tiene que caer dentro de la finca.
  /// Se dibuja el círculo y no se deja tocar por fuera. Nulos cuando se marca
  /// la finca misma, que no tiene contra qué compararse.
  final LatLng? centroPermitido;
  final double? radioPermitido;

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  /// Centro de Colombia: si no hay nada, se arranca en el país.
  static const _colombia = LatLng(4.6, -74.08);

  final _mapa = MapController();
  late final _departamento = centroDepartamento(widget.departamento);
  late LatLng _punto = widget.inicial ?? _departamento?.centro ?? _colombia;
  var _buscandoGps = false;
  var _buscandoMunicipio = false;
  var _verificando = false;

  /// Si ya hay punto, se abre ahí. Si no, se busca el municipio y se hace
  /// zoom sobre él.
  Future<void> _alAbrirMapa() async {
    final departamento = widget.departamento;
    final municipio = widget.municipio;
    if (widget.inicial != null || departamento == null || municipio == null) {
      return;
    }
    setState(() => _buscandoMunicipio = true);
    final zona = await buscarMunicipio(
      departamento: departamento,
      municipio: municipio,
    );
    if (!mounted) return;
    setState(() => _buscandoMunicipio = false);
    if (zona == null) return; // Sin internet: se queda en el departamento.
    setState(() => _punto = zona.centro);
    _mapa.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(zona.sur, zona.norte),
        padding: const EdgeInsets.fromLTRB(30, 140, 30, 170),
        maxZoom: 15,
      ),
    );
  }

  Future<void> _usarMiUbicacion() async {
    setState(() => _buscandoGps = true);
    final aqui = await ubicacionActual(context);
    if (!mounted) return;
    setState(() => _buscandoGps = false);
    if (aqui == null) return;
    // El botón del GPS también respeta el perímetro: antes se lo saltaba, y
    // era la puerta de atrás para dejar un lote donde no va.
    if (!_dentroDelPerimetro(aqui)) return;
    setState(() => _punto = aqui);
    _mapa.move(aqui, 16);
  }

  Future<void> _usarEstePunto() async {
    if (!_dentroDelPerimetro(_punto)) return;

    // Marcando un LOTE no se pregunta por el municipio. El límite que manda
    // aquí es el perímetro de la finca, que es una frontera clara y ya se
    // comprobó; el municipio del lote es el de su finca, no se decide otra
    // vez. Solo la FINCA pasa por esa comprobación, porque ahí los límites
    // municipales sí son borrosos —una vereda puede quedar en otro municipio
    // sin que el productor lo sepa— y por eso allí sí tiene sentido poder
    // seguir de todas formas.
    if (_esLote) {
      Navigator.of(context).pop(_punto);
      return;
    }

    setState(() => _verificando = true);
    final sirve = await confirmarUbicacion(
      context,
      punto: _punto,
      departamento: widget.departamento,
      municipio: widget.municipio,
    );
    if (!mounted) return;
    setState(() => _verificando = false);
    if (sirve) Navigator.of(context).pop(_punto);
  }

  /// Se está marcando un lote (hay perímetro), no la finca.
  bool get _esLote =>
      widget.centroPermitido != null && widget.radioPermitido != null;

  /// Comprueba el perímetro y lo explica si no da. Devuelve `false` cuando el
  /// punto no sirve.
  bool _dentroDelPerimetro(LatLng punto) {
    final centro = widget.centroPermitido;
    final radio = widget.radioPermitido;
    if (centro == null || radio == null) return true;
    final lejos = metrosEntre(centro, punto);
    if (lejos <= radio) return true;
    avisar(
      context,
      'Ese punto queda a ${distanciaEnPalabras(lejos)} de la finca. El lote '
      'tiene que estar dentro del círculo (${distanciaEnPalabras(radio)}).',
    );
    return false;
  }

  /// El dibujo del mapa no bajó (sin señal, o el servidor de OpenStreetMap no
  /// contestó). El punto se puede marcar igual con el GPS.
  var _sinMapa = false;

  /// Fuera del perímetro no se mueve el punto: se explica por qué y cuánto se
  /// pasó, que es lo único que le sirve a quien está mirando el mapa.
  void _tocar(LatLng punto) {
    if (!_dentroDelPerimetro(punto)) return;
    setState(() => _punto = punto);
  }

  @override
  Widget build(BuildContext context) {
    final lugar = [
      if (widget.municipio != null) widget.municipio!,
      if (widget.departamento != null) widget.departamento!,
    ].join(', ');
    return Scaffold(
      appBar: cabeceraCacao(
        titulo: Text(_esLote ? 'Ubicación del lote' : 'Ubicación de la finca'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapa,
            options: MapOptions(
              initialCenter: _punto,
              initialZoom: widget.inicial != null
                  ? 16
                  : (_departamento?.zoom ?? 6),
              onMapReady: _alAbrirMapa,
              onTap: (_, punto) => _tocar(punto),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.redcacao.cacao_app',
                // Si el dibujo del mapa no baja, el lienzo queda en blanco y
                // uno no sabe si la app se rompió o es que no hay señal. Se
                // dice, y se recuerda que el GPS no necesita internet.
                errorTileCallback: (_, _, _) {
                  if (mounted && !_sinMapa) {
                    setState(() => _sinMapa = true);
                  }
                },
              ),
              if (widget.centroPermitido != null &&
                  widget.radioPermitido != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: widget.centroPermitido!,
                      radius: widget.radioPermitido!,
                      useRadiusInMeter: true,
                      color: PaletaCacao.verde.withValues(alpha: 0.12),
                      borderColor: PaletaCacao.verde,
                      borderStrokeWidth: 2,
                    ),
                  ],
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
              // La licencia de OpenStreetMap exige dar el crédito donde se
              // muestren sus mapas. No es un adorno: es la condición de uso.
              const RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (_sinMapa)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Material(
                color: PaletaCacao.cafeOscuro,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No se pudo cargar el dibujo del mapa: revise la '
                          'conexión. El punto se puede tomar igual con el GPS, '
                          'que no necesita internet.',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (lugar.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_city_outlined,
                            color: PaletaCacao.cafe,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              lugar,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (_buscandoMunicipio)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    Text(
                      'Toque el mapa para marcar la finca.\n'
                          '${_punto.latitude.toStringAsFixed(5)}, '
                          '${_punto.longitude.toStringAsFixed(5)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
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
                  onPressed: _verificando ? null : _usarEstePunto,
                  icon: _verificando
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.check, size: 28),
                  label: Text(
                    _verificando ? 'Revisando el punto…' : 'Usar este punto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}