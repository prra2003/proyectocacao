import 'api_remota.dart';

/// Cuenta del servidor de prueba.
class CuentaFalsa {
  CuentaFalsa(this.uid);

  final String uid;
  String? correo;
  String? clave;

  /// Imita la confirmación por correo del servidor real.
  bool confirmado = false;
}

/// El servidor en memoria: cuentas y filas, compartido por varios clientes.
///
/// Separar servidor de cliente es lo que permite probar dos instalaciones
/// distintas —dos teléfonos— hablando con el mismo backend, cada una con su
/// propia sesión.
class ServidorFalso {
  ServidorFalso({DateTime? desde}) : _base = desde ?? DateTime.utc(2026, 1, 1);

  final DateTime _base;
  final Map<String, CuentaFalsa> _cuentas = {};
  final Map<String, Map<String, FilaRemota>> _tablas = {};

  /// Dueño de cada fila: `"entidad/id" -> uid`. Es el equivalente al RLS.
  final Map<String, String> _duenos = {};

  var _tick = 0;

  DateTime sello() => _base.add(Duration(seconds: ++_tick));

  Map<String, FilaRemota> tabla(String entidad) =>
      _tablas.putIfAbsent(entidad, () => {});

  CuentaFalsa crearAnonima() {
    final cuenta = CuentaFalsa('auth-${sello().microsecondsSinceEpoch}');
    _cuentas[cuenta.uid] = cuenta;
    return cuenta;
  }

  /// Solo entra quien tenga el correo **confirmado**, como el servidor real
  /// cuando la confirmación está activada.
  CuentaFalsa? porCorreo(String correo, String clave) {
    for (final cuenta in _cuentas.values) {
      if (cuenta.correo == correo &&
          cuenta.clave == clave &&
          cuenta.confirmado) {
        return cuenta;
      }
    }
    return null;
  }

  /// Lo que haría la persona al abrir el enlace del correo.
  void confirmarCorreo(String correo) {
    for (final cuenta in _cuentas.values) {
      if (cuenta.correo == correo) cuenta.confirmado = true;
    }
  }

  bool correoOcupado(String correo, String salvoUid) {
    return _cuentas.values.any(
      (c) => c.correo == correo && c.uid != salvoUid,
    );
  }

  CuentaFalsa cuenta(String uid) => _cuentas[uid]!;

  /// Guarda una fila y la deja a nombre de [uid].
  FilaRemota guardar(String entidad, FilaRemota fila, String? uid) {
    final sellada = {...fila, 'updated_at': sello().toIso8601String()};
    final id = fila['id']! as String;
    tabla(entidad)[id] = sellada;
    if (uid != null) _duenos['$entidad/$id'] = uid;
    return sellada;
  }

  /// Filas visibles para [uid].
  ///
  /// Una fila sin dueño la ve cualquiera: son las que siembran los tests que no
  /// ejercitan cuentas.
  List<FilaRemota> visibles(String entidad, String? uid) {
    return [
      for (final fila in tabla(entidad).values)
        if (_duenos['$entidad/${fila['id']}'] == null ||
            _duenos['$entidad/${fila['id']}'] == uid)
          fila,
    ];
  }

  String? duenoDe(String entidad, String id) => _duenos['$entidad/$id'];
}

/// Cliente del servidor de prueba: imita a Supabase sin red.
///
/// Sella `updated_at` con el reloj del servidor, igual que hará el trigger de
/// PostgreSQL: el reloj del dispositivo nunca entra en la comparación.
class ApiRemotaFalsa implements ApiRemota {
  ApiRemotaFalsa({DateTime? desde}) : servidor = ServidorFalso(desde: desde);

  /// Otro "teléfono" contra el mismo servidor.
  ApiRemotaFalsa.deServidor(this.servidor);

  final ServidorFalso servidor;

  CuentaFalsa? _sesion;

  /// ¿El servidor exige confirmar el correo? Refleja el ajuste
  /// "Confirm email" de Supabase, que en este proyecto está **activado**.
  bool exigeConfirmacion = true;

  /// Fallos que provocará en las próximas llamadas, para probar la
  /// recuperación ante errores.
  int fallosProgramados = 0;

  /// Fallos que provocará solo al descargar, para probar que el cursor no
  /// avanza cuando la descarga se corta a la mitad.
  int fallosEnDescarga = 0;

  /// Llamadas atendidas, para comprobar que no se descarga de más.
  var descargas = 0;

  /// `auth.uid()` de la sesión abierta en este cliente.
  String? get uid => _sesion?.uid;

  String? get correo => _sesion?.correo;

