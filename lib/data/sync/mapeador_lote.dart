import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/enums.dart';
import 'api_remota.dart';

/// Traduce entre la fila local de `lotes` y su equivalente remoto.
class MapeadorLote {
  const MapeadorLote._();

  static const entidad = 'lotes';

  static FilaRemota aRemoto(Lote fila) => {
    'id': fila.id,
    'finca_id': fila.fincaId,
    'nombre': fila.nombre,
    'codigo': fila.codigo,
    'area_sembrada_ha': fila.areaSembradaHa,
    'variedad_cacao': fila.variedadCacao,
    'fecha_siembra': fila.fechaSiembra.toUtc().toIso8601String(),
    'created_at': fila.createdAt.toUtc().toIso8601String(),
    'deleted_at': fila.deletedAt?.toUtc().toIso8601String(),
  };

  /// [borradoForzado] entra cuando la finca ya está borrada aquí: el lote se
  /// guarda, pero muerto, para no dejar un lote vivo colgando de un padre
  /// borrado ni tener que revivir la finca.
  static LotesCompanion deRemoto(FilaRemota fila, {DateTime? borradoForzado}) {
    final sello = selloDe(fila);
    return LotesCompanion(
      id: Value(fila['id']! as String),
      fincaId: Value(fila['finca_id']! as String),
      nombre: Value(fila['nombre']! as String),
      codigo: Value((fila['codigo'] as String?) ?? ''),
      areaSembradaHa: Value((fila['area_sembrada_ha']! as num).toDouble()),
      variedadCacao: Value(fila['variedad_cacao']! as String),
      fechaSiembra: Value(fecha(fila['fecha_siembra'])!),
      createdAt: Value(fecha(fila['created_at'])!),
      updatedAt: Value(sello),
      deletedAt: Value(fecha(fila['deleted_at']) ?? borradoForzado),
      serverUpdatedAt: Value(sello),
      syncStatus: const Value(SyncStatus.synced),
      syncError: const Value(null),
    );
  }

  static DateTime selloDe(FilaRemota fila) => fecha(fila['updated_at'])!;

  static DateTime? fecha(Object? valor) =>
      valor == null ? null : DateTime.parse(valor as String).toLocal();
}
