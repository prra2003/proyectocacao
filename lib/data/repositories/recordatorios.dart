import '../local/database.dart';
import '../local/enums.dart';

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
