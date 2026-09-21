# Documentación técnica — Red Nacional de Cacao

Este documento explica **cómo está hecha** la aplicación y **por qué se hizo
así**. El [README](../README.md) cuenta qué hace; aquí se cuenta cómo funciona
por dentro, decisión por decisión.

Está pensado para alguien que va a trabajar en el código y necesita entender las
partes donde es fácil equivocarse.

---

## 1. La decisión que manda sobre todas las demás

En la finca **no hay señal**. Todo lo que sigue —la base local, los UUID, el
borrado suave, el motor de sincronización, hasta el diseño de la identidad—
existe por esa sola razón.

De ahí salen tres reglas que no se negocian:

1. **La base local es la fuente de verdad.** La nube es respaldo y puente entre
   dispositivos, nunca el origen del dato.
2. **La interfaz nunca espera al servidor.** Guarda en local y sigue. Si hay red,
   la sincronización ocurre por detrás.
3. **Nada se borra físicamente.** Un teléfono que estuvo un mes sin señal tiene
   que poder enterarse de que algo se borró, y un `DELETE` no deja rastro que
   propagar.

Si alguna vez alguien propone "que la app consulte el servidor para mostrar los
lotes", ahí se rompe todo el diseño.

---

## 2. Capa de datos

### 2.1 Tecnología

**Drift sobre SQLite** (`drift` + `drift_flutter`). Drift genera código a partir
de las definiciones en Dart, así que las consultas se escriben con tipos y los
errores salen al compilar, no en el celular del productor.

Los archivos `*.g.dart` son generados. Después de tocar tablas o DAOs:

```bash
dart run build_runner build
```

### 2.2 El mixin `SyncColumns`

Está en `lib/data/local/tables.dart` y es el corazón del modelo. Todas las
tablas de datos lo incluyen, así que todas tienen las mismas siete columnas:

| Columna | Decisión detrás |
|---|---|
| `id` | **UUID generado en el dispositivo**, no autoincremental. Dos teléfonos sin señal pueden crear registros a la vez sin chocar al sincronizar. Un `id` autoincremental haría imposible el offline real. |
| `createdAt` / `updatedAt` | Reloj del teléfono. Sirven para ordenar localmente, **nunca** para comparar entre dispositivos. |
| `deletedAt` | Borrado suave. Es lo que permite propagar una eliminación. |
| `serverUpdatedAt` | El sello que puso el servidor. **Este sí** es comparable entre dispositivos. |
| `syncStatus` | `pending` · `synced` · `error`. Estado **local**: nunca viaja al servidor. |
| `syncError` | Motivo del último fallo de subida, para no tener que adivinar. |

Un detalle que cuesta ver: **`updatedAt` y `serverUpdatedAt` son relojes
distintos a propósito**. Si se comparara el reloj de un teléfono con el de otro,
bastaría un celular con la hora mal puesta para corromper la sincronización de
todos.

### 2.3 Tablas

```
asociaciones ─< productores ─< fincas ─< lotes ─┬─< actividades_agricolas
                                                 ├─< cosechas
                                                 └─< diagnosticos
```

Más dos tablas de servicio que no son datos del productor:

- **`sesion`** — una sola fila. La identidad de esta instalación, la cuenta y su
  estado. Ver el capítulo 5.
- **`sync_meta`** — el cursor de descarga por entidad: `lastSyncAt` y
  `lastSyncId`.

### 2.4 Migraciones

| Versión | Qué introdujo | Por qué |
|---|---|---|
| v1 | Modelo inicial | Captura local pura |
| v2 | `serverUpdatedAt`, `syncError`, `usuarioId`, tablas `sesion` y `syncMeta` | Preparar la sincronización |
| v3 | `lastSyncId` | El cursor pasó a ser compuesto (ver 4.3) |
| v4 | `correo`, `descargaInicial` | Cuentas y bloqueo de la primera descarga |
| v5 | `correoConfirmado` | La confirmación de correo del servidor |
| v6 | `tipoDocumento`, `numeroDocumento` | La identificación que pide el SENA |
| v7 | `tokenNube` | La sesión del servidor, para no pedir Google en cada arranque |

