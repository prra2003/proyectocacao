import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_remota.dart';
import 'config_nube.dart';

/// Le pide la cuenta a Google y entrega el token que el servidor verifica.
///
/// Vive aparte de [ApiAppsScript] a propósito: así el cliente del servidor no
/// depende del paquete de Google y las pruebas pueden entrar sin abrir ninguna
/// pantalla.
///
/// **Android y la web no funcionan igual, y el paquete lo prohíbe expresamente:**
///
///  - En Android la app abre la ventana de Google cuando quiere
///    (`authenticate`), y el token debe ir dirigido al cliente **web**: por eso
///    se pasa [clienteWeb] como `serverClientId`. El identificador de Android
///    solo le sirve a Google para comprobar la huella SHA-1 de la app.
///
///  - En la web `authenticate` **lanza error**, y `serverClientId` también.
///    Google obliga a mostrar *su* botón (ver `ui/widgets/boton_google.dart`) y
///    la cuenta llega después por [GoogleSignIn.authenticationEvents]. Es una
///    defensa contra páginas que imiten la ventana de Google.
class AutenticadorGoogle {
  StreamSubscription<GoogleSignInAuthenticationEvent>? _escucha;
  String? _tokenReciente;
  Completer<String>? _esperando;
  bool _listo = false;

  /// Deja el paquete listo y empieza a escuchar los ingresos.
  ///
  /// En la web hay que llamarlo **antes** de dibujar el botón de Google; por
  /// eso `main.dart` lo espera al arrancar.
  Future<void> preparar() async {
    if (_listo) return;
    await GoogleSignIn.instance.initialize(
      clientId: clienteWeb,
      serverClientId: kIsWeb ? null : clienteWeb,
    );
    _escucha ??= GoogleSignIn.instance.authenticationEvents.listen(_alEntrar);
    _listo = true;
  }

  void _alEntrar(GoogleSignInAuthenticationEvent evento) {
    if (evento is! GoogleSignInAuthenticationEventSignIn) return;
    final token = evento.user.authentication.idToken;
    if (token == null) return;
    _tokenReciente = token;
    final esperando = _esperando;
    if (esperando != null && !esperando.isCompleted) {
      esperando.complete(token);
      _esperando = null;
    }
  }

  /// Devuelve el token de identidad de la cuenta.
  Future<String> idToken() async {
    await preparar();
    return kIsWeb ? _tokenDeLaWeb() : _tokenDeAndroid();
  }

  /// En la web el ingreso ya ocurrió: lo disparó el botón de Google y la cuenta
  /// llegó por el flujo de eventos. Aquí solo se recoge.
  Future<String> _tokenDeLaWeb() async {
    final reciente = _tokenReciente;
    if (reciente != null) {
      _tokenReciente = null;
      return reciente;
    }
    // Si el evento todavía no llega, se espera un momento en vez de fallar: el
    // orden entre el botón y este código no está garantizado.
    final espera = _esperando ??= Completer<String>();
    try {
      return await espera.future.timeout(const Duration(seconds: 20));
    } on TimeoutException {
      _esperando = null;
      throw const ErrorRemoto(
        'Google no devolvió la cuenta. Intente otra vez.',
      );
    }
  }

  Future<String> _tokenDeAndroid() async {
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

  /// Suelta la cuenta en este equipo, para que la próxima vez pregunte cuál
  /// usar. Si falla, no importa: lo que manda es la sesión del servidor.
  Future<void> salir() async {
    _tokenReciente = null;
    try {
      await GoogleSignIn.instance.signOut();
    } on Exception {
      return;
    }
  }
}
