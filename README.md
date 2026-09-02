# Red Nacional de Cacao

Aplicación móvil para que un **productor de cacao** lleve el control de su finca
desde el celular, **en el campo y sin señal**.

Proyecto de seminario de grado desarrollado con el SENA / Tecnoparque, como
primer paso del ecosistema digital de la Red Nacional de Cacao.

| | |
|---|---|
| **Estado** | Fase 1 cerrada (captura local + sincronización + cuentas) |
| **Plataforma** | Android · Web (iOS preparado, sin compilar todavía) |
| **Tecnología** | Flutter · Drift/SQLite · Supabase (PostgreSQL) |
| **Tests** | 121, todos en verde |

---

## 1. Qué problema resuelve

El productor de cacao anota hoy sus labores y cosechas en cuadernos o no las
anota. Cuando llega el técnico del SENA o de FEDECACAO, no hay historial: no se
sabe cuándo se podó, cuánto se cosechó ni cómo viene el lote.

Esta aplicación reemplaza ese cuaderno, con una condición que manda sobre todo lo
demás: **en la finca no hay señal**. Por eso todo se guarda primero en el
teléfono y se sincroniza después, cuando haya internet.

**Para quién es:** productores de cacao, con celulares de gama baja o media, que
usan la app de pie, al sol y con las manos ocupadas. De ahí que todo sea grande y
que haya poco texto en pantalla.

### Qué se puede registrar

```
Productor
 └── Fincas              (nombre, municipio, departamento, ubicación GPS)
      └── Lotes          (variedad, área, fecha de siembra)
           ├── Actividades   (poda, fertilización, control fitosanitario, riego, otra)
           ├── Cosechas      (kilos y fecha)
           └── Diagnósticos  (estado fenológico, notas y foto)
```

---

## 2. Características implementadas

- Registro y edición de **productor**, **finca** y **lotes**.
- Registro de **labores**, **cosechas** y **diagnósticos** por lote.
- **Ubicación de la finca** con mapa (OpenStreetMap) y con el GPS del teléfono.
- **Foto del cultivo** en los diagnósticos (cámara o galería).
- **Producción anual** calculada en vivo, por lote y por finca.
- **Última labor** de cada lote a la vista en el inicio ("Poda, hace 12 días").
- **Borrado suave con cascada**: borrar un lote arrastra sus registros y nada se
  borra físicamente.
- **Funcionamiento sin internet** de toda la app.
- **Sincronización con Supabase**: subida de cambios pendientes, descarga
  incremental, reglas de conflicto y cascadas remotas.
- **Cuenta**: sesión anónima automática y vinculación con correo y contraseña,
  con aviso mientras el correo está **pendiente de confirmar**.
- **Inicio de sesión** en otra instalación para recuperar los datos.
- **Cerrar sesión** y **cambiar de cuenta**, que borran los datos de ese
  teléfono avisando antes si hay cambios sin enviar.

