import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'tema.dart';
import 'tutorial_registro_screen.dart';
import 'widgets/comunes.dart';

/// El canal de YouTube de Cacaiva, donde están todos los videos de ayuda.
final canalCacaiva = Uri.parse(
  'https://www.youtube.com/channel/UCv3denL0TKZTuN_nyv2BnkA',
);

/// Un video de ayuda que vive en el canal de Cacaiva.
///
/// Solo el de registro va guardado dentro de la app (ver
/// [rutaVideoTutorialRegistro]): cada video pesa varios megas y se les sumaría
/// a cada versión de la app. Los demás se abren en YouTube, y un video nuevo
/// no obliga a publicar la app otra vez.
class VideoAyuda {
  const VideoAyuda({
    required this.titulo,
    required this.descripcion,
    required this.id,
  });

  final String titulo;
  final String descripcion;

  /// Lo que va después de `watch?v=` en el enlace de YouTube.
  final String id;

  Uri get enlace => Uri.parse('https://www.youtube.com/watch?v=$id');
}

/// En el orden en que una persona nueva los va a necesitar.
const videosDeAyuda = [
  VideoAyuda(
    titulo: 'Registro de lotes',
    descripcion: 'Cómo agregar sus lotes y ver su finca en el Inicio.',
    id: 'g7DugGmxr9A',
  ),
  VideoAyuda(
    titulo: 'Registro de actividades',
    descripcion: 'Cómo anotar las labores y las cosechas de cada lote.',
    id: 'CRrhv8bQFAQ',
  ),
  VideoAyuda(
    titulo: 'Menú de reportes',
    descripcion: 'Cómo ver el historial y los indicadores, y descargarlos.',
    id: '3upatJBb36k',
  ),
  VideoAyuda(
    titulo: 'Menú perfil',
    descripcion: 'Cómo ver y cambiar sus datos y guardar su cuenta.',
    id: 'nTd0XN9qyuQ',
  ),
];

/// Abre un enlace fuera de la app (en YouTube o el navegador). Devuelve si
/// se pudo abrir; es un parámetro de [AyudaScreen] para poder probarla sin un
/// teléfono.
typedef AbridorDeEnlaces = Future<bool> Function(Uri enlace);

Future<bool> _abrirFuera(Uri enlace) async {
  try {
    return await launchUrl(enlace, mode: LaunchMode.externalApplication);
  } on Object {
    return false;
  }
}

/// La puerta a los videos de ayuda: el que se ve sin internet y los del canal.
class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key, this.abrirEnlace = _abrirFuera});

  final AbridorDeEnlaces abrirEnlace;

  Future<void> _abrir(BuildContext context, Uri enlace) async {
    final abierto = await abrirEnlace(enlace);
    if (abierto || !context.mounted) return;
    avisar(
      context,
      'No se pudo abrir el video. Revise que tenga internet e intente de '
      'nuevo.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: cabeceraCacao(titulo: const Text('Ayuda')),
      body: FondoCacao(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            Text(
              'Videos que le explican la aplicación paso a paso.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _TarjetaVideo(
              icono: Icons.download_done_rounded,
              titulo: 'Cómo registrarse',
              descripcion: 'Su nombre y los datos de la finca, en dos pasos.',
              nota: 'Se ve sin internet',
              onTap: () => abrirTutorialRegistro(context),
            ),
            for (final video in videosDeAyuda) ...[
              const SizedBox(height: 12),
              _TarjetaVideo(
                icono: Icons.play_circle_fill_rounded,
                titulo: video.titulo,
                descripcion: video.descripcion,
                nota: 'Se abre en YouTube y necesita internet',
                onTap: () => _abrir(context, video.enlace),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _abrir(context, canalCacaiva),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Ver todos los videos de Cacaiva'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaVideo extends StatelessWidget {
  const _TarjetaVideo({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.nota,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final String nota;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Semantics(
      button: true,
      label: 'Ver el video: $titulo. $nota',
      excludeSemantics: true,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icono, size: 44, color: PaletaCacao.verde),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: tema.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(descripcion, style: tema.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        nota,
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La tarjeta de Perfil que lleva a [AyudaScreen].
class TarjetaAyuda extends StatelessWidget {
  const TarjetaAyuda({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            Navigator.of(context)
                .push(RutaCacao<void>(builder: (_) => const AyudaScreen())),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: PaletaCacao.verdeClaro,
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  size: 32,
                  color: PaletaCacao.verde,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ayuda', style: tema.textTheme.titleLarge),
                    Text(
                      'Videos que le explican cómo usar la app',
                      style: tema.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
