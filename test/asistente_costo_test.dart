import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/ui/asistente_costo_screen.dart';
import 'package:cacao_app/ui/tema.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

/// El asistente es para quien nunca ha sacado la cuenta del costo por kilo:
/// una pregunta por pantalla, y en cada una lo que ya tiene anotado para que
/// no lo anote dos veces.
///
/// Lo que se prueba aquí es que el recorrido llegue de verdad hasta el
/// número, que lo ya anotado se le muestre en el paso que le corresponde, y
/// que al final no dé un número si falta un dato.
void main() {
  late AppDatabase db;
  late PerfilRepository perfil;
  late LoteRepository repo;
  late Lote lote;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    perfil = PerfilRepository(db, usuarioId: await db.syncDao.identidadLocal());
    repo = LoteRepository(db);

    final productorId = await perfil.guardarProductor(nombreCompleto: 'Diego');
    final fincaId = await perfil.guardarFinca(
      productorId: productorId,
      nombre: 'El Porvenir',
      municipio: 'Calarcá',
      departamento: 'Quindío',
    );
    final loteId = await perfil.guardarLote(
      fincaId: fincaId,
      nombre: 'La Quebrada',
      areaSembradaHa: 3.2,
      variedadCacao: 'Criollo',
      fechaSiembra: DateTime(2018, 5, 2),
    );
    lote = (await perfil.watchLotes(fincaId).first).firstWhere(
      (l) => l.id == loteId,
    );
  });
  tearDown(() => db.close());

  Future<void> abrir(WidgetTester tester) async {
    pantallaAlta(tester);
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
        home: AsistenteCostoScreen(repo: repo, lote: lote),
      ),
    );
    await asentar(tester);
  }

  Future<String> anotarCosecha({required double kg}) {
    return repo.registrarCosecha(
      loteId: lote.id,
      fecha: DateTime.now(),
      cantidadKg: kg,
      tipoProducto: 'Cacao seco',
    );
  }

  Future<String> anotarLabor({
    required TipoActividad tipo,
    double? costo,
  }) {
    return repo.registrarActividad(
      loteId: lote.id,
      tipo: tipo,
      fecha: DateTime.now(),
      costo: costo,
    );
  }

  /// Pasa los cinco pasos de gastos sin anotar nada nuevo.
  Future<void> pasarLosGastos(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const Key('asistente_seguir')));
      await asentar(tester);
    }
  }

  testWidgets('sin cosecha anotada, lo primero que pide es la cosecha', (
    tester,
  ) async {
    await abrir(tester);

    expect(find.text('Primero hay que anotar la cosecha'), findsOneWidget);
    expect(
      find.byKey(const Key('asistente_anotar_cosecha')),
      findsOneWidget,
      reason: 'No se le deja en un callejón: desde ahí mismo la anota.',
    );

    await desmontar(tester);
  });

  testWidgets('el recorrido completo llega hasta el número', (tester) async {
    final cosechaId = await anotarCosecha(kg: 100);
    await anotarLabor(tipo: TipoActividad.poda, costo: 400000);
    await abrir(tester);

    // Paso 1: escoger la cosecha, que sale con sus kilos.
    expect(find.text('¿De cuál cosecha quiere saber?'), findsOneWidget);
    expect(find.text('100 kg'), findsOneWidget);
    await tester.tap(find.byKey(Key('cosecha_$cosechaId')));
    await asentar(tester);

    // Paso 2: desde cuándo, con la respuesta más común ya escogida.
    expect(find.text('¿Desde cuándo trabajó para esa cosecha?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('asistente_seguir')));
    await asentar(tester);

    // Paso 3: el primer gasto, con lo que ya tiene anotado.
    expect(find.text('¿Pagó por podar este lote?'), findsOneWidget);
    expect(
      find.byKey(const Key('ya_tiene_anotados')),
      findsOneWidget,
      reason: 'Si no se le muestra lo que ya anotó, lo anota dos veces y la '
          'cuenta le sale al doble.',
    );
    expect(find.text(r'$400.000'), findsOneWidget);

    await pasarLosGastos(tester);

    // El trabajo que no deja recibo.
    expect(find.text('¿Trabajó usted o su familia sin cobrar?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('asistente_confirmar')));
    await asentar(tester);

    expect(find.byKey(const Key('asistente_resultado')), findsOneWidget);
    expect(find.text(r'$4.000'), findsOneWidget);
    expect(
      find.textContaining('÷ 100 kg'),
      findsOneWidget,
      reason: 'Se le muestra la cuenta, no solo el resultado.',
    );

    await desmontar(tester);
  });

  testWidgets('en el paso del abono no se le muestra la poda', (tester) async {
    final cosechaId = await anotarCosecha(kg: 100);
    await anotarLabor(tipo: TipoActividad.poda, costo: 400000);
    await abrir(tester);

    await tester.tap(find.byKey(Key('cosecha_$cosechaId')));
    await asentar(tester);
    await tester.tap(find.byKey(const Key('asistente_seguir')));
    await asentar(tester);
    // De poda a abono.
    await tester.tap(find.byKey(const Key('asistente_seguir')));
    await asentar(tester);

    expect(find.text('¿Abonó este lote?'), findsOneWidget);
    expect(
      find.byKey(const Key('nada_de_este_tipo')),
      findsOneWidget,
      reason: 'Cada paso pregunta por su propio gasto; mezclarlos haría que '
          'el productor crea que ya anotó el abono.',
    );

    await desmontar(tester);
  });

  testWidgets('si falta el valor de un gasto, al final no da número', (
    tester,
  ) async {
    final cosechaId = await anotarCosecha(kg: 100);
    await anotarLabor(tipo: TipoActividad.poda, costo: 400000);
    await anotarLabor(tipo: TipoActividad.riego);
    await abrir(tester);

    await tester.tap(find.byKey(Key('cosecha_$cosechaId')));
    await asentar(tester);
    await tester.tap(find.byKey(const Key('asistente_seguir')));
    await asentar(tester);
    await pasarLosGastos(tester);
    await tester.tap(find.byKey(const Key('asistente_confirmar')));
    await asentar(tester);

    expect(find.text('Todavía falta un dato'), findsOneWidget);
    expect(find.byKey(const Key('asistente_resultado')), findsNothing);
    expect(find.textContaining('Falta el costo de 1 labor'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('sin confirmar que no falta nada, el número sale provisional', (
    tester,
  ) async {
    final cosechaId = await anotarCosecha(kg: 100);
    await anotarLabor(tipo: TipoActividad.poda, costo: 400000);
    await abrir(tester);

    await tester.tap(find.byKey(Key('cosecha_$cosechaId')));
    await asentar(tester);
    await tester.tap(find.byKey(const Key('asistente_seguir')));
    await asentar(tester);
    await pasarLosGastos(tester);
    await tester.tap(find.byKey(const Key('asistente_sin_confirmar')));
    await asentar(tester);

    expect(find.text(r'$4.000'), findsOneWidget);
    expect(find.textContaining('Es provisional'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('un gasto anotado en el asistente aparece ahí mismo, aunque la '
      'cosecha sea vieja', (tester) async {
    // Una cosecha de hace dos meses: el caso corriente, porque uno saca la
    // cuenta después de vender, no el mismo día.
    final haceDosMeses = DateTime.now().subtract(const Duration(days: 60));
    final cosechaId = await repo.registrarCosecha(
      loteId: lote.id,
      fecha: haceDosMeses,
      cantidadKg: 100,
      tipoProducto: 'Cacao seco',
    );
    await abrir(tester);

    await tester.tap(find.byKey(Key('cosecha_$cosechaId')));
    await asentar(tester);
    await tester.tap(find.byKey(const Key('asistente_seguir')));
    await asentar(tester);

    // Paso de la poda: anotar una.
    await tester.tap(find.byKey(const Key('asistente_anotar_gasto')));
    await asentar(tester);
    await tester.tap(find.byKey(const Key('boton_mas_detalles')));
    await asentar(tester);
    await tester.enterText(find.byKey(const Key('campo_costo')), '400000');
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar'));
    await asentar(tester);

    expect(
      find.byKey(const Key('ya_tiene_anotados')),
      findsOneWidget,
      reason: 'Lo acaba de anotar aquí mismo, contestando esta pregunta: si '
          'no sale, parece que no se guardó y lo anota otra vez.',
    );
    expect(find.text(r'$400.000'), findsOneWidget);

    await desmontar(tester);
  });
}
