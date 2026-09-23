import 'package:drift/drift.dart' show Value;

import '../daos/daos.dart';
import '../local/database.dart';
import '../local/enums.dart';

/// Fachada del perfil del productor: la UI habla con esto y no con los DAOs,
/// para que cuando entre la sincronización con la nube solo cambie esta capa.
class PerfilRepository {
  PerfilRepository(AppDatabase db, {required this.usuarioId})
    : _productores = db.productoresDao,
      _fincas = db.fincasDao,
      _lotes = db.lotesDao,
      _registros = db.registrosDao,
      _sync = db.syncDao;

  final ProductoresDao _productores;
  final SyncDao _sync;
  final FincasDao _fincas;
  final LotesDao _lotes;
  final RegistrosDao _registros;

  /// Identidad de esta instalación: con ella se sabe cuál de los productores
  /// de la base es el de este usuario.
  final String usuarioId;

  Stream<Productor?> watchProductor() =>
      _productores.watchProductorDe(usuarioId);

  /// La cuenta con la que se entró, si hay una: de ahí salen el nombre y el
  /// correo para no pedírselos otra vez al productor.
  Future<SesionLocal?> sesionActual() => _sync.sesionActual();

  Stream<Finca?> watchFinca(String productorId) =>
      _fincas.watchFincaPrincipal(productorId);

  /// Todas las fincas del productor (RF-02/RF-04): la Fase 1 ya no se limita
  /// a una sola.
  Stream<List<Finca>> watchFincas(String productorId) =>
      _fincas.watchFincasDe(productorId);

  Stream<List<Lote>> watchLotes(String fincaId) => _lotes.watchLotesDe(fincaId);

  Stream<List<Asociacion>> watchAsociaciones() =>
      _productores.watchAsociaciones();

  Future<Asociacion?> asociacionPorId(String id) =>
      _productores.asociacionPorId(id);

  /// Crea una asociación fuera del catálogo ("Otra, especificar") y devuelve
  /// su id, listo para usarse como `asociacionId` del productor.
  Future<String> crearAsociacion(String nombre) =>
      _productores.crearAsociacion(nombre);

  Future<String> guardarProductor({
    String? id,
    required String nombreCompleto,
    String? telefono,
    String? email,
    String? asociacionId,
    TipoDocumento? tipoDocumento,
    String? numeroDocumento,
  }) {
    return _productores.guardar(
      id: id,
      usuarioId: usuarioId,
      nombreCompleto: nombreCompleto,
      telefono: telefono,
      email: email,
      asociacionId: asociacionId,
      tipoDocumento: tipoDocumento,
      numeroDocumento: numeroDocumento,
    );
  }

  Future<String> guardarFinca({
    String? id,
    required String productorId,
    required String nombre,
    required String municipio,
    required String departamento,
    double? latitud,
    double? longitud,
  }) {
    return _fincas.guardar(
      id: id,
      productorId: productorId,
      nombre: nombre,
      municipio: municipio,
      departamento: departamento,
      latitud: latitud,
      longitud: longitud,
    );
  }

  Future<String> guardarLote({
    String? id,
    required String fincaId,
    required String nombre,
    String? codigo,
    required double areaSembradaHa,
    required String variedadCacao,
    required DateTime fechaSiembra,
    Value<String?> fotoPath = const Value.absent(),
  }) {
    return _lotes.guardar(
      id: id,
      fincaId: fincaId,
      nombre: nombre,
      codigo: codigo,
      areaSembradaHa: areaSembradaHa,
      variedadCacao: variedadCacao,
      fechaSiembra: fechaSiembra,
      fotoPath: fotoPath,
    );
  }

  Future<void> borrarLote(String id) => _lotes.borrar(id);

  /// Borra la finca y, en cascada, sus lotes, labores, cosechas y
  /// diagnósticos. Es borrado suave: viaja al servidor como los demás.
  Future<void> borrarFinca(String id) => _fincas.borrar(id);

  /// Kilos que llevaba la finca el año pasado **a esta misma fecha**: con eso
  /// se compara lo de este año sin castigarlo por los meses que faltan.
  Stream<double> watchKgAnioPasadoAEstaFecha(String fincaId, {DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    final corte = DateTime(ahora.year - 1, ahora.month, ahora.day + 1);
    return _registros.watchKgDeFincaEntre(
      fincaId,
      DateTime(ahora.year - 1),
      corte,
    );
  }

  /// Labores de la finca, para los recordatorios del Inicio.
  Stream<List<ActividadAgricola>> watchActividadesDeFinca(String fincaId) =>
      _registros.watchActividadesDeFinca(fincaId);

  /// Producción de toda la finca en un año, como stream para el resumen.
  Stream<double> watchProduccionAnual(String fincaId, int anio) =>
      _registros.watchKgDeFinca(fincaId, anio);

  /// Producción de toda la finca en un año, sumando lote por lote.
  Future<double> produccionAnual(String fincaId, int anio) async {
    final lotes = await _lotes.watchLotesDe(fincaId).first;
    var total = 0.0;
    for (final lote in lotes) {
      total += await _registros.kgCosechadosEn(lote.id, anio);
    }
    return total;
  }

  /// Edad del cultivo calculada, nunca guardada: el dato se desactualiza solo.
  static int edadEnAnios(DateTime fechaSiembra, {DateTime? hoy}) {
    final referencia = hoy ?? DateTime.now();
    var anios = referencia.year - fechaSiembra.year;
    final cumpleEsteAnio = DateTime(
      referencia.year,
      fechaSiembra.month,
      fechaSiembra.day,
    );
    if (referencia.isBefore(cumpleEsteAnio)) anios--;
    return anios < 0 ? 0 : anios;
  }

  /// Área sembrada total de la finca, en hectáreas.
  static double areaTotal(List<Lote> lotes) =>
      lotes.fold<double>(0, (suma, l) => suma + l.areaSembradaHa);

  /// Todos los lotes del productor, de todas sus fincas. Lo usa la pantalla
  /// de reportes, que mira la finca entera y no un lote a la vez.
  Stream<List<Lote>> watchLotesDeProductor(String productorId) =>
      _fincas.watchLotesDeProductor(productorId);
}
