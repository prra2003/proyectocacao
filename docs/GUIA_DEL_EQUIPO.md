# Guía del equipo

Cómo trabajar en este proyecto entre varias personas sin pisarnos.

Si es tu primer día: lee el [README](../README.md) para saber qué hace la
aplicación, y la [documentación técnica](DOCUMENTACION_TECNICA.md) para entender
cómo está construida por dentro.

---

## 1. Preparar tu computador

Necesitas **Flutter 3.47 o superior** y el **SDK de Android** (viene con Android
Studio).

```bash
git clone URL_DEL_REPOSITORIO
```

```bash
cd cacao_app && flutter pub get
```

```bash
dart run build_runner build
```

Ese último comando genera el código de la base de datos. **Hay que correrlo cada
vez que alguien cambia las tablas o los DAOs**, o el proyecto no compila.

Para verlo funcionando:

```bash
flutter run
```

---

## 2. La regla principal

**Nadie escribe directo en `main`.** Una rama por tarea, y un *pull request* que
otra persona revisa antes de juntarlo.

```bash
git checkout main && git pull
git checkout -b clima-en-el-inicio
```

Trabajas, guardas los cambios, y subes tu rama:

```bash
git add -A
git commit -m "Muestra el clima del municipio en el inicio"
git push -u origin clima-en-el-inicio
```

Después abres el pull request desde GitHub. Cuando alguien lo aprueba y las
pruebas están en verde, se junta a `main`.

### Nombres de rama

Cortos y en español, describiendo la tarea: `clima-en-el-inicio`,
`arreglar-cascada-diagnosticos`, `panel-tecnico`.

### Mensajes de commit

En español, diciendo **qué hace el cambio**, no qué archivos tocaste:

- ✅ `Evita que la finca se guarde sin municipio`
- ❌ `cambios en editar_finca_screen.dart`

---

## 3. Antes de abrir un pull request

Estos dos comandos tienen que pasar. Si fallan, el cambio no entra:

```bash
flutter analyze
```

```bash
flutter test
```

GitHub los corre solo en cada pull request, pero es más rápido descubrirlo en tu
computador que esperar.

**Si tocaste algo de datos o de sincronización, agrega o ajusta un test.** Los
121 tests que hay son la red de seguridad del proyecto: gracias a ellos se
cazaron un bucle infinito de paginación y una comparación de fechas que perdía
filas en silencio.

---

## 4. Quién toca qué

Para no chocar, cada quien trabaja sobre su carpeta:

| Área | Carpeta | Qué hay ahí |
|---|---|---|
| Interfaz | `lib/ui/` | Pantallas, tema, diálogos |
| Datos | `lib/data/local/`, `lib/data/daos/` | Tablas, migraciones, consultas |
| Sincronización | `lib/data/sync/` | Lo más delicado del proyecto |
| Backend | `supabase/` | Esquema, triggers, políticas RLS |
| Pruebas | `test/` | |

Si tu tarea toca `lib/data/sync/`, avisa antes en el grupo: es la parte donde un
cambio mal hecho se nota tarde y duele.

---

## 5. Cosas que **no** se hacen

- **No** subir la APK ni la carpeta `build/` al repositorio. Las versiones se
  publican en *Releases* de GitHub.
- **No** poner la llave `service_role` de Google Apps Script en el código. La publicable
  sí, es pública por diseño; la otra se salta toda la seguridad.
- **No** borrar filas de verdad. Todo borrado es suave (`deleted_at`), o los
  demás teléfonos nunca se enteran.
- **No** hacer que la interfaz espere al servidor. Se guarda en local y se
  sincroniza después: esa es la razón de ser de la aplicación.

---

## 6. Convenciones del código

- **Todo en español**: nombres de clases, variables, métodos y comentarios.
- **Comentarios donde alguien se puede equivocar**, no en lo obvio. Explican
  *por qué*, no *qué*.
- La UI habla con los **repositorios**, nunca con los DAOs directamente.
- Antes de subir, formatear: `dart format lib test`

---

## 7. Google Apps Script mientras somos varios

Por ahora todos apuntamos al **mismo proyecto** de Google Apps Script, así que los datos de
prueba se ven entre nosotros. No pasa nada en esta etapa.

Cuando alguien vaya a cambiar el `schema.sql`, mejor que cree su propio proyecto
gratis y lo use con su llave:

```bash
flutter run --dart-define=SUPABASE_URL=TU_URL --dart-define=SUPABASE_KEY=TU_LLAVE
```

Así nadie le tumba las tablas a otro.

---

## 8. Publicar una versión

**APK** para que la prueben:

```bash
flutter build apk --release
```

Queda en `build/app/outputs/flutter-apk/app-release.apk` y se sube a *Releases*
en GitHub, con una nota de qué cambió.

**Web**, para mostrarla sin instalar nada:

```bash
flutter build web --release
vercel deploy --prod build/web
```

Recuerda que la web necesita las cabeceras de aislamiento; ya están configuradas
en `web/_headers` y `vercel.json`, no las quites o la base de datos del navegador
deja de funcionar.
