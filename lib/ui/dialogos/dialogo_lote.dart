import 'package:flutter/material.dart';

import '../../data/local/database.dart';
import '../tema.dart';
import '../widgets/comunes.dart';
import '../widgets/selector_fecha.dart';

typedef DatosLote = ({
  String nombre,
  String codigo,
  double areaHa,
  String variedad,
  DateTime fechaSiembra,
  String? fotoPath,
});

/// Las 13 variedades de cacao reconocidas en Colombia (requerimiento del
/// registro de lotes): el productor elige la que corresponda a su cultivo
/// en vez de escribirla a mano, para no tener nombres distintos para la
/// misma variedad.
const _variedades = [
  'Criollo',
  'Forastero',
  'Trinitario',
  'TCS13',
  'TCS19',
  'SCC53',
  'SCC82',
  'SCC83',
  'CCS73',
  'CCS77',
  'CCS80',
  'Cacao Amazónico',
  'Cacao Fino de Aroma',
];

/// Descripción corta de cada variedad, para que el productor sepa qué está
/// eligiendo antes de tocarla (muchos no reconocen códigos como "SCC53"
/// a simple vista). Los clones colombianos (TCS, SCC, CCS) resumen lo
/// reportado por Fedecacao/Agrosavia en sus evaluaciones; conviene
/// confirmar la recomendación exacta para cada zona con el técnico de
/// Fedecacao antes de sembrar.
const _descripciones = <String, String>{
  'Criollo':
      'La variedad más fina y antigua. Mazorca de cáscara delgada y grano '
      'casi blanco, con un sabor suave y muy aromático. Es delicada: '
      'produce poco y se enferma con facilidad.',
  'Forastero':
      'La más sembrada en el mundo por su resistencia y buena producción. '
      'Grano morado y sabor fuerte, menos aromático que el Criollo. Es la '
      'base del cacao corriente.',
  'Trinitario':
      'Cruce natural entre Criollo y Forastero, originado en Trinidad. Junta '
      'la buena producción del Forastero con un sabor más fino, cercano '
      'al del Criollo.',
  'TCS13':
      'Clon colombiano (Corpoica La Suiza) registrado en 2017. Se poliniza '
      'solo (no necesita otro árbol cerca), con buena producción y baja '
      'incidencia de enfermedades.',
  'TCS19':
      'Hermano del TCS13 y el de mejor desempeño en las pruebas colombianas: '
      'más mazorcas por árbol y buen comportamiento en distintas zonas y '
      'niveles de sombra.',
  'SCC53':
      'Clon colombiano de Selección Corpoica, con grano de buen tamaño. '
      'Produce menos mazorcas que los TCS y necesita otro árbol cerca '
      'para polinizar bien.',
  'SCC82':
      'De la misma familia que el SCC53. Se poliniza solo en parte, lo que '
      'ayuda a fijar cosecha aunque no haya otras variedades sembradas '
      'cerca.',
  'SCC83':
      'Clon SCC de grano grande, con el mismo comportamiento general de sus '
      'hermanos SCC53 y SCC82: producción media y necesita polinización '
      'cruzada.',
  'CCS73':
      'Clon de la Colección Corpoica La Suiza, se destaca por el buen tamaño '
      'de su grano. Producción moderada.',
  'CCS77':
      'Clon CCS de comportamiento similar al CCS73: grano de buena calidad, '
      'rendimiento medio, necesita otras variedades cerca para '
      'polinizar.',
  'CCS80':
      'Completa la familia CCS, con las mismas características generales: '
      'buen grano y necesidad de polinización cruzada con otro árbol.',
  'Cacao Amazónico':
      'Material típico de la región amazónica colombiana, adaptado a su '
      'clima y suelo particulares.',
  'Cacao Fino de Aroma':
      'No es una sola variedad, sino una categoría: cacaos (normalmente '
      'Criollos o Trinitarios) con notas florales o frutales muy '
      'valoradas en chocolatería fina, que suelen pagarse mejor que el '
      'cacao corriente.',
};

/// El código que le toca al próximo lote nuevo: uno más que el número más
/// alto ya usado en **cualquiera** de las fincas del productor (no solo en
/// la finca donde se está agregando), así dos lotes nunca quedan con el
/// mismo código aunque estén en fincas distintas. Si el productor no tiene
/// lotes todavía, arranca en "001".
///
/// Los códigos viejos pueden traer texto (ej. "Lote 007"): se toma el
/// primer número que aparezca en cada uno y se ignoran los que no tengan
/// ninguno.
String siguienteCodigoLote(Iterable<String> codigosExistentes) {
  var maximo = 0;
  for (final codigo in codigosExistentes) {
    final numero = int.tryParse(RegExp(r'\d+').stringMatch(codigo) ?? '');
    if (numero != null && numero > maximo) maximo = numero;
  }
  return (maximo + 1).toString().padLeft(3, '0');
}

