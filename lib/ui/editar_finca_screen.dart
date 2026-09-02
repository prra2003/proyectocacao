import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/perfil_repository.dart';

import 'package:latlong2/latlong.dart';

import 'mapa_screen.dart';
import 'tema.dart';
import 'widgets/comunes.dart';

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
  late final _municipio = TextEditingController(
    text: widget.finca?.municipio ?? '',
  );
  late final _departamento = TextEditingController(
    text: widget.finca?.departamento ?? '',
  );
  late final _latitud = TextEditingController(
    text: widget.finca?.latitud?.toString() ?? '',
  );
  late final _longitud = TextEditingController(
    text: widget.finca?.longitud?.toString() ?? '',
  );
  var _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _municipio.dispose();
    _departamento.dispose();
    _latitud.dispose();
    _longitud.dispose();
    super.dispose();
  }

  /// Abre el mapa con lo que ya haya escrito y trae de vuelta el punto.
  Future<void> _elegirEnMapa() async {
    final lat = aNumero(_latitud.text);
    final lon = aNumero(_longitud.text);
    final elegido = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapaScreen(
          inicial: lat != null && lon != null ? LatLng(lat, lon) : null,
        ),
      ),
    );
    if (elegido == null) return;
    setState(() {
      _latitud.text = elegido.latitude.toStringAsFixed(5);
      _longitud.text = elegido.longitude.toStringAsFixed(5);
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    await widget.repo.guardarFinca(
      id: widget.finca?.id,
      productorId: widget.productorId,
      nombre: _nombre.text.trim(),
      municipio: _municipio.text.trim(),
      departamento: _departamento.text.trim(),
      latitud: aNumero(_latitud.text),
      longitud: aNumero(_longitud.text),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  String? _coordenada(String? valor, String campo, double maximo) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return null;
    final numero = aNumero(texto);
    if (numero == null) return 'La $campo no es un número';
    if (numero < -maximo || numero > maximo) {
      return 'La $campo va de -$maximo a $maximo';
    }
    return null;
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
              TextFormField(
                key: const Key('campo_nombre_finca'),
                controller: _nombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la finca',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: campoRequerido,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('campo_municipio'),
                controller: _municipio,
                decoration: const InputDecoration(
                  labelText: 'Municipio',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: campoRequerido,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('campo_departamento'),
                controller: _departamento,
                decoration: const InputDecoration(
                  labelText: 'Departamento',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: campoRequerido,
              ),
              const SizedBox(height: 22),
              Text(
                'Ubicación GPS (opcional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Sirve para el clima y para ubicar la finca en el mapa de la '
                'Red. El GPS funciona sin señal; el mapa necesita internet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _elegirEnMapa,
                icon: const Icon(Icons.map_outlined, size: 26),
                label: const Text('Marcar en el mapa'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('campo_latitud'),
                      controller: _latitud,
                      decoration: const InputDecoration(labelText: 'Latitud'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (v) => _coordenada(v, 'latitud', 90),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('campo_longitud'),
                      controller: _longitud,
                      decoration: const InputDecoration(labelText: 'Longitud'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (v) => _coordenada(v, 'longitud', 180),
                    ),
                  ),
                ],
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
