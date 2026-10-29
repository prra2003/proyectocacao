import '../data/local/enums.dart';

/// Fecha corta en el formato que se usa en campo: 05/03/2026.
String fechaCorta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/${d.year}';

const _meses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// Fecha legible para los listados: 5 mar 2026.
String fechaLarga(DateTime d) => '${d.day} ${_meses[d.month - 1]} ${d.year}';

/// Cantidades sin decimales de más: 2.5 ha, no 2.50 ha.
String numeroCorto(double valor) {
  final texto = valor.toStringAsFixed(2);
  if (texto.endsWith('.00')) return texto.substring(0, texto.length - 3);
  if (texto.endsWith('0')) return texto.substring(0, texto.length - 1);
  return texto;
}

/// Plata en pesos, con los puntos de mil y sin centavos: $1.840.000.
///
/// Se escribe a mano en vez de usar `intl` porque la app no lo trae y por un
/// solo formato no vale sumar una dependencia. Los centavos sobran: nadie
/// anota el jornal con decimales.
String pesos(double valor) {
  final negativo = valor < 0;
  final puntos = conPuntosDeMil(valor.abs().round().toString());
  return '${negativo ? '-' : ''}\$$puntos';
}

/// Mete los puntos de mil en una tira de dígitos: `1840000` → `1.840.000`.
///
/// Aparte de [pesos] porque el campo donde se escribe el costo también los
/// necesita, y ahí no va el signo de pesos adelante.
String conPuntosDeMil(String digitos) {
  final puntos = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) puntos.write('.');
    puntos.write(digitos[i]);
  }
  return puntos.toString();
}

/// Cuánto hace de una fecha, en palabras de todos los días.
String haceCuanto(DateTime fecha, {DateTime? hoy}) {
  final referencia = hoy ?? DateTime.now();
  final dias = DateTime(
    referencia.year,
    referencia.month,
    referencia.day,
  ).difference(DateTime(fecha.year, fecha.month, fecha.day)).inDays;

  if (dias <= 0) return 'hoy';
  if (dias == 1) return 'ayer';
  if (dias < 30) return 'hace $dias días';
  final meses = (dias / 30).floor();
  if (meses < 12) return meses == 1 ? 'hace un mes' : 'hace $meses meses';
  final anios = (dias / 365).floor();
  return anios == 1 ? 'hace un año' : 'hace $anios años';
}

String etiquetaActividad(TipoActividad tipo) => switch (tipo) {
  TipoActividad.siembra => 'Siembra',
  TipoActividad.poda => 'Poda',
  TipoActividad.fertilizacion => 'Fertilización',
  TipoActividad.controlFitosanitario => 'Control fitosanitario',
  TipoActividad.riego => 'Riego',
  TipoActividad.otro => 'Otra labor',
};

String etiquetaTipoDocumento(TipoDocumento tipo) => switch (tipo) {
  TipoDocumento.cedulaCiudadania => 'Cédula de ciudadanía',
  TipoDocumento.cedulaExtranjeria => 'Cédula de extranjería',
  TipoDocumento.tarjetaIdentidad => 'Tarjeta de identidad',
  TipoDocumento.nit => 'NIT',
  TipoDocumento.pasaporte => 'Pasaporte',
  TipoDocumento.otro => 'Otro',
};

String etiquetaEstado(EstadoFenologico estado) => switch (estado) {
  EstadoFenologico.vegetativo => 'Vegetativo',
  EstadoFenologico.floracion => 'Floración',
  EstadoFenologico.cuajado => 'Cuajado',
  EstadoFenologico.fructificacion => 'Fructificación',
  EstadoFenologico.maduracion => 'Maduración',
  EstadoFenologico.cosecha => 'Cosecha',
};
