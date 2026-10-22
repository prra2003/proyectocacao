import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'tema.dart';

/// Ruta del video dentro de la app. Va empaquetado en los assets a propósito:
/// en el campo no hay señal, y un tutorial que necesita internet para
/// explicar cómo usar una app que funciona sin internet no sirve de mucho.
const rutaVideoTutorialRegistro = 'assets/tutorial_registro.mp4';

/// Abre el tutorial de registro a pantalla completa.
Future<void> abrirTutorialRegistro(BuildContext context) {
  return Navigator.of(context).push(
    RutaCacao<void>(builder: (_) => const TutorialRegistroScreen()),
  );
}

/// Tarjeta para poner arriba de los formularios del registro: le avisa a quien
/// se atasca que hay un video que lo explica, sin obligarlo a verlo.
class TarjetaTutorial extends StatelessWidget {
  const TarjetaTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ver el video tutorial de cómo registrarse',
      child: Material(
        color: PaletaCacao.verdeClaro,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => abrirTutorialRegistro(context),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: PaletaCacao.verde,
                  size: 44,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Tiene dudas? Vea el video',
                        style: TextStyle(
                          color: PaletaCacao.cafeOscuro,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Le explica paso a paso cómo registrarse.',
                        style: TextStyle(
                          color: PaletaCacao.cafeOscuro,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: PaletaCacao.verde),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// El video que explica cómo registrarse, con el mismo cuidado de siempre:
/// botones grandes, nada que haya que adivinar y un mensaje claro si algo
/// falla.
class TutorialRegistroScreen extends StatefulWidget {
  const TutorialRegistroScreen({super.key});

  @override
  State<TutorialRegistroScreen> createState() => _TutorialRegistroScreenState();
}

class _TutorialRegistroScreenState extends State<TutorialRegistroScreen> {
  late VideoPlayerController _video;
  var _fallo = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _video = VideoPlayerController.asset(rutaVideoTutorialRegistro)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _video
        .initialize()
        .then((_) async {
          if (!mounted) return;
          setState(() => _fallo = false);
          // En el navegador, reproducir sin que la persona haya tocado la
          // página puede estar bloqueado. Si pasa, queda en pausa con el
          // botón de reproducir a la vista, que es lo correcto.
          try {
            await _video.play();
          } on Object {
            return;
          }
        })
        .catchError((Object _) {
          if (mounted) setState(() => _fallo = true);
        });
  }

  void _reintentar() {
    _video.dispose();
    setState(() => _fallo = false);
    _cargar();
  }

  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }

  void _alternar() {
    final valor = _video.value;
    if (valor.position >= valor.duration && valor.duration > Duration.zero) {
      _video
        ..seekTo(Duration.zero)
        ..play();
    } else if (valor.isPlaying) {
      _video.pause();
    } else {
      _video.play();
    }
  }

  String _tiempo(Duration d) {
    final minutos = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final segundos = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaCacao.cafeOscuro,
      appBar: cabeceraCacao(titulo: const Text('Cómo registrarse')),
      body: SafeArea(
        child: _fallo
            ? _MensajeDeFallo(onReintentar: _reintentar)
            : !_video.value.isInitialized
            ? const Center(
                child: CircularProgressIndicator(color: PaletaCacao.dorado),
              )
            : _Reproductor(
                video: _video,
                tiempo: _tiempo,
                onAlternar: _alternar,
              ),
      ),
    );
  }
}

class _Reproductor extends StatelessWidget {
  const _Reproductor({
    required this.video,
    required this.tiempo,
    required this.onAlternar,
  });

  final VideoPlayerController video;
  final String Function(Duration) tiempo;
  final VoidCallback onAlternar;

  @override
  Widget build(BuildContext context) {
    final valor = video.value;
    final terminado =
        valor.duration > Duration.zero && valor.position >= valor.duration;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: valor.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: onAlternar,
                    behavior: HitTestBehavior.opaque,
                    child: VideoPlayer(video),
                  ),
                  if (!valor.isPlaying)
                    IgnorePointer(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xAA000000),
                        ),
                        child: Icon(
                          terminado ? Icons.replay : Icons.play_arrow_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: VideoProgressIndicator(
            video,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: 10),
            colors: const VideoProgressColors(
              playedColor: PaletaCacao.dorado,
              bufferedColor: Color(0x55FFFFFF),
              backgroundColor: Color(0x33FFFFFF),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: Row(
            children: [
              IconButton(
                tooltip: valor.isPlaying ? 'Pausar' : 'Reproducir',
                iconSize: 44,
                color: Colors.white,
                onPressed: onAlternar,
                icon: Icon(
                  terminado
                      ? Icons.replay
                      : valor.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${tiempo(valor.position)} / ${tiempo(valor.duration)}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            'Este video está guardado en la aplicación: se ve sin internet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _MensajeDeFallo extends StatelessWidget {
  const _MensajeDeFallo({required this.onReintentar});

  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_off_outlined,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo reproducir el video',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Puede registrarse igual: solo le pediremos su nombre y los '
              'datos de la finca.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onReintentar,
              child: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}
