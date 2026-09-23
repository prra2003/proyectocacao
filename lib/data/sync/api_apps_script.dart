import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import 'api_remota.dart';

/// Cliente del servidor en Google Apps Script (ver `backend/Codigo.gs`).
///
/// Habla el mismo idioma que hablaba `ApiSupabase`: filas planas en snake_case,
/// descarga por páginas con cursor `(updated_at, id)` y borrado suave. Lo que
/// cambia es quién da la identidad: antes era el propio servidor con correo y
/// contraseña, ahora es Google.
///
/// Dos cosas de Apps Script que hay que respetar o nada funciona:
///
///  1. **El cuerpo va como `text/plain`, no como `application/json`.** Con
///     `application/json` el navegador manda primero una petición de permiso
///     que Apps Script no contesta, y la versión web se queda sin sincronizar
///     sin dar ningún error claro.
///
///  2. **Un `POST` nunca responde de una vez:** contesta con una redirección a
///     `script.googleusercontent.com`, y esa segunda dirección solo acepta
///     `GET`. Si el cliente reenvía el `POST` a donde lo mandan, recibe un 405
///     y parece que el servidor estuviera roto. Por eso aquí la redirección se
///     sigue a mano. En la web no hace falta: el navegador ya la resuelve.
class ApiAppsScript implements ApiRemota {
  ApiAppsScript({
    required this.url,
    required Future<String> Function() pedirIdTokenAGoogle,
    Future<void> Function()? salirDeGoogle,
    http.Client? cliente,
    String? token,
    String? usuarioId,
  }) : _cliente = cliente ?? http.Client(),
       _idTokenDeGoogle = pedirIdTokenAGoogle {
    _salirDeGoogle = salirDeGoogle;
    _usuarioId = usuarioId;
    _token = token;
  }

  final Uri url;
  final http.Client _cliente;

  /// Quién le pide la cuenta a Google. Se inyecta para que las pruebas puedan
  /// correr sin abrir ninguna pantalla.
  final Future<String> Function() _idTokenDeGoogle;
  late final Future<void> Function()? _salirDeGoogle;

  /// Identidad de la sesión abierta. Se restaura al arrancar junto con el
  /// token: sin ella, la app creería que nadie ha entrado.
  String? _usuarioId;

  /// Sesión propia del servidor, no el token de Google.
  ///
  /// El de Google dura una hora; este dura meses. Sin el cambio, la
  /// sincronización empezaría a fallar sola al rato y sin motivo visible.
  String? _token;

  String? get token => _token;
  bool get haySesion => _token != null;

  /// ¿El servidor está vivo? Sirve para diagnosticar sin tocar datos.
  Future<bool> disponible() async {
    try {
      final respuesta = await _pedir({'accion': 'ping'});
      return respuesta['ok'] == true;
    } on ErrorRemoto {
      return false;
    }
  }

  /// Cambia el token de Google por una sesión del servidor.
  ///
  /// Devuelve el identificador permanente de la cuenta (`sub` de Google), que
  /// es el que marca de quién es cada fila. Ocupa el lugar que tenía el
  /// `auth.uid()` de Supabase.
  @override
  Future<SesionRemota> entrarConGoogle() async {
    final idToken = await _idTokenDeGoogle();
    final respuesta = await _pedir({'accion': 'entrar', 'idToken': idToken});
    _token = respuesta['token'] as String;
    _usuarioId = respuesta['usuarioId'] as String;
    return SesionRemota(
      usuarioId: _usuarioId!,
      correo: (respuesta['correo'] as String?) ?? '',
      token: _token,
      nombre: nombreDelToken(idToken),
    );
  }

