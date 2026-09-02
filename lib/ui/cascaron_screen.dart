import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/lote_repository.dart';
import '../data/repositories/perfil_repository.dart';
import '../data/sync/sync_service.dart';
import 'dialogos/dialogo_actividad.dart';
import 'dialogos/dialogo_cosecha.dart';
import 'bienvenida_screen.dart';
import 'cuenta_screens.dart';
import 'inicio_screen.dart';
import 'perfil_screen.dart';
import 'tema.dart';
import 'widgets/comunes.dart';

/// El armazón de la app: inicio, perfil y el botón de anotar siempre a mano.
///
/// La idea es que anotar una labor o una cosecha no obligue a navegar hasta el
/// lote: en el campo se anota justo después de hacer la vuelta.
class CascaronScreen extends StatefulWidget {
  const CascaronScreen({
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

  /// Avisos de que volvió la señal. Se inyecta desde `main` con el plugin de
  /// conectividad; en los tests se deja en null y la app funciona igual, solo
  /// sin reintento automático.
  final Stream<List<ConnectivityResult>>? cambiosDeConexion;

  @override
  State<CascaronScreen> createState() => _CascaronScreenState();
}

class _CascaronScreenState extends State<CascaronScreen> {
  var _pestana = 0;
  StreamSubscription<List<ConnectivityResult>>? _conexion;

  @override
  void initState() {
    super.initState();
    // Un intento al abrir y otro cada vez que vuelve la señal. Si no hay red,
    // falla en silencio: lo anotado ya está guardado y la cinta del inicio
    // lleva la cuenta de lo que falta por mandar.
    unawaited(widget.sync.sincronizar());
    _escucharConexion();
  }

  void _escucharConexion() {
    _conexion = widget.cambiosDeConexion?.listen((estados) {
      final hayRed = estados.any((e) => e != ConnectivityResult.none);
      if (hayRed && !widget.sync.estado.value.sincronizando) {
        unawaited(widget.sync.sincronizar());
      }
    });
  }

  @override
  void dispose() {
    _conexion?.cancel();
    super.dispose();
  }

  Future<void> _anotar() async {
    final lotes = await _lotesDisponibles();
    if (!mounted) return;
    if (lotes.isEmpty) {
      avisar(context, 'Primero registre un lote');
      return;
    }

    final lote = lotes.length == 1
        ? lotes.first
        : await showModalBottomSheet<Lote>(
            context: context,
            builder: (_) => _ElegirLote(lotes: lotes),
          );
    if (lote == null || !mounted) return;

    final esCosecha = await showModalBottomSheet<bool>(
      context: context,
      builder: (_) => _ElegirTipo(lote: lote),
    );
    if (esCosecha == null || !mounted) return;

    if (esCosecha) {
      final datos = await pedirDatosCosecha(context);
      if (datos == null) return;
      await widget.lotesRepo.registrarCosecha(
        loteId: lote.id,
        fecha: datos.fecha,
        cantidadKg: datos.cantidadKg,
        observaciones: datos.observaciones,
      );
      if (mounted) avisar(context, 'Cosecha registrada');
    } else {
      final datos = await pedirDatosActividad(context);
      if (datos == null) return;
      await widget.lotesRepo.registrarActividad(
        loteId: lote.id,
        tipo: datos.tipo,
        fecha: datos.fecha,
        observaciones: datos.observaciones,
      );
      if (mounted) avisar(context, 'Labor registrada');
    }
  }

  Future<List<Lote>> _lotesDisponibles() async {
    final productor = await widget.repo.watchProductor().first;
    if (productor == null) return const [];
    final finca = await widget.repo.watchFinca(productor.id).first;
    if (finca == null) return const [];
    return widget.repo.watchLotes(finca.id).first;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Productor?>(
      stream: widget.repo.watchProductor(),
      builder: (context, snapshot) {
        // Durante el registro no hay barra ni botón: no hay nada que anotar
        // todavía y el productor solo tiene un camino por delante.
        if (snapshot.connectionState != ConnectionState.waiting &&
            snapshot.data == null) {
          return StreamBuilder<SesionLocal?>(
            stream: widget.db.syncDao.watchSesion(),
            builder: (context, sesion) {
              // Si se está entrando con una cuenta existente, la primera
              // descarga manda: hasta que termine no se puede ofrecer crear un
              // perfil, o quedarían dos productores en la misma cuenta.
              if (sesion.data?.descargaInicial == false) {
                return RecuperandoScreen(sync: widget.sync);
              }
              return Scaffold(
                body: BienvenidaScreen(repo: widget.repo, sync: widget.sync),
              );
            },
          );
        }
        return _armazon(context);
      },
    );
  }

  Widget _armazon(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pestana,
        children: [
          InicioScreen(
            repo: widget.repo,
            lotesRepo: widget.lotesRepo,
            db: widget.db,
            sync: widget.sync,
          ),
          PerfilScreen(repo: widget.repo, db: widget.db, sync: widget.sync),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _anotar,
        backgroundColor: PaletaCacao.maduro,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Anotar',
        child: const Icon(Icons.add, size: 40),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        height: 78,
        // Sin esto, el relleno propio de la barra deja 54 px útiles y el
        // contenido (ícono + etiqueta) se desborda.
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BotonBarra(
              icono: Icons.home_rounded,
              texto: 'Inicio',
              activo: _pestana == 0,
              onTap: () => setState(() => _pestana = 0),
            ),
            const SizedBox(width: 72),
            _BotonBarra(
              icono: Icons.person_rounded,
              texto: 'Perfil',
              activo: _pestana == 1,
              onTap: () => setState(() => _pestana = 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonBarra extends StatelessWidget {
  const _BotonBarra({
    required this.icono,
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  final IconData icono;
  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = activo
        ? PaletaCacao.cafe
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 30, color: color),
            const SizedBox(height: 2),
            Text(
              texto,
              style: TextStyle(
                fontSize: 14,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElegirLote extends StatelessWidget {
  const _ElegirLote({required this.lotes});

  final List<Lote> lotes;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text('¿En cuál lote?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final lote in lotes)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 6,
              ),
              leading: const Icon(Icons.park_rounded, size: 32),
              title: Text(
                lote.nombre,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: () => Navigator.of(context).pop(lote),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ElegirTipo extends StatelessWidget {
  const _ElegirTipo({required this.lote});

  final Lote lote;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Qué va a anotar en ${lote.nombre}?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: PaletaCacao.verde),
              onPressed: () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.agriculture_rounded, size: 30),
              label: const Text('Una labor'),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: PaletaCacao.maduro,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.shopping_basket_rounded, size: 30),
              label: const Text('Una cosecha'),
            ),
          ],
        ),
      ),
    );
  }
}
