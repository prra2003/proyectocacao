import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../ui/formato.dart';
import '../../ui/widgets/comunes.dart';
import '../local/database.dart';
import '../repositories/lote_repository.dart';
import '../repositories/perfil_repository.dart';
import 'nombre_archivo.dart';

/// Todo lo de un lote ya cargado: sus labores y sus cosechas, listas para
/// imprimir. Se arma antes de tocar el PDF para no mezclar `Future`s con la
/// construcción del documento.
class _DatosLote {
  _DatosLote({
    required this.lote,
    required this.actividades,
    required this.cosechas,
  });

  final Lote lote;
  final List<ActividadAgricola> actividades;
  final List<Cosecha> cosechas;

  double get kgCosechados =>
      cosechas.fold<double>(0, (suma, c) => suma + c.cantidadKg);
}

/// Todo lo de una finca: sus datos y la lista de lotes ya cargados.
class _DatosFinca {
  _DatosFinca({required this.finca, required this.lotes});

  final Finca finca;
  final List<_DatosLote> lotes;

  double get kgCosechados =>
      lotes.fold<double>(0, (suma, l) => suma + l.kgCosechados);
}

/// Exporta a un solo PDF el nombre del productor, cada una de las [fincas]
/// pasadas, los lotes de cada finca, y las labores y cosechas de cada lote —
/// organizado en ese orden, de lo general a lo particular.
///
/// [fincas] decide el alcance: la pantalla que llama pasa una sola finca
/// (para "descargar solo esta finca") o todas las fincas del productor
/// (para "descargar todo"); esta función no sabe ni le importa cuál fue.
///
/// A diferencia de `exportarTablaAPdf` (una sola tabla plana, ya filtrada por
/// la pantalla que llama), esta función arma el árbol completo desde los
/// repositorios y construye un documento con una sección por finca y una
/// subsección por lote, cada una con su propia tabla de labores y de
/// cosechas.
Future<void> exportarHistorialProductorAPdf(
  BuildContext context, {
  required PerfilRepository repo,
  required LoteRepository lotesRepo,
  required Productor productor,
  required List<Finca> fincas,
  DateTimeRange? rango,
}) async {
  if (fincas.isEmpty) {
    if (context.mounted) {
      avisar(context, 'Todavía no hay fincas registradas para exportar');
    }
    return;
  }

  final datosFincas = <_DatosFinca>[];
  for (final finca in fincas) {
    final lotes = await repo.watchLotes(finca.id).first;
    final datosLotes = <_DatosLote>[];
    for (final lote in lotes) {
      final actividades = await lotesRepo.watchActividades(lote.id).first;
      final cosechas = await lotesRepo.watchCosechas(lote.id).first;
      datosLotes.add(
        _DatosLote(
          lote: lote,
          actividades: actividades
              .where((a) => _dentro(a.fecha, rango))
              .toList(),
          cosechas: cosechas.where((c) => _dentro(c.fecha, rango)).toList(),
        ),
      );
    }
    datosFincas.add(_DatosFinca(finca: finca, lotes: datosLotes));
  }

  if (!context.mounted) return;

  final soloUnaFinca = fincas.length == 1;
  final titulo = soloUnaFinca
      ? 'Historial de la finca ${fincas.first.nombre}'
      : 'Historial completo del productor';

  final documento = pw.Document();
  documento.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      header: (contexto) {
        // El encabezado del título solo va en la primera página: en las
        // siguientes molesta más de lo que ayuda.
        if (contexto.pageNumber > 1) return pw.SizedBox();
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              titulo,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              rango == null
                  ? 'Generado el ${fechaLarga(DateTime.now())}'
                  : 'Del ${fechaLarga(rango.start)} al '
                        '${fechaLarga(rango.end)}   ·   generado el '
                        '${fechaLarga(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 16),
          ],
        );
      },
      footer: (contexto) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Página ${contexto.pageNumber} de ${contexto.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ),
      build: (contexto) => [
        _bloqueProductor(productor, datosFincas),
        pw.SizedBox(height: 20),
        for (final datosFinca in datosFincas) _bloqueFinca(datosFinca),
      ],
    ),
  );

  final bytes = await documento.save();
  final nombreArchivo = soloUnaFinca
      ? 'historial_${productor.nombreCompleto}_${fincas.first.nombre}'
      : 'historial_${productor.nombreCompleto}';
  await Printing.sharePdf(
    bytes: bytes,
    filename: '${nombreDeArchivo(nombreArchivo)}.pdf',
  );
}

/// ¿La fecha cae dentro del rango elegido en la pantalla?
///
/// Sin rango entra todo. El día final cuenta completo: quien escoge "hasta el
/// 30" espera que lo del 30 salga, no que se pierda por la hora.
bool _dentro(DateTime fecha, DateTimeRange? rango) {
  if (rango == null) return true;
  return !fecha.isBefore(rango.start) &&
      !fecha.isAfter(rango.end.add(const Duration(days: 1)));
}

// ---------------------------------------------------------------------------
// Bloques del documento
// ---------------------------------------------------------------------------

