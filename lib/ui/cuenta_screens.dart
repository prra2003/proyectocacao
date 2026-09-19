import 'package:flutter/material.dart';

import '../data/sync/sync_service.dart';
import 'tema.dart';
import 'widgets/comunes.dart';
import 'widgets/mazorca.dart';

/// Mínimo pero no vacío de contenido: 8 caracteres, con letras y números. Nada
/// de mayúsculas ni símbolos obligatorios — lo pide quien va a usar esto en el
/// campo, no un banco.
String? _validarClaveNueva(String? valor) {
  final texto = valor ?? '';
  if (texto.isEmpty) return 'Campo obligatorio';
  if (texto.length < 8) return 'Mínimo 8 caracteres';
  final tieneLetra = RegExp('[A-Za-z]').hasMatch(texto);
  final tieneNumero = RegExp('[0-9]').hasMatch(texto);
  if (!tieneLetra || !tieneNumero) return 'Use letras y números';
  return null;
}

/// Crear la cuenta desde una instalación **que ya tiene datos**.
///
/// No registra una cuenta nueva: vincula la sesión anónima que ya existe, para
/// que el `auth.uid()` no cambie y lo ya subido siga siendo de esta cuenta.
class CrearCuentaScreen extends StatefulWidget {
  const CrearCuentaScreen({super.key, required this.sync});

  final SyncService sync;

  @override
  State<CrearCuentaScreen> createState() => _CrearCuentaScreenState();
}

class _CrearCuentaScreenState extends State<CrearCuentaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  final _confirmacion = TextEditingController();
  var _trabajando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _trabajando = true;
      _error = null;
    });
    final resultado = await widget.sync.vincularCuenta(
      correo: _correo.text.trim(),
      clave: _clave.text,
    );
    if (!mounted) return;
    if (!resultado.ok) {
      setState(() {
        _trabajando = false;
        _error = resultado.error;
      });
      return;
    }
    Navigator.of(context).pop(true);
    avisar(context, 'Cuenta creada: sus datos ya están respaldados');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cabeceraCacao(titulo: const Text('Crear cuenta')),
      body: FondoCacao(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              const Text(
                'Con una cuenta puede recuperar su finca en otro teléfono '
                'si pierde este. Sus datos actuales no se pierden.',
                style: TextStyle(fontSize: 18, height: 1.4),
              ),
              const SizedBox(height: 24),
              _CampoCorreo(controlador: _correo),
              const SizedBox(height: 14),
              _CampoClave(
                controlador: _clave,
                etiqueta: 'Contraseña',
                clave: const Key('campo_clave'),
                validador: _validarClaveNueva,
              ),
              const SizedBox(height: 14),
              _CampoClave(
                controlador: _confirmacion,
                etiqueta: 'Repita la contraseña',
                clave: const Key('campo_confirmacion'),
                validador: (valor) => valor != _clave.text
                    ? 'Las contraseñas no son iguales'
                    : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _Aviso(_error!),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _trabajando ? null : _crear,
                child: Text(_trabajando ? 'Creando…' : 'Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Entrar con una cuenta existente desde una instalación nueva.
class IniciarSesionScreen extends StatefulWidget {
  const IniciarSesionScreen({
    super.key,
    required this.sync,
    this.reemplazarDatos = false,
  });

  final SyncService sync;

  /// Se entra desde una instalación que ya tiene datos: al autenticarse, lo
  /// local se borra y se baja lo de la cuenta.
  final bool reemplazarDatos;

  @override
  State<IniciarSesionScreen> createState() => _IniciarSesionScreenState();
}

class _IniciarSesionScreenState extends State<IniciarSesionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  var _trabajando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _trabajando = true;
      _error = null;
    });
    final resultado = await widget.sync.entrarConCuenta(
      correo: _correo.text.trim(),
      clave: _clave.text,
      reemplazarDatosLocales: widget.reemplazarDatos,
    );
    if (!mounted) return;
    if (!resultado.ok) {
      setState(() {
        _trabajando = false;
        _error = resultado.error;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cabeceraCacao(titulo: const Text('Iniciar sesión')),
      body: FondoCacao(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text(
                widget.reemplazarDatos
                    ? 'Al entrar, los datos de este teléfono se reemplazan por '
                          'los de su cuenta.'
                    : 'Entre con la cuenta que creó en su otro teléfono. '
                          'Bajaremos su finca, sus lotes y sus registros.',
                style: const TextStyle(fontSize: 18, height: 1.4),
              ),
              const SizedBox(height: 24),
              _CampoCorreo(controlador: _correo),
              const SizedBox(height: 14),
              _CampoClave(
                controlador: _clave,
                etiqueta: 'Contraseña',
                clave: const Key('campo_clave'),
                // Aquí no se exige el formato nuevo: la cuenta pudo crearse
                // antes de este cambio, y lo que valida la clave de verdad es
                // el servidor, no este formulario.
                validador: campoRequerido,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _Aviso(_error!),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _trabajando ? null : _entrar,
                child: Text(_trabajando ? 'Entrando…' : 'Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lo que se ve mientras baja la finca de una cuenta ya existente.
///
/// Es una pantalla de bloqueo a propósito: si dejara pasar al registro, el
/// productor podría crear un segundo perfil bajo la misma cuenta antes de que
/// llegara el que ya existe.
class RecuperandoScreen extends StatelessWidget {
  const RecuperandoScreen({super.key, required this.sync});

  final SyncService sync;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoCacao(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ValueListenableBuilder(
              valueListenable: sync.estado,
              builder: (context, estado, _) {
                final fallo = estado.ultimoResultado?.error;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Mazorca(tamano: 110),
                    const SizedBox(height: 28),
                    Text(
                      fallo == null
                          ? 'Recuperando sus datos…'
                          : 'No se pudieron recuperar sus datos',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fallo ??
                          'Estamos bajando su finca, sus lotes y sus '
                              'registros. Puede tardar un momento.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (fallo == null)
                      const CircularProgressIndicator()
                    else
                      FilledButton(
                        onPressed: sync.sincronizar,
                        child: const Text('Reintentar'),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CampoCorreo extends StatelessWidget {
  const _CampoCorreo({required this.controlador});

  final TextEditingController controlador;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('campo_correo'),
      controller: controlador,
      decoration: const InputDecoration(
        labelText: 'Correo',
        prefixIcon: Icon(Icons.mail_outline),
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      validator: (valor) {
        final texto = (valor ?? '').trim();
        if (texto.isEmpty) return 'Campo obligatorio';
        if (!texto.contains('@') || !texto.contains('.')) {
          return 'Ese correo no parece válido';
        }
        return null;
      },
    );
  }
}

class _CampoClave extends StatelessWidget {
  const _CampoClave({
    required this.controlador,
    required this.etiqueta,
    required this.clave,
    required this.validador,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final Key clave;
  final String? Function(String?) validador;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: clave,
      controller: controlador,
      obscureText: true,
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      validator: validador,
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.mensaje);

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esquema.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: esquema.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(fontSize: 17, color: esquema.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
