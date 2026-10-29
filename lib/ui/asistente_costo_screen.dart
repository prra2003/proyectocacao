import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/local/enums.dart';
import '../data/repositories/costo_por_kilo.dart';
import '../data/repositories/lote_repository.dart';
import '../data/repositories/recordatorios.dart';
import 'dialogos/dialogo_actividad.dart';
import 'dialogos/dialogo_cosecha.dart';
import 'formato.dart';
import 'tema.dart';
import 'widgets/comunes.dart';

/// Lo que el asistente dejó escogido, para que la pantalla de detalle quede
/// mirando exactamente la misma cuenta.
///
/// Si al salir del asistente el detalle siguiera con su propio período, el
/// productor vería dos números distintos para la misma pregunta y no tendría
/// forma de saber cuál creer.
typedef CuentaEscogida = ({
  DateTime desde,
  DateTime hasta,
  String? producto,
  bool confirmado,
});

/// Los gastos por los que se pregunta, en el orden en que uno los recuerda.
///
/// La siembra no está: no es un gasto de esta cosecha, es lo que costó
/// levantar el lote, y repartirlo entre una cosecha sería otra cuenta.
const _gastosQueSePreguntan = [
  TipoActividad.poda,
  TipoActividad.fertilizacion,
  TipoActividad.controlFitosanitario,
  TipoActividad.riego,
  TipoActividad.otro,
];

/// La pregunta de cada gasto, como se dice en el campo.
String _preguntaDe(TipoActividad tipo) => switch (tipo) {
  TipoActividad.poda => '¿Pagó por podar este lote?',
  TipoActividad.fertilizacion => '¿Abonó este lote?',
  TipoActividad.controlFitosanitario => '¿Fumigó o curó alguna enfermedad?',
  TipoActividad.riego => '¿Pagó por regar?',
  TipoActividad.otro => '¿Hubo otros gastos?',
  TipoActividad.siembra => '¿Sembró?',
};

String _pistaDe(TipoActividad tipo) => switch (tipo) {
  TipoActividad.poda => 'Jornales de poda, machete, tijeras.',
  TipoActividad.fertilizacion => 'Los bultos de abono y el jornal de echarlo.',
  TipoActividad.controlFitosanitario =>
    'El producto que compró y el jornal de aplicarlo.',
  TipoActividad.riego => 'Mangueras, bombeo, el jornal de regar.',
  TipoActividad.otro =>
    'Transporte del bulto, jornales de cosecha, bolsas, arriendo, '
        'herramienta. Todo lo que pagó y no cabe arriba.',
  TipoActividad.siembra => '',
};

/// Le pregunta una cosa a la vez hasta poder decirle cuánto le cuesta el kilo.
///
/// La pantalla de detalle le pone todo al frente de una vez —fechas, tipo de
/// producto, precio, la lista de gastos— y da por hecho que ya sabe qué es un
/// costo por kilo. Para quien nunca ha sacado esa cuenta eso es una pared.
/// Aquí es una pregunta por pantalla, con letra grande y dos botones, y en
/// cada paso se le muestra lo que ya tiene anotado para que no lo anote dos
/// veces.
///
/// No anota nada por su cuenta ni en una tabla aparte: cuando hay que anotar
/// un gasto abre el mismo formulario de labor de siempre, con el tipo ya
/// escogido. Es la misma puerta, más despacio.
class AsistenteCostoScreen extends StatefulWidget {
  const AsistenteCostoScreen({
    super.key,
    required this.repo,
    required this.lote,
  });

  final LoteRepository repo;
  final Lote lote;

  @override
  State<AsistenteCostoScreen> createState() => _AsistenteCostoScreenState();
}

class _AsistenteCostoScreenState extends State<AsistenteCostoScreen> {
  /// 0 = la cosecha, 1 = desde cuándo, 2..6 = un gasto cada uno,
  /// 7 = el trabajo propio, 8 = el resultado.
  var _paso = 0;

  Cosecha? _cosecha;
  DateTime? _desde;
  var _confirmado = false;

  static final _ultimo = 3 + _gastosQueSePreguntan.length;

  DateTime get _hasta => _cosecha!.fecha;

  void _avanzar() => setState(() => _paso++);
  void _retroceder() => setState(() => _paso--);

