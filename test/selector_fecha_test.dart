import 'package:cacao_app/ui/tema.dart';
import 'package:cacao_app/ui/widgets/selector_fecha.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// En la pantalla del costo por kilo van dos selectores de fecha lado a lado.
/// En un teléfono angosto cada uno queda con poco más de cien píxeles útiles,
/// y ahí "01/01/2026" se partía en dos renglones con el año colgando aparte.
void main() {
  testWidgets('la fecha cabe en un renglón en un teléfono angosto', (
    tester,
  ) async {
    // Un teléfono de los corrientes, no una pantalla de escritorio.
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: temaCacao(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: SelectorFecha(
                    etiqueta: 'Desde',
                    fecha: DateTime(2026, 1, 1),
                    onCambio: (_) {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SelectorFecha(
                    etiqueta: 'Hasta',
                    fecha: DateTime(2026, 12, 31),
                    onCambio: (_) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    for (final texto in ['01/01/2026', '31/12/2026']) {
      final parrafo = tester.renderObject<RenderParagraph>(find.text(texto));
      expect(
        parrafo.size.height,
        lessThan(30),
        reason: 'La fecha $texto se partió en dos renglones: el año queda '
            'colgando aparte y se ve roto.',
      );
    }
  });
}
