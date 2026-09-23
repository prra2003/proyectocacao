import 'package:flutter/material.dart';

/// Tema de la app: cálido y claro, crema con cabeceras en café oscuro y
/// acentos en naranja y verde — la interfaz original que se le mostró al
/// productor.
///
/// El fondo de las pantallas es un crema suave, las cabeceras (arriba de
/// cada pantalla) van en café bien oscuro casi negro, y cada tipo de dato
/// tiene su propio acento de color (naranja para lo principal, verde para
/// el productor/contacto, café para lo secundario), igual que en las
/// tarjetas de "Ingresar datos".
class PaletaCacao {
  const PaletaCacao._();

  /// Café oscuro pero vivo (no casi negro): el degradado de las cabeceras,
  /// el texto sobre elementos claros y el fondo de los avisos (snackbar).
  static const cafeOscuro = Color(0xFF3D2314);

  /// Café cálido: acento secundario (hectáreas, diagnóstico, identificación).
  static const cafe = Color(0xFF8B5A34);
  static const cafeClaro = Color(0xFFF0E0C8);

  /// Verde salvia: el productor, lo que crece, el teléfono de contacto.
  static const verde = Color(0xFF4C8058);
  static const verdeClaro = Color(0xFFDCEAE0);

  /// Verde profundo: solo para contraste dentro de dibujos (la hoja de la
  /// mazorca/el brote), nunca como fondo de pantalla.
  static const verdeOscuro = Color(0xFF2E5233);

  /// Naranja de la mazorca madura: acción de cosecha, FAB de anotar.
  static const maduro = Color(0xFFE07B39);
  static const maduroClaro = Color(0xFFF6DFC7);

  /// Naranja dorado: el acento principal de toda la app (botones, lo que
  /// más se toca), igual que en la referencia.
  static const dorado = Color(0xFFDB7A34);
  static const doradoClaro = Color(0xFFF3D7B8);

  /// Fondo: crema cálido, plano.
  static const profundo = Color(0xFFEFE1C7);
  static const profundoOscuro = Color(0xFFE3CFA4);

  /// Texto principal, oscuro sobre el fondo claro.
  static const crema = Color(0xFF2B1810);

  /// Texto secundario, más apagado, para subtítulos y etiquetas.
  static const cremaVerdosa = Color(0xFF7C6656);

  /// Las tarjetas van casi blancas, apenas un tono más claras que el fondo.
  static const tarjeta = Color(0xFFFBF3E4);

  /// Degradado de las cabeceras: café vivo, más claro y llamativo que un
  /// café casi negro.
  static const cabecera = [Color(0xFF63391F), Color(0xFF2E1810)];

  /// Degradado del fondo de las pantallas: crema cálido.
  static const fondo = [Color(0xFFEFE1C7), Color(0xFFE3CFA4)];
}