Lo que **todavía no** está: fotos en la nube, recuperación de contraseña, cambio
de cuenta en un teléfono con datos, compilación de iOS. Ver
[Estado del proyecto](#12-estado-del-proyecto).

---

> 📘 **¿Cómo está hecho por dentro?** El detalle técnico —decisiones,
> algoritmos, trampas y los problemas reales que aparecieron— está en
> [`docs/DOCUMENTACION_TECNICA.md`](docs/DOCUMENTACION_TECNICA.md).

## 3. Arquitectura

```
        Flutter (UI)
             │
        Repositories          PerfilRepository · LoteRepository
             │
    Base de datos local       Drift / SQLite  ← FUENTE DE VERDAD
             │
        SyncService           push → pull, cursor, conflictos
             │
         ApiRemota            (interfaz)
        ┌────┴─────┐
   ApiRemotaFalsa  ApiSupabase
     (tests)            │
                  Supabase / PostgreSQL
```

La aplicación es **offline-first**. Eso significa, en concreto:

1. La UI **nunca** espera al servidor. Guarda en local y sigue.
2. Cada fila escrita queda marcada como `pending`.
3. Cuando hay red, `SyncService` sube lo pendiente y baja lo nuevo.
4. Las filas ya sincronizadas quedan `synced`.

`ApiRemota` es una interfaz a propósito: los tests corren contra
`ApiRemotaFalsa` (un servidor en memoria, sin red) y la app real contra
`ApiSupabase`. Cambiar de una a otra no toca la UI, ni los repositorios, ni los
DAOs, ni la lógica de sincronización.

---

## 4. Arquitectura de datos

Siete tablas de datos —`asociaciones`, `productores`, `fincas`, `lotes`,
`actividades_agricolas`, `cosechas`, `diagnosticos`— más dos de servicio:
`sesion` y `sync_meta`.

Todas las tablas de datos comparten el mixin `SyncColumns`:

| Columna | Para qué |
|---|---|
| `id` | **UUID generado en el dispositivo**, no autoincremental |
| `created_at` / `updated_at` | Reloj del teléfono |
| `deleted_at` | **Borrado suave**: la fila no se borra, se marca |
| `server_updated_at` | Sello que puso el servidor (único reloj comparable) |
| `sync_status` | `pending` · `synced` · `error` |
| `sync_error` | Motivo del último fallo de subida |

**Por qué UUID en el dispositivo:** dos teléfonos sin señal pueden crear
registros al mismo tiempo sin chocar cuando por fin sincronicen.

**Por qué borrado suave:** un teléfono que estuvo un mes sin señal tiene que
poder enterarse de que algo se borró. Un `DELETE` no deja rastro que propagar.

**Cascadas:** borrar un lote marca `deleted_at` en el lote **y** en sus
actividades, cosechas y diagnósticos, en una sola transacción, dejando todo
`pending` para que el borrado también viaje.

---

## 5. Sincronización

Cada pasada hace **push y después pull**, entidad por entidad y respetando las
dependencias:

```
productores → fincas → lotes → actividades · cosechas · diagnósticos
```

### Subida (push)

```
filas pending → ApiRemota.subir() → el servidor sella updated_at
             → serverUpdatedAt local ← sello    → sync_status = synced
```

### Descarga (pull)

```
cursor (lastSyncAt, lastSyncId) → descargar ordenado por (updated_at, id)
                                → aplicar fila por fila → guardar cursor
```

**El cursor es compuesto `(updated_at, id)`** y se guarda en `sync_meta`. No es
un capricho: con un cursor de solo tiempo, varias filas selladas en el mismo
segundo se pierden o se repiten para siempre. La primera versión de este código
entró en un bucle infinito por exactamente eso, y el test de paginación lo cazó.

Otras garantías del ciclo:

- **Idempotencia**: aplicar dos veces la misma fila no cambia nada (se compara
  `serverUpdatedAt` con el sello recibido).
- **Descarga interrumpida**: si falla a mitad, **el cursor no avanza**; la
  siguiente pasada repite el tramo.
- **Reintentos**: un fallo de red deja la fila `pending` y la cinta del inicio
  la sigue contando. No se pierde nada.
- **Paginación** por la misma clave, con avance garantizado.

### Reglas de conflicto (las reales, implementadas)

1. **Push antes que pull.** Por lo tanto **gana el último en sincronizar**, no
   el último en editar. La regla no depende del reloj de ningún teléfono.
2. **Una fila remota nunca pisa una fila local `pending`.** Gana lo local y el
   choque queda anotado como conflicto en el `SyncResult`.
3. **Hijo sin padre**: si llega una finca cuyo productor no está aquí, se
   aplaza, se anota y el cursor no avanza. La próxima pasada lo reintenta.
4. **Hijo vivo con padre borrado**: entra **ya borrado**; no se revive el padre.
5. **Padre borrado en el servidor**: se dispara la cascada local y los hijos
   quedan borrados y **`synced`**, nunca `pending` — si quedaran pendientes,
   este teléfono subiría un borrado que nunca decidió.

---

## 6. Sistema de identidad

Es la parte más sutil del proyecto. Hay **tres** identificadores distintos y
conviene no confundirlos:

| Identificador | Qué representa | ¿Cambia? |
|---|---|---|
| `id` de cada fila | La fila en sí (UUID) | **Nunca** |
| `sesion.usuarioId` | **La instalación** (este teléfono) | Nunca |
| `sesion.authUid` | **La cuenta** en Supabase | No al vincular |

Y el dueño de los datos se expresa distinto en cada lado:

- **Local**: `productores.usuarioId` = la instalación.
- **Remoto**: `productores.usuario_id` = la cuenta.

La traducción entre ambos ocurre en los mapeadores, y es justamente lo que
permite que otro teléfono adopte los datos sin reescribir un solo UUID ni una
clave foránea.

### El recorrido

```
Instalación sin internet
      ↓
usuarioId local (UUID)          ← se puede trabajar ya, sin cuenta
      ↓
hay internet → sesión anónima → authUid
      ↓
sincronización
      ↓
vincular cuenta (correo + contraseña)
      ↓
MISMO auth.uid()                ← los datos ya subidos siguen siendo suyos
```

**Regla dura del código:** si existe una sesión anónima, la cuenta se **vincula**
(`updateUser`), nunca se **registra** (`signUp`). Registrar crearía un `auth.uid()`
nuevo y dejaría los datos anteriores huérfanos, invisibles para el RLS.

### Dos teléfonos, una cuenta

```
Teléfono A                        Teléfono B
instalación A                     instalación B
      └──────── cuenta X ─────────────┘
                   │
              Supabase
```

B inicia sesión, baja las filas y **las adopta con su propia identidad de
instalación**. Los `id` y las claves foráneas viajan intactos. Mientras la
primera descarga no termina, la app **bloquea el registro** para que no aparezca
un productor duplicado bajo la misma cuenta.

---

## 7. Supabase

- **PostgreSQL** guarda las mismas siete tablas de datos (sin `sync_status` ni
  `sync_error`, que son estado local).
- **`updated_at` lo escribe el servidor** con un trigger, ignorando lo que mande
  el cliente. Un teléfono con la hora mal no puede envenenar la sincronización.
- Todas las fechas son `timestamptz`, nunca `date`.
- **Supabase Auth** con sesión anónima y con correo/contraseña.
- **Row Level Security** activo en las siete tablas.

El esquema completo, listo para pegar en el SQL Editor, está en
[`supabase/schema.sql`](supabase/schema.sql). El script es **idempotente**: se
puede volver a ejecutar sin borrar datos ni fallar por lo que ya exista.

### Configuración

Las credenciales viven en `lib/data/sync/config_supabase.dart` y se pueden pasar
por línea de comandos sin tocar el código:

```bash
flutter run \
  --dart-define=SUPABASE_URL=TU_URL \
  --dart-define=SUPABASE_KEY=TU_LLAVE_PUBLICABLE
```

Si no hay llave configurada, la app arranca contra el **doble en memoria** y
funciona igual; lo único que cambia es a dónde van los datos.

> La llave **publicable** (antes `anon`) es pública por diseño: viaja dentro de
> la app y lo que protege los datos es el RLS del servidor. La llave
> **`service_role` / secret nunca debe estar en el código ni en el repositorio**,
> porque se salta el RLS.

---

## 8. Instalación y ejecución

**Requisitos**

- Flutter 3.47 o superior (incluye Dart 3.13)
- Android SDK con API 36 y NDK (para compilar a Android)
- Un proyecto de Supabase, si se quiere sincronizar de verdad

**Puesta en marcha**

```bash
flutter pub get
```

```bash
dart run build_runner build
```

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter run
```

`build_runner` es necesario porque Drift genera código (`*.g.dart`) a partir de
las tablas.

**Compilar la APK de prueba**

```bash
flutter build apk --release
```

**Versión web**

El mismo proyecto compila a navegador, útil para mostrar la aplicación sin
instalar nada —por ejemplo, en un iPhone—:

```bash
flutter build web --release
```

Para probarla en el computador hay un servidor incluido, que hay que usar en vez
de un `http.server` normal:

```bash
python3 tools/servidor_web.py
```

Y se abre en `http://localhost:8099`.

> **Importante:** la base de datos del navegador necesita que la página se sirva
> con las cabeceras `Cross-Origin-Opener-Policy: same-origin` y
> `Cross-Origin-Embedder-Policy: require-corp`. Sin ellas la app carga pero **no
> puede guardar datos**. Ya están configuradas para Netlify (`web/_headers`) y
> para Vercel (`vercel.json`).

> **Qué es y qué no es la versión web.** Sirve para *mostrar* la aplicación y,
> más adelante, para un panel de técnicos. **No sustituye a la app del
> productor**: el navegador guarda los datos en un almacenamiento que él mismo
> puede desalojar, mientras que en el teléfono el archivo SQLite es del sistema
> operativo. En el campo, esa diferencia lo es todo.

---

## 9. Pruebas

**121 tests**, todos en verde. Se ejecutan con `flutter test`.

| Archivo | Qué cubre |
|---|---|
| `database_test.dart` | Esquema, llaves foráneas, borrado suave |
| `borrado_cascada_test.dart` | Cascadas locales de lote, finca y productor |
| `perfil_productor_test.dart` | Registro en cascada, validaciones, inicio |
| `lote_detalle_test.dart` | Labores, cosechas, diagnósticos, borrar lote |
| `sync_productores_test.dart` | Ciclo completo de una entidad |
| `sync_fincas_test.dart` | Dependencias, hijo antes que padre, cascada remota |
| `sync_lotes_test.dart` | Paginación con sellos repetidos, conflictos |
| `sync_registros_test.dart` | Las tres hojas, parametrizado |
| `sync_ui_test.dart` | Cinta de sincronización y estado pendiente |
| `cuentas_test.dart` | Vinculación, confirmación de correo, login, cerrar sesión, dos instalaciones, aislamiento |
| `cuentas_ui_test.dart` | Pantallas de cuenta y bloqueo de la descarga inicial |

### Qué se probó contra el doble (`ApiRemotaFalsa`)

Todo el ciclo de sincronización: subida, descarga incremental, cursor,
paginación, idempotencia, reintentos, conflictos, cascadas remotas, vinculación
de cuenta conservando el `auth.uid()`, inicio de sesión, dos instalaciones
compartiendo una cuenta y aislamiento entre cuentas distintas.

### Qué se verificó contra Supabase real

En emulador Android, contra el proyecto real: creación de las tablas, sesión
anónima, **subida** de productor, finca y lote con sello de PostgreSQL,
**borrado suave** viajando como `deleted_at`, y **vinculación de la cuenta** con
correo y contraseña.

**Lo que no se alcanzó a verificar en dispositivos reales** es la recuperación
completa en un segundo teléfono (inicio de sesión y descarga). Está implementado
y cubierto por tests contra el doble, pero **no confirmado de punta a punta con
dos teléfonos**.

---

## 10. Migraciones de la base local

| Versión | Qué introdujo |
|---|---|
| v1 | Modelo inicial: productores, fincas, lotes, actividades, cosechas, diagnósticos |
| v2 | Columnas de sincronización (`serverUpdatedAt`, `syncError`), `usuarioId`, tablas `sesion` y `sync_meta` |
| v3 | `lastSyncId`: el cursor pasa a ser compuesto |
| v4 | `correo` y `descargaInicial` en `sesion` (cuentas) |
| v5 | `correoConfirmado` en `sesion` |

Todas son **aditivas**: agregan columnas o tablas, no borran datos ni cambian
identificadores. Las migraciones v1→v2 y v2→v3 se probaron instalando sobre una
instalación real con datos.

---

## 11. Capturas

| | |
|---|---|
| ![Bienvenida](docs/capturas/01-bienvenida.png) | ![Inicio](docs/capturas/02-inicio.png) |
| Bienvenida y registro | Inicio: finca, sincronización y lotes |
| ![Labores](docs/capturas/03-lote-labores.png) | ![Anotar](docs/capturas/07-anotar-labor.png) |
| Detalle del lote | Anotar una labor |
| ![Diagnóstico](docs/capturas/04-diagnostico.png) | ![Mapa](docs/capturas/06-mapa-gps.png) |
| Diagnóstico con foto | Ubicación con mapa y GPS |
| ![Perfil](docs/capturas/05-perfil-cuenta.png) | ![Sesión](docs/capturas/08-iniciar-sesion.png) |
| Perfil y cuenta | Iniciar sesión |

---

## 12. Estado del proyecto

| Funcionalidad | Estado |
|---|---|
| Gestión de productores | ✅ Implementado |
| Gestión de fincas (con GPS y mapa) | ✅ Implementado |
| Gestión de lotes | ✅ Implementado |
| Actividades / labores | ✅ Implementado |
| Cosechas y producción anual | ✅ Implementado |
| Diagnósticos con foto | ✅ Implementado |
| Funcionamiento offline-first | ✅ Implementado |
| Borrado suave y cascadas | ✅ Implementado |
| Sincronización con Supabase | ✅ Implementado |
| Autenticación anónima | ✅ Implementado |
| Vinculación de cuenta (correo confirmado) | ✅ Implementado |
| Inicio de sesión | ✅ Implementado |
| Cerrar sesión | ✅ Implementado |
| Cambiar de cuenta en un teléfono con datos | ✅ Implementado |
| Recuperación en varios dispositivos | 🟡 Funciona con un correo real confirmado; falta dejar registro formal de la prueba con dos teléfonos |
| Fotos en Supabase Storage | ⏳ Pendiente (hoy viaja la ruta, no la imagen) |
| Recuperación de contraseña | ⏳ Pendiente |
| Versión web (mismo código) | 🟡 Compila y arranca en navegador de escritorio; falta probarla a fondo y publicarla |
| Compilación iOS | ⏳ Pendiente (permisos ya configurados) |
| Clima, alertas y recordatorios | ⏳ Fase 2 |

---

## 13. Seguridad y privacidad

- **RLS** activo en las siete tablas. `productores` filtra por
  `usuario_id = auth.uid()`; las demás llegan por *join* hasta el productor.
- Un usuario **no puede leer ni modificar** los datos de otro. La misma cuenta sí
  puede entrar desde varios dispositivos.
- La app usa **únicamente la llave publicable**. La `service_role` **no está** en
  el código ni en el repositorio, y no debe estarlo nunca.
- Las contraseñas las gestiona Supabase Auth; la app no las guarda.
- Las fotos de diagnóstico **no salen del teléfono**.

**Confirmación de correo.** Está **activada** a propósito: la cuenta solo sirve
para recuperar los datos, y con un correo inventado esa recuperación es
imposible el día que hace falta. Mientras el correo no se confirma, la app lo
dice con todas sus letras y no promete un respaldo que no existe.

> **Pendiente antes de producción:** conectar un SMTP propio (el correo incluido
> de Supabase está limitado a unos pocos envíos por hora y es solo para
> pruebas), recuperación y cambio de contraseña —que necesitan enlaces
> profundos hacia la app—, y revisión de cuentas abandonadas.

---

## 14. Mapa del código

### Datos locales — `lib/data/local/`

| Archivo | Qué hay dentro |
|---|---|
| `tables.dart` | Las 9 tablas y el mixin `SyncColumns`. **Aquí se define el modelo.** |
| `database.dart` | `AppDatabase`, las 4 migraciones y las **cascadas de borrado** (locales y remotas) |
| `enums.dart` | `SyncStatus`, `TipoActividad`, `EstadoFenologico` |
| `database.g.dart` | Generado por Drift. **No se edita a mano** |

### Consultas — `lib/data/daos/`

| Archivo | Qué hay dentro |
|---|---|
| `daos.dart` | `ProductoresDao`, `FincasDao`, `LotesDao`, `RegistrosDao` y `SyncDao` (identidad, cuenta y cursores) |

### Repositorios — `lib/data/repositories/`

| Archivo | Qué hay dentro |
|---|---|
| `perfil_repository.dart` | Productor, finca y lotes. Cálculos de edad y área |
| `lote_repository.dart` | Labores, cosechas y diagnósticos de un lote |

### Sincronización — `lib/data/sync/`

| Archivo | Qué hay dentro |
|---|---|
| `sync_service.dart` | **El corazón**: push/pull, cursor, conflictos, cuentas |
| `api_remota.dart` | La interfaz con el backend |
| `api_supabase.dart` | Implementación real (PostgREST + Auth) |
| `api_falsa.dart` | Servidor en memoria con cuentas, para tests y desarrollo |
| `config_supabase.dart` | URL y llave publicable |
| `mapeador_productor.dart` · `mapeador_finca.dart` · `mapeador_lote.dart` · `mapeadores_registros.dart` | Traducen fila local ↔ fila remota |
| `sync_result.dart` | Resultado de una pasada y motivos de conflicto |
| `sync_state.dart` | Estado observable para la interfaz |

### Interfaz — `lib/ui/`

| Archivo | Qué hay dentro |
|---|---|
| `cascaron_screen.dart` | El armazón: barra inferior, botón *Anotar*, y qué mostrar según el estado |
| `bienvenida_screen.dart` | Primera pantalla y registro en dos pasos |
| `inicio_screen.dart` | La pantalla de todos los días: finca, resumen y lotes |
| `lote_detalle_screen.dart` | Las tres pestañas del lote y el borrado |
| `perfil_screen.dart` | Datos de identidad y tarjeta de cuenta |
| `cuenta_screens.dart` | Crear cuenta, iniciar sesión y pantalla de recuperación |
| `perfil_screen.dart` (tarjeta de cuenta) | Los tres estados: sin cuenta, pendiente de confirmar, confirmada; y cerrar sesión |
| `editar_productor_screen.dart` · `editar_finca_screen.dart` | Formularios |
| `mapa_screen.dart` | Mapa y GPS para ubicar la finca |
| `tema.dart` | `PaletaCacao`, tema, cabecera con degradado y fondo |
| `formato.dart` | Fechas, números y etiquetas en español |
| `dialogos/` | Diálogos de lote, labor, cosecha y diagnóstico |
| `widgets/mazorca.dart` | La mazorca de cacao, dibujada en vector |
| `widgets/comunes.dart` | Estados vacíos, indicadores, avisos y validaciones |
| `widgets/estado_sync.dart` | La cinta de sincronización del inicio |
| `widgets/selector_fecha.dart` | Campo de fecha |

### Raíz y otros

| Archivo | Qué hay dentro |
|---|---|
| `lib/main.dart` | Arranque: base local, identidad, backend y `runApp` |
| `supabase/schema.sql` | Esquema, triggers, índices y políticas RLS |
| `tools/servidor_web.py` | Servidor local con las cabeceras que exige la base del navegador |
| `web/_headers` · `vercel.json` | Las mismas cabeceras para Netlify y Vercel |
| `test/utiles.dart` | Ayudas de tests (incluye por qué no se usa `pumpAndSettle`) |
| `docs/DOCUMENTACION_TECNICA.md` | Cómo está hecho cada componente y por qué |
| `android/app/src/main/AndroidManifest.xml` | Permisos y nombre visible |
| `ios/Runner/Info.plist` | Permisos de ubicación, cámara y galería |

---

## 15. Créditos

Seminario de grado · SENA / Tecnoparque · 2026
