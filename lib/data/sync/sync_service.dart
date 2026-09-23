import 'package:flutter/foundation.dart';

import '../local/database.dart';
import '../local/enums.dart';
import 'api_remota.dart';
import 'mapeador_asociacion.dart';
import 'mapeador_finca.dart';
import 'mapeador_lote.dart';
import 'mapeadores_registros.dart';
import 'mapeador_productor.dart';
import 'sync_result.dart';
import 'sync_state.dart';

/// Qué pasó al intentar meter una fila remota en la base local.
enum ResultadoAplicacion {
  /// Se escribió.
  aplicada,

  /// No hacía falta escribir (ya estaba esa misma versión).
  sinCambios,

  /// Gana lo local, o el cambio local se descarta: hay un conflicto anotado.
  conflicto,

  /// No se puede aplicar todavía. El cursor se queda antes de esta fila.
  aplazada,
}

/// Lo que cada entidad aporta al ciclo común de sincronización.
///
/// Es a propósito una estructura de funciones y no una jerarquía de clases
/// genéricas: la parte delicada (orden, cursor, paginación, conflictos) vive una
/// sola vez en [SyncService], y cada entidad solo dice cómo son sus filas.
class PlanEntidad {
  const PlanEntidad({
    required this.nombre,
    required this.pendientes,
    required this.marcarSincronizado,
    required this.aplicar,
    required this.selloDe,
  });

  final String nombre;
  final Future<List<FilaRemota>> Function() pendientes;
  final Future<void> Function(String id, DateTime sello) marcarSincronizado;
  final Future<ResultadoAplicacion> Function(
    FilaRemota fila,
    ResultadoEntidad resultado,
  )
  aplicar;
  final DateTime Function(FilaRemota fila) selloDe;
}

/// Sincroniza la base local con el backend.
///
/// La base local es la fuente de verdad: esta clase nunca la reemplaza, solo
/// sube lo que falta y aplica lo que llegó. La UI jamás la espera.
///
/// Reglas, en orden:
/// 1. **Push antes que pull**, y por dependencias: productores → fincas. Así el
///    servidor nunca ve un hijo cuyo padre todavía no subió.
/// 2. **Una fila remota no pisa una fila local `pending`.** Cuando pasa, queda
///    anotado como [Conflicto] en el [SyncResult] en vez de perderse.
/// 3. **El cursor solo avanza sobre filas resueltas.** Si la descarga se corta,
///    o si un hijo llega antes que su padre, la siguiente pasada repite desde
///    ese punto; aplicar dos veces la misma fila es inofensivo.
class SyncService {
  SyncService({
    required AppDatabase baseDatos,
    required ApiRemota apiRemota,
    required this.usuarioLocal,
    this.tamanoPagina = 100,
  }) : _db = baseDatos,
       _api = apiRemota;

  final AppDatabase _db;
  final ApiRemota _api;

  /// Identidad de esta instalación (no cambia nunca).
  final String usuarioLocal;

  final int tamanoPagina;

  /// Para que la UI pueda mostrar el estado sin conocer la implementación.
  final estado = ValueNotifier<SyncState>(const SyncState());

  var _enCurso = false;

  /// Entra con la cuenta de Google y baja lo que haya en el servidor.
  ///
  /// Marca la descarga inicial como pendiente **antes** de sincronizar: hasta
  /// que termine, la interfaz no puede ofrecer crear un perfil, o quedarían dos
  /// productores bajo la misma cuenta.
  ///
  /// Con [reemplazarDatosLocales] se usa desde un teléfono que **ya tiene
  /// datos** y quiere cambiar de cuenta. El borrado ocurre **después** de que
  /// Google y el servidor aceptan: si algo falla, no se toca nada.
  Future<SyncResult> entrarConGoogle({
    bool reemplazarDatosLocales = false,
  }) async {
    try {
      final sesion = await _api.entrarConGoogle();
      if (reemplazarDatosLocales) await borrarDatosLocales(_db);
      await _db.syncDao.guardarSesionRemota(
        usuarioRemoto: sesion.usuarioId,
        correo: sesion.correo,
        token: sesion.token,
        nombre: sesion.nombre,
      );
      await _db.syncDao.empezarDescargaInicial();
    } on ErrorRemoto catch (e) {
      return SyncResult.fallo(e.mensaje);
    }
    return sincronizar();
  }

