import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/local/enums.dart';
import '../data/repositories/costo_por_kilo.dart';
import '../data/repositories/lote_repository.dart';
import '../data/repositories/recordatorios.dart';
import 'dialogos/dialogo_actividad.dart';
import 'formato.dart';
import 'tema.dart';
import 'widgets/comunes.dart';
import 'widgets/confirmacion_guardado.dart';
import 'widgets/selector_fecha.dart';

/// Cuánto cuesta producir un kilo en un lote, con lo que ya está anotado.
///
/// Va aparte del resto de Reportes y marcada como **beta** por una razón
/// concreta: el precio de venta no se guarda en ningún lado. Se escribe aquí,
/// se ve la cuenta, y se pierde al salir. Mientras la aplicación no tenga
/// dónde guardarlo, prometer que esto es un reporte sería mentir.
///
/// Lo demás sí sale de datos reales: los costos que el productor le anotó a
/// cada labor —que hasta ahora se guardaban y no se usaban para nada— y los
/// kilos de sus cosechas.
///
/// Abajo van esos gastos uno por uno, y desde ahí se agregan y se corrigen.
/// Se hace con el mismo formulario de labor de siempre y se guarda en la
/// misma tabla: un gasto anotado aquí es una labor del lote, aparece en el
/// historial y se sincroniza como cualquier otra. Esta pantalla es otra
/// puerta a lo mismo, no una contabilidad paralela —dos lugares donde anotar
/// gastos que no se hablan entre sí sería la forma más rápida de que los
/// números dejen de cuadrar.
class CostoPorKiloScreen extends StatefulWidget {
  const CostoPorKiloScreen({
    super.key,
    required this.repo,
    required this.lote,
    required this.nombreFinca,
  });

  final LoteRepository repo;
  final Lote lote;
  final String nombreFinca;

  @override
  State<CostoPorKiloScreen> createState() => _CostoPorKiloScreenState();
}

class _CostoPorKiloScreenState extends State<CostoPorKiloScreen> {
  final _precio = TextEditingController();

  late DateTime _desde = DateTime(DateTime.now().year);
  late DateTime _hasta = DateTime(DateTime.now().year, 12, 31);
  String? _producto;
  double? _precioPorKilo;

  @override
  void initState() {
    super.initState();
    // El campo avisa por su cuenta: CampoTarjeta no expone onChanged, y
    // agregárselo tocaría un widget que usan todos los formularios.
    _precio.addListener(_releerPrecio);
  }

  @override
  void dispose() {
    _precio
      ..removeListener(_releerPrecio)
      ..dispose();
    super.dispose();
  }

  void _releerPrecio() {
    final leido = aNumero(_precio.text);
    if (leido == _precioPorKilo) return;
    setState(() => _precioPorKilo = leido);
  }

  /// Anota un gasto sin salir de la cuenta.
  ///
  /// Abre el mismo formulario de labor de siempre, no uno recortado. Si fue
  /// una poda, ahí mismo puede llenar el tipo de poda y los árboles; si fue
  /// algo que la aplicación no tiene en la lista —transporte, un jornal,
  /// bolsas—, escoge "Otra labor" y le pone el nombre. En los dos casos
  /// queda guardado como una labor del lote, igual que si lo hubiera anotado
  /// desde el historial: esta pantalla no inventa una tabla aparte.
  Future<void> _agregarGasto() async {
    final datos = await pedirDatosActividad(
      context,
      loteNombre: widget.lote.nombre,
    );
    if (datos == null || !mounted) return;
    await guardarLabor(widget.repo, widget.lote, datos);
    if (!mounted) return;
    // Anotarlo con una fecha de fuera del período y no verlo aparecer haría
    // pensar que no se guardó.
    if (!enPeriodo(datos.fecha, _desde, _hasta)) {
      await _avisarFueraDelPeriodo(datos.fecha);
      return;
    }
    if (!mounted) return;
    await mostrarConfirmacionGuardado(context, mensaje: 'Gasto anotado');
  }

  /// Corrige un gasto ya anotado, con el formulario completo de esa labor.
  Future<void> _editarGasto(ActividadAgricola labor) async {
    if (plazoVencido(labor)) {
      await _explicarCerrada();
      return;
    }
    final datos = await pedirDatosActividad(
      context,
      inicial: datosDeLabor(labor),
      loteNombre: widget.lote.nombre,
    );
    if (datos == null || !mounted) return;
    final cambiadas = await actualizarLabor(widget.repo, labor, datos);
    if (!mounted) return;
    // La semana pudo vencerse entre que abrió el formulario y lo guardó.
    if (cambiadas == 0) {
      await _explicarCerrada();
      return;
    }
    await mostrarConfirmacionGuardado(context, mensaje: 'Gasto guardado');
  }

