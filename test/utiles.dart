import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/api_remota.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deja correr el asincronismo real de Drift (que el reloj falso del test no
/// mueve) y luego repinta. `pumpAndSettle` no sirve: los indicadores de carga
/// son animaciones infinitas y dejarían el test colgado.
Future<void> asentar(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }
}

/// Ejecuta trabajo real contra la base dentro de un test de widgets.
Future<T> conAsync<T>(WidgetTester tester, Future<T> Function() accion) async {
  late T resultado;
  await tester.runAsync(() async => resultado = await accion());
  return resultado;
}

/// La ventana por defecto del test mide 800x600 y los botones del final del
/// formulario quedarían fuera de pantalla, sin poder recibir el toque.
void pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Desmonta el árbol y deja correr los timers de cierre de Drift y del
/// SnackBar: si no, el framework falla con "A Timer is still pending".
Future<void> desmontar(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 5));
}


/// Envuelve la API falsa anulando la subida, para provocar el choque de
/// "el servidor cambió y yo tengo algo pendiente".
class ApiSinSubida implements ApiRemota {
  ApiSinSubida(this.real);

  final ApiRemotaFalsa real;

  @override
  Future<String> asegurarSesion() => real.asegurarSesion();

  @override
  Future<String> vincularCorreo({
    required String correo,
    required String clave,
  }) => real.vincularCorreo(correo: correo, clave: clave);

  @override
  Future<String> iniciarSesion({
    required String correo,
    required String clave,
  }) => real.iniciarSesion(correo: correo, clave: clave);

  @override
  Future<void> cerrarSesion() => real.cerrarSesion();

  @override
  Future<bool> correoConfirmado() => real.correoConfirmado();

  @override
  Future<List<FilaRemota>> descargar({
    required String entidad,
    DateTime? desde,
    String? desdeId,
    int limite = 100,
  }) => real.descargar(
    entidad: entidad,
    desde: desde,
    desdeId: desdeId,
    limite: limite,
  );

  @override
  Future<List<FilaRemota>> subir({
    required String entidad,
    required List<FilaRemota> filas,
  }) async => const [];
}