  /// Cierra la sesión y **borra los datos de este teléfono**.
  ///
  /// Los datos siguen en el servidor a nombre de la cuenta: se recuperan
  /// volviendo a entrar. Lo que no vuelve es lo que estuviera sin subir, por eso
  /// quien llama debe avisar antes si hay cambios pendientes.
  Future<void> cerrarSesion() async {
    await _api.cerrarSesion();
    await borrarDatosLocales(_db);
    await _db.syncDao.olvidarCuenta();
    estado.value = const SyncState();
  }

  Future<SyncResult> sincronizar() async {
    if (_enCurso) {
      return SyncResult.fallo('ya hay una sincronización en curso');
    }
    _enCurso = true;
    estado.value = estado.value.copiaCon(estado: EstadoSync.sincronizando);

    final entidades = <ResultadoEntidad>[];
    try {
      // Sin cuenta no hay servidor: el trabajo se guarda en el teléfono y ya.
      // No es un error ni algo que reintentar, así que la cinta no se pone en
      // rojo: simplemente no hay nada que sincronizar.
      final authUid = await _api.usuarioActual();
      if (authUid == null) {
        estado.value = const SyncState();
        return SyncResult.fallo('Sin cuenta: los datos quedan en el teléfono');
      }
      await _db.syncDao.guardarAuthUid(authUid);

      // El orden es el del árbol: un padre nunca puede ir después de su hijo.
      // Asociaciones va primero porque productores.asociacion_id apunta ahí.
      for (final plan in [
        _planAsociaciones(),
        _planProductores(authUid),
        _planFincas(),
        _planLotes(),
        ..._planesRegistros(),
      ]) {
        entidades.add(await _sincronizarEntidad(plan));
      }

      final resultado = SyncResult(entidades: entidades);
      // Si se estaba esperando la primera descarga de una cuenta, ya llegó.
      await _db.syncDao.terminarDescargaInicial();
      estado.value = SyncState(
        estado: EstadoSync.ok,
        lastSyncAt: DateTime.now(),
        ultimoResultado: resultado,
      );
      return resultado;
    } on SesionVencida catch (e) {
      // Reintentar no arregla nada: hay que pedirle la cuenta a la persona.
      await _db.syncDao.olvidarCuenta();
      final resultado = SyncResult.fallo(e.mensaje, entidades: entidades);
      estado.value = estado.value.copiaCon(
        estado: EstadoSync.error,
        ultimoResultado: resultado,
      );
      return resultado;
    } on ErrorRemoto catch (e) {
      final resultado = SyncResult.fallo(e.mensaje, entidades: entidades);
      estado.value = estado.value.copiaCon(
        estado: EstadoSync.error,
        ultimoResultado: resultado,
      );
      return resultado;
    } finally {
      _enCurso = false;
    }
  }

