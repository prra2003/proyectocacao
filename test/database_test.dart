import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/local/tables.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
    'guarda la cadena finca -> lote -> cosecha y calcula la edad del cultivo',
    () async {
      final asociacionId = nuevoId();
      await db
          .into(db.asociaciones)
          .insert(
            AsociacionesCompanion.insert(
              id: Value(asociacionId),
              nombre: 'ASOPROCAR',
              municipio: 'San Vicente de Chucuri',
              departamento: 'Santander',
            ),
          );

      final productorId = nuevoId();
      await db
          .into(db.productores)
          .insert(
            ProductoresCompanion.insert(
              id: Value(productorId),
              nombreCompleto: 'Diego Parra',
              asociacionId: Value(asociacionId),
            ),
          );

      final fincaId = nuevoId();
      await db
          .into(db.fincas)
          .insert(
            FincasCompanion.insert(
              id: Value(fincaId),
              productorId: productorId,
              nombre: 'La Esperanza',
              municipio: 'San Vicente de Chucuri',
              departamento: 'Santander',
              latitud: const Value(6.8809),
              longitud: const Value(-73.4118),
            ),
          );

      final loteId = nuevoId();
      await db
          .into(db.lotes)
          .insert(
            LotesCompanion.insert(
              id: Value(loteId),
              fincaId: fincaId,
              nombre: 'Lote 1',
              areaSembradaHa: 2.5,
              variedadCacao: 'CCN-51',
              fechaSiembra: DateTime(2020, 3, 15),
            ),
          );

      await db
          .into(db.cosechas)
          .insert(
            CosechasCompanion.insert(
              loteId: loteId,
              fecha: DateTime(2026, 6, 1),
              cantidadKg: 180.5,
            ),
          );

      final lote = await (db.select(
        db.lotes,
      )..where((l) => l.id.equals(loteId))).getSingle();
      final edadAnios =
          DateTime(2026, 8, 30).difference(lote.fechaSiembra).inDays ~/ 365;

      expect(edadAnios, 6);
      expect(lote.syncStatus, SyncStatus.pending);
      expect(await db.select(db.cosechas).get(), hasLength(1));
    },
  );

  test('rechaza un lote cuya finca no existe', () async {
    await expectLater(
      db
          .into(db.lotes)
          .insert(
            LotesCompanion.insert(
              fincaId: 'finca-que-no-existe',
              nombre: 'Lote fantasma',
              areaSembradaHa: 1,
              variedadCacao: 'ICS-95',
              fechaSiembra: DateTime(2024, 1, 1),
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test(
    'el borrado suave marca la fila y la deja pendiente de sincronizar',
    () async {
      final id = nuevoId();
      await db
          .into(db.asociaciones)
          .insert(
            AsociacionesCompanion.insert(
              id: Value(id),
              nombre: 'ASOCACAO',
              municipio: 'Rionegro',
              departamento: 'Santander',
            ),
          );
      await db
          .update(db.asociaciones)
          .write(
            const AsociacionesCompanion(syncStatus: Value(SyncStatus.synced)),
          );

      await borrarSuave(db, db.asociaciones, id);

      final fila = await (db.select(
        db.asociaciones,
      )..where((a) => a.id.equals(id))).getSingle();
      expect(fila.deletedAt, isA<DateTime>());
      expect(fila.syncStatus, SyncStatus.pending);
    },
  );
}
