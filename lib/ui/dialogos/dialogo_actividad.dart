import 'package:flutter/material.dart';

import '../../data/local/database.dart';
import '../../data/local/enums.dart';
import '../../data/repositories/lote_repository.dart';
import '../../data/repositories/perfil_repository.dart';
import '../formato.dart';
import '../tema.dart';
import '../widgets/campo_dictado.dart';
import '../widgets/nota_bpa.dart';
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
/// Lo que hace falta para repartir un gasto que fue de varios lotes.
///
/// Se pasa al formulario desde la pantalla, que es la que sabe en qué finca
/// está: el formulario no consulta la base.
typedef RepartoDelGasto = ({
  /// Hectáreas sembradas de este lote.
  double hectareasLote,

  /// Hectáreas sembradas de toda la finca, este lote incluido.
  double hectareasFinca,

  /// Cuántos lotes tiene la finca. Con uno solo no hay nada que repartir y la
  /// pregunta no se hace.
  int lotesDeLaFinca,
});

typedef DatosActividad = ({
  TipoActividad tipo,
  DateTime fecha,
  String? observaciones,
  String? responsable,

  /// Lo que le toca a **este** lote. Es lo que suman las cuentas del lote.
  double? costo,

  /// Lo pagado completo, si el gasto fue de varios lotes; `null` si fue solo
  /// de este y [costo] ya es todo.
  double? costoTotalCompartido,
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
/// Abre el formulario de labor.
///
/// Con [inicial] abre el mismo formulario ya lleno, para corregir o terminar
/// de llenar una labor que ya está anotada: es el mismo de siempre, no otro
/// distinto, para que nadie tenga que aprender dos pantallas.
Future<DatosActividad?> pedirDatosActividad(
  BuildContext context, {
  TipoActividad? tipoInicial,
  String? loteNombre,
  DatosActividad? inicial,
  RepartoDelGasto? reparto,
}) {
  return showDialog<DatosActividad>(
    context: context,
    builder: (_) => _DialogoActividad(
      tipoInicial: tipoInicial,
      loteNombre: loteNombre,
      inicial: inicial,
      reparto: reparto,
    ),
  );
}

/// La labor ya guardada, en la forma que entiende el formulario.
DatosActividad datosDeLabor(ActividadAgricola labor) => (
  tipo: labor.tipoActividad,
  fecha: labor.fecha,
  observaciones: labor.observaciones,
  responsable: labor.responsable,
  costo: labor.costo,
  costoTotalCompartido: labor.costoTotalCompartido,
  resultadoEsperado: labor.resultadoEsperado,
  arbolesSembrados: labor.arbolesSembrados,
  edadPlantulaMeses: labor.edadPlantulaMeses,
  insumos: labor.insumos,
  subtipoLabor: labor.subtipoLabor,
  arbolesAfectados: labor.arbolesAfectados,
  edadCultivoAnios: labor.edadCultivoAnios,
  producto: labor.producto,
  cantidadAplicada: labor.cantidadAplicada,
  incidencia: labor.incidencia,
);

/// Las hectáreas con las que se reparte un gasto de varios lotes.
///
/// Devuelve `null` cuando no hay nada que repartir —la finca tiene un solo
/// lote, o falta el área— y entonces el formulario no hace la pregunta.
///
/// Se consulta al abrir el formulario y no se guarda: si acabó de registrar
/// otro lote, la división tiene que contar con él.
Future<RepartoDelGasto?> repartoDelGasto(
  LoteRepository repo,
  Lote lote,
) async {
  final lotes = await repo.watchLotesDe(lote.fincaId).first;
  if (lotes.length < 2 || lote.areaSembradaHa <= 0) return null;
  final hectareas = lotes.fold<double>(0, (suma, l) => suma + l.areaSembradaHa);
  if (hectareas <= lote.areaSembradaHa) return null;
  return (
    hectareasLote: lote.areaSembradaHa,
    hectareasFinca: hectareas,
    lotesDeLaFinca: lotes.length,
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
    costoTotalCompartido: datos.costoTotalCompartido,
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

/// Guarda sobre [labor] lo que se corrigió en el formulario.
///
/// Devuelve cuántas filas cambió; **0 significa que pasó la semana** y la
/// labor quedó cerrada, no que no hubiera nada que cambiar. Quien llama tiene
/// que decírselo a la persona en vez de dar por guardado.
///
/// Está aquí, y no copiado en cada pantalla, porque la actualización escribe
/// todas las columnas de una: a la que se le olvide pasar un campo lo borra.
Future<int> actualizarLabor(
  LoteRepository repo,
  ActividadAgricola labor,
  DatosActividad datos,
) {
  return repo.actualizarActividad(
    id: labor.id,
    tipo: datos.tipo,
    fecha: datos.fecha,
    observaciones: datos.observaciones,
    responsable: datos.responsable,
    costo: datos.costo,
    costoTotalCompartido: datos.costoTotalCompartido,
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
  const _DialogoActividad({
    this.tipoInicial,
    this.loteNombre,
    this.inicial,
    this.reparto,
  });

  final TipoActividad? tipoInicial;
  final String? loteNombre;

  /// Con qué repartir un gasto de varios lotes. `null` en una finca de un
  /// solo lote, o donde la pantalla no tenga el dato: entonces no se
  /// pregunta y el costo es todo de este lote, como antes.
  final RepartoDelGasto? reparto;

  /// Valores con los que arranca el formulario, si se está corrigiendo una
  /// labor ya anotada.
  final DatosActividad? inicial;

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

  late var _tipo =
      widget.inicial?.tipo ?? widget.tipoInicial ?? TipoActividad.poda;
  late DateTime _fecha = widget.inicial?.fecha ?? DateTime.now();

  bool get _editando => widget.inicial != null;

  /// Lo único obligatorio es qué labor y cuándo. Todo lo demás (tipo de poda,
  /// árboles, responsable, costo, foto, notas) va aquí dentro, cerrado: quien
  /// tenga tiempo lo llena, y quien no, registra con dos toques.
  var _masDetalles = false;

  /// Se pidió decir qué fue y se dejó en blanco. Mientras esté en true, el
  /// campo sale en rojo con el motivo.
  var _faltaDecirQueFue = false;

  /// El gasto fue de toda la finca, no solo de este lote.
  ///
  /// Una fertilización de siete bultos para las seis hectáreas de la finca no
  /// es un gasto de este lote: si se anota completo aquí, el costo por kilo
  /// de este lote sale inflado y el de los otros lotes sale regalado. Con
  /// esto marcado se guarda la parte proporcional al área, y el valor
  /// completo queda aparte para no perderlo.
  var _deTodaLaFinca = false;

  /// ¿Hay algo que repartir? Con un solo lote, o sin áreas, no.
  bool get _sePuedeRepartir {
    final r = widget.reparto;
    return r != null &&
        r.lotesDeLaFinca > 1 &&
        r.hectareasLote > 0 &&
        r.hectareasFinca > r.hectareasLote;
  }

  /// Qué parte del gasto le toca a este lote, entre 0 y 1.
  double get _parteDelLote {
    final r = widget.reparto!;
    return r.hectareasLote / r.hectareasFinca;
  }

  /// Lo escrito en el campo de costo, tal como se escribió.
  double? get _costoEscrito => aNumero(_costo.text);

  /// Lo que se va a guardar como costo de **este** lote.
  double? get _costoDelLote {
    final escrito = _costoEscrito;
    if (escrito == null) return null;
    if (!(_deTodaLaFinca && _sePuedeRepartir)) return escrito;
    // Redondeado al peso: un costo con decimales en pesos no significa nada.
    return (escrito * _parteDelLote).roundToDouble();
  }

  bool get _esSiembra => _tipo == TipoActividad.siembra;
  bool get _esPoda => _tipo == TipoActividad.poda;
  bool get _esFertilizacion => _tipo == TipoActividad.fertilizacion;
  bool get _esFitosanitario => _tipo == TipoActividad.controlFitosanitario;
  bool get _esRiego => _tipo == TipoActividad.riego;

  /// Un gasto o una labor que la aplicación todavía no tiene en la lista:
  /// transporte, jornales, bolsas, arriendo. Lo único que se le exige es que
  /// diga qué fue, porque "Otra labor" a secas no le sirve a nadie después.
  bool get _esOtro => _tipo == TipoActividad.otro;

  @override
  void initState() {
    super.initState();
    // En cuanto empieza a escribir, el reclamo en rojo sobra.
    _observaciones.addListener(_borrarElReclamo);
    // Al escribir el costo hay que recalcular lo que le toca al lote, que se
    // muestra debajo. CampoTarjeta no expone onChanged.
    _costo.addListener(_repintar);
    final inicial = widget.inicial;
    if (inicial == null) return;
    // Abrir el formulario en blanco sobre una labor ya anotada seria pedirle
    // a la persona que la escriba otra vez.
    _observaciones.text = inicial.observaciones ?? '';
    _responsable.text = inicial.responsable ?? '';
    // De un gasto compartido se muestra lo pagado completo, que es lo que la
    // persona recuerda haber pagado, no la parte ya repartida.
    final compartido = inicial.costoTotalCompartido;
    _deTodaLaFinca = compartido != null;
    final aMostrar = compartido ?? inicial.costo;
    _costo.text = aMostrar == null ? '' : aMostrar.toStringAsFixed(0);
    _resultadoEsperado.text = inicial.resultadoEsperado ?? '';
    _arbolesSembrados.text = inicial.arbolesSembrados?.toString() ?? '';
    _edadPlantula.text = inicial.edadPlantulaMeses?.toString() ?? '';
    _insumos.text = inicial.insumos ?? '';
    _arbolesAfectados.text = inicial.arbolesAfectados?.toString() ?? '';
    _producto.text = inicial.producto ?? '';
    _cantidadAplicada.text = inicial.cantidadAplicada ?? '';
    _incidencia.text = inicial.incidencia ?? '';
    _subtipo = inicial.subtipoLabor;
    // Los detalles arrancan abiertos: si vino a terminar de llenar, lo que
    // busca está justamente ahí dentro.
    _masDetalles = true;
  }

  void _repintar() {
    if (_deTodaLaFinca && _sePuedeRepartir) setState(() {});
  }

  void _borrarElReclamo() {
    if (!_faltaDecirQueFue) return;
    if (textoONulo(_observaciones.text) == null) return;
    setState(() => _faltaDecirQueFue = false);
  }

  @override
  void dispose() {
    _observaciones.removeListener(_borrarElReclamo);
    _observaciones.dispose();
    _responsable.dispose();
    _costo
      ..removeListener(_repintar)
      ..dispose();
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
      _faltaDecirQueFue = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_editando ? 'Corregir labor' : 'Registrar labor'),
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
            const SizedBox(height: 14),
            // Las demás labores ya se nombran solas con el botón que se tocó.
            // Esta no: va arriba y fuera de los detalles opcionales porque,
            // sin ella, el registro queda como "Otra labor" y dentro de un
            // año nadie sabrá si fue el transporte o el jornal de cosecha.
            if (_esOtro) ...[
              CampoTarjeta(
                key: const Key('campo_que_fue'),
                etiqueta: '¿Qué gasto o labor fue?',
                icono: Icons.edit_note_outlined,
                color: PaletaCacao.cafe,
                controller: _observaciones,
                hint: 'Ej: transporte del bulto, jornal de cosecha, bolsas',
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  _faltaDecirQueFue
                      ? 'Escriba qué fue para poder guardarlo.'
                      : 'Esto no está en la lista de la aplicación, así que '
                            'queda anotado con el nombre que usted le ponga.',
                  key: const Key('nota_que_fue'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _faltaDecirQueFue
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            const NotaBpa(
              titulo: '¿Para qué sirve anotar esta labor?',
              puntos: [
                'En una visita, el ICA pide ver el registro de lo que se le '
                    'aplicó al cultivo: qué producto, cuánto, cuándo y quién '
                    'lo aplicó. Anotarlo aquí es tenerlo listo.',
                'Los registros hay que poder mostrarlos durante al menos dos '
                    'años. En la libreta de papel eso casi nunca se logra.',
                'Saber qué se le hizo a cada lote es lo que después permite '
                    'explicar por qué ese lote rindió o no rindió.',
              ],
              ojo: 'Si fumigó, el ICA además pide el número de registro ICA '
                  'del producto, el ingrediente activo y el periodo de '
                  'carencia —los días de espera antes de cosechar—. La '
                  'aplicación todavía no tiene casilla para eso: escríbalo '
                  'en Observaciones.',
            ),
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
                  etiqueta: 'Árboles sembrados',
                  icono: Icons.park_outlined,
                  color: PaletaCacao.verde,
                  controller: _arbolesSembrados,
                  hint: 'Cantidad de árboles',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_edad_plantula'),
                  etiqueta: 'Edad de la plántula',
                  icono: Icons.eco_outlined,
                  color: PaletaCacao.dorado,
                  controller: _edadPlantula,
                  hint: 'Meses al momento de sembrarla',
                  suffixText: 'meses',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_insumos'),
                  etiqueta: 'Insumos utilizados',
                  icono: Icons.inventory_2_outlined,
                  color: PaletaCacao.cafe,
                  controller: _insumos,
                  hint: 'Ej: bolsas biodegradables, abono orgánico',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
              ],
              // Lo que pide el documento para Poda: tipo de desplegable, lo
              // demás se escribe normal.
              if (_esPoda) ...[
                SelectorDesplegable(
                  key: ValueKey(_tipo),
                  etiqueta: 'Tipo de poda',
                  icono: Icons.content_cut,
                  color: PaletaCacao.verde,
                  opciones: _tiposPoda,
                  valor: _subtipo,
                  onCambio: (v) => setState(() => _subtipo = v),
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_arboles_podados'),
                  etiqueta: 'Árboles podados',
                  icono: Icons.content_cut,
                  color: PaletaCacao.verde,
                  controller: _arbolesAfectados,
                  hint: 'Cantidad de árboles',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_resultado_esperado'),
                  etiqueta: 'Resultado esperado',
                  icono: Icons.flag_outlined,
                  color: PaletaCacao.cafe,
                  controller: _resultadoEsperado,
                  hint: 'Ej: mejorar la sanidad y la productividad del lote',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
              ],
              // Lo que pide el documento para Fertilización: tipo de
              // desplegable, producto y cantidad se escriben normal.
              if (_esFertilizacion) ...[
                SelectorDesplegable(
                  key: ValueKey(_tipo),
                  etiqueta: 'Tipo de fertilización',
                  icono: Icons.grass,
                  color: PaletaCacao.verde,
                  opciones: _tiposFertilizacion,
                  valor: _subtipo,
                  onCambio: (v) => setState(() => _subtipo = v),
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_producto_fertilizacion'),
                  etiqueta: 'Producto aplicado',
                  icono: Icons.inventory_2_outlined,
                  color: PaletaCacao.cafe,
                  controller: _producto,
                  hint: 'Ej: NPK 15-15-15',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_cantidad_fertilizacion'),
                  etiqueta: 'Cantidad aplicada',
                  icono: Icons.scale_outlined,
                  color: PaletaCacao.dorado,
                  controller: _cantidadAplicada,
                  hint: 'Ej: 25 kg',
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_arboles_fertilizados'),
                  etiqueta: 'Árboles fertilizados',
                  icono: Icons.park_outlined,
                  color: PaletaCacao.verde,
                  controller: _arbolesAfectados,
                  hint: 'Cantidad de árboles',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],
              // Lo que pide el documento para Control fitosanitario: problema
              // detectado también de desplegable, lo demás se escribe normal.
              if (_esFitosanitario) ...[
                SelectorDesplegable(
                  key: ValueKey(_tipo),
                  etiqueta: 'Problema detectado',
                  icono: Icons.pest_control,
                  color: PaletaCacao.maduro,
                  opciones: _problemasFitosanitarios,
                  valor: _subtipo,
                  onCambio: (v) => setState(() => _subtipo = v),
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_incidencia'),
                  etiqueta: 'Incidencia',
                  icono: Icons.percent,
                  color: PaletaCacao.cafe,
                  controller: _incidencia,
                  hint: 'Ej: 20% de los árboles',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_producto_fitosanitario'),
                  etiqueta: 'Producto aplicado',
                  icono: Icons.inventory_2_outlined,
                  color: PaletaCacao.verde,
                  controller: _producto,
                  hint: 'Ej: fungicida biológico Trichoderma',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_cantidad_fitosanitario'),
                  etiqueta: 'Cantidad aplicada',
                  icono: Icons.scale_outlined,
                  color: PaletaCacao.dorado,
                  controller: _cantidadAplicada,
                  hint: 'Ej: 10 litros',
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_arboles_tratados'),
                  etiqueta: 'Árboles tratados',
                  icono: Icons.park_outlined,
                  color: PaletaCacao.verde,
                  controller: _arbolesAfectados,
                  hint: 'Cantidad de árboles',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],
              // Riego no viene descrito en el documento, pero se pidió el
              // mismo tratamiento: tipo de desplegable y cantidad normal.
              if (_esRiego) ...[
                SelectorDesplegable(
                  key: ValueKey(_tipo),
                  etiqueta: 'Tipo de riego',
                  icono: Icons.water_drop_outlined,
                  color: PaletaCacao.verde,
                  opciones: _tiposRiego,
                  valor: _subtipo,
                  onCambio: (v) => setState(() => _subtipo = v),
                ),
                const SizedBox(height: 16),
                CampoTarjeta(
                  key: const Key('campo_cantidad_riego'),
                  etiqueta: 'Cantidad de agua',
                  icono: Icons.scale_outlined,
                  color: PaletaCacao.dorado,
                  controller: _cantidadAplicada,
                  hint: 'Ej: 200 litros, 1 hora de goteo',
                ),
                const SizedBox(height: 16),
              ],
              CampoTarjeta(
                key: const Key('campo_responsable'),
                etiqueta: 'Responsable',
                icono: Icons.person_outline,
                color: PaletaCacao.maduro,
                controller: _responsable,
                hint: 'Nombre de quien la realizó',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_costo'),
                etiqueta: 'Costo',
                icono: Icons.payments_outlined,
                color: PaletaCacao.dorado,
                controller: _costo,
                hint: 'Valor en pesos',
                suffixText: r'$',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              if (_sePuedeRepartir) _preguntaDelReparto(context),
              // En "Otra labor" este mismo texto ya se pidió arriba, con su
              // nombre propio. Mostrarlo otra vez aquí sería el mismo campo
              // dos veces en la misma pantalla.
              if (!_esOtro) ...[
                const SizedBox(height: 14),
                CampoDictado(
                  campoKey: const Key('campo_observaciones_actividad'),
                  controller: _observaciones,
                  etiqueta: 'Observaciones',
                  hint: 'Toque el micrófono y hable, o escriba',
                ),
              ],
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
          onPressed: () => _registrar(context),
          child: Text(_editando ? 'Guardar' : 'Registrar'),
        ),
      ],
    );
  }

  /// "¿Fue solo de este lote, o de toda la finca?", y la cuenta hecha.
  ///
  /// Se pregunta así y no por porcentaje porque nadie sabe sus porcentajes y
  /// todo el mundo sabe sus hectáreas —que además la aplicación ya tiene—.
  /// La división por área es una aproximación: buena para abono y jornales,
  /// que crecen con el terreno; mala para algo que se hizo en un solo lote.
  /// Por eso se pregunta gasto por gasto y el valor repartido se puede
  /// corregir a mano desmarcándola.
  Widget _preguntaDelReparto(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final reparto = widget.reparto!;
    final completo = _costoEscrito;
    final delLote = _costoDelLote;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            color: _deTodaLaFinca
                ? PaletaCacao.verdeClaro
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _deTodaLaFinca = !_deTodaLaFinca),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 14, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      key: const Key('gasto_de_toda_la_finca'),
                      value: _deTodaLaFinca,
                      onChanged: (v) =>
                          setState(() => _deTodaLaFinca = v ?? false),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 11, bottom: 4),
                        child: Text(
                          'Este gasto fue para toda la finca, no solo para '
                          'este lote',
                          style: textos.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_deTodaLaFinca) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Text(
                completo == null || delLote == null
                    ? 'Escriba lo que pagó en total y aquí sale cuánto le '
                          'toca a este lote.'
                    : 'De los ${pesos(completo)}, a este lote le tocan '
                          '${pesos(delLote)} — '
                          '${numeroCorto(reparto.hectareasLote)} de '
                          '${numeroCorto(reparto.hectareasFinca)} hectáreas. '
                          'Lo que pagó completo queda guardado igual.',
                key: const Key('cuenta_del_reparto'),
                style: textos.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _registrar(BuildContext context) {
    if (_esOtro && textoONulo(_observaciones.text) == null) {
      setState(() => _faltaDecirQueFue = true);
      return;
    }
    Navigator.of(context).pop((
            tipo: _tipo,
            fecha: _fecha,
            observaciones: textoONulo(_observaciones.text),
            responsable: textoONulo(_responsable.text),
            costo: _costoDelLote,
            costoTotalCompartido: _deTodaLaFinca && _sePuedeRepartir
                ? _costoEscrito
                : null,
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
          ));
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
