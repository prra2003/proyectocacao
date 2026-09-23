import 'package:flutter/material.dart';

import '../../data/local/enums.dart';
import '../formato.dart';
import '../tema.dart';
import '../widgets/comunes.dart';
import '../widgets/selector_fecha.dart';

/// Opciones fijas de cada desplegable, tal como las trae el documento de
/// requerimientos: el productor elige una, no escribe a mano.
const _tiposPoda = ['Formación', 'Mantenimiento', 'Rehabilitación'];
const _tiposFertilizacion = ['Química', 'Orgánica', 'Foliar', 'Edáfica (suelo)'];
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

Future<DatosActividad?> pedirDatosActividad(BuildContext context) {
  return showDialog<DatosActividad>(
    context: context,
    builder: (_) => const _DialogoActividad(),
  );
}

class _DialogoActividad extends StatefulWidget {
  const _DialogoActividad();

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
  final _edadCultivo = TextEditingController();
  String? _subtipo;

  // Fertilización / Control fitosanitario
  final _producto = TextEditingController();
  final _cantidadAplicada = TextEditingController();
  final _incidencia = TextEditingController();

  var _tipo = TipoActividad.poda;
  DateTime _fecha = DateTime.now();
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
    _edadCultivo.dispose();
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
      title: const Text('Registrar labor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tipo in TipoActividad.values)
                  ChoiceChip(
                    label: Text(etiquetaActividad(tipo)),
                    avatar: Icon(iconoActividad(tipo), size: 18),
                    selected: _tipo == tipo,
                    onSelected: (_) => _cambiarTipo(tipo),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SelectorFecha(
              etiqueta: 'Fecha de la labor',
              fecha: _fecha,
              onCambio: (f) => setState(() => _fecha = f),
            ),
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
                hint: 'Cuántos árboles',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_edad_plantula'),
                etiqueta: 'Edad de la plántula',
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
                etiqueta: 'Insumos usados',
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
                hint: 'Cuántos árboles',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_edad_cultivo'),
                etiqueta: 'Edad del cultivo',
                icono: Icons.schedule,
                color: PaletaCacao.dorado,
                controller: _edadCultivo,
                hint: 'Edad del lote',
                suffixText: 'años',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_resultado_esperado'),
                etiqueta: 'Resultado esperado',
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
                etiqueta: 'Producto',
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
                hint: 'Cuántos árboles',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_edad_cultivo'),
                etiqueta: 'Edad del cultivo',
                icono: Icons.schedule,
                color: PaletaCacao.maduro,
                controller: _edadCultivo,
                hint: 'Edad del lote',
                suffixText: 'años',
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
                hint: 'Ej: 20% de los árboles afectados',
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_producto_fitosanitario'),
                etiqueta: 'Producto aplicado',
                icono: Icons.inventory_2_outlined,
                color: PaletaCacao.verde,
                controller: _producto,
                hint: 'Ej: Fungicida biológico Trichoderma',
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_cantidad_fitosanitario'),
                etiqueta: 'Cantidad',
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
                hint: 'Cuántos árboles',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_edad_cultivo'),
                etiqueta: 'Edad del cultivo',
                icono: Icons.schedule,
                color: PaletaCacao.maduro,
                controller: _edadCultivo,
                hint: 'Edad del lote',
                suffixText: 'años',
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
                etiqueta: 'Cantidad aplicada',
                icono: Icons.scale_outlined,
                color: PaletaCacao.dorado,
                controller: _cantidadAplicada,
                hint: 'Ej: 200 litros, 1 hora de goteo...',
              ),
              const SizedBox(height: 16),
            ],
            CampoTarjeta(
              key: const Key('campo_responsable'),
              etiqueta: 'Responsable',
              icono: Icons.person_outline,
              color: PaletaCacao.maduro,
              controller: _responsable,
              hint: 'Quién hizo la labor',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            CampoTarjeta(
              key: const Key('campo_costo'),
              etiqueta: 'Costo',
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
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('campo_observaciones_actividad'),
              controller: _observaciones,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                hintText: 'Qué se hizo, con qué producto, dosis...',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
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
          edadCultivoAnios: int.tryParse(_edadCultivo.text.trim()),
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