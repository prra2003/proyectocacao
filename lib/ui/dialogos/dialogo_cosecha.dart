import 'package:flutter/material.dart';

import '../widgets/comunes.dart';
import '../widgets/selector_fecha.dart';

typedef DatosCosecha = ({
  DateTime fecha,
  double cantidadKg,
  String? observaciones,
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

  @override
  void dispose() {
    _cantidad.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  void _aceptar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      fecha: _fecha,
      cantidadKg: aNumero(_cantidad.text)!,
      observaciones: textoONulo(_observaciones.text),
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
                validator: (v) {
                  final kg = aNumero(v ?? '');
                  if (kg == null || kg <= 0) return 'Cantidad inválida';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              SelectorFecha(
                etiqueta: 'Fecha de la cosecha',
                fecha: _fecha,
                onCambio: (f) => setState(() => _fecha = f),
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('campo_observaciones_cosecha'),
                controller: _observaciones,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  hintText: 'Cacao en baba, seco, calidad...',
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
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
