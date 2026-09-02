import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/local/database.dart';
import 'data/repositories/lote_repository.dart';
import 'data/repositories/perfil_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/sync/api_falsa.dart';
import 'data/sync/api_remota.dart';
import 'data/sync/api_supabase.dart';
import 'data/sync/config_supabase.dart';
import 'data/sync/sync_service.dart';
import 'ui/cascaron_screen.dart';
import 'ui/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();

  // La identidad se resuelve sin red: la app tiene que poder crear el perfil
  // aunque nunca haya visto internet.
  final usuarioId = await db.syncDao.identidadLocal();

  // Con llave configurada se habla con Supabase; sin ella, con el doble en
  // memoria. La app funciona igual en los dos casos: lo que cambia es a dónde
  // van los datos, no cómo se guardan aquí.
  final ApiRemota api;
  if (ConfigSupabase.hayBackend) {
    await Supabase.initialize(
      url: ConfigSupabase.url,
      publishableKey: ConfigSupabase.llavePublica,
    );
    api = ApiSupabase(Supabase.instance.client);
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
      title: 'Red Nacional de Cacao',
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
