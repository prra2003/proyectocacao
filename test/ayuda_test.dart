import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/sync_service.dart';
import 'package:cacao_app/main.dart';
import 'package:cacao_app/ui/ayuda_screen.dart';
import 'package:cacao_app/ui/tutorial_registro_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

void main() {
  test('cada video del canal tiene un enlace de YouTube propio', () {
    expect(videosDeAyuda, hasLength(4));
    final ids = videosDeAyuda.map((v) => v.id).toSet();
    expect(ids, hasLength(videosDeAyuda.length), reason: 'ids repetidos');
    for (final video in videosDeAyuda) {
      expect(video.id, matches(RegExp(r'^[\w-]{11}$')));
      expect(video.enlace.host, 'www.youtube.com');
      expect(video.enlace.queryParameters['v'], video.id);
    }
    expect(canalCacaiva.toString(), contains('youtube.com/channel/'));
  });

  testWidgets('la ayuda lista los videos y abre cada uno en YouTube', (
    tester,
  ) async {
    // La lista es larga: con la pantalla de prueba normal los últimos videos
    // quedarían fuera de la vista y la lista perezosa ni los construiría.
    pantallaAlta(tester);
    final abiertos = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: AyudaScreen(
          abrirEnlace: (enlace) async {
            abiertos.add(enlace);
            return true;
          },
        ),
      ),
    );
    await asentar(tester);

    expect(find.text('Cómo registrarse'), findsOneWidget);
    expect(find.text('Se ve sin internet'), findsOneWidget);
    for (final video in videosDeAyuda) {
      expect(find.text(video.titulo), findsOneWidget);
    }

    await tester.tap(find.text('Registro de lotes'));
    await asentar(tester);
    expect(abiertos, [videosDeAyuda.first.enlace]);

    await tester.tap(find.text('Ver todos los videos de Cacaiva'));
    await asentar(tester);
    expect(abiertos.last, canalCacaiva);

    await desmontar(tester);
  });

  testWidgets('si el video no se puede abrir, lo dice', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AyudaScreen(abrirEnlace: (_) async => false)),
    );
    await asentar(tester);

    await tester.tap(find.text('Menú de reportes'));
    await asentar(tester);

    expect(find.textContaining('No se pudo abrir el video'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('el de registro se abre dentro de la app, sin internet', (
    tester,
  ) async {
    var llamadas = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AyudaScreen(
          abrirEnlace: (_) async {
            llamadas++;
            return true;
          },
        ),
      ),
    );
    await asentar(tester);

    await tester.tap(find.text('Cómo registrarse'));
    await asentar(tester);

    expect(find.byType(TutorialRegistroScreen), findsOneWidget);
    expect(llamadas, 0);

    await desmontar(tester);
  });

  testWidgets('Perfil tiene la tarjeta que lleva a la ayuda', (tester) async {
    pantallaAlta(tester);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = PerfilRepository(
      db,
      usuarioId: await db.syncDao.identidadLocal(),
    );
    await conAsync(
      tester,
      () => repo.guardarProductor(nombreCompleto: 'Diego Parra'),
    );
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

    await tester.tap(find.text('Perfil'));
    await asentar(tester);
    expect(find.text('Ayuda'), findsOneWidget);

    await tester.tap(find.text('Ayuda'));
    await asentar(tester);
    expect(find.byType(AyudaScreen), findsOneWidget);

    await desmontar(tester);
  });
}
