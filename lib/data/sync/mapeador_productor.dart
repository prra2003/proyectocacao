import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/enums.dart';
import 'api_remota.dart';

/// Traduce entre la fila local de `productores` y su equivalente remoto.
///
/// Dos cosas que **no** viajan al servidor: `sync_status` y `sync_error`, que
/// son estado local ("¿ya subí esto?"), y `updated_at`, que lo sella el
/// servidor para que el reloj del teléfono no sea la referencia.
class MapeadorProductor {
  const MapeadorProductor._();

  static const entidad = 'productores';

  static FilaRemota aRemoto(Productor fila, String authUid) => {
    'id': fila.id,
    'usuario_id': authUid,
    'nombre_completo': fila.nombreCompleto,
    'telefono': fila.telefono,
    'email': fila.email,
    'asociacion_id': fila.asociacionId,
    'created_at': fila.createdAt.toUtc().toIso8601String(),
    'deleted_at': fila.deletedAt?.toUtc().toIso8601String(),
  };

  /// [usuarioLocal] es la identidad de esta instalación: lo que llega del
  /// servidor viene filtrado por RLS, así que es todo de este usuario.
  static ProductoresCompanion deRemoto(FilaRemota fila, String usuarioLocal) {
    final sello = selloDe(fila);
    return ProductoresCompanion(
      id: Value(fila['id']! as String),
      usuarioId: Value(usuarioLocal),
      nombreCompleto: Value(fila['nombre_completo']! as String),
      telefono: Value(fila['telefono'] as String?),
      email: Value(fila['email'] as String?),
      asociacionId: Value(fila['asociacion_id'] as String?),
      createdAt: Value(_fecha(fila['created_at'])!),
      updatedAt: Value(sello),
      deletedAt: Value(_fecha(fila['deleted_at'])),
      serverUpdatedAt: Value(sello),
      syncStatus: const Value(SyncStatus.synced),
      syncError: const Value(null),
    );
  }

  /// El `updated_at` que puso el servidor.
  static DateTime selloDe(FilaRemota fila) => _fecha(fila['updated_at'])!;

  static DateTime? _fecha(Object? valor) =>
      valor == null ? null : DateTime.parse(valor as String).toLocal();
}