**Todas son aditivas**: agregan columnas o tablas, nunca borran datos ni cambian
identificadores. Las migraciones v1→v2 y v2→v3 se probaron instalando la app
nueva sobre una instalación real con datos, no solo en tests.

### 2.5 Borrado suave y cascadas

Hay **dos** cascadas distintas, y confundirlas rompe la sincronización:

**Cascada local** (`borrarLoteEnCascada`, `borrarFincaEnCascada`,
`borrarProductorEnCascada`) — la dispara el usuario. Marca `deletedAt` en el
padre y en todos los descendientes, **dejando todo en `pending`**, porque ese
borrado tiene que viajar al servidor.

**Cascada remota** (`aplicarBorradoRemotoDeFinca`, `aplicarBorradoRemotoDeLote`)
— la dispara una fila que llegó del servidor. Marca lo mismo, pero deja los
hijos en **`synced`**. La diferencia es crítica: este teléfono no decidió ese
borrado, solo lo está reflejando. Si quedaran `pending`, subiría un borrado que
nunca originó y podría ganar un conflicto por accidente.

Ambas corren dentro de una transacción y llevan `WHERE deleted_at IS NULL`, lo
que las hace idempotentes: repetir el borrado no cambia la fecha original.

---

## 3. DAOs y repositorios

**DAOs** (`lib/data/daos/daos.dart`) — las consultas. Hay uno por área:
`ProductoresDao`, `FincasDao`, `LotesDao`, `RegistrosDao` (las tres hojas) y
`SyncDao` (identidad, cuenta y cursores).

Dos convenciones que se repiten en todos:

- Toda consulta de lectura filtra `deletedAt.isNull()`.
- Toda escritura refresca `updatedAt` y devuelve la fila a `pending`.

**Repositorios** (`lib/data/repositories/`) — la fachada que usa la interfaz.
`PerfilRepository` (productor, finca, lotes) y `LoteRepository` (labores,
cosechas, diagnósticos). La UI **no** habla con los DAOs: así, cuando entró la
sincronización, solo hubo que tocar esta capa.

Aquí viven también dos cálculos que a propósito **no** se guardan en la base:

- `edadEnAnios(fechaSiembra)` — la edad se calcula, no se almacena. Un número
  guardado se desactualiza solo.
- `areaTotal(lotes)` — suma de hectáreas.

---

## 4. Sincronización

Todo el motor está en `lib/data/sync/sync_service.dart`. Es la parte más
delicada del proyecto.

### 4.1 El contrato con el backend

`ApiRemota` es una interfaz, y eso no es decoración: permite que los tests
corran contra `ApiRemotaFalsa` —un servidor en memoria, con cuentas y aislamiento
entre usuarios— sin tocar la red, y que la app real use `ApiAppsScript`. Cambiar
de una a otra no toca la interfaz, ni los repositorios, ni los DAOs, ni el
`SyncService`.

En `main.dart`, si hay servidor configurado se usa Apps Script; si no, el doble. La app
funciona igual en los dos casos.

### 4.2 El ciclo

Una pasada de `sincronizar()` recorre las entidades **en orden de dependencia**:

```
productores → fincas → lotes → actividades · cosechas · diagnósticos
```

Y para cada una hace **push y luego pull**:

```
PUSH   filas pending → subir() → el servidor sella updated_at
                    → serverUpdatedAt ← sello, syncStatus ← synced

PULL   cursor (updated_at, id) → descargar ordenado por esa clave
                              → aplicar fila por fila → guardar cursor
```

El orden padres→hijos no es cosmético: si un lote llegara al servidor antes que
su finca, la llave foránea lo rechazaría.

### 4.3 El cursor compuesto `(updated_at, id)`

**Este es el punto donde más fácil se rompe algo.**

La primera versión usaba solo `updated_at`. Falló de dos maneras distintas:

1. Con cursor `>=` y páginas llenas de filas ya vistas, el bucle pedía la misma
   página **para siempre**. El test de paginación colgó la suite entera.
2. El primer parche (recordar los ids ya vistos) cortaba la descarga demasiado
   pronto: bajaba 1 de 3 filas.