  Future<void> _explicarCerrada() {
    return showDialog<void>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Esta labor ya se cerró'),
        content: const Text(
          'Pasó la semana que hay para corregirla, y de ahí en adelante los '
          'datos quedan firmes. El administrador de la Red puede volver a '
          'habilitarla.',
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

  Future<void> _avisarFueraDelPeriodo(DateTime fecha) {
    return showDialog<void>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Quedó guardado, pero no se ve aquí'),
        content: Text(
          'Lo anotó con fecha ${fechaCorta(fecha)}, que está fuera del '
          'período que está mirando. Está guardado en el lote; para verlo en '
          'esta cuenta, cambie las fechas de arriba.',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cabeceraCacao(
        titulo: Row(
          children: [
            Flexible(
              child: Text(
                'Costo por kilo',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            const _SelloBeta(),
          ],
        ),
      ),
      body: FondoCacao(
        child: StreamBuilder<List<ActividadAgricola>>(
          stream: widget.repo.watchActividades(widget.lote.id),
          builder: (context, labores) {
            return StreamBuilder<List<Cosecha>>(
              stream: widget.repo.watchCosechas(widget.lote.id),
              builder: (context, cosechas) {
                if (labores.data == null || cosechas.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cuenta = calcularCostoPorKilo(
                  actividades: labores.data!,
                  cosechas: cosechas.data!,
                  desde: _desde,
                  hasta: _hasta,
                  producto: _producto,
                  precioPorKilo: _precioPorKilo,
                );
                // Los mismos que se sumaron, los más recientes primero.
                final gastos =
                    labores.data!
                        .where((l) => enPeriodo(l.fecha, _desde, _hasta))
                        .toList()
                      ..sort((a, b) => b.fecha.compareTo(a.fecha));
                return _Contenido(
                  cuenta: cuenta,
                  gastos: gastos,
                  lote: widget.lote,
                  nombreFinca: widget.nombreFinca,
                  desde: _desde,
                  hasta: _hasta,
                  controladorPrecio: _precio,
                  onDesde: (f) => setState(() => _desde = f),
                  onHasta: (f) => setState(() => _hasta = f),
                  onProducto: (p) => setState(() => _producto = p),
                  onAgregar: _agregarGasto,
                  onEditar: _editarGasto,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.cuenta,
    required this.gastos,
    required this.lote,
    required this.nombreFinca,
    required this.desde,
    required this.hasta,
    required this.controladorPrecio,
    required this.onDesde,
    required this.onHasta,
    required this.onProducto,
    required this.onAgregar,
    required this.onEditar,
  });

  final CuentaDelLote cuenta;

  /// Las labores del período, una por una, de la más reciente a la más vieja.
  final List<ActividadAgricola> gastos;
  final Lote lote;
  final String nombreFinca;
  final DateTime desde;
  final DateTime hasta;
  final TextEditingController controladorPrecio;
  final ValueChanged<DateTime> onDesde;
  final ValueChanged<DateTime> onHasta;
  final ValueChanged<String?> onProducto;
  final VoidCallback onAgregar;
  final ValueChanged<ActividadAgricola> onEditar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final costo = cuenta.costoPorKilo;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 48),
      children: [
        Text(
          '${lote.nombre} · $nombreFinca',
          style: textos.titleMedium,
        ),
        const SizedBox(height: 14),

        // ---- el período -----------------------------------------------
        Row(
          children: [
            Expanded(
              child: SelectorFecha(
                etiqueta: 'Desde',
                fecha: desde,
                onCambio: onDesde,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelectorFecha(
                etiqueta: 'Hasta',
                fecha: hasta,
                onCambio: onHasta,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ---- el resultado ---------------------------------------------
        _TarjetaResultado(cuenta: cuenta, costo: costo),
        const SizedBox(height: 16),

        if (cuenta.variosProductos) ...[
          _EscogerProducto(cuenta: cuenta, onProducto: onProducto),
          const SizedBox(height: 16),
        ],

        if (cuenta.laboresSinCosto > 0) ...[
          _AvisoCostosFaltantes(cuantas: cuenta.laboresSinCosto),
          const SizedBox(height: 16),
        ],

        // ---- el precio de venta ---------------------------------------
        CampoTarjeta(
          key: const Key('campo_precio_kilo'),
          etiqueta: 'Si vende el kilo a…',
          icono: Icons.sell_outlined,
          color: PaletaCacao.maduro,
          controller: controladorPrecio,
          hint: 'Ej: 12000',
          suffixText: r'$',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            'Este precio no se guarda. Es solo para ver la cuenta.',
            style: textos.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        if (cuenta.margenPorKilo != null) ...[
          const SizedBox(height: 18),
          _TarjetaGanancia(cuenta: cuenta),
        ],

        if (cuenta.costoPorLabor.isNotEmpty) ...[
          const SizedBox(height: 26),
          const TituloSeccion('En qué se fue la plata'),
          const SizedBox(height: 10),
          for (final entrada in _ordenadas(cuenta.costoPorLabor))
            _FilaGasto(
              tipo: entrada.key,
              valor: entrada.value,
              total: cuenta.costoTotal,
            ),
        ],

        // ---- los gastos, uno por uno, para corregir o agregar -----------
        const SizedBox(height: 26),
        const TituloSeccion('Gasto por gasto'),
        const SizedBox(height: 4),
        Text(
          'Estos son los mismos que suman arriba. Toque uno para corregirle '
          'el valor o terminar de llenarlo.',
          style: textos.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _BotonAgregarGasto(onTap: onAgregar),
        const SizedBox(height: 12),
        if (gastos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'No hay nada anotado en este período.',
              key: const Key('sin_gastos'),
              style: textos.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final gasto in gastos)
            _FilaGastoLabor(labor: gasto, onTap: () => onEditar(gasto)),

        const SizedBox(height: 26),
        const _NotaBeta(),
      ],
    );
  }

  List<MapEntry<TipoActividad, double>> _ordenadas(
    Map<TipoActividad, double> mapa,
  ) {
    return mapa.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }
}

// ---------------------------------------------------------------------------

class _TarjetaResultado extends StatelessWidget {
  const _TarjetaResultado({required this.cuenta, required this.costo});

  final CuentaDelLote cuenta;
  final double? costo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      color: PaletaCacao.cafeOscuro,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Producir un kilo le cuesta',
              style: textos.bodyMedium?.copyWith(color: PaletaCacao.cafeClaro),
            ),
            const SizedBox(height: 8),
            Text(
              costo == null ? 'Sin cosechas' : pesos(costo!),
              key: const Key('costo_por_kilo'),
              style: textos.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              costo == null
                  ? 'Anote una cosecha en este período y aquí sale la cuenta.'
                  : '${pesos(cuenta.costoTotal)} gastados · '
                        '${numeroCorto(cuenta.kilos)} kg de '
                        '${(cuenta.producto ?? '').toLowerCase()}',
              style: textos.bodyMedium?.copyWith(
                color: PaletaCacao.cafeClaro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaGanancia extends StatelessWidget {
  const _TarjetaGanancia({required this.cuenta});

  final CuentaDelLote cuenta;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final margen = cuenta.margenPorKilo!;
    final gana = margen >= 0;
    final color = gana ? PaletaCacao.verde : PaletaCacao.cafe;

    return Card(
      color: gana ? PaletaCacao.verdeClaro : PaletaCacao.maduroClaro,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gana ? 'Por cada kilo le quedan' : 'Por cada kilo pierde',
              style: textos.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              pesos(margen.abs()),
              key: const Key('margen_por_kilo'),
              style: textos.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 26),
            _Linea(
              etiqueta: 'Vendiendo los ${numeroCorto(cuenta.kilos)} kg',
              valor: pesos(cuenta.ventaEstimada!),
            ),
            const SizedBox(height: 6),
            _Linea(
              etiqueta: 'Menos lo que costó',
              valor: '− ${pesos(cuenta.costoTotal)}',
            ),
            const SizedBox(height: 10),
            _Linea(
              etiqueta: gana ? 'Le queda' : 'Le falta',
              valor: pesos(cuenta.utilidad!.abs()),
              fuerte: true,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  const _Linea({
    required this.etiqueta,
    required this.valor,
    this.fuerte = false,
    this.color,
  });

  final String etiqueta;
  final String valor;
  final bool fuerte;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final estilo = fuerte
        ? textos.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          )
        : textos.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(etiqueta, style: estilo)),
        Text(valor, style: estilo),
      ],
    );
  }
}

class _EscogerProducto extends StatelessWidget {
  const _EscogerProducto({required this.cuenta, required this.onProducto});

  final CuentaDelLote cuenta;
  final ValueChanged<String?> onProducto;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cosechó más de un tipo de cacao',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Un kilo de baba no es un kilo de seco, así que no se suman. '
              'Escoja cuál quiere costear.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entrada in cuenta.kilosPorProducto.entries)
                  ChoiceChip(
                    label: Text(
                      '${entrada.key} · ${numeroCorto(entrada.value)} kg',
                    ),
                    selected: cuenta.producto == entrada.key,
                    onSelected: (_) => onProducto(entrada.key),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoCostosFaltantes extends StatelessWidget {
  const _AvisoCostosFaltantes({required this.cuantas});

  final int cuantas;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: PaletaCacao.maduroClaro,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: PaletaCacao.maduro),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                cuantas == 1
                    ? 'Hay 1 labor del período sin costo anotado, así que este '
                          'número va por debajo de lo que de verdad le costó.'
                    : 'Hay $cuantas labores del período sin costo anotado, así '
                          'que este número va por debajo de lo que de verdad '
                          'le costó.',
                key: const Key('aviso_costos_faltantes'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaGasto extends StatelessWidget {
  const _FilaGasto({
    required this.tipo,
    required this.valor,
    required this.total,
  });

  final TipoActividad tipo;
  final double valor;
  final double total;

  @override
  Widget build(BuildContext context) {
    final parte = total <= 0 ? 0.0 : valor / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  etiquetaActividad(tipo),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                pesos(valor),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: parte,
              minHeight: 8,
              backgroundColor: PaletaCacao.profundoOscuro,
              color: PaletaCacao.maduro,
            ),
          ),
        ],
      ),
    );
  }
}

/// Anotar un gasto desde aquí, sin tener que irse al historial del lote.
class _BotonAgregarGasto extends StatelessWidget {
  const _BotonAgregarGasto({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('agregar_gasto'),
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: PaletaCacao.cafeOscuro,
      ),
      icon: const Icon(Icons.add),
      label: const Text('Agregar un gasto'),
    );
  }
}

/// Un gasto del período: qué fue, cuándo y cuánto.
///
/// Se toca para corregirlo, y se abre el formulario completo de esa labor —no
/// un campo suelto de valor—, porque corregir el costo de una poda y terminar
/// de llenarle el tipo de poda son la misma visita al mismo registro.
///
/// Pasada la semana la labor queda cerrada: la fila lo dice con un candado en
/// vez de dejar que la persona abra el formulario, escriba y después se
/// entere de que no se guardó.
class _FilaGastoLabor extends StatelessWidget {
  const _FilaGastoLabor({required this.labor, required this.onTap});

  final ActividadAgricola labor;
  final VoidCallback onTap;

  /// "Otra labor" a secas no le dice nada a nadie: para esas vale el nombre
  /// que el productor escribió.
  String get _nombre {
    if (labor.tipoActividad == TipoActividad.otro) {
      final escrito = labor.observaciones?.trim();
      if (escrito != null && escrito.isNotEmpty) return escrito;
    }
    final base = etiquetaActividad(labor.tipoActividad);
    final subtipo = labor.subtipoLabor;
    return subtipo == null || subtipo.isEmpty ? base : '$base · $subtipo';
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cerrada = plazoVencido(labor);
    final costo = labor.costo;
    final sinCosto = costo == null || costo <= 0;

    return Card(
      key: Key('gasto_${labor.id}'),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: PaletaCacao.verdeClaro,
                child: Icon(
                  iconoActividad(labor.tipoActividad),
                  size: 20,
                  color: PaletaCacao.verdeOscuro,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nombre,
                      style: textos.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (cerrada) ...[
                          const Icon(
                            Icons.lock_outline,
                            size: 13,
                            color: PaletaCacao.cafe,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          cerrada
                              ? '${fechaCorta(labor.fecha)} · cerrada'
                              : fechaCorta(labor.fecha),
                          style: textos.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                sinCosto ? 'Sin costo' : pesos(costo),
                style: textos.bodyLarge?.copyWith(
                  fontWeight: sinCosto ? FontWeight.w400 : FontWeight.w600,
                  color: sinCosto ? PaletaCacao.maduro : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelloBeta extends StatelessWidget {
  const _SelloBeta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: PaletaCacao.maduro,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'BETA',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _NotaBeta extends StatelessWidget {
  const _NotaBeta();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _SelloBeta(),
                const SizedBox(width: 10),
                Text(
                  'Esto está en prueba',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'El costo sale de lo que usted le anotó a cada labor, y los '
              'kilos de sus cosechas: eso sí está guardado, y lo que agregue '
              'o corrija aquí abajo queda guardado igual que si lo anotara '
              'en el lote. Lo que no se guarda todavía es el precio de '
              'venta, así que esta cuenta no queda en el historial ni se '
              'puede descargar. Si le sirve, avísele al instructor para '
              'terminarla.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
