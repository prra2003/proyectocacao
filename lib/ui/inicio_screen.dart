import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/lote_repository.dart';
import '../data/repositories/perfil_repository.dart';
import '../data/sync/sync_service.dart';
import 'bienvenida_screen.dart';
import '../data/repositories/recordatorios.dart';
import 'dialogos/dialogo_actividad.dart';
import 'dialogos/dialogo_lote.dart';
import 'editar_finca_screen.dart';
import 'formato.dart';
import 'lote_detalle_screen.dart';
import 'tema.dart';
import 'widgets/comunes.dart';
import 'widgets/confirmacion_guardado.dart';
import 'widgets/estado_sync.dart';
import 'widgets/mazorca.dart';
import 'widgets/selector_finca.dart';

/// La pantalla de todos los días: cómo va la finca y qué pasó en cada lote.
///
/// Aquí no van los datos de identidad (nombre, teléfono, GPS): se leen una vez
/// y viven en el perfil. El inicio responde a otra pregunta: *cómo va mi finca*.
///
/// Un productor puede tener varias fincas (RF-02), así que la cabecera lleva
/// un selector siempre tocable: con una sola finca sirve para agregar otra,
/// con varias sirve también para cambiar cuál se está mirando.
class InicioScreen extends StatefulWidget {
  const InicioScreen({
    super.key,
    required this.repo,
    required this.lotesRepo,
    required this.db,
    required this.sync,
  });

  final PerfilRepository repo;
  final LoteRepository lotesRepo;
  final AppDatabase db;
  final SyncService sync;

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  String? _seleccionId;

  Future<void> _agregarFinca(BuildContext context, String productorId) {
    return Navigator.of(context).push(
      RutaCacao<void>(
        builder: (_) =>
            EditarFincaScreen(repo: widget.repo, productorId: productorId),
      ),
    );
  }

  Future<void> _editarFinca(BuildContext context, Finca finca) {
    return Navigator.of(context).push(
      RutaCacao<void>(
        builder: (_) => EditarFincaScreen(
          repo: widget.repo,
          productorId: finca.productorId,
          finca: finca,
        ),
      ),
    );
  }

