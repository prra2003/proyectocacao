/// Datos del proyecto de Supabase.
///
/// La llave publicable (antes llamada `anon key`) es **pública por diseño**:
/// viaja dentro de la app y lo que protege los datos es el RLS del servidor, no
/// el secreto de esta llave. La que nunca puede estar aquí es la `service_role`
/// —o `secret key`—, que se salta el RLS.
///
/// Se pueden pasar por línea de comandos para no tocar el código:
///
///     flutter run --dart-define=SUPABASE_KEY=...
class ConfigSupabase {
  const ConfigSupabase._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://uhtimwqxxfidwbjsjkdp.supabase.co',
  );

  static const llavePublica = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'sb_publishable_WuJQwdJxWLkpznZs1WPT1A_kMAz3kb2',
  );

  /// Sin llave, la app corre contra el doble en memoria: se puede seguir
  /// usando y probando todo sin backend.
  static bool get hayBackend => url.isNotEmpty && llavePublica.isNotEmpty;
}
