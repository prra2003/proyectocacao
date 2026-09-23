import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/enums.dart';
import 'api_remota.dart';

DateTime? _fecha(Object? valor) =>
    valor == null ? null : DateTime.parse(valor as String).toLocal();

DateTime _selloDe(FilaRemota fila) => _fecha(fila['updated_at'])!;

/// **Ausente no es lo mismo que vacío.**
///
/// Si el servidor todavía no tiene esa columna, la clave no viene en la fila y
/// hay que **dejar el valor local como está**: escribir `null` encima borraría
/// lo que la persona escribió en el teléfono. Si la columna sí viene y está
/// vacía, entonces sí es un valor nulo de verdad.
Value<String?> _textoSiViene(FilaRemota fila, String clave) =>
    fila.containsKey(clave)
        ? Value(fila[clave] as String?)
        : const Value.absent();

Value<double?> _realSiViene(FilaRemota fila, String clave) =>
    fila.containsKey(clave) ? Value(_numero(fila[clave])) : const Value.absent();

Value<int?> _enteroSiViene(FilaRemota fila, String clave) =>
    fila.containsKey(clave) ? Value(_entero(fila[clave])) : const Value.absent();

/// La hoja de cálculo guarda texto: un número puede llegar como `12` o como
/// `'12'`. Las dos formas tienen que entrar igual.
double? _numero(Object? valor) => switch (valor) {
  null => null,
  final num n => n.toDouble(),
  final String t => double.tryParse(t),
  _ => null,
};

int? _entero(Object? valor) => switch (valor) {
  null => null,
  final num n => n.toInt(),
  final String t => int.tryParse(t),
  _ => null,
};

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
    'responsable': fila.responsable,
    'costo': fila.costo,
    // La foto no viaja: solo su ruta en este teléfono. Subir la imagen es
    // harina de otro costal (ver docs/DOCUMENTACION_TECNICA.md, 11.1).
    'foto_path': fila.fotoPath,
    'subtipo_labor': fila.subtipoLabor,
    'producto': fila.producto,
    'cantidad_aplicada': fila.cantidadAplicada,
    'incidencia': fila.incidencia,
    'arboles_afectados': fila.arbolesAfectados,
    'edad_cultivo_anios': fila.edadCultivoAnios,
    'arboles_sembrados': fila.arbolesSembrados,
    'edad_plantula_meses': fila.edadPlantulaMeses,
    'insumos': fila.insumos,
    'resultado_esperado': fila.resultadoEsperado,
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
      responsable: _textoSiViene(fila, 'responsable'),
      costo: _realSiViene(fila, 'costo'),
      fotoPath: _textoSiViene(fila, 'foto_path'),
      subtipoLabor: _textoSiViene(fila, 'subtipo_labor'),
      producto: _textoSiViene(fila, 'producto'),
      cantidadAplicada: _textoSiViene(fila, 'cantidad_aplicada'),
      incidencia: _textoSiViene(fila, 'incidencia'),
      arbolesAfectados: _enteroSiViene(fila, 'arboles_afectados'),
      edadCultivoAnios: _enteroSiViene(fila, 'edad_cultivo_anios'),
      arbolesSembrados: _enteroSiViene(fila, 'arboles_sembrados'),
      edadPlantulaMeses: _enteroSiViene(fila, 'edad_plantula_meses'),
      insumos: _textoSiViene(fila, 'insumos'),
      resultadoEsperado: _textoSiViene(fila, 'resultado_esperado'),
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
    'tipo_producto': fila.tipoProducto,
    'foto_path': fila.fotoPath,
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
      cantidadKg: Value(_numero(fila['cantidad_kg'])!),
      observaciones: Value(fila['observaciones'] as String?),
      tipoProducto: _textoSiViene(fila, 'tipo_producto'),
      fotoPath: _textoSiViene(fila, 'foto_path'),
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
      fotoPath: _textoSiViene(fila, 'foto_path'),
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
