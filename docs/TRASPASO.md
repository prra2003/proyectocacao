# Traspaso al seminario 2027-1

Para el equipo que recibe Cacaiva y la continúa. Este documento no repite el
README: dice **qué hay que recibir además del código**, qué quedó a medias y
dónde se engancha lo que le toca al seminario siguiente.

**Se entrega:** versión **1.7.0** (compilación 16), noviembre de 2026.
`flutter analyze` sin avisos y 230 pruebas en verde. La rama `main` es lo que
está publicado en la página y lo que tienen instalado los productores.

---

## 1. El primer día

1. Clonar el repositorio y seguir la sección **Instalación y ejecución** del
   [README](../README.md). Antes de tocar nada, correr `flutter test`: si las
   230 pruebas no pasan en su máquina, el problema es de la instalación, no del
   código.
2. Leer [`docs/MODELOS.md`](MODELOS.md) —arquitectura, IDEF0 y entidad-relación—
   y la sección **Estado del proyecto** del README.
3. Leer [`docs/GUIA_DEL_EQUIPO.md`](GUIA_DEL_EQUIPO.md): cómo se trabaja con
   ramas y *pull requests*. `main` está protegida: solo entra por un *pull
   request* con las pruebas en verde.

---

## 2. Lo que hay que recibir además del código

El código está en GitHub. **Todo lo de esta tabla no**, y sin ello el equipo
nuevo puede leer el proyecto pero no publicarlo ni actualizar la app de nadie.

| Qué | Dónde vive | Qué pasa si se pierde | Cómo se traspasa |
|---|---|---|---|
| **Llave de firma de Android** (`cacao-release.jks` y su `key.properties`) | En el computador de quien compila, **fuera del repositorio** | **Nadie podrá volver a actualizar la app** en los teléfonos donde ya está instalada: Android solo acepta una actualización firmada con la misma llave. Habría que desinstalar en cada teléfono y los productores perderían lo que no hayan sincronizado. | En persona o por un gestor de contraseñas. **Nunca** por GitHub, chat o correo sin cifrar: con ella cualquiera firma una app que el teléfono acepta como Cacaiva. Hacer una copia de respaldo **antes** de entregar. |
| **Repositorio** `prra2003/proyectocacao` | GitHub (público) | — | Agregar a los nuevos como colaboradores, o transferir el repositorio. |
| **Hoja de cálculo y Apps Script** (el servidor) | En una cuenta de Google | Los teléfonos dejan de sincronizar | Compartir la hoja y el script como **editor** con el equipo nuevo. |
| **Proyecto de Google Cloud** "Red Cacao" (los dos clientes de OAuth: Android y Web) | En la misma cuenta de Google | Nadie puede entrar con Google | Agregar al equipo nuevo como propietario del proyecto. |
| **Vercel**, equipo `cacao3`, proyecto `redcacao` (la página) | Vercel | No se puede publicar la página | Invitar al equipo nuevo al equipo `cacao3`. |
| **Canal de YouTube** de los videos de Ayuda | YouTube | Los videos de la pantalla de Ayuda dejan de cargar | Agregar administradores al canal. |
| **Correos de administrador del SENA** | Lista `ADMINISTRADORES` en `backend/Codigo.gs` | — | Actualizar la lista con los correos del equipo y del instructor. |

> **Antes de entregar, anotar en esta tabla con qué cuenta está cada cosa.**
> La guía del servidor ya lo advertía: todo queda amarrado a la cuenta de
> Google con la que se creó. Si es una cuenta personal de alguien que se va, el
> traspaso es más largo; si se puede, conviene moverlo a una cuenta del SENA o
> del equipo.

---

## 3. Las direcciones de la página

Hay **cuatro** direcciones que sirven la versión web, y solo una es la oficial:

| Dirección | Qué es |
|---|---|
| **https://redcacao.vercel.app** | **La oficial.** La que se reparte y la que va en Google |
| `web-rust-tau-65.vercel.app` · `redcacao-cacao3.vercel.app` | Heredadas, del mismo proyecto; sirven lo mismo |
| `proyectocacao.vercel.app` | **Una copia vieja (1.5.0), en otra cuenta de Vercel.** No se actualiza con nada de lo de aquí |

Publicar siempre con `tools/publicar_web.sh`: compila, sube, apunta las tres
direcciones del proyecto y comprueba que las tres hayan quedado en la versión
nueva. Un `vercel --prod` a secas deja la oficial clavada en la versión
anterior sin avisar —pasó, y la página estuvo 38 días atrás—.

