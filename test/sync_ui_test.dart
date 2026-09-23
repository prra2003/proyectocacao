import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/sync_service.dart';
import 'package:cacao_app/main.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

void main() {
  late AppDatabase db;
  late PerfilRepository repo;
  late ApiRemotaFalsa api;
  late SyncService sync;
  late String fincaId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final usuarioId = await db.syncDao.identidadLocal();
    repo = PerfilRepository(db, usuarioId: usuarioId);
    api = ApiRemotaFalsa();
    sync = SyncService(baseDatos: db, apiRemota: api, usuarioLocal: usuarioId);
    // La cinta solo tiene algo que contar cuando hay cuenta: sin ella no hay
    // servidor a donde enviar.
    await sync.entrarConGoogle();

    final productorId = await repo.guardarProductor(
      nombreCompleto: 'Diego Parra',
    );
    fincaId = await repo.guardarFinca(
      productorId: productorId,
      nombre: 'La Esperanza',
      municipio: 'Rionegro',
      departamento: 'Santander',
    );
  });
  tearDown(() => db.close());

  Future<void> abrirApp(WidgetTester tester) async {
    pantallaAlta(tester);
    await tester.pumpWidget(
      CacaoApp(repo: repo, lotesRepo: LoteRepository(db), db: db, sync: sync),
    );
    await asentar(tester);
  }

  testWidgets('al abrir, la app sincroniza sola y la cinta lo dice', (
    tester,
  ) async {
    await abrirApp(tester);

    // El productor y la finca ya subieron sin que nadie tocara nada.
    expect(find.text('Todo guardado y enviado'), findsOneWidget);
    expect(api.filasDe('fincas'), hasLength(1));

    await desmontar(tester);
  });

  testWidgets('lo que se anota sin señal queda contado y se envía al tocar', (
    tester,
  ) async {
    await abrirApp(tester);

    // Se anota algo nuevo: la cinta lo cuenta al instante.
    await conAsync(
      tester,
      () => repo.guardarLote(
        fincaId: fincaId,
        nombre: 'Lote 1',
        areaSembradaHa: 2,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020),
      ),
    );
    await asentar(tester);

    expect(find.text('1 cambio sin enviar'), findsOneWidget);
    expect(api.filasDe('lotes'), isEmpty);

    await tester.tap(find.text('1 cambio sin enviar'));
    await asentar(tester);

    expect(find.text('Todo guardado y enviado'), findsOneWidget);
    expect(api.filasDe('lotes'), hasLength(1));

    await desmontar(tester);
  });

  testWidgets('si la sincronización falla, lo anotado sigue contado', (
    tester,
  ) async {
    await abrirApp(tester);
    await conAsync(
      tester,
      () => repo.guardarLote(
        fincaId: fincaId,
        nombre: 'Lote 1',
        areaSembradaHa: 2,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020),
      ),
    );
    await asentar(tester);
    api.fallosProgramados = 1;

    await tester.tap(find.text('1 cambio sin enviar'));
    await asentar(tester);

    // Nada se pierde: sigue guardado aquí y pendiente de mandar.
    expect(find.text('1 cambio sin enviar'), findsOneWidget);
    expect(api.filasDe('lotes'), isEmpty);

    await desmontar(tester);
  });
}
