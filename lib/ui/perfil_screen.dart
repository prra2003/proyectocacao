import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/perfil_repository.dart';
import '../data/sync/sync_service.dart';
import 'cuenta_screens.dart';
import 'editar_finca_screen.dart';
import 'editar_productor_screen.dart';
import 'tema.dart';
import 'widgets/comunes.dart';

/// Los datos que se leen una vez: quién es el productor y dónde está la finca.
///
/// Viven aquí y no en el inicio justamente porque no cambian: ocupaban el mejor
/// sitio de la app sin decir nada nuevo nunca.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({
    super.key,
    required this.repo,
    required this.db,
    required this.sync,
  });

  final PerfilRepository repo;
  final AppDatabase db;
  final SyncService sync;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: cabeceraCacao(titulo: const Text('Mi perfil')),
      body: FondoCacao(
        child: StreamBuilder<Productor?>(
          stream: repo.watchProductor(),
          builder: (context, snapshot) {
            final productor = snapshot.data;
            if (productor == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Todavía no hay perfil registrado.'),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                _TarjetaProductor(repo: repo, productor: productor),
                const SizedBox(height: 20),
                _TarjetaCuenta(db: db, sync: sync),
                const SizedBox(height: 20),
                StreamBuilder<Finca?>(
                  stream: repo.watchFinca(productor.id),
                  builder: (context, snapshot) {
                    final finca = snapshot.data;
                    if (finca == null) return const SizedBox.shrink();
                    return _TarjetaFinca(
                      repo: repo,
                      productorId: productor.id,
                      finca: finca,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Estado de la cuenta. Tiene tres caras, y la del medio importa: con la
/// confirmación de correo activada en el servidor, vincular **no** basta, y la
/// app no puede decir que los datos están respaldados hasta que la persona
/// abra el enlace del mensaje.
class _TarjetaCuenta extends StatefulWidget {
  const _TarjetaCuenta({required this.db, required this.sync});

  final AppDatabase db;
  final SyncService sync;

  @override
  State<_TarjetaCuenta> createState() => _TarjetaCuentaState();
}

class _TarjetaCuentaState extends State<_TarjetaCuenta> {
  var _trabajando = false;

  Future<void> _yaConfirme() async {
    setState(() => _trabajando = true);
    final confirmado = await widget.sync.refrescarEstadoCuenta();
    if (!mounted) return;
    setState(() => _trabajando = false);
    avisar(
      context,
      confirmado
          ? 'Listo: su cuenta quedó confirmada'
          : 'Todavía no aparece confirmado. Abra el enlace del correo.',
    );
  }

  /// Entrar con una cuenta existente desde un teléfono que ya tiene datos.
  ///
  /// Se avisa antes porque lo local se reemplaza; el borrado real ocurre dentro
  /// de `entrarConCuenta`, y solo si el servidor acepta las credenciales.
  Future<void> _entrarConOtraCuenta() async {
    final pendientes = await widget.db.syncDao.watchPendientes().first;
    if (!mounted) return;

    final seguir = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('¿Ya tiene cuenta?'),
        content: Text(
          'Al entrar, los datos de este teléfono se borran y se bajan los de '
          'su cuenta.'
          '${pendientes > 0 ? '\n\nTiene $pendientes '
                    '${pendientes == 1 ? 'cambio' : 'cambios'} sin enviar: '
                    'se perderían.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (seguir != true || !mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            IniciarSesionScreen(sync: widget.sync, reemplazarDatos: true),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    final pendientes = await widget.db.syncDao.watchPendientes().first;
    if (!mounted) return;

    final salir = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: Text(
          pendientes > 0
              ? 'Tiene $pendientes ${pendientes == 1 ? 'cambio' : 'cambios'} '
                    'sin enviar. Si sale ahora, se pierden.\n\n'
                    'Los datos de este teléfono se borran; los que ya envió los '
                    'recupera volviendo a entrar con su correo.'
              : 'Los datos de este teléfono se borran. Los recupera volviendo '
                    'a entrar con su correo y contraseña.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 44),
              backgroundColor: Theme.of(contexto).colorScheme.error,
            ),
            onPressed: () => Navigator.of(contexto).pop(true),
            child: Text(pendientes > 0 ? 'Salir igual' : 'Cerrar sesión'),
          ),
        ],
      ),
    );
    if (salir != true || !mounted) return;

    await widget.sync.cerrarSesion();
    if (mounted) avisar(context, 'Sesión cerrada en este teléfono');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return StreamBuilder<SesionLocal?>(
      stream: widget.db.syncDao.watchSesion(),
      builder: (context, snapshot) {
        final correo = snapshot.data?.correo;
        final confirmado = snapshot.data?.correoConfirmado ?? false;
        final pendienteDeConfirmar = correo != null && !confirmado;

        final (color, fondo, icono, titulo) = switch ((correo, confirmado)) {
          (null, _) => (
            PaletaCacao.maduro,
            PaletaCacao.maduroClaro,
            Icons.cloud_off_outlined,
            'Sin cuenta',
          ),
          (final c?, false) => (
            PaletaCacao.maduro,
            PaletaCacao.maduroClaro,
            Icons.mark_email_unread_outlined,
            c,
          ),
          (final c?, true) => (
            PaletaCacao.verde,
            PaletaCacao.verdeClaro,
            Icons.verified_user_outlined,
            c,
          ),
        };

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: fondo,
                      child: Icon(icono, size: 32, color: color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(titulo, style: tema.textTheme.titleMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  switch ((correo, confirmado)) {
                    (null, _) =>
                      'Sus datos están solo en este teléfono. Con una cuenta '
                          'puede recuperarlos si lo pierde o cambia de equipo.',
                    (_, false) =>
                      'Le enviamos un correo para confirmar su cuenta. Ábralo '
                          'y toque el enlace: hasta entonces no podrá entrar '
                          'desde otro teléfono.',
                    (_, true) =>
                      'Sus datos están respaldados. Puede entrar con este '
                          'correo desde otro teléfono.',
                  },
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                if (correo == null) ...[
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CrearCuentaScreen(sync: widget.sync),
                      ),
                    ),
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Crear cuenta'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _entrarConOtraCuenta,
                    icon: const Icon(Icons.login),
                    label: const Text('Ya tengo cuenta'),
                  ),
                ] else ...[
                  if (pendienteDeConfirmar)
                    FilledButton.icon(
                      onPressed: _trabajando ? null : _yaConfirme,
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        _trabajando ? 'Revisando…' : 'Ya confirmé mi correo',
                      ),
                    ),
                  if (pendienteDeConfirmar) const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _cerrarSesion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tema.colorScheme.error,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TarjetaProductor extends StatelessWidget {
  const _TarjetaProductor({required this.repo, required this.productor});

  final PerfilRepository repo;
  final Productor productor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: PaletaCacao.verdeClaro,
                  child: Icon(Icons.person, size: 42, color: PaletaCacao.verde),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productor.nombreCompleto,
                        style: tema.textTheme.titleLarge,
                      ),
                      Text(
                        'Productor de cacao',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (productor.telefono != null)
              FilaDato(icono: Icons.phone_outlined, texto: productor.telefono!),
            if (productor.email != null)
              FilaDato(icono: Icons.mail_outline, texto: productor.email!),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      EditarProductorScreen(repo: repo, productor: productor),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar mis datos'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaFinca extends StatelessWidget {
  const _TarjetaFinca({
    required this.repo,
    required this.productorId,
    required this.finca,
  });

  final PerfilRepository repo;
  final String productorId;
  final Finca finca;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(finca.nombre, style: tema.textTheme.titleLarge),
            FilaDato(
              icono: Icons.place_outlined,
              texto: '${finca.municipio}, ${finca.departamento}',
            ),
            if (finca.latitud != null && finca.longitud != null)
              FilaDato(
                icono: Icons.my_location_outlined,
                secundario: true,
                texto:
                    '${finca.latitud!.toStringAsFixed(4)}, '
                    '${finca.longitud!.toStringAsFixed(4)}',
              ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EditarFincaScreen(
                    repo: repo,
                    productorId: productorId,
                    finca: finca,
                  ),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar la finca'),
            ),
          ],
        ),
      ),
    );
  }
}
