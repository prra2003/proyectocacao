import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PerfilRepository perfil;
  late LoteRepository lotes;
  late String productorId;
  late String fincaId;
  late String loteId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    perfil = PerfilRepository(db, usuarioId: await db.syncDao.identidadLocal());
    lotes = LoteRepository(db);

    productorId = await perfil.guardarProductor(nombreCompleto: 'Diego');
    fincaId = await perfil.guardarFinca(
      productorId: productorId,
      nombre: 'La Esperanza',
      municipio: 'Rionegro',
      departamento: 'Santander',
    );
    loteId = await perfil.guardarLote(
      fincaId: fincaId,
      nombre: 'Lote 1',
      areaSembradaHa: 2,
      variedadCacao: 'CCN-51',
      fechaSiembra: DateTime(2020),
    );
    await lotes.registrarActividad(
      loteId: loteId,
      tipo: TipoActividad.poda,
      fecha: DateTime(2026, 2, 1),
    );
    await lotes.registrarCosecha(
      loteId: loteId,
      fecha: DateTime(2026, 3, 1),
      cantidadKg: 50,
    );
    await db.registrosDao.registrarDiagnostico(
      loteId: loteId,
      fecha: DateTime(2026, 4, 1),
      estado: EstadoFenologico.floracion,
    );
  });
  tearDown(() => db.close());

  /// Todas las filas hijas del lote, borradas incluidas.
  Future<List<({DateTime? borradoEn, SyncStatus estado})>> hijas() async {
    final actividades = await db.select(db.actividadesAgricolas).get();
    final cosechas = await db.select(db.cosechas).get();
    final diagnosticos = await db.select(db.diagnosticos).get();
    return [
      for (final a in actividades)
        (borradoEn: a.deletedAt, estado: a.syncStatus),
      for (final c in cosechas) (borradoEn: c.deletedAt, estado: c.syncStatus),
      for (final d in diagnosticos)
        (borradoEn: d.deletedAt, estado: d.syncStatus),
    ];
  }

  void esperarTodasBorradasYPendientes(
    List<({DateTime? borradoEn, SyncStatus estado})> filas,
  ) {
    expect(filas, hasLength(3));
    for (final fila in filas) {
      expect(fila.borradoEn, isA<DateTime>());
      // Pendiente: el borrado también tiene que viajar a los demás
      // dispositivos, no basta con marcarlo aquí.
      expect(fila.estado, SyncStatus.pending);
    }
  }

  test('borrar el lote arrastra actividades, cosechas y diagnósticos',
      () async {
    await perfil.borrarLote(loteId);

    expect((await db.select(db.lotes).getSingle()).deletedAt, isA<DateTime>());
    esperarTodasBorradasYPendientes(await hijas());
    // Borrado suave: nada desaparece físicamente.
    expect(await db.select(db.cosechas).get(), hasLength(1));
  });

  test('borrar la finca arrastra sus lotes y los hijos de esos lotes',
      () async {
    await db.fincasDao.borrar(fincaId);

    expect((await db.select(db.fincas).getSingle()).deletedAt, isA<DateTime>());
    final lote = await db.select(db.lotes).getSingle();
    expect(lote.deletedAt, isA<DateTime>());
    expect(lote.syncStatus, SyncStatus.pending);
    esperarTodasBorradasYPendientes(await hijas());
    expect(await perfil.watchLotes(fincaId).first, isEmpty);
  });

  test('borrar el productor arrastra fincas, lotes e hijos', () async {
    await borrarProductorEnCascada(db, productorId);

    expect(
      (await db.select(db.productores).getSingle()).deletedAt,
      isA<DateTime>(),
    );
    expect((await db.select(db.fincas).getSingle()).deletedAt, isA<DateTime>());
    expect((await db.select(db.lotes).getSingle()).deletedAt, isA<DateTime>());
    esperarTodasBorradasYPendientes(await hijas());
    expect(await perfil.watchProductor().first, isNull);
  });

  test('repetir el borrado no cambia la fecha de lo que ya estaba borrado',
      () async {
    await perfil.borrarLote(loteId);
    final primera = (await db.select(db.cosechas).getSingle()).deletedAt;

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await perfil.borrarLote(loteId);

    expect((await db.select(db.cosechas).getSingle()).deletedAt, primera);
  });
}