  Future<ResultadoEntidad> _sincronizarEntidad(PlanEntidad plan) async {
    final resultado = ResultadoEntidad(plan.nombre);

    // --- Subida ---
    final pendientes = await plan.pendientes();
    if (pendientes.isNotEmpty) {
      final selladas = await _api.subir(
        entidad: plan.nombre,
        filas: pendientes,
      );
      for (final sellada in selladas) {
        await plan.marcarSincronizado(
          sellada['id']! as String,
          plan.selloDe(sellada),
        );
        resultado.subidos++;
      }
    }

    // --- Descarga incremental por clave (updated_at, id) ---
    final cursor = await _db.syncDao.cursor(plan.nombre);
    var selloPagina = cursor.sello;
    var idPagina = cursor.id;
    DateTime? selloResuelto;
    String? idResuelto;
    var aplazada = false;

    while (!aplazada) {
      final filas = await _api.descargar(
        entidad: plan.nombre,
        desde: selloPagina,
        desdeId: idPagina,
        limite: tamanoPagina,
      );
      if (filas.isEmpty) break;

      for (final fila in filas) {
        final aplicacion = await plan.aplicar(fila, resultado);
        if (aplicacion == ResultadoAplicacion.aplazada) {
          aplazada = true;
          break;
        }
        if (aplicacion == ResultadoAplicacion.aplicada) resultado.bajados++;
        // El cursor solo se mueve sobre filas resueltas.
        selloResuelto = plan.selloDe(fila);
        idResuelto = fila['id']! as String;
      }

      if (filas.length < tamanoPagina) break;
      // Página siguiente: estrictamente después de la última clave leída, así
      // que el avance está garantizado aunque varias filas compartan sello.
      selloPagina = plan.selloDe(filas.last);
      idPagina = filas.last['id']! as String;
    }

    // Si algo falló, la excepción salió antes de esta línea y la próxima pasada
    // repite el tramo.
    if (selloResuelto != null && idResuelto != null) {
      await _db.syncDao.guardarCursor(plan.nombre, selloResuelto, idResuelto);
    }
    return resultado;
  }

  // --- Asociaciones ------------------------------------------------------
  //
  // Catálogo compartido sin dueño: no hay `usuario_id` que filtrar en
  // pendientes ni padre que esperar al aplicar.

  PlanEntidad _planAsociaciones() => PlanEntidad(
    nombre: MapeadorAsociacion.entidad,
    selloDe: MapeadorAsociacion.selloDe,
    pendientes: () async {
      final filas = await _db.productoresDao.asociacionesPendientes();
      return [for (final fila in filas) MapeadorAsociacion.aRemoto(fila)];
    },
    marcarSincronizado: _db.productoresDao.marcarAsociacionSincronizada,
    aplicar: _aplicarAsociacion,
  );

  Future<ResultadoAplicacion> _aplicarAsociacion(
    FilaRemota fila,
    ResultadoEntidad resultado,
  ) async {
    final id = fila['id']! as String;
    final local = await _db.productoresDao.asociacionPorId(id);
    final sello = MapeadorAsociacion.selloDe(fila);

    if (local != null && local.syncStatus == SyncStatus.pending) {
      resultado.conflictos.add(
        Conflicto(
          entidad: MapeadorAsociacion.entidad,
          id: id,
          motivo: motivoLocalPendiente,
        ),
      );
      return ResultadoAplicacion.conflicto;
    }
    // isAtSameMomentAs y no ==: dos DateTime del mismo instante no son iguales
    // en Dart si uno es UTC y el otro local.
    if (local != null &&
        (local.serverUpdatedAt?.isAtSameMomentAs(sello) ?? false)) {
      return ResultadoAplicacion.sinCambios;
    }

    await _db.productoresDao.aplicarAsociacionRemota(
      MapeadorAsociacion.deRemoto(fila),
    );
    return ResultadoAplicacion.aplicada;
  }

  // --- Productores -----------------------------------------------------

  PlanEntidad _planProductores(String authUid) => PlanEntidad(
    nombre: MapeadorProductor.entidad,
    selloDe: MapeadorProductor.selloDe,
    pendientes: () async {
      final filas = await _db.productoresDao.pendientes(usuarioLocal);
      return [
        for (final fila in filas) MapeadorProductor.aRemoto(fila, authUid),
      ];
    },
    marcarSincronizado: _db.productoresDao.marcarSincronizado,
    aplicar: _aplicarProductor,
  );

