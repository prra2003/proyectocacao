import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/sync_service.dart';
import 'package:cacao_app/main.dart';
import 'package:cacao_app/ui/widgets/selector_finca.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

/// Abre un `DropdownButtonFormField` por su [key] y elige la opción [texto].
Future<void> _elegirDropdown(WidgetTester tester, Key key, String texto) async {
  await tester.tap(find.byKey(key));
  await asentar(tester);
  await tester.tap(find.text(texto).last);
  await asentar(tester);
}

/// Abre el selector de la cabecera del inicio y elige la finca [nombre].
Future<void> _elegirFinca(WidgetTester tester, String nombre) async {
  await tester.tap(find.byType(SelectorFinca));
  await asentar(tester);
  await tester.tap(find.widgetWithText(ListTile, nombre));
  await asentar(tester);
}

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

  testWidgets('el perfil se completa en cascada: productor, finca y lote', (
    tester,
  ) async {
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
    // La cédula ya viene elegida: casi todos los productores tienen cédula.
    expect(find.text('Documento: cédula de ciudadanía'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('campo_numero_documento')),
      '91234567',
    );
    expect(find.text('Paso 1 de 2'), findsOneWidget);
    await tester.tap(find.text('Crear perfil'));
    // Dos veces: la confirmación "Datos guardados" se queda un momento en
    // pantalla antes de pasar al siguiente paso.
    await asentar(tester);
    await asentar(tester);

    // El registro encadena: el segundo paso se abre solo.
    expect(find.text('Paso 2 de 2'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('campo_nombre_finca')),
      'La Esperanza',
    );
    // Departamento y municipio se eligen de la lista de Colombia, no se
    // escriben: el municipio solo aparece después del departamento.
    await _elegirDropdown(tester, const Key('campo_departamento'), 'Santander');
    await _elegirDropdown(tester, const Key('campo_municipio'), 'Bucaramanga');
    await tester.tap(find.text('Registrar finca').last);
    await asentar(tester);
    await asentar(tester);

    // Al terminar la primera finca pregunta si hay otra (RF-02).
    expect(find.text('¿Tiene otra finca?'), findsOneWidget);
    await tester.tap(find.text('No, ya terminé'));
    await asentar(tester);

    // La cabecera del inicio: nombre de la finca y municipio.
    expect(find.text('La Esperanza'), findsOneWidget);
    expect(find.text('Bucaramanga'), findsOneWidget);
    expect(find.text('Sin lotes todavía'), findsOneWidget);

    // El lote se crea por el repositorio: el selector de fecha ya lo cubre
    // la prueba del diálogo.
    final finca = await conAsync(tester, () async {
      final productor = await repo.watchProductor().first;
      return repo.watchFinca(productor!.id).first;
    });
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
    expect(find.text('Cédula de ciudadanía 91234567'), findsOneWidget);
    expect(find.text('La Esperanza · Bucaramanga, Santander'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('sin tipo ni número de documento no deja crear el perfil', (
    tester,
  ) async {
    await abrirApp(tester);

    await tester.tap(find.text('Comenzar registro'));
    await asentar(tester);
    await tester.enterText(
      find.byKey(const Key('campo_nombre_productor')),
      'Diego Parra',
    );
    await tester.tap(find.text('Crear perfil'));
    await asentar(tester);

    // Sigue en el paso 1: la validación no dejó avanzar.
    expect(find.text('Paso 1 de 2'), findsOneWidget);
    expect(await conAsync(tester, () => repo.watchProductor().first), isNull);

    await desmontar(tester);
  });

  testWidgets(
    'el nombre con números y el teléfono con letras no dejan avanzar',
    (tester) async {
      await abrirApp(tester);

      await tester.tap(find.text('Comenzar registro'));
      await asentar(tester);
      await tester.enterText(
        find.byKey(const Key('campo_nombre_productor')),
        'Diego 2',
      );
      await tester.enterText(
        find.byKey(const Key('campo_telefono')),
        '300abc4567',
      );
      await tester.tap(find.text('Crear perfil'));
      await asentar(tester);

      expect(find.text('Solo letras, sin números'), findsOneWidget);
      expect(find.text('Solo números'), findsOneWidget);
      expect(find.text('Paso 1 de 2'), findsOneWidget);

      await desmontar(tester);
    },
  );

  testWidgets('la asociación elegida en el formulario queda guardada', (
    tester,
  ) async {
    await conAsync(
      tester,
      () => db
          .into(db.asociaciones)
          .insert(
            AsociacionesCompanion.insert(
              nombre: 'Coop. Cacaotera de Santander',
              municipio: 'San Vicente de Chucurí',
              departamento: 'Santander',
            ),
          ),
    );
    await conAsync(
      tester,
      () => repo.guardarProductor(nombreCompleto: 'Diego Parra'),
    );
    await abrirApp(tester);

    await tester.tap(find.text('Perfil'));
    await asentar(tester);
    await tester.tap(find.text('Editar mis datos'));
    await asentar(tester);
    await tester.enterText(
      find.byKey(const Key('campo_numero_documento')),
      '91234567',
    );
    await _elegirDropdown(
      tester,
      const Key('campo_asociacion'),
      'Coop. Cacaotera de Santander',
    );
    await tester.tap(find.text('Guardar cambios'));
    await asentar(tester);
    await asentar(tester);

    final productor = await conAsync(tester, () => repo.watchProductor().first);
    expect(productor!.asociacionId, isNotNull);
    expect(find.text('Coop. Cacaotera de Santander'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('el catálogo de asociaciones viene sembrado desde el arranque', (
    tester,
  ) async {
    await abrirApp(tester);

    await tester.tap(find.text('Comenzar registro'));
    await asentar(tester);
    await tester.tap(find.byKey(const Key('campo_asociacion')));
    await asentar(tester);

    for (final nombre in [
      'FEDECACAO',
      'FEPCACAO',
      'ASOMUSTIC',
      'APROCAVILLA',
      'AMUCAFUE',
    ]) {
      expect(find.text(nombre), findsOneWidget);
    }
    expect(find.text('Otra (especificar)'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets(
    '"Otra (especificar)" crea una asociación nueva y la deja guardada',
    (tester) async {
      await conAsync(
        tester,
        () => repo.guardarProductor(nombreCompleto: 'Diego Parra'),
      );
      await abrirApp(tester);

      await tester.tap(find.text('Perfil'));
      await asentar(tester);
      await tester.tap(find.text('Editar mis datos'));
      await asentar(tester);
      await tester.enterText(
        find.byKey(const Key('campo_numero_documento')),
        '91234567',
      );
      await _elegirDropdown(
        tester,
        const Key('campo_asociacion'),
        'Otra (especificar)',
      );
      await tester.enterText(
        find.byKey(const Key('campo_asociacion_otra')),
        'Asociación de Productores El Cacaotal',
      );
      await tester.tap(find.text('Guardar cambios'));
      await asentar(tester);
      await asentar(tester);

      final productor = await conAsync(
        tester,
        () => repo.watchProductor().first,
      );
      final asociacion = await conAsync(
        tester,
        () => repo.asociacionPorId(productor!.asociacionId!),
      );
      expect(asociacion!.nombre, 'Asociación de Productores El Cacaotal');
      expect(
        find.text('Asociación de Productores El Cacaotal'),
        findsOneWidget,
      );

      await desmontar(tester);
    },
  );

  /// Deja un productor con dos fincas, cada una con un lote, listo para las
  /// dos pruebas de abajo.
  Future<void> sembrarDosFincas(WidgetTester tester) async {
    final productorId = await conAsync(
      tester,
      () => repo.guardarProductor(nombreCompleto: 'Diego Parra'),
    );
    final finca1 = await conAsync(
      tester,
      () => repo.guardarFinca(
        productorId: productorId,
        nombre: 'La Esperanza',
        municipio: 'San Vicente de Chucurí',
        departamento: 'Santander',
      ),
    );
    final finca2 = await conAsync(
      tester,
      () => repo.guardarFinca(
        productorId: productorId,
        nombre: 'El Paraíso',
        municipio: 'Rionegro',
        departamento: 'Santander',
      ),
    );
    await conAsync(
      tester,
      () => repo.guardarLote(
        fincaId: finca1,
        nombre: 'Lote 1',
        areaSembradaHa: 2,
        variedadCacao: 'CCN-51',
        fechaSiembra: DateTime(2020, 1, 1),
      ),
    );
    await conAsync(
      tester,
      () => repo.guardarLote(
        fincaId: finca2,
        nombre: 'Lote 2',
        areaSembradaHa: 3,
        variedadCacao: 'ICS-95',
        fechaSiembra: DateTime(2021, 1, 1),
      ),
    );
  }

  testWidgets(
    'el perfil muestra todas las fincas, sin otro lugar para editarlas',
    (tester) async {
      await sembrarDosFincas(tester);
      await abrirApp(tester);

      await tester.tap(find.text('Perfil'));
      await asentar(tester);

      expect(find.text('Sus fincas'), findsOneWidget);
      expect(find.textContaining('La Esperanza ·'), findsOneWidget);
      expect(find.textContaining('El Paraíso ·'), findsOneWidget);
      // Agregar o cambiar fincas se hace solo desde el Inicio.
      expect(find.text('Agregar otra finca'), findsNothing);
      expect(find.textContaining('Ver mis fincas'), findsNothing);

      await desmontar(tester);
    },
  );

  testWidgets(
    '"Anotar" reúne lotes de todas las fincas, no solo de la primera',
    (tester) async {
      await sembrarDosFincas(tester);
      await abrirApp(tester);

      await tester.tap(find.byTooltip('Anotar'));
      await asentar(tester);

      // Uno de los dos ya se ve en el panel de Inicio (la finca "principal" es
      // la primera en orden alfabético, no la primera creada) y por eso puede
      // aparecer duplicado; lo que importa es que los dos están en la hoja.
      expect(find.text('Lote 1'), findsWidgets);
      expect(find.text('Lote 2'), findsWidgets);

      await desmontar(tester);
    },
  );

  testWidgets(
    'con dos fincas y un solo lote, "Anotar" pregunta en vez de escoger solo',
    (tester) async {
      // La trampa que encontramos en el campo: una finca sin lotes y otra con
      // uno. La app daba por hecho que era ese y anotaba ahí callada, en una
      // finca distinta de la que la persona estaba viendo.
      final productorId = await conAsync(
        tester,
        () => repo.guardarProductor(nombreCompleto: 'Diego Parra'),
      );
      final conLote = await conAsync(
        tester,
        () => repo.guardarFinca(
          productorId: productorId,
          nombre: 'La Esperanza',
          municipio: 'San Vicente de Chucurí',
          departamento: 'Santander',
        ),
      );
      await conAsync(
        tester,
        () => repo.guardarFinca(
          productorId: productorId,
          nombre: 'El Paraíso',
          municipio: 'Rionegro',
          departamento: 'Santander',
        ),
      );
      await conAsync(
        tester,
        () => repo.guardarLote(
          fincaId: conLote,
          nombre: 'Lote 1',
          areaSembradaHa: 2,
          variedadCacao: 'CCN-51',
          fechaSiembra: DateTime(2020, 1, 1),
        ),
      );
      await abrirApp(tester);

      await tester.tap(find.byTooltip('Anotar'));
      await asentar(tester);

      // Pregunta, y además dice de qué finca es el lote.
      expect(find.text('¿En cuál lote?'), findsOneWidget);
      expect(find.text('La Esperanza'), findsWidgets);

      await desmontar(tester);
    },
  );

  testWidgets('el selector de fincas en Inicio cambia los lotes que se ven', (
    tester,
  ) async {
    await sembrarDosFincas(tester);
    await abrirApp(tester);

    // Arranca mostrando una de las dos; la cabecera abre la lista de todas.
    expect(find.byType(SelectorFinca), findsOneWidget);

    await _elegirFinca(tester, 'La Esperanza');
    expect(find.text('Lote 1'), findsOneWidget);
    expect(find.text('Lote 2'), findsNothing);

    await _elegirFinca(tester, 'El Paraíso');
    expect(find.text('Lote 2'), findsOneWidget);
    expect(find.text('Lote 1'), findsNothing);

    await desmontar(tester);
  });

  testWidgets('con perfil pero sin finca, el inicio lleva a registrarla', (
    tester,
  ) async {
    await conAsync(
      tester,
      () => repo.guardarProductor(nombreCompleto: 'Diego Parra'),
    );
    await abrirApp(tester);

    expect(find.text('Registre su finca'), findsOneWidget);

    await tester.tap(find.text('Registrar finca'));
    await asentar(tester);

    // La ubicación se toma con el GPS o en el mapa; ya no se escribe.
    expect(find.byKey(const Key('boton_estoy_en_la_finca')), findsOneWidget);
    expect(find.text('O marcarla en el mapa'), findsOneWidget);
    expect(find.byKey(const Key('campo_latitud')), findsNothing);

    await desmontar(tester);
  });

  testWidgets('la finca se puede registrar sin ubicación', (tester) async {
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
    await _elegirDropdown(tester, const Key('campo_departamento'), 'Santander');
    await _elegirDropdown(tester, const Key('campo_municipio'), 'Bucaramanga');
    await tester.tap(find.text('Registrar finca').last);
    await asentar(tester);
    await asentar(tester);

    final finca = await conAsync(tester, () async {
      final productor = await repo.watchProductor().first;
      return repo.watchFinca(productor!.id).first;
    });
    expect(finca, isNotNull);
    expect(finca!.latitud, isNull);

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

  test(
    'un lote borrado desaparece de la lista pero queda en la base',
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
    },
  );
}
