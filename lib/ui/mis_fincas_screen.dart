import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/perfil_repository.dart';
import 'editar_finca_screen.dart';
import 'tema.dart';
import 'widgets/comunes.dart';

/// Listado de todas las fincas del productor (RF-02, RF-04).
///
/// La Fase 1 dejó de asumir una sola finca por productor: aquí se ven todas,
/// se edita cualquiera y se puede agregar una nueva.
class MisFincasScreen extends StatelessWidget {
  const MisFincasScreen({
    super.key,
    required this.repo,
    required this.productorId,
  });

  final PerfilRepository repo;
  final String productorId;

  Future<void> _agregarFinca(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            EditarFincaScreen(repo: repo, productorId: productorId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cabeceraCacao(titulo: const Text('Mis fincas')),
      body: FondoCacao(
        child: StreamBuilder<List<Finca>>(
          stream: repo.watchFincas(productorId),
          builder: (context, snapshot) {
            final fincas = snapshot.data ?? const <Finca>[];
            if (fincas.isEmpty) {
              return SingleChildScrollView(
                child: EstadoVacio(
                  icono: Icons.holiday_village_outlined,
                  titulo: 'Sin fincas todavía',
                  mensaje: 'Registre su primera finca para empezar.',
                  textoAccion: 'Agregar finca',
                  onAccion: () => _agregarFinca(context),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                for (final finca in fincas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _TarjetaFincaListado(repo: repo, finca: finca),
                  ),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: () => _agregarFinca(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar otra finca'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TarjetaFincaListado extends StatelessWidget {
  const _TarjetaFincaListado({required this.repo, required this.finca});

  final PerfilRepository repo;
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
                    productorId: finca.productorId,
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
