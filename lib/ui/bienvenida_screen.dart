import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/repositories/perfil_repository.dart';
import '../data/sync/sync_service.dart';
import 'editar_finca_screen.dart';
import 'editar_productor_screen.dart';
import 'tema.dart';
import 'widgets/boton_google.dart';
import 'widgets/brote.dart';
import 'widgets/comunes.dart';
import 'widgets/mazorca.dart';

/// Lo primero que se ve al instalar la app.
///
/// Encadena el registro en dos pasos —sus datos y su finca— en vez de dejar al
/// productor adivinando qué toca después: al terminar el primero, el segundo se
/// abre solo. Después de la primera finca, se le pregunta si tiene otra (RF-02:
/// un productor puede tener varias), en vez de obligarlo a ir luego a Perfil.
///
/// La entrada va animada y pausada a propósito: varios brotes pequeños
/// entran desde los bordes, convergen hacia el centro y se desvanecen justo
/// cuando el brote grande termina de aparecer — como si "se juntaran" en
/// una sola. Después sube el texto y por último los botones, que responden
/// al toque con un achique bien visible y un rebote al soltar.
class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key, required this.repo, required this.sync});

  final PerfilRepository repo;
  final SyncService sync;

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen>
    with SingleTickerProviderStateMixin {
  // 2.6 s en vez de 1.1 s: da tiempo a que se note el recorrido de las
  // mazorcas pequeñas antes de que aparezca la grande.
  late final _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  /// Fracción [inicio, fin] de la animación de entrada, ya envuelta en una
  /// curva: cada elemento aparece un poco después que el anterior, en vez de
  /// que todo salte a la vez.
  Animation<double> _tramo(
    double inicio,
    double fin, {
    Curve curva = Curves.easeOutCubic,
  }) {
    return CurvedAnimation(
      parent: _entrada,
      curve: Interval(inicio, fin, curve: curva),
    );
  }

  Future<void> _registrar(BuildContext context) async {
    final navegador = Navigator.of(context);

    final creado = await navegador.push<bool>(
      RutaCacao(
        builder: (_) =>
            EditarProductorScreen(repo: widget.repo, paso: 'Paso 1 de 2'),
      ),
    );
    if (creado != true) return;

    final productor = await widget.repo.watchProductor().first;
    if (productor == null) return;

    await navegador.push<bool>(
      RutaCacao(
        builder: (_) => EditarFincaScreen(
          repo: widget.repo,
          productorId: productor.id,
          paso: 'Paso 2 de 2',
        ),
      ),
    );

    // En cuanto el productor quedó creado, esta pantalla ya se reemplazó por
    // la app principal (el cascarón la cambia solo al ver el productor), así
    // que su propio `context` ya no sirve para abrir diálogos. Se usa el
    // contexto del propio Navigator, que sigue siendo válido.
    while (true) {
      final otraMas = await showDialog<bool>(
        // ignore: use_build_context_synchronously  (es el del Navigator, no el de esta pantalla)
        context: navegador.context,
        builder: (contexto) => AlertDialog(
          title: const Text('¿Tiene otra finca?'),
          content: const Text(
            'Puede registrar todas las fincas que maneje, no solo una. '
            'Después puede agregar más tocando el nombre de la finca en el Inicio.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(contexto).pop(false),
              child: const Text('No, ya terminé'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
              onPressed: () => Navigator.of(contexto).pop(true),
              child: const Text('Agregar otra finca'),
            ),
          ],
        ),
      );
      if (otraMas != true) break;
      await navegador.push<bool>(
        RutaCacao(
          builder: (_) =>
              EditarFincaScreen(repo: widget.repo, productorId: productor.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // Degradado de tres tonos (café casi negro → café tostado → naranja
      // apagado) en vez del café plano de dos tonos que se veía sin vida:
      // da la sensación de tener varios colores mezclándose sin perder
      // elegancia ni el contraste del texto blanco.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF160B05), Color(0xFF3C2013), Color(0xFF6B3A1E)],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Manchas difuminadas de varios colores de la paleta: le dan
          // profundidad y variedad al fondo en vez de dejarlo de un solo
          // tono café.
          const Positioned(
            top: -70,
            left: -80,
            child: _ManchaSuave(
              tamano: 260,
              alfa: 0.22,
              color: PaletaCacao.dorado,
            ),
          ),
          const Positioned(
            top: 180,
            right: -90,
            child: _ManchaSuave(
              tamano: 220,
              alfa: 0.16,
              color: PaletaCacao.verde,
            ),
          ),
          const Positioned(
            bottom: -90,
            right: -60,
            child: _ManchaSuave(
              tamano: 280,
              alfa: 0.18,
              color: PaletaCacao.maduro,
            ),
          ),
          const Positioned(
            bottom: 60,
            left: -90,
            child: _ManchaSuave(tamano: 200, alfa: 0.14, color: Colors.white),
          ),

          // Resplandor detrás de la matica: un halo suave que la hace
          // destacar, como si tuviera luz propia, en vez de quedar plana
          // sobre el fondo.
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, -0.32),
              child: FadeTransition(
                opacity: _tramo(0.3, 0.6),
                child: const _ManchaSuave(
                  tamano: 320,
                  alfa: 0.30,
                  color: PaletaCacao.doradoClaro,
                ),
              ),
            ),
          ),

          // La mazorca grande de fondo: cubre buena parte de la pantalla,
          // con un tinte dorado y verde (no blanco plano) para sumarse a la
          // mezcla de colores, sin competir con la matica ni con el texto.
          // Entra con el mismo giro + aparecido que el resto de la
          // bienvenida, solo que empieza un poco antes para sentirse
          // "debajo" de todo lo demás.
          Positioned(
            bottom: -70,
            right: -90,
            child: IgnorePointer(
              child: ScaleTransition(
                scale: Tween(
                  begin: 0.6,
                  end: 1.0,
                ).animate(_tramo(0.15, 0.75, curva: Curves.easeOutCubic)),
                child: FadeTransition(
                  opacity: _tramo(0.15, 0.45),
                  child: Mazorca(
                    tamano: 340,
                    color: PaletaCacao.dorado.withValues(alpha: 0.22),
                    colorHoja: PaletaCacao.verde.withValues(alpha: 0.30),
                  ),
                ),
              ),
            ),
          ),

          // Los cuatro brotes pequeños: entran desde las esquinas y
          // convergen hacia donde va a quedar el brote grande, para
          // desvanecerse justo cuando este termina de aparecer. Cada uno
          // en un color distinto de la paleta, para que la "mezcla" ya se
          // note desde que empieza la animación.
          _BroteConvergente(
            animacion: _tramo(0, 0.5, curva: Curves.easeOutCubic),
            inicio: const Alignment(-1.6, -1.1),
            destino: const Alignment(0, -0.32),
            color: PaletaCacao.dorado,
            colorHoja: PaletaCacao.doradoClaro,
          ),
          _BroteConvergente(
            animacion: _tramo(0.05, 0.55, curva: Curves.easeOutCubic),
            inicio: const Alignment(1.6, -1.0),
            destino: const Alignment(0, -0.32),
            color: PaletaCacao.verde,
            colorHoja: PaletaCacao.verdeClaro,
          ),
          _BroteConvergente(
            animacion: _tramo(0.1, 0.6, curva: Curves.easeOutCubic),
            inicio: const Alignment(-1.5, 1.2),
            destino: const Alignment(0, -0.32),
            color: PaletaCacao.maduro,
            colorHoja: PaletaCacao.maduroClaro,
          ),
          _BroteConvergente(
            animacion: _tramo(0.15, 0.65, curva: Curves.easeOutCubic),
            inicio: const Alignment(1.5, 1.1),
            destino: const Alignment(0, -0.32),
            color: PaletaCacao.doradoClaro,
            colorHoja: PaletaCacao.dorado,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween(
                      begin: 0.3,
                      end: 1.0,
                    ).animate(_tramo(0.4, 0.85, curva: Curves.elasticOut)),
                    child: FadeTransition(
                      opacity: _tramo(0.4, 0.62),
                      // El brote que dibujó el equipo: los brotes pequeños
                      // convergen hacia él. Coloreado con la paleta —dorado
                      // adelante, verde atrás, tallo café— en vez de blanco
                      // plano, para que combine con el resto de la pantalla.
                      child: const Brote(
                        tamano: 250,
                        color: PaletaCacao.dorado,
                        colorHoja: PaletaCacao.verde,
                        colorTallo: PaletaCacao.cafe,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Aparece(
                    animacion: _tramo(0.62, 0.82),
                    child: const Text(
                      'Cacaiva',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // Más grande que el nombre largo anterior: "Cacaiva"
                        // cabe holgado en una línea y el nombre es lo que la
                        // pantalla de entrada tiene que dejar grabado.
                        fontSize: 46,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Aparece(
                    animacion: _tramo(0.7, 0.9),
                    child: const Text(
                      'Lleve el control de su finca, sus lotes y sus '
                      'cosechas.\nFunciona sin señal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        height: 1.4,
                        color: Color(0xE6FFFFFF),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _Aparece(
                    animacion: _tramo(0.8, 1.0),
                    desplazar: 24,
                    child: Column(
                      children: [
                        _BotonPrimario(
                          texto: 'Comenzar registro',
                          onTap: () => _registrar(context),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Solo le pediremos su nombre y los datos de '
                          'la finca.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xB3FFFFFF),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // La puerta del teléfono nuevo: quien ya tiene
                        // cuenta no debe registrarse otra vez, sino
                        // bajar lo que ya existe.
                        // No hace falta navegar a ninguna parte: Google abre
                        // su propia ventana.
                        BotonGoogle(
                          // Si algo falla hay que decirlo: un botón que no
                          // responde deja a la persona sin saber si tocó mal
                          // o si no hay señal.
                          alEntrar: () async {
                            final resultado = await widget.sync
                                .entrarConGoogle();
                            if (!context.mounted || resultado.ok) return;
                            avisar(
                              context,
                              resultado.error ?? 'No se pudo entrar',
                            );
                          },
                          constructorPropio: (alTocar) => _BotonTexto(
                            texto: 'Ya tengo cuenta',
                            onTap: alTocar,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Envuelve a [child] en un desvanecido + subida desde abajo, sobre el tramo
/// de animación que se le pase — así cada elemento entra un poco después que
/// el anterior sin repetir la misma configuración de Tween en cada sitio.
class _Aparece extends StatelessWidget {
  const _Aparece({
    required this.animacion,
    required this.child,
    this.desplazar = 16,
  });

  final Animation<double> animacion;
  final Widget child;
  final double desplazar;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animacion,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: animacion.value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - animacion.value) * desplazar),
            child: child,
          ),
        );
      },
    );
  }
}

/// Un brote pequeño que viaja desde [inicio] hasta [destino] (en
/// coordenadas de [Alignment], relativas a toda la pantalla) y se desvanece
/// al llegar: el efecto de "varios que se juntan en uno".
class _BroteConvergente extends StatelessWidget {
  const _BroteConvergente({
    required this.animacion,
    required this.inicio,
    required this.destino,
    required this.color,
    required this.colorHoja,
  });

  final Animation<double> animacion;
  final Alignment inicio;
  final Alignment destino;
  final Color color;
  final Color colorHoja;

  /// Siempre el mismo: era un parámetro que nadie usaba.
  static const double tamano = 52;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animacion,
        builder: (context, child) {
          final t = animacion.value;
          final alineacion = Alignment.lerp(inicio, destino, t)!;
          // Sube rápido, se sostiene visible y se apaga cerca del final del
          // recorrido, justo cuando "llega" al centro.
          double opacidad;
          if (t < 0.18) {
            opacidad = t / 0.18;
          } else if (t > 0.7) {
            opacidad = (1 - (t - 0.7) / 0.3).clamp(0.0, 1.0);
          } else {
            opacidad = 1.0;
          }
          return Align(
            alignment: alineacion,
            child: Opacity(
              opacity: opacidad,
              child: Transform.rotate(
                angle: (1 - t) * 0.8,
                child: Brote(
                  tamano: tamano,
                  color: color.withValues(alpha: 0.9),
                  colorHoja: colorHoja.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Botón principal: se achica bien visible al presionarlo y rebota un poco
/// de más al soltar, para que el efecto se note sin tener que fijarse.
class _BotonPrimario extends StatefulWidget {
  const _BotonPrimario({required this.texto, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  State<_BotonPrimario> createState() => _BotonPrimarioState();
}

class _BotonPrimarioState extends State<_BotonPrimario> {
  var _presionado = false;

  void _fijar(bool valor) {
    if (_presionado != valor) setState(() => _presionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _fijar(true),
      onTapUp: (_) => _fijar(false),
      onTapCancel: () => _fijar(false),
      child: AnimatedScale(
        // 0.88 en vez de 0.96: el achique anterior casi no se notaba.
        scale: _presionado ? 0.88 : 1,
        duration: Duration(milliseconds: _presionado ? 90 : 260),
        // El rebote pasado de 1.0 al soltar es lo que hace notorio el efecto.
        curve: _presionado ? Curves.easeOut : Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: _presionado ? const Color(0xFFC49A4C) : PaletaCacao.dorado,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: PaletaCacao.dorado.withValues(
                  alpha: _presionado ? 0.18 : 0.45,
                ),
                blurRadius: _presionado ? 6 : 22,
                offset: Offset(0, _presionado ? 1 : 9),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: widget.onTap,
              child: SizedBox(
                height: 62,
                width: double.infinity,
                child: Center(
                  child: Text(
                    widget.texto,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: PaletaCacao.cafeOscuro,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// El enlace de texto ("Ya tengo cuenta"): mismo gesto de "peso" al tocar,
/// exagerado igual que el botón principal para que se note parejo.
class _BotonTexto extends StatefulWidget {
  const _BotonTexto({required this.texto, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  State<_BotonTexto> createState() => _BotonTextoState();
}

class _BotonTextoState extends State<_BotonTexto> {
  var _presionado = false;

  void _fijar(bool valor) {
    if (_presionado != valor) setState(() => _presionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _fijar(true),
      onTapUp: (_) => _fijar(false),
      onTapCancel: () => _fijar(false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _presionado ? 0.45 : 1,
        duration: Duration(milliseconds: _presionado ? 90 : 220),
        child: AnimatedScale(
          scale: _presionado ? 0.9 : 1,
          duration: Duration(milliseconds: _presionado ? 90 : 260),
          curve: _presionado ? Curves.easeOut : Curves.easeOutBack,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.texto,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mancha difuminada fija, para dar profundidad al degradado sin necesitar
/// una imagen.
class _ManchaSuave extends StatelessWidget {
  const _ManchaSuave({
    required this.tamano,
    required this.alfa,
    this.color = Colors.white,
  });

  final double tamano;
  final double alfa;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: tamano,
          height: tamano,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: alfa),
          ),
        ),
      ),
    );
  }
}
