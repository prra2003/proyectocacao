import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/lote_repository.dart';
import '../data/repositories/perfil_repository.dart';
import '../data/repositories/reportes_repository.dart';
import '../data/sync/sync_service.dart';
import 'dialogos/dialogo_actividad.dart';
import 'dialogos/dialogo_cosecha.dart';
import 'bienvenida_screen.dart';
import 'cuenta_screens.dart';
import 'inicio_screen.dart';
import 'perfil_screen.dart';
import 'reportes_screen.dart';
import 'tema.dart';
import 'widgets/comunes.dart';
import 'widgets/confirmacion_guardado.dart';

/// Un lote y el nombre de la finca a la que pertenece, para poder mostrarlo
/// en la lista de "¿en cuál lote?" cuando el productor tiene varias fincas.
typedef LoteConFinca = ({Lote lote, String fincaNombre});

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
  // RNF-02: respaldo periódico. El intervalo es largo y con backoff a
  // propósito (RNF-01): en campo, con datos móviles y señal intermitente, no
  // conviene insistir cada pocos minutos si ya se sabe que está fallando.
  static const _intervaloBase = Duration(minutes: 15);
  static const _intervaloMaximo = Duration(minutes: 60);

  var _pestana = 0;
  late final _reportesRepo = ReportesRepository(widget.db);
  StreamSubscription<List<ConnectivityResult>>? _conexion;
  Timer? _reintentoPeriodico;
  var _fallosSeguidos = 0;
  DateTime? _proximoIntentoPermitido;

  @override
  void initState() {
    super.initState();
    // Un intento al abrir y otro cada vez que vuelve la señal. Si no hay red,
    // falla en silencio: lo anotado ya está guardado y la cinta del inicio
    // lleva la cuenta de lo que falta por mandar.
    unawaited(widget.sync.sincronizar());
    _escucharConexion();
    _reintentoPeriodico = Timer.periodic(
      _intervaloBase,
      (_) => unawaited(_intentoPeriodico()),
    );
  }

  void _escucharConexion() {
    _conexion = widget.cambiosDeConexion?.listen((estados) {
      final hayRed = estados.any((e) => e != ConnectivityResult.none);
      if (hayRed && !widget.sync.estado.value.sincronizando) {
        unawaited(widget.sync.sincronizar());
      }
    });
  }

  /// Reintento de fondo cada [_intervaloBase], salvo que los últimos intentos
  /// hayan fallado: entonces se espera más (15 → 30 → 60 min) para no gastar
  /// datos móviles insistiendo contra una señal que ya se sabe mala.
  Future<void> _intentoPeriodico() async {
    if (widget.sync.estado.value.sincronizando) return;
    final ahora = DateTime.now();
    if (_proximoIntentoPermitido != null &&
        ahora.isBefore(_proximoIntentoPermitido!)) {
      return;
    }
    final resultado = await widget.sync.sincronizar();
    if (resultado.ok) {
      _fallosSeguidos = 0;
      _proximoIntentoPermitido = null;
      return;
    }
    _fallosSeguidos++;
    final espera = _intervaloBase * (1 << _fallosSeguidos);
    _proximoIntentoPermitido = ahora.add(
      espera > _intervaloMaximo ? _intervaloMaximo : espera,
    );
  }

  @override
  void dispose() {
    _conexion?.cancel();
    _reintentoPeriodico?.cancel();
    super.dispose();
  }

  Future<void> _anotar() async {
    final disponibles = await _lotesDisponibles();
    if (!mounted) return;
    if (disponibles.isEmpty) {
      avisar(context, 'Primero registre un lote');
      return;
    }

    final lote = disponibles.length == 1
        ? disponibles.first.lote
        : await showModalBottomSheet<Lote>(
            context: context,
            builder: (_) => _ElegirLote(disponibles: disponibles),
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
        tipoProducto: datos.tipoProducto,
        fotoPath: datos.fotoPath,
      );
      if (mounted) {
        mostrarConfirmacionGuardado(context, mensaje: 'Cosecha registrada');
      }
    } else {
      final datos = await pedirDatosActividad(context, loteNombre: lote.nombre);
      if (datos == null) return;
      await guardarLabor(widget.lotesRepo, lote, datos);
      if (mounted) {
        mostrarConfirmacionGuardado(context, mensaje: 'Labor registrada');
      }
    }
  }

  /// Todos los lotes de todas las fincas del productor, cada uno con el
  /// nombre de su finca — el botón de anotar no depende de cuál finca esté
  /// seleccionada en la pantalla de Inicio o Reportes en ese momento.
  Future<List<LoteConFinca>> _lotesDisponibles() async {
    final productor = await widget.repo.watchProductor().first;
    if (productor == null) return const [];
    final fincas = await widget.repo.watchFincas(productor.id).first;
    final disponibles = <LoteConFinca>[];
    for (final finca in fincas) {
      final lotes = await widget.repo.watchLotes(finca.id).first;
      for (final lote in lotes) {
        disponibles.add((lote: lote, fincaNombre: finca.nombre));
      }
    }
    return disponibles;
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
      body: _CuerpoAnimado(
        indice: _pestana,
        hijos: [
          InicioScreen(
            repo: widget.repo,
            lotesRepo: widget.lotesRepo,
            db: widget.db,
            sync: widget.sync,
          ),
          ReportesScreen(
            repo: widget.repo,
            lotesRepo: widget.lotesRepo,
            reportesRepo: _reportesRepo,
          ),
          PerfilScreen(repo: widget.repo, db: widget.db, sync: widget.sync),
        ],
      ),
      // Con palabra y no solo el "+": se entiende sin adivinar qué hace. Va
      // flotando sobre la barra y no encajado en ella, así la barra reparte
      // su ancho entre tres botones grandes en vez de dejar un hueco.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _anotar,
        backgroundColor: PaletaCacao.maduro,
        foregroundColor: Colors.white,
        tooltip: 'Anotar',
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Anotar',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // Tres pestañas: "Mis lotes" salió de aquí porque los lotes ya están en
      // el Inicio y en Reportes.
      bottomNavigationBar: BottomAppBar(
        color: PaletaCacao.tarjeta,
        height: 78,
        // Sin esto, el relleno propio de la barra deja 54 px útiles y el
        // contenido (ícono + etiqueta) se desborda.
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
              child: _BotonBarra(
                icono: Icons.home_rounded,
                texto: 'Inicio',
                activo: _pestana == 0,
                onTap: () => setState(() => _pestana = 0),
              ),
            ),
            Expanded(
              child: _BotonBarra(
                icono: Icons.bar_chart_rounded,
                texto: 'Reportes',
                activo: _pestana == 1,
                onTap: () => setState(() => _pestana = 1),
              ),
            ),
            Expanded(
              child: _BotonBarra(
                icono: Icons.person_rounded,
                texto: 'Perfil',
                activo: _pestana == 2,
                onTap: () => setState(() => _pestana = 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// El `IndexedStack` que muestra Inicio/Reportes/Perfil no pasa por ninguna
/// `Route`, así que la transición de `RutaCacao` no le llegaba: cambiar de
/// pestaña en la barra de abajo se sentía "de golpe" mientras todo lo demás
/// ya giraba. Este widget mantiene el `IndexedStack` (cada pestaña conserva
/// su estado y su scroll) pero le monta encima el mismo giro + desvanecido
/// que usa `RutaCacao`, disparado cada vez que cambia el índice.
class _CuerpoAnimado extends StatefulWidget {
  const _CuerpoAnimado({required this.indice, required this.hijos});

  final int indice;
  final List<Widget> hijos;

  @override
  State<_CuerpoAnimado> createState() => _CuerpoAnimadoState();
}

class _CuerpoAnimadoState extends State<_CuerpoAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    // Misma duración que `RutaCacao`, para que se sienta igual de rápido
    // en toda la app y no distinto según por dónde se navegue.
    duration: const Duration(milliseconds: 180),
  )..forward();

  @override
  void didUpdateWidget(covariant _CuerpoAnimado anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.indice != widget.indice) {
      _controlador.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entrada = CurvedAnimation(
      parent: _controlador,
      curve: Curves.easeOutCubic,
    );
    return AnimatedBuilder(
      animation: entrada,
      child: IndexedStack(index: widget.indice, children: widget.hijos),
      builder: (context, hijo) {
        // El mismo desvanecido corto que la transición entre páginas.
        return Opacity(opacity: entrada.value, child: hijo);
      },
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
        ? PaletaCacao.dorado
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 31, color: color),
            const SizedBox(height: 2),
            Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
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
  const _ElegirLote({required this.disponibles});

  final List<LoteConFinca> disponibles;

  @override
  Widget build(BuildContext context) {
    // Con una sola finca no hace falta repetir su nombre en cada fila.
    final variasFincas =
        disponibles.map((d) => d.fincaNombre).toSet().length > 1;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text('¿En cuál lote?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final disponible in disponibles)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 6,
              ),
              leading: const Icon(Icons.park_rounded, size: 32),
              title: Text(
                disponible.lote.nombre,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: variasFincas ? Text(disponible.fincaNombre) : null,
              onTap: () => Navigator.of(context).pop(disponible.lote),
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