La solución correcta es **paginación por clave**: se pide lo estrictamente
posterior a `(updated_at, id)`. Con eso el avance está garantizado aunque varias
filas compartan el mismo sello, que es exactamente lo que pasa cuando el
servidor escribe varias filas en el mismo segundo.

El cursor se guarda con **sus dos componentes** en `sync_meta`. Guardar solo el
tiempo obliga a elegir entre repetir filas o perderlas.

### 4.4 Garantías del ciclo

- **Idempotencia** — si `serverUpdatedAt` local coincide con el sello recibido,
  la fila se ignora. Aplicar dos veces lo mismo no cambia nada.
- **Descarga interrumpida** — el cursor se guarda **al final**. Si algo falla, la
  excepción sale antes y la próxima pasada repite el tramo.
- **Fallo de red** — la fila sigue `pending` y la cinta del inicio la cuenta.
  Nunca se pierde nada.
- **Aplazamiento** — si llega un hijo cuyo padre no está, no se aplica y **el
  cursor no avanza más allá de esa fila**.

### 4.5 Las cinco reglas de conflicto

Están implementadas, no son teoría:

1. **Push antes que pull.** Por eso **gana el último en sincronizar**, no el
   último en editar. La regla no depende del reloj de ningún teléfono.
2. **Una fila remota nunca pisa una fila local `pending`.** Gana lo local y el
   choque queda anotado como `Conflicto` en el `SyncResult`.
3. **Hijo sin padre** → se aplaza, se anota (`motivoPadreAusente`), el cursor no
   avanza. La siguiente pasada lo reintenta.
4. **Hijo vivo con padre borrado** → entra **ya borrado**
   (`motivoPadreBorrado`). Aplazarlo lo dejaría atascado para siempre, porque el
   padre no va a revivir, y bloquearía el cursor de todos los que vienen detrás.
5. **Padre borrado en el servidor** → cascada remota, hijos en `synced`. Si algún
   hijo tenía cambios locales, se descartan y se anota
   (`motivoPadreBorradoRemoto`).

### 4.6 `PlanEntidad`: por qué no hay seis copias del algoritmo

Cada entidad aporta cuatro funciones —`pendientes`, `marcarSincronizado`,
`aplicar`, `selloDe`— y el ciclo común vive **una sola vez**. Las tres hojas
(actividades, cosechas, diagnósticos) comparten además `_planHoja`, porque sus
reglas son idénticas.

Es una estructura de funciones y no una jerarquía de clases genéricas a
propósito: la parte donde viven los bugs no se duplica, y lo específico de cada
tabla queda a la vista. Los mapeadores siguen siendo clases separadas y legibles.

### 4.7 Los mapeadores

Uno por entidad, en `lib/data/sync/mapeador_*.dart`. Traducen fila local ↔ fila
remota. Tres cosas **no** viajan al servidor:

- `sync_status` y `sync_error` — son estado local. Si viajaran, una descarga
  pisaría el estado del dispositivo.
- `updated_at` — lo sella el servidor, ignorando lo que mande el cliente.

---

## 5. Identidad y cuentas

La parte más sutil del proyecto. Hay **cinco** identificadores y tres se
parecen:

| Identificador | Qué representa | ¿Cambia? |
|---|---|---|
| `id` de cada fila | La fila en sí | **Nunca** |
| `sesion.usuarioId` | **La instalación** (este teléfono) | Nunca |
| `sesion.authUid` | **La cuenta** de Google (su `sub`) | Solo al entrar con otra |
| `productores.usuarioId` (local) | Dueño local = la instalación | — |
| `productores.usuario_id` (remoto) | Dueño remoto = la cuenta | — |

### 5.1 Por qué la instalación y la cuenta son cosas distintas

Porque la app tiene que funcionar **antes** de que exista una cuenta. En el
primer arranque, sin red, se genera un UUID local y ya se puede registrar la
finca. La cuenta llega después, si llega.

La traducción entre "dueño local" y "dueño remoto" ocurre **solo en los
mapeadores**. Eso es lo que permite que otro teléfono descargue las filas y las
**adopte con su propia identidad de instalación**, sin reescribir un solo UUID ni
una sola clave foránea.

