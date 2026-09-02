import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/enums.dart';
import 'api_remota.dart';

/// Traduce entre la fila local de `fincas` y su equivalente remoto.
///
/// Igual que en productores: no viajan `sync_status` ni `sync_error` (estado
/// local) ni `updated_at` (lo sella el servidor).
class MapeadorFinca {
  const MapeadorFinca._();

  static const entidad = 'fincas';

  static FilaRemota aRemoto(Finca fila) => {
    'id': fila.id,
    'productor_id': fila.productorId,
    'nombre': fila.nombre,
    'latitud': fila.latitud,
    'longitud': fila.longitud,
    'municipio': fila.municipio,
    'departamento': fila.departamento,
    'created_at': fila.createdAt.toUtc().toIso8601String(),
    'deleted_at': fila.deletedAt?.toUtc().toIso8601String(),
  };

  static FincasCompanion deRemoto(FilaRemota fila) {
    final sello = selloDe(fila);
    return FincasCompanion(
      id: Value(fila['id']! as String),
      productorId: Value(fila['productor_id']! as String),
      nombre: Value(fila['nombre']! as String),
      latitud: Value((fila['latitud'] as num?)?.toDouble()),
      longitud: Value((fila['longitud'] as num?)?.toDouble()),
      municipio: Value(fila['municipio']! as String),
      departamento: Value(fila['departamento']! as String),
      createdAt: Value(fecha(fila['created_at'])!),
      updatedAt: Value(sello),
      deletedAt: Value(fecha(fila['deleted_at'])),
      serverUpdatedAt: Value(sello),
      syncStatus: const Value(SyncStatus.synced),
      syncError: const Value(null),
    );
  }

  static DateTime selloDe(FilaRemota fila) => fecha(fila['updated_at'])!;

  static DateTime? fecha(Object? valor) =>
      valor == null ? null : DateTime.parse(valor as String).toLocal();
}
