// Genera las capturas de pantalla de docs/capturas/ con la app de verdad y
// datos inventados.
//
//     flutter test tools/generar_capturas_test.dart
//
// No vive en test/ a propósito: no es una prueba, escribe archivos, y no debe
// correr en cada pull request. Se corre a mano cuando cambia la cara de la app.
//
// Las capturas salen de la interfaz real —los mismos widgets, el tema, las
// fuentes Roboto y los íconos de Material, que se cargan del SDK de Flutter—,
// con una base en memoria llenada con una productora y una finca ficticias.
// Nunca se usan datos de productores reales: estas imágenes se publican.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/data/sync/api_falsa.dart';
import 'package:cacao_app/data/sync/sync_service.dart';
import 'package:cacao_app/ui/asistente_costo_screen.dart';
import 'package:cacao_app/ui/ayuda_screen.dart';
import 'package:cacao_app/ui/cascaron_screen.dart';
import 'package:cacao_app/ui/costo_por_kilo_screen.dart';
import 'package:cacao_app/ui/editar_finca_screen.dart';
import 'package:cacao_app/ui/tema.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/utiles.dart';

const _carpeta = 'docs/capturas';
final _marco = GlobalKey();

/// Roboto y los íconos salen del SDK de Flutter: sin cargarlos, el test
/// dibuja cada letra como un cuadrado y cada ícono como una caja vacía.
Future<void> _cargarFuentes() async {
  final raiz =
      Platform.environment['FLUTTER_ROOT'] ??
      r'C:\flutter_windows_3.47.4-stable\flutter';
  final dir = '$raiz/bin/cache/artifacts/material_fonts';
  Future<ByteData> bytes(String nombre) async =>
      ByteData.sublistView(await File('$dir/$nombre').readAsBytes());

  // Las pruebas dibujan con "Ahem" (cuadrados) todo estilo que no nombre su
  // familia, como el título de la barra, las etiquetas de los botones y el
  // "Anotar": en el teléfono real eso cae en Roboto. Cargar Roboto también
  // con el nombre "Ahem" hace que esos textos se vean como se ven allá.
  for (final familia in ['Roboto', 'Ahem']) {
    final roboto = FontLoader(familia);
    for (final f in [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
      'roboto-light.ttf',
      'roboto-italic.ttf',
      'roboto-black.ttf',
    ]) {
      roboto.addFont(bytes(f));
    }
    await roboto.load();
  }

  final iconos = FontLoader('MaterialIcons')
    ..addFont(bytes('materialicons-regular.otf'));
  await iconos.load();
}

