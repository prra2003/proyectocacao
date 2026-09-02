/// Una fila tal como viaja por la red: JSON plano en snake_case.
typedef FilaRemota = Map<String, Object?>;

/// Contrato con el backend.
///
/// La lógica de sincronización habla solo con esta interfaz, así que cambiar la
/// implementación falsa por Supabase no toca ni la UI, ni los repositorios, ni
/// los DAOs, ni el [SyncService].
abstract interface class ApiRemota {
  /// Devuelve el `auth.uid()` de la sesión actual, abriendo una **anónima**
  /// solo si no hay ninguna.
  ///
  /// El orden importa: si el productor ya entró con su correo, esa sesión es la
  /// que manda. Abrir una anónima encima lo dejaría mirando datos de otra
  /// cuenta.
  Future<String> asegurarSesion();

  /// Convierte la sesión anónima actual en una cuenta con correo y contraseña,
  /// **conservando el mismo `auth.uid()`**.
  ///
  /// Esto es lo que salva los datos ya subidos: como el uid no cambia, las
  /// filas remotas siguen perteneciendo a la misma cuenta y las políticas de
  /// seguridad del servidor siguen encajando sin tocar una sola fila. Registrar
  /// una cuenta nueva (`signUp`) crearía otro uid y dejaría los datos huérfanos.
  Future<String> vincularCorreo({
    required String correo,
    required String clave,
  });

  /// Entra con una cuenta ya existente. Devuelve su `auth.uid()`.
  Future<String> iniciarSesion({
    required String correo,
    required String clave,
  });

  Future<void> cerrarSesion();

  /// ¿La cuenta tiene un correo ya confirmado?
  ///
  /// Con la confirmación activada en el servidor, vincular el correo lo deja
  /// **pendiente** hasta que la persona abre el enlace: hasta ese momento no
  /// puede entrar desde otro teléfono.
  Future<bool> correoConfirmado();

  /// Filas de [entidad] ordenadas por `(updated_at, id)` ascendente.
  ///
  /// Sin [desdeId] devuelve `updated_at >= desde`, que es como empieza cada
  /// pasada: repetir la última fila ya aplicada no cuesta nada y en cambio
  /// evita perder filas que compartan sello.
  ///
  /// Con [desdeId] devuelve lo estrictamente posterior a esa clave
  /// (`updated_at > desde OR (updated_at = desde AND id > desdeId)`), que es lo
  /// que hace avanzar las páginas aunque varias filas tengan el mismo sello.
  Future<List<FilaRemota>> descargar({
    required String entidad,
    DateTime? desde,
    String? desdeId,
    int limite = 100,
  });

  /// Inserta o actualiza [filas] y devuelve la versión sellada por el
  /// servidor, con su propio `updated_at`.
  Future<List<FilaRemota>> subir({
    required String entidad,
    required List<FilaRemota> filas,
  });
}

/// Fallo hablando con el backend: sin red, permiso denegado, datos inválidos.
class ErrorRemoto implements Exception {
  const ErrorRemoto(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'ErrorRemoto: $mensaje';
}