  Future<ResultadoAplicacion> _aplicarProductor(
    FilaRemota fila,
    ResultadoEntidad resultado,
  ) async {
    final id = fila['id']! as String;
    final local = await _db.productoresDao.porId(id);
    final sello = MapeadorProductor.selloDe(fila);

    if (local != null && local.syncStatus == SyncStatus.pending) {
      resultado.conflictos.add(
        Conflicto(
          entidad: MapeadorProductor.entidad,
          id: id,
          motivo: motivoLocalPendiente,
        ),
      );
      return ResultadoAplicacion.conflicto;
    }
    // isAtSameMomentAs y no ==: dos DateTime del mismo instante no son iguales
    // en Dart si uno es UTC y el otro local.
    if (local != null &&
        (local.serverUpdatedAt?.isAtSameMomentAs(sello) ?? false)) {
      return ResultadoAplicacion.sinCambios;
    }

    await _db.productoresDao.aplicarRemoto(
      MapeadorProductor.deRemoto(fila, usuarioLocal),
    );
    return ResultadoAplicacion.aplicada;
  }

  // --- Fincas ----------------------------------------------------------

  PlanEntidad _planFincas() => PlanEntidad(
    nombre: MapeadorFinca.entidad,
    selloDe: MapeadorFinca.selloDe,
    pendientes: () async {
      final filas = await _db.fincasDao.pendientes(usuarioLocal);
      return [for (final fila in filas) MapeadorFinca.aRemoto(fila)];
    },
    marcarSincronizado: _db.fincasDao.marcarSincronizado,
    aplicar: _aplicarFinca,
  );

  Future<ResultadoAplicacion> _aplicarFinca(
    FilaRemota fila,
    ResultadoEntidad resultado,
  ) async {
    final id = fila['id']! as String;
    final local = await _db.fincasDao.porId(id);
    final sello = MapeadorFinca.selloDe(fila);

    if (local != null && local.syncStatus == SyncStatus.pending) {
      resultado.conflictos.add(
        Conflicto(
          entidad: MapeadorFinca.entidad,
          id: id,
          motivo: motivoLocalPendiente,
        ),
      );
      return ResultadoAplicacion.conflicto;
    }

    // Una finca sin su productor rompería la llave foránea. En vez de tragarse
    // el error, se aplaza: en esta misma pasada los productores ya se
    // sincronizaron antes, así que si el padre sigue sin aparecer es que aún no
    // ha llegado al servidor.
    final padre = await _db.productoresDao.porId(
      fila['productor_id']! as String,
    );
    if (padre == null) {
      resultado.conflictos.add(
        Conflicto(
          entidad: MapeadorFinca.entidad,
          id: id,
          motivo: motivoPadreAusente,
        ),
      );
      return ResultadoAplicacion.aplazada;
    }

    // isAtSameMomentAs y no ==: dos DateTime del mismo instante no son iguales
    // en Dart si uno es UTC y el otro local.
    if (local != null &&
        (local.serverUpdatedAt?.isAtSameMomentAs(sello) ?? false)) {
      return ResultadoAplicacion.sinCambios;
    }

    await _db.fincasDao.aplicarRemoto(MapeadorFinca.deRemoto(fila));

    // Un borrado que llega del servidor arrastra el árbol de abajo, para que no
    // queden lotes ni registros vivos colgando de una finca borrada aunque sus
    // filas lleguen en otra página o en otro ciclo.
    final borradoEn = MapeadorFinca.fecha(fila['deleted_at']);
    if (borradoEn != null) {
      final pisados = await aplicarBorradoRemotoDeFinca(_db, id, borradoEn);
      for (final hijo in pisados) {
        resultado.conflictos.add(
          Conflicto(
            entidad: MapeadorFinca.entidad,
            id: hijo,
            motivo: motivoPadreBorradoRemoto,
          ),
        );
      }
    }
    return ResultadoAplicacion.aplicada;
  }

  // --- Lotes -----------------------------------------------------------

