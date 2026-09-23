import 'package:flutter/material.dart';

import '../../data/local/database.dart';
import '../../data/local/enums.dart';
import '../../data/repositories/lote_repository.dart';
import '../../data/repositories/perfil_repository.dart';
import '../formato.dart';
import '../tema.dart';
import '../widgets/campo_dictado.dart';
import '../widgets/comunes.dart';
import '../widgets/selector_fecha.dart';

/// Opciones fijas de cada desplegable, tal como las trae el documento de
/// requerimientos: el productor elige una, no escribe a mano.
const _tiposPoda = ['Formación', 'Mantenimiento', 'Rehabilitación'];
const _tiposFertilizacion = [
  'Química',
  'Orgánica',
  'Foliar',
  'Edáfica (suelo)',
];
const _problemasFitosanitarios = [
  'Moniliasis',
  'Escoba de bruja',
  'Insectos',
  'Enfermedad (hongos o bacterias)',
  'Otro',
];
const _tiposRiego = ['Goteo', 'Aspersión', 'Manual / por gravedad'];

/// Además de tipo, fecha y observaciones (lo que ya había), trae los campos
/// del "Registro del proceso (cacao)" del documento de requerimientos:
/// - responsable, costo, foto y resultado esperado valen para cualquier
///   labor.
/// - arbolesSembrados/edadPlantulaMeses/insumos son de Siembra.
/// - subtipoLabor/arbolesAfectados/edadCultivoAnios se reutilizan en Poda,
///   Fertilización, Control fitosanitario y Riego (cada una con sus propias
///   opciones de desplegable).
/// - producto/cantidadAplicada/incidencia son de Fertilización y Control
///   fitosanitario.
typedef DatosActividad = ({
  TipoActividad tipo,
  DateTime fecha,
  String? observaciones,
  String? responsable,
  double? costo,
  String? fotoPath,
  String? resultadoEsperado,
  // Siembra
  int? arbolesSembrados,
  int? edadPlantulaMeses,
  String? insumos,
  // Poda / Fertilización / Control fitosanitario / Riego
  String? subtipoLabor,
  int? arbolesAfectados,
  int? edadCultivoAnios,
  // Fertilización / Control fitosanitario
  String? producto,
  String? cantidadAplicada,
  String? incidencia,
});

/// [tipoInicial] llega desde un recordatorio ("El Alto lleva 90 días sin
/// poda"): el formulario abre con esa labor ya elegida. [loteNombre] se
/// muestra debajo del título para que no quede duda de en qué lote se anota.
Future<DatosActividad?> pedirDatosActividad(
  BuildContext context, {
  TipoActividad? tipoInicial,
  String? loteNombre,
}) {
  return showDialog<DatosActividad>(
    context: context,
    builder: (_) =>
        _DialogoActividad(tipoInicial: tipoInicial, loteNombre: loteNombre),
  );
}

/// Guarda lo que se llenó en el formulario como una labor de [lote].
///
/// La edad del cultivo no se pregunta: se calcula con la fecha de siembra del
/// lote, que la app ya conoce.
Future<void> guardarLabor(
  LoteRepository repo,
  Lote lote,
  DatosActividad datos,
) {
  return repo.registrarActividad(
    loteId: lote.id,
    tipo: datos.tipo,
    fecha: datos.fecha,
    observaciones: datos.observaciones,
    responsable: datos.responsable,
    costo: datos.costo,
    fotoPath: datos.fotoPath,
    arbolesSembrados: datos.arbolesSembrados,
    edadPlantulaMeses: datos.edadPlantulaMeses,
    insumos: datos.insumos,
    resultadoEsperado: datos.resultadoEsperado,
    subtipoLabor: datos.subtipoLabor,
    arbolesAfectados: datos.arbolesAfectados,
    edadCultivoAnios: PerfilRepository.edadEnAnios(lote.fechaSiembra),
    producto: datos.producto,
    cantidadAplicada: datos.cantidadAplicada,
    incidencia: datos.incidencia,
  );
}

/// Cómo se le dice a cada labor en el campo. En el historial y los reportes
/// sigue saliendo el nombre técnico ([etiquetaActividad]), que es el que usa
/// el técnico; aquí, donde el productor elige, va el de todos los días.
String _nombreDelCampo(TipoActividad tipo) => switch (tipo) {
  TipoActividad.siembra => 'Siembra',
  TipoActividad.poda => 'Poda',
  TipoActividad.fertilizacion => 'Abonar',
  TipoActividad.controlFitosanitario => 'Fumigar o curar',
  TipoActividad.riego => 'Riego',
  TipoActividad.otro => 'Otra labor',
};

