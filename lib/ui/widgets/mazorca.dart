import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tema.dart';

/// Una mazorca de cacao dibujada a mano.
///
/// Va en vector y no como imagen para que se vea nítida a cualquier tamaño y
/// para no cargar la app con archivos: es el símbolo que acompaña a la finca,
/// los lotes y las pantallas vacías.
class Mazorca extends StatelessWidget {
  const Mazorca({
    super.key,
    this.tamano = 96,
    this.color,
    this.colorHoja,
    this.conHoja = true,
  });

  final double tamano;
  final Color? color;
  final Color? colorHoja;
  final bool conHoja;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(
        painter: _PintorMazorca(
          cuerpo: color ?? esquema.primary,
          hoja: colorHoja ?? PaletaCacao.verde,
          conHoja: conHoja,
        ),
      ),
    );
  }
}

class _PintorMazorca extends CustomPainter {
  _PintorMazorca({
    required this.cuerpo,
    required this.hoja,
    required this.conHoja,
  });

  final Color cuerpo;
  final Color hoja;
  final bool conHoja;

  @override
  void paint(Canvas lienzo, Size medida) {
    final w = medida.width;
    final h = medida.height;

    lienzo.save();
    // Ligeramente inclinada: una mazorca perfectamente vertical parece un icono
    // genérico, inclinada parece fruta.
    lienzo.translate(w / 2, h / 2);
    lienzo.rotate(-0.18);
    lienzo.translate(-w / 2, -h / 2);

    final alto = h * 0.78;
    final ancho = w * 0.46;
    final centroX = w * 0.5;
    final arriba = h * 0.16;
    final abajo = arriba + alto;

    final fruto = Path()
      ..moveTo(centroX, arriba)
      ..cubicTo(
        centroX + ancho,
        arriba + alto * 0.18,
        centroX + ancho * 0.92,
        abajo - alto * 0.12,
        centroX,
        abajo,
      )
      ..cubicTo(
        centroX - ancho * 0.92,
        abajo - alto * 0.12,
        centroX - ancho,
        arriba + alto * 0.18,
        centroX,
        arriba,
      )
      ..close();

    lienzo.drawPath(fruto, Paint()..color = cuerpo);

    // Los surcos que recorren la mazorca de punta a punta.
    final surco = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, w * 0.022)
      ..strokeCap = StrokeCap.round;
    for (final desvio in [-0.5, 0.0, 0.5]) {
      lienzo.drawPath(
        Path()
          ..moveTo(centroX + ancho * 0.12 * desvio, arriba + alto * 0.08)
          ..cubicTo(
            centroX + ancho * (0.55 * desvio + 0.06),
            arriba + alto * 0.35,
            centroX + ancho * (0.55 * desvio + 0.06),
            abajo - alto * 0.3,
            centroX + ancho * 0.12 * desvio,
            abajo - alto * 0.06,
          ),
        surco,
      );
    }

    // Pedúnculo.
    lienzo.drawLine(
      Offset(centroX, arriba),
      Offset(centroX - w * 0.04, arriba - h * 0.1),
      Paint()
        ..color = cuerpo
        ..strokeWidth = math.max(1.6, w * 0.035)
        ..strokeCap = StrokeCap.round,
    );

    if (conHoja) {
      final base = Offset(centroX - w * 0.04, arriba - h * 0.07);
      lienzo.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(
            base.dx + w * 0.2,
            base.dy - h * 0.14,
            base.dx + w * 0.28,
            base.dy - h * 0.02,
          )
          ..quadraticBezierTo(
            base.dx + w * 0.16,
            base.dy + h * 0.06,
            base.dx,
            base.dy,
          )
          ..close(),
        Paint()..color = hoja,
      );
    }

    lienzo.restore();
  }

  @override
  bool shouldRepaint(_PintorMazorca anterior) =>
      anterior.cuerpo != cuerpo ||
      anterior.hoja != hoja ||
      anterior.conHoja != conHoja;
}

/// La mazorca dentro de un círculo, para usarla como avatar de una fila.
class MazorcaRedonda extends StatelessWidget {
  const MazorcaRedonda({super.key, this.diametro = 56, this.fondo});

  final double diametro;
  final Color? fondo;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        color: fondo ?? esquema.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Mazorca(
        tamano: diametro * 0.62,
        color: esquema.onPrimaryContainer,
        conHoja: false,
      ),
    );
  }
}
