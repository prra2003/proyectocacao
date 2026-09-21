import 'package:flutter/material.dart';

import 'boton_google_movil.dart'
    if (dart.library.js_interop) 'boton_google_web.dart';

/// Botón para entrar con Google, distinto en cada plataforma.
///
/// En Android se usa el botón de la app, con las palabras del proyecto. En la
/// web Google **obliga** a mostrar el suyo, dibujado por ellos: es la única
/// forma de que la ventana de ingreso se abra, y una defensa contra páginas
/// que imiten esa ventana.
///
/// [constructorPropio] es el botón que se ve en Android; en la web se ignora.
/// [alEntrar] se llama cuando la persona ya escogió su cuenta.
class BotonGoogle extends StatelessWidget {
  const BotonGoogle({
    super.key,
    required this.alEntrar,
    required this.constructorPropio,
  });

  final VoidCallback alEntrar;
  final Widget Function(VoidCallback alTocar) constructorPropio;

  @override
  Widget build(BuildContext context) {
    return construirBotonGoogle(
      alEntrar: alEntrar,
      constructorPropio: constructorPropio,
    );
  }
}
