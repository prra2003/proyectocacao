import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../tema.dart';
import 'comunes.dart';

/// Casilla de texto libre con un micrófono para dictar en vez de escribir.
///
/// En el campo se anota de pie y con las manos ocupadas: hablar es mucho más
/// fácil que escribir en el teclado del celular. Lo dictado se agrega al final
/// de lo que ya hubiera, así se puede dictar por partes o corregir a mano.
///
/// El reconocimiento de voz es el del propio teléfono. Si no está disponible
/// (sin permiso de micrófono, o un equipo sin el servicio), se avisa y la
/// casilla sigue sirviendo para escribir.
class CampoDictado extends StatefulWidget {
  const CampoDictado({
    super.key,
    required this.controller,
    required this.etiqueta,
    this.hint,
    this.maxLines = 3,
    this.campoKey,
  });

  final TextEditingController controller;
  final String etiqueta;
  final String? hint;
  final int maxLines;

  /// Va en el campo de texto de adentro: es lo que buscan los tests.
  final Key? campoKey;

  @override
  State<CampoDictado> createState() => _CampoDictadoState();
}

class _CampoDictadoState extends State<CampoDictado> {
  final _voz = SpeechToText();
  var _escuchando = false;

  @override
  void dispose() {
    if (_escuchando) _voz.stop();
    super.dispose();
  }

  Future<void> _dictar() async {
    if (_escuchando) {
      await _voz.stop();
      if (mounted) setState(() => _escuchando = false);
      return;
    }

    var disponible = false;
    try {
      disponible = await _voz.initialize(
        onStatus: (estado) {
          if ((estado == 'done' || estado == 'notListening') && mounted) {
            setState(() => _escuchando = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _escuchando = false);
        },
      );
    } on Exception {
      disponible = false;
    }
    if (!mounted) return;
    if (!disponible) {
      avisar(context, 'El dictado no está disponible en este teléfono');
      return;
    }

    final antes = widget.controller.text.trim();
    setState(() => _escuchando = true);
    await _voz.listen(
      listenOptions: SpeechListenOptions(partialResults: true),
      onResult: (resultado) {
        final texto = [
          antes,
          resultado.recognizedWords,
        ].where((t) => t.isNotEmpty).join(' ');
        widget.controller.value = TextEditingValue(
          text: texto,
          selection: TextSelection.collapsed(offset: texto.length),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: widget.campoKey,
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.etiqueta,
            hintText: widget.hint,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton.filled(
                tooltip: _escuchando ? 'Dejar de escuchar' : 'Dictar',
                style: IconButton.styleFrom(
                  backgroundColor: _escuchando
                      ? PaletaCacao.verde
                      : PaletaCacao.dorado,
                  foregroundColor: Colors.white,
                ),
                onPressed: _dictar,
                icon: Icon(_escuchando ? Icons.stop_rounded : Icons.mic),
              ),
            ),
          ),
          maxLines: widget.maxLines,
          textCapitalization: TextCapitalization.sentences,
        ),
        if (_escuchando)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              'Escuchando… hable ahora',
              style: TextStyle(
                color: PaletaCacao.verde,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
