import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
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

  /// El idioma que se le pide al teléfono. Se busca una vez y se guarda.
  String? _idioma;

  /// Lo que ya quedó reconocido de firme en esta sesión de dictado.
  ///
  /// El teléfono entrega frases sueltas: cuando la persona hace una pausa,
  /// cierra una frase y empieza otra desde cero. Sin ir acumulando aquí, cada
  /// frase nueva borraba la anterior y solo quedaba la última.
  var _firme = '';
  var _antes = '';

  @override
  void dispose() {
    if (_escuchando) _voz.stop();
    super.dispose();
  }

  /// Busca un idioma español entre los que el teléfono reconoce.
  ///
  /// Sin esto se usa el idioma del sistema, y en un teléfono configurado en
  /// inglés —o con el teclado en inglés— el dictado en español sale hecho un
  /// disparate. Se prefiere Colombia; si no está, cualquier español sirve.
  Future<String?> _idiomaEspanol() async {
    if (_idioma != null) return _idioma;
    try {
      final idiomas = await _voz.locales();
      final espanoles = idiomas
          .where((i) => i.localeId.toLowerCase().startsWith('es'))
          .toList();
      if (espanoles.isEmpty) return null;
      final colombia = espanoles.where(
        (i) => i.localeId.toLowerCase().contains('co'),
      );
      _idioma = (colombia.isNotEmpty ? colombia.first : espanoles.first)
          .localeId;
    } on Exception {
      return null;
    }
    return _idioma;
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
      avisar(
        context,
        'El dictado no está disponible. Revise que le haya dado permiso '
        'al micrófono.',
      );
      return;
    }

    _antes = widget.controller.text.trim();
    _firme = '';
    setState(() => _escuchando = true);
    await _voz.listen(
      listenOptions: SpeechListenOptions(
        localeId: await _idiomaEspanol(),
        partialResults: true,
        // "Dictado" en vez de "confirmación": la segunda está pensada para
        // respuestas de una o dos palabras y corta apenas oye algo.
        listenMode: ListenMode.dictation,
        // El teléfono corta a los pocos segundos de silencio, y en el campo
        // la gente piensa mientras habla. Se le da aire: hasta medio minuto
        // callado y dos minutos de dictado seguido.
        pauseFor: const Duration(seconds: 30),
        listenFor: const Duration(minutes: 2),
        // Un error pasajero no debe tumbar el dictado entero.
        cancelOnError: false,
        autoPunctuation: true,
      ),
      onResult: _alOir,
    );
  }

  /// Junta lo que ya estaba escrito, las frases ya cerradas y la que se está
  /// oyendo en este momento.
  void _alOir(SpeechRecognitionResult resultado) {
    final texto = [
      _antes,
      _firme,
      resultado.recognizedWords,
    ].where((t) => t.trim().isNotEmpty).join(' ');
    widget.controller.value = TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
    // Frase cerrada: pasa a lo firme para que la siguiente no la pise.
    if (resultado.finalResult) {
      _firme = [
        _firme,
        resultado.recognizedWords,
      ].where((t) => t.trim().isNotEmpty).join(' ');
    }
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
