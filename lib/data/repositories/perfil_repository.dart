import '../daos/daos.dart';
import '../local/database.dart';
import '../local/enums.dart';

/// Fachada del perfil del productor: la UI habla con esto y no con los DAOs,
/// para que cuando entre la sincronización con Supabase solo cambie esta capa.
class PerfilRepository {
  PerfilRepository(AppDatabase db, {required this.usuarioId})
    : _productores = db.productoresDao,
      _fincas = db.fincasDao,
      _lotes = db.lotesDao,
      _registros = db.registrosDao;

  final ProductoresDao _productores;
  final FincasDao _fincas;
  final LotesDao _lotes;
  final RegistrosDao _registros;

  /// Identidad de esta instalación: con ella se sabe cuál de los productores
  /// de la base es el de este usuario.
  final String usuarioId;

  Stream<Productor?> watchProductor() =>
      _productores.watchProductorDe(usuarioId);

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
    required double areaSembradaHa,
    required String variedadCacao,
    required DateTime fechaSiembra,
  }) {
    return _lotes.guardar(
      id: id,
      fincaId: fincaId,
      nombre: nombre,
      areaSembradaHa: areaSembradaHa,
      variedadCacao: variedadCacao,
      fechaSiembra: fechaSiembra,
    );
  }

  Future<void> borrarLote(String id) => _lotes.borrar(id);

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
}
