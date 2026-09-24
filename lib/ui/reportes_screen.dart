import 'package:flutter/material.dart';

import '../data/daos/daos.dart';
import '../data/local/database.dart';
import '../data/local/enums.dart';
import '../data/repositories/lote_repository.dart';
import '../data/repositories/perfil_repository.dart';
import '../data/repositories/reportes_repository.dart';
import '../data/servicios/exportador_excel.dart';
import '../data/servicios/exportador_historial_productor.dart';
import '../data/servicios/exportador_pdf.dart';
import 'formato.dart';
import 'lote_detalle_screen.dart';
import 'tema.dart';
import 'widgets/comunes.dart';

/// Valor especial de selección: "ver todas las fincas juntas", en vez de una
/// finca puntual.
const _todasLasFincas = '__todas__';

/// "¿Cómo va la finca en total?": indicadores de gestión y el historial
/// completo de todos los lotes en una sola línea de tiempo, con filtros.
///
/// Igual que en Inicio, un productor puede tener varias fincas (RF-02), pero
/// acá además se pueden ver **todas juntas**: es lo que responde "¿cómo va el
/// productor en total?", no solo una finca suelta (RF-08).
class ReportesScreen extends StatefulWidget {
  const ReportesScreen({
    super.key,
    required this.repo,
    required this.lotesRepo,
    required this.reportesRepo,
  });

  final PerfilRepository repo;
  final LoteRepository lotesRepo;
  final ReportesRepository reportesRepo;

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  String? _seleccionId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Productor?>(
      stream: widget.repo.watchProductor(),
      builder: (context, snapshotProductor) {
        final productor = snapshotProductor.data;
        if (productor == null) {
          return const SizedBox.shrink();
        }
        return StreamBuilder<List<Finca>>(
          stream: widget.repo.watchFincas(productor.id),
          builder: (context, snapshotFincas) {
            final fincas = snapshotFincas.data ?? const <Finca>[];
            if (fincas.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: EstadoVacio(
                    icono: Icons.bar_chart_rounded,
                    titulo: 'Todavía no hay nada que reportar',
                    mensaje:
                        'Registre su finca y sus lotes para ver aquí la '
                        'producción y el historial.',
                  ),
                ),
              );
            }
            // Con varias fincas, si el productor no ha elegido nada todavía
            // se parte viendo todas juntas.
            final seleccionId =
                _seleccionId ??
                (fincas.length > 1 ? _todasLasFincas : fincas.first.id);
            final verTodas =
                fincas.length > 1 && seleccionId == _todasLasFincas;
            final finca = verTodas
                ? null
                : fincas.firstWhere(
                    (f) => f.id == seleccionId,
                    orElse: () => fincas.first,
                  );
            return _ReportesContenido(
              repo: widget.repo,
              lotesRepo: widget.lotesRepo,
              reportesRepo: widget.reportesRepo,
              productorId: productor.id,
              finca: finca,
              fincas: fincas,
              seleccionId: seleccionId,
              onSeleccionarFinca: (id) => setState(() => _seleccionId = id),
            );
          },
        );
      },
    );
  }
}

class _ReportesContenido extends StatefulWidget {
  const _ReportesContenido({
    required this.repo,
    required this.lotesRepo,
    required this.reportesRepo,
    required this.productorId,
    required this.finca,
    required this.fincas,
    required this.seleccionId,
    required this.onSeleccionarFinca,
  });

  final PerfilRepository repo;
  final LoteRepository lotesRepo;
  final ReportesRepository reportesRepo;
  final String productorId;

  /// null = se está viendo la vista combinada de todas las fincas.
  final Finca? finca;
  final List<Finca> fincas;
  final String seleccionId;
  final ValueChanged<String> onSeleccionarFinca;

  @override
  State<_ReportesContenido> createState() => _ReportesContenidoState();
}

