import '../local/database.dart';
import '../local/enums.dart';

/// Lo que le falta por llenar a una labor ya anotada, con los mismos nombres
/// que usa el formulario.
///
/// Solo se piden los datos que esa labor sí necesita: a un riego no se le
/// reclama el producto aplicado. La fecha y el tipo nunca faltan — son
/// obligatorios al registrar.
///
/// Vive en la capa de datos y no en el diálogo porque no es una regla de
/// pantalla: es qué se considera una labor bien documentada, y eso lo usan
/// tanto el formulario como el Inicio.
List<String> faltaLlenarEn(ActividadAgricola labor) {
  bool vacio(String? valor) => valor == null || valor.trim().isEmpty;
  final falta = <String>[];

  switch (labor.tipoActividad) {
    case TipoActividad.siembra:
      if (labor.arbolesSembrados == null) falta.add('Árboles sembrados');
      if (labor.edadPlantulaMeses == null) falta.add('Edad de la plántula');
    case TipoActividad.poda:
      if (vacio(labor.subtipoLabor)) falta.add('Tipo de poda');
      if (labor.arbolesAfectados == null) falta.add('Árboles podados');
    case TipoActividad.fertilizacion:
      if (vacio(labor.subtipoLabor)) falta.add('Tipo de fertilización');
      if (vacio(labor.producto)) falta.add('Producto aplicado');
      if (vacio(labor.cantidadAplicada)) falta.add('Cantidad aplicada');
    case TipoActividad.controlFitosanitario:
      if (vacio(labor.subtipoLabor)) falta.add('Problema detectado');
      if (vacio(labor.producto)) falta.add('Producto aplicado');
      if (vacio(labor.cantidadAplicada)) falta.add('Cantidad aplicada');
    case TipoActividad.riego:
      if (vacio(labor.subtipoLabor)) falta.add('Tipo de riego');
      if (vacio(labor.cantidadAplicada)) falta.add('Cantidad de agua');
    case TipoActividad.otro:
      if (vacio(labor.observaciones)) falta.add('Observaciones');
  }
  return falta;
}

// ---------------------------------------------------------------------------
// Plazo de una semana para editar (lote y labor)
// ---------------------------------------------------------------------------

/// Días que tiene el productor para editar un lote o una labor, contados desde
/// el día en que lo creó. Es la misma semana para los dos. Pasado el plazo
/// queda cerrado y solo el administrador podrá volver a habilitarlo.
///
/// Para cambiar el plazo basta con cambiar este número.
const diasParaEditar = 7;

DateTime _soloFecha(DateTime momento) {
  final local = momento.toLocal();
  // En UTC para que la resta dé días exactos, sin líos de horario.
  return DateTime.utc(local.year, local.month, local.day);
}

/// Días que le quedan para editar algo creado en [creado]. 0 = ya se cerró.
///
/// Ej. creado hace 2 días: le quedan 5.
int diasQuedanParaEditar(DateTime creado, {DateTime? hoy}) {
  final pasados = _soloFecha(
    hoy ?? DateTime.now(),
  ).difference(_soloFecha(creado)).inDays;
  final quedan = diasParaEditar - pasados;
  return quedan < 0 ? 0 : quedan;
}

/// Días que le quedan a la labor para poder editarse. 0 = ya se cerró.
int diasQuedanLabor(ActividadAgricola labor, {DateTime? hoy}) =>
    diasQuedanParaEditar(labor.createdAt, hoy: hoy);

/// ¿Ya pasó la semana y la labor quedó cerrada?
bool plazoVencido(ActividadAgricola labor, {DateTime? hoy}) =>
    diasQuedanLabor(labor, hoy: hoy) == 0;

/// Le falta algo y todavía está dentro de la semana para llenarlo.
bool sePuedeCompletar(ActividadAgricola labor, {DateTime? hoy}) =>
    faltaLlenarEn(labor).isNotEmpty && !plazoVencido(labor, hoy: hoy);

/// Le falta algo y ya se cerró: hay que pedirle al administrador que la
/// vuelva a habilitar.
bool quedoIncompleta(ActividadAgricola labor, {DateTime? hoy}) =>
    faltaLlenarEn(labor).isNotEmpty && plazoVencido(labor, hoy: hoy);

/// "Faltan 5 días para que llene la labor", en palabras del campo.
String textoPlazo(ActividadAgricola labor, {DateTime? hoy}) {
  if (plazoVencido(labor, hoy: hoy)) {
    return 'Pasó la semana: ya no se puede editar. El administrador puede '
        'volver a habilitarla.';
  }
  final quedan = diasQuedanLabor(labor, hoy: hoy);
  final completa = faltaLlenarEn(labor).isEmpty;
  if (quedan == 1) {
    return completa
        ? 'Hoy es el último día para editarla.'
        : 'Hoy es el último día para llenar la labor.';
  }
  return completa
      ? 'Puede editarla durante $quedan días más.'
      : 'Faltan $quedan días para que llene la labor; de lo contrario no '
      'podrá editarla.';
}

/// Un aviso del Inicio: "El Alto lleva 95 días sin poda".
class Recordatorio {
  const Recordatorio({
    required this.lote,
    required this.mensaje,
    required this.tipo,
    required this.dias,
  });

  final Lote lote;
  final String mensaje;

  /// La labor que se propone anotar; `null` si es un aviso general.
  final TipoActividad? tipo;
  final int dias;
}

/// Cada cuánto conviene podar el cacao: la de mantenimiento se hace dos a
/// cuatro veces al año, así que pasados tres meses ya vale la pena recordarla.
const diasEntrePodas = 90;

/// Sin anotar nada en un lote durante este tiempo, lo más probable es que sí
/// se haya trabajado y no se anotó.
const diasSinLabores = 45;

/// Los avisos que tocan hoy, del más atrasado al menos atrasado.
///
/// Se calculan con lo que ya está anotado, sin guardar nada: si el productor
/// anota la poda, el aviso desaparece solo. A un lote recién creado no se le
/// recuerda nada: todavía no ha tenido tiempo.
List<Recordatorio> recordatoriosPara(
    List<Lote> lotes,
    List<ActividadAgricola> actividades, {
      DateTime? hoy,
      int maximo = 2,
    }) {
  final ahora = hoy ?? DateTime.now();
  int diasDesde(DateTime fecha) => ahora.difference(fecha).inDays;

  final avisos = <Recordatorio>[];
  for (final lote in lotes) {
    final delLote = actividades.where((a) => a.loteId == lote.id).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    final edadDelLote = diasDesde(lote.createdAt);

    final podas = delLote.where((a) => a.tipoActividad == TipoActividad.poda);
    if (podas.isNotEmpty) {
      final dias = diasDesde(podas.first.fecha);
      if (dias >= diasEntrePodas) {
        avisos.add(
          Recordatorio(
            lote: lote,
            mensaje: '${lote.nombre} lleva $dias días sin poda.',
            tipo: TipoActividad.poda,
            dias: dias,
          ),
        );
        continue;
      }
    }

    final ultima = delLote.isEmpty ? null : delLote.first.fecha;
    final dias = ultima == null ? edadDelLote : diasDesde(ultima);
    if (dias >= diasSinLabores && edadDelLote >= diasSinLabores) {
      avisos.add(
        Recordatorio(
          lote: lote,
          mensaje: ultima == null
              ? '${lote.nombre} no tiene labores anotadas.'
              : 'Hace $dias días no anota nada en ${lote.nombre}.',
          tipo: null,
          dias: dias,
        ),
      );
    }
  }
  avisos.sort((a, b) => b.dias.compareTo(a.dias));
  return avisos.take(maximo).toList();
}