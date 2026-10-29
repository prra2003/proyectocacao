import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/local/enums.dart';
import '../data/repositories/costo_por_kilo.dart';
import '../data/repositories/lote_repository.dart';
import '../data/repositories/recordatorios.dart';
import 'asistente_costo_screen.dart';
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

  /// El productor dijo que ya no falta ningún gasto por anotar.
  ///
  /// Vive en la pantalla y no en la base porque es una afirmación sobre un
  /// período y un lote que se está mirando ahora, no un dato del lote. Se
  /// vuelve a preguntar cada vez, y eso está bien: con un gasto nuevo la
  /// respuesta de la semana pasada ya no vale.
  var _confirmado = false;

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
    final leido = aPesos(_precio.text);
    if (leido == _precioPorKilo) return;
    setState(() => _precioPorKilo = leido);
  }

  /// Abre el asistente, que pregunta una cosa a la vez.
  ///
  /// Al volver, esta pantalla adopta el período, el producto y la
  /// confirmación que él escogió: si se quedara con los suyos, el productor
  /// vería dos números distintos para la misma pregunta y no tendría forma de
  /// saber cuál creer.
  Future<void> _abrirAsistente() async {
    final escogido = await Navigator.of(context).push<CuentaEscogida>(
      MaterialPageRoute(
        builder: (_) =>
            AsistenteCostoScreen(repo: widget.repo, lote: widget.lote),
      ),
    );
    if (escogido == null || !mounted) return;
    setState(() {
      _desde = escogido.desde;
      _hasta = escogido.hasta;
      _producto = escogido.producto;
      _confirmado = escogido.confirmado;
    });
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
    final reparto = await repartoDelGasto(widget.repo, widget.lote);
    if (!mounted) return;
    final datos = await pedirDatosActividad(
      context,
      loteNombre: widget.lote.nombre,
      reparto: reparto,
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
    final reparto = await repartoDelGasto(widget.repo, widget.lote);
    if (!mounted) return;
    final datos = await pedirDatosActividad(
      context,
      inicial: datosDeLabor(labor),
      loteNombre: widget.lote.nombre,
      reparto: reparto,
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
                  confirmada: _confirmado,
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
                  onDesde: (f) => setState(() {
                    _desde = f;
                    // Otro período, otros gastos: lo que confirmó para el
                    // anterior no dice nada de este.
                    _confirmado = false;
                  }),
                  onHasta: (f) => setState(() {
                    _hasta = f;
                    _confirmado = false;
                  }),
                  onProducto: (p) => setState(() => _producto = p),
                  onAgregar: _agregarGasto,
                  onEditar: _editarGasto,
                  onConfirmar: (v) => setState(() => _confirmado = v),
                  onAsistente: _abrirAsistente,
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
    required this.onConfirmar,
    required this.onAsistente,
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
  final ValueChanged<bool> onConfirmar;
  final VoidCallback onAsistente;

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
        const SizedBox(height: 16),

        // ---- la puerta fácil, antes que nada --------------------------
        _BotonAsistente(onTap: onAsistente),
        const SizedBox(height: 20),

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

        // Ya no se puede confirmar nada si falta algo: el estado de arriba
        // lo dice y nombra qué es.
        if (cuenta.calculable) ...[
          _ConfirmarCompleto(
            confirmada: cuenta.confirmada,
            onConfirmar: onConfirmar,
          ),
          const SizedBox(height: 16),
        ],

        // ---- el precio de venta ---------------------------------------
        CampoTarjeta(
          key: const Key('campo_precio_kilo'),
          etiqueta: 'Si vende el kilo a…',
          icono: Icons.sell_outlined,
          color: PaletaCacao.maduro,
          controller: controladorPrecio,
          hint: 'Ej: 12.000',
          suffixText: r'$',
          keyboardType: TextInputType.number,
          inputFormatters: const [FiltroPesos()],
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

        // Sin un costo confiable, el margen tampoco lo es: restarle a un
        // gasto incompleto da una ganancia inflada, que es peor que ninguna.
        if (cuenta.calculable && cuenta.margenPorKilo != null) ...[
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

/// El número grande, o la razón por la que todavía no hay número.
///
/// Mientras falte algo obligatorio —kilos cosechados, o el costo de alguna
/// labor— aquí dice **Pendiente** y debajo qué es lo que falta. Antes
/// mostraba `$0`, que no es un costo bajo: es la cuenta diciendo que no sabe
/// y aparentando que sí.
class _TarjetaResultado extends StatelessWidget {
  const _TarjetaResultado({required this.cuenta, required this.costo});

  final CuentaDelLote cuenta;
  final double? costo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final faltantes = cuenta.faltantes;
    final hayNumero = cuenta.calculable && costo != null;

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
              hayNumero ? pesos(costo!) : 'Pendiente',
              key: const Key('costo_por_kilo'),
              style: textos.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (!hayNumero) ...[
              Text(
                'Falta esto para poder dar el número:',
                key: const Key('falta_para_el_numero'),
                style: textos.bodyMedium?.copyWith(
                  color: PaletaCacao.cafeClaro,
                ),
              ),
              const SizedBox(height: 8),
              for (final falta in faltantes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(
                          Icons.radio_button_unchecked,
                          size: 13,
                          color: PaletaCacao.cafeClaro,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          falta,
                          style: textos.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ] else ...[
              Text(
                '${pesos(cuenta.costoTotal)} gastados · '
                '${numeroCorto(cuenta.kilos)} kg de '
                '${(cuenta.producto ?? '').toLowerCase()}',
                style: textos.bodyMedium?.copyWith(
                  color: PaletaCacao.cafeClaro,
                ),
              ),
              const SizedBox(height: 14),
              _Sello(estado: cuenta.estado),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dice si el número es definitivo o provisional, sin esconderlo.
class _Sello extends StatelessWidget {
  const _Sello({required this.estado});

  final EstadoCuenta estado;

  @override
  Widget build(BuildContext context) {
    final confirmada = estado == EstadoCuenta.confirmada;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: confirmada ? PaletaCacao.verde : PaletaCacao.maduro,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        confirmada ? '✓ Gastos confirmados' : 'Provisional',
        key: const Key('sello_estado'),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
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

/// La única pregunta que la aplicación no puede responder sola.
///
/// La cuenta ve los gastos anotados; no ve los que nunca se anotaron. El más
/// grande de esos suele ser el trabajo propio y el de la familia, que no se
/// paga en efectivo y por eso no se apunta —y es el que decide si el lote
/// deja plata o solo lo parece.
///
/// Mientras no esté marcado, el número sale rotulado "Provisional". Nada se
/// esconde: se dice con qué reserva está dado.
class _ConfirmarCompleto extends StatelessWidget {
  const _ConfirmarCompleto({
    required this.confirmada,
    required this.onConfirmar,
  });

  final bool confirmada;
  final ValueChanged<bool> onConfirmar;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: confirmada
          ? PaletaCacao.verdeClaro
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onConfirmar(!confirmada),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                key: const Key('confirmar_gastos_completos'),
                value: confirmada,
                onChanged: (v) => onConfirmar(v ?? false),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 11),
                  child: Text(
                    'Ya están anotados todos los gastos de este lote y este '
                    'período, incluidos mis jornales y los de la familia.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
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

/// La entrada al asistente: grande, primero, y sin jerga.
///
/// Es lo primero que se ve porque para quien nunca ha sacado esta cuenta el
/// resto de la pantalla —fechas, tipo de producto, precio, la lista de
/// gastos— es una pared. Esto no pregunta nada todavía: solo ofrece hacerlo
/// despacio.
class _BotonAsistente extends StatelessWidget {
  const _BotonAsistente({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      key: const Key('abrir_asistente'),
      elevation: 3,
      color: PaletaCacao.verde,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Cuánto le cuesta su kilo?',
                      style: textos.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Le hago unas preguntas, una por una, y le digo.',
                      style: textos.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
            ],
          ),
        ),
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
    final compartido = labor.costoTotalCompartido;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sinCosto ? 'Sin costo' : pesos(costo),
                    style: textos.bodyLarge?.copyWith(
                      fontWeight: sinCosto ? FontWeight.w400 : FontWeight.w600,
                      color: sinCosto ? PaletaCacao.maduro : null,
                    ),
                  ),
                  // Lo que se ve es la parte del lote, no lo que pagó: sin
                  // decirlo, parecería que el valor quedó mal anotado.
                  if (compartido != null)
                    Text(
                      'parte de ${pesos(compartido)}',
                      style: textos.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
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
