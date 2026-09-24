import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/repositories/recordatorios.dart';
import 'package:drift/drift.dart' show Variable;
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

  test('una poda a medias dice exactamente qué le falta', () async {
    await lotes.registrarActividad(
      loteId: loteId,
      tipo: TipoActividad.poda,
      fecha: DateTime(2026, 2, 1),
    );
    final labor = (await lotes.watchActividades(loteId).first).single;

    expect(faltaLlenarEn(labor), ['Tipo de poda', 'Árboles podados']);
  });

  test('corregir la labor llena lo que faltaba y la deja por subir', () async {
    await lotes.registrarActividad(
      loteId: loteId,
      tipo: TipoActividad.poda,
      fecha: DateTime(2026, 2, 1),
    );
    var labor = (await lotes.watchActividades(loteId).first).single;
    // Se da por sincronizada para comprobar que la corrección la vuelve a
    // marcar: si no, el teléfono y el servidor quedarían con versiones
    // distintas y nadie se enteraría.
    await db.customUpdate(
      "UPDATE actividades_agricolas SET sync_status = 'synced' WHERE id = ?",
      variables: [Variable(labor.id)],
    );

    await lotes.actualizarActividad(
      id: labor.id,
      tipo: TipoActividad.poda,
      fecha: labor.fecha,
      subtipoLabor: 'Formación',
      arbolesAfectados: 35,
    );

    labor = (await lotes.watchActividades(loteId).first).single;
    expect(faltaLlenarEn(labor), isEmpty);
    expect(labor.subtipoLabor, 'Formación');
    expect(labor.arbolesAfectados, 35);
    expect(labor.syncStatus, SyncStatus.pending);
  });

  test('una labor ya completa no se puede volver a cambiar', () async {
    await lotes.registrarActividad(
      loteId: loteId,
      tipo: TipoActividad.poda,
      fecha: DateTime(2026, 2, 1),
      subtipoLabor: 'Formación',
      arbolesAfectados: 35,
    );
    final labor = (await lotes.watchActividades(loteId).first).single;
    expect(faltaLlenarEn(labor), isEmpty);

    final escritas = await lotes.actualizarActividad(
      id: labor.id,
      tipo: TipoActividad.poda,
      fecha: labor.fecha,
      subtipoLabor: 'Rehabilitación',
      arbolesAfectados: 900,
    );

    expect(escritas, 0, reason: 'no debería escribir nada');
    final despues = (await lotes.watchActividades(loteId).first).single;
    expect(despues.subtipoLabor, 'Formación');
    expect(despues.arbolesAfectados, 35);
  });

  test('una labor sin campos extra no inventa nada', () async {
    await lotes.registrarActividad(
      loteId: loteId,
      tipo: TipoActividad.riego,
      fecha: DateTime(2026, 3, 1),
    );

    final eventos = await db.registrosDao.watchHistorialDeFinca(fincaId).first;
    expect(eventos.single.anotado, isEmpty);
  });

  test(
    'cerrar sesión borra los datos pero deja el catálogo de asociaciones',
    () async {
      // El catálogo no es un dato de la persona: es una lista fija que la app
      // trae de fábrica. Sin volver a sembrarlo, el formulario de perfil se
      // quedaba sin opciones hasta que alguien cerrara y abriera la app otra
      // vez —en la web, hasta recargar la página—.
      expect(
        (await db.select(db.asociaciones).get()).length,
        greaterThan(0),
        reason: 'debería venir sembrado',
      );
      await lotes.registrarActividad(
        loteId: loteId,
        tipo: TipoActividad.poda,
        fecha: DateTime(2026, 2, 1),
      );

      await borrarDatosLocales(db);

      expect((await db.select(db.actividadesAgricolas).get()).length, 0);
      expect((await db.select(db.fincas).get()).length, 0);
      expect((await db.select(db.asociaciones).get()).length, greaterThan(0));
    },
  );
}