class _ReportesContenidoState extends State<_ReportesContenido>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// El nombre del productor, los lotes y las labores/cosechas de cada uno,
  /// en un solo PDF organizado por finca y por lote. Respeta el selector de
  /// arriba: si el productor eligió una finca puntual, descarga solo esa
  /// finca; si eligió "Todas mis fincas" (o solo tiene una), descarga todo.
  /// Así, con varias fincas, el productor decide cuál se lleva.
  Future<void> _exportarHistorial(
    BuildContext context,
    DateTimeRange? rango,
  ) async {
    final productor = await widget.repo.watchProductor().first;
    if (productor == null || !context.mounted) return;
    final finca = widget.finca;
    await exportarHistorialProductorAPdf(
      context,
      repo: widget.repo,
      lotesRepo: widget.lotesRepo,
      productor: productor,
      fincas: finca == null ? widget.fincas : [finca],
      rango: rango,
    );
  }

  @override
  Widget build(BuildContext context) {
    final finca = widget.finca;
    final streamIndicadores = finca == null
        ? widget.reportesRepo.watchIndicadoresProductor(widget.productorId)
        : widget.reportesRepo.watchIndicadores(finca.id);
    final streamHistorial = finca == null
        ? widget.reportesRepo.watchHistorialProductor(widget.productorId)
        : widget.reportesRepo.watchHistorial(finca.id);
    final streamLotes = finca == null
        ? widget.repo.watchLotesDeProductor(widget.productorId)
        : widget.repo.watchLotes(finca.id);

    return Scaffold(
      appBar: cabeceraCacao(
        titulo: _SelectorFincaReportes(
          fincas: widget.fincas,
          seleccionId: widget.seleccionId,
          onSeleccionar: widget.onSeleccionarFinca,
        ),
        abajo: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Indicadores'),
            Tab(text: 'Historial'),
            Tab(text: 'Mis lotes'),
          ],
        ),
      ),
      body: FondoCacao(
        child: TabBarView(
          controller: _tabs,
          children: [
            _PestanaIndicadores(stream: streamIndicadores),
            _PestanaHistorial(
              streamHistorial: streamHistorial,
              streamLotes: streamLotes,
              mostrarFinca: finca == null,
              tituloExportacion: finca?.nombre ?? 'Todas mis fincas',
              onExportarCompleto: (rango) =>
                  _exportarHistorial(context, rango),
            ),
            PestanaLotes(
              repo: widget.repo,
              lotesRepo: widget.lotesRepo,
              productorId: widget.productorId,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selector: una finca puntual, o todas juntas
// ---------------------------------------------------------------------------

class _SelectorFincaReportes extends StatelessWidget {
  const _SelectorFincaReportes({
    required this.fincas,
    required this.seleccionId,
    required this.onSeleccionar,
  });

  final List<Finca> fincas;
  final String seleccionId;
  final ValueChanged<String> onSeleccionar;

  bool get _esTodas => seleccionId == _todasLasFincas;

  Future<void> _abrirSelector(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Sus fincas', style: Theme.of(contexto).textTheme.titleLarge),
            const SizedBox(height: 4),
            if (fincas.length > 1)
              ListTile(
                leading: Icon(
                  _esTodas
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off_outlined,
                  color: _esTodas
                      ? Theme.of(contexto).colorScheme.primary
                      : Theme.of(contexto).colorScheme.outline,
                ),
                title: const Text('Todas mis fincas'),
                subtitle: Text('${fincas.length} fincas juntas'),
                onTap: () {
                  Navigator.of(contexto).pop();
                  onSeleccionar(_todasLasFincas);
                },
              ),
            for (final finca in fincas)
              ListTile(
                leading: Icon(
                  !_esTodas && finca.id == seleccionId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off_outlined,
                  color: !_esTodas && finca.id == seleccionId
                      ? Theme.of(contexto).colorScheme.primary
                      : Theme.of(contexto).colorScheme.outline,
                ),
                title: Text(finca.nombre),
                subtitle: Text('${finca.municipio}, ${finca.departamento}'),
                onTap: () {
                  Navigator.of(contexto).pop();
                  onSeleccionar(finca.id);
                },
              ),
            // Agregar o editar fincas se hace en un solo lugar: tocando el
            // nombre de la finca en el Inicio. Aquí solo se elige qué mirar.
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finca = _esTodas
        ? null
        : fincas.firstWhere(
            (f) => f.id == seleccionId,
            orElse: () => fincas.first,
          );
    final nombre = _esTodas ? 'Todas mis fincas' : finca!.nombre;
    final subtitulo = _esTodas ? '${fincas.length} fincas' : finca!.municipio;
    return InkWell(
      onTap: () => _abrirSelector(context),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nombre,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xCCFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.unfold_more_rounded,
              color: Color(0xCCFFFFFF),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Indicadores
// ---------------------------------------------------------------------------

class _PestanaIndicadores extends StatelessWidget {
  const _PestanaIndicadores({required this.stream});

  final Stream<IndicadoresFinca> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<IndicadoresFinca>(
      stream: stream,
      builder: (context, snapshot) {
        final datos = snapshot.data;
        if (datos == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Indicador(
                      color: PaletaCacao.maduro,
                      icono: Icons.shopping_basket_outlined,
                      valor: numeroCorto(datos.produccionTotalKg),
                      etiqueta: 'kg en total',
                    ),
                    Indicador(
                      color: PaletaCacao.verde,
                      icono: Icons.agriculture_outlined,
                      valor: '${datos.actividadesRealizadas}',
                      etiqueta: datos.actividadesRealizadas == 1
                          ? 'labor'
                          : 'labores',
                    ),
                    Indicador(
                      color: PaletaCacao.cafe,
                      icono: Icons.receipt_long_outlined,
                      valor: '${datos.cosechasRegistradas}',
                      etiqueta: datos.cosechasRegistradas == 1
                          ? 'cosecha'
                          : 'cosechas',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const TituloSeccion('Rendimiento por lote'),
            const SizedBox(height: 6),
            Text(
              'Kilos cosechados por hectárea sembrada, de mayor a menor.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            if (datos.rendimientoPorLote.isEmpty)
              const Card(
                child: EstadoVacio(
                  compacto: true,
                  titulo: 'Sin lotes todavía',
                  mensaje:
                      'El rendimiento aparece cuando haya lotes y cosechas.',
                ),
              )
            else
              for (final lote in datos.rendimientoPorLote)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: PaletaCacao.verdeClaro,
                            child: const Icon(
                              Icons.forest_outlined,
                              color: PaletaCacao.verde,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lote.loteNombre,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                Text(
                                  lote.fincaNombre == null
                                      ? '${numeroCorto(lote.kgTotales)} kg · '
                                            '${numeroCorto(lote.areaHa)} ha'
                                      : '${numeroCorto(lote.kgTotales)} kg · '
                                            '${numeroCorto(lote.areaHa)} ha · '
                                            '${lote.fincaNombre}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${numeroCorto(lote.kgPorHectarea)}\nkg/ha',
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: PaletaCacao.maduro),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Mis lotes: todas las fincas del productor, cada una con sus lotes debajo.
// ---------------------------------------------------------------------------

/// Vista "por finca y por productor" del documento de requerimientos: junta
/// todas las fincas del productor y, debajo de cada una, sus lotes. No
/// depende del selector de arriba (que es solo para Indicadores/Historial):
/// acá siempre se ven todas juntas, que es lo que pide el requerimiento.

class PestanaLotes extends StatelessWidget {
  const PestanaLotes({
    super.key,
    required this.repo,
    required this.lotesRepo,
    required this.productorId,
  });

  final PerfilRepository repo;
  final LoteRepository lotesRepo;
  final String productorId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Finca>>(
      stream: repo.watchFincas(productorId),
      builder: (context, snapshot) {
        final fincas = snapshot.data;
        if (fincas == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (fincas.isEmpty) {
          return const SingleChildScrollView(
            child: EstadoVacio(
              icono: Icons.holiday_village_outlined,
              titulo: 'Sin fincas todavía',
              mensaje: 'Registre su finca para ver aquí sus lotes agrupados.',
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            for (final finca in fincas)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _TarjetaFincaConLotes(
                  finca: finca,
                  repo: repo,
                  lotesRepo: lotesRepo,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TarjetaFincaConLotes extends StatelessWidget {
  const _TarjetaFincaConLotes({
    required this.finca,
    required this.repo,
    required this.lotesRepo,
  });

  final Finca finca;
  final PerfilRepository repo;
  final LoteRepository lotesRepo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.holiday_village_outlined,
                  color: PaletaCacao.cafe,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        finca.nombre,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${finca.municipio}, ${finca.departamento}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            StreamBuilder<List<Lote>>(
              stream: repo.watchLotes(finca.id),
              builder: (context, snapshotLotes) {
                final lotes = snapshotLotes.data ?? const <Lote>[];
                if (lotes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Sin lotes todavía',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final lote in lotes)
                      _FilaLote(lote: lote, lotesRepo: lotesRepo),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaLote extends StatelessWidget {
  const _FilaLote({required this.lote, required this.lotesRepo});

  final Lote lote;
  final LoteRepository lotesRepo;

  @override
  Widget build(BuildContext context) {
    final edad = PerfilRepository.edadEnAnios(lote.fechaSiembra);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.forest_outlined, color: PaletaCacao.verde),
      title: Text(
        lote.codigo.isNotEmpty
            ? '${lote.codigo} · ${lote.nombre}'
            : lote.nombre,
      ),
      subtitle: Text(
        '${numeroCorto(lote.areaSembradaHa)} ha · '
        '${edad == 1 ? '1 año' : '$edad años'}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        RutaCacao<void>(
          builder: (_) => LoteDetalleScreen(repo: lotesRepo, lote: lote),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Historial
// ---------------------------------------------------------------------------

enum _FiltroTipo { todos, actividades, cosechas, diagnosticos }

class _PestanaHistorial extends StatefulWidget {
  const _PestanaHistorial({
    required this.streamHistorial,
    required this.streamLotes,
    required this.mostrarFinca,
    required this.tituloExportacion,
    required this.onExportarCompleto,
  });

  final Stream<List<EventoHistorial>> streamHistorial;
  final Stream<List<Lote>> streamLotes;

  /// true en la vista "Todas mis fincas": cada fila muestra de qué finca es.
  final bool mostrarFinca;

  /// Nombre de la finca (o "Todas mis fincas") para el título del archivo
  /// exportado.
  final String tituloExportacion;

  /// El PDF completo por finca y por lote (el que antes salía desde tres
  /// botones distintos: arriba en Reportes, en Mis lotes y en cada finca).
  final ValueChanged<DateTimeRange?> onExportarCompleto;

  @override
  State<_PestanaHistorial> createState() => _PestanaHistorialState();
}

class _PestanaHistorialState extends State<_PestanaHistorial> {
  var _filtroTipo = _FiltroTipo.todos;
  String? _loteId;
  DateTimeRange? _rango;

  Future<void> _elegirRango(BuildContext context) async {
    final ahora = DateTime.now();
    final elegido = await showDateRangePicker(
      context: context,
      firstDate: DateTime(ahora.year - 15),
      lastDate: ahora,
      initialDateRange: _rango,
      locale: const Locale('es'),
    );
    if (elegido != null) setState(() => _rango = elegido);
  }

  /// Encabezados y filas de texto listos para exportar, a partir de los
  /// eventos ya filtrados: la misma tabla que se ve en pantalla, sea para
  /// Excel o para PDF.
  (List<String>, List<List<String>>) _tabla(List<EventoHistorial> eventos) {
    final encabezados = <String>[
      'Fecha',
      'Tipo',
      if (widget.mostrarFinca) 'Finca',
      'Lote',
      'Detalle',
      'Cantidad (kg)',
    ];
    final filas = <List<String>>[];
    for (final evento in eventos) {
      final (tipo, detalle) = switch (evento.tipo) {
        TipoEvento.actividad => (
          etiquetaActividad(TipoActividad.values.byName(evento.subtipo!)),
          evento.detalle ?? '',
        ),
        TipoEvento.cosecha => ('Cosecha', evento.detalle ?? ''),
        TipoEvento.diagnostico => (
          etiquetaEstado(EstadoFenologico.values.byName(evento.subtipo!)),
          evento.detalle ?? '',
        ),
      };
      // Lo anotado va junto con las observaciones: si no, la descarga salía
      // más pobre que la pantalla, y es la que termina en manos del técnico.
      final completo = [
        for (final (etiqueta, valor) in evento.anotado) '$etiqueta: $valor',
        if (detalle.trim().isNotEmpty) detalle.trim(),
      ].join(' · ');
      filas.add([
        fechaLarga(evento.fecha),
        tipo,
        if (widget.mostrarFinca) evento.fincaNombre ?? '',
        evento.loteNombre,
        completo,
        evento.cantidadKg == null ? '' : numeroCorto(evento.cantidadKg!),
      ]);
    }
    return (encabezados, filas);
  }

  List<EventoHistorial> _filtrar(List<EventoHistorial> eventos) {
    return eventos.where((evento) {
      final pasaTipo = switch (_filtroTipo) {
        _FiltroTipo.todos => true,
        _FiltroTipo.actividades => evento.tipo == TipoEvento.actividad,
        _FiltroTipo.cosechas => evento.tipo == TipoEvento.cosecha,
        _FiltroTipo.diagnosticos => evento.tipo == TipoEvento.diagnostico,
      };
      final pasaLote = _loteId == null || evento.loteId == _loteId;
      final pasaFecha =
          _rango == null ||
          (!evento.fecha.isBefore(_rango!.start) &&
              !evento.fecha.isAfter(_rango!.end.add(const Duration(days: 1))));
      return pasaTipo && pasaLote && pasaFecha;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lote>>(
      stream: widget.streamLotes,
      builder: (context, snapshotLotes) {
        final lotes = snapshotLotes.data ?? const <Lote>[];
        return StreamBuilder<List<EventoHistorial>>(
          stream: widget.streamHistorial,
          builder: (context, snapshot) {
            final eventos = snapshot.data;
            if (eventos == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final filtrados = _filtrar(eventos);
            return Column(
              children: [
                _BarraFiltros(
                  filtroTipo: _filtroTipo,
                  onTipo: (t) => setState(() => _filtroTipo = t),
                  lotes: lotes,
                  loteId: _loteId,
                  onLote: (id) => setState(() => _loteId = id),
                  rango: _rango,
                  onRango: () => _elegirRango(context),
                  onLimpiarRango: () => setState(() => _rango = null),
                  onExportarCompleto: () =>
                      widget.onExportarCompleto(_rango),
                  onExportarExcel: () {
                    final (encabezados, filas) = _tabla(filtrados);
                    exportarTablaAExcel(
                      context,
                      tituloHoja: 'Historial',
                      encabezados: encabezados,
                      filas: filas,
                      nombreArchivo: 'historial_${widget.tituloExportacion}',
                      tituloComparticion:
                          'Historial de ${widget.tituloExportacion}',
                    );
                  },
                  onExportarPdf: () {
                    final (encabezados, filas) = _tabla(filtrados);
                    exportarTablaAPdf(
                      context,
                      titulo: 'Historial de ${widget.tituloExportacion}',
                      subtitulo: 'Generado el ${fechaLarga(DateTime.now())}',
                      encabezados: encabezados,
                      filas: filas,
                      nombreArchivo: 'historial_${widget.tituloExportacion}',
                    );
                  },
                ),
                Expanded(
                  child: filtrados.isEmpty
                      ? SingleChildScrollView(
                          child: EstadoVacio(
                            icono: Icons.history,
                            titulo: eventos.isEmpty
                                ? 'Sin historial todavía'
                                : 'Nada con estos filtros',
                            mensaje: eventos.isEmpty
                                ? 'Las labores, cosechas y diagnósticos que '
                                      'anote van a aparecer aquí.'
                                : 'Pruebe a quitar algún filtro.',
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          itemCount: filtrados.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, i) => _FilaEvento(
                            evento: filtrados[i],
                            mostrarFinca: widget.mostrarFinca,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _BarraFiltros extends StatelessWidget {
  const _BarraFiltros({
    required this.filtroTipo,
    required this.onTipo,
    required this.lotes,
    required this.loteId,
    required this.onLote,
    required this.rango,
    required this.onRango,
    required this.onLimpiarRango,
    required this.onExportarCompleto,
    required this.onExportarExcel,
    required this.onExportarPdf,
  });

  final _FiltroTipo filtroTipo;
  final ValueChanged<_FiltroTipo> onTipo;
  final List<Lote> lotes;
  final String? loteId;
  final ValueChanged<String?> onLote;
  final DateTimeRange? rango;
  final VoidCallback onRango;
  final VoidCallback onLimpiarRango;

  final VoidCallback onExportarCompleto;

  /// Exportan exactamente lo que se ve con los filtros actuales.
  final VoidCallback onExportarExcel;
  final VoidCallback onExportarPdf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final MapEntry(key: tipo, value: etiqueta) in const {
                  _FiltroTipo.todos: 'Todos',
                  _FiltroTipo.actividades: 'Labores',
                  _FiltroTipo.cosechas: 'Cosechas',
                  _FiltroTipo.diagnosticos: 'Diagnósticos',
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(etiqueta),
                      selected: filtroTipo == tipo,
                      onSelected: (_) => onTipo(tipo),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: loteId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Lote',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    for (final lote in lotes)
                      DropdownMenuItem(
                        value: lote.id,
                        child: Text(lote.nombre),
                      ),
                  ],
                  onChanged: onLote,
                ),
              ),
              const SizedBox(width: 10),
              // Con palabra y no solo el ícono: el calendario suelto entre
              // el lote y el botón de compartir pasaba desapercibido, y la
              // gente creía que la app no dejaba filtrar por fechas.
              OutlinedButton.icon(
                onPressed: onRango,
                icon: const Icon(Icons.date_range_outlined, size: 20),
                label: Text(rango == null ? 'Fechas' : 'Cambiar'),
              ),
              const SizedBox(width: 10),
              // El único botón de exportar de la app: el historial completo
              // para mandarle al técnico, o la tabla de lo que se ve con los
              // filtros (Excel para trabajarla, PDF para mostrarla).
              Container(
                decoration: const BoxDecoration(
                  color: PaletaCacao.verde,
                  shape: BoxShape.circle,
                ),
                child: PopupMenuButton<String>(
                  tooltip: 'Enviar o descargar el historial',
                  icon: const Icon(
                    Icons.ios_share_outlined,
                    color: Colors.white,
                  ),
                  onSelected: (valor) => switch (valor) {
                    'completo' => onExportarCompleto(),
                    'excel' => onExportarExcel(),
                    _ => onExportarPdf(),
                  },
                  itemBuilder: (contexto) => [
                    PopupMenuItem(
                      value: 'completo',
                      child: Row(
                        children: [
                          const Icon(Icons.summarize_outlined, size: 20),
                          const SizedBox(width: 10),
                          // Dice el alcance en vez de dejarlo adivinar: antes
                          // esta opción ignoraba las fechas elegidas y salía
                          // todo el historial sin avisar.
                          Text(
                            rango == null
                                ? 'Historial completo (PDF)'
                                : 'Historial de estas fechas (PDF)',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'excel',
                      child: Row(
                        children: [
                          Icon(Icons.grid_on_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Esta tabla en Excel'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Esta tabla en PDF'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (rango != null)
                IconButton(
                  tooltip: 'Quitar filtro de fecha',
                  onPressed: onLimpiarRango,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          if (rango != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${fechaCorta(rango!.start)} – ${fechaCorta(rango!.end)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _FilaEvento extends StatelessWidget {
  const _FilaEvento({required this.evento, required this.mostrarFinca});

  final EventoHistorial evento;
  final bool mostrarFinca;

  @override
  Widget build(BuildContext context) {
    final (icono, color, fondo, titulo) = switch (evento.tipo) {
      TipoEvento.actividad => (
        iconoActividad(TipoActividad.values.byName(evento.subtipo!)),
        PaletaCacao.verde,
        PaletaCacao.verdeClaro,
        etiquetaActividad(TipoActividad.values.byName(evento.subtipo!)),
      ),
      TipoEvento.cosecha => (
        Icons.shopping_basket_outlined,
        PaletaCacao.maduro,
        PaletaCacao.maduroClaro,
        '${numeroCorto(evento.cantidadKg ?? 0)} kg cosechados',
      ),
      TipoEvento.diagnostico => (
        Icons.eco_outlined,
        PaletaCacao.cafe,
        PaletaCacao.cafeClaro,
        etiquetaEstado(EstadoFenologico.values.byName(evento.subtipo!)),
      ),
    };
    // Dónde y cuándo va en una línea; lo que la persona anotó va debajo, en
    // otra. Antes iba todo pegado en un solo renglón y el detalle —lo único
    // que no se puede adivinar— era lo primero que se cortaba.
    final donde = [
      if (mostrarFinca && evento.fincaNombre != null) evento.fincaNombre!,
      evento.loteNombre,
      fechaLarga(evento.fecha),
    ].join(' · ');
    final anotado = [
      for (final (etiqueta, valor) in evento.anotado) '$etiqueta: $valor',
      if (evento.detalle != null && evento.detalle!.trim().isNotEmpty)
        evento.detalle!.trim(),
    ].join(' · ');

    return ListTile(
      isThreeLine: anotado.isNotEmpty,
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: fondo,
        child: Icon(icono, color: color),
      ),
      title: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(donde),
          if (anotado.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                anotado,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