```
Teléfono A                        Teléfono B
instalación A                     instalación B
      └──────── cuenta X ─────────────┘
                   │
        Apps Script / Sheets
```

### 5.2 Vincular, nunca registrar

**Regla dura del código.** Si existe una sesión anónima con datos, la cuenta se
vincula con `updateUser(email, password)`, que **conserva el mismo
`auth.uid()`**. Los datos ya subidos siguen perteneciendo a esa cuenta y las
políticas de seguridad siguen encajando sin tocar una fila.

`signUp()` crearía un usuario **nuevo**, con otro uid, y dejaría los datos
anteriores huérfanos: invisibles para el RLS, imposibles de recuperar.

### 5.3 La identidad la da Google

Hasta septiembre de 2026 la cuenta era de correo y contraseña, con confirmación
por correo activada, y la app tenía un tercer estado: "pendiente de confirmar".
Al pasar a Google ese estado desapareció, porque la cuenta llega verificada.

Lo que hay ahora, en orden:

1. La app pide la cuenta a Google y recibe un **token de identidad** (un JWT
   firmado que dura una hora).
2. El servidor le pregunta a Google si el token es válido y **comprueba que sea
   de esta app** (`aud` contra la lista de identificadores). Sin esa
   comprobación, el token de cualquier aplicación de Google serviría para
   entrar: es la línea que sostiene la seguridad.
3. El servidor devuelve una **sesión propia de 90 días**, que se guarda en
   `sesion.tokenNube`. Sin ese cambio, la sincronización empezaría a fallar
   sola al cabo de una hora y sin motivo visible.

El `sub` de Google pasa a ser el dueño de cada fila: ocupa exactamente el lugar
que tenía el `auth.uid()` de Supabase, así que el resto del diseño no cambió.

**Lo que sí cambió de fondo:** ya no hay sesión anónima. Antes se respaldaba
aunque nadie hubiera entrado; ahora **sin cuenta no hay servidor**. Lo anotado
antes de entrar no se pierde: queda `pending` y sube con la primera
sincronización, ya a nombre de la cuenta.

## 6. El servidor

### 6.1 El esquema

`backend/Codigo.gs` crea las siete hojas de datos más la de sesiones, con sus
encabezados, al ejecutar `instalar()` una vez. Es **idempotente**: se puede
volver a ejecutar sin borrar nada, porque solo crea lo que falte.

Las columnas se leen **por orden**, no por nombre, así que renombrar o mover una
columna en la hoja rompe la sincronización. Está avisado en `backend/README.md`.

Tres decisiones que no son obvias:

1. **No existen `sync_status` ni `sync_error`** en el servidor.
2. **`updated_at` lo escribe siempre un trigger** con `now()`, ignorando al
   cliente.
3. **Todas las fechas son `timestamptz`, nunca `date`.** Con `date`, un valor
   local con hora volvería a medianoche al bajar, la fila se vería "cambiada" en
   cada ciclo y se produciría un bucle de escrituras infinito.

### 6.2 Seguridad por fila (RLS)

Activo en las siete tablas. `productores` filtra por `usuario_id = auth.uid()`;
las demás llegan por *join* hasta el productor. El `with check` impide además
crear filas a nombre de otro.

Resultado: un usuario **no puede leer ni modificar** lo de otro, y la misma
cuenta **sí** puede entrar desde varios dispositivos.

La app usa **solo la llave publicable**, que es pública por diseño: lo que
protege los datos es el RLS. La `service_role` no está en el código ni debe
estarlo nunca.

---

## 7. Interfaz

### 7.1 Diseñada para el campo

Todo es grande a propósito: texto de 17 para arriba, botones de 62 px, campos con
22 px de relleno. Se usa de pie, al sol, con las manos sucias.

Y hay poco texto: cada pantalla dice lo justo. El trato es de **usted**, que es
como se habla en el campo.

### 7.2 Estructura

- **`cascaron_screen.dart`** — el armazón. Decide qué mostrar según el estado
  (bienvenida, recuperación o la app), monta la barra inferior y el botón central
  de *Anotar*, y dispara la sincronización al arrancar y cuando vuelve la señal.
