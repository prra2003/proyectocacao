import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/local/enums.dart';
import '../data/repositories/perfil_repository.dart';
import 'formato.dart';
import 'tema.dart';
import 'widgets/comunes.dart';

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
  /// Valor centinela del dropdown de asociación: no es un id real, dispara el
  /// campo de texto libre.
  static const _otraAsociacion = '__otra__';

  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(
    text: widget.productor?.nombreCompleto ?? '',
  );
  late final _telefono = TextEditingController(
    text: widget.productor?.telefono ?? '',
  );
  late final _email = TextEditingController(
    text: widget.productor?.email ?? '',
  );
  late final _numeroDocumento = TextEditingController(
    text: widget.productor?.numeroDocumento ?? '',
  );
  final _asociacionOtroNombre = TextEditingController();
  TipoDocumento? _tipoDocumento;
  String? _asociacionId;
  var _guardando = false;

  @override
  void initState() {
    super.initState();
    _tipoDocumento = widget.productor?.tipoDocumento;
    _asociacionId = widget.productor?.asociacionId;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _email.dispose();
    _numeroDocumento.dispose();
    _asociacionOtroNombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    // "Otra" no es un id real: primero hay que crear la asociación para
    // conseguir uno antes de guardar el productor.
    final asociacionId = _asociacionId == _otraAsociacion
        ? await widget.repo.crearAsociacion(_asociacionOtroNombre.text.trim())
        : _asociacionId;
    await widget.repo.guardarProductor(
      id: widget.productor?.id,
      nombreCompleto: _nombre.text.trim(),
      telefono: textoONulo(_telefono.text),
      email: textoONulo(_email.text),
      asociacionId: asociacionId,
      tipoDocumento: _tipoDocumento,
      numeroDocumento: textoONulo(_numeroDocumento.text),
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
              TextFormField(
                key: const Key('campo_nombre_productor'),
                controller: _nombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: soloLetras,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('campo_telefono'),
                controller: _telefono,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: soloNumerosOpcional,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('campo_email'),
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<TipoDocumento>(
                key: const Key('campo_tipo_documento'),
                initialValue: _tipoDocumento,
                decoration: const InputDecoration(
                  labelText: 'Tipo de documento',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: [
                  for (final tipo in TipoDocumento.values)
                    DropdownMenuItem(
                      value: tipo,
                      child: Text(etiquetaTipoDocumento(tipo)),
                    ),
                ],
                onChanged: (valor) => setState(() => _tipoDocumento = valor),
                validator: (valor) =>
                    valor == null ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('campo_numero_documento'),
                controller: _numeroDocumento,
                decoration: const InputDecoration(
                  labelText: 'Número de documento',
                  prefixIcon: Icon(Icons.numbers_outlined),
                ),
                keyboardType: TextInputType.text,
                validator: campoRequerido,
              ),
              const SizedBox(height: 14),
              StreamBuilder<List<Asociacion>>(
                stream: widget.repo.watchAsociaciones(),
                builder: (context, snapshot) {
                  final asociaciones = snapshot.data ?? const <Asociacion>[];
                  // Si la asociación que traía el productor ya no está en el
                  // catálogo (borrada o aún sin bajar), el dropdown no puede
                  // mostrarla como seleccionada sin romper.
                  final valorValido =
                      _asociacionId == null ||
                      _asociacionId == _otraAsociacion ||
                      asociaciones.any((a) => a.id == _asociacionId);
                  return DropdownButtonFormField<String?>(
                    key: const Key('campo_asociacion'),
                    initialValue: valorValido ? _asociacionId : null,
                    decoration: const InputDecoration(
                      labelText: 'Asociación',
                      prefixIcon: Icon(Icons.groups_outlined),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin asociación'),
                      ),
                      for (final asociacion in asociaciones)
                        DropdownMenuItem(
                          value: asociacion.id,
                          child: Text(asociacion.nombre),
                        ),
                      const DropdownMenuItem(
                        value: _otraAsociacion,
                        child: Text('Otra (especificar)'),
                      ),
                    ],
                    onChanged: (valor) =>
                        setState(() => _asociacionId = valor),
                  );
                },
              ),
              if (_asociacionId == _otraAsociacion) ...[
                const SizedBox(height: 14),
                TextFormField(
                  key: const Key('campo_asociacion_otra'),
                  controller: _asociacionOtroNombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la asociación',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
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
