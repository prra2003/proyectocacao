import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/lote_repository.dart';
import '../data/repositories/perfil_repository.dart';
import 'dialogos/dialogo_actividad.dart';

import 'dart:io';

import 'dialogos/dialogo_cosecha.dart';
import 'dialogos/dialogo_diagnostico.dart';
import 'formato.dart';
import 'tema.dart';
import 'widgets/comunes.dart';
import 'widgets/mazorca.dart';

/// Vida del lote: las labores culturales y las cosechas que se le registran.
class LoteDetalleScreen extends StatefulWidget {
  const LoteDetalleScreen({super.key, required this.repo, required this.lote});

  final LoteRepository repo;
  final Lote lote;

  @override
  State<LoteDetalleScreen> createState() => _LoteDetalleScreenState();
}

class _LoteDetalleScreenState extends State<LoteDetalleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _registrarActividad() async {
    final datos = await pedirDatosActividad(context);
    if (datos == null) return;
    await widget.repo.registrarActividad(
      loteId: widget.lote.id,
      tipo: datos.tipo,
      fecha: datos.fecha,
      observaciones: datos.observaciones,
      responsable: datos.responsable,
      costo: datos.costo,
      fotoPath: datos.fotoPath,
      subtipoLabor: datos.subtipoLabor,
      producto: datos.producto,
      cantidadAplicada: datos.cantidadAplicada,
      incidencia: datos.incidencia,
      arbolesAfectados: datos.arbolesAfectados,
      edadCultivoAnios: datos.edadCultivoAnios,
      arbolesSembrados: datos.arbolesSembrados,
      edadPlantulaMeses: datos.edadPlantulaMeses,
      insumos: datos.insumos,
      resultadoEsperado: datos.resultadoEsperado,
    );
    if (mounted) avisar(context, 'Labor registrada');
  }

  /// Borrar el lote se lleva por delante sus labores, cosechas y diagnósticos,
  /// así que se pregunta antes y se dice qué implica.
  Future<void> _borrarLote() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text('¿Borrar ${widget.lote.nombre}?'),
        content: const Text(
          'Se borran también sus labores, cosechas y diagnósticos. '
          'Esto no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 44),
              backgroundColor: Theme.of(contexto).colorScheme.error,
            ),
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    await widget.repo.borrarLote(widget.lote.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _registrarDiagnostico() async {
    final datos = await pedirDatosDiagnostico(context);
    if (datos == null) return;
    await widget.repo.registrarDiagnostico(
      loteId: widget.lote.id,
      fecha: datos.fecha,
      estado: datos.estado,
      fotoPath: datos.fotoPath,
      notas: datos.notas,
    );
    if (mounted) avisar(context, 'Diagnóstico guardado');
  }

  Future<void> _registrarCosecha() async {
    final datos = await pedirDatosCosecha(context);
    if (datos == null) return;
    await widget.repo.registrarCosecha(
      loteId: widget.lote.id,
      fecha: datos.fecha,
      cantidadKg: datos.cantidadKg,
      observaciones: datos.observaciones,
      tipoProducto: datos.tipoProducto,
      fotoPath: datos.fotoPath,
    );
    if (mounted) avisar(context, 'Cosecha registrada');
  }

  @override
  Widget build(BuildContext context) {
    final pestana = _tabs.index;
    return Scaffold(
      appBar: cabeceraCacao(
        titulo: Text(widget.lote.nombre),
        acciones: [
          IconButton(
            tooltip: 'Borrar lote',
            iconSize: 30,
            icon: const Icon(Icons.delete_outline),
            onPressed: _borrarLote,
          ),
        ],
        abajo: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Labores'),
            Tab(text: 'Cosechas'),
            Tab(text: 'Estado'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: switch (pestana) {
          1 => _registrarCosecha,
          2 => _registrarDiagnostico,
          _ => _registrarActividad,
        },
        // Cada pestaña tiene su color: verde lo que se le hace al lote,
        // naranja lo que sale de él, café cómo lo ve el productor.
        backgroundColor: switch (pestana) {
          1 => PaletaCacao.maduro,
          2 => PaletaCacao.cafe,
          _ => PaletaCacao.verde,
        },
        icon: const Icon(Icons.add),
        label: Text(switch (pestana) {
          1 => 'Cosecha',
          2 => 'Diagnóstico',
          _ => 'Labor',
        }),
      ),
      body: FondoCacao(
        child: Column(
          children: [
            _EncabezadoLote(lote: widget.lote, repo: widget.repo),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _ListaActividades(repo: widget.repo, loteId: widget.lote.id),
                  _ListaCosechas(repo: widget.repo, loteId: widget.lote.id),
                  _ListaDiagnosticos(repo: widget.repo, loteId: widget.lote.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EncabezadoLote extends StatelessWidget {
  const _EncabezadoLote({required this.lote, required this.repo});

  final Lote lote;
  final LoteRepository repo;

  @override
  Widget build(BuildContext context) {
    final anio = DateTime.now().year;
    final edad = PerfilRepository.edadEnAnios(lote.fechaSiembra);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Etiqueta(
                    icono: Icons.spa_outlined,
                    texto: lote.variedadCacao,
                    color: PaletaCacao.verde,
                    fondo: PaletaCacao.verdeClaro,
                  ),
                  _Etiqueta(
                    icono: Icons.landscape_outlined,
                    texto: '${numeroCorto(lote.areaSembradaHa)} ha',
                    color: PaletaCacao.cafe,
                    fondo: PaletaCacao.cafeClaro,
                  ),
                  _Etiqueta(
                    icono: Icons.schedule,
                    texto: edad == 1 ? '1 año' : '$edad años',
                    color: PaletaCacao.maduro,
                    fondo: PaletaCacao.maduroClaro,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<double>(
                stream: repo.watchKgDelAnio(lote.id, anio),
                builder: (context, snapshot) {
                  final kg = snapshot.data ?? 0;
                  return Row(
                    children: [
                      const MazorcaRedonda(diametro: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Producción $anio: ${numeroCorto(kg)} kg',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.icono,
    required this.texto,
    required this.color,
    required this.fondo,
  });

  final IconData icono;
  final String texto;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 22, color: color),
          const SizedBox(width: 8),
          Text(
            texto,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _ListaActividades extends StatelessWidget {
  const _ListaActividades({required this.repo, required this.loteId});

  final LoteRepository repo;
  final String loteId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ActividadAgricola>>(
      stream: repo.watchActividades(loteId),
      builder: (context, snapshot) {
        final actividades = snapshot.data;
        if (actividades == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (actividades.isEmpty) {
          return const SingleChildScrollView(
            child: EstadoVacio(
              icono: Icons.agriculture_outlined,
              titulo: 'Sin labores registradas',
              mensaje:
                  'Anote aquí las podas, abonadas, riegos y controles '
                  'del lote.',
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: actividades.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, i) {
            final actividad = actividades[i];
            return Dismissible(
              key: ValueKey(actividad.id),
              direction: DismissDirection.endToStart,
              background: const _FondoBorrar(),
              onDismissed: (_) async {
                await repo.borrarActividad(actividad.id);
                if (context.mounted) avisar(context, 'Labor eliminada');
              },
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: PaletaCacao.verdeClaro,
                  child: Icon(
                    iconoActividad(actividad.tipoActividad),
                    size: 30,
                    color: PaletaCacao.verde,
                  ),
                ),
                title: Text(
                  etiquetaActividad(actividad.tipoActividad),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  actividad.observaciones == null
                      ? fechaLarga(actividad.fecha)
                      : '${fechaLarga(actividad.fecha)} · '
                            '${actividad.observaciones}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ListaCosechas extends StatelessWidget {
  const _ListaCosechas({required this.repo, required this.loteId});

  final LoteRepository repo;
  final String loteId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Cosecha>>(
      stream: repo.watchCosechas(loteId),
      builder: (context, snapshot) {
        final cosechas = snapshot.data;
        if (cosechas == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (cosechas.isEmpty) {
          return const SingleChildScrollView(
            child: EstadoVacio(
              titulo: 'Sin cosechas registradas',
              mensaje:
                  'Cada entrega que saque del lote suma a la '
                  'producción del año.',
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: cosechas.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, i) {
            final cosecha = cosechas[i];
            return Dismissible(
              key: ValueKey(cosecha.id),
              direction: DismissDirection.endToStart,
              background: const _FondoBorrar(),
              onDismissed: (_) async {
                await repo.borrarCosecha(cosecha.id);
                if (context.mounted) avisar(context, 'Cosecha eliminada');
              },
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: PaletaCacao.maduroClaro,
                  child: const Icon(
                    Icons.shopping_basket_outlined,
                    size: 30,
                    color: PaletaCacao.maduro,
                  ),
                ),
                title: Text(
                  '${numeroCorto(cosecha.cantidadKg)} kg',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  cosecha.observaciones == null
                      ? fechaLarga(cosecha.fecha)
                      : '${fechaLarga(cosecha.fecha)} · '
                            '${cosecha.observaciones}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ListaDiagnosticos extends StatelessWidget {
  const _ListaDiagnosticos({required this.repo, required this.loteId});

  final LoteRepository repo;
  final String loteId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Diagnostico>>(
      stream: repo.watchDiagnosticos(loteId),
      builder: (context, snapshot) {
        final diagnosticos = snapshot.data;
        if (diagnosticos == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (diagnosticos.isEmpty) {
          return const SingleChildScrollView(
            child: EstadoVacio(
              icono: Icons.photo_camera_outlined,
              titulo: 'Sin diagnósticos',
              mensaje:
                  'Tome una foto y anote cómo está el cultivo: '
                  'floración, cuajado, monilla, escoba de bruja...',
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: diagnosticos.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, i) {
            final diagnostico = diagnosticos[i];
            final foto = diagnostico.fotoPath;
            return Dismissible(
              key: ValueKey(diagnostico.id),
              direction: DismissDirection.endToStart,
              background: const _FondoBorrar(),
              onDismissed: (_) async {
                await repo.borrarDiagnostico(diagnostico.id);
                if (context.mounted) avisar(context, 'Diagnóstico eliminado');
              },
              child: ListTile(
                leading: foto == null
                    ? const CircleAvatar(
                        radius: 30,
                        backgroundColor: PaletaCacao.cafeClaro,
                        child: Icon(
                          Icons.eco_outlined,
                          size: 30,
                          color: PaletaCacao.cafe,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(foto),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const CircleAvatar(
                            radius: 30,
                            backgroundColor: PaletaCacao.cafeClaro,
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                title: Text(
                  etiquetaEstado(diagnostico.estadoFenologico),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  diagnostico.notas == null
                      ? fechaLarga(diagnostico.fecha)
                      : '${fechaLarga(diagnostico.fecha)} · '
                            '${diagnostico.notas}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FondoBorrar extends StatelessWidget {
  const _FondoBorrar();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
  }
}