class _DialogoActividad extends StatefulWidget {
  const _DialogoActividad({this.tipoInicial, this.loteNombre});

  final TipoActividad? tipoInicial;
  final String? loteNombre;

  @override
  State<_DialogoActividad> createState() => _DialogoActividadState();
}

class _DialogoActividadState extends State<_DialogoActividad> {
  final _observaciones = TextEditingController();
  final _responsable = TextEditingController();
  final _costo = TextEditingController();
  final _resultadoEsperado = TextEditingController();

  // Siembra
  final _arbolesSembrados = TextEditingController();
  final _edadPlantula = TextEditingController();
  final _insumos = TextEditingController();

  // Poda / Fertilización / Control fitosanitario / Riego
  final _arbolesAfectados = TextEditingController();
  String? _subtipo;

  // Fertilización / Control fitosanitario
  final _producto = TextEditingController();
  final _cantidadAplicada = TextEditingController();
  final _incidencia = TextEditingController();

  late var _tipo = widget.tipoInicial ?? TipoActividad.poda;
  DateTime _fecha = DateTime.now();

  /// Lo único obligatorio es qué labor y cuándo. Todo lo demás (tipo de poda,
  /// árboles, responsable, costo, foto, notas) va aquí dentro, cerrado: quien
  /// tenga tiempo lo llena, y quien no, registra con dos toques.
  var _masDetalles = false;
  String? _fotoPath;
  var _cargandoFoto = false;

  bool get _esSiembra => _tipo == TipoActividad.siembra;
  bool get _esPoda => _tipo == TipoActividad.poda;
  bool get _esFertilizacion => _tipo == TipoActividad.fertilizacion;
  bool get _esFitosanitario => _tipo == TipoActividad.controlFitosanitario;
  bool get _esRiego => _tipo == TipoActividad.riego;

  @override
  void dispose() {
    _observaciones.dispose();
    _responsable.dispose();
    _costo.dispose();
    _resultadoEsperado.dispose();
    _arbolesSembrados.dispose();
    _edadPlantula.dispose();
    _insumos.dispose();
    _arbolesAfectados.dispose();
    _producto.dispose();
    _cantidadAplicada.dispose();
    _incidencia.dispose();
    super.dispose();
  }

  /// Al cambiar de labor se limpia el desplegable de subtipo: sus opciones
  /// son distintas en cada una (Formación no significa nada en Riego), así
  /// que dejar el valor anterior seleccionado confundiría más de lo que
  /// ayuda.
  void _cambiarTipo(TipoActividad tipo) {
    setState(() {
      _tipo = tipo;
      _subtipo = null;
    });
  }