  /// Anota un gasto del tipo que se está preguntando.
  ///
  /// Abre el formulario completo, no uno recortado: si fue una poda, ahí
  /// mismo llena el tipo de poda y los árboles. Y si el gasto fue de toda la
  /// finca, el formulario le pregunta cómo repartirlo.
  Future<void> _anotarGasto(TipoActividad tipo) async {
    final reparto = await repartoDelGasto(widget.repo, widget.lote);
    if (!mounted) return;
    final datos = await pedirDatosActividad(
      context,
      tipoInicial: tipo,
      loteNombre: widget.lote.nombre,
      reparto: reparto,
    );
    if (datos == null) return;
    await guardarLabor(widget.repo, widget.lote, datos);
  }

  Future<void> _corregirGasto(ActividadAgricola labor) async {
    if (plazoVencido(labor)) {
      await _avisarCerrada();
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
    if (datos == null) return;
    final cambiadas = await actualizarLabor(widget.repo, labor, datos);
    if (cambiadas == 0 && mounted) await _avisarCerrada();
  }

  Future<void> _anotarCosecha() async {
    final datos = await pedirDatosCosecha(context);
    if (datos == null) return;
    await widget.repo.registrarCosecha(
      loteId: widget.lote.id,
      fecha: datos.fecha,
      cantidadKg: datos.cantidadKg,
      observaciones: datos.observaciones,
      tipoProducto: datos.tipoProducto,
    );
  }

  Future<void> _avisarCerrada() {
    return showDialog<void>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Esta labor ya se cerró'),
        content: const Text(
          'Pasó la semana que hay para corregirla. El administrador de la Red '
          'puede volver a habilitarla.',
        ),
        actions: [
          FilledButton(
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
        titulo: const Text('Su costo por kilo'),
        abajo: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_paso + 1) / (_ultimo + 1),
            minHeight: 4,
            backgroundColor: Colors.white24,
            color: PaletaCacao.maduro,
          ),
        ),
      ),
      body: FondoCacao(
        child: StreamBuilder<List<Cosecha>>(
          stream: widget.repo.watchCosechas(widget.lote.id),
          builder: (context, cosechas) {
            return StreamBuilder<List<ActividadAgricola>>(
              stream: widget.repo.watchActividades(widget.lote.id),
              builder: (context, labores) {
                if (cosechas.data == null || labores.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _pagina(cosechas.data!, labores.data!);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _pagina(List<Cosecha> cosechas, List<ActividadAgricola> labores) {
    if (_paso == 0) {
      return _PasoCosecha(
        cosechas: cosechas,
        escogida: _cosecha,
        onEscoger: (c) {
          setState(() {
            _cosecha = c;
            // Lo más común: lo que se gastó en el año de la cosecha.
            _desde ??= DateTime(c.fecha.year);
          });
          _avanzar();
        },
        onAnotarCosecha: _anotarCosecha,
      );
    }
    if (_paso == 1) {
      return _PasoDesde(
        cosecha: _cosecha!,
        desde: _desde!,
        onDesde: (f) => setState(() => _desde = f),
        onSeguir: _avanzar,
        onAtras: _retroceder,
      );
    }
    if (_paso <= 1 + _gastosQueSePreguntan.length) {
      final tipo = _gastosQueSePreguntan[_paso - 2];
      final deEsteTipo =
          labores
              .where((l) => l.tipoActividad == tipo)
              .where((l) => enPeriodo(l.fecha, _desde!, _hasta))
              .toList()
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
      return _PasoGasto(
        tipo: tipo,
        numero: _paso - 1,
        deCuantos: _gastosQueSePreguntan.length,
        anotados: deEsteTipo,
        onAnotar: () => _anotarGasto(tipo),
        onCorregir: _corregirGasto,
        onSeguir: _avanzar,
        onAtras: _retroceder,
      );
    }
    if (_paso == 2 + _gastosQueSePreguntan.length) {
      return _PasoTrabajoPropio(
        onAnotar: () => _anotarGasto(TipoActividad.otro),
        onConfirmar: () {
          setState(() => _confirmado = true);
          _avanzar();
        },
        onSinConfirmar: _avanzar,
        onAtras: _retroceder,
      );
    }
    final cuenta = calcularCostoPorKilo(
      actividades: labores,
      cosechas: cosechas,
      desde: _desde!,
      hasta: _hasta,
      producto: _cosecha!.tipoProducto,
      confirmada: _confirmado,
    );
    return _PasoResultado(
      cuenta: cuenta,
      cosecha: _cosecha!,
      desde: _desde!,
      onAtras: _retroceder,
      onVerDetalle: () => Navigator.of(context).pop((
        desde: _desde!,
        hasta: _hasta,
        producto: _cosecha!.tipoProducto,
        confirmado: _confirmado,
      )),
    );
  }
}

// ---------------------------------------------------------------- pasos ----

/// El armazón de cada paso: la pregunta arriba, el contenido, y los botones
/// siempre en el mismo sitio para que la mano aprenda dónde están.
class _Paso extends StatelessWidget {
  const _Paso({
    required this.pregunta,
    this.pista,
    required this.cuerpo,
    required this.botones,
    this.onAtras,
  });

  final String pregunta;
  final String? pista;
  final List<Widget> cuerpo;
  final List<Widget> botones;
  final VoidCallback? onAtras;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            children: [
              Text(
                pregunta,
                style: textos.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (pista != null) ...[
                const SizedBox(height: 8),
                Text(
                  pista!,
                  style: textos.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              ...cuerpo,
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
          color: PaletaCacao.cafeOscuro.withValues(alpha: 0.06),
          child: Row(
            children: [
              if (onAtras != null) ...[
                IconButton(
                  key: const Key('asistente_atras'),
                  onPressed: onAtras,
                  iconSize: 28,
                  tooltip: 'Atrás',
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 6),
              ],
              for (final boton in botones) ...[
                Expanded(child: boton),
                const SizedBox(width: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PasoCosecha extends StatelessWidget {
  const _PasoCosecha({
    required this.cosechas,
    required this.escogida,
    required this.onEscoger,
    required this.onAnotarCosecha,
  });

  final List<Cosecha> cosechas;
  final Cosecha? escogida;
  final ValueChanged<Cosecha> onEscoger;
  final Future<void> Function() onAnotarCosecha;

  @override
  Widget build(BuildContext context) {
    if (cosechas.isEmpty) {
      return _Paso(
        pregunta: 'Primero hay que anotar la cosecha',
        pista: 'El costo por kilo son los gastos divididos entre los kilos '
            'que recogió. Sin los kilos no hay entre qué dividir.',
        cuerpo: const [],
        botones: [
          FilledButton.icon(
            key: const Key('asistente_anotar_cosecha'),
            onPressed: onAnotarCosecha,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Anotar la cosecha'),
          ),
        ],
      );
    }

    return _Paso(
      pregunta: '¿De cuál cosecha quiere saber?',
      pista: 'Toque la que quiere costear. Son las que usted ya anotó.',
      cuerpo: [
        for (final cosecha in cosechas)
          Card(
            key: Key('cosecha_${cosecha.id}'),
            margin: const EdgeInsets.only(bottom: 12),
            color: escogida?.id == cosecha.id ? PaletaCacao.verdeClaro : null,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onEscoger(cosecha),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${numeroCorto(cosecha.cantidadKg)} kg',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${fechaLarga(cosecha.fecha)}'
                            '${cosecha.tipoProducto == null ? '' : ' · ${cosecha.tipoProducto}'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: onAnotarCosecha,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Anotar otra cosecha'),
        ),
      ],
      botones: const [],
    );
  }
}

class _PasoDesde extends StatelessWidget {
  const _PasoDesde({
    required this.cosecha,
    required this.desde,
    required this.onDesde,
    required this.onSeguir,
    required this.onAtras,
  });

  final Cosecha cosecha;
  final DateTime desde;
  final ValueChanged<DateTime> onDesde;
  final VoidCallback onSeguir;
  final VoidCallback onAtras;

  /// Las tres respuestas que cubren casi todos los casos, para no hacerle
  /// abrir un calendario.
  List<({String texto, DateTime fecha})> _opciones() {
    final fin = cosecha.fecha;
    return [
      (texto: 'Desde principio de año', fecha: DateTime(fin.year)),
      (
        texto: 'Los últimos 6 meses',
        fecha: DateTime(fin.year, fin.month - 6, fin.day),
      ),
      (
        texto: 'Los últimos 3 meses',
        fecha: DateTime(fin.year, fin.month - 3, fin.day),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _Paso(
      pregunta: '¿Desde cuándo trabajó para esa cosecha?',
      pista: 'Los gastos de ese tiempo son los que entran en la cuenta. Si no '
          'está seguro, deje la primera: es la más común.',
      cuerpo: [
        for (final opcion in _opciones())
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: _mismoDia(opcion.fecha, desde)
                ? PaletaCacao.verdeClaro
                : null,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onDesde(opcion.fecha),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opcion.texto,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Desde el ${fechaCorta(opcion.fecha)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (_mismoDia(opcion.fecha, desde))
                      const Icon(Icons.check_circle, color: PaletaCacao.verde),
                  ],
                ),
              ),
            ),
          ),
      ],
      botones: [_BotonSeguir(onTap: onSeguir)],
      onAtras: onAtras,
    );
  }

  static bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _PasoGasto extends StatelessWidget {
  const _PasoGasto({
    required this.tipo,
    required this.numero,
    required this.deCuantos,
    required this.anotados,
    required this.onAnotar,
    required this.onCorregir,
    required this.onSeguir,
    required this.onAtras,
  });

  final TipoActividad tipo;
  final int numero;
  final int deCuantos;
  final List<ActividadAgricola> anotados;
  final Future<void> Function() onAnotar;
  final Future<void> Function(ActividadAgricola) onCorregir;
  final VoidCallback onSeguir;
  final VoidCallback onAtras;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final sinCosto = anotados
        .where((l) => l.costo == null || l.costo! <= 0)
        .length;

    return _Paso(
      pregunta: _preguntaDe(tipo),
      pista: _pistaDe(tipo),
      onAtras: onAtras,
      cuerpo: [
        Text(
          'Gasto $numero de $deCuantos',
          style: textos.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        if (anotados.isEmpty)
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'Todavía no tiene nada anotado de esto en ese tiempo.',
                key: const Key('nada_de_este_tipo'),
                style: textos.bodyMedium,
              ),
            ),
          )
        else ...[
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 18,
                color: PaletaCacao.verde,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  anotados.length == 1
                      ? 'Ya tiene 1 anotado:'
                      : 'Ya tiene ${anotados.length} anotados:',
                  key: const Key('ya_tiene_anotados'),
                  style: textos.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final labor in anotados)
            _FilaAnotada(labor: labor, onTap: () => onCorregir(labor)),
          if (sinCosto > 0) ...[
            const SizedBox(height: 6),
            Text(
              sinCosto == 1
                  ? 'Al que dice "Sin costo" le falta el valor. Tóquelo para '
                        'ponérselo: sin él, la cuenta va a salir por debajo.'
                  : 'A los que dicen "Sin costo" les falta el valor. '
                        'Tóquelos para ponérselo: sin ellos, la cuenta va a '
                        'salir por debajo.',
              style: textos.bodySmall?.copyWith(color: PaletaCacao.maduro),
            ),
          ],
        ],
      ],
      botones: [
        OutlinedButton.icon(
          key: const Key('asistente_anotar_gasto'),
          onPressed: onAnotar,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            foregroundColor: PaletaCacao.cafeOscuro,
          ),
          icon: const Icon(Icons.add),
          label: Text(anotados.isEmpty ? 'Sí, anotar' : 'Anotar otro'),
        ),
        _BotonSeguir(onTap: onSeguir, texto: anotados.isEmpty ? 'No' : 'Seguir'),
      ],
    );
  }
}

class _FilaAnotada extends StatelessWidget {
  const _FilaAnotada({required this.labor, required this.onTap});

  final ActividadAgricola labor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final costo = labor.costo;
    final sinCosto = costo == null || costo <= 0;
    final compartido = labor.costoTotalCompartido;
    final cerrada = plazoVencido(labor);

    return Card(
      key: Key('anotado_${labor.id}'),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Icon(iconoActividad(labor.tipoActividad), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cerrada
                      ? '${fechaCorta(labor.fecha)} · cerrada'
                      : fechaCorta(labor.fecha),
                  style: textos.bodyMedium,
                ),
              ),
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

/// El gasto que no deja recibo y por eso nunca se anota.
///
/// Es la pregunta que decide si el lote deja plata o solo lo parece, y la
/// única que la aplicación no puede contestar sola: ve lo que se anotó, no lo
/// que se dejó de anotar.
class _PasoTrabajoPropio extends StatelessWidget {
  const _PasoTrabajoPropio({
    required this.onAnotar,
    required this.onConfirmar,
    required this.onSinConfirmar,
    required this.onAtras,
  });

  final Future<void> Function() onAnotar;
  final VoidCallback onConfirmar;
  final VoidCallback onSinConfirmar;
  final VoidCallback onAtras;

  @override
  Widget build(BuildContext context) {
    return _Paso(
      pregunta: '¿Trabajó usted o su familia sin cobrar?',
      pista: 'Ese trabajo vale, aunque no se haya pagado en efectivo: si no '
          'lo cuenta, su kilo le va a parecer más barato de lo que es. '
          'Cuéntelo como lo que le habría tocado pagarle a un jornalero.',
      onAtras: onAtras,
      cuerpo: [
        OutlinedButton.icon(
          key: const Key('asistente_anotar_jornal_propio'),
          onPressed: onAnotar,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            foregroundColor: PaletaCacao.cafeOscuro,
          ),
          icon: const Icon(Icons.add),
          label: const Text('Sí, falta anotarlo'),
        ),
        const SizedBox(height: 10),
        Text(
          'Se anota como otro gasto, poniéndole el nombre: "mis jornales", '
          '"jornales de mi hijo".',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
      botones: [
        OutlinedButton(
          key: const Key('asistente_sin_confirmar'),
          onPressed: onSinConfirmar,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
          ),
          child: const Text('No estoy seguro'),
        ),
        FilledButton(
          key: const Key('asistente_confirmar'),
          onPressed: onConfirmar,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
          ),
          child: const Text('Ya está todo'),
        ),
      ],
    );
  }
}

class _PasoResultado extends StatelessWidget {
  const _PasoResultado({
    required this.cuenta,
    required this.cosecha,
    required this.desde,
    required this.onAtras,
    required this.onVerDetalle,
  });

  final CuentaDelLote cuenta;
  final Cosecha cosecha;
  final DateTime desde;
  final VoidCallback onAtras;
  final VoidCallback onVerDetalle;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final costo = cuenta.costoPorKilo;
    final hayNumero = cuenta.calculable && costo != null;

    return _Paso(
      pregunta: hayNumero
          ? 'Producir un kilo le cuesta'
          : 'Todavía falta un dato',
      onAtras: onAtras,
      cuerpo: [
        if (hayNumero) ...[
          Text(
            pesos(costo),
            key: const Key('asistente_resultado'),
            style: textos.displayMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: PaletaCacao.cafeOscuro,
            ),
          ),
          const SizedBox(height: 18),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Así salió la cuenta', style: textos.titleSmall),
                  const SizedBox(height: 10),
                  Text(
                    '${pesos(cuenta.costoTotal)} gastados desde el '
                    '${fechaCorta(desde)}\n'
                    '÷ ${numeroCorto(cuenta.kilos)} kg de la cosecha del '
                    '${fechaCorta(cosecha.fecha)}\n'
                    '= ${pesos(costo)} cada kilo',
                    style: textos.bodyLarge,
                  ),
                  if (!cuenta.confirmada) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Es provisional: no confirmó que estuvieran anotados '
                      'todos los gastos.',
                      style: textos.bodySmall?.copyWith(
                        color: PaletaCacao.maduro,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ] else ...[
          for (final falta in cuenta.faltantes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.radio_button_unchecked,
                      size: 14,
                      color: PaletaCacao.maduro,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(falta, style: textos.bodyLarge)),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text(
            'Devuélvase con la flecha y póngale el valor al gasto que lo '
            'tiene en blanco.',
            style: textos.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
      botones: [
        FilledButton(
          key: const Key('asistente_ver_detalle'),
          onPressed: onVerDetalle,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
          child: const Text('Ver el detalle'),
        ),
      ],
    );
  }
}

class _BotonSeguir extends StatelessWidget {
  const _BotonSeguir({required this.onTap, this.texto = 'Seguir'});

  final VoidCallback onTap;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const Key('asistente_seguir'),
      onPressed: onTap,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
      child: Text(texto),
    );
  }
}
