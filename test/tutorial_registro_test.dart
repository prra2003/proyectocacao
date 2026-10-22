import 'dart:io';

import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/sync_service.dart';
import 'package:cacao_app/main.dart';
import 'package:cacao_app/ui/tutorial_registro_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

void main() {
  late AppDatabase db;
  late PerfilRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = PerfilRepository(db, usuarioId: await db.syncDao.identidadLocal());
  });
  tearDown(() => db.close());

  Future<void> abrirApp(WidgetTester tester) async {
    pantallaAlta(tester);
    await tester.pumpWidget(
      CacaoApp(
        repo: repo,
        lotesRepo: LoteRepository(db),
        db: db,
        sync: SyncService(
          baseDatos: db,
          apiRemota: ApiRemotaFalsa(),
          usuarioLocal: repo.usuarioId,
        ),
      ),
    );
    await asentar(tester);
  }

  test('el video está empaquetado en la app, para verse sin internet', () {
    final archivo = File(rutaVideoTutorialRegistro);
    expect(archivo.existsSync(), isTrue, reason: 'falta ${archivo.path}');
    expect(archivo.lengthSync(), greaterThan(1024 * 1024));

    // pubspec.yaml tiene que declarar la carpeta, o el video queda fuera del
    // APK y del sitio aunque el archivo exista en el repositorio.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- assets/'));
  });

  testWidgets('la bienvenida ofrece el tutorial y lo abre', (tester) async {
    await abrirApp(tester);

    expect(find.text('Ver tutorial'), findsOneWidget);
    await tester.tap(find.text('Ver tutorial'));
    await asentar(tester);

    expect(find.text('Cómo registrarse'), findsOneWidget);
    expect(find.byType(TutorialRegistroScreen), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('si el video no se puede reproducir, lo dice y deja reintentar', (
    tester,
  ) async {
    await abrirApp(tester);
    await tester.tap(find.text('Ver tutorial'));
    await asentar(tester);

    // En las pruebas no hay reproductor de video: es justo el caso de un
    // dispositivo que no puede abrirlo.
    expect(find.text('No se pudo reproducir el video'), findsOneWidget);
    expect(find.text('Intentar de nuevo'), findsOneWidget);
    // Y no deja a la persona sin salida: registrarse sigue siendo posible.
    expect(find.textContaining('Puede registrarse igual'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('el tutorial también está en los dos pasos del registro', (
    tester,
  ) async {
    await abrirApp(tester);
    await tester.tap(find.text('Comenzar registro'));
    await asentar(tester);

    expect(find.text('Paso 1 de 2'), findsOneWidget);
    expect(find.byTooltip('Ver tutorial'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('al editar los datos ya no aparece el tutorial', (tester) async {
    await conAsync(
      tester,
      () => repo.guardarProductor(nombreCompleto: 'Diego Parra'),
    );
    await abrirApp(tester);

    await tester.tap(find.text('Perfil'));
    await asentar(tester);
    await tester.tap(find.text('Editar mis datos'));
    await asentar(tester);

    expect(find.text('Editar mis datos'), findsWidgets);
    expect(find.byTooltip('Ver tutorial'), findsNothing);

    await desmontar(tester);
  });
}
