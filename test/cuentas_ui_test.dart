import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/sync_service.dart';
import 'package:cacao_app/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

void main() {
  late AppDatabase db;
  late PerfilRepository repo;
  late ApiRemotaFalsa api;
  late SyncService sync;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final usuarioId = await db.syncDao.identidadLocal();
    repo = PerfilRepository(db, usuarioId: usuarioId);
    api = ApiRemotaFalsa();
    sync = SyncService(baseDatos: db, apiRemota: api, usuarioLocal: usuarioId);
  });
  tearDown(() => db.close());

  Future<void> abrirApp(WidgetTester tester) async {
    pantallaAlta(tester);
    await tester.pumpWidget(
      CacaoApp(
        repo: repo,
        lotesRepo: LoteRepository(db),
        db: db,
        sync: sync,
      ),
    );
    await asentar(tester);
  }

  testWidgets('la bienvenida ofrece entrar con una cuenta ya existente',
      (tester) async {
    await abrirApp(tester);

    expect(find.text('Comenzar registro'), findsOneWidget);
    expect(find.text('Ya tengo cuenta'), findsOneWidget);

    await tester.tap(find.text('Ya tengo cuenta'));
    await asentar(tester);

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byKey(const Key('campo_correo')), findsOneWidget);

    // Con datos que no existen, avisa y no deja pasar.
    await tester.enterText(
      find.byKey(const Key('campo_correo')),
      'nadie@finca.co',
    );
    await tester.enterText(find.byKey(const Key('campo_clave')), 'cacao1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await asentar(tester);

    expect(find.text('correo o contraseña incorrectos'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('si la descarga de la cuenta falla, el registro sigue bloqueado',
      (tester) async {
    // Estado de "entré con una cuenta y la descarga no ha terminado".
    await db.syncDao.empezarDescargaInicial();
    // Y sin red, para que el intento automático del arranque no la termine.
    api.fallosProgramados = 5;
    await abrirApp(tester);

    // Lo importante: no hay puerta al registro mientras no sepamos si esa
    // cuenta ya tenía datos.
    expect(find.text('Comenzar registro'), findsNothing);
    expect(find.text('No se pudieron recuperar sus datos'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Reintentar'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('cuando la descarga termina bien, el bloqueo se levanta',
      (tester) async {
    await db.syncDao.empezarDescargaInicial();
    await abrirApp(tester);

    // El intento automático del arranque completó la descarga: la cuenta no
    // tenía datos, así que ahora sí se puede registrar.
    expect((await db.syncDao.sesionActual())!.descargaInicial, isTrue);
    expect(find.text('Comenzar registro'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('desde el perfil se crea la cuenta y queda a la vista',
      (tester) async {
    final productorId = await repo.guardarProductor(
      nombreCompleto: 'Diego Parra',
    );
    await repo.guardarFinca(
      productorId: productorId,
      nombre: 'La Esperanza',
      municipio: 'Rionegro',
      departamento: 'Santander',
    );
    await abrirApp(tester);

    await tester.tap(find.text('Perfil'));
    await asentar(tester);
    expect(find.text('Sin cuenta'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await asentar(tester);

    await tester.enterText(
      find.byKey(const Key('campo_correo')),
      'diego@finca.co',
    );
    await tester.enterText(find.byKey(const Key('campo_clave')), 'cacao1234');
    await tester.enterText(
      find.byKey(const Key('campo_confirmacion')),
      'cacao1234',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await asentar(tester);

    // De vuelta en el perfil, con la cuenta ya vinculada.
    expect(find.text('diego@finca.co'), findsOneWidget);
    expect(find.text('Sin cuenta'), findsNothing);
    expect(api.correo, 'diego@finca.co');

    await desmontar(tester);
  });

  testWidgets('las contraseñas distintas no dejan crear la cuenta',
      (tester) async {
    await repo.guardarProductor(nombreCompleto: 'Diego Parra');
    await abrirApp(tester);

    await tester.tap(find.text('Perfil'));
    await asentar(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await asentar(tester);

    await tester.enterText(
      find.byKey(const Key('campo_correo')),
      'diego@finca.co',
    );
    await tester.enterText(find.byKey(const Key('campo_clave')), 'cacao1234');
    await tester.enterText(
      find.byKey(const Key('campo_confirmacion')),
      'otraClave',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await asentar(tester);

    expect(find.text('Las contraseñas no son iguales'), findsOneWidget);
    expect(api.correo, isNull);

    await desmontar(tester);
  });

  testWidgets('una contraseña débil no deja crear la cuenta', (tester) async {
    await repo.guardarProductor(nombreCompleto: 'Diego Parra');
    await abrirApp(tester);

    await tester.tap(find.text('Perfil'));
    await asentar(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await asentar(tester);

    await tester.enterText(
      find.byKey(const Key('campo_correo')),
      'diego@finca.co',
    );
    // Menos de 8 caracteres.
    await tester.enterText(find.byKey(const Key('campo_clave')), 'cacao1');
    await tester.enterText(
      find.byKey(const Key('campo_confirmacion')),
      'cacao1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await asentar(tester);

    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    expect(api.correo, isNull);

    // Ocho caracteres, pero solo letras: sigue sin dejar pasar.
    await tester.enterText(
      find.byKey(const Key('campo_clave')),
      'cacaocacao',
    );
    await tester.enterText(
      find.byKey(const Key('campo_confirmacion')),
      'cacaocacao',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await asentar(tester);

    expect(find.text('Use letras y números'), findsOneWidget);
    expect(api.correo, isNull);

    await desmontar(tester);
  });
}
