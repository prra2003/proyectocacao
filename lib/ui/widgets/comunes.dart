import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/enums.dart';
import '../formato.dart';
import '../tema.dart';
import 'mazorca.dart';

const _uuid = Uuid();

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
  TipoActividad.siembra => Icons.eco_outlined,
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

/// Valida que un número esté en un rango razonable, además de ser válido.
///
/// Sin este techo, un error de dedo (200000 en vez de 2) pasa la validación
/// de "mayor que cero" sin problema y queda enterrado en la base hasta que
/// alguien lo nota en un reporte.
/// Campo de formulario en tarjeta propia: un círculo de color con el ícono,
/// la etiqueta al lado, y debajo el campo de texto con relleno del mismo
/// color — el estilo de "Ingresar datos" (Nombre completo, Teléfono,
/// Correo), con una marca de agua del ícono en la esquina.
class CampoTarjeta extends StatelessWidget {
  const CampoTarjeta({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.color,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.suffixText,
    this.readOnly = false,
    this.campoKey,
  });

  final String etiqueta;
  final IconData icono;
  final Color color;
  final TextEditingController controller;

  /// Va en el campo de texto de adentro, no en la tarjeta: es lo que buscan
  /// los tests para escribir.
  final Key? campoKey;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  /// Ej. "ha" en el área sembrada: va pegado a la derecha del campo.
  final String? suffixText;

  /// Para un valor que la app llena sola (ej. un código automático): se ve
  /// igual, pero no se puede escribir en él y lleva un candado de aviso.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PaletaCacao.tarjeta,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Icon(icono, size: 74, color: color.withValues(alpha: 0.10)),
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
                    child: Icon(icono, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Expanded: las preguntas largas ("¿Cuántos árboles
                  // podó?") bajan de línea en vez de cortarse.
                  Expanded(
                    child: Text(
                      etiqueta,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: PaletaCacao.crema,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: campoKey,
                controller: controller,
                validator: validator,
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                readOnly: readOnly,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: color.withValues(alpha: readOnly ? 0.08 : 0.14),
                  hintText: hint ?? etiqueta,
                  suffixText: suffixText,
                  suffixIcon: readOnly
                      ? Icon(Icons.lock_outline, color: color, size: 18)
                      : null,
                  prefixIcon: Icon(icono, color: color, size: 22),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String? validarRango(
  String? texto, {
  required double min,
  required double max,
  required String etiqueta,
}) {
  final valor = aNumero(texto ?? '');
  if (valor == null) return '$etiqueta inválido';
  if (valor <= min) return '$etiqueta debe ser mayor a ${numeroCorto(min)}';
  if (valor > max) {
    return '$etiqueta no puede pasar de ${numeroCorto(max)}';
  }
  return null;
}

/// Desplegable con el mismo look de [CampoTarjeta], pero con opciones fijas
/// en vez de un campo de texto libre: para los "tipo de..." y "problema
/// detectado" del registro del proceso (Poda, Fertilización, Control
/// fitosanitario, Riego, Cosecha), donde el productor elige de una lista en
/// vez de escribir a mano.
class SelectorDesplegable extends StatelessWidget {
  const SelectorDesplegable({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.color,
    required this.opciones,
    required this.valor,
    required this.onCambio,
    this.validator,
    this.campoKey,
  });

  final String etiqueta;
  final IconData icono;
  final Color color;
  final List<String> opciones;
  final String? valor;
  final ValueChanged<String?> onCambio;
  final String? Function(String?)? validator;

  /// Va en el desplegable de adentro, igual que en [CampoTarjeta].
  final Key? campoKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PaletaCacao.tarjeta,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Icon(icono, size: 74, color: color.withValues(alpha: 0.10)),
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
                    child: Icon(icono, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Expanded: las preguntas largas ("¿Cuántos árboles
                  // podó?") bajan de línea en vez de cortarse.
                  Expanded(
                    child: Text(
                      etiqueta,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: PaletaCacao.crema,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                key: campoKey,
                initialValue: valor,
                isExpanded: true,
                validator: validator,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: color.withValues(alpha: 0.14),
                  hintText: 'Elija una opción',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                ),
                items: [
                  for (final opcion in opciones)
                    DropdownMenuItem(value: opcion, child: Text(opcion)),
                ],
                onChanged: onCambio,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Abre una hoja para elegir "Tomar foto" o "Elegir de la galería", y copia
/// lo elegido a una carpeta propia de la app dentro de sus documentos.
///
/// Se copia en vez de guardar la ruta que entrega el selector porque, sobre
/// todo en la galería, esa ruta puede vivir en una caché temporal que el
/// sistema borra sin avisar — la foto desaparecería del historial sin que
/// el productor lo note. Devuelve `null` si cancela en cualquier paso.
Future<String?> elegirFoto(
  BuildContext context, {
  required String carpeta,
}) async {
  final origen = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tomar foto'),
            onTap: () => Navigator.of(contexto).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Elegir de la galería'),
            onTap: () => Navigator.of(contexto).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (origen == null) return null;

  final archivo = await ImagePicker().pickImage(
    source: origen,
    imageQuality: 80,
    maxWidth: 1600,
  );
  if (archivo == null) return null;

  final destinoCarpeta = Directory(
    p.join((await getApplicationDocumentsDirectory()).path, carpeta),
  );
  await destinoCarpeta.create(recursive: true);
  final destino = p.join(
    destinoCarpeta.path,
    '${_uuid.v4()}${p.extension(archivo.path)}',
  );
  await File(archivo.path).copy(destino);
  return destino;
}

/// Campo tocable para agregar una foto: muestra la miniatura si ya hay una,
/// o una invitación a tomarla si no. Es opcional a propósito: no toda labor
/// en campo tiene con qué tomar la foto en el momento.
class CampoFoto extends StatelessWidget {
  const CampoFoto({
    super.key,
    required this.fotoPath,
    required this.cargando,
    required this.onTap,
    required this.onQuitar,
    this.etiqueta = 'Registro fotográfico (opcional)',
  });

  final String? fotoPath;
  final bool cargando;
  final VoidCallback onTap;
  final VoidCallback onQuitar;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: cargando ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PaletaCacao.tarjeta,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PaletaCacao.verde.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            if (fotoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(fotoPath!),
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: PaletaCacao.verde.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: cargando
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.add_a_photo_outlined,
                        color: PaletaCacao.verde,
                      ),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                fotoPath != null ? 'Foto agregada' : etiqueta,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: PaletaCacao.crema,
                ),
              ),
            ),
            if (fotoPath != null)
              IconButton(
                tooltip: 'Quitar foto',
                icon: const Icon(Icons.close),
                onPressed: onQuitar,
              ),
          ],
        ),
      ),
    );
  }
}
