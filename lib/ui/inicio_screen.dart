import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/lote_repository.dart';
import '../data/repositories/perfil_repository.dart';
import '../data/sync/sync_service.dart';
import 'bienvenida_screen.dart';
import 'dialogos/dialogo_lote.dart';
import 'editar_finca_screen.dart';
import 'formato.dart';
import 'lote_detalle_screen.dart';
import 'tema.dart';
import 'widgets/comunes.dart';
import 'widgets/estado_sync.dart';
import 'widgets/mazorca.dart';

/// La pantalla de todos los días: cómo va la finca y qué pasó en cada lote.
///
/// Aquí no van los datos de identidad (nombre, teléfono, GPS): se leen una vez
/// y viven en el perfil. El inicio responde a otra pregunta: *cómo va mi finca*.
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
  /// Cuál finca se ve en el panel. Arranca en null (se resuelve a la primera
  /// en cuanto llegan las fincas) y solo cambia cuando el productor elige otra
  /// en el selector de la cabecera.
  String? _fincaSeleccionadaId;

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
          builder: (context, snapshot) {
            final fincas = snapshot.data ?? const <Finca>[];
            if (fincas.isEmpty) {
              return SingleChildScrollView(
                child: EstadoVacio(
                  icono: Icons.holiday_village_outlined,
                  titulo: 'Registre su finca',
                  mensaje: 'Con la finca creada ya puede agregar sus lotes.',
                  textoAccion: 'Registrar finca',
                  onAccion: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EditarFincaScreen(
                        repo: widget.repo,
                        productorId: productor.id,
                      ),
                    ),
                  ),
                ),
              );
            }
            // Si la finca elegida ya no existe (se borró), se cae a la
            // primera en vez de dejar la pantalla en blanco.
            final fincaActiva = fincas.firstWhere(
              (f) => f.id == _fincaSeleccionadaId,
              orElse: () => fincas.first,
            );
            return _Contenido(
              repo: widget.repo,
              lotesRepo: widget.lotesRepo,
              db: widget.db,
              sync: widget.sync,
              finca: fincaActiva,
              fincas: fincas,
              onCambiarFinca: (id) => setState(() => _fincaSeleccionadaId = id),
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
    required this.onCambiarFinca,
  });

  final PerfilRepository repo;
  final LoteRepository lotesRepo;
  final AppDatabase db;
  final SyncService sync;
  final Finca finca;

  /// Todas las fincas del productor, para el selector de la cabecera.
  final List<Finca> fincas;
  final ValueChanged<String> onCambiarFinca;

  Future<void> _agregarLote(BuildContext context) async {
    final datos = await pedirDatosLote(context);
    if (datos == null) return;
    await repo.guardarLote(
      fincaId: finca.id,
      nombre: datos.nombre,
      areaSembradaHa: datos.areaHa,
      variedadCacao: datos.variedad,
      fechaSiembra: datos.fechaSiembra,
    );
    if (context.mounted) avisar(context, 'Lote agregado');
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
              onCambiarFinca: onCambiarFinca,
              lotes: lotes,
              db: db,
              sync: sync,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _TarjetaLote(
                          lote: lotes[i],
                          lotesRepo: lotesRepo,
                          color: _coloresLote[i % _coloresLote.length],
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

/// Los lotes se turnan estos tres colores, como las materias de un horario:
/// así se distinguen de un vistazo sin tener que leer el nombre.
const _coloresLote = [PaletaCacao.cafe, PaletaCacao.verde, PaletaCacao.maduro];

class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.repo,
    required this.finca,
    required this.fincas,
    required this.onCambiarFinca,
    required this.lotes,
    required this.db,
    required this.sync,
  });

  final PerfilRepository repo;
  final Finca finca;
  final List<Finca> fincas;
  final ValueChanged<String> onCambiarFinca;
  final List<Lote> lotes;
  final AppDatabase db;
  final SyncService sync;

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finca.nombre,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      finca.municipio,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Con una sola finca no hace falta elegir: el selector solo estorba.
          if (fincas.length > 1) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: fincas.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final opcion = fincas[i];
                  final activa = opcion.id == finca.id;
                  return ChoiceChip(
                    label: Text(opcion.nombre),
                    selected: activa,
                    onSelected: (_) => onCambiarFinca(opcion.id),
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: activa ? PaletaCacao.cafeOscuro : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide.none,
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          EstadoSync(db: db, sync: sync),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: StreamBuilder<double>(
                stream: repo.watchProduccionAnual(finca.id, anio),
                builder: (context, produccion) {
                  return Row(
                    children: [
                      Indicador(
                        color: PaletaCacao.maduro,
                        icono: Icons.shopping_basket_outlined,
                        valor: numeroCorto(produccion.data ?? 0),
                        etiqueta: 'kg en $anio',
                      ),
                      Indicador(
                        color: PaletaCacao.verde,
                        icono: Icons.forest_outlined,
                        valor: '${lotes.length}',
                        etiqueta: lotes.length == 1 ? 'lote' : 'lotes',
                      ),
                      Indicador(
                        color: PaletaCacao.cafe,
                        icono: Icons.landscape_outlined,
                        valor: numeroCorto(PerfilRepository.areaTotal(lotes)),
                        etiqueta: 'hectáreas',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de lote: lo que el productor necesita saber sin entrar.
class _TarjetaLote extends StatelessWidget {
  const _TarjetaLote({
    required this.lote,
    required this.lotesRepo,
    required this.color,
  });

  final Lote lote;
  final LoteRepository lotesRepo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final edad = PerfilRepository.edadEnAnios(lote.fechaSiembra);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LoteDetalleScreen(repo: lotesRepo, lote: lote),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lote.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Marca de agua, no ilustración: acompaña sin robar
                  // atención al nombre del lote.
                  Mazorca(
                    tamano: 46,
                    color: Colors.white.withValues(alpha: 0.38),
                    conHoja: false,
                  ),
                ],
              ),
              Text(
                '${lote.variedadCacao} · ${numeroCorto(lote.areaSembradaHa)} ha'
                ' · ${edad == 1 ? '1 año' : '$edad años'}',
                style: const TextStyle(fontSize: 16, color: Color(0xCCFFFFFF)),
              ),
              const SizedBox(height: 18),
              _UltimaLabor(repo: lotesRepo, loteId: lote.id),
              const SizedBox(height: 8),
              _ProduccionDelLote(repo: lotesRepo, loteId: lote.id),
            ],
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
        return _LineaBlanca(
          icono: ultima == null
              ? Icons.hourglass_empty_rounded
              : iconoActividad(ultima.tipoActividad),
          texto: ultima == null
              ? 'Sin labores anotadas'
              : '${etiquetaActividad(ultima.tipoActividad)}, '
                    '${haceCuanto(ultima.fecha)}',
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