- **`inicio_screen.dart`** — la pantalla de todos los días: finca, cinta de
  sincronización, tres indicadores y las tarjetas de lote con *última labor* y
  *kg del año*. Responde a "cómo va mi finca", no a "quién soy yo".
- **`perfil_screen.dart`** — los datos de identidad, que se leen una vez, y la
  tarjeta de cuenta con sus tres estados.
- **`lote_detalle_screen.dart`** — tres pestañas (Labores, Cosechas, Estado) y el
  borrado del lote con confirmación.

### 7.3 Detalles de diseño con intención

- **La mazorca** (`widgets/mazorca.dart`) está dibujada con `CustomPainter`, no
  es una imagen: se ve nítida a cualquier tamaño y no engorda la app.
- **La paleta** (`PaletaCacao`) sale del cultivo: café de grano tostado, verde de
  hoja, naranja de mazorca madura, crema de pulpa. El texto va en café muy
  oscuro, no en negro puro: sobre la crema, el negro corta demasiado.
- **El color dice algo**: verde lo que se le hace al lote, naranja lo que sale de
  él. El botón de anotar cambia de color según la pestaña.
- **Los estados vacíos** nunca son solo un texto gris: explican qué falta y
  traen el botón para hacerlo.

---

## 7.4 La versión web

El mismo proyecto compila a navegador (`flutter build web`). No es una copia:
es el mismo código, la misma base de datos y la misma sincronización.

Lo único que cambia es **dónde vive SQLite**. En el teléfono es un archivo; en el
navegador es el mismo SQLite compilado a WebAssembly, y hace falta:

1. Servir `sqlite3.wasm` y `drift_worker.js` junto a la aplicación (están en
   `web/`, y `flutter build web` los copia).
2. Pasarle a Drift esas rutas — ver `_conexion()` en `database.dart`.
3. **Servir la página con el origen aislado**: `Cross-Origin-Opener-Policy:
   same-origin` y `Cross-Origin-Embedder-Policy: require-corp`.

El punto 3 es el que más cuesta descubrir: sin esas cabeceras el navegador no
habilita `SharedArrayBuffer`, Drift cae en una implementación de respaldo y, si
el navegador tampoco soporta *dedicated workers* dentro de *shared workers*, la
apertura de la base **se cuelga sin lanzar ningún error**. La pantalla queda en
negro y no hay excepción que atrapar.

Por eso hay un `tools/servidor_web.py` que manda esas cabeceras, y por eso están
configuradas para Netlify (`web/_headers`) y Vercel (`vercel.json`).

Verificado: arranca en Brave/Chrome de escritorio, abre la base y completa la
inicialización del servidor. **No** se ha probado a fondo la interfaz completa en
navegador ni en Safari de iPhone.

### Qué es y qué no es

La versión web sirve para **mostrar** la aplicación sin instalar nada y, más
adelante, para el panel del técnico. No sustituye a la app del productor: el
almacenamiento del navegador lo puede desalojar el propio navegador cuando le
falta espacio —Safari en iOS es especialmente agresivo—, mientras que el archivo
SQLite del teléfono es del sistema operativo y no se borra solo. Para alguien que
anota tres cosechas sin señal, esa diferencia lo es todo.

## 8. Estrategia de pruebas

**121 tests**, todos en verde. Se ejecutan con `flutter test`.

### 8.1 Por qué un doble en memoria

`ApiRemotaFalsa` no es un *mock* superficial: es un servidor con cuentas,
propiedad de filas y aislamiento entre usuarios, con su propio reloj monótono
para sellar. Eso permite probar sin red cosas que de otro modo exigirían dos
teléfonos y un servidor: sincronización A↔B, conflictos, aislamiento entre
cuentas, confirmación de correo.

La separación **servidor / cliente** dentro del doble es lo que permite simular
dos instalaciones distintas hablando con el mismo backend.

### 8.2 Dos trampas de los tests de widgets

Están documentadas en `test/utiles.dart` porque cuestan horas si no se saben:

