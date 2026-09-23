import 'package:flutter/material.dart';

import '../data/local/colombia.dart';
import '../data/local/database.dart';
import '../data/repositories/perfil_repository.dart';

import 'package:latlong2/latlong.dart';

import 'mapa_screen.dart';
import 'tema.dart';
import 'widgets/comunes.dart';
import 'widgets/ubicacion.dart';
import 'widgets/confirmacion_guardado.dart';

/// Alta y edición de la finca: ubicación administrativa y coordenadas.
class EditarFincaScreen extends StatefulWidget {
  const EditarFincaScreen({
    super.key,
    required this.repo,
    required this.productorId,
    this.finca,
    this.paso,
  });

  final PerfilRepository repo;

  /// "Paso 1 de 2" mientras se está registrando por primera vez.
  final String? paso;
  final String productorId;
  final Finca? finca;

  @override
  State<EditarFincaScreen> createState() => _EditarFincaScreenState();
}

class _EditarFincaScreenState extends State<EditarFincaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.finca?.nombre ?? '');
  // Ya no se escriben: salen del GPS o del mapa. Nadie se sabe de memoria
  // que su finca queda en "5.2718".
  late double? _latitud = widget.finca?.latitud;
  late double? _longitud = widget.finca?.longitud;
  var _buscandoGps = false;

  // Se eligen de un desplegable, no se escriben: así el municipio siempre
  // corresponde a un departamento real de Colombia y no hay dos fincas con
  // el mismo municipio escrito de formas distintas.
  //
  // Si la finca ya existía con un departamento o municipio que no está en
  // la lista actual (dato viejo escrito a mano), se deja sin elegir para
  // que el productor lo vuelva a seleccionar.
  late String? _departamento =
      widget.finca != null &&
          departamentosYMunicipios.containsKey(widget.finca!.departamento)
      ? widget.finca!.departamento
      : null;
  late String? _municipio =
      widget.finca != null &&
          _departamento != null &&
          departamentosYMunicipios[_departamento]!.contains(
            widget.finca!.municipio,
          )
      ? widget.finca!.municipio
      : null;
  var _faltaDepartamento = false;
  var _faltaMunicipio = false;
  var _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  /// Abre el mapa con lo que ya haya escrito y trae de vuelta el punto.
  Future<void> _usarMiUbicacion() async {
    setState(() => _buscandoGps = true);
    final aqui = await ubicacionActual(context);
    if (!mounted) return;
    setState(() {
      _buscandoGps = false;
      if (aqui != null) {
        _latitud = aqui.latitude;
        _longitud = aqui.longitude;
      }
    });
  }

  Future<void> _elegirEnMapa() async {
    final lat = _latitud;
    final lon = _longitud;
    final elegido = await Navigator.of(context).push<LatLng>(
      RutaCacao(
        builder: (_) => MapaScreen(
          inicial: lat != null && lon != null ? LatLng(lat, lon) : null,
        ),
      ),
    );
    if (elegido == null) return;
    setState(() {
      _latitud = elegido.latitude;
      _longitud = elegido.longitude;
    });
  }

  Future<void> _guardar() async {
    final departamentoOk = _departamento != null;
    final municipioOk = _municipio != null;
    setState(() {
      _faltaDepartamento = !departamentoOk;
      _faltaMunicipio = !municipioOk;
    });
    if (!_formKey.currentState!.validate() || !departamentoOk || !municipioOk) {
      return;
    }
    setState(() => _guardando = true);
    final esNueva = widget.finca == null;
    await widget.repo.guardarFinca(
      id: widget.finca?.id,
      productorId: widget.productorId,
      nombre: _nombre.text.trim(),
      municipio: _municipio!,
      departamento: _departamento!,
      latitud: _latitud,
      longitud: _longitud,
    );
    if (!mounted) return;
    await mostrarConfirmacionGuardado(
      context,
      mensaje: esNueva ? 'Finca registrada' : 'Cambios guardados',
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final esNueva = widget.finca == null;
    return Scaffold(
      appBar: cabeceraCacao(
        titulo: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(esNueva ? 'Mi finca' : 'Editar finca'),
            if (widget.paso != null)
              Text(
                widget.paso!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xCCFFFFFF),
                ),
              ),
          ],
        ),
      ),
      body: FondoCacao(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              CampoTarjeta(
                etiqueta: 'Nombre de la finca',
                icono: Icons.home_outlined,
                color: PaletaCacao.dorado,
                controller: _nombre,
                campoKey: const Key('campo_nombre_finca'),
                hint: 'Nombre de la finca',
                textCapitalization: TextCapitalization.words,
                validator: campoRequerido,
              ),
              const SizedBox(height: 16),
              // Primero el departamento: elegirlo limita qué municipios se
              // pueden elegir después, así el productor nunca escribe nada
              // a mano ni puede dejar un nombre mal escrito.
              SelectorDesplegable(
                campoKey: const Key('campo_departamento'),
                etiqueta: 'Departamento',
                icono: Icons.map_outlined,
                color: PaletaCacao.verde,
                opciones: departamentosColombia,
                valor: _departamento,
                onCambio: (v) => setState(() {
                  _departamento = v;
                  _faltaDepartamento = false;
                  // Cambiar de departamento invalida el municipio ya
                  // elegido: puede que no exista en el nuevo departamento.
                  _municipio = null;
                }),
              ),
              if (_faltaDepartamento)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Elige el departamento',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (_departamento == null)
                _AvisoSinDepartamento(color: PaletaCacao.cafe)
              else
                SelectorDesplegable(
                  // Se remonta con una key distinta por departamento para
                  // que el desplegable siempre arranque limpio con la
                  // lista de municipios correcta (SelectorDesplegable no
                  // reacciona solo a que cambie `valor`, igual que en el
                  // selector de tipo de labor de dialogo_actividad.dart).
                  key: ValueKey('campo_municipio_$_departamento'),
                  campoKey: const Key('campo_municipio'),
                  etiqueta: 'Municipio',
                  icono: Icons.location_city_outlined,
                  color: PaletaCacao.cafe,
                  opciones: departamentosYMunicipios[_departamento]!,
                  valor: _municipio,
                  onCambio: (v) => setState(() {
                    _municipio = v;
                    _faltaMunicipio = false;
                  }),
                ),
              if (_faltaMunicipio)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Elige el municipio',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              Text(
                '¿Dónde queda la finca? (opcional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Sirve para el clima y para ubicar la finca en el mapa de la '
                'Red. El GPS funciona sin señal.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              if (_latitud != null && _longitud != null)
                _UbicacionGuardada(
                  latitud: _latitud!,
                  longitud: _longitud!,
                  onQuitar: () => setState(() {
                    _latitud = null;
                    _longitud = null;
                  }),
                )
              else
                FilledButton.icon(
                  key: const Key('boton_estoy_en_la_finca'),
                  style: FilledButton.styleFrom(
                    backgroundColor: PaletaCacao.verde,
                  ),
                  onPressed: _buscandoGps ? null : _usarMiUbicacion,
                  icon: _buscandoGps
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.my_location, size: 26),
                  label: Text(
                    _buscandoGps
                        ? 'Buscando la ubicación…'
                        : 'Estoy en la finca: usar mi ubicación',
                  ),
                ),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: _elegirEnMapa,
                icon: const Icon(Icons.map_outlined),
                label: Text(
                  _latitud == null
                      ? 'O marcarla en el mapa'
                      : 'Cambiarla en el mapa',
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: Text(esNueva ? 'Registrar finca' : 'Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Se muestra en el lugar del desplegable de municipio mientras no se haya
/// elegido un departamento: evita mostrar un desplegable vacío o con todos
/// los municipios del país mezclados.
class _AvisoSinDepartamento extends StatelessWidget {
  const _AvisoSinDepartamento({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: PaletaCacao.tarjeta,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_city_outlined,
            color: color.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Elija primero el departamento para ver sus municipios',
              style: TextStyle(
                color: PaletaCacao.crema.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// La ubicación ya tomada: se ve que quedó guardada sin mostrar números que
/// no le dicen nada al productor (van en letra pequeña, para el técnico).
class _UbicacionGuardada extends StatelessWidget {
  const _UbicacionGuardada({
    required this.latitud,
    required this.longitud,
    required this.onQuitar,
  });

  final double latitud;
  final double longitud;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      decoration: BoxDecoration(
        color: PaletaCacao.verdeClaro,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: PaletaCacao.verde, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubicación guardada',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${latitud.toStringAsFixed(5)}, '
                  '${longitud.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Quitar la ubicación',
            onPressed: onQuitar,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