  /// El selector ya preguntó y confirmó; acá solo queda borrar de verdad.
  /// Si la finca borrada era la que estaba activa, la próxima construcción
  /// cae sola en otra (o en la pantalla de "registre su finca" si esa era
  /// la última).
  Future<void> _eliminarFinca(BuildContext context, Finca finca) async {
    await widget.repo.borrarFinca(finca.id);
    if (context.mounted) avisar(context, 'Finca eliminada');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Productor?>(
      stream: widget.repo.watchProductor(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final productor = snapshot.data;
        // El cascarón ya decide qué mostrar cuando no hay productor; esto es
        // solo la red de seguridad si esta pantalla se usa suelta.
        if (productor == null) {
          return BienvenidaScreen(repo: widget.repo, sync: widget.sync);
        }
        return StreamBuilder<List<Finca>>(
          stream: widget.repo.watchFincas(productor.id),
          builder: (context, snapshotFincas) {
            // Mientras la base responde, esperar: mostrar "Registre su finca"
            // en ese momento invitaba a crear una finca que ya existía.
            if (!snapshotFincas.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final fincas = snapshotFincas.data!;
            if (fincas.isEmpty) {
              return SingleChildScrollView(
                child: EstadoVacio(
                  icono: Icons.holiday_village_outlined,
                  titulo: 'Registre su finca',
                  mensaje: 'Con la finca creada ya puede agregar sus lotes.',
                  textoAccion: 'Registrar finca',
                  onAccion: () => Navigator.of(context).push(
                    RutaCacao<void>(
                      builder: (_) => EditarFincaScreen(
                        repo: widget.repo,
                        productorId: productor.id,
                      ),
                    ),
                  ),
                ),
              );
            }
            final seleccionId = _seleccionId ?? fincas.first.id;
            final finca = fincas.firstWhere(
              (f) => f.id == seleccionId,
              orElse: () => fincas.first,
            );
            return _Contenido(
              repo: widget.repo,
              lotesRepo: widget.lotesRepo,
              db: widget.db,
              sync: widget.sync,
              finca: finca,
              fincas: fincas,
              onSeleccionarFinca: (id) => setState(() => _seleccionId = id),
              onAgregarFinca: () => _agregarFinca(context, productor.id),
              onEliminarFinca: (f) => _eliminarFinca(context, f),
              onEditarFinca: (f) => _editarFinca(context, f),
            );
          },
        );
      },
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.repo,
    required this.lotesRepo,
    required this.db,
    required this.sync,
    required this.finca,
    required this.fincas,
    required this.onSeleccionarFinca,
    required this.onAgregarFinca,
    required this.onEliminarFinca,
    required this.onEditarFinca,
  });

  final PerfilRepository repo;
  final LoteRepository lotesRepo;
  final AppDatabase db;
  final SyncService sync;
  final Finca finca;
  final List<Finca> fincas;
  final ValueChanged<String> onSeleccionarFinca;
  final VoidCallback onAgregarFinca;
  final ValueChanged<Finca> onEliminarFinca;
  final ValueChanged<Finca> onEditarFinca;

  /// El código del lote nuevo se calcula antes de abrir el formulario,
  /// mirando todos los lotes de todas las fincas del productor (no solo los
  /// de esta finca): así la numeración es una sola secuencia para todo el
  /// productor y nunca se repite entre fincas.
  Future<void> _agregarLote(BuildContext context) async {
    final lotesDelProductor = await repo
        .watchLotesDeProductor(finca.productorId)
        .first;
    final codigoSugerido = siguienteCodigoLote(
      lotesDelProductor.map((l) => l.codigo),
    );
    if (!context.mounted) return;
    final datos = await pedirDatosLote(context, codigoSugerido: codigoSugerido);
    if (datos == null) return;
    await repo.guardarLote(
      fincaId: finca.id,
      nombre: datos.nombre,
      codigo: datos.codigo,
      areaSembradaHa: datos.areaHa,
      variedadCacao: datos.variedad,
      fechaSiembra: datos.fechaSiembra,
      fotoPath: Value(datos.fotoPath),
    );
    if (context.mounted) {
      mostrarConfirmacionGuardado(context, mensaje: 'Lote agregado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lote>>(
      stream: repo.watchLotes(finca.id),
      builder: (context, snapshot) {
        final lotes = snapshot.data ?? const <Lote>[];
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _Cabecera(
              repo: repo,
              finca: finca,
              fincas: fincas,
              lotes: lotes,
              db: db,
              sync: sync,
              onSeleccionarFinca: onSeleccionarFinca,
              onAgregarFinca: onAgregarFinca,
              onEliminarFinca: onEliminarFinca,
              onEditarFinca: onEditarFinca,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Recordatorios(
                    repo: repo,
                    lotesRepo: lotesRepo,
                    fincaId: finca.id,
                    lotes: lotes,
                  ),
                  TituloSeccion(
                    'Mis lotes',
                    accion: TextButton.icon(
                      onPressed: () => _agregarLote(context),
                      icon: const Icon(Icons.add, size: 24),
                      label: const Text('Agregar'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (lotes.isEmpty)
                    Card(
                      child: EstadoVacio(
                        compacto: true,
                        titulo: 'Sin lotes todavía',
                        mensaje:
                            'Agregue su primer lote para anotar labores '
                            'y cosechas.',
                        textoAccion: 'Agregar lote',
                        onAccion: () => _agregarLote(context),
                      ),
                    )
                  else
                    for (var i = 0; i < lotes.length; i++)
                      Padding(
                        key: ValueKey(lotes[i].id),
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _EntradaEscalonada(
                          retraso: Duration(milliseconds: 70 * i),
                          child: _TarjetaLote(
                            lote: lotes[i],
                            lotesRepo: lotesRepo,
                            color: _coloresLote[i % _coloresLote.length],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Los lotes se turnan estos cuatro colores, como las materias de un horario:
/// así se distinguen de un vistazo sin tener que leer el nombre.
const _coloresLote = [
  PaletaCacao.cafe,
  PaletaCacao.verde,
  PaletaCacao.maduro,
  PaletaCacao.dorado,
];

/// Envuelve a [child] en un desvanecido + subida leve, con un [retraso] antes
/// de empezar: así las tarjetas de la lista no aparecen todas de golpe sino
/// en cascada, una detrás de otra.
class _EntradaEscalonada extends StatefulWidget {
  const _EntradaEscalonada({
    required this.retraso,
    required this.child,
  });

  final Duration retraso;
  final Widget child;

  @override
  State<_EntradaEscalonada> createState() => _EntradaEscalonadaState();
}

class _EntradaEscalonadaState extends State<_EntradaEscalonada> {
  var _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.retraso, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.12),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.repo,
    required this.finca,
    required this.fincas,
    required this.lotes,
    required this.db,
    required this.sync,
    required this.onSeleccionarFinca,
    required this.onAgregarFinca,
    required this.onEliminarFinca,
    required this.onEditarFinca,
  });

  final PerfilRepository repo;
  final Finca finca;
  final List<Finca> fincas;
  final List<Lote> lotes;
  final AppDatabase db;
  final SyncService sync;
  final ValueChanged<String> onSeleccionarFinca;
  final VoidCallback onAgregarFinca;
  final ValueChanged<Finca> onEliminarFinca;
  final ValueChanged<Finca> onEditarFinca;

  @override
  Widget build(BuildContext context) {
    final anio = DateTime.now().year;
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        MediaQuery.paddingOf(context).top + 24,
        22,
        26,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: PaletaCacao.cabecera,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Mazorca(
                tamano: 40,
                color: Colors.white,
                colorHoja: PaletaCacao.verdeClaro,
              ),
              const SizedBox(width: 12),
              // Siempre tocable, tenga el productor una finca o varias: es el
              // único camino para agregar otra finca desde el Inicio.
              Expanded(
                child: SelectorFinca(
                  fincas: fincas,
                  seleccionada: finca,
                  onSeleccionar: onSeleccionarFinca,
                  onAgregar: onAgregarFinca,
                  onEliminar: onEliminarFinca,
                  onEditar: onEditarFinca,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          EstadoSync(db: db, sync: sync),
          const SizedBox(height: 16),
          StreamBuilder<double>(
            stream: repo.watchProduccionAnual(finca.id, anio),
            builder: (context, produccion) {
              return Row(
                children: [
                  Expanded(
                    child: _TarjetaIndicador(
                      fondo: PaletaCacao.maduroClaro,
                      child: _IndicadorAnimado(
                        color: PaletaCacao.maduro,
                        icono: Icons.shopping_basket_outlined,
                        valor: produccion.data ?? 0,
                        formatear: numeroCorto,
                        etiqueta: 'kg en $anio',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TarjetaIndicador(
                      fondo: PaletaCacao.verdeClaro,
                      child: _IndicadorAnimado(
                        color: PaletaCacao.verde,
                        icono: Icons.forest_outlined,
                        valor: lotes.length.toDouble(),
                        formatear: (v) => '${v.round()}',
                        etiqueta: lotes.length == 1 ? 'lote' : 'lotes',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TarjetaIndicador(
                      fondo: PaletaCacao.cafeClaro,
                      child: _IndicadorAnimado(
                        color: PaletaCacao.cafe,
                        icono: Icons.landscape_outlined,
                        valor: PerfilRepository.areaTotal(lotes),
                        formatear: numeroCorto,
                        etiqueta: 'hectáreas',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _ComparacionAnioPasado(repo: repo, fincaId: finca.id),
        ],
      ),
    );
  }
}

/// Una línea debajo de los tres indicadores: cómo va este año frente al año
/// pasado **a la misma fecha**. Va aparte y no dentro de los cuadritos para
/// no apretarlos, y solo sale si hay con qué comparar.
class _ComparacionAnioPasado extends StatelessWidget {
  const _ComparacionAnioPasado({required this.repo, required this.fincaId});

  final PerfilRepository repo;
  final String fincaId;

  @override
  Widget build(BuildContext context) {
    final anio = DateTime.now().year;
    return StreamBuilder<double>(
      stream: repo.watchProduccionAnual(fincaId, anio),
      builder: (context, esteAnio) {
        return StreamBuilder<double>(
          stream: repo.watchKgAnioPasadoAEstaFecha(fincaId),
          builder: (context, anioPasado) {
            final ahora = esteAnio.data ?? 0;
            final antes = anioPasado.data ?? 0;
            if (antes <= 0) return const SizedBox.shrink();
            final cambio = ((ahora - antes) / antes * 100).round();
            final sube = cambio >= 0;
            final texto = cambio == 0
                ? 'Igual que el año pasado a esta fecha '
                      '(${numeroCorto(antes)} kg)'
                : '${sube ? '$cambio% más' : '${-cambio}% menos'} que en '
                      '${anio - 1} a esta fecha (${numeroCorto(antes)} kg)';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    sube ? Icons.trending_up : Icons.trending_down,
                    color: sube
                        ? const Color(0xFFA9E0B4)
                        : const Color(0xFFF3B79B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      texto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Avisos de lo que ya toca hacer ("El Alto lleva 95 días sin poda"), con un
/// botón que abre la anotación con el lote y la labor ya elegidos. Salen de lo
/// que ya está anotado: cuando se anota la labor, el aviso desaparece solo.
class _Recordatorios extends StatelessWidget {
  const _Recordatorios({
    required this.repo,
    required this.lotesRepo,
    required this.fincaId,
    required this.lotes,
  });

  final PerfilRepository repo;
  final LoteRepository lotesRepo;
  final String fincaId;
  final List<Lote> lotes;

  Future<void> _anotar(BuildContext context, Recordatorio aviso) async {
    final datos = await pedirDatosActividad(
      context,
      tipoInicial: aviso.tipo,
      loteNombre: aviso.lote.nombre,
    );
    if (datos == null) return;
    await guardarLabor(lotesRepo, aviso.lote, datos);
    if (context.mounted) {
      mostrarConfirmacionGuardado(context, mensaje: 'Labor registrada');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ActividadAgricola>>(
      stream: repo.watchActividadesDeFinca(fincaId),
      builder: (context, snapshot) {
        final avisos = recordatoriosPara(lotes, snapshot.data ?? const []);
        if (avisos.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final aviso in avisos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaRecordatorio(
                    aviso: aviso,
                    onAnotar: () => _anotar(context, aviso),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TarjetaRecordatorio extends StatelessWidget {
  const _TarjetaRecordatorio({required this.aviso, required this.onAnotar});

  final Recordatorio aviso;
  final VoidCallback onAnotar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PaletaCacao.maduro.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: PaletaCacao.maduro,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  aviso.mensaje,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: PaletaCacao.verde),
            onPressed: onAnotar,
            icon: Icon(
              aviso.tipo == null
                  ? Icons.edit_note
                  : iconoActividad(aviso.tipo!),
            ),
            label: Text(
              aviso.tipo == null
                  ? 'Anotar una labor'
                  : 'Anotar la ${etiquetaActividad(aviso.tipo!).toLowerCase()}',
            ),
          ),
        ],
      ),
    );
  }
}

/// Envoltorio de color para un indicador: cada dato del resumen va en su
/// propia tarjeta pastel en vez de compartir una sola tarjeta blanca, para
/// que se distingan de un vistazo.
///
/// `Indicador` ya viene envuelto en `Expanded` (para repartirse el ancho
/// dentro de una fila), así que aquí adentro va un `Row` de un solo elemento
/// para que ese `Expanded` tenga un padre válido.
class _TarjetaIndicador extends StatelessWidget {
  const _TarjetaIndicador({required this.fondo, required this.child});

  final Color fondo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [child]),
    );
  }
}

/// Un [Indicador] cuyo número sube contando desde cero hasta el valor real
/// cada vez que se construye: le da vida al resumen en vez de que los
/// números simplemente aparezcan fijos.
class _IndicadorAnimado extends StatelessWidget {
  const _IndicadorAnimado({
    required this.valor,
    required this.etiqueta,
    required this.icono,
    required this.color,
    required this.formatear,
  });

  final double valor;
  final String etiqueta;
  final IconData icono;
  final Color color;
  final String Function(double) formatear;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: valor),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Indicador(
        valor: formatear(v),
        etiqueta: etiqueta,
        icono: icono,
        color: color,
      ),
    );
  }
}

/// Tarjeta de lote: lo que el productor necesita saber sin entrar.
///
/// Se achica al presionarla y rebota un poco al soltar, igual que los
/// botones de la bienvenida: da la misma sensación de "responde al toque"
/// en toda la app.
class _TarjetaLote extends StatefulWidget {
  const _TarjetaLote({
    required this.lote,
    required this.lotesRepo,
    required this.color,
  });

  final Lote lote;
  final LoteRepository lotesRepo;
  final Color color;

  @override
  State<_TarjetaLote> createState() => _TarjetaLoteState();
}

class _TarjetaLoteState extends State<_TarjetaLote> {
  var _presionado = false;

  void _fijar(bool valor) {
    if (_presionado != valor) setState(() => _presionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    final edad = PerfilRepository.edadEnAnios(widget.lote.fechaSiembra);
    final foto = widget.lote.fotoPath;
    return GestureDetector(
      onTapDown: (_) => _fijar(true),
      onTapUp: (_) => _fijar(false),
      onTapCancel: () => _fijar(false),
      child: AnimatedScale(
        scale: _presionado ? 0.95 : 1,
        duration: Duration(milliseconds: _presionado ? 90 : 260),
        curve: _presionado ? Curves.easeOut : Curves.easeOutBack,
        child: Material(
          color: widget.color,
          borderRadius: BorderRadius.circular(26),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              RutaCacao<void>(
                builder: (_) => LoteDetalleScreen(
                  repo: widget.lotesRepo,
                  lote: widget.lote,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (foto != null)
                  Image.file(
                    File(foto),
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.lote.nombre,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Marca de agua, no ilustración: acompaña sin robar
                          // atención al nombre del lote. Con foto sobra.
                          if (foto == null)
                            Mazorca(
                              tamano: 46,
                              color: Colors.white.withValues(alpha: 0.38),
                              conHoja: false,
                            ),
                        ],
                      ),
                      // Vacío en los lotes que ya existían antes de este campo
                      // (todavía no le pusieron código); no ocupa espacio hasta
                      // que lo tengan.
                      if (widget.lote.codigo.isNotEmpty)
                        Text(
                          widget.lote.codigo,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xCCFFFFFF),
                          ),
                        ),
                      Text(
                        '${widget.lote.variedadCacao} · '
                        '${numeroCorto(widget.lote.areaSembradaHa)} ha'
                        ' · ${edad == 1 ? '1 año' : '$edad años'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _UltimaLabor(
                        repo: widget.lotesRepo,
                        loteId: widget.lote.id,
                      ),
                      const SizedBox(height: 8),
                      _ProduccionDelLote(
                        repo: widget.lotesRepo,
                        loteId: widget.lote.id,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UltimaLabor extends StatelessWidget {
  const _UltimaLabor({required this.repo, required this.loteId});

  final LoteRepository repo;
  final String loteId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ActividadAgricola>>(
      stream: repo.watchActividades(loteId),
      builder: (context, snapshot) {
        final actividades = snapshot.data ?? const <ActividadAgricola>[];
        final ultima = actividades.isEmpty ? null : actividades.first;
        // En el campo se anota a la carrera y se deja a medias. El lote lo
        // dice aquí mismo, sin tener que entrar a buscarlo labor por labor.
        final aMedias = actividades
            .where((a) => faltaLlenarEn(a).isNotEmpty)
            .length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LineaBlanca(
              icono: ultima == null
                  ? Icons.hourglass_empty_rounded
                  : iconoActividad(ultima.tipoActividad),
              texto: ultima == null
                  ? 'Sin labores anotadas'
                  : '${etiquetaActividad(ultima.tipoActividad)}, '
                        '${haceCuanto(ultima.fecha)}',
            ),
            if (aMedias > 0) ...[
              const SizedBox(height: 8),
              _LineaBlanca(
                icono: Icons.edit_note,
                texto: aMedias == 1
                    ? 'Falta llenar 1 labor'
                    : 'Falta llenar $aMedias labores',
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ProduccionDelLote extends StatelessWidget {
  const _ProduccionDelLote({required this.repo, required this.loteId});

  final LoteRepository repo;
  final String loteId;

  @override
  Widget build(BuildContext context) {
    final anio = DateTime.now().year;
    return StreamBuilder<double>(
      stream: repo.watchKgDelAnio(loteId, anio),
      builder: (context, snapshot) {
        final kg = snapshot.data ?? 0;
        return _LineaBlanca(
          icono: Icons.shopping_basket_outlined,
          texto: kg == 0
              ? 'Sin cosechas en $anio'
              : '${numeroCorto(kg)} kg en $anio',
        );
      },
    );
  }
}

class _LineaBlanca extends StatelessWidget {
  const _LineaBlanca({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 22, color: const Color(0xE6FFFFFF)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
