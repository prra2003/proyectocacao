import 'dart:convert';

import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/repositories/recordatorios.dart';
import 'package:cacao_app/data/sync/api_apps_script.dart';
import 'package:cacao_app/ui/dialogos/dialogo_actividad.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Las mejoras pensadas para el productor en campo: recordatorios, la
/// comparación con el año pasado, la edad del cultivo calculada sola y el
/// nombre tomado de la cuenta de Google.
void main() {
  late AppDatabase db;
  late PerfilRepository repo;
  late LoteRepository lotes;
  late String fincaId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = PerfilRepository(db, usuarioId: await db.syncDao.identidadLocal());
    lotes = LoteRepository(db);
    final productorId = await repo.guardarProductor(nombreCompleto: 'Diego');
    fincaId = await repo.guardarFinca(
      productorId: productorId,
      nombre: 'La Esperanza',
      municipio: 'Aranzazu',
      departamento: 'Caldas',
    );
  });
  tearDown(() => db.close());

  Future<Lote> nuevoLote(String nombre) async {
    final id = await repo.guardarLote(
      fincaId: fincaId,
      nombre: nombre,
      areaSembradaHa: 2,
      variedadCacao: 'Trinitario',
      fechaSiembra: DateTime(2020, 3, 1),
    );
    return (await db.lotesDao.porId(id))!;
  }

  group('recordatorios', () {
    test('avisan la poda atrasada y el lote sin nada anotado', () async {
      final alto = await nuevoLote('El Alto');
      final loma = await nuevoLote('La Loma');
      final hoy = DateTime.now();
      await lotes.registrarActividad(
        loteId: alto.id,
        tipo: TipoActividad.poda,
        fecha: hoy,
      );
      final actividades = await repo.watchActividadesDeFinca(fincaId).first;

      final avisos = recordatoriosPara(
        [alto, loma],
        actividades,
        hoy: hoy.add(const Duration(days: 100)),
      );

      expect(avisos, hasLength(2));
      final poda = avisos.firstWhere((a) => a.lote.id == alto.id);
      expect(poda.tipo, TipoActividad.poda);
      expect(poda.mensaje, 'El Alto lleva 100 días sin poda.');
      final nada = avisos.firstWhere((a) => a.lote.id == loma.id);
      expect(nada.tipo, isNull);
      expect(nada.mensaje, 'La Loma no tiene labores anotadas.');
    });

    test('a un lote recién creado no le recuerdan nada', () async {
      final alto = await nuevoLote('El Alto');
      final avisos = recordatoriosPara(
        [alto],
        const [],
        hoy: DateTime.now().add(const Duration(days: 10)),
      );
      expect(avisos, isEmpty);
    });

    test('anotar la poda hace desaparecer el aviso', () async {
      final alto = await nuevoLote('El Alto');
      final hoy = DateTime.now().add(const Duration(days: 100));
      await lotes.registrarActividad(
        loteId: alto.id,
        tipo: TipoActividad.poda,
        fecha: hoy,
      );
      final actividades = await repo.watchActividadesDeFinca(fincaId).first;
      expect(recordatoriosPara([alto], actividades, hoy: hoy), isEmpty);
    });
  });

  test(
    'compara con el año pasado a la misma fecha, no con todo el año',
    () async {
      final alto = await nuevoLote('El Alto');
      final hoy = DateTime(2026, 9, 23);
      Future<void> cosecha(DateTime fecha, double kg) =>
          lotes.registrarCosecha(loteId: alto.id, fecha: fecha, cantidadKg: kg);
      await cosecha(DateTime(2025, 3, 10), 100);
      await cosecha(DateTime(2025, 9, 23, 12), 50); // el mismo día cuenta
      await cosecha(DateTime(2025, 11, 5), 400); // después de la fecha: no
      await cosecha(DateTime(2024, 6, 1), 999); // otro año: no

      final kg = await repo
          .watchKgAnioPasadoAEstaFecha(fincaId, hoy: hoy)
          .first;
      expect(kg, 150);
    },
  );

  test('la labor guarda la edad del cultivo sin preguntarla', () async {
    final alto = await nuevoLote('El Alto');
    final DatosActividad datos = (
      tipo: TipoActividad.poda,
      fecha: DateTime.now(),
      observaciones: null,
      responsable: null,
      costo: null,
      fotoPath: null,
      resultadoEsperado: null,
      arbolesSembrados: null,
      edadPlantulaMeses: null,
      insumos: null,
      subtipoLabor: null,
      arbolesAfectados: null,
      edadCultivoAnios: null,
      producto: null,
      cantidadAplicada: null,
      incidencia: null,
    );
    await guardarLabor(lotes, alto, datos);

    final guardada = (await lotes.watchActividades(alto.id).first).single;
    expect(
      guardada.edadCultivoAnios,
      PerfilRepository.edadEnAnios(alto.fechaSiembra),
    );
  });

  group('nombre de la cuenta de Google', () {
    String token(Map<String, Object?> datos) {
      String parte(Map<String, Object?> m) =>
          base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
      return '${parte({'alg': 'RS256'})}.${parte(datos)}.firma';
    }

    test('se lee del token, con tildes', () {
      expect(
        ApiAppsScript.nombreDelToken(token({'name': 'María Rojas'})),
        'María Rojas',
      );
    });

    test('sin nombre o con un token raro no rompe nada', () {
      expect(ApiAppsScript.nombreDelToken(token({'email': 'a@b.co'})), isNull);
      expect(ApiAppsScript.nombreDelToken('no-es-un-token'), isNull);
      expect(ApiAppsScript.nombreDelToken('a.@@@.c'), isNull);
    });
  });

  test('la foto del lote se guarda y editar sin tocarla no la borra', () async {
    final id = await repo.guardarLote(
      fincaId: fincaId,
      nombre: 'El Alto',
      areaSembradaHa: 2,
      variedadCacao: 'Trinitario',
      fechaSiembra: DateTime(2020, 3, 1),
      fotoPath: const Value('/fotos/el_alto.jpg'),
    );
    await repo.guardarLote(
      id: id,
      fincaId: fincaId,
      nombre: 'El Alto de arriba',
      areaSembradaHa: 2,
      variedadCacao: 'Trinitario',
      fechaSiembra: DateTime(2020, 3, 1),
    );
    final lote = (await db.lotesDao.porId(id))!;
    expect(lote.nombre, 'El Alto de arriba');
    expect(lote.fotoPath, '/fotos/el_alto.jpg');
  });
}
