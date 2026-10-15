import 'package:flutter/material.dart';

import '../tema.dart';

/// Nota plegada que explica por qué lo que se está anotando cuenta como una
/// Buena Práctica Agrícola, y para qué le sirve al productor.
///
/// Va plegada a propósito. El que anota a diario no necesita leerla cada vez;
/// el que se está preguntando "¿y esto para qué?" la abre y ahí está. Si
/// estuviera abierta, en dos días sería ruido que todo el mundo salta.
///
/// **Lo que esto NO es.** No es una lista de verificación ni dice que el
/// productor cumpla. Quien certifica en BPA es el ICA, con una visita. Esto
/// solo le explica para qué sirve lo que está anotando y qué pide la norma,
/// que es la [Resolución ICA 30021 de 2017]. Por eso cada nota cierra con el
/// mismo recordatorio: orienta, no certifica.
///
/// Esa distinción no es un tecnicismo. Una aplicación que le diga a alguien
/// "usted cumple" y después le llegue el ICA y le diga que no, hace más daño
/// que no haber dicho nada.
class NotaBpa extends StatefulWidget {
  const NotaBpa({
    super.key,
    required this.titulo,
    required this.puntos,
    this.ojo,
  });

  /// De qué habla la nota, en una línea.
  final String titulo;

  /// Las razones, una por renglón. Cortas: esto se lee en un celular, de pie.
  final List<String> puntos;

  /// Una advertencia, cuando la hay. Se usa sobre todo para avisar que el ICA
  /// pide datos que la aplicación todavía no tiene campo para guardar.
  final String? ojo;

  @override
  State<NotaBpa> createState() => _NotaBpaState();
}

class _NotaBpaState extends State<NotaBpa> {
  var _abierta = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PaletaCacao.verdeClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const Key('nota_bpa_abrir'),
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _abierta = !_abierta),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  const _Sello(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.titulo,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: PaletaCacao.verdeOscuro,
                      ),
                    ),
                  ),
                  Icon(
                    _abierta ? Icons.expand_less : Icons.expand_more,
                    color: PaletaCacao.verdeOscuro,
                  ),
                ],
              ),
            ),
          ),
          if (_abierta)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final punto in widget.puntos)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 7, right: 9),
                            child: _Punto(),
                          ),
                          Expanded(
                            child: Text(
                              punto,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                color: PaletaCacao.verdeOscuro,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.ojo != null) ...[
                    const SizedBox(height: 3),
                    _Ojo(texto: widget.ojo!),
                  ],
                  const SizedBox(height: 10),
                  const Text(
                    'Esto le orienta; no lo certifica. Quien certifica en BPA '
                    'es el ICA, con una visita a la finca.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.3,
                      fontStyle: FontStyle.italic,
                      color: PaletaCacao.cremaVerdosa,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// El distintivo "BPA" que se ve aunque la nota esté plegada.
class _Sello extends StatelessWidget {
  const _Sello();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: PaletaCacao.verde,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'BPA',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: PaletaCacao.verde,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Ojo extends StatelessWidget {
  const _Ojo({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
      decoration: BoxDecoration(
        color: PaletaCacao.maduroClaro,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 17,
            color: PaletaCacao.maduro,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: PaletaCacao.cafeOscuro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
