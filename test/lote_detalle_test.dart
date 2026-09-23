import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/ui/lote_detalle_screen.dart';
import 'package:cacao_app/ui/tema.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

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
      nombre: 'La Esperanza',
      municipio: 'Rionegro',
      departamento: 'Santander',
    );
    final loteId = await perfil.guardarLote(
      fincaId: fincaId,
      nombre: 'Lote 1',
      areaSembradaHa: 2.5,
      variedadCacao: 'CCN-51',
      fechaSiembra: DateTime(2020, 3, 15),
    );
    lote = (await perfil.watchLotes(fincaId).first).firstWhere(
      (l) => l.id == loteId,
    );
  });
  tearDown(() => db.close());

  Future<void> abrirLote(WidgetTester tester) async {
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
        home: LoteDetalleScreen(repo: repo, lote: lote),
      ),
    );
    await asentar(tester);
  }

  testWidgets('las dos pestañas arrancan vacías y explican para qué sirven', (
    tester,
  ) async {
    await abrirLote(tester);

    expect(find.text('CCN-51'), findsOneWidget);
    expect(find.text('2.5 ha'), findsOneWidget);
    expect(find.text('Sin labores registradas'), findsOneWidget);

    await tester.tap(find.text('Cosechas'));
    await asentar(tester);
    expect(find.text('Sin cosechas registradas'), findsOneWidget);

    await tester.tap(find.text('Estado'));
    await asentar(tester);
    expect(find.text('Sin diagnósticos'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('registrar un diagnóstico desde el diálogo lo deja en la lista', (
    tester,
  ) async {
    await abrirLote(tester);

    await tester.tap(find.text('Estado'));
    await asentar(tester);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Diagnóstico'));
    await asentar(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Maduración'));
    await asentar(tester);
    await tester.enterText(
      find.byKey(const Key('campo_notas_diagnostico')),
      'Mazorcas listas para corte',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await asentar(tester);

    expect(find.text('Maduración'), findsOneWidget);
    expect(find.textContaining('Mazorcas listas para corte'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('registrar una labor desde el diálogo la deja en la lista', (
    tester,
  ) async {
    await abrirLote(tester);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Labor'));
    await asentar(tester);

    // En el formulario la labor se llama como en el campo: "Abonar". En la
    // lista sale con su nombre técnico, "Fertilización".
    await tester.tap(find.text('Abonar'));
    await asentar(tester);
    // Las notas van dentro de "Agregar más detalles", que arranca cerrado.
    await tester.tap(find.byKey(const Key('boton_mas_detalles')));
    await asentar(tester);
    await tester.enterText(
      find.byKey(const Key('campo_observaciones_actividad')),
      'Abono orgánico, 2 kg por árbol',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar'));
    await asentar(tester);
    await asentar(tester);

    expect(find.text('Fertilización'), findsOneWidget);
    expect(
      find.textContaining('Abono orgánico, 2 kg por árbol'),
      findsOneWidget,
    );

    await desmontar(tester);
  });

  testWidgets('registrar una cosecha suma a la producción del año', (
    tester,
  ) async {
    await abrirLote(tester);

    await tester.tap(find.text('Cosechas'));
    await asentar(tester);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Cosecha'));
    await asentar(tester);

    await tester.enterText(find.byKey(const Key('campo_cantidad')), '125,5');
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar'));
    await asentar(tester);

    final anio = DateTime.now().year;
    expect(find.text('125.5 kg'), findsOneWidget);
    expect(find.text('Producción $anio: 125.5 kg'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('borrar el lote pide confirmación y se lleva sus registros', (
    tester,
  ) async {
    await conAsync(
      tester,
      () => repo.registrarCosecha(
        loteId: lote.id,
        fecha: DateTime(2026, 3, 1),
        cantidadKg: 20,
      ),
    );
    await abrirLote(tester);

    await tester.tap(find.byTooltip('Borrar lote'));
    await asentar(tester);
    expect(
      find.textContaining('Se borran también sus labores'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Borrar'));
    await asentar(tester);

    final lotesVivos = await conAsync(
      tester,
      () => perfil.watchLotes(lote.fincaId).first,
    );
    final cosechasVivas = await conAsync(
      tester,
      () => repo.watchCosechas(lote.id).first,
    );
    expect(lotesVivos, isEmpty);
    expect(cosechasVivas, isEmpty);

    await desmontar(tester);
  });

  test(
    'las labores y cosechas se listan de la más reciente a la más vieja',
    () async {
      await repo.registrarActividad(
        loteId: lote.id,
        tipo: TipoActividad.poda,
        fecha: DateTime(2026, 1, 10),
      );
      await repo.registrarActividad(
        loteId: lote.id,
        tipo: TipoActividad.riego,
        fecha: DateTime(2026, 5, 20),
      );

      final actividades = await repo.watchActividades(lote.id).first;
      expect(actividades.map((a) => a.tipoActividad), [
        TipoActividad.riego,
        TipoActividad.poda,
      ]);
    },
  );

  test(
    'la producción del año ignora otros años y las cosechas borradas',
    () async {
      await repo.registrarCosecha(
        loteId: lote.id,
        fecha: DateTime(2026, 3, 1),
        cantidadKg: 100,
      );
      final borrada = await repo.registrarCosecha(
        loteId: lote.id,
        fecha: DateTime(2026, 4, 1),
        cantidadKg: 50,
      );
      await repo.registrarCosecha(
        loteId: lote.id,
        fecha: DateTime(2025, 4, 1),
        cantidadKg: 999,
      );

      expect(await repo.watchKgDelAnio(lote.id, 2026).first, 150);

      await repo.borrarCosecha(borrada);

      expect(await repo.watchKgDelAnio(lote.id, 2026).first, 100);
      expect(await repo.watchCosechas(lote.id).first, hasLength(2));
    },
  );
}
