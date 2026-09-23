import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../ui/widgets/comunes.dart';
import 'nombre_archivo.dart';

/// Arma un PDF genérico a partir de un título, encabezados y filas de texto,
/// y abre el panel del sistema para guardarlo, compartirlo o imprimirlo
/// directamente —lo mismo que hace `exportarTablaAExcel`, pero en PDF.
///
/// Igual que el de Excel, no sabe nada de fincas ni lotes: recibe la tabla
/// ya armada por la pantalla que llama, con exactamente lo que el productor
/// está viendo.
Future<void> exportarTablaAPdf(
    BuildContext context, {
      required String titulo,
      required String subtitulo,
      required List<String> encabezados,
      required List<List<String>> filas,
      required String nombreArchivo,
    }) async {
  if (filas.isEmpty) {
    avisar(context, 'No hay nada que exportar con estos filtros');
    return;
  }

  final documento = pw.Document();
  documento.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      header: (contexto) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            subtitulo,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
        ],
      ),
      build: (contexto) => [
        pw.TableHelper.fromTextArray(
          headers: encabezados,
          data: filas,
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
          cellStyle: const pw.TextStyle(fontSize: 9.5),
          cellAlignment: pw.Alignment.centerLeft,
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 5,
          ),
          rowDecoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            ),
          ),
        ),
      ],
      footer: (contexto) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Página ${contexto.pageNumber} de ${contexto.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ),
    ),
  );

  final bytes = await documento.save();
  await Printing.sharePdf(
    bytes: bytes,
    filename: '${nombreDeArchivo(nombreArchivo)}.pdf',
  );
}