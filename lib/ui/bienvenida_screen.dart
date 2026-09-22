import 'package:flutter/material.dart';

import '../data/repositories/perfil_repository.dart';
import '../data/sync/sync_service.dart';
import 'editar_finca_screen.dart';
import 'editar_productor_screen.dart';
import 'tema.dart';
import 'widgets/boton_google.dart';
import 'widgets/comunes.dart';

/// Lo primero que se ve al instalar la app.
///
/// Encadena el registro en dos pasos —sus datos y su finca— en vez de dejar al
/// productor adivinando qué toca después: al terminar el primero, el segundo se
/// abre solo.
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key, required this.repo, required this.sync});

  final PerfilRepository repo;
  final SyncService sync;

  Future<void> _registrar(BuildContext context) async {
    final navegador = Navigator.of(context);

    final creado = await navegador.push<bool>(
      MaterialPageRoute(
        builder: (_) => EditarProductorScreen(repo: repo, paso: 'Paso 1 de 2'),
      ),
    );
    if (creado != true) return;

    final productor = await repo.watchProductor().first;
    if (productor == null) return;

    await navegador.push<bool>(
      MaterialPageRoute(
        builder: (_) => EditarFincaScreen(
          repo: repo,
          productorId: productor.id,
          paso: 'Paso 2 de 2',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: PaletaCacao.cabecera,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // El emblema de la Red. Va recortado en círculo y con el fondo
              // transparente por fuera, para que sobre el degradado se lea
              // como un sello y no como una calcomanía cuadrada.
              Image.asset(
                'assets/emblema.png',
                width: 190,
                height: 190,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(height: 32),
              const Text(
                'Red Nacional de Cacao',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lleve el control de su finca, sus lotes y sus cosechas.\n'
                'Funciona sin señal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  height: 1.4,
                  color: Color(0xE6FFFFFF),
                ),
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: PaletaCacao.cafeOscuro,
                ),
                onPressed: () => _registrar(context),
                child: const Text('Comenzar registro'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Solo le pediremos su nombre y los datos de la finca.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xB3FFFFFF)),
              ),
              const SizedBox(height: 10),
              // La puerta del teléfono nuevo: quien ya tiene cuenta no debe
              // registrarse otra vez, sino bajar lo que ya existe. No hace
              // falta navegar a ninguna parte: Google abre su propia ventana.
              BotonGoogle(
                // Si algo falla hay que decirlo: un botón que no responde deja
                // a la persona sin saber si tocó mal o si no hay señal.
                alEntrar: () async {
                  final resultado = await sync.entrarConGoogle();
                  if (!context.mounted || resultado.ok) return;
                  avisar(context, resultado.error ?? 'No se pudo entrar');
                },
                constructorPropio: (alTocar) => TextButton(
                  onPressed: alTocar,
                  child: const Text(
                    'Ya tengo cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
