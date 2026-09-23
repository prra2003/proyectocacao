import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/local/enums.dart';
import '../data/repositories/perfil_repository.dart';
import 'formato.dart';
import 'tema.dart';
import 'widgets/comunes.dart';
import 'widgets/confirmacion_guardado.dart';

/// Valor del dropdown que representa "no está en la lista, la voy a escribir".
const _valorOtraAsociacion = '__otro__';

/// Alta y edición de los datos del productor.
class EditarProductorScreen extends StatefulWidget {
  const EditarProductorScreen({
    super.key,
    required this.repo,
    this.productor,
    this.paso,
  });

  final PerfilRepository repo;

  /// "Paso 1 de 2" mientras se está registrando por primera vez.
  final String? paso;
  final Productor? productor;

  @override
  State<EditarProductorScreen> createState() => _EditarProductorScreenState();
}

class _EditarProductorScreenState extends State<EditarProductorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(
    text: widget.productor?.nombreCompleto ?? '',
  );
  late final _numeroDocumento = TextEditingController(
    text: widget.productor?.numeroDocumento ?? '',
  );
  late final _telefono = TextEditingController(
    text: widget.productor?.telefono ?? '',
  );
  late final _email = TextEditingController(
    text: widget.productor?.email ?? '',
  );
  final _nombreAsociacion = TextEditingController();
  TipoDocumento? _tipoDocumento;

  /// Casi todos los productores tienen cédula: viene elegida, y los otros
  /// tipos de documento aparecen solo si toca "Cambiar".
  var _mostrarTiposDocumento = false;

  /// Correo de la cuenta de Google con la que se entró. Si existe, no se
  /// pregunta el correo: ya se sabe.
  String? _correoCuenta;

  /// null = "Ninguna", `_valorOtraAsociacion` = "Otro" (la escribe el
  /// productor), cualquier otro valor = el id de una [Asociacion] existente.
  String? _asociacionId;
  var _guardando = false;

  @override
  void initState() {
    super.initState();
    _asociacionId = widget.productor?.asociacionId;
    _tipoDocumento =
        widget.productor?.tipoDocumento ?? TipoDocumento.cedulaCiudadania;
    _mostrarTiposDocumento = _tipoDocumento != TipoDocumento.cedulaCiudadania;
    _leerCuenta();
  }

  Future<void> _leerCuenta() async {
    final sesion = await widget.repo.sesionActual();
    final correo = sesion?.correo;
    if (!mounted || correo == null || correo.isEmpty) return;
    setState(() {
      _correoCuenta = correo;
      if (_email.text.trim().isEmpty) _email.text = correo;
      final nombre = sesion?.nombreCuenta;
      if (_nombre.text.trim().isEmpty && nombre != null) _nombre.text = nombre;
    });
  }

  @override
  void dispose() {
    _nombre.dispose();
    _numeroDocumento.dispose();
    _telefono.dispose();
    _email.dispose();
    _nombreAsociacion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final esNuevo = widget.productor == null;

    // "Otro" no es un id real: primero hay que crear la asociación para
    // conseguir uno antes de guardar el productor.
    final asociacionIdFinal = _asociacionId == _valorOtraAsociacion
        ? await widget.repo.crearAsociacion(_nombreAsociacion.text.trim())
        : _asociacionId;

    await widget.repo.guardarProductor(
      id: widget.productor?.id,
      nombreCompleto: _nombre.text.trim(),
      tipoDocumento: _tipoDocumento,
      numeroDocumento: textoONulo(_numeroDocumento.text),
      telefono: textoONulo(_telefono.text),
      email: textoONulo(_email.text),
      asociacionId: asociacionIdFinal,
    );
    if (!mounted) return;
    await mostrarConfirmacionGuardado(
      context,
      mensaje: esNuevo ? 'Datos guardados' : 'Cambios guardados',
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.productor == null;
    return Scaffold(
      appBar: cabeceraCacao(
        titulo: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(esNuevo ? 'Mis datos' : 'Editar mis datos'),
            if (widget.paso != null)
              Text(
                widget.paso!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xCCFFFFFF),
                ),
              ),
          ],
        ),
      ),
      body: FondoCacao(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (_correoCuenta != null) ...[
                _AvisoCuentaGoogle(correo: _correoCuenta!),
                const SizedBox(height: 16),
              ],
              CampoTarjeta(
                etiqueta: 'Nombre completo',
                icono: Icons.person_outline,
                color: PaletaCacao.dorado,
                controller: _nombre,
                campoKey: const Key('campo_nombre_productor'),
                hint: 'Nombre completo',
                textCapitalization: TextCapitalization.words,
                validator: soloLetras,
              ),
              const SizedBox(height: 16),
              if (!_mostrarTiposDocumento)
                _CedulaElegida(
                  onCambiar: () =>
                      setState(() => _mostrarTiposDocumento = true),
                )
              else
                SelectorDesplegable(
                  etiqueta: 'Tipo de documento',
                  icono: Icons.badge_outlined,
                  color: PaletaCacao.cafe,
                  campoKey: const Key('campo_tipo_documento'),
                  opciones: [
                    for (final tipo in TipoDocumento.values)
                      etiquetaTipoDocumento(tipo),
                  ],
                  valor: _tipoDocumento == null
                      ? null
                      : etiquetaTipoDocumento(_tipoDocumento!),
                  onCambio: (etiqueta) => setState(
                    () => _tipoDocumento = TipoDocumento.values
                        .where((t) => etiquetaTipoDocumento(t) == etiqueta)
                        .firstOrNull,
                  ),
                  validator: (valor) =>
                      valor == null ? 'Campo obligatorio' : null,
                ),
              const SizedBox(height: 16),
              CampoTarjeta(
                etiqueta: _mostrarTiposDocumento
                    ? 'Número de documento'
                    : 'Número de cédula',
                icono: Icons.numbers_outlined,
                color: PaletaCacao.cafe,
                controller: _numeroDocumento,
                campoKey: const Key('campo_numero_documento'),
                hint: 'Número de documento',
                validator: campoRequerido,
              ),
              const SizedBox(height: 16),
              CampoTarjeta(
                etiqueta: 'Teléfono',
                icono: Icons.phone_outlined,
                color: PaletaCacao.verde,
                controller: _telefono,
                campoKey: const Key('campo_telefono'),
                hint: 'Teléfono',
                keyboardType: TextInputType.phone,
                validator: soloNumerosOpcional,
              ),
              if (_correoCuenta == null) ...[
                const SizedBox(height: 16),
                CampoTarjeta(
                  etiqueta: 'Correo',
                  icono: Icons.mail_outline,
                  color: PaletaCacao.dorado,
                  controller: _email,
                  campoKey: const Key('campo_email'),
                  hint: 'Correo',
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
              const SizedBox(height: 22),
              Text(
                'Asociación a la que pertenece',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Si no aparece la suya, elija "Otra" y escríbala.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<Asociacion>>(
                stream: widget.repo.watchAsociaciones(),
                builder: (context, snapshot) {
                  final asociaciones = snapshot.data ?? const <Asociacion>[];
                  // Si el productor ya tenía una asociación que por alguna
                  // razón no viene en la lista (borrada, de otra fuente...),
                  // igual se muestra para no perder la selección al abrir el
                  // formulario.
                  final valorActual =
                      _asociacionId == null ||
                          _asociacionId == _valorOtraAsociacion ||
                          asociaciones.any((a) => a.id == _asociacionId)
                      ? _asociacionId
                      : null;
                  return DropdownButtonFormField<String?>(
                    key: const Key('campo_asociacion'),
                    initialValue: valorActual,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.groups_outlined),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Ninguna'),
                      ),
                      for (final asociacion in asociaciones)
                        DropdownMenuItem(
                          value: asociacion.id,
                          child: Text(
                            asociacion.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const DropdownMenuItem(
                        value: _valorOtraAsociacion,
                        child: Text('Otra (especificar)'),
                      ),
                    ],
                    onChanged: (valor) => setState(() => _asociacionId = valor),
                  );
                },
              ),
              if (_asociacionId == _valorOtraAsociacion) ...[
                const SizedBox(height: 14),
                CampoTarjeta(
                  etiqueta: 'Nombre de la asociación',
                  icono: Icons.edit_outlined,
                  color: PaletaCacao.verde,
                  controller: _nombreAsociacion,
                  campoKey: const Key('campo_asociacion_otra'),
                  textCapitalization: TextCapitalization.words,
                  validator: campoRequerido,
                ),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: Text(esNuevo ? 'Crear perfil' : 'Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recuerda que el correo (y el nombre, si Google lo dio) ya vienen de la
/// cuenta: por eso no hay casilla de correo.
class _AvisoCuentaGoogle extends StatelessWidget {
  const _AvisoCuentaGoogle({required this.correo});

  final String correo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PaletaCacao.verdeClaro,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: PaletaCacao.verde),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entró con su cuenta de Google',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(correo, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// La cédula ya elegida, con una salida discreta para quien tenga otro
/// documento.
class _CedulaElegida extends StatelessWidget {
  const _CedulaElegida({required this.onCambiar});

  final VoidCallback onCambiar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.badge_outlined, color: PaletaCacao.cafe),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Documento: cédula de ciudadanía',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          key: const Key('boton_cambiar_documento'),
          onPressed: onCambiar,
          child: const Text('Cambiar'),
        ),
      ],
    );
  }
}
