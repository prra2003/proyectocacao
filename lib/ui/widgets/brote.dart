import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tema.dart';

/// Un brote de cacao: dos hojas saliendo de un tallo curvo sobre una
/// semillita, dibujado a mano.
///
/// Se usa en la pantalla de bienvenida en vez de la mazorca completa: una
/// mazorca ya es la cosecha lista, y lo que la app acompaña es el ciclo
/// entero desde que se siembra — el brote cuenta esa historia mejor y se
/// lee igual de bien en tamaños pequeños.
class Brote extends StatelessWidget {
  const Brote({
    super.key,
    this.tamano = 96,
    this.color,
    this.colorHoja,
    this.colorTallo,
  });

  final double tamano;

  /// Color de la hoja de adelante. Sin color explícito, usa el color
  /// primario del tema (igual que hace `Mazorca`).
  final Color? color;

  /// Color de la hoja de atrás, para dar algo de contraste entre las dos.
  final Color? colorHoja;

  /// Color del tallo y la semilla de la base.
  final Color? colorTallo;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(
        painter: _PintorBrote(
          hojaFrente: color ?? esquema.primary,
          hojaAtras: colorHoja ?? PaletaCacao.verdeOscuro,
          tallo: colorTallo ?? colorHoja ?? PaletaCacao.verdeOscuro,
        ),
      ),
    );
  }
}

class _PintorBrote extends CustomPainter {
  _PintorBrote({
    required this.hojaFrente,
    required this.hojaAtras,
    required this.tallo,
  });

  final Color hojaFrente;
  final Color hojaAtras;
  final Color tallo;

  @override
  void paint(Canvas lienzo, Size medida) {
    final w = medida.width;
    final h = medida.height;

    final baseX = w * 0.5;
    final baseY = h * 0.92;
    final apiceY = h * 0.42;

    // La semilla de la que sale todo: una elipse suave en la base.
    lienzo.drawOval(
      Rect.fromCenter(
        center: Offset(baseX, baseY + h * 0.03),
        width: w * 0.26,
        height: h * 0.16,
      ),
      Paint()..color = tallo.withValues(alpha: 0.28),
    );

    // El tallo: una curva, no una línea recta, para que se vea vivo.
    final trazoTallo = Paint()
      ..color = tallo
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(3, w * 0.045)
      ..strokeCap = StrokeCap.round;
    lienzo.drawPath(
      Path()
        ..moveTo(baseX, baseY)
        ..quadraticBezierTo(baseX - w * 0.07, h * 0.66, baseX, apiceY),
      trazoTallo,
    );

    void hoja(Offset origen, double angulo, bool espejo, Color color) {
      lienzo.save();
      lienzo.translate(origen.dx, origen.dy);
      lienzo.rotate(espejo ? -angulo : angulo);

      final ancho = w * 0.4;
      final alto = h * 0.34;
      final ruta = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(ancho * 0.18, -alto * 0.62, ancho, -alto * 0.14)
        ..quadraticBezierTo(ancho * 0.5, alto * 0.22, 0, 0)
        ..close();
      lienzo.drawPath(ruta, Paint()..color = color);

      // Vena central: le da textura de hoja en vez de gota lisa.
      lienzo.drawLine(
        Offset.zero,
        Offset(ancho * 0.78, -alto * 0.05),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.14)
          ..strokeWidth = math.max(1, w * 0.012),
      );
      lienzo.restore();
    }

    // La de atrás primero, un poco más abajo y hacia el otro lado, para que
    // se note que son dos hojas y no una sola simétrica.
    hoja(Offset(baseX, apiceY + h * 0.06), 0.62, true, hojaAtras);
    hoja(Offset(baseX, apiceY), 0.58, false, hojaFrente);
  }

  @override
  bool shouldRepaint(_PintorBrote anterior) =>
      anterior.hojaFrente != hojaFrente ||
      anterior.hojaAtras != hojaAtras ||
      anterior.tallo != tallo;
}
