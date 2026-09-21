import 'package:flutter/material.dart';

/// En Android (y en las pruebas) manda el botón de la app: la ventana de
/// Google se abre desde el código cuando la persona lo toca.
Widget construirBotonGoogle({
  required VoidCallback alEntrar,
  required Widget Function(VoidCallback alTocar) constructorPropio,
}) {
  return constructorPropio(alEntrar);
}
