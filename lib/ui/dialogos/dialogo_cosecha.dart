import 'package:flutter/material.dart';

import '../tema.dart';
import '../widgets/campo_dictado.dart';
import '../widgets/comunes.dart';
import '../widgets/selector_fecha.dart';

/// Los 3 tipos de producto que trae el documento de requerimientos: el
/// productor elige uno, no escribe a mano.
const _tiposProducto = ['Cacao en baba', 'Cacao fermentado', 'Cacao seco'];

typedef DatosCosecha = ({
  DateTime fecha,
  double cantidadKg,
  String? observaciones,
  String? tipoProducto,
  String? fotoPath,
});

Future<DatosCosecha?> pedirDatosCosecha(BuildContext context) {
  return showDialog<DatosCosecha>(
    context: context,
    builder: (_) => const _DialogoCosecha(),
  );
}

class _DialogoCosecha extends StatefulWidget {
  const _DialogoCosecha();

  @override
  State<_DialogoCosecha> createState() => _DialogoCosechaState();
}

class _DialogoCosechaState extends State<_DialogoCosecha> {
  final _formKey = GlobalKey<FormState>();
  final _cantidad = TextEditingController();
  final _observaciones = TextEditingController();
  DateTime _fecha = DateTime.now();
  String? _tipoProducto;
  String? _fotoPath;
  var _cargandoFoto = false;

  @override
  void dispose() {
    _cantidad.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    setState(() => _cargandoFoto = true);
    try {
      final destino = await elegirFoto(context, carpeta: 'fotos_cosechas');
      if (mounted && destino != null) setState(() => _fotoPath = destino);
    } finally {
      if (mounted) setState(() => _cargandoFoto = false);
    }
  }

  void _aceptar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      fecha: _fecha,
      cantidadKg: aNumero(_cantidad.text)!,
      observaciones: textoONulo(_observaciones.text),
      tipoProducto: _tipoProducto,
      fotoPath: _fotoPath,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar cosecha'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('campo_cantidad'),
                controller: _cantidad,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  suffixText: 'kg',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => validarRango(
                  v,
                  min: 0,
                  // Una sola entrega de 20 toneladas ya no es creíble para
                  // un lote de un productor individual.
                  max: 20000,
                  etiqueta: 'Cantidad',
                ),
              ),
              const SizedBox(height: 14),
              SelectorFecha(
                etiqueta: 'Fecha de la cosecha',
                fecha: _fecha,
                onCambio: (f) => setState(() => _fecha = f),
              ),
              const SizedBox(height: 16),
              // Lo que pide el documento para el registro de cosecha: el
              // tipo de producto va de desplegable, no de texto libre.
              SelectorDesplegable(
                key: const Key('campo_tipo_producto'),
                etiqueta: 'Tipo de producto',
                icono: Icons.eco_outlined,
                color: PaletaCacao.dorado,
                opciones: _tiposProducto,
                valor: _tipoProducto,
                onCambio: (v) => setState(() => _tipoProducto = v),
              ),
              const SizedBox(height: 16),
              CampoFoto(
                fotoPath: _fotoPath,
                cargando: _cargandoFoto,
                onTap: _elegirFoto,
                onQuitar: () => setState(() => _fotoPath = null),
                etiqueta: 'Tomar una foto (si quiere)',
              ),
              const SizedBox(height: 14),
              CampoDictado(
                campoKey: const Key('campo_observaciones_cosecha'),
                controller: _observaciones,
                etiqueta: 'Observaciones',
                hint: 'Secado al sol, calidad... Toque el micrófono y hable',
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
          onPressed: _aceptar,
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}