/// Un teléfono corriente: 390 x 844, a doble densidad.
void _telefono(WidgetTester tester, {double alto = 844}) {
  tester.view.physicalSize = Size(780, alto * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

Future<void> _montar(
  WidgetTester tester,
  Widget app, {
  double alto = 844,
}) async {
  _telefono(tester, alto: alto);
  await tester.pumpWidget(RepaintBoundary(key: _marco, child: app));
  await asentar(tester);
  // Los números del Inicio suben contando: hay que esperar a que terminen
  // o la captura sale con una cifra a medias.
  await tester.pump(const Duration(seconds: 2));
}

/// El tema de la app, con Roboto puesto a mano en los estilos de componentes
/// que no nombran su familia (barra, botones, pestañas, diálogos...). En el
/// teléfono esos estilos caen en Roboto, la fuente del sistema; en una prueba
/// caerían en "Ahem", que dibuja cada letra como un cuadrado.
ThemeData _temaConFuente() {
  final t = temaCacao();
  TextStyle? roboto(TextStyle? s) => s?.copyWith(fontFamily: 'Roboto');
  ButtonStyle? boton(ButtonStyle? s) => s?.copyWith(
    textStyle: WidgetStatePropertyAll(roboto(s.textStyle?.resolve({}))),
  );
  return t.copyWith(
    appBarTheme: t.appBarTheme.copyWith(
      titleTextStyle: roboto(t.appBarTheme.titleTextStyle),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: boton(t.filledButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: boton(t.outlinedButtonTheme.style),
    ),
    textButtonTheme: TextButtonThemeData(style: boton(t.textButtonTheme.style)),
    floatingActionButtonTheme: t.floatingActionButtonTheme.copyWith(
      extendedTextStyle: roboto(t.floatingActionButtonTheme.extendedTextStyle),
    ),
    chipTheme: t.chipTheme.copyWith(
      labelStyle: roboto(t.chipTheme.labelStyle),
      secondaryLabelStyle: roboto(t.chipTheme.secondaryLabelStyle),
    ),
    tabBarTheme: t.tabBarTheme.copyWith(
      labelStyle: roboto(t.tabBarTheme.labelStyle),
      unselectedLabelStyle: roboto(t.tabBarTheme.unselectedLabelStyle),
    ),
    dialogTheme: t.dialogTheme.copyWith(
      titleTextStyle: roboto(t.dialogTheme.titleTextStyle),
    ),
    snackBarTheme: t.snackBarTheme.copyWith(
      contentTextStyle: roboto(t.snackBarTheme.contentTextStyle),
    ),
    inputDecorationTheme: t.inputDecorationTheme.copyWith(
      labelStyle: roboto(t.inputDecorationTheme.labelStyle),
      floatingLabelStyle: roboto(t.inputDecorationTheme.floatingLabelStyle),
      hintStyle: roboto(t.inputDecorationTheme.hintStyle),
    ),
  );
}

Widget _conTema(Widget home) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: _temaConFuente(),
  locale: const Locale('es'),
  supportedLocales: const [Locale('es'), Locale('en')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: home,
);

Future<void> _capturar(WidgetTester tester, String nombre) async {
  await tester.runAsync(() async {
    final frontera =
        _marco.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final imagen = await frontera.toImage(pixelRatio: 2);
    final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
    await File('$_carpeta/$nombre.png')
        .writeAsBytes(datos!.buffer.asUint8List());
  });
}

/// Cierra la escena: desmonta, cierra la base y devuelve las sombras a como
/// las deja el framework (si no, la prueba falla al terminar).
Future<void> _fin(WidgetTester tester, _Mundo m) async {
  await desmontar(tester);
  await conAsync(tester, m.db.close);
  debugDisableShadows = true;
}

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f.first);
  await tester.pump();
  await tester.tap(f.first);
  await asentar(tester);
}

class _Mundo {
  _Mundo(this.db, this.perfil, this.lotes);

  final AppDatabase db;
  final PerfilRepository perfil;
  final LoteRepository lotes;
  late String productorId;
  late String fincaId;
  late String elMirador;
  late String laQuebrada;
}

DateTime _hace(int dias) => DateTime.now().subtract(Duration(days: dias));

/// La finca ficticia con la que se arman todas las capturas.
Future<_Mundo> _sembrar({
  bool conRegistros = true,
  bool conPendientes = false,
}) async {
  final db = AppDatabase(NativeDatabase.memory());
  final perfil = PerfilRepository(
    db,
    usuarioId: await db.syncDao.identidadLocal(),
  );
  final m = _Mundo(db, perfil, LoteRepository(db));

  final asociaciones = await perfil.watchAsociaciones().first;
  final fedecacao = asociaciones.firstWhere((a) => a.nombre == 'FEDECACAO');

  m.productorId = await perfil.guardarProductor(
    nombreCompleto: 'María Fernanda Ríos',
    telefono: '3001234567',
    email: 'maria.rios@ejemplo.co',
    asociacionId: fedecacao.id,
    tipoDocumento: TipoDocumento.cedulaCiudadania,
    numeroDocumento: '1000000000',
  );
  m.fincaId = await perfil.guardarFinca(
    productorId: m.productorId,
    nombre: 'La Esperanza',
    municipio: 'Calarcá',
    departamento: 'Quindío',
    latitud: 4.5339,
    longitud: -75.6811,
  );
  m.elMirador = await perfil.guardarLote(
    fincaId: m.fincaId,
    nombre: 'El Mirador',
    areaSembradaHa: 2.4,
    variedadCacao: 'CCN-51',
    fechaSiembra: DateTime(2019, 3, 12),
  );
  m.laQuebrada = await perfil.guardarLote(
    fincaId: m.fincaId,
    nombre: 'La Quebrada',
    areaSembradaHa: 3.2,
    variedadCacao: 'Criollo',
    fechaSiembra: DateTime(2018, 5, 2),
  );
  await perfil.guardarLote(
    fincaId: m.fincaId,
    nombre: 'Loma Alta',
    areaSembradaHa: 1.1,
    variedadCacao: 'ICS-95',
    fechaSiembra: DateTime(2022, 8, 20),
  );
  if (!conRegistros) return m;

  final l = m.lotes;
  // El Mirador: el lote con más historia. Las labores van completas, salvo
  // cuando se pide mostrar el aviso de "labores por terminar de llenar".
  await l.registrarActividad(
    loteId: m.elMirador,
    tipo: TipoActividad.poda,
    fecha: _hace(12),
    subtipoLabor: 'Formación',
    arbolesAfectados: 120,
    responsable: 'María Ríos',
    costo: 180000,
    observaciones: 'Se podó la parte baja del lote',
  );
  await l.registrarActividad(
    loteId: m.elMirador,
    tipo: TipoActividad.fertilizacion,
    fecha: _hace(30),
    subtipoLabor: 'Orgánica',
    producto: 'Compost de la finca',
    cantidadAplicada: '7 bultos',
    responsable: 'María Ríos',
    costo: 350000,
  );
  await l.registrarActividad(
    loteId: m.elMirador,
    tipo: TipoActividad.controlFitosanitario,
    fecha: _hace(45),
    subtipoLabor: 'Monilia',
    producto: 'Fungicida cúprico',
    cantidadAplicada: '2 litros',
    responsable: 'Jorge Ríos',
    costo: 90000,
  );
  await l.registrarActividad(
    loteId: m.elMirador,
    tipo: TipoActividad.riego,
    fecha: _hace(3),
    subtipoLabor: conPendientes ? null : 'Por goteo',
    cantidadAplicada: conPendientes ? null : '500 litros',
    costo: 40000,
  );
  await l.registrarCosecha(
    loteId: m.elMirador,
    fecha: _hace(20),
    cantidadKg: 85,
    tipoProducto: 'Cacao seco',
  );
  await l.registrarCosecha(
    loteId: m.elMirador,
    fecha: _hace(50),
    cantidadKg: 120,
    tipoProducto: 'Cacao seco',
  );
  await l.registrarDiagnostico(
    loteId: m.elMirador,
    fecha: _hace(6),
    estado: EstadoFenologico.fructificacion,
    notas: 'Buena carga de mazorcas',
  );
  // La Quebrada: sin poda hace rato, para que el Inicio lo recuerde.
  await l.registrarActividad(
    loteId: m.laQuebrada,
    tipo: TipoActividad.poda,
    fecha: _hace(95),
    subtipoLabor: 'Mantenimiento',
    arbolesAfectados: 80,
    responsable: 'María Ríos',
    costo: 150000,
  );
  await l.registrarCosecha(
    loteId: m.laQuebrada,
    fecha: _hace(35),
    cantidadKg: 60,
    tipoProducto: 'Cacao seco',
  );
  return m;
}

Widget _app(_Mundo m) => _conTema(
  CascaronScreen(
    repo: m.perfil,
    lotesRepo: m.lotes,
    db: m.db,
    sync: SyncService(
      baseDatos: m.db,
      apiRemota: ApiRemotaFalsa(),
      usuarioLocal: m.perfil.usuarioId,
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Directory(_carpeta).create(recursive: true);
    await _cargarFuentes();
  });

  // Las pruebas dibujan las sombras como un borde negro duro, para que los
  // goldens sean idénticos entre equipos. Aquí interesa lo que se ve de
  // verdad en el teléfono. El framework exige devolver la variable a su valor
  // dentro de la prueba (ver `_fin`), no después.
  setUp(() => debugDisableShadows = false);

  testWidgets('bienvenida y registro', (tester) async {
    final m = await conAsync(tester, () => _sembrar(conRegistros: false));
    // Sin productor registrado la app abre en la bienvenida.
    await conAsync(tester, () async {
      await m.db.customStatement('DELETE FROM lotes');
      await m.db.customStatement('DELETE FROM fincas');
      await m.db.customStatement('DELETE FROM productores');
    });
    await _montar(tester, _app(m));
    // La entrada es una animación de casi tres segundos.
    await tester.pump(const Duration(seconds: 3));
    await asentar(tester);
    await _capturar(tester, '01-bienvenida');

    await _tocar(tester, find.text('Comenzar registro'));
    await _capturar(tester, '02-registro-paso-1');

    await _fin(tester, m);
  });

  testWidgets('registro paso 2', (tester) async {
    final m = await conAsync(tester, () => _sembrar(conRegistros: false));
    await _montar(
      tester,
      _conTema(
        EditarFincaScreen(
          repo: m.perfil,
          productorId: m.productorId,
          paso: 'Paso 2 de 2',
        ),
      ),
    );
    await _capturar(tester, '03-registro-paso-2');
    await _fin(tester, m);
  });

  testWidgets('inicio', (tester) async {
    final m = await conAsync(tester, _sembrar);
    await _montar(tester, _app(m), alto: 1000);
    await _capturar(tester, '04-inicio');
    await _fin(tester, m);
  });

  testWidgets('inicio con labores por terminar', (tester) async {
    final m = await conAsync(tester, () => _sembrar(conPendientes: true));
    await _montar(tester, _app(m), alto: 1000);
    await _capturar(tester, '05-inicio-pendientes');
    await _fin(tester, m);
  });

  testWidgets('lote', (tester) async {
    final m = await conAsync(tester, _sembrar);
    await _montar(tester, _app(m), alto: 1000);
    await _tocar(tester, find.text('El Mirador'));
    await _capturar(tester, '06-lote-labores');
    await _tocar(tester, find.text('Cosechas'));
    await _capturar(tester, '07-lote-cosechas');
    await _tocar(tester, find.text('Estado'));
    await _capturar(tester, '08-lote-estado');

    await _fin(tester, m);
  });

  testWidgets('anotar una labor', (tester) async {
    final m = await conAsync(tester, _sembrar);
    await _montar(tester, _app(m));
    await _tocar(tester, find.byTooltip('Anotar'));
    await _capturar(tester, '09-anotar');
    // "El Mirador" también está en el Inicio, debajo de la hoja: hay que
    // escoger el de la hoja.
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('El Mirador'),
      ),
    );
    await _tocar(tester, find.text('Una labor'));
    await _capturar(tester, '10-anotar-labor');

    await _fin(tester, m);
  });

  testWidgets('reportes', (tester) async {
    final m = await conAsync(tester, _sembrar);
    await _montar(tester, _app(m), alto: 1000);
    await _tocar(tester, find.text('Reportes'));
    await _capturar(tester, '11-reportes-indicadores');
    await _tocar(tester, find.text('Historial'));
    await _capturar(tester, '12-reportes-historial');
    await _tocar(tester, find.text('Mis lotes'));
    await _capturar(tester, '13-reportes-lotes');

    await _fin(tester, m);
  });

  testWidgets('perfil y ayuda', (tester) async {
    final m = await conAsync(tester, _sembrar);
    // Alto suficiente para ver la tarjeta de Ayuda sin bajar.
    await _montar(tester, _app(m), alto: 1100);
    await _tocar(tester, find.text('Perfil'));
    await _capturar(tester, '14-perfil');

    await _montar(
      tester,
      _conTema(AyudaScreen(abrirEnlace: (_) async => true)),
    );
    await _capturar(tester, '15-ayuda');

    await _fin(tester, m);
  });

  testWidgets('costo por kilo', (tester) async {
    final m = await conAsync(tester, _sembrar);
    final lote = await conAsync(
      tester,
      () async => (await m.perfil.watchLotes(m.fincaId).first).firstWhere(
        (l) => l.id == m.elMirador,
      ),
    );
    await _montar(
      tester,
      _conTema(
        CostoPorKiloScreen(
          repo: m.lotes,
          lote: lote,
          nombreFinca: 'La Esperanza',
        ),
      ),
      alto: 1000,
    );
    await _capturar(tester, '16-costo-por-kilo');

    await _montar(
      tester,
      _conTema(AsistenteCostoScreen(repo: m.lotes, lote: lote)),
    );
    await _capturar(tester, '17-asistente-cosecha');

    await _fin(tester, m);
  });
}
