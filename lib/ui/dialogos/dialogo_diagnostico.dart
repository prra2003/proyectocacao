import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/local/enums.dart';
import '../formato.dart';
import '../tema.dart';
import '../widgets/campo_dictado.dart';
import '../widgets/comunes.dart';
import '../widgets/selector_fecha.dart';

typedef DatosDiagnostico = ({
  DateTime fecha,
  EstadoFenologico estado,
  String? fotoPath,
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
  String? _fotoPath;

  @override
  void dispose() {
    _notas.dispose();
    super.dispose();
  }

  /// La foto se copia a la carpeta de la app: lo que devuelve la cámara es un
  /// archivo temporal que el sistema puede borrar cuando quiera.
  Future<void> _tomarFoto(ImageSource origen) async {
    try {
      final tomada = await ImagePicker().pickImage(
        source: origen,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (tomada == null) return;
      final carpeta = await getApplicationDocumentsDirectory();
      final destino = p.join(
        carpeta.path,
        'diagnostico_${DateTime.now().millisecondsSinceEpoch}'
        '${p.extension(tomada.path)}',
      );
      await File(tomada.path).copy(destino);
      if (mounted) setState(() => _fotoPath = destino);
    } on Exception catch (_) {
      if (mounted) avisar(context, 'No se pudo guardar la foto');
    }
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
            const SizedBox(height: 16),
            SelectorFecha(
              etiqueta: 'Fecha del diagnóstico',
              fecha: _fecha,
              onCambio: (f) => setState(() => _fecha = f),
            ),
            const SizedBox(height: 14),
            if (_fotoPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(_fotoPath!),
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _tomarFoto(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Foto'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _tomarFoto(ImageSource.gallery),
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Galería'),
                  ),
                ),
              ],
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
            fotoPath: _fotoPath,
            notas: textoONulo(_notas.text),
          )),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
