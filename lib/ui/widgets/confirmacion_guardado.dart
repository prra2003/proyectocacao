import 'package:flutter/material.dart';

import '../tema.dart';

/// Muestra una confirmación animada de "guardado": una tarjeta con un
/// círculo que aparece con un rebote y, adentro, un check que se dibuja
/// trazo a trazo. Se cierra sola después de un momento.
///
/// Se usa en los registros que de verdad le importan al productor —un
/// lote, una finca, sus propios datos, una cosecha, una labor, un
/// diagnóstico— en vez de un snackbar que es fácil de no ver. El `Future`
/// que devuelve termina cuando la confirmación ya se cerró, así que quien
/// llama puede esperarla antes de, por ejemplo, volver a la pantalla
/// anterior.
Future<void> mostrarConfirmacionGuardado(
  BuildContext context, {
  required String mensaje,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: mensaje,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (contexto, animacion, animacionSecundaria) {
      return _ConfirmacionGuardado(mensaje: mensaje);
    },
    transitionBuilder: (contexto, animacion, animacionSecundaria, child) {
      return FadeTransition(opacity: animacion, child: child);
    },
  );
}

class _ConfirmacionGuardado extends StatefulWidget {
  const _ConfirmacionGuardado({required this.mensaje});

  final String mensaje;

  @override
  State<_ConfirmacionGuardado> createState() => _ConfirmacionGuardadoState();
}

class _ConfirmacionGuardadoState extends State<_ConfirmacionGuardado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _circulo = CurvedAnimation(
    parent: _controlador,
    curve: const Interval(0, 0.5, curve: Curves.elasticOut),
  );
  late final Animation<double> _trazo = CurvedAnimation(
    parent: _controlador,
    curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controlador.forward();
    // Se queda visible un instante después de terminar de dibujarse, y
    // luego se cierra sola: el productor no tiene que tocar nada para
    // seguir su camino.
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: _circulo,
          child: Container(
            width: 190,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: PaletaCacao.tarjeta,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 68,
                  height: 68,
                  child: AnimatedBuilder(
                    animation: _trazo,
                    builder: (contexto, _) => CustomPaint(
                      painter: _PintorCheck(progreso: _trazo.value),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PaletaCacao.crema,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibuja un círculo verde y, adentro, un check que se traza progresivamente
/// según [progreso] (0 = nada, 1 = check completo).
class _PintorCheck extends CustomPainter {
  _PintorCheck({required this.progreso});

  final double progreso;

  @override
  void paint(Canvas lienzo, Size medida) {
    final w = medida.width;
    final h = medida.height;

    lienzo.drawCircle(
      Offset(w / 2, h / 2),
      w / 2,
      Paint()..color = PaletaCacao.verde,
    );

    final ruta = Path()
      ..moveTo(w * 0.27, h * 0.52)
      ..lineTo(w * 0.44, h * 0.68)
      ..lineTo(w * 0.76, h * 0.32);

    final metrica = ruta.computeMetrics().first;
    final parcial = metrica.extractPath(0, metrica.length * progreso);

    lienzo.drawPath(
      parcial,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PintorCheck anterior) => anterior.progreso != progreso;
}
