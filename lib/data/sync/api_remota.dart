/// Una fila tal como viaja por la red: JSON plano en snake_case.
typedef FilaRemota = Map<String, Object?>;

/// Quién entró: identidad permanente de la cuenta y su correo.
///
/// Con Google, [usuarioId] es el `sub`: un número que identifica a esa persona
/// para siempre, aunque cambie de correo. Es lo que marca de quién es cada
/// fila, el lugar que antes ocupaba el `auth.uid()` de Supabase.
class SesionRemota {
  const SesionRemota({
    required this.usuarioId,
    required this.correo,
    this.token,
  });

  final String usuarioId;
  final String correo;

  /// Sesión del servidor, si la implementación usa una. Se guarda en el
  /// teléfono para no tener que pedir la cuenta de Google en cada arranque.
  final String? token;
}

/// Contrato con el backend.
///
/// La lógica de sincronización habla solo con esta interfaz, así que cambiar
/// de servidor no toca ni la UI, ni los repositorios, ni los DAOs, ni el
/// [SyncService].
///
/// **Sin cuenta no hay servidor.** Antes existía una sesión anónima que
/// respaldaba aunque nadie hubiera entrado. Con la cuenta de Google eso ya no
/// es posible: quien no entra trabaja solo contra el teléfono. La app funciona
/// igual —el campo no espera a la nube—, pero no hay respaldo, y la interfaz
/// tiene que decirlo con todas las letras.
abstract interface class ApiRemota {
  /// Identidad de la sesión abierta, o `null` si nadie ha entrado.
  ///
  /// No abre ninguna pantalla ni pide nada: es una pregunta, no una acción.
  Future<String?> usuarioActual();

  /// Pide la cuenta de Google y abre sesión en el servidor.
  ///
  /// Es lo único que muestra una pantalla de Google, así que solo se llama
  /// cuando la persona tocó el botón de entrar.
  Future<SesionRemota> entrarConGoogle();

  /// Cierra la sesión. Si el servidor no contesta, se olvida igual: en el
  /// teléfono la sesión tiene que quedar cerrada aunque no haya señal.
  Future<void> cerrarSesion();

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

/// La sesión del servidor venció: hay que volver a entrar con Google.
///
/// Se distingue de los demás fallos porque no se arregla reintentando: la app
/// tiene que pedirle la cuenta a la persona otra vez.
class SesionVencida extends ErrorRemoto {
  const SesionVencida([super.mensaje = 'La sesión venció, vuelva a entrar']);
}