1. **Nunca `await` de un stream de Drift dentro de `testWidgets`** sin
   `tester.runAsync`. El reloj falso del test no mueve el asincronismo real de la
   base y el test se cuelga para siempre.
2. **Nunca `pumpAndSettle`** con un indicador de carga en pantalla: es una
   animación infinita y nunca se estabiliza.

### 8.3 Qué se verificó contra el servidor real

En emulador Android, contra el proyecto real: creación del esquema, sesión
anónima, subida de productor, finca y lote con sello de PostgreSQL, borrado
suave viajando como `deleted_at`, y vinculación de cuenta con correo y
contraseña.

La recuperación completa en un segundo teléfono está implementada y cubierta por
tests contra el doble; **falta dejar registro formal de esa prueba con dos
teléfonos reales**.

---

## 9. Problemas reales encontrados y cómo se resolvieron

Esta sección existe porque cada uno de estos costó tiempo y podría volver.

| Problema | Causa | Solución |
|---|---|---|
| La suite de tests se colgaba | Bucle infinito de paginación: cursor `>=` pidiendo la misma página | Paginación por clave `(updated_at, id)` |
| Se bajaba 1 de 3 filas | El primer parche cortaba la descarga demasiado pronto | Misma solución de arriba, bien hecha |
| Filas con el mismo sello se perdían | En Dart, dos `DateTime` del mismo instante **no son iguales** si uno es UTC y el otro local | `isAtSameMomentAs` en vez de `==` |
| Tests colgados sin error | `await` de un stream de Drift bajo reloj falso | `tester.runAsync` (helpers en `utiles.dart`) |
| "A Timer is still pending" | Timers de Drift y del SnackBar vivos al terminar | Desmontar el árbol y avanzar el reloj |
| Gradle no compilaba | Carpeta del NDK a medio descargar | Borrar el resto y dejar que se baje solo |
| Chips ilegibles | `labelStyle` sin color en el tema: Material dejaba de resolverlo | Color explícito para chip normal y seleccionado |
| Desbordamiento de 12 px | Relleno propio de `BottomAppBar` | `padding: EdgeInsets.zero` |
| El degradado no pintaba | `DecoratedBox` sin hijo no toma tamaño en `flexibleSpace` | `SizedBox.expand` |
| "La sincronización no funciona" | `mailer_autoconfirm = false` con un correo inventado | Confirmar con un correo real + avisar en la app |

---

## 10. Limitaciones conocidas

- **Las fotos no salen del teléfono.** Al servidor viaja la ruta, no la imagen.
  Si el productor cambia de equipo, los diagnósticos llegan sin foto. Falta
  Google Drive.
- **No hay recuperación de contraseña.** Necesita enlaces profundos hacia la app
  y configuración de la URL de redirección.
- **Los límites de Apps Script**: 90 minutos de ejecución al día en cuentas
  gratuitas de Gmail, y las escrituras se hacen de a una con candado. Con
  decenas de productores va bien; con cientos, se sentiría lento. Y
  es solo para pruebas. Para usuarios reales hace falta un SMTP propio.
- **iOS nunca se ha compilado.** La configuración y los permisos están puestos,
  pero falta un Mac con Xcode para saber si algo hay que ajustar.
- **La APK se firma con la llave de depuración.** Sirve para instalar y probar;
  publicar exigiría una llave propia.

---

## 11. Por dónde seguir

Ordenado por lo que más valor da:

1. **Dejar registro de la prueba con dos teléfonos reales** — es lo único que
   falta para cerrar la Fase 1 sin asteriscos.
2. **Llaves de firma propias** para Android, registrando la nueva huella SHA-1
   en Google: hoy se firma con las de depuración.
3. **Fotos en Google Drive.**
4. **Publicar la app en Google**, para que pueda entrar cualquier productor y no
   solo los correos de la lista de prueba.
5. **Panel web para técnicos** — el navegador es el sitio natural para ver muchos
   productores. Ojo: exige otro modelo de permisos, porque hoy el RLS aísla a
   cada productor.

Y lo que **no** haría sin hablar antes con el SENA: agregar módulos nuevos. Que
la priorización de la Fase 2 salga de ellos.
