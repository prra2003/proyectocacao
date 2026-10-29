import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/ui/costo_por_kilo_screen.dart';
import 'package:cacao_app/ui/tema.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

/// La pantalla de costo por kilo no solo muestra la cuenta: desde ahí se
/// anotan y se corrigen los gastos que la componen. Lo que se prueba aquí es
/// que eso de verdad escriba en la base, y que un gasto que la aplicación no
/// tiene en su lista no pueda quedar guardado sin nombre.
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
        home: CostoPorKiloScreen(
          repo: repo,
          lote: lote,
          nombreFinca: 'El Porvenir',
        ),
      ),
    );
    await asentar(tester);
  }

  /// Una labor de hoy, para que caiga dentro del período que la pantalla
  /// abre por defecto (el año en curso) y siga dentro de la semana que hay
  /// para corregirla.
  Future<String> anotarLabor({
    required TipoActividad tipo,
    double? costo,
    String? observaciones,
  }) {
    return repo.registrarActividad(
      loteId: lote.id,
      tipo: tipo,
      fecha: DateTime.now(),
      costo: costo,
      observaciones: observaciones,
    );
  }

  testWidgets('sin nada anotado, lo dice en vez de mostrar una lista vacía', (
    tester,
  ) async {
    await abrir(tester);

    expect(find.byKey(const Key('sin_gastos')), findsOneWidget);
    expect(find.byKey(const Key('agregar_gasto')), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('cada gasto sale con su valor, y el que no tiene lo confiesa', (
    tester,
  ) async {
    await anotarLabor(tipo: TipoActividad.poda, costo: 400000);
    await anotarLabor(tipo: TipoActividad.riego);
    await abrir(tester);

    expect(find.text(r'$400.000'), findsWidgets);
    expect(
      find.text('Sin costo'),
      findsOneWidget,
      reason: 'Un gasto sin valor tiene que verse, porque es justamente el '
          'que hace que el total vaya por debajo de lo real.',
    );

    await desmontar(tester);
  });

  testWidgets('un gasto que no está en la lista no se guarda sin nombre', (
    tester,
  ) async {
    await abrir(tester);

    await tester.tap(find.byKey(const Key('agregar_gasto')));
    await asentar(tester);
    await tester.tap(find.text('Otra labor'));
    await asentar(tester);

    // El campo sale arriba, no escondido en los detalles opcionales.
    expect(find.byKey(const Key('campo_que_fue')), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Registrar'));
    await asentar(tester);

    expect(
      find.text('Escriba qué fue para poder guardarlo.'),
      findsOneWidget,
      reason: 'Guardarlo como "Otra labor" a secas deja un gasto que dentro '
          'de un año nadie sabrá qué fue.',
    );
    expect(
      find.text('Registrar labor'),
      findsOneWidget,
      reason: 'El formulario tiene que seguir abierto, con lo escrito.',
    );

    await desmontar(tester);
  });

  testWidgets('con el nombre puesto, el gasto queda anotado y se ve así', (
    tester,
  ) async {
    await abrir(tester);

    await tester.tap(find.byKey(const Key('agregar_gasto')));
    await asentar(tester);
    await tester.tap(find.text('Otra labor'));
    await asentar(tester);
    await tester.enterText(
      find.byKey(const Key('campo_que_fue')),
      'Transporte del bulto',
    );
    await tester.tap(find.byKey(const Key('boton_mas_detalles')));
    await asentar(tester);
    await tester.enterText(find.byKey(const Key('campo_costo')), '150000');
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar'));
    await asentar(tester);

    final guardadas = await conAsync(
      tester,
      () => repo.watchActividades(lote.id).first,
    );
    expect(guardadas, hasLength(1));
    expect(guardadas.single.tipoActividad, TipoActividad.otro);
    expect(guardadas.single.observaciones, 'Transporte del bulto');
    expect(guardadas.single.costo, 150000);

    await asentar(tester);
    expect(
      find.text('Transporte del bulto'),
      findsWidgets,
      reason: 'En la lista va el nombre que el productor le puso, no '
          '"Otra labor".',
    );

    await desmontar(tester);
  });

  testWidgets('tocar un gasto abre su formulario y guarda el valor corregido', (
    tester,
  ) async {
    final id = await anotarLabor(tipo: TipoActividad.poda, costo: 400000);
    await abrir(tester);

    await tester.tap(find.byKey(Key('gasto_$id')));
    await asentar(tester);

    // Abre lleno: el costo que ya tenía está ahí, no en blanco.
    expect(find.text('400000'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('campo_costo')), '500000');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await asentar(tester);

    final guardadas = await conAsync(
      tester,
      () => repo.watchActividades(lote.id).first,
    );
    expect(guardadas.single.costo, 500000);

    await desmontar(tester);
  });
  testWidgets('pasada la semana, el gasto se ve cerrado y no se abre', (
    tester,
  ) async {
    final id = await anotarLabor(tipo: TipoActividad.poda, costo: 400000);
    // La labor se cierra contando desde el día en que se anotó, así que para
    // probarlo hay que envejecerla: es lo único que la pantalla mira.
    await db.customStatement(
      'UPDATE actividades_agricolas SET created_at = ? WHERE id = ?',
      [
        DateTime.now()
            .subtract(const Duration(days: 20))
            .millisecondsSinceEpoch ~/
            1000,
        id,
      ],
    );
    await abrir(tester);

    expect(find.textContaining('cerrada'), findsOneWidget);

    await tester.tap(find.byKey(Key('gasto_$id')));
    await asentar(tester);

    expect(
      find.text('Esta labor ya se cerró'),
      findsOneWidget,
      reason: 'Dejarlo abrir el formulario y escribir, para después no '
          'guardar nada, sería peor que no dejarlo entrar.',
    );
    expect(find.text('Corregir labor'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Entendido'));
    await asentar(tester);

    await desmontar(tester);
  });
}
