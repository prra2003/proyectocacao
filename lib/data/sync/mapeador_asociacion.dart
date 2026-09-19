import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/enums.dart';
import 'api_remota.dart';

/// Traduce entre la fila local de `asociaciones` y su equivalente remoto.
///
/// Es un catálogo compartido, sin dueño: a diferencia de productores, fincas y
/// lotes, aquí no hay `usuario_id` que filtrar ni padre que esperar.
class MapeadorAsociacion {
  const MapeadorAsociacion._();

  static const entidad = 'asociaciones';

  static FilaRemota aRemoto(Asociacion fila) => {
    'id': fila.id,
    'nombre': fila.nombre,
    'municipio': fila.municipio,
    'departamento': fila.departamento,
    'created_at': fila.createdAt.toUtc().toIso8601String(),
    'deleted_at': fila.deletedAt?.toUtc().toIso8601String(),
  };

  static AsociacionesCompanion deRemoto(FilaRemota fila) {
    final sello = selloDe(fila);
    return AsociacionesCompanion(
      id: Value(fila['id']! as String),
      nombre: Value(fila['nombre']! as String),
      municipio: Value(fila['municipio']! as String),
      departamento: Value(fila['departamento']! as String),
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
