import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

/// En la web, el botón lo dibuja Google.
///
/// No es un capricho de estilo: `authenticate()` lanza error en el navegador y
/// la única forma de abrir el ingreso es el botón que Google renderiza. La
/// cuenta no vuelve por el toque, sino por el flujo de eventos del paquete, y
/// por eso este widget escucha y avisa cuando ya hay sesión.
Widget construirBotonGoogle({
  required VoidCallback alEntrar,
  required Widget Function(VoidCallback alTocar) constructorPropio,
}) {
  return _BotonGoogleWeb(alEntrar: alEntrar);
}

class _BotonGoogleWeb extends StatefulWidget {
  const _BotonGoogleWeb({required this.alEntrar});

  final VoidCallback alEntrar;

  @override
  State<_BotonGoogleWeb> createState() => _BotonGoogleWebState();
}

class _BotonGoogleWebState extends State<_BotonGoogleWeb> {
  StreamSubscription<GoogleSignInAuthenticationEvent>? _escucha;

  @override
  void initState() {
    super.initState();
    _escucha = GoogleSignIn.instance.authenticationEvents.listen((evento) {
      if (evento is GoogleSignInAuthenticationEventSignIn) widget.alEntrar();
    });
  }

  @override
  void dispose() {
    _escucha?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plataforma = GoogleSignInPlatform.instance;
    if (plataforma is! GoogleSignInPlugin) {
      return const Text('El ingreso con Google no está disponible aquí.');
    }
    return Align(
      alignment: Alignment.center,
      child: plataforma.renderButton(
        configuration: GSIButtonConfiguration(
          text: GSIButtonText.continueWith,
          size: GSIButtonSize.large,
          shape: GSIButtonShape.pill,
          locale: 'es',
        ),
      ),
    );
  }
}
