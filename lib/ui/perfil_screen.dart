import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/perfil_repository.dart';
import '../data/sync/sync_service.dart';
import 'editar_productor_screen.dart';
import 'formato.dart';
import 'tema.dart';
import 'widgets/boton_google.dart';
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
                StreamBuilder<List<Finca>>(
                  stream: repo.watchFincas(productor.id),
                  builder: (context, snapshot) {
                    final fincas = snapshot.data ?? const <Finca>[];
                    if (fincas.isEmpty) return const SizedBox.shrink();
                    return _TarjetaFincas(fincas: fincas);
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

/// Estado de la cuenta: con Google son dos caras, no tres.
///
/// Antes había un estado intermedio —"le mandamos un correo, ábralo"— porque
/// el servidor exigía confirmar la dirección. Con Google la cuenta llega
/// verificada, así que o hay respaldo o no lo hay.
class _TarjetaCuenta extends StatefulWidget {
  const _TarjetaCuenta({required this.db, required this.sync});

  final AppDatabase db;
  final SyncService sync;

  @override
  State<_TarjetaCuenta> createState() => _TarjetaCuentaState();
}

class _TarjetaCuentaState extends State<_TarjetaCuenta> {
  var _trabajando = false;

  /// Entra con Google. Si el teléfono ya tiene datos, avisa primero: lo local
  /// se reemplaza por lo de la cuenta.
  ///
  /// El borrado ocurre dentro de `entrarConGoogle`, y solo si Google y el
  /// servidor aceptaron: si la persona cierra la ventana, no se toca nada.
  Future<void> _entrar() async {
    final pendientes = await widget.db.syncDao.watchPendientes().first;
    final hayProductor = await widget.db.syncDao.hayDatosLocales();
    if (!mounted) return;

    if (hayProductor) {
      final seguir = await showDialog<bool>(
        context: context,
        builder: (contexto) => AlertDialog(
          title: const Text('¿Entrar con su cuenta?'),
          content: Text(
            'Si ya tiene datos guardados en esa cuenta, los de este teléfono '
            'se reemplazan por los suyos.'
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
    }

    setState(() => _trabajando = true);
    final resultado = await widget.sync.entrarConGoogle();
    if (!mounted) return;
    setState(() => _trabajando = false);
    avisar(
      context,
      resultado.ok
          ? 'Listo: sus datos quedaron respaldados'
          : resultado.error ?? 'No se pudo entrar',
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
                    'recupera volviendo a entrar con la misma cuenta.'
              : 'Los datos de este teléfono se borran. Los recupera volviendo '
                    'a entrar con la misma cuenta de Google.',
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
        final hayCuenta = correo != null;

        final (color, fondo, icono, titulo) = hayCuenta
            ? (
                PaletaCacao.verde,
                PaletaCacao.verdeClaro,
                Icons.verified_user_outlined,
                correo,
              )
            : (
                PaletaCacao.maduro,
                PaletaCacao.maduroClaro,
                Icons.cloud_off_outlined,
                'Sin cuenta',
              );

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
                  hayCuenta
                      ? 'Sus datos están respaldados. Puede entrar con esta '
                            'misma cuenta desde otro teléfono.'
                      : 'Sus datos están solo en este teléfono. Entrando con '
                            'su cuenta de Google puede recuperarlos si lo '
                            'pierde o cambia de equipo.',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                if (!hayCuenta)
                  BotonGoogle(
                    alEntrar: _entrar,
                    constructorPropio: (alTocar) => FilledButton.icon(
                      onPressed: _trabajando ? null : alTocar,
                      icon: const Icon(Icons.login),
                      label: Text(
                        _trabajando ? 'Entrando…' : 'Entrar con Google',
                      ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _cerrarSesion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tema.colorScheme.error,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
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
            if (productor.tipoDocumento != null &&
                productor.numeroDocumento != null)
              FilaDato(
                icono: Icons.badge_outlined,
                texto:
                    '${etiquetaTipoDocumento(productor.tipoDocumento!)} '
                    '${productor.numeroDocumento}',
              ),
            if (productor.asociacionId != null)
              FutureBuilder<Asociacion?>(
                future: repo.asociacionPorId(productor.asociacionId!),
                builder: (context, snapshot) {
                  final asociacion = snapshot.data;
                  if (asociacion == null) return const SizedBox.shrink();
                  return FilaDato(
                    icono: Icons.groups_outlined,
                    texto: asociacion.nombre,
                  );
                },
              ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                RutaCacao<void>(
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

/// Las fincas del productor, solo para verlas.
///
/// Agregar, editar o borrar una finca se hace en un solo lugar: tocando el
/// nombre de la finca arriba en el Inicio. Antes se podía también desde aquí
/// y desde Reportes, y con tres caminos para lo mismo el productor no sabía
/// cuál era el bueno.
class _TarjetaFincas extends StatelessWidget {
  const _TarjetaFincas({required this.fincas});

  final List<Finca> fincas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fincas.length == 1 ? 'Su finca' : 'Sus fincas',
              style: tema.textTheme.titleLarge,
            ),
            for (final finca in fincas)
              FilaDato(
                icono: Icons.place_outlined,
                texto:
                    '${finca.nombre} · ${finca.municipio}, '
                    '${finca.departamento}',
              ),
            const SizedBox(height: 12),
            Text(
              'Para cambiar o agregar una finca, toque su nombre arriba en '
              'el Inicio.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
