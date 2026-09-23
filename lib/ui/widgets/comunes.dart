import 'package:flutter/material.dart';

import '../../data/local/enums.dart';
import 'mazorca.dart';

/// Pantalla o sección sin datos todavía: ícono, explicación y una salida clara.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    this.icono,
    required this.titulo,
    required this.mensaje,
    this.textoAccion,
    this.onAccion,
    this.compacto = false,
  });

  /// Sin ícono se dibuja la mazorca, que es el símbolo de la app.
  final IconData? icono;
  final String titulo;
  final String mensaje;
  final String? textoAccion;
  final VoidCallback? onAccion;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: compacto ? 24 : 44,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono == null)
            Mazorca(tamano: compacto ? 84 : 132)
          else
            Icon(
              icono,
              size: compacto ? 52 : 76,
              color: tema.colorScheme.primary.withValues(alpha: 0.8),
            ),
          const SizedBox(height: 20),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: tema.textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyLarge?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          if (textoAccion != null && onAccion != null) ...[
            const SizedBox(height: 28),
            FilledButton(onPressed: onAccion, child: Text(textoAccion!)),
          ],
        ],
      ),
    );
  }
}

/// Título de sección con una acción opcional al lado.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key, this.accion});

  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            texto,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ?accion,
      ],
    );
  }
}

/// Dato suelto del resumen: número grande arriba, etiqueta abajo.
class Indicador extends StatelessWidget {
  const Indicador({
    super.key,
    required this.valor,
    required this.etiqueta,
    required this.icono,
    required this.color,
  });

  final String valor;
  final String etiqueta;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 26, color: color),
          ),
          const SizedBox(height: 8),
          Text(valor, style: tema.textTheme.headlineSmall),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de dato dentro de una tarjeta: ícono, etiqueta y valor.
class FilaDato extends StatelessWidget {
  const FilaDato({
    super.key,
    required this.icono,
    required this.texto,
    this.secundario = false,
  });

  final IconData icono;
  final String texto;
  final bool secundario;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = secundario
        ? tema.colorScheme.onSurfaceVariant
        : tema.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 24, color: tema.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: tema.textTheme.bodyLarge?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

IconData iconoActividad(TipoActividad tipo) => switch (tipo) {
  TipoActividad.siembra => Icons.spa_outlined,
  TipoActividad.poda => Icons.content_cut,
  TipoActividad.fertilizacion => Icons.grass,
  TipoActividad.controlFitosanitario => Icons.pest_control,
  TipoActividad.riego => Icons.water_drop_outlined,
  TipoActividad.otro => Icons.handyman_outlined,
};

void avisar(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
}

String? campoRequerido(String? valor) =>
    (valor == null || valor.trim().isEmpty) ? 'Campo obligatorio' : null;

/// Solo letras (con tildes/ñ), espacios, guiones y apóstrofes: para nombres de
/// persona, donde un número casi siempre es un error de digitación.
final _soloLetrasPatron = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ\s'-]+$");

String? soloLetras(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return 'Campo obligatorio';
  if (!_soloLetrasPatron.hasMatch(texto)) return 'Solo letras, sin números';
  return null;
}

/// Solo dígitos (con un '+' inicial opcional, para el indicativo de país). El
/// campo puede quedar vacío: quien no ponga nada no está obligado a hacerlo.
final _soloNumerosPatron = RegExp(r'^\+?[0-9]+$');

String? soloNumerosOpcional(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return null;
  if (!_soloNumerosPatron.hasMatch(texto)) return 'Solo números';
  return null;
}

String? textoONulo(String texto) => texto.trim().isEmpty ? null : texto.trim();

/// Convierte lo que se escribe en campo ("2,5") a número.
double? aNumero(String texto) =>
    double.tryParse(texto.trim().replaceAll(',', '.'));
