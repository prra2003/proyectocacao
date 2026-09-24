import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// El historial mostraba solo las observaciones, así que todo lo que el
/// formulario pide —el tipo de poda, los árboles, el producto, el
/// responsable— se guardaba bien pero no se veía en ninguna parte, ni en
/// pantalla ni en lo que se descarga y se le manda al técnico.
void main() {
  late AppDatabase db;
  late PerfilRepository perfil;
  late LoteRepository lotes;
  late String fincaId;
  late String loteId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    perfil = PerfilRepository(db, usuarioId: await db.syncDao.identidadLocal());
    lotes = LoteRepository(db);

    final productorId = await perfil.guardarProductor(nombreCompleto: 'Diego');
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
  });

  tearDown(() => db.close());

  test(
    'el historial trae lo que se anotó en la labor, no solo las notas',
    () async {
      await lotes.registrarActividad(
        loteId: loteId,
        tipo: TipoActividad.poda,
        fecha: DateTime(2026, 2, 1),
        subtipoLabor: 'Formación',
        arbolesAfectados: 35,
        responsable: 'Diego Parra',
        observaciones: 'Quedó pendiente la mitad de abajo',
      );

      final eventos = await db.registrosDao
          .watchHistorialDeFinca(fincaId)
          .first;
      expect(eventos, hasLength(1));

      final anotado = eventos.single.anotado;
      expect(anotado, contains(('Tipo', 'Formación')));
      expect(anotado, contains(('Árboles', '35')));
      expect(anotado, contains(('Responsable', 'Diego Parra')));
      // Las observaciones siguen aparte: no se mezclan con los campos.
      expect(eventos.single.detalle, 'Quedó pendiente la mitad de abajo');
    },
  );

  test('una labor sin campos extra no inventa nada', () async {
    await lotes.registrarActividad(
      loteId: loteId,
      tipo: TipoActividad.riego,
      fecha: DateTime(2026, 3, 1),
    );

    final eventos = await db.registrosDao.watchHistorialDeFinca(fincaId).first;
    expect(eventos.single.anotado, isEmpty);
  });
}
