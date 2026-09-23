import 'package:flutter/material.dart';

/// Tema de la app, pensado para usarse en campo.
///
/// Tres decisiones que mandan sobre el resto: **todo es grande** (texto de 17
/// para arriba y botones de 60 px, porque esto se usa al sol, de pie y con las
/// manos sucias), **hay poco contraste de adorno** (nada de bordes ni sombras
/// que compitan con el dato) y **la paleta es de cacao**: marrón de grano
/// tostado, crema de la mazorca abierta y verde de hoja.
/// Los colores del cacao, en un solo sitio.
///
/// El texto va en [cafeOscuro] y no en negro puro: sobre la crema, el negro
/// corta demasiado y cansa; el café oscuro se lee igual de bien y pertenece a
/// la misma familia que el resto.
class PaletaCacao {
  const PaletaCacao._();

  /// Café casi negro: el color del texto.
  static const cafeOscuro = Color(0xFF33200F);

  /// Café del grano tostado: acciones y marca.
  static const cafe = Color(0xFF7A4A2B);
  static const cafeClaro = Color(0xFFF6E5D5);

  /// Verde de la hoja del cacao: lo vivo, lo que crece.
  static const verde = Color(0xFF3D7A3F);
  static const verdeClaro = Color(0xFFD9EBD4);

  /// Naranja de la mazorca madura: la cosecha.
  static const maduro = Color(0xFFC26A1E);

  /// El amarillo del grano seco. Lo trajo el módulo de reportes para separar
  /// visualmente los campos de la siembra.
  static const dorado = Color(0xFFD9A03C);

  /// El crema de las tarjetas y los campos de formulario.
  static const tarjeta = Color(0xFFFBF3E4);
  static const maduroClaro = Color(0xFFFBE3CB);

  /// Fondo: crema de la pulpa.
  static const crema = Color(0xFFFDF5EC);
  static const cremaVerdosa = Color(0xFFF1F3E4);

  /// Degradado de las cabeceras: de la hoja al grano.
  static const cabecera = [Color(0xFF2F6B3A), Color(0xFF7A4A2B)];

  /// Degradado del fondo de las pantallas.
  static const fondo = [crema, cremaVerdosa];
}

ThemeData temaCacao() {
  final esquema = ColorScheme.fromSeed(seedColor: PaletaCacao.cafe).copyWith(
    primary: PaletaCacao.cafe,
    primaryContainer: PaletaCacao.cafeClaro,
    onPrimaryContainer: PaletaCacao.cafeOscuro,
    secondary: PaletaCacao.verde,
    secondaryContainer: PaletaCacao.verdeClaro,
    onSecondaryContainer: const Color(0xFF1E4522),
    tertiary: PaletaCacao.maduro,
    tertiaryContainer: PaletaCacao.maduroClaro,
    onTertiaryContainer: const Color(0xFF5A2E05),
    surface: PaletaCacao.crema,
    onSurface: PaletaCacao.cafeOscuro,
    surfaceContainerLow: Colors.white,
    onSurfaceVariant: const Color(0xFF6B5344),
    outlineVariant: const Color(0xFFE4D6C6),
  );

  const textoBase = TextStyle(height: 1.3);

  return ThemeData(
    colorScheme: esquema,
    useMaterial3: true,
    scaffoldBackgroundColor: esquema.surface,
    textTheme: TextTheme(
      headlineSmall: textoBase.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: textoBase.copyWith(fontSize: 23, fontWeight: FontWeight.w700),
      titleMedium: textoBase.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: textoBase.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: textoBase.copyWith(fontSize: 19),
      bodyMedium: textoBase.copyWith(fontSize: 17),
      bodySmall: textoBase.copyWith(fontSize: 15),
      labelLarge: textoBase.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
    ),
    // Las cabeceras van sobre el degradado verde→café, así que su contenido es
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
      margin: EdgeInsets.zero,
      color: esquema.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(fontSize: 18, color: esquema.onSurfaceVariant),
      floatingLabelStyle: TextStyle(fontSize: 16, color: esquema.primary),
      hintStyle: TextStyle(fontSize: 17, color: esquema.outline),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: esquema.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: esquema.outlineVariant),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: esquema.primary,
      foregroundColor: esquema.onPrimary,
      extendedTextStyle: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
      extendedSizeConstraints: const BoxConstraints.tightFor(height: 64),
    ),
    chipTheme: ChipThemeData(
      // El color va explícito: un labelStyle sin color deja las etiquetas en
      // blanco sobre fondo claro, ilegibles.
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
      selectedColor: esquema.secondaryContainer,
      backgroundColor: Colors.white,
      side: BorderSide(color: esquema.outlineVariant),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      minVerticalPadding: 12,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: esquema.onSurface,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      contentTextStyle: TextStyle(fontSize: 17),
    ),
    dividerTheme: DividerThemeData(color: esquema.outlineVariant, space: 1),
  );
}

/// Cabecera con el degradado de la app: de la hoja verde al grano de cacao.
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

/// Fondo de pantalla: crema con un punto de verde, para que no sea un blanco
/// plano de formulario.
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

/// Reemplazo directo de `MaterialPageRoute`: mismo uso (`RutaCacao(builder:
/// ...)`), pero bastante más lento a propósito — casi el doble que un
/// cambio de pantalla normal — para que el giro de `_TransicionCacao`
/// alcance a verse completo y no solo un parpadeo.
class RutaCacao<T> extends MaterialPageRoute<T> {
  RutaCacao({
    required super.builder,
    super.settings,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 480);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 380);
}