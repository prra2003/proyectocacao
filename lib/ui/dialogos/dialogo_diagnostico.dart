import 'package:flutter/material.dart';

import '../../data/local/enums.dart';
import '../formato.dart';
import '../tema.dart';
import '../widgets/campo_dictado.dart';
import '../widgets/nota_bpa.dart';
import '../widgets/comunes.dart';
import '../widgets/selector_fecha.dart';

typedef DatosDiagnostico = ({
  DateTime fecha,
  EstadoFenologico estado,
  String? notas,
});

Future<DatosDiagnostico?> pedirDatosDiagnostico(BuildContext context) {
  return showDialog<DatosDiagnostico>(
    context: context,
    builder: (_) => const _DialogoDiagnostico(),
  );
}

class _DialogoDiagnostico extends StatefulWidget {
  const _DialogoDiagnostico();

  @override
  State<_DialogoDiagnostico> createState() => _DialogoDiagnosticoState();
}

class _DialogoDiagnosticoState extends State<_DialogoDiagnostico> {
  final _notas = TextEditingController();
  var _estado = EstadoFenologico.floracion;
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _notas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Estado del lote'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final estado in EstadoFenologico.values)
                  ChoiceChip(
                    label: Text(etiquetaEstado(estado)),
                    selected: _estado == estado,
                    onSelected: (_) => setState(() => _estado = estado),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const NotaBpa(
              titulo: '¿Para qué sirve anotar cómo ve el lote?',
              puntos: [
                'Las BPA parten de mirar el cultivo antes de aplicarle algo. '
                    'Dejar anotado qué vio y cuándo es lo que sustenta por qué '
                    'después fumigó o abonó.',
                'Si va apareciendo monilia o escoba de bruja, el registro '
                    'muestra desde cuándo y qué tan rápido avanzó.',
                'Al técnico que lo visite le sirve más esto que un recuerdo: '
                    'puede ver la historia del lote en orden.',
              ],
            ),
            const SizedBox(height: 16),
            SelectorFecha(
              etiqueta: 'Fecha del diagnóstico',
              fecha: _fecha,
              onCambio: (f) => setState(() => _fecha = f),
            ),
            const SizedBox(height: 14),
            CampoDictado(
              campoKey: const Key('campo_notas_diagnostico'),
              controller: _notas,
              etiqueta: '¿Cómo ve el lote?',
              hint: 'Manchas, monilia, escoba... Toque el micrófono y hable',
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
          style: FilledButton.styleFrom(
            minimumSize: const Size(100, 44),
            backgroundColor: PaletaCacao.verde,
          ),
          onPressed: () => Navigator.of(context).pop((
            fecha: _fecha,
            estado: _estado,
            notas: textoONulo(_notas.text),
          )),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
