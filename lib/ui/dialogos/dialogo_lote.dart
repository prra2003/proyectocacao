import 'package:flutter/material.dart';

import '../widgets/comunes.dart';
import '../widgets/selector_fecha.dart';

typedef DatosLote = ({
  String nombre,
  double areaHa,
  String variedad,
  DateTime fechaSiembra,
});

/// Variedades más comunes en Colombia, como atajo para no escribirlas.
const _variedades = [
  'CCN-51',
  'ICS-95',
  'ICS-1',
  'TCS-01',
  'FEAR-5',
  'Criollo',
];

Future<DatosLote?> pedirDatosLote(BuildContext context) {
  return showDialog<DatosLote>(
    context: context,
    builder: (_) => const _DialogoLote(),
  );
}

class _DialogoLote extends StatefulWidget {
  const _DialogoLote();

  @override
  State<_DialogoLote> createState() => _DialogoLoteState();
}

class _DialogoLoteState extends State<_DialogoLote> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _area = TextEditingController();
  final _variedad = TextEditingController();
  DateTime? _fechaSiembra;
  var _faltaFecha = false;

  @override
  void dispose() {
    _nombre.dispose();
    _area.dispose();
    _variedad.dispose();
    super.dispose();
  }

  void _aceptar() {
    final fechaOk = _fechaSiembra != null;
    setState(() => _faltaFecha = !fechaOk);
    if (!_formKey.currentState!.validate() || !fechaOk) return;
    Navigator.of(context).pop((
      nombre: _nombre.text.trim(),
      areaHa: aNumero(_area.text)!,
      variedad: _variedad.text.trim(),
      fechaSiembra: _fechaSiembra!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo lote'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('campo_nombre_lote'),
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre del lote'),
                textCapitalization: TextCapitalization.words,
                validator: campoRequerido,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('campo_area'),
                controller: _area,
                decoration: const InputDecoration(
                  labelText: 'Área sembrada',
                  suffixText: 'ha',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final area = aNumero(v ?? '');
                  if (area == null || area <= 0) return 'Área inválida';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('campo_variedad'),
                controller: _variedad,
                decoration: const InputDecoration(
                  labelText: 'Variedad de cacao',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: campoRequerido,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  for (final variedad in _variedades)
                    ActionChip(
                      label: Text(variedad),
                      onPressed: () =>
                          setState(() => _variedad.text = variedad),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SelectorFecha(
                etiqueta: 'Fecha de siembra',
                fecha: _fechaSiembra,
                onCambio: (f) => setState(() {
                  _fechaSiembra = f;
                  _faltaFecha = false;
                }),
              ),
              if (_faltaFecha)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Elige la fecha de siembra',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
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
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