  /// El nombre viene dentro del token de Google (un JWT). Se lee aquí, sin
  /// preguntarle al servidor: solo se usa para llenar el formulario, no para
  /// dar acceso, así que no hace falta verificar la firma.
  static String? nombreDelToken(String idToken) {
    try {
      final partes = idToken.split('.');
      if (partes.length != 3) return null;
      final datos = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(partes[1]))),
      );
      final nombre = (datos as Map<String, dynamic>)['name'];
      return nombre is String && nombre.trim().isNotEmpty ? nombre : null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<String?> usuarioActual() async => _token == null ? null : _usuarioId;

  /// Cierra la sesión en el servidor y olvida el token.
  ///
  /// Si el servidor no contesta, se olvida igual: en el teléfono la sesión
  /// tiene que quedar cerrada aunque no haya señal.
  @override
  Future<void> cerrarSesion() async {
    final token = _token;
    _token = null;
    _usuarioId = null;
    await _salirDeGoogle?.call();
    if (token == null) return;
    try {
      await _pedir({'accion': 'salir', 'token': token});
    } on ErrorRemoto {
      return;
    }
  }

  @override
  Future<List<FilaRemota>> descargar({
    required String entidad,
    DateTime? desde,
    String? desdeId,
    int limite = 100,
  }) async {
    final respuesta = await _pedir({
      'accion': 'descargar',
      'token': _token,
      'entidad': entidad,
      if (desde != null) 'desde': desde.toUtc().toIso8601String(),
      'desdeId': ?desdeId,
      'limite': limite,
    });
    return _filasDe(respuesta);
  }

  @override
  Future<List<FilaRemota>> subir({
    required String entidad,
    required List<FilaRemota> filas,
  }) async {
    if (filas.isEmpty) return const [];
    final respuesta = await _pedir({
      'accion': 'subir',
      'token': _token,
      'entidad': entidad,
      'filas': filas.map(_paraEnviar).toList(),
    });
    return _filasDe(respuesta);
  }

  // ------------------------------------------------------------ interno ----

  List<FilaRemota> _filasDe(Map<String, Object?> respuesta) {
    final crudas = (respuesta['filas'] as List?) ?? const [];
    return crudas
        .map((fila) => normalizar(Map<String, Object?>.from(fila as Map)))
        .toList(growable: false);
  }

  /// Columnas que el resto de la app espera como número.
  ///
  /// Se enumeran a mano a propósito: convertir "todo lo que parezca número"
  /// volvería enteros el teléfono y el documento, que son texto aunque solo
  /// tengan dígitos, y perdería el cero de la izquierda.
  static const columnasNumericas = <String>{
    'area_sembrada_ha',
    'latitud',
    'longitud',
    'cantidad_kg',
  };

  /// Devuelve la fila a los tipos que espera la app.
  ///
  /// La hoja de cálculo solo guarda texto, así que todo llega como cadena y
  /// **una celda vacía llega como `''`, no como nulo**. Sin esta traducción,
  /// un `deleted_at` vacío rompe `DateTime.parse` y la sincronización se cae
  /// entera en la primera fila.
  static FilaRemota normalizar(FilaRemota fila) {
    final salida = <String, Object?>{};
    fila.forEach((columna, valor) {
      if (valor is String) {
        if (valor.isEmpty) {
          salida[columna] = null;
          return;
        }
        if (columnasNumericas.contains(columna)) {
          salida[columna] = num.tryParse(valor) ?? valor;
          return;
        }
      }
      salida[columna] = valor;
    });
    return salida;
  }

  /// La hoja de cálculo guarda texto. Las fechas viajan en ISO-8601 UTC y los
  /// números como texto; convertirlos de vuelta es trabajo de los mapeadores,
  /// que ya saben de qué tipo es cada columna.
  Map<String, Object?> _paraEnviar(FilaRemota fila) {
    return fila.map((columna, valor) {
      if (valor is DateTime) {
        return MapEntry(columna, valor.toUtc().toIso8601String());
      }
      return MapEntry(columna, valor?.toString() ?? '');
    });
  }

  Future<Map<String, Object?>> _pedir(Map<String, Object?> cuerpo) async {
    final http.Response respuesta;
    try {
      respuesta = await _enviar(cuerpo);
    } on Exception catch (error) {
      throw ErrorRemoto('No se pudo hablar con el servidor: $error');
    }

    if (respuesta.statusCode != 200) {
      throw ErrorRemoto('El servidor respondió ${respuesta.statusCode}');
    }

    final Object? datos;
    try {
      datos = jsonDecode(respuesta.body);
    } on FormatException {
      // Pasa cuando la implementación quedó sin publicar o el acceso no es
      // "Cualquier usuario": Google devuelve una página de error, no JSON.
      throw const ErrorRemoto(
        'El servidor no respondió datos. Revise que la implementación esté '
        'publicada y con acceso para cualquier usuario.',
      );
    }

    if (datos is! Map) throw const ErrorRemoto('Respuesta inesperada');
    final mapa = Map<String, Object?>.from(datos);
    if (mapa['ok'] == true) return mapa;

    final mensaje = (mapa['error'] as String?) ?? 'Error desconocido';
    throw mapa['reentrar'] == true
        ? SesionVencida(mensaje)
        : ErrorRemoto(mensaje);
  }

  Future<http.Response> _enviar(Map<String, Object?> cuerpo) async {
    final peticion = http.Request('POST', url)
      ..headers['Content-Type'] = 'text/plain;charset=utf-8'
      ..body = jsonEncode(cuerpo);
    // En Android hay que seguir la redirección a mano: si se reenvía el POST a
    // donde Apps Script manda, contesta 405. En la web no se puede decidir
    // esto —el navegador sigue las redirecciones por su cuenta— y pedirlo
    // rompe la petición entera con un "Failed to fetch".
    if (!kIsWeb) peticion.followRedirects = false;

    final primera = await http.Response.fromStream(
      await _cliente.send(peticion),
    );
    final aDonde = primera.headers['location'];
    if (primera.statusCode >= 300 &&
        primera.statusCode < 400 &&
        aDonde != null) {
      return _cliente.get(Uri.parse(aDonde));
    }
    return primera;
  }
}
