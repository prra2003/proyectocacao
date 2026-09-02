import 'package:flutter/material.dart';

import '../formato.dart';

/// Campo de fecha con el mismo aspecto que los demás campos del formulario.
class SelectorFecha extends StatelessWidget {
  const SelectorFecha({
    super.key,
    required this.etiqueta,
    required this.fecha,
    required this.onCambio,
    this.primeraFecha,
    this.ultimaFecha,
  });

  final String etiqueta;
  final DateTime? fecha;
  final ValueChanged<DateTime> onCambio;
  final DateTime? primeraFecha;
  final DateTime? ultimaFecha;

  Future<void> _elegir(BuildContext context) async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: fecha ?? hoy,
      firstDate: primeraFecha ?? DateTime(hoy.year - 60),
      lastDate: ultimaFecha ?? hoy,
      helpText: etiqueta,
    );
    if (elegida != null) onCambio(elegida);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _elegir(context),
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(
          fecha == null ? 'Sin definir' : fechaCorta(fecha!),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
