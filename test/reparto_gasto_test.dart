import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/ui/dialogos/dialogo_actividad.dart';
import 'package:cacao_app/ui/tema.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

/// Un gasto puede ser de varios lotes a la vez: una fertilización de siete
/// bultos para toda la finca no es un gasto de un lote.
///
/// Si se anota completo en uno, el costo por kilo de ese lote sale inflado y
/// el de los demás sale regalado —el número sale al revés de la realidad, y
/// con él se decide si el lote se renueva—. Lo que se prueba aquí es que el
/// reparto por hectáreas se guarde bien y que lo pagado completo no se
/// pierda.
void main() {
  late AppDatabase db;
  late PerfilRepository perfil;
  late LoteRepository repo;
  late String fincaId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    perfil = PerfilRepository(db, usuarioId: await db.syncDao.identidadLocal());
    repo = LoteRepository(db);

    final productorId = await perfil.guardarProductor(nombreCompleto: 'Diego');
    fincaId = await perfil.guardarFinca(
      productorId: productorId,
      nombre: 'El Porvenir',
      municipio: 'Calarcá',
      departamento: 'Quindío',
    );
  });
  tearDown(() => db.close());

  Future<Lote> nuevoLote(String nombre, double hectareas) async {
    final id = await perfil.guardarLote(
      fincaId: fincaId,
      nombre: nombre,
      areaSembradaHa: hectareas,
      variedadCacao: 'Criollo',
      fechaSiembra: DateTime(2018, 5, 2),
    );
    return (await perfil.watchLotes(fincaId).first).firstWhere(
      (l) => l.id == id,
    );
  }

  /// Abre el formulario de labor sobre [lote] y devuelve lo que se guarde.
  Future<void> abrirFormulario(
    WidgetTester tester,
    Lote lote, {
    ActividadAgricola? corrigiendo,
  }) async {
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
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                key: const Key('abrir'),
                onPressed: () async {
                  final reparto = await repartoDelGasto(repo, lote);
                  if (!context.mounted) return;
                  final datos = await pedirDatosActividad(
                    context,
                    loteNombre: lote.nombre,
                    reparto: reparto,
                    inicial: corrigiendo == null
                        ? null
                        : datosDeLabor(corrigiendo),
                  );
                  if (datos == null) return;
                  if (corrigiendo == null) {
                    await guardarLabor(repo, lote, datos);
                  } else {
                    await actualizarLabor(repo, corrigiendo, datos);
                  }
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await asentar(tester);
    await tester.tap(find.byKey(const Key('abrir')));
    await asentar(tester);
  }

  // ---- la cuenta de las hectáreas --------------------------------------

  test('con un solo lote no hay nada que repartir', () async {
    final unico = await nuevoLote('La Quebrada', 3.2);

    expect(await repartoDelGasto(repo, unico), isNull);
  });

  test('con dos lotes, el reparto sale de las hectáreas de los dos', () async {
    final quebrada = await nuevoLote('La Quebrada', 3.2);
    await nuevoLote('El Alto', 3.0);

    final reparto = await repartoDelGasto(repo, quebrada);

    expect(reparto, isNotNull);
    expect(reparto!.hectareasLote, 3.2);
    expect(reparto.hectareasFinca, closeTo(6.2, 0.001));
    expect(reparto.lotesDeLaFinca, 2);
  });

  test('un lote sin área no reparte: dividir por cero no es repartir', () async {
    final sinArea = await nuevoLote('Sin medir', 0);
    await nuevoLote('El Alto', 3.0);

    expect(await repartoDelGasto(repo, sinArea), isNull);
  });

  // ---- la pregunta en el formulario ------------------------------------

  testWidgets('con un solo lote, no se pregunta por el reparto', (
    tester,
  ) async {
    final unico = await conAsync(tester, () => nuevoLote('La Quebrada', 3.2));
    await abrirFormulario(tester, unico);

    await tester.tap(find.byKey(const Key('boton_mas_detalles')));
    await asentar(tester);

    expect(
      find.byKey(const Key('gasto_de_toda_la_finca')),
      findsNothing,
      reason: 'Preguntarle por el reparto a quien tiene un solo lote es una '
          'pregunta de más para la mayoría de los productores.',
    );

    await desmontar(tester);
  });

  testWidgets('marcado como de toda la finca, guarda la parte del lote y no '
      'pierde lo pagado', (tester) async {
    final quebrada = await conAsync(
      tester,
      () => nuevoLote('La Quebrada', 3.2),
    );
    await conAsync(tester, () => nuevoLote('El Alto', 3.0));
    await abrirFormulario(tester, quebrada);

    await tester.tap(find.text('Abonar'));
    await asentar(tester);
    await tester.tap(find.byKey(const Key('boton_mas_detalles')));
    await asentar(tester);
    await tester.enterText(find.byKey(const Key('campo_costo')), '700000');
    await asentar(tester);
    await tester.tap(find.byKey(const Key('gasto_de_toda_la_finca')));
    await asentar(tester);

    // La cuenta se le muestra antes de guardar, para que la apruebe.
    expect(find.textContaining(r'a este lote le tocan $361.290'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Registrar'));
    await asentar(tester);

    final guardada = await conAsync(
      tester,
      () => repo.watchActividades(quebrada.id).first,
    );
    expect(guardada, hasLength(1));
    expect(
      guardada.single.costo,
      361290,
      reason: '3,2 de 6,2 hectáreas de los \$700.000. Es lo que suman las '
          'cuentas de este lote.',
    );
    expect(
      guardada.single.costoTotalCompartido,
      700000,
      reason: 'Lo pagado de verdad no se pierde: la parte del lote es un '
          'número derivado de ello, no el gasto mutilado.',
    );

    await desmontar(tester);
  });

  testWidgets('sin marcar, el costo es todo de este lote, como siempre', (
    tester,
  ) async {
    final quebrada = await conAsync(
      tester,
      () => nuevoLote('La Quebrada', 3.2),
    );
    await conAsync(tester, () => nuevoLote('El Alto', 3.0));
    await abrirFormulario(tester, quebrada);

    await tester.tap(find.byKey(const Key('boton_mas_detalles')));
    await asentar(tester);
    await tester.enterText(find.byKey(const Key('campo_costo')), '400000');
    await asentar(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar'));
    await asentar(tester);

    final guardada = await conAsync(
      tester,
      () => repo.watchActividades(quebrada.id).first,
    );
    expect(guardada.single.costo, 400000);
    expect(guardada.single.costoTotalCompartido, isNull);

    await desmontar(tester);
  });

  testWidgets('al volver a abrir un gasto compartido se ve lo que pagó, no la '
      'parte repartida', (tester) async {
    final quebrada = await conAsync(
      tester,
      () => nuevoLote('La Quebrada', 3.2),
    );
    await conAsync(tester, () => nuevoLote('El Alto', 3.0));
    await conAsync(
      tester,
      () => repo.registrarActividad(
        loteId: quebrada.id,
        tipo: TipoActividad.fertilizacion,
        fecha: DateTime.now(),
        costo: 361290,
        costoTotalCompartido: 700000,
      ),
    );
    final labor = (await conAsync(
      tester,
      () => repo.watchActividades(quebrada.id).first,
    )).single;

    await abrirFormulario(tester, quebrada, corrigiendo: labor);

    expect(
      find.text('700.000'),
      findsOneWidget,
      reason: 'Es lo que la persona recuerda haber pagado. Mostrarle los '
          '\$361.290 repartidos la haría pensar que el dato quedó mal.',
    );
    expect(find.textContaining(r'a este lote le tocan $361.290'), findsOneWidget);

    await desmontar(tester);
  });
}