  PlanEntidad _planLotes() => PlanEntidad(
    nombre: MapeadorLote.entidad,
    selloDe: MapeadorLote.selloDe,
    pendientes: () async {
      final filas = await _db.lotesDao.pendientes(usuarioLocal);
      return [for (final fila in filas) MapeadorLote.aRemoto(fila)];
    },
    marcarSincronizado: _db.lotesDao.marcarSincronizado,
    aplicar: _aplicarLote,
  );

  Future<ResultadoAplicacion> _aplicarLote(
    FilaRemota fila,
    ResultadoEntidad resultado,
  ) async {
    final id = fila['id']! as String;
    final local = await _db.lotesDao.porId(id);
    final sello = MapeadorLote.selloDe(fila);

    if (local != null && local.syncStatus == SyncStatus.pending) {
      resultado.conflictos.add(
        Conflicto(
          entidad: MapeadorLote.entidad,
          id: id,
          motivo: motivoLocalPendiente,
        ),
      );
      return ResultadoAplicacion.conflicto;
    }

    final finca = await _db.fincasDao.porId(fila['finca_id']! as String);
    if (finca == null) {
      resultado.conflictos.add(
        Conflicto(
          entidad: MapeadorLote.entidad,
          id: id,
          motivo: motivoPadreAusente,
        ),
      );
      return ResultadoAplicacion.aplazada;
    }

    // isAtSameMomentAs y no ==: dos DateTime del mismo instante no son iguales
    // en Dart si uno es UTC y el otro local.
    if (local != null &&
        (local.serverUpdatedAt?.isAtSameMomentAs(sello) ?? false)) {
      return ResultadoAplicacion.sinCambios;
    }

    // La finca está borrada aquí y el lote llega vivo. Aplazarlo lo dejaría
    // atascado para siempre (la finca no va a revivir) y bloquearía el cursor,
    // así que se guarda ya borrado, con la fecha del padre.
    final padreBorrado = finca.deletedAt;
    final vieneVivo = MapeadorLote.fecha(fila['deleted_at']) == null;
    if (padreBorrado != null && vieneVivo) {
      resultado.conflictos.add(
        Conflicto(
          entidad: MapeadorLote.entidad,
          id: id,
          motivo: motivoPadreBorrado,
        ),
      );
    }

    await _db.lotesDao.aplicarRemoto(
      MapeadorLote.deRemoto(fila, borradoForzado: padreBorrado),
    );

    // Un borrado que llega del servidor arrastra los registros del lote, para
    // que no queden vivos aunque sus filas lleguen en otra página u otro ciclo.
    final borradoEn = MapeadorLote.fecha(fila['deleted_at']) ?? padreBorrado;
    if (borradoEn != null) {
      final pisados = await aplicarBorradoRemotoDeLote(_db, id, borradoEn);
      for (final hijo in pisados) {
        resultado.conflictos.add(
          Conflicto(
            entidad: MapeadorLote.entidad,
            id: hijo,
            motivo: motivoPadreBorradoRemoto,
          ),
        );
      }
    }
    return ResultadoAplicacion.aplicada;
  }

  // --- Actividades, cosechas y diagnósticos ----------------------------
  //
  // Las tres son hojas del árbol: cuelgan de un lote y no arrastran a nadie.
  // Por eso comparten [_planHoja] y solo se diferencian en su mapeador.