/// Pide los datos de un lote nuevo, o los de uno existente para editarlo si
/// se pasa [inicial]: en ese caso el formulario sale ya lleno con lo que
/// tenía el lote.
///
/// [codigoSugerido] solo aplica cuando el lote es nuevo (sin [inicial]): es
/// el código que ya calculó [siguienteCodigoLote], y el formulario lo
/// muestra fijo, sin dejar escribirlo, para que la numeración de lotes
/// nunca se repita ni dependa de que el productor la lleve en la cabeza.
Future<DatosLote?> pedirDatosLote(
  BuildContext context, {
  Lote? inicial,
  String? codigoSugerido,
}) {
  return showDialog<DatosLote>(
    context: context,
    builder: (_) =>
        _DialogoLote(inicial: inicial, codigoSugerido: codigoSugerido),
  );
}

class _DialogoLote extends StatefulWidget {
  const _DialogoLote({this.inicial, this.codigoSugerido});

  final Lote? inicial;
  final String? codigoSugerido;

  @override
  State<_DialogoLote> createState() => _DialogoLoteState();
}

class _DialogoLoteState extends State<_DialogoLote> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(
    text: widget.inicial?.nombre ?? '',
  );
  late final _codigo = TextEditingController(
    text: widget.inicial?.codigo ?? widget.codigoSugerido ?? '',
  );

  /// El código queda fijo solo cuando se está creando el lote y ya se
  /// calculó uno: al editar un lote existente, su código se puede seguir
  /// corrigiendo a mano como siempre.
  bool get _codigoAutomatico =>
      widget.inicial == null && widget.codigoSugerido != null;
  late final _area = TextEditingController(
    text: widget.inicial?.areaSembradaHa.toString() ?? '',
  );
  // Si el lote ya existía con una variedad que no está en la lista actual
  // (dato viejo escrito a mano), se deja sin elegir para que el productor
  // la vuelva a seleccionar.
  late String? _variedad =
      widget.inicial != null &&
          _variedades.contains(widget.inicial!.variedadCacao)
      ? widget.inicial!.variedadCacao
      : null;
  late DateTime? _fechaSiembra = widget.inicial?.fechaSiembra;

  /// Una foto del lote hace que su tarjeta se reconozca sin leer el nombre.
  late String? _fotoPath = widget.inicial?.fotoPath;
  var _cargandoFoto = false;

  Future<void> _elegirFoto() async {
    setState(() => _cargandoFoto = true);
    try {
      final destino = await elegirFoto(context, carpeta: 'fotos_lotes');
      if (mounted && destino != null) setState(() => _fotoPath = destino);
    } finally {
      if (mounted) setState(() => _cargandoFoto = false);
    }
  }

  var _faltaFecha = false;
  var _faltaVariedad = false;

  bool get _esNuevo => widget.inicial == null;

  @override
  void dispose() {
    _nombre.dispose();
    _codigo.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _elegirVariedad() async {
    final elegida = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HojaVariedades(seleccion: _variedad),
    );
    if (elegida != null) {
      setState(() {
        _variedad = elegida;
        _faltaVariedad = false;
      });
    }
  }

  void _aceptar() {
    final fechaOk = _fechaSiembra != null;
    final variedadOk = _variedad != null;
    setState(() {
      _faltaFecha = !fechaOk;
      _faltaVariedad = !variedadOk;
    });
    if (!_formKey.currentState!.validate() || !fechaOk || !variedadOk) return;
    Navigator.of(context).pop((
      nombre: _nombre.text.trim(),
      codigo: _codigo.text.trim(),
      areaHa: aNumero(_area.text)!,
      variedad: _variedad!,
      fechaSiembra: _fechaSiembra!,
      fotoPath: _fotoPath,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_esNuevo ? 'Nuevo lote' : 'Editar lote'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoTarjeta(
                key: const Key('campo_codigo_lote'),
                etiqueta: 'Código del lote',
                icono: Icons.qr_code_2_outlined,
                color: PaletaCacao.dorado,
                controller: _codigo,
                hint: 'Ej: Lote 001',
                textCapitalization: TextCapitalization.words,
                validator: campoRequerido,
                readOnly: _codigoAutomatico,
              ),
              if (_codigoAutomatico)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Se asigna solo, siguiendo el orden de todos sus '
                    'lotes (de cualquiera de sus fincas), así nunca se '
                    'repite.',
                    style: TextStyle(
                      color: PaletaCacao.crema.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_nombre_lote'),
                etiqueta: 'Nombre del lote',
                icono: Icons.park_outlined,
                color: PaletaCacao.verde,
                controller: _nombre,
                hint: 'Nombre del lote',
                textCapitalization: TextCapitalization.words,
                validator: campoRequerido,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                key: const Key('campo_area'),
                etiqueta: 'Área sembrada',
                icono: Icons.landscape_outlined,
                color: PaletaCacao.cafe,
                controller: _area,
                hint: 'Área sembrada',
                suffixText: 'ha',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => validarRango(
                  v,
                  min: 0,
                  // 1000 ha es ya una finca enorme para un solo lote; por
                  // arriba de eso lo más probable es un error de tecleo.
                  max: 1000,
                  etiqueta: 'Área',
                ),
              ),
              const SizedBox(height: 16),
              // En vez de un dropdown con solo el código (nadie sabe qué es
              // "SCC53" de solo verlo), esto abre una hoja que describe cada
              // variedad y solo se elige después de leerla.
              _SelectorVariedad(
                key: const Key('campo_variedad'),
                variedad: _variedad,
                error: _faltaVariedad,
                onTap: _elegirVariedad,
              ),
              const SizedBox(height: 14),
              SelectorFecha(
                etiqueta: 'Fecha de siembra',
                fecha: _fechaSiembra,
                onCambio: (f) => setState(() {
                  _fechaSiembra = f;
                  _faltaFecha = false;
                }),
              ),
              if (_faltaFecha)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Elige la fecha de siembra',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              CampoFoto(
                fotoPath: _fotoPath,
                cargando: _cargandoFoto,
                onTap: _elegirFoto,
                onQuitar: () => setState(() => _fotoPath = null),
                etiqueta: 'Foto del lote (si quiere)',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
          onPressed: _aceptar,
          child: Text(_esNuevo ? 'Guardar' : 'Guardar cambios'),
        ),
      ],
    );
  }
}