  Future<void> _elegirFoto() async {
    setState(() => _cargandoFoto = true);
    try {
      final destino = await elegirFoto(context, carpeta: 'fotos_actividades');
      if (mounted && destino != null) setState(() => _fotoPath = destino);
    } finally {
      if (mounted) setState(() => _cargandoFoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Registrar labor'),
          if (widget.loteNombre != null)
            Text(
              widget.loteNombre!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SelectorTipo(tipo: _tipo, onCambio: _cambiarTipo),
            const SizedBox(height: 16),
            SelectorFecha(
              etiqueta: 'Fecha de la labor',
              fecha: _fecha,
              onCambio: (f) => setState(() => _fecha = f),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              key: const Key('boton_mas_detalles'),
              onPressed: () => setState(() => _masDetalles = !_masDetalles),
              icon: Icon(_masDetalles ? Icons.expand_less : Icons.expand_more),
              label: Text(
                _masDetalles
                    ? 'Ocultar detalles'
                    : 'Agregar más detalles (opcional)',
              ),
            ),
            if (_masDetalles) ...[
              const SizedBox(height: 14),
              // Lo que pide el documento para Siembra: cuántos árboles se
              // sembraron, con qué edad de plántula y qué insumos se usaron.
              if (_esSiembra) ...[
                CampoTarjeta(
                  key: const Key('campo_arboles_sembrados'),
                  etiqueta: '¿Cuántos árboles sembró?',
                  icono: Icons.park_outlined,
                  color: PaletaCacao.verde,
                  controller: _arbolesSembrados,
                  hint: 'Cuántos árboles',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_edad_plantula'),
                  etiqueta: '¿Qué edad tenía la matica?',
                  icono: Icons.eco_outlined,
                  color: PaletaCacao.dorado,
                  controller: _edadPlantula,
                  hint: 'Edad al sembrarla',
                  suffixText: 'meses',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_insumos'),
                  etiqueta: '¿Qué usó?',
                  icono: Icons.inventory_2_outlined,
                  color: PaletaCacao.cafe,
                  controller: _insumos,
                  hint: 'Ej: Bolsas biodegradables, abono orgánico',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
              ],
              // Lo que pide el documento para Poda: tipo de desplegable, lo
              // demás se escribe normal.
              if (_esPoda) ...[
                SelectorDesplegable(
                  key: ValueKey(_tipo),
                  etiqueta: '¿Qué poda hizo?',
                  icono: Icons.content_cut,
                  color: PaletaCacao.verde,
                  opciones: _tiposPoda,
                  valor: _subtipo,
                  onCambio: (v) => setState(() => _subtipo = v),
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_arboles_podados'),
                  etiqueta: '¿Cuántos árboles podó?',
                  icono: Icons.content_cut,
                  color: PaletaCacao.verde,
                  controller: _arbolesAfectados,
                  hint: 'Cuántos árboles',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_resultado_esperado'),
                  etiqueta: '¿Para qué la hizo?',
                  icono: Icons.flag_outlined,
                  color: PaletaCacao.cafe,
                  controller: _resultadoEsperado,
                  hint: 'Ej: Mejorar sanidad y productividad del lote',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
              ],
              // Lo que pide el documento para Fertilización: tipo de
              // desplegable, producto y cantidad se escriben normal.
              if (_esFertilizacion) ...[
                SelectorDesplegable(
                  key: ValueKey(_tipo),
                  etiqueta: '¿Con qué abonó?',
                  icono: Icons.grass,
                  color: PaletaCacao.verde,
                  opciones: _tiposFertilizacion,
                  valor: _subtipo,
                  onCambio: (v) => setState(() => _subtipo = v),
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_producto_fertilizacion'),
                  etiqueta: '¿Qué producto?',
                  icono: Icons.inventory_2_outlined,
                  color: PaletaCacao.cafe,
                  controller: _producto,
                  hint: 'Ej: NPK 15-15-15',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_cantidad_fertilizacion'),
                  etiqueta: '¿Cuánto echó?',
                  icono: Icons.scale_outlined,
                  color: PaletaCacao.dorado,
                  controller: _cantidadAplicada,
                  hint: 'Ej: 25 kg',
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_arboles_fertilizados'),
                  etiqueta: '¿A cuántos árboles?',
                  icono: Icons.park_outlined,
                  color: PaletaCacao.verde,
                  controller: _arbolesAfectados,
                  hint: 'Cuántos árboles',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],
              // Lo que pide el documento para Control fitosanitario: problema
              // detectado también de desplegable, lo demás se escribe normal.
              if (_esFitosanitario) ...[
                SelectorDesplegable(
                  key: ValueKey(_tipo),
                  etiqueta: '¿Qué problema tenía?',
                  icono: Icons.pest_control,
                  color: PaletaCacao.maduro,
                  opciones: _problemasFitosanitarios,
                  valor: _subtipo,
                  onCambio: (v) => setState(() => _subtipo = v),
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_incidencia'),
                  etiqueta: '¿Qué tanto está afectado?',
                  icono: Icons.percent,
                  color: PaletaCacao.cafe,
                  controller: _incidencia,
                  hint: 'Ej: 20% de los árboles afectados',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_producto_fitosanitario'),
                  etiqueta: '¿Qué le echó?',
                  icono: Icons.inventory_2_outlined,
                  color: PaletaCacao.verde,
                  controller: _producto,
                  hint: 'Ej: Fungicida biológico Trichoderma',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_cantidad_fitosanitario'),
                  etiqueta: '¿Cuánto le echó?',
                  icono: Icons.scale_outlined,
                  color: PaletaCacao.dorado,
                  controller: _cantidadAplicada,
                  hint: 'Ej: 10 litros',
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_arboles_tratados'),
                  etiqueta: '¿Cuántos árboles curó?',
                  icono: Icons.park_outlined,
                  color: PaletaCacao.verde,
                  controller: _arbolesAfectados,
                  hint: 'Cuántos árboles',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],
              // Riego no viene descrito en el documento, pero se pidió el
              // mismo tratamiento: tipo de desplegable y cantidad normal.
              if (_esRiego) ...[
                SelectorDesplegable(
                  key: ValueKey(_tipo),
                  etiqueta: '¿Cómo regó?',
                  icono: Icons.water_drop_outlined,
                  color: PaletaCacao.verde,
                  opciones: _tiposRiego,
                  valor: _subtipo,
                  onCambio: (v) => setState(() => _subtipo = v),
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_cantidad_riego'),
                  etiqueta: '¿Cuánto echó?',
                  icono: Icons.scale_outlined,
                  color: PaletaCacao.dorado,
                  controller: _cantidadAplicada,
                  hint: 'Ej: 200 litros, 1 hora de goteo...',
                ),
                const SizedBox(height: 16),
              ],
              CampoTarjeta(
                key: const Key('campo_responsable'),
                etiqueta: '¿Quién la hizo?',
                icono: Icons.person_outline,
                color: PaletaCacao.maduro,
                controller: _responsable,
                hint: 'Quién hizo la labor',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_costo'),
                etiqueta: '¿Cuánto gastó?',
                icono: Icons.payments_outlined,
                color: PaletaCacao.dorado,
                controller: _costo,
                hint: 'Valor gastado',
                suffixText: r'$',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              CampoFoto(
                fotoPath: _fotoPath,
                cargando: _cargandoFoto,
                onTap: _elegirFoto,
                onQuitar: () => setState(() => _fotoPath = null),
                etiqueta: 'Tomar una foto (si quiere)',
              ),
              const SizedBox(height: 14),
              CampoDictado(
                campoKey: const Key('campo_observaciones_actividad'),
                controller: _observaciones,
                etiqueta: '¿Algo más?',
                hint: 'Toque el micrófono y hable, o escriba',
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
          onPressed: () => Navigator.of(context).pop((
            tipo: _tipo,
            fecha: _fecha,
            observaciones: textoONulo(_observaciones.text),
            responsable: textoONulo(_responsable.text),
            costo: aNumero(_costo.text),
            fotoPath: _fotoPath,
            resultadoEsperado: textoONulo(_resultadoEsperado.text),
            arbolesSembrados: int.tryParse(_arbolesSembrados.text.trim()),
            edadPlantulaMeses: int.tryParse(_edadPlantula.text.trim()),
            insumos: textoONulo(_insumos.text),
            subtipoLabor: _subtipo,
            arbolesAfectados: int.tryParse(_arbolesAfectados.text.trim()),
            // La calcula quien llama, con la fecha de siembra del lote.
            edadCultivoAnios: null,
            producto: textoONulo(_producto.text),
            cantidadAplicada: textoONulo(_cantidadAplicada.text),
            incidencia: textoONulo(_incidencia.text),
          )),
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}

/// Los tipos de labor como seis botones grandes con ícono, en dos filas de
/// tres: se reconocen sin leer y se tocan fácil con el dedo, a diferencia de
/// los chips pequeños que había antes.
class _SelectorTipo extends StatelessWidget {
  const _SelectorTipo({required this.tipo, required this.onCambio});

  final TipoActividad tipo;
  final ValueChanged<TipoActividad> onCambio;

  @override
  Widget build(BuildContext context) {
    // Dos filas de tres con `Expanded`, y no una cuadrícula: el diálogo mide
    // su contenido antes de dibujarlo, y un `LayoutBuilder` o un `GridView`
    // ahí dentro revientan.
    const tipos = TipoActividad.values;
    return Column(
      children: [
        for (var fila = 0; fila < tipos.length; fila += 3) ...[
          if (fila > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var i = fila; i < fila + 3 && i < tipos.length; i++) ...[
                if (i > fila) const SizedBox(width: 8),
                Expanded(
                  child: _BotonTipo(
                    tipo: tipos[i],
                    elegido: tipos[i] == tipo,
                    onTap: () => onCambio(tipos[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _BotonTipo extends StatelessWidget {
  const _BotonTipo({
    required this.tipo,
    required this.elegido,
    required this.onTap,
  });

  final TipoActividad tipo;
  final bool elegido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = elegido ? PaletaCacao.verde : PaletaCacao.dorado;
    return Semantics(
      selected: elegido,
      button: true,
      child: Material(
        color: elegido ? PaletaCacao.verdeClaro : const Color(0xFFF1E2C7),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 92,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: elegido ? PaletaCacao.verde : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconoActividad(tipo), size: 32, color: color),
                const SizedBox(height: 6),
                Text(
                  _nombreDelCampo(tipo),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: PaletaCacao.crema,
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
