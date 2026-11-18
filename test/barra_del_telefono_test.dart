import 'package:cacao_app/data/local/database.dart';
import 'package:cacao_app/data/local/enums.dart';
import 'package:cacao_app/data/repositories/lote_repository.dart';
import 'package:cacao_app/data/repositories/perfil_repository.dart';
import 'package:cacao_app/ui/asistente_costo_screen.dart';
import 'package:cacao_app/ui/costo_por_kilo_screen.dart';
import 'package:cacao_app/ui/tema.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utiles.dart';

/// Desde Android 15 la aplicación se dibuja de borde a borde: debajo de la
/// barra de arriba y, lo que importa aquí, **debajo de la barra de botones
/// del teléfono**.
///
/// Sin dejarle su hueco, los tres botones del sistema le quedan encima a lo
/// último de cada pantalla. En un teléfono con botones en pantalla eso no es
/// un detalle: el productor no sabe dónde dar, y toca "atrás" cuando quería
/// tocar "Seguir".
///
/// La franja se simula con `viewPadding` abajo, que es como se la informa
/// Android a la aplicación.
void main() {
  const barraDelTelefono = 48.0;

  /// Monta [pantalla] como si el teléfono tuviera la barra de botones.
  Future<void> conBarra(WidgetTester tester, Widget pantalla) async {
    pantallaAlta(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: temaCacao(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, hijo) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(bottom: barraDelTelefono),
            viewPadding: const EdgeInsets.only(bottom: barraDelTelefono),
          ),
          child: hijo!,
        ),
        home: pantalla,
      ),
    );
    await asentar(tester);
  }

  /// El borde de abajo de la pantalla de prueba (ver `pantallaAlta`), por
  /// donde pasa la barra del teléfono.
  const bordeDeAbajo = 2400.0;

  testWidgets('el fondo de la app no mete contenido bajo la barra', (
    tester,
  ) async {
    await conBarra(
      tester,
      const Scaffold(
        body: FondoCacao(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(key: Key('lo_de_abajo'), height: 20, width: 100),
          ),
        ),
      ),
    );

    final caja = tester.getRect(find.byKey(const Key('lo_de_abajo')));
    expect(
      caja.bottom,
      lessThanOrEqualTo(bordeDeAbajo - barraDelTelefono),
      reason: 'Lo último de la pantalla tiene que quedar por encima de los '
          'tres botones del teléfono, no debajo de ellos.',
    );
  });

  testWidgets('donde ya hay barra de pestañas, no deja hueco doble', (
    tester,
  ) async {
    await conBarra(
      tester,
      Scaffold(
        body: const FondoCacao(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(key: Key('lo_de_abajo'), height: 20, width: 100),
          ),
        ),
        bottomNavigationBar: SizedBox(
          key: const Key('barra'),
          height: 78 + barraDelTelefono,
        ),
      ),
    );

    final caja = tester.getRect(find.byKey(const Key('lo_de_abajo')));
    final barra = tester.getRect(find.byKey(const Key('barra')));
    expect(
      caja.bottom,
      barra.top,
      reason: 'La barra de pestañas ya se descontó del cuerpo; volver a '
          'descontar el hueco del teléfono dejaría una franja vacía entre el '
          'contenido y la barra.',
    );
  });

  group('con una finca de verdad', () {
    late AppDatabase db;
    late LoteRepository repo;
    late Lote lote;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      final perfil = PerfilRepository(
        db,
        usuarioId: await db.syncDao.identidadLocal(),
      );
      repo = LoteRepository(db);
      final productorId = await perfil.guardarProductor(nombreCompleto: 'D');
      final fincaId = await perfil.guardarFinca(
        productorId: productorId,
        nombre: 'El Porvenir',
        municipio: 'Calarcá',
        departamento: 'Quindío',
      );
      final loteId = await perfil.guardarLote(
        fincaId: fincaId,
        nombre: 'La Quebrada',
        areaSembradaHa: 3.2,
        variedadCacao: 'Criollo',
        fechaSiembra: DateTime(2018, 5, 2),
      );
      lote = (await perfil.watchLotes(fincaId).first).firstWhere(
        (l) => l.id == loteId,
      );
    });
    tearDown(() => db.close());

    testWidgets('los botones del asistente no quedan bajo la barra', (
      tester,
    ) async {
      await repo.registrarCosecha(
        loteId: lote.id,
        fecha: DateTime.now(),
        cantidadKg: 100,
        tipoProducto: 'Cacao seco',
      );
      await repo.registrarActividad(
        loteId: lote.id,
        tipo: TipoActividad.poda,
        fecha: DateTime.now(),
        costo: 400000,
      );
      await conBarra(tester, AsistenteCostoScreen(repo: repo, lote: lote));

      await tester.tap(find.textContaining('100 kg'));
      await asentar(tester);

      final boton = tester.getRect(
        find.byKey(const Key('asistente_seguir')),
      );
      expect(
        boton.bottom,
        lessThanOrEqualTo(bordeDeAbajo - barraDelTelefono),
        reason: 'Es la barra de botones fija del asistente: si queda bajo los '
            'del teléfono, al querer dar "Seguir" se sale de la aplicación.',
      );

      await desmontar(tester);
    });

    testWidgets('lo último de la cuenta no queda bajo la barra', (
      tester,
    ) async {
      await conBarra(
        tester,
        CostoPorKiloScreen(
          repo: repo,
          lote: lote,
          nombreFinca: 'El Porvenir',
        ),
      );

      final lista = tester.getRect(find.byType(ListView).first);
      expect(
        lista.bottom,
        lessThanOrEqualTo(bordeDeAbajo - barraDelTelefono),
        reason: 'La lista de gastos termina donde empieza la barra del '
            'teléfono, no debajo de ella.',
      );

      await desmontar(tester);
    });
  });
}
