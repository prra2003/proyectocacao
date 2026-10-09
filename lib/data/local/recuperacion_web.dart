import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Borra la base del navegador y recarga la página.
///
/// En la web la base local es solo un espejo: lo que vale está en el servidor
/// y vuelve a bajar al entrar con Google. Por eso aquí sí se puede rehacer, y
/// en el celular no —allá la base local **es** el original—.
///
/// Hace falta porque una actualización de esquema que falle en el navegador
/// deja la app sin base y sin nada que dibujar: una página en blanco, sin
/// explicación y sin salida.
///
/// Se intenta **una sola vez por pestaña**: si después de rehacerla vuelve a
/// fallar, el problema es otro, y recargar en bucle solo lo escondería.
Future<bool> rehacerBaseLocal() async {
  const marca = 'cacao_db_rehecha';
  try {
    if (web.window.sessionStorage.getItem(marca) != null) return false;
    web.window.sessionStorage.setItem(marca, '1');

    final listo = Completer<void>();
    final peticion = web.window.indexedDB.deleteDatabase('cacao_db');
    void terminar(web.Event _) {
      if (!listo.isCompleted) listo.complete();
    }

    peticion.addEventListener('success', terminar.toJS);
    peticion.addEventListener('error', terminar.toJS);
    // `blocked` ocurre si otra pestaña tiene la base abierta: se recarga
    // igual, porque al cerrarse esta la otra la soltará.
    peticion.addEventListener('blocked', terminar.toJS);
    await listo.future.timeout(const Duration(seconds: 5), onTimeout: () {});

    web.window.location.reload();
    return true;
  } on Object catch (error) {
    debugPrint('No se pudo rehacer la base del navegador: $error');
    return false;
  }
}
