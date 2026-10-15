import 'package:cacao_app/ui/widgets/nota_bpa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La nota de BPA tiene dos trabajos y los dos se prueban aquí: estar plegada
/// para no estorbarle al que anota a diario, y decir con todas las letras que
/// esto no certifica a nadie.
void main() {
  Future<void> montar(WidgetTester tester, {String? ojo}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotaBpa(
            titulo: '¿Para qué sirve anotar esto?',
            puntos: const ['La primera razón', 'La segunda razón'],
            ojo: ojo,
          ),
        ),
      ),
    );
  }

  testWidgets('arranca plegada: se ve el sello y el título, nada más', (
    tester,
  ) async {
    await montar(tester);

    expect(find.text('BPA'), findsOneWidget);
    expect(find.text('¿Para qué sirve anotar esto?'), findsOneWidget);
    expect(find.text('La primera razón'), findsNothing);
  });

  testWidgets('al tocarla muestra las razones, y al tocar otra vez se cierra', (
    tester,
  ) async {
    await montar(tester);

    await tester.tap(find.byKey(const Key('nota_bpa_abrir')));
    await tester.pumpAndSettle();
    expect(find.text('La primera razón'), findsOneWidget);
    expect(find.text('La segunda razón'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nota_bpa_abrir')));
    await tester.pumpAndSettle();
    expect(find.text('La primera razón'), findsNothing);
  });

  testWidgets('abierta, siempre aclara que no certifica', (tester) async {
    await montar(tester);
    await tester.tap(find.byKey(const Key('nota_bpa_abrir')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('no lo certifica'),
      findsOneWidget,
      reason:
          'Sin esta frase la nota puede hacerle creer al productor que ya '
          'cumple, y el ICA decirle lo contrario en la visita.',
    );
    expect(find.textContaining('ICA'), findsWidgets);
  });

  testWidgets('sin advertencia, no aparece el aviso naranja', (tester) async {
    await montar(tester);
    await tester.tap(find.byKey(const Key('nota_bpa_abrir')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.info_outline), findsNothing);
  });

  testWidgets('con advertencia, el aviso sale al abrirla', (tester) async {
    await montar(tester, ojo: 'Falta el periodo de carencia');
    await tester.tap(find.byKey(const Key('nota_bpa_abrir')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.text('Falta el periodo de carencia'), findsOneWidget);
  });
}
