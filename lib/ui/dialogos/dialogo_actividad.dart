import 'package:flutter/material.dart';

import '../../data/local/enums.dart';
import '../formato.dart';
import '../widgets/comunes.dart';
import '../widgets/selector_fecha.dart';

typedef DatosActividad = ({
  TipoActividad tipo,
  DateTime fecha,
  String? observaciones,
});

Future<DatosActividad?> pedirDatosActividad(BuildContext context) {
  return showDialog<DatosActividad>(
    context: context,
    builder: (_) => const _DialogoActividad(),
  );
}

class _DialogoActividad extends StatefulWidget {
  const _DialogoActividad();

  @override
  State<_DialogoActividad> createState() => _DialogoActividadState();
}

class _DialogoActividadState extends State<_DialogoActividad> {
  final _observaciones = TextEditingController();
  var _tipo = TipoActividad.poda;
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _observaciones.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar labor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tipo in TipoActividad.values)
                  ChoiceChip(
                    label: Text(etiquetaActividad(tipo)),
                    avatar: Icon(iconoActividad(tipo), size: 18),
                    selected: _tipo == tipo,
                    onSelected: (_) => setState(() => _tipo = tipo),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SelectorFecha(
              etiqueta: 'Fecha de la labor',
              fecha: _fecha,
              onCambio: (f) => setState(() => _fecha = f),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('campo_observaciones_actividad'),
              controller: _observaciones,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                hintText: 'Qué se hizo, con qué producto, dosis...',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
          onPressed: () => Navigator.of(context).pop((
            tipo: _tipo,
            fecha: _fecha,
            observaciones: textoONulo(_observaciones.text),
          )),
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}
