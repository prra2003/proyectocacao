import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/enums.dart';
import 'api_remota.dart';

DateTime? _fecha(Object? valor) =>
    valor == null ? null : DateTime.parse(valor as String).toLocal();

DateTime _selloDe(FilaRemota fila) => _fecha(fila['updated_at'])!;

/// Traduce entre la fila local de `actividades_agricolas` y la remota.
class MapeadorActividad {
  const MapeadorActividad._();

  static const entidad = 'actividades_agricolas';

  static FilaRemota aRemoto(ActividadAgricola fila) => {
    'id': fila.id,
    'lote_id': fila.loteId,
    'tipo_actividad': fila.tipoActividad.name,
    'fecha': fila.fecha.toUtc().toIso8601String(),
    'observaciones': fila.observaciones,
    'created_at': fila.createdAt.toUtc().toIso8601String(),
    'deleted_at': fila.deletedAt?.toUtc().toIso8601String(),
  };

  static ActividadesAgricolasCompanion deRemoto(
    FilaRemota fila, {
    DateTime? borradoForzado,
  }) {
    final sello = selloDe(fila);
    return ActividadesAgricolasCompanion(
      id: Value(fila['id']! as String),
      loteId: Value(fila['lote_id']! as String),
      tipoActividad: Value(
        TipoActividad.values.byName(fila['tipo_actividad']! as String),
      ),
      fecha: Value(_fecha(fila['fecha'])!),
      observaciones: Value(fila['observaciones'] as String?),
      createdAt: Value(_fecha(fila['created_at'])!),
      updatedAt: Value(sello),
      deletedAt: Value(_fecha(fila['deleted_at']) ?? borradoForzado),
      serverUpdatedAt: Value(sello),
      syncStatus: const Value(SyncStatus.synced),
      syncError: const Value(null),
    );
  }

  static DateTime selloDe(FilaRemota fila) => _selloDe(fila);
}

/// Traduce entre la fila local de `cosechas` y la remota.
class MapeadorCosecha {
  const MapeadorCosecha._();

  static const entidad = 'cosechas';

  static FilaRemota aRemoto(Cosecha fila) => {
    'id': fila.id,
    'lote_id': fila.loteId,
    'fecha': fila.fecha.toUtc().toIso8601String(),
    'cantidad_kg': fila.cantidadKg,
    'observaciones': fila.observaciones,
    'created_at': fila.createdAt.toUtc().toIso8601String(),
    'deleted_at': fila.deletedAt?.toUtc().toIso8601String(),
  };

  static CosechasCompanion deRemoto(
    FilaRemota fila, {
    DateTime? borradoForzado,
  }) {
    final sello = selloDe(fila);
    return CosechasCompanion(
      id: Value(fila['id']! as String),
      loteId: Value(fila['lote_id']! as String),
      fecha: Value(_fecha(fila['fecha'])!),
      cantidadKg: Value((fila['cantidad_kg']! as num).toDouble()),
      observaciones: Value(fila['observaciones'] as String?),
      createdAt: Value(_fecha(fila['created_at'])!),
      updatedAt: Value(sello),
      deletedAt: Value(_fecha(fila['deleted_at']) ?? borradoForzado),
      serverUpdatedAt: Value(sello),
      syncStatus: const Value(SyncStatus.synced),
      syncError: const Value(null),
    );
  }

  static DateTime selloDe(FilaRemota fila) => _selloDe(fila);
}

/// Traduce entre la fila local de `diagnosticos` y la remota.
class MapeadorDiagnostico {
  const MapeadorDiagnostico._();

  static const entidad = 'diagnosticos';

  static FilaRemota aRemoto(Diagnostico fila) => {
    'id': fila.id,
    'lote_id': fila.loteId,
    'fecha': fila.fecha.toUtc().toIso8601String(),
    'foto_path': fila.fotoPath,
    'estado_fenologico': fila.estadoFenologico.name,
    'notas': fila.notas,
    'created_at': fila.createdAt.toUtc().toIso8601String(),
    'deleted_at': fila.deletedAt?.toUtc().toIso8601String(),
  };

  static DiagnosticosCompanion deRemoto(
    FilaRemota fila, {
    DateTime? borradoForzado,
  }) {
    final sello = selloDe(fila);
    return DiagnosticosCompanion(
      id: Value(fila['id']! as String),
      loteId: Value(fila['lote_id']! as String),
      fecha: Value(_fecha(fila['fecha'])!),
      // La foto es una ruta del dispositivo: viaja el dato, no el archivo. Subir
      // imágenes es harina de otro costal (Google Drive).
      fotoPath: Value(fila['foto_path'] as String?),
      estadoFenologico: Value(
        EstadoFenologico.values.byName(fila['estado_fenologico']! as String),
      ),
      notas: Value(fila['notas'] as String?),
      createdAt: Value(_fecha(fila['created_at'])!),
      updatedAt: Value(sello),
      deletedAt: Value(_fecha(fila['deleted_at']) ?? borradoForzado),
      serverUpdatedAt: Value(sello),
      syncStatus: const Value(SyncStatus.synced),
      syncError: const Value(null),
    );
  }

  static DateTime selloDe(FilaRemota fila) => _selloDe(fila);
}

/// Fecha de borrado que trae una fila remota, si la trae.
DateTime? borradoRemotoDe(FilaRemota fila) => _fecha(fila['deleted_at']);