pw.Widget _bloqueProductor(Productor productor, List<_DatosFinca> fincas) {
  final totalKg = fincas.fold<double>(0, (suma, f) => suma + f.kgCosechados);
  final totalLotes = fincas.fold<int>(0, (suma, f) => suma + f.lotes.length);
  final datos = [
    if (productor.numeroDocumento != null)
      '${productor.tipoDocumento == null ? 'Documento' : etiquetaTipoDocumento(productor.tipoDocumento!)}: ${productor.numeroDocumento}',
    if (productor.telefono != null) 'Teléfono: ${productor.telefono}',
    if (productor.email != null) 'Correo: ${productor.email}',
  ];
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: PdfColors.green50,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: PdfColors.green200),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          productor.nombreCompleto,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        if (datos.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            datos.join('   ·   '),
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          '${fincas.length} ${fincas.length == 1 ? 'finca' : 'fincas'}   ·   '
          '$totalLotes ${totalLotes == 1 ? 'lote' : 'lotes'}   ·   '
          '${numeroCorto(totalKg)} kg cosechados en total',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

pw.Widget _bloqueFinca(_DatosFinca datosFinca) {
  final finca = datosFinca.finca;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 4),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: const pw.BoxDecoration(color: PdfColors.green700),
        child: pw.Text(
          'Finca: ${finca.nombre}  —  ${finca.municipio}, ${finca.departamento}'
          '  ·  ${numeroCorto(datosFinca.kgCosechados)} kg cosechados',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ),
      pw.SizedBox(height: 8),
      if (datosFinca.lotes.isEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 8, bottom: 12),
          child: pw.Text(
            'Sin lotes registrados en esta finca.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        )
      else
        for (final datosLote in datosFinca.lotes) _bloqueLote(datosLote),
      pw.SizedBox(height: 10),
    ],
  );
}

pw.Widget _bloqueLote(_DatosLote datosLote) {
  final lote = datosLote.lote;
  final edad = PerfilRepository.edadEnAnios(lote.fechaSiembra);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: 10, bottom: 12),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: pw.BoxDecoration(
            color: PdfColors.green100,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            'Lote ${lote.nombre}${lote.codigo.isEmpty ? '' : ' (${lote.codigo})'}'
            '  ·  ${lote.variedadCacao}  ·  ${numeroCorto(lote.areaSembradaHa)} ha'
            '  ·  sembrado ${fechaLarga(lote.fechaSiembra)} ($edad años)',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Labores (${datosLote.actividades.length})',
          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        if (datosLote.actividades.isEmpty)
          _sinRegistros('Sin labores registradas en este lote.')
        else
          _tabla(
            encabezados: const [
              'Fecha',
              'Tipo',
              'Detalle',
              'Responsable',
              'Costo',
            ],
            filas: [for (final a in datosLote.actividades) _filaActividad(a)],
            anchos: const {0: 1.6, 1: 1.7, 2: 4.2, 3: 1.7, 4: 1.3},
          ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Cosechas (${datosLote.cosechas.length})',
          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        if (datosLote.cosechas.isEmpty)
          _sinRegistros('Sin cosechas registradas en este lote.')
        else
          _tabla(
            encabezados: const [
              'Fecha',
              'Tipo de producto',
              'Cantidad (kg)',
              'Observaciones',
            ],
            filas: [for (final c in datosLote.cosechas) _filaCosecha(c)],
            anchos: const {0: 1.6, 1: 2.2, 2: 1.6, 3: 3.6},
          ),
      ],
    ),
  );
}

pw.Widget _sinRegistros(String mensaje) => pw.Text(
  mensaje,
  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
);

pw.Widget _tabla({
  required List<String> encabezados,
  required List<List<String>> filas,
  required Map<int, double> anchos,
}) {
  return pw.TableHelper.fromTextArray(
    headers: encabezados,
    data: filas,
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 8.5,
      color: PdfColors.white,
    ),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.brown700),
    cellStyle: const pw.TextStyle(fontSize: 8),
    cellAlignment: pw.Alignment.centerLeft,
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    columnWidths: {
      for (final entrada in anchos.entries)
        entrada.key: pw.FlexColumnWidth(entrada.value),
    },
  );
}

/// Junta en una sola celda de "Detalle" los campos propios de cada tipo de
/// labor (siembra, poda, fertilización, control fitosanitario, riego),
/// dejando fuera responsable y costo porque esos van en su propia columna.
List<String> _filaActividad(ActividadAgricola a) {
  final detalle = [
    if (a.subtipoLabor != null) a.subtipoLabor!,
    if (a.arbolesSembrados != null) '${a.arbolesSembrados} árboles sembrados',
    if (a.edadPlantulaMeses != null) 'plántula de ${a.edadPlantulaMeses} meses',
    if (a.insumos != null) 'Insumos: ${a.insumos}',
    if (a.arbolesAfectados != null) '${a.arbolesAfectados} árboles',
    if (a.edadCultivoAnios != null) 'cultivo de ${a.edadCultivoAnios} años',
    if (a.producto != null) 'Producto: ${a.producto}',
    if (a.cantidadAplicada != null) 'Cantidad: ${a.cantidadAplicada}',
    if (a.incidencia != null) 'Incidencia: ${a.incidencia}',
    if (a.resultadoEsperado != null) 'Esperado: ${a.resultadoEsperado}',
    if (a.observaciones != null) a.observaciones!,
  ].join(' · ');
  return [
    fechaCorta(a.fecha),
    etiquetaActividad(a.tipoActividad),
    detalle.isEmpty ? '—' : detalle,
    a.responsable ?? '—',
    a.costo == null ? '—' : '\$${numeroCorto(a.costo!)}',
  ];
}

List<String> _filaCosecha(Cosecha c) => [
  fechaCorta(c.fecha),
  c.tipoProducto ?? '—',
  numeroCorto(c.cantidadKg),
  c.observaciones ?? '—',
];
