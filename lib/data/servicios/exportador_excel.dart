import 'dart:io';

import 'package:excel/excel.dart' as xls;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../ui/widgets/comunes.dart';
import 'nombre_archivo.dart';

/// Arma un Excel (.xlsx) genérico a partir de encabezados y filas de texto,
/// y abre el panel para compartir de Android/iOS —el productor decide si lo
/// guarda en el teléfono, lo sube a Drive o lo manda por correo o WhatsApp.
///
/// No sabe nada de fincas, lotes ni historial: cualquier pantalla con una
/// tabla en pantalla la puede exportar con esto, pasándole exactamente lo
/// que el productor está viendo (ya filtrado, si hay filtros puestos).
Future<void> exportarTablaAExcel(
  BuildContext context, {
  required String tituloHoja,
  required List<String> encabezados,
  required List<List<String>> filas,
  required String nombreArchivo,
  required String tituloComparticion,
}) async {
  if (filas.isEmpty) {
    avisar(context, 'No hay nada que exportar con estos filtros');
    return;
  }

  final libro = xls.Excel.createExcel();
  final nombreHojaOriginal = libro.sheets.keys.first;
  // El nombre de hoja por defecto ("Sheet1") no dice nada; se renombra a
  // algo que sí tenga sentido para quien abra el archivo.
  final tituloValido = tituloHoja.length > 31
      ? tituloHoja.substring(0, 31)
      : tituloHoja;
  libro.rename(nombreHojaOriginal, tituloValido);
  final hoja = libro[tituloValido];

  hoja.appendRow(encabezados.map(xls.TextCellValue.new).toList());
  for (final fila in filas) {
    hoja.appendRow(fila.map(xls.TextCellValue.new).toList());
  }
  for (var i = 0; i < encabezados.length; i++) {
    hoja.setColumnAutoFit(i);
  }

  final bytes = libro.save();
  if (bytes == null) {
    if (context.mounted) avisar(context, 'No se pudo generar el Excel');
    return;
  }

  final carpeta = await getTemporaryDirectory();
  final marca = DateTime.now().millisecondsSinceEpoch;
  final archivo = File(
    '${carpeta.path}/${nombreDeArchivo(nombreArchivo)}_$marca.xlsx',
  );
  await archivo.writeAsBytes(bytes, flush: true);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(archivo.path)],
      subject: tituloComparticion,
      text: tituloComparticion,
    ),
  );
}
