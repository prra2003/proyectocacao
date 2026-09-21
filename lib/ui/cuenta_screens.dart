import 'package:flutter/material.dart';

import '../data/sync/sync_service.dart';
import 'tema.dart';
import 'widgets/mazorca.dart';

/// Pantalla de espera mientras bajan los datos de la cuenta.
///
/// Es la única que queda de las tres que había: crear cuenta y entrar con
/// correo y contraseña desaparecieron cuando la identidad pasó a Google. No es
/// una pantalla de adorno: mientras la descarga inicial no termine, la app no
/// puede ofrecer crear un perfil, o quedarían dos productores en la misma
/// cuenta.

class RecuperandoScreen extends StatelessWidget {
  const RecuperandoScreen({super.key, required this.sync});

  final SyncService sync;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoCacao(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ValueListenableBuilder(
              valueListenable: sync.estado,
              builder: (context, estado, _) {
                final fallo = estado.ultimoResultado?.error;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Mazorca(tamano: 110),
                    const SizedBox(height: 28),
                    Text(
                      fallo == null
                          ? 'Recuperando sus datos…'
                          : 'No se pudieron recuperar sus datos',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fallo ??
                          'Estamos bajando su finca, sus lotes y sus '
                              'registros. Puede tardar un momento.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (fallo == null)
                      const CircularProgressIndicator()
                    else
                      FilledButton(
                        onPressed: sync.sincronizar,
                        child: const Text('Reintentar'),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
