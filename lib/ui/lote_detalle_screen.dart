import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/lote_repository.dart';
import '../data/repositories/perfil_repository.dart';
import 'dialogos/dialogo_actividad.dart';

import 'dart:io';

import 'dialogos/dialogo_cosecha.dart';
import 'dialogos/dialogo_diagnostico.dart';
import 'dialogos/dialogo_lote.dart';
import 'formato.dart';
import 'tema.dart';
import 'widgets/comunes.dart';
import 'widgets/confirmacion_guardado.dart';
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

  // Copia editable: cuando se guarda una edición se actualiza este campo
  // (con setState) para que la pantalla refleje los cambios sin tener que
  // volver a Inicio y entrar de nuevo al lote.
  late Lote _lote = widget.lote;

  /// El lote solo se puede editar durante la semana siguiente a que se creó.
  /// Pasado ese plazo queda fijo: lo que ya se sembró y registró no debería
  /// cambiarse después (las fincas, en cambio, se pueden editar siempre).
  static const _plazoEdicion = Duration(days: 7);

  bool get _yaNoSePuedeEditar =>
      DateTime.now().difference(_lote.createdAt) > _plazoEdicion;

  /// Días que le quedan al lote para poder corregirse (0 si ya no).
  int get _diasParaEditar {
    final quedan = _plazoEdicion - DateTime.now().difference(_lote.createdAt);
    return quedan.isNegative ? 0 : quedan.inDays + 1;
  }

  /// Antes el lápiz solo salía gris y, al tocarlo, un aviso decía que "se
  /// terminó el tiempo límite", sin decir por qué ni qué hacer. Ahora se
  /// explica y se dice a quién acudir.
  Future<void> _explicarCandado() {
    return showDialog<void>(
      context: context,
      builder: (contexto) => AlertDialog(
        icon: const Icon(Icons.lock_outline, size: 36),
        title: const Text('¿Por qué solo una semana?'),
        content: const Text(
          'Los datos del lote (nombre, área, variedad y fecha de siembra) se '
          'pueden corregir solo durante la primera semana. Así el historial '
          'que revisa el técnico no cambia después.\n\n'
          'Si algo quedó mal, pídale al técnico de la Red que lo corrija. '
          'Las labores y cosechas se siguen anotando normal.',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.of(contexto).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _registrarActividad() async {
    final datos = await pedirDatosActividad(context, loteNombre: _lote.nombre);
    if (datos == null) return;
    await guardarLabor(widget.repo, _lote, datos);
    if (mounted) {
      mostrarConfirmacionGuardado(context, mensaje: 'Labor registrada');
    }
  }

  /// Abre el formulario ya lleno con los datos actuales del lote (incluido
  /// el código nuevo) y guarda los cambios al aceptar. Pasada la semana de
  /// plazo, ni siquiera se abre el formulario: se avisa y ya.
  Future<void> _editarLote() async {
    if (_yaNoSePuedeEditar) {
      await _explicarCandado();
      return;
    }
    final datos = await pedirDatosLote(context, inicial: _lote);
    if (datos == null) return;
    await widget.repo.guardarLote(
      id: _lote.id,
      fincaId: _lote.fincaId,
      nombre: datos.nombre,
      codigo: datos.codigo,
      areaSembradaHa: datos.areaHa,
      variedadCacao: datos.variedad,
      fechaSiembra: datos.fechaSiembra,
      fotoPath: Value(datos.fotoPath),
    );
    if (!mounted) return;
    setState(() {
      _lote = _lote.copyWith(
        nombre: datos.nombre,
        codigo: datos.codigo,
        areaSembradaHa: datos.areaHa,
        variedadCacao: datos.variedad,
        fechaSiembra: datos.fechaSiembra,
        fotoPath: Value(datos.fotoPath),
      );
    });
    mostrarConfirmacionGuardado(context, mensaje: 'Cambios guardados');
  }

  /// Borrar el lote se lleva por delante sus labores, cosechas y diagnósticos,
  /// así que se pregunta antes y se dice qué implica.
  Future<void> _borrarLote() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text('¿Borrar ${_lote.nombre}?'),
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
    await widget.repo.borrarLote(_lote.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _registrarDiagnostico() async {
    final datos = await pedirDatosDiagnostico(context);
    if (datos == null) return;
    await widget.repo.registrarDiagnostico(
      loteId: _lote.id,
      fecha: datos.fecha,
      estado: datos.estado,
      fotoPath: datos.fotoPath,
      notas: datos.notas,
    );
    if (mounted) {
      mostrarConfirmacionGuardado(context, mensaje: 'Diagnóstico guardado');
    }
  }

  Future<void> _registrarCosecha() async {
    final datos = await pedirDatosCosecha(context);
    if (datos == null) return;
    await widget.repo.registrarCosecha(
      loteId: _lote.id,
      fecha: datos.fecha,
      cantidadKg: datos.cantidadKg,
      observaciones: datos.observaciones,
      tipoProducto: datos.tipoProducto,
      fotoPath: datos.fotoPath,
    );
    if (mounted) {
      mostrarConfirmacionGuardado(context, mensaje: 'Cosecha registrada');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pestana = _tabs.index;
    return Scaffold(
      appBar: cabeceraCacao(
        titulo: Text(_lote.nombre),
        acciones: [
          IconButton(
            tooltip: _yaNoSePuedeEditar
                ? 'Ya no se puede editar: pasó la semana de plazo'
                : 'Editar lote',
            iconSize: 28,
            icon: Icon(
              Icons.edit_outlined,
              color: _yaNoSePuedeEditar
                  ? Theme.of(context).disabledColor
                  : null,
            ),
            onPressed: _editarLote,
          ),
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
            _EncabezadoLote(
              lote: _lote,
              repo: widget.repo,
              diasParaEditar: _diasParaEditar,
              onPorQue: _explicarCandado,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _ListaActividades(repo: widget.repo, loteId: _lote.id),
                  _ListaCosechas(repo: widget.repo, loteId: _lote.id),
                  _ListaDiagnosticos(repo: widget.repo, loteId: _lote.id),
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
  const _EncabezadoLote({
    required this.lote,
    required this.repo,
    required this.diasParaEditar,
    required this.onPorQue,
  });

  final Lote lote;
  final LoteRepository repo;

  /// 0 = ya no se puede editar. Se dice antes de que pase, no después.
  final int diasParaEditar;
  final VoidCallback onPorQue;

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
                  // Los lotes que ya existían antes de este campo pueden
                  // tener el código vacío: no se muestra la etiqueta hasta
                  // que el productor lo complete editando el lote.
                  if (lote.codigo.isNotEmpty)
                    _Etiqueta(
                      icono: Icons.qr_code_2_outlined,
                      texto: lote.codigo,
                      color: PaletaCacao.dorado,
                      fondo: PaletaCacao.cafeOscuro,
                    ),
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
              const SizedBox(height: 12),
              _AvisoEdicion(diasParaEditar: diasParaEditar, onPorQue: onPorQue),
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
            final foto = actividad.fotoPath;
            // El "registro del proceso" del lote: además de la fecha, se
            // arman los detalles propios de cada labor (Siembra, Poda...)
            // junto con responsable, costo y observaciones, todos opcionales.
            final detalles = <String>[
              fechaLarga(actividad.fecha),
              if (actividad.subtipoLabor != null) actividad.subtipoLabor!,
              if (actividad.arbolesSembrados != null)
                '${actividad.arbolesSembrados} árboles',
              if (actividad.edadPlantulaMeses != null)
                'plántula de ${actividad.edadPlantulaMeses} meses',
              if (actividad.insumos != null) actividad.insumos!,
              if (actividad.arbolesAfectados != null)
                '${actividad.arbolesAfectados} árboles',
              if (actividad.edadCultivoAnios != null)
                'cultivo de ${actividad.edadCultivoAnios} años',
              if (actividad.incidencia != null)
                'Incidencia: ${actividad.incidencia}',
              if (actividad.producto != null) 'Producto: ${actividad.producto}',
              if (actividad.cantidadAplicada != null)
                'Cantidad: ${actividad.cantidadAplicada}',
              if (actividad.responsable != null)
                'Responsable: ${actividad.responsable}',
              if (actividad.costo != null)
                'Costo: \$${numeroCorto(actividad.costo!)}',
              if (actividad.observaciones != null) actividad.observaciones!,
              if (actividad.resultadoEsperado != null)
                'Esperado: ${actividad.resultadoEsperado}',
            ];
            return Dismissible(
              key: ValueKey(actividad.id),
              direction: DismissDirection.endToStart,
              background: const _FondoBorrar(),
              onDismissed: (_) async {
                await repo.borrarActividad(actividad.id);
                if (context.mounted) avisar(context, 'Labor eliminada');
              },
              child: ListTile(
                leading: foto == null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundColor: PaletaCacao.verdeClaro,
                        child: Icon(
                          iconoActividad(actividad.tipoActividad),
                          size: 30,
                          color: PaletaCacao.verde,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(foto),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => CircleAvatar(
                            radius: 30,
                            backgroundColor: PaletaCacao.verdeClaro,
                            child: Icon(
                              iconoActividad(actividad.tipoActividad),
                              size: 30,
                              color: PaletaCacao.verde,
                            ),
                          ),
                        ),
                      ),
                title: Text(
                  etiquetaActividad(actividad.tipoActividad),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(detalles.join(' · ')),
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
                leading: cosecha.fotoPath == null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundColor: PaletaCacao.maduroClaro,
                        child: const Icon(
                          Icons.shopping_basket_outlined,
                          size: 30,
                          color: PaletaCacao.maduro,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(cosecha.fotoPath!),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => CircleAvatar(
                            radius: 30,
                            backgroundColor: PaletaCacao.maduroClaro,
                            child: const Icon(
                              Icons.shopping_basket_outlined,
                              size: 30,
                              color: PaletaCacao.maduro,
                            ),
                          ),
                        ),
                      ),
                title: Text(
                  '${numeroCorto(cosecha.cantidadKg)} kg',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  [
                    fechaLarga(cosecha.fecha),
                    if (cosecha.tipoProducto != null) cosecha.tipoProducto!,
                    if (cosecha.observaciones != null) cosecha.observaciones!,
                  ].join(' · '),
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

/// Una línea que dice si los datos del lote todavía se pueden corregir, y un
/// "¿Por qué?" que lo explica, en vez de un lápiz gris que no dice nada.
class _AvisoEdicion extends StatelessWidget {
  const _AvisoEdicion({required this.diasParaEditar, required this.onPorQue});

  final int diasParaEditar;
  final VoidCallback onPorQue;

  @override
  Widget build(BuildContext context) {
    final bloqueado = diasParaEditar == 0;
    final texto = bloqueado
        ? 'Los datos del lote ya no se pueden cambiar.'
        : diasParaEditar == 1
        ? 'Puede corregir los datos del lote hasta mañana.'
        : 'Puede corregir los datos del lote durante $diasParaEditar días más.';
    return Material(
      color: const Color(0xFFF1E2C7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPorQue,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                bloqueado ? Icons.lock_outline : Icons.edit_calendar_outlined,
                color: PaletaCacao.cafe,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(texto)),
              const SizedBox(width: 6),
              const Text(
                '¿Por qué?',
                style: TextStyle(
                  color: PaletaCacao.dorado,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
