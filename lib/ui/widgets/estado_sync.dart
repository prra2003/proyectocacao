import 'package:flutter/material.dart';

import '../../data/local/database.dart';
import '../../data/sync/sync_service.dart';
import '../../data/sync/sync_state.dart';
import '../tema.dart';
import 'comunes.dart';

/// Cinta de sincronización: dice si hay algo sin subir y lo sube al tocarla.
///
/// Es la única parte de la app donde la sincronización se ve. Todo lo demás
/// sigue funcionando igual sin señal: lo que se anota queda guardado aquí y
/// esta cinta lleva la cuenta de lo que falta por mandar.
class EstadoSync extends StatelessWidget {
  const EstadoSync({super.key, required this.db, required this.sync});

  final AppDatabase db;
  final SyncService sync;

  Future<void> _sincronizar(BuildContext context) async {
    final resultado = await sync.sincronizar();
    if (!context.mounted) return;
    avisar(
      context,
      resultado.ok
          ? 'Todo al día: ${resultado.subidos} enviados, '
                '${resultado.bajados} recibidos'
          : 'No se pudo sincronizar: ${resultado.error}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: db.syncDao.watchPendientes(),
      builder: (context, snapshot) {
        final pendientes = snapshot.data ?? 0;
        return ValueListenableBuilder<SyncState>(
          valueListenable: sync.estado,
          builder: (context, estado, _) {
            final sincronizando = estado.sincronizando;
            final alDia = pendientes == 0;
            return Material(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: sincronizando ? null : () => _sincronizar(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      if (sincronizando)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: Colors.white,
                          ),
                        )
                      else
                        Icon(
                          alDia
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_upload_outlined,
                          size: 24,
                          color: Colors.white,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sincronizando
                              ? 'Sincronizando…'
                              : alDia
                              ? 'Todo guardado y enviado'
                              : pendientes == 1
                              ? '1 cambio sin enviar'
                              : '$pendientes cambios sin enviar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (!alDia && !sincronizando)
                        const Text(
                          'Enviar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: PaletaCacao.verdeClaro,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
