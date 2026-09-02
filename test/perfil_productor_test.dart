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
  late LoteRepository lotesRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = PerfilRepository(db, usuarioId: await db.syncDao.identidadLocal());
    lotesRepo = LoteRepository(db);
  });
  tearDown(() => db.close());

  Future<void> abrirApp(WidgetTester tester) async {
    pantallaAlta(tester);
    await tester.pumpWidget(
      CacaoApp(
        repo: repo,
        lotesRepo: lotesRepo,
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

  testWidgets('el perfil se completa en cascada: productor, finca y lote',
      (tester) async {
    await abrirApp(tester);

    // Sin perfil, lo primero es la bienvenida y el registro.
    expect(find.text('Red Nacional de Cacao'), findsOneWidget);

    await tester.tap(find.text('Comenzar registro'));
    await asentar(tester);
    await tester.enterText(
      find.byKey(const Key('campo_nombre_productor')),
      'Diego Parra',
    );
    await tester.enterText(
      find.byKey(const Key('campo_telefono')),
      '3001234567',
    );
    expect(find.text('Paso 1 de 2'), findsOneWidget);
    await tester.tap(find.text('Crear perfil'));
    await asentar(tester);

    // El registro encadena: el segundo paso se abre solo.
    expect(find.text('Paso 2 de 2'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('campo_nombre_finca')),
      'La Esperanza',
    );
    await tester.enterText(
      find.byKey(const Key('campo_municipio')),
      'San Vicente de Chucurí',
    );
    await tester.enterText(
      find.byKey(const Key('campo_departamento')),
      'Santander',
    );
    await tester.enterText(find.byKey(const Key('campo_latitud')), '6.8809');
    await tester.enterText(find.byKey(const Key('campo_longitud')), '-73.4118');
    await tester.tap(find.text('Registrar finca').last);
    await asentar(tester);

    // La cabecera del inicio: nombre de la finca y municipio.
    expect(find.text('La Esperanza'), findsOneWidget);
    expect(find.text('San Vicente de Chucurí'), findsOneWidget);
    expect(find.text('Sin lotes todavía'), findsOneWidget);

    // El lote se crea por el repositorio: el selector de fecha ya lo cubre
    // la prueba del diálogo.
    final finca = await conAsync(
      tester,
      () async {
        final productor = await repo.watchProductor().first;
        return repo.watchFinca(productor!.id).first;
      },
    );
    await conAsync(
      tester,
      () => repo.guardarLote(
        fincaId: finca!.id,
        nombre: 'Lote 1',
        areaSembradaHa: 2.5,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020, 3, 15),
      ),
    );
    await asentar(tester);

    expect(find.text('Lote 1'), findsOneWidget);
    expect(find.textContaining('CCN-51 · 2.5 ha'), findsOneWidget);
    // Lo que se ve sin entrar al lote.
    expect(find.text('Sin labores anotadas'), findsOneWidget);
    expect(find.textContaining('Sin cosechas en'), findsOneWidget);
    // Indicadores de la finca: 1 lote y 2.5 hectáreas.
    expect(find.text('2.5'), findsOneWidget);
    expect(find.text('hectáreas'), findsOneWidget);

    // Y los datos de identidad están en la pestaña de perfil.
    await tester.tap(find.text('Perfil'));
    await asentar(tester);
    expect(find.text('Diego Parra'), findsOneWidget);
    expect(find.text('3001234567'), findsOneWidget);
    expect(find.text('San Vicente de Chucurí, Santander'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('con perfil pero sin finca, el inicio lleva a registrarla',
      (tester) async {
    await conAsync(
      tester,
      () => repo.guardarProductor(nombreCompleto: 'Diego Parra'),
    );
    await abrirApp(tester);

    expect(find.text('Registre su finca'), findsOneWidget);

    await tester.tap(find.text('Registrar finca'));
    await asentar(tester);

    // Y la ubicación se puede marcar en el mapa, no solo escribir.
    expect(find.text('Marcar en el mapa'), findsOneWidget);
    expect(find.byKey(const Key('campo_latitud')), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('la coordenada fuera de rango no deja guardar la finca',
      (tester) async {
    await conAsync(
      tester,
      () => repo.guardarProductor(nombreCompleto: 'Diego Parra'),
    );
    await abrirApp(tester);

    await tester.tap(find.text('Registrar finca'));
    await asentar(tester);
    await tester.enterText(
      find.byKey(const Key('campo_nombre_finca')),
      'La Esperanza',
    );
    await tester.enterText(
      find.byKey(const Key('campo_municipio')),
      'Rionegro',
    );
    await tester.enterText(
      find.byKey(const Key('campo_departamento')),
      'Santander',
    );
    await tester.enterText(find.byKey(const Key('campo_latitud')), '200');
    await tester.tap(find.text('Registrar finca').last);
    await asentar(tester);

    expect(find.text('La latitud va de -90.0 a 90.0'), findsOneWidget);
    final finca = await conAsync(tester, () async {
      final productor = await repo.watchProductor().first;
      return repo.watchFinca(productor!.id).first;
    });
    expect(finca, isNull);

    await desmontar(tester);
  });

  test('la producción anual suma solo las cosechas del año pedido', () async {
    final productorId = await repo.guardarProductor(nombreCompleto: 'Diego');
    final fincaId = await repo.guardarFinca(
      productorId: productorId,
      nombre: 'La Esperanza',
      municipio: 'Rionegro',
      departamento: 'Santander',
    );
    final loteId = await repo.guardarLote(
      fincaId: fincaId,
      nombre: 'Lote 1',
      areaSembradaHa: 2,
      variedadCacao: 'ICS-95',
      fechaSiembra: DateTime(2019, 1, 1),
    );

    await db.registrosDao.registrarCosecha(
      loteId: loteId,
      fecha: DateTime(2026, 3, 1),
      cantidadKg: 120,
    );
    await db.registrosDao.registrarCosecha(
      loteId: loteId,
      fecha: DateTime(2026, 8, 1),
      cantidadKg: 80.5,
    );
    await db.registrosDao.registrarCosecha(
      loteId: loteId,
      fecha: DateTime(2025, 12, 20),
      cantidadKg: 999,
    );

    expect(await repo.produccionAnual(fincaId, 2026), 200.5);
    expect(await repo.watchProduccionAnual(fincaId, 2026).first, 200.5);
  });

  test('la edad del cultivo se calcula, no se guarda', () {
    expect(
      PerfilRepository.edadEnAnios(
        DateTime(2020, 3, 15),
        hoy: DateTime(2026, 8, 30),
      ),
      6,
    );
    // Un día antes de cumplir años todavía no suma el año.
    expect(
      PerfilRepository.edadEnAnios(
        DateTime(2020, 9, 1),
        hoy: DateTime(2026, 8, 31),
      ),
      5,
    );
  });

  test('un lote borrado desaparece de la lista pero queda en la base',
      () async {
    final productorId = await repo.guardarProductor(nombreCompleto: 'Diego');
    final fincaId = await repo.guardarFinca(
      productorId: productorId,
      nombre: 'La Esperanza',
      municipio: 'Rionegro',
      departamento: 'Santander',
    );
    final loteId = await repo.guardarLote(
      fincaId: fincaId,
      nombre: 'Lote 1',
      areaSembradaHa: 2,
      variedadCacao: 'ICS-95',
      fechaSiembra: DateTime(2019, 1, 1),
    );

    await repo.borrarLote(loteId);

    expect(await repo.watchLotes(fincaId).first, isEmpty);
    expect(await db.select(db.lotes).get(), hasLength(1));
  });
}