/// Campo tocable que abre la hoja de variedades. Muestra la descripción
/// corta de la variedad ya elegida (no solo el nombre), para que quede
/// claro qué se seleccionó sin tener que volver a abrir la hoja.
class _SelectorVariedad extends StatelessWidget {
  const _SelectorVariedad({
    super.key,
    required this.variedad,
    required this.error,
    required this.onTap,
  });

  final String? variedad;
  final bool error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final elegida = variedad != null;
    final color = PaletaCacao.verde;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: PaletaCacao.tarjeta,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: error
                    ? Theme.of(context).colorScheme.error
                    : color.withValues(alpha: 0.16),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Stack(
              children: [
                Positioned(
                  top: -10,
                  right: -10,
                  child: Icon(
                    Icons.spa_outlined,
                    size: 74,
                    color: color.withValues(alpha: 0.10),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.spa_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Variedad de cacao',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: PaletaCacao.crema,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: color.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: elegida
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  variedad!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: PaletaCacao.crema,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _descripciones[variedad!] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: PaletaCacao.crema.withValues(
                                      alpha: 0.75,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Toque para ver y elegir la variedad',
                              style: TextStyle(
                                color: PaletaCacao.crema.withValues(alpha: 0.6),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (error)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Elija la variedad',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

/// Hoja inferior con las 13 variedades y su descripción: el productor lee
/// de qué se trata cada una antes de tocarla, en vez de elegir a ciegas un
/// código como "SCC53".
class _HojaVariedades extends StatelessWidget {
  const _HojaVariedades({required this.seleccion});

  final String? seleccion;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, control) {
        return Container(
          decoration: const BoxDecoration(
            color: PaletaCacao.tarjeta,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: PaletaCacao.crema.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Row(
                  children: [
                    Icon(Icons.spa_outlined, color: PaletaCacao.verde),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Elija la variedad de cacao',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: PaletaCacao.crema,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: control,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: _variedades.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final variedad = _variedades[i];
                    final elegida = variedad == seleccion;
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.of(context).pop(variedad),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: elegida
                              ? PaletaCacao.verde.withValues(alpha: 0.16)
                              : PaletaCacao.crema.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: elegida
                                ? PaletaCacao.verde
                                : PaletaCacao.crema.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    variedad,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: PaletaCacao.crema,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _descripciones[variedad] ?? '',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.35,
                                      color: PaletaCacao.crema.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (elegida) ...[
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.check_circle,
                                color: PaletaCacao.verde,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