---

## 4. Pendiente de este seminario

Lo que figura en 🟡 o ⏳ en la tabla **Estado del proyecto** del README, más
estos tres puntos de operación:

1. **Registrar `https://redcacao.vercel.app` en Google** (Google Cloud → Google
   Auth Platform → Clientes → *Cacao Web* → Orígenes autorizados de
   JavaScript). En la oficial, el ingreso con Google da `Error 400:
   origin_mismatch`. La guía del servidor mandaba registrar
   `proyectocacao.vercel.app` —ya está corregida—, así que lo más probable es
   que esa copia vieja sea la única registrada. La app de Android no se afecta:
   usa su propio cliente.
2. **Atar `redcacao.vercel.app` al proyecto** en Vercel (proyecto `redcacao` →
   Settings → Domains). Así sigue sola a cada publicación y el script deja de
   ser indispensable para esa parte.
3. **Decidir qué hacer con `proyectocacao.vercel.app`**: actualizarla o darla
   de baja. Mientras exista, hay una versión vieja de la app en internet.

---

## 5. Lo que le toca a 2027-1, y dónde se engancha

El documento del seminario reparte los módulos así: lo productivo en 2026-2
(hecho), y la asistencia técnica y lo comercial en 2027-1. Ninguno de los
cuatro módulos nuevos parte de cero:

### Asistencia técnica especializada

- **Ya hay:** los **diagnósticos** del estado del cultivo (floración, cuajado,
  maduración…) por lote, con fecha y notas; la **nota de BPA** en cada
  registro; y en el servidor, el **rol de administrador del SENA**, que puede
  ver la información de todos y no escribir nada.
- **Falta:** la pantalla del panel para el técnico. Hay tres propuestas de
  diseño de esa pantalla fuera del repositorio (carpeta `cacao_admin/`, junto a
  este proyecto), sin conectar a datos.

### Consulta de precios del cacao

- **Ya hay:** el **costo por kilo** (en prueba) recibe un precio de venta
  para calcular la ganancia, pero ese precio se escribe a mano y **no se
  guarda**. Es el lugar natural para enchufar una tabla de precios.
- **Falta:** de dónde salen los precios y dónde se guardan. Si es una tabla
  nueva, ver la regla de la sección 6.

### Conexión entre productores y compradores

- **Falta todo.** Va a necesitar entidades nuevas (comprador, oferta o
  similar). Es la primera vez que la información de un productor la vería
  alguien que no es él ni la Red: conviene revisar la política de privacidad
  antes de diseñarlo.

### Trazabilidad del producto

- **Ya hay** buena parte de la base: cada lote tiene un **código único**, un
  **punto GPS** que solo se acepta dentro del perímetro de su finca —se agregó
  justamente porque es lo que pide el comprador que exporta—, y cada cosecha
  queda con fecha, kilos y tipo de producto, colgada de su lote.
- **Falta:** para la aplicación de productos (control fitosanitario), los
  datos que exige el ICA y que hoy no tienen campo propio: **registro ICA**
  del producto, **ingrediente activo**, **lote del envase** y **periodo de
  carencia**. Por ahora la nota de BPA le pide al productor anotarlos en
  Observaciones. Y faltaría ligar cada cosecha con las aplicaciones que se le
  hicieron al lote en el periodo de carencia anterior.

---

## 6. Reglas que no hay que romper

Están explicadas en el README y en la documentación técnica; aquí, solo la
lista para no olvidarlas.

- **Offline-first.** La interfaz nunca espera al servidor. Todo se guarda
  primero en el teléfono.
- **El identificador lo crea el teléfono** (UUID). Nunca un número que asigne
  el servidor.
- **Nunca se borra una fila**: se marca `deleted_at`. Un borrado de verdad no
  llega a los otros teléfonos.
- **Una tabla nueva** lleva el mixin `SyncColumns`, se agrega a `TABLAS` en
  `backend/Codigo.gs` (y se vuelve a ejecutar `instalar()`), se dibuja en
  `tools/generar_modelos.py` y sube la versión del esquema en
  `lib/data/local/database.dart`.
- **El plazo de 7 días** para corregir un registro es lo que hace confiables
  los reportes del técnico. No se salta desde la app.
- **La versión siempre sube** antes de repartir una APK, o el teléfono
  rechaza la instalación. Ver [`docs/GUIA_ACTUALIZAR_APK.md`](GUIA_ACTUALIZAR_APK.md).
- **Ninguna llave ni secreto va al repositorio.** El repositorio es público.