  void _quizasFallar() {
    if (fallosProgramados > 0) {
      fallosProgramados--;
      throw const ErrorRemoto('sin conexión');
    }
  }

  /// Simula el cambio hecho por **otro** dispositivo: entra ya sellado.
  ///
  /// [sello] permite forzar el mismo `updated_at` en varias filas, que es el
  /// caso que rompe una paginación basada solo en el tiempo. [uid] deja la fila
  /// a nombre de una cuenta concreta; sin él, la fila queda sin dueño y la ve
  /// cualquiera.
  FilaRemota sembrar(
    String entidad,
    FilaRemota fila, {
    DateTime? sello,
    String? uid,
  }) {
    final sellada = {
      ...fila,
      'updated_at': (sello ?? servidor.sello()).toIso8601String(),
    };
    servidor.tabla(entidad)[fila['id']! as String] = sellada;
    if (uid != null) {
      servidor.guardar(entidad, sellada, uid);
      servidor.tabla(entidad)[fila['id']! as String] = sellada;
    }
    return sellada;
  }

  /// Contenido actual del servidor, para las comprobaciones de los tests.
  List<FilaRemota> filasDe(String entidad) =>
      servidor.tabla(entidad).values.toList();

  String? duenoDe(String entidad, String id) => servidor.duenoDe(entidad, id);

  @override
  Future<String> asegurarSesion() async {
    _quizasFallar();
    return (_sesion ??= servidor.crearAnonima()).uid;
  }

  @override
  Future<String> vincularCorreo({
    required String correo,
    required String clave,
  }) async {
    _quizasFallar();
    final sesion = _sesion ?? servidor.crearAnonima();
    _sesion = sesion;
    if (servidor.correoOcupado(correo, sesion.uid)) {
      throw const ErrorRemoto('ese correo ya tiene una cuenta');
    }
    sesion.correo = correo;
    sesion.clave = clave;
    sesion.confirmado = !exigeConfirmacion;
    // El uid no cambia: es toda la gracia de vincular en vez de registrar.
    return sesion.uid;
  }

  @override
  Future<String> iniciarSesion({
    required String correo,
    required String clave,
  }) async {
    _quizasFallar();
    final cuenta = servidor.porCorreo(correo, clave);
    if (cuenta == null) {
      throw const ErrorRemoto('correo o contraseña incorrectos');
    }
    _sesion = cuenta;
    return cuenta.uid;
  }

  @override
  Future<void> cerrarSesion() async => _sesion = null;

  @override
  Future<bool> correoConfirmado() async =>
      _sesion?.correo != null && (_sesion?.confirmado ?? false);

  /// Atajo de tests: abre el enlace del correo por la persona.
  void confirmarCorreo(String correo) => servidor.confirmarCorreo(correo);

  @override
  Future<List<FilaRemota>> descargar({
    required String entidad,
    DateTime? desde,
    String? desdeId,
    int limite = 100,
  }) async {
    _quizasFallar();
    if (fallosEnDescarga > 0) {
      fallosEnDescarga--;
      throw const ErrorRemoto('descarga interrumpida');
    }
    descargas++;
    final filas =
        servidor.visibles(entidad, uid).where((fila) {
          if (desde == null) return true;
          final sello = DateTime.parse(fila['updated_at']! as String);
          if (desdeId == null) return !sello.isBefore(desde);
          if (sello.isAfter(desde)) return true;
          // isAtSameMomentAs, no ==: en Dart dos DateTime del mismo instante no
          // son iguales si uno es UTC y el otro local, y los sellos llegan en
          // UTC desde el servidor.
          return sello.isAtSameMomentAs(desde) &&
              (fila['id']! as String).compareTo(desdeId) > 0;
        }).toList()
        ..sort((a, b) {
          final porSello = (a['updated_at']! as String).compareTo(
            b['updated_at']! as String,
          );
          return porSello != 0
              ? porSello
              : (a['id']! as String).compareTo(b['id']! as String);
        });
    return filas.take(limite).map((f) => {...f}).toList();
  }

  @override
  Future<List<FilaRemota>> subir({
    required String entidad,
    required List<FilaRemota> filas,
  }) async {
    _quizasFallar();
    final mio = uid;
    return [
      for (final fila in filas)
        () {
          final id = fila['id']! as String;
          final dueno = servidor.duenoDe(entidad, id);
          // El equivalente al RLS: no se pisa una fila de otra cuenta.
          if (dueno != null && dueno != mio) {
            throw ErrorRemoto('$entidad/$id pertenece a otra cuenta');
          }
          return {...servidor.guardar(entidad, fila, mio)};
        }(),
    ];
  }
}
