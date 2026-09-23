import 'package:flutter/material.dart';

import '../../data/local/database.dart';

/// Nombre de la finca actual, tocable: abre la lista de todas las fincas del
/// productor y el camino para agregar una nueva.
///
/// Antes esto era un `Text` fijo porque solo existía una finca por productor
/// (RF-02 no estaba cumplido). Ahora un productor puede tener varias, así que
/// hace falta un lugar para ver cuál está activa y cambiarla.
class SelectorFinca extends StatelessWidget {
  const SelectorFinca({
    super.key,
    required this.fincas,
    required this.seleccionada,
    required this.onSeleccionar,
    required this.onAgregar,
    required this.onEliminar,
    required this.onEditar,
    this.colorTexto = Colors.white,
    this.colorSubtexto = const Color(0xCCFFFFFF),
  });

  final List<Finca> fincas;
  final Finca seleccionada;
  final ValueChanged<String> onSeleccionar;
  final VoidCallback onAgregar;

  /// Se llama ya confirmado por el productor (el aviso sale desde acá
  /// mismo, antes de cerrar la lista). Quien lo reciba solo tiene que
  /// borrar la finca de verdad.
  final ValueChanged<Finca> onEliminar;

  /// Abre la pantalla de edición de esa finca; quien lo reciba ya cierra
  /// esta lista antes de navegar.
  final ValueChanged<Finca> onEditar;
  final Color colorTexto;
  final Color colorSubtexto;

  /// Agregar y eliminar una finca son cosas que solo se hacen desde acá (el
  /// selector del Inicio): así hay un único lugar donde tocar, en vez de
  /// repetir el mismo botón en Perfil.
  Future<void> _confirmarEliminar(BuildContext contexto, Finca finca) async {
    final confirmado = await showDialog<bool>(
      context: contexto,
      builder: (dialogo) => AlertDialog(
        title: Text('¿Borrar ${finca.nombre}?'),
        content: const Text(
          'Se borran también sus lotes, labores, cosechas y diagnósticos. '
          'Esto no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 44),
              backgroundColor: Theme.of(dialogo).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    if (contexto.mounted) Navigator.of(contexto).pop();
    onEliminar(finca);
  }

  Future<void> _abrirSelector(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Sus fincas', style: Theme.of(contexto).textTheme.titleLarge),
            const SizedBox(height: 4),
            for (final finca in fincas)
              ListTile(
                leading: Icon(
                  finca.id == seleccionada.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off_outlined,
                  color: finca.id == seleccionada.id
                      ? Theme.of(contexto).colorScheme.primary
                      : Theme.of(contexto).colorScheme.outline,
                ),
                title: Text(finca.nombre),
                subtitle: Text('${finca.municipio}, ${finca.departamento}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Editar finca',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.of(contexto).pop();
                        onEditar(finca);
                      },
                    ),
                    IconButton(
                      tooltip: 'Eliminar finca',
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(contexto).colorScheme.error,
                      ),
                      onPressed: () => _confirmarEliminar(contexto, finca),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(contexto).pop();
                  if (finca.id != seleccionada.id) onSeleccionar(finca.id);
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Agregar otra finca'),
              onTap: () {
                Navigator.of(contexto).pop();
                onAgregar();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _abrirSelector(context),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    seleccionada.nombre,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: colorTexto,
                    ),
                  ),
                  Text(
                    seleccionada.municipio,
                    style: TextStyle(fontSize: 18, color: colorSubtexto),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.unfold_more_rounded, color: colorSubtexto, size: 22),
          ],
        ),
      ),
    );
  }
}
