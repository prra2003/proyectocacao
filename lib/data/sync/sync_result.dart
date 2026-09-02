/// Por qué una fila remota no se aplicó tal cual.
class Conflicto {
  const Conflicto({
    required this.entidad,
    required this.id,
    required this.motivo,
  });

  final String entidad;
  final String id;
  final String motivo;

  @override
  String toString() => '$entidad/$id: $motivo';
}

/// El registro local tenía cambios sin subir: gana lo local y se sube en el
/// siguiente push.
const motivoLocalPendiente = 'cambio local pendiente, gana la versión local';

/// Llegó un hijo cuyo padre todavía no existe aquí. No se aplica y el cursor no
/// avanza más allá: la siguiente pasada lo reintenta, ya con el padre bajado.
const motivoPadreAusente = 'el padre aún no está en la base local, se aplaza';

/// Llegó un hijo vivo cuyo padre ya está borrado aquí. Se guarda, pero muerto:
/// ni se revive el padre ni queda un hijo vivo colgando de un padre borrado.
const motivoPadreBorrado =
    'el padre ya está borrado: el hijo se aplica como borrado';

/// El servidor borró un padre y este hijo tenía cambios locales sin subir. El
/// borrado del padre manda; el cambio local se pierde y queda anotado aquí.
const motivoPadreBorradoRemoto =
    'padre borrado en el servidor: se descarta el cambio local pendiente';

class ResultadoEntidad {
  ResultadoEntidad(this.entidad);

  final String entidad;
  var subidos = 0;
  var bajados = 0;
  final conflictos = <Conflicto>[];
}

/// Qué pasó en una pasada de sincronización.
class SyncResult {
  SyncResult({required this.entidades, this.error});

  factory SyncResult.fallo(String error, {List<ResultadoEntidad>? entidades}) =>
      SyncResult(entidades: entidades ?? const [], error: error);

  final List<ResultadoEntidad> entidades;
  final String? error;

  bool get ok => error == null;

  int get subidos =>
      entidades.fold(0, (suma, entidad) => suma + entidad.subidos);

  int get bajados =>
      entidades.fold(0, (suma, entidad) => suma + entidad.bajados);

  List<Conflicto> get conflictos => [
    for (final entidad in entidades) ...entidad.conflictos,
  ];

  @override
  String toString() => ok
      ? 'SyncResult(subidos: $subidos, bajados: $bajados, '
            'conflictos: ${conflictos.length})'
      : 'SyncResult(error: $error)';
}
