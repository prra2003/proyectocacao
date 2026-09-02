import 'sync_result.dart';

enum EstadoSync { inactivo, sincronizando, ok, error }

/// Lo que la UI puede mostrar sobre la sincronización, sin saber cómo funciona.
class SyncState {
  const SyncState({
    this.estado = EstadoSync.inactivo,
    this.lastSyncAt,
    this.ultimoResultado,
  });

  final EstadoSync estado;

  /// Cuándo terminó bien la última sincronización (reloj del dispositivo, solo
  /// para mostrarlo; el cursor de descarga usa el sello del servidor).
  final DateTime? lastSyncAt;

  final SyncResult? ultimoResultado;

  bool get sincronizando => estado == EstadoSync.sincronizando;

  SyncState copiaCon({
    EstadoSync? estado,
    DateTime? lastSyncAt,
    SyncResult? ultimoResultado,
  }) {
    return SyncState(
      estado: estado ?? this.estado,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      ultimoResultado: ultimoResultado ?? this.ultimoResultado,
    );
  }
}
