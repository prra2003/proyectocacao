import 'package:google_sign_in/google_sign_in.dart';

import 'api_remota.dart';
import 'config_nube.dart';

/// Le pide la cuenta a Google y entrega el token que el servidor verifica.
///
/// Vive aparte de [ApiAppsScript] a propósito: así el cliente del servidor no
/// depende del paquete de Google y las pruebas pueden entrar sin abrir ninguna
/// pantalla.
///
/// Un detalle que cuesta encontrar cuando falla: en Android el token solo trae
/// identidad si se pasa [clienteWeb] como `serverClientId`. El identificador de
/// Android sirve para que Google compruebe la huella SHA-1 de la app, pero el
/// token que viaja al servidor va dirigido al cliente **web**. Por eso el
/// servidor acepta ese identificador y no el de Android.
class AutenticadorGoogle {
  bool _listo = false;

  Future<void> _preparar() async {
    if (_listo) return;
    await GoogleSignIn.instance.initialize(
      clientId: clienteWeb,
      serverClientId: clienteWeb,
    );
    _listo = true;
  }

  /// Abre la pantalla de Google y devuelve el token de identidad.
  Future<String> idToken() async {
    await _preparar();
    final GoogleSignInAccount cuenta;
    try {
      cuenta = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      // `canceled` es que la persona cerró la ventana: no es un fallo que haya
      // que reportar como error del servidor.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const ErrorRemoto('Se canceló el ingreso con Google');
      }
      throw ErrorRemoto('Google no dejó entrar: ${e.description ?? e.code}');
    }

    final token = cuenta.authentication.idToken;
    if (token == null) {
      // Pasa cuando el identificador web no está configurado o la huella SHA-1
      // no coincide con la que Google tiene registrada.
      throw const ErrorRemoto(
        'Google no entregó la identidad de la cuenta. Revise que la huella '
        'SHA-1 de la app esté registrada en Google Cloud.',
      );
    }
    return token;
  }

  /// Suelta la cuenta en este teléfono, para que la próxima vez pregunte cuál
  /// usar. Si falla, no importa: lo que manda es la sesión del servidor.
  Future<void> salir() async {
    try {
      await GoogleSignIn.instance.signOut();
    } on Exception {
      return;
    }
  }
}