ThemeData temaCacao() {
  final esquema =
      ColorScheme.fromSeed(
        seedColor: PaletaCacao.dorado,
        brightness: Brightness.light,
      ).copyWith(
        primary: PaletaCacao.dorado,
        onPrimary: Colors.white,
        primaryContainer: PaletaCacao.doradoClaro,
        onPrimaryContainer: PaletaCacao.cafeOscuro,
        secondary: PaletaCacao.verde,
        onSecondary: Colors.white,
        secondaryContainer: PaletaCacao.verdeClaro,
        onSecondaryContainer: PaletaCacao.cafeOscuro,
        tertiary: PaletaCacao.cafe,
        tertiaryContainer: PaletaCacao.cafeClaro,
        onTertiaryContainer: PaletaCacao.cafeOscuro,
        error: const Color(0xFFB3452D),
        onError: Colors.white,
        surface: PaletaCacao.tarjeta,
        onSurface: PaletaCacao.crema,
        surfaceContainerLow: PaletaCacao.tarjeta,
        surfaceContainerHighest: const Color(0xFFF3E6CE),
        onSurfaceVariant: PaletaCacao.cremaVerdosa,
        outline: const Color(0xFFD8C4A0),
        outlineVariant: const Color(0xFFE9DCC0),
      );

  const textoBase = TextStyle(height: 1.3);

  return ThemeData(
    colorScheme: esquema,
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: PaletaCacao.fondo.last,
    textTheme: TextTheme(
      headlineSmall: textoBase.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: PaletaCacao.crema,
      ),
      titleLarge: textoBase.copyWith(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: PaletaCacao.crema,
      ),
      titleMedium: textoBase.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: PaletaCacao.crema,
      ),
      titleSmall: textoBase.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: PaletaCacao.crema,
      ),
      bodyLarge: textoBase.copyWith(fontSize: 19, color: PaletaCacao.crema),
      bodyMedium: textoBase.copyWith(fontSize: 17, color: PaletaCacao.crema),
      bodySmall: textoBase.copyWith(
        fontSize: 15,
        color: PaletaCacao.cremaVerdosa,
      ),
      labelLarge: textoBase.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: PaletaCacao.crema,
      ),
    ),
    // Las cabeceras van sobre el degradado oscuro, así que su contenido es
    // blanco (ver `cabeceraCacao`).
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 70,
      titleTextStyle: TextStyle(
        fontSize: 27,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white, size: 28),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      margin: EdgeInsets.zero,
      color: PaletaCacao.tarjeta,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: PaletaCacao.dorado.withValues(alpha: 0.16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1E2C7),
      labelStyle: TextStyle(fontSize: 18, color: esquema.onSurfaceVariant),
      floatingLabelStyle: TextStyle(fontSize: 16, color: esquema.primary),
      hintStyle: const TextStyle(fontSize: 17, color: Color(0xFFAA9678)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: esquema.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      prefixIconColor: esquema.primary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(62),
        elevation: 4,
        shadowColor: PaletaCacao.dorado.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        foregroundColor: PaletaCacao.crema,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        side: BorderSide(color: esquema.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PaletaCacao.dorado,
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: PaletaCacao.maduro,
      foregroundColor: Colors.white,
      extendedTextStyle: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
      extendedSizeConstraints: const BoxConstraints.tightFor(height: 64),
    ),
    chipTheme: ChipThemeData(
      // El color va explícito: un labelStyle sin color deja las etiquetas
      // sin contraste sobre el fondo oscuro.
      labelStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: esquema.onSurface,
      ),
      secondaryLabelStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: esquema.onSecondaryContainer,
      ),
      selectedColor: esquema.primaryContainer,
      backgroundColor: const Color(0xFFF1E2C7),
      side: BorderSide(color: esquema.outlineVariant),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      minVerticalPadding: 12,
    ),
    // Una sola transición para TODA la navegación (cualquier
    // `Navigator.push(MaterialPageRoute(...))` de la app la usa
    // automáticamente, sin tocar cada pantalla una por una): entra con un
    // desvanecido + deslizado suave hacia arriba, y la pantalla de atrás se
    // opaca un poco mientras tanto, para dar sensación de profundidad en vez
    // del corte seco por defecto de Android.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _TransicionCacao(),
        TargetPlatform.iOS: _TransicionCacao(),
        TargetPlatform.macOS: _TransicionCacao(),
        TargetPlatform.windows: _TransicionCacao(),
        TargetPlatform.linux: _TransicionCacao(),
      },
    ),
    tabBarTheme: const TabBarThemeData(
      labelStyle: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 19),
      labelColor: Colors.white,
      unselectedLabelColor: Color(0xCCFFFFFF),
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: PaletaCacao.tarjeta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: esquema.onSurface,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: PaletaCacao.cafeOscuro,
      contentTextStyle: TextStyle(fontSize: 17, color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    dividerTheme: DividerThemeData(color: esquema.outlineVariant, space: 1),
  );
}

/// Cabecera con el degradado de la app: verde-azulado oscuro de punta a
/// punta.
AppBar cabeceraCacao({
  required Widget titulo,
  List<Widget>? acciones,
  PreferredSizeWidget? abajo,
}) {
  return AppBar(
    title: titulo,
    actions: acciones,
    bottom: abajo,
    // SizedBox.expand: sin él, el DecoratedBox no toma tamaño dentro del
    // flexibleSpace y el degradado no se pinta.
    flexibleSpace: const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: PaletaCacao.cabecera,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
  );
}

/// Fondo de pantalla: el degradado oscuro de la app, plano y sobrio, de
/// punta a punta — sin manchas ni adornos encima, para que el foco quede en
/// las tarjetas.
class FondoCacao extends StatelessWidget {
  const FondoCacao({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: PaletaCacao.fondo,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

/// La transición propia de la app: la pantalla nueva aparece con un
/// desvanecido corto y un leve deslizamiento hacia arriba.
///
/// Antes giraba medio segundo sobre su eje. Se veía vistoso la primera vez,
/// pero en un celular de gama baja y usado todos los días se sentía lento:
/// ahora cambiar de pantalla es casi inmediato.
class _TransicionCacao extends PageTransitionsBuilder {
  const _TransicionCacao();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final entrada = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    return FadeTransition(
      opacity: entrada,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(entrada),
        child: child,
      ),
    );
  }
}

/// Reemplazo directo de `MaterialPageRoute`: mismo uso (`RutaCacao(builder:
/// ...)`), con la duración corta de [_TransicionCacao].
class RutaCacao<T> extends MaterialPageRoute<T> {
  RutaCacao({required super.builder, super.settings, super.fullscreenDialog});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 180);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 150);
}
