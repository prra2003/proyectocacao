import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/perfil_repository.dart';
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
  var _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    await widget.repo.guardarProductor(
      id: widget.productor?.id,
      nombreCompleto: _nombre.text.trim(),
      telefono: textoONulo(_telefono.text),
      email: textoONulo(_email.text),
      asociacionId: widget.productor?.asociacionId,
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
                validator: campoRequerido,
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
