import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_remota.dart';

/// El backend de verdad: Supabase.
///
/// Es la única clase que sabe que el servidor existe. Implementa el mismo
/// contrato que [ApiRemota], así que entra en el sitio del doble en memoria sin
/// tocar UI, repositorios, DAOs ni la lógica de sincronización.
class ApiSupabase implements ApiRemota {
  ApiSupabase(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<String> asegurarSesion() async {
    try {
      // Si ya hay sesión —anónima o con correo— esa manda. Abrir una anónima
      // encima dejaría al productor mirando datos de otra cuenta.
      final sesion = _cliente.auth.currentSession;
      if (sesion != null && !sesion.isExpired) return sesion.user.id;

      final respuesta = await _cliente.auth.signInAnonymously();
      final usuario = respuesta.user;
      if (usuario == null) {
        throw const ErrorRemoto('el servidor no devolvió una sesión');
      }
      return usuario.id;
    } on AuthException catch (e) {
      // El caso típico: falta activar "Anonymous sign-ins" en el panel.
      throw ErrorRemoto('no se pudo abrir sesión: ${e.message}');
    } on Object catch (e) {
      throw ErrorRemoto('sin conexión con el servidor ($e)');
    }
  }

  @override
  Future<String> vincularCorreo({
    required String correo,
    required String clave,
  }) async {
    try {
      // `updateUser` sobre la sesión anónima **conserva el auth.uid()**, que es
      // lo que mantiene vivos los datos ya subidos. `signUp` crearía otro
      // usuario y los dejaría huérfanos: nunca usarlo aquí.
      await asegurarSesion();
      final respuesta = await _cliente.auth.updateUser(
        UserAttributes(email: correo, password: clave),
      );
      final usuario = respuesta.user;
      if (usuario == null) {
        throw const ErrorRemoto('el servidor no devolvió la cuenta');
      }
      return usuario.id;
    } on AuthException catch (e) {
      throw ErrorRemoto(_mensajeDeCuenta(e));
    } on ErrorRemoto {
      rethrow;
    } on Object catch (e) {
      throw ErrorRemoto('sin conexión con el servidor ($e)');
    }
  }

  @override
  Future<String> iniciarSesion({
    required String correo,
    required String clave,
  }) async {
    try {
      final respuesta = await _cliente.auth.signInWithPassword(
        email: correo,
        password: clave,
      );
      final usuario = respuesta.user;
      if (usuario == null) {
        throw const ErrorRemoto('correo o contraseña incorrectos');
      }
      return usuario.id;
    } on AuthException catch (e) {
      throw ErrorRemoto(_mensajeDeCuenta(e));
    } on Object catch (e) {
      throw ErrorRemoto('sin conexión con el servidor ($e)');
    }
  }

  @override
  Future<void> cerrarSesion() => _cliente.auth.signOut();

  @override
  Future<bool> correoConfirmado() async {
    try {
      // Se refresca la sesión para enterarse si la persona ya abrió el enlace
      // del correo desde otro dispositivo. Si no hay red, vale lo que se sepa.
      await _cliente.auth.refreshSession();
    } on Object catch (_) {
      // Sin conexión: se responde con el último estado conocido.
    }
    final usuario = _cliente.auth.currentUser;
    return usuario?.email != null && usuario?.emailConfirmedAt != null;
  }

  /// Traduce los errores de Supabase a algo que un productor entienda.
  String _mensajeDeCuenta(AuthException e) {
    final mensaje = e.message.toLowerCase();
    if (mensaje.contains('already') && mensaje.contains('registered') ||
        mensaje.contains('already been registered') ||
        mensaje.contains('already exists')) {
      return 'ese correo ya tiene una cuenta';
    }
    if (mensaje.contains('invalid login')) {
      return 'correo o contraseña incorrectos';
    }
    if (mensaje.contains('password')) {
      return 'la contraseña no cumple lo que pide el servidor';
    }
    return e.message;
  }

  @override
  Future<List<FilaRemota>> descargar({
    required String entidad,
    DateTime? desde,
    String? desdeId,
    int limite = 100,
  }) async {
    try {
      final tabla = _cliente.from(entidad).select();

      // Paginación por clave (updated_at, id), la misma que usa el cursor
      // local: sin `desdeId` se arranca en `>=` para no perder filas que
      // compartan sello; con él se pide lo estrictamente posterior.
      final filtrada = switch ((desde, desdeId)) {
        (null, _) => tabla,
        (final d?, null) => tabla.gte('updated_at', d.toUtc().toIso8601String()),
        (final d?, final id?) => tabla.or(
          'updated_at.gt.${d.toUtc().toIso8601String()},'
          'and(updated_at.eq.${d.toUtc().toIso8601String()},id.gt.$id)',
        ),
      };

      final filas = await filtrada
          .order('updated_at')
          .order('id')
          .limit(limite);
      return [for (final fila in filas) Map<String, Object?>.from(fila)];
    } on PostgrestException catch (e) {
      throw ErrorRemoto('no se pudo descargar $entidad: ${e.message}');
    } on Object catch (e) {
      throw ErrorRemoto('sin conexión al descargar $entidad ($e)');
    }
  }

  @override
  Future<List<FilaRemota>> subir({
    required String entidad,
    required List<FilaRemota> filas,
  }) async {
    if (filas.isEmpty) return const [];
    try {
      // `upsert` porque la fila puede existir o no: el id lo generó el
      // dispositivo. El servidor devuelve la versión sellada con su updated_at.
      final selladas = await _cliente.from(entidad).upsert(filas).select();
      return [for (final fila in selladas) Map<String, Object?>.from(fila)];
    } on PostgrestException catch (e) {
      throw ErrorRemoto('no se pudo subir $entidad: ${e.message}');
    } on Object catch (e) {
      throw ErrorRemoto('sin conexión al subir $entidad ($e)');
    }
  }
}
