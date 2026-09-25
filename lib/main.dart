import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/local/database.dart';
import 'data/repositories/lote_repository.dart';
import 'data/repositories/perfil_repository.dart';

import 'data/sync/api_apps_script.dart';
import 'data/sync/api_falsa.dart';
import 'data/sync/api_remota.dart';
import 'data/sync/autenticador_google.dart';
import 'data/sync/config_nube.dart';
import 'data/sync/sync_service.dart';
import 'ui/cascaron_screen.dart';
import 'ui/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sin esto, un error de dibujo deja la pantalla **en blanco** y nadie sabe
  // qué pasó: en el navegador no hay consola a la vista ni forma de contarlo.
  // Mostrar el motivo es la diferencia entre un reporte útil y un "no sirve".
  ErrorWidget.builder = (detalles) => _PantallaDeError(
    mensaje: detalles.exceptionAsString(),
  );
  final db = AppDatabase();

  // La identidad se resuelve sin red: la app tiene que poder crear el perfil
  // aunque nunca haya visto internet.
  final usuarioId = await db.syncDao.identidadLocal();
  final sesion = await db.syncDao.sesionActual();

  // Con servidor configurado se habla con Apps Script; sin él, con el doble en
  // memoria. La app funciona igual en los dos casos: lo que cambia es a dónde
  // van los datos, no cómo se guardan aquí.
  //
  // La sesión guardada se restaura de una: así quien ya entró alguna vez no
  // vuelve a ver la pantalla de Google en cada arranque.
  final ApiRemota api;
  if (hayNube) {
    final google = AutenticadorGoogle();
    // En la web hay que tener listo el paquete antes de dibujar el botón de
    // Google; en Android da igual, pero cuesta nada y deja un solo camino.
    await google.preparar();
    api = ApiAppsScript(
      url: Uri.parse(urlNube),
      pedirIdTokenAGoogle: google.idToken,
      salirDeGoogle: google.salir,
      token: sesion?.tokenNube,
      usuarioId: sesion?.authUid,
    );
  } else {
    api = ApiRemotaFalsa();
  }

  runApp(
    CacaoApp(
      repo: PerfilRepository(db, usuarioId: usuarioId),
      lotesRepo: LoteRepository(db),
      db: db,
      sync: SyncService(baseDatos: db, apiRemota: api, usuarioLocal: usuarioId),
    ),
  );
}

/// Lo que se ve cuando algo se rompe dibujando.
class _PantallaDeError extends StatelessWidget {
  const _PantallaDeError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFFFBF2EA),
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Algo falló en la aplicación',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF33200F),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                mensaje,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6E5A4C)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CacaoApp extends StatelessWidget {
  const CacaoApp({
    super.key,
    required this.repo,
    required this.lotesRepo,
    required this.db,
    required this.sync,
    this.cambiosDeConexion,
  });

  final PerfilRepository repo;
  final LoteRepository lotesRepo;
  final AppDatabase db;
  final SyncService sync;

  /// Avisos de que volvió la señal; llega desde `main` con el plugin real.
  final Stream<List<ConnectivityResult>>? cambiosDeConexion;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cacaiva',
      debugShowCheckedModeBanner: false,
      theme: temaCacao(),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: CascaronScreen(
        repo: repo,
        lotesRepo: lotesRepo,
        db: db,
        sync: sync,
        cambiosDeConexion: cambiosDeConexion,
      ),
    );
  }
}