  List<PlanEntidad> _planesRegistros() {
    final registros = _db.registrosDao;
    return [
      _planHoja(
        nombre: MapeadorActividad.entidad,
        selloDe: MapeadorActividad.selloDe,
        pendientes: () async => [
          for (final fila in await registros.actividadesPendientes(
            usuarioLocal,
          ))
            MapeadorActividad.aRemoto(fila),
        ],
        marcarSincronizado: registros.marcarActividadSincronizada,
        estadoLocal: (id) async {
          final fila = await registros.actividadPorId(id);
          return fila == null
              ? null
              : (estado: fila.syncStatus, sello: fila.serverUpdatedAt);
        },
        aplicarRemoto: (fila, borradoForzado) =>
            registros.aplicarActividadRemota(
              MapeadorActividad.deRemoto(fila, borradoForzado: borradoForzado),
            ),
      ),
      _planHoja(
        nombre: MapeadorCosecha.entidad,
        selloDe: MapeadorCosecha.selloDe,
        pendientes: () async => [
          for (final fila in await registros.cosechasPendientes(usuarioLocal))
            MapeadorCosecha.aRemoto(fila),
        ],
        marcarSincronizado: registros.marcarCosechaSincronizada,
        estadoLocal: (id) async {
          final fila = await registros.cosechaPorId(id);
          return fila == null
              ? null
              : (estado: fila.syncStatus, sello: fila.serverUpdatedAt);
        },
        aplicarRemoto: (fila, borradoForzado) => registros.aplicarCosechaRemota(
          MapeadorCosecha.deRemoto(fila, borradoForzado: borradoForzado),
        ),
      ),
      _planHoja(
        nombre: MapeadorDiagnostico.entidad,
        selloDe: MapeadorDiagnostico.selloDe,
        pendientes: () async => [
          for (final fila in await registros.diagnosticosPendientes(
            usuarioLocal,
          ))
            MapeadorDiagnostico.aRemoto(fila),
        ],
        marcarSincronizado: registros.marcarDiagnosticoSincronizado,
        estadoLocal: (id) async {
          final fila = await registros.diagnosticoPorId(id);
          return fila == null
              ? null
              : (estado: fila.syncStatus, sello: fila.serverUpdatedAt);
        },
        aplicarRemoto: (fila, borradoForzado) =>
            registros.aplicarDiagnosticoRemoto(
              MapeadorDiagnostico.deRemoto(
                fila,
                borradoForzado: borradoForzado,
              ),
            ),
      ),
    ];
  }

  /// Las reglas de una hoja del árbol, escritas una sola vez.
  ///
  /// Son las mismas que las de [_aplicarLote] menos la cascada: una hoja no
  /// tiene hijos que arrastrar.
  PlanEntidad _planHoja({
    required String nombre,
    required DateTime Function(FilaRemota fila) selloDe,
    required Future<List<FilaRemota>> Function() pendientes,
    required Future<void> Function(String id, DateTime sello)
    marcarSincronizado,
    required Future<({SyncStatus estado, DateTime? sello})?> Function(String id)
    estadoLocal,
    required Future<void> Function(FilaRemota fila, DateTime? borradoForzado)
    aplicarRemoto,
  }) {
    return PlanEntidad(
      nombre: nombre,
      selloDe: selloDe,
      pendientes: pendientes,
      marcarSincronizado: marcarSincronizado,
      aplicar: (fila, resultado) async {
        final id = fila['id']! as String;
        final local = await estadoLocal(id);
        final sello = selloDe(fila);

        if (local != null && local.estado == SyncStatus.pending) {
          resultado.conflictos.add(
            Conflicto(entidad: nombre, id: id, motivo: motivoLocalPendiente),
          );
          return ResultadoAplicacion.conflicto;
        }

        final lote = await _db.lotesDao.porId(fila['lote_id']! as String);
        if (lote == null) {
          resultado.conflictos.add(
            Conflicto(entidad: nombre, id: id, motivo: motivoPadreAusente),
          );
          return ResultadoAplicacion.aplazada;
        }

        if (local != null && (local.sello?.isAtSameMomentAs(sello) ?? false)) {
          return ResultadoAplicacion.sinCambios;
        }

        // Mismo criterio que en los lotes: si el padre ya está borrado aquí, el
        // registro entra muerto en vez de aplazarse para siempre.
        final padreBorrado = lote.deletedAt;
        if (padreBorrado != null && borradoRemotoDe(fila) == null) {
          resultado.conflictos.add(
            Conflicto(entidad: nombre, id: id, motivo: motivoPadreBorrado),
          );
        }

        await aplicarRemoto(fila, padreBorrado);
        return ResultadoAplicacion.aplicada;
      },
    );
  }
}
