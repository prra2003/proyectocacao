# Lo que usted tiene que hacer — paso a paso

Guía para dejar el servidor funcionando en Google. Son **tres partes** y en
total toma entre 30 y 45 minutos.

Al final debe quedar con **tres datos** que me tiene que pasar:

1. La dirección del servidor (termina en `/exec`).
2. El identificador de Android.
3. El identificador Web.

> **Antes de empezar, decida con qué cuenta de Google va a hacer todo.** Todo
> queda amarrado a esa cuenta: la hoja, el script y los permisos. Si es la suya
> personal y mañana entrega el proyecto, toca volver a hacerlo. Una cuenta del
> SENA o una del equipo es mejor. **Use la misma cuenta en las tres partes.**

---

# PARTE 1 · La hoja y el servidor

### 1.1 Crear la hoja

1. Entre a <https://sheets.google.com> con la cuenta que escogió.
2. Toque **En blanco** para crear una hoja nueva.
3. Arriba a la izquierda, donde dice *Hoja de cálculo sin título*, escriba:
   **Red Nacional de Cacao**

### 1.2 Abrir el editor del script

1. En el menú de arriba: **Extensiones → Apps Script**.
2. Se abre una pestaña nueva con un editor de código y algo como:
   ```
   function myFunction() {
   }
   ```
3. Seleccione todo eso (`Cmd + A`) y bórrelo.
4. Abra el archivo **`Codigo.gs`** que le pasé, copie **todo** su contenido y
   péguelo ahí.
5. Arriba a la izquierda, donde dice *Proyecto sin título*, escriba:
   **Servidor Cacao**
6. Guarde con `Cmd + S`.

### 1.3 Crear las hojas automáticamente

1. En la barra de arriba del editor hay una lista de funciones. Escoja
   **`instalar`**.
2. Toque **▷ Ejecutar**.
3. **La primera vez Google le pide permiso.** Aparece una ventana:
   - Toque **Revisar permisos**.
   - Escoja su cuenta.
   - Sale un aviso amarillo: *"Google no ha verificado esta aplicación"*.
     **Es normal**: la app es suya y no está publicada en ningún lado.
   - Toque **Configuración avanzada** (abajo a la izquierda).
   - Toque **Ir a Servidor Cacao (no seguro)**.
   - Toque **Permitir**.
4. Abajo del editor aparece un registro de ejecución. Debe decir algo como
   *"Listo: 8 hojas revisadas"*.

**Cómo saber si quedó bien:** vuelva a la pestaña de la hoja de cálculo. Abajo
deben verse 8 pestañas: `asociaciones`, `productores`, `fincas`, `lotes`,
`actividades_agricolas`, `cosechas`, `diagnosticos` y `_sesiones`. En
`asociaciones` deben aparecer las 5 asociaciones.

### 1.4 Publicar el servidor

1. En el editor del script, arriba a la derecha: botón azul **Implementar →
   Nueva implementación**.
2. Al lado de *Seleccionar tipo* hay un engranaje ⚙️. Tóquelo y escoja
   **Aplicación web**.
3. Llene así:
   - **Descripción:** `version 1`
   - **Ejecutar como:** **Yo (su correo)**
   - **Quién tiene acceso:** **Cualquier usuario**
4. Toque **Implementar**.
5. Copie la **URL de la aplicación web**. Es larga y **termina en `/exec`**.
   Guárdela en un archivo de texto; la necesito.

> **Ojo con esto:** "Cualquier usuario" no significa que los datos queden
> abiertos. Sin una sesión válida, el servidor no entrega nada. Es como tener
> la puerta de la calle abierta pero la de la casa con llave.

### 1.5 Comprobar que responde

Abra esa dirección `/exec` en el navegador. Debe ver:

```json
{"ok":true,"servicio":"Red Nacional de Cacao","version":1}
```

Si ve eso, la Parte 1 está lista. Si ve una página de error, avíseme y la
revisamos.

---

# PARTE 2 · La huella del celular (SHA-1)

Google necesita saber cuál app puede usar sus credenciales. Eso se prueba con
una "huella" del certificado con que se firma la app.

1. Abra la terminal.
2. Vaya a la carpeta de Android del proyecto:

   ```bash
   cd "/Users/delta/universidad/seminario de grado/cacao_app/android"
   ```

3. Pida el reporte de firmas:

   ```bash
   ./gradlew signingReport
   ```

4. Se demora un rato. Al final imprime varios bloques. Busque el que dice
   **`Variant: debug`** y dentro de él la línea que empieza por **`SHA1:`**.
   Se ve así:

   ```
   SHA1: A1:B2:C3:D4:E5:F6:...:99
   ```

5. Copie esa línea completa, con los dos puntos incluidos, y guárdela junto con
   la dirección del servidor.

> Esa huella es la de las llaves de **prueba**. Cuando vayan a publicar la app
> de verdad habrá que generar llaves propias y registrar también **esa** huella,
> o el inicio de sesión dejará de funcionar en los celulares de la gente.

---

# PARTE 3 · Los permisos en Google Cloud

Entre a <https://console.cloud.google.com> con **la misma cuenta**.

### 3.1 Crear el proyecto

1. Arriba, al lado del logo, hay un selector de proyecto. Tóquelo.
2. **Proyecto nuevo**.
3. Nombre: **Red Cacao**. Toque **Crear**.
4. Espere a que termine y **asegúrese de que el selector de arriba diga
   "Red Cacao"**. Este es el error más común: crear las credenciales en otro
   proyecto sin darse cuenta.

### 3.2 Configurar la pantalla de permisos

1. En el buscador de arriba escriba **Google Auth Platform** (antes se llamaba
   *Pantalla de consentimiento de OAuth*) y entre.
2. Toque **Comenzar** o **Configurar**.
3. Llene:
   - **Nombre de la aplicación:** `Red Nacional de Cacao`
   - **Correo de asistencia:** el suyo
   - **Tipo de usuario / Audiencia:** **Externo**
   - **Datos de contacto:** su correo
4. Acepte las condiciones y termine.
5. Entre a la sección **Público** o **Audiencia**. Ahí abajo hay **Usuarios de
   prueba**. Toque **Agregar usuarios** y ponga:
   - su correo,
   - el de Quice,
   - el de cualquier persona que vaya a probar la app.

> **Esto es importante:** mientras la app esté en modo *Prueba*, **solo esos
> correos pueden iniciar sesión**. Si un cacaotero intenta entrar con un correo
> que no esté en la lista, Google lo rechaza. Caben 100 correos. Cuando quieran
> abrirlo a todo el mundo hay que publicar la app, y eso Google lo revisa.

### 3.3 Crear el identificador de Android

1. En el menú, **Clientes** (o **Credenciales**).
2. **Crear cliente** → **Tipo de aplicación: Android**.
3. Llene:
   - **Nombre:** `Cacao Android`
   - **Nombre del paquete:** `com.redcacao.cacao_app`
     *(cópielo exacto, sin espacios)*
   - **Huella digital del certificado SHA-1:** la que sacó en la Parte 2
4. **Crear**.
5. Copie el **ID de cliente**. Termina en `.apps.googleusercontent.com`.

### 3.4 Crear el identificador Web

1. Otra vez **Crear cliente** → **Tipo de aplicación: Aplicación web**.
2. Llene:
   - **Nombre:** `Cacao Web`
   - En **Orígenes autorizados de JavaScript**, toque **Agregar URI** y ponga
     estos dos, uno por uno:
     - `https://proyectocacao.vercel.app`
     - `http://127.0.0.1:8099`
       *(este es el servidor local con el que probamos la versión web)*
3. **Crear**.
4. Copie el **ID de cliente**.

> Aparece también un **"Secreto del cliente"**. **Ese no me lo mande y no lo
> suba a GitHub.** Los identificadores sí se pueden compartir; el secreto no.

### 3.5 Pegar los identificadores en el script

1. Vuelva al editor de Apps Script.
2. Arriba del archivo están estas líneas:

   ```javascript
   var CLIENTES_AUTORIZADOS = [
     'PEGUE-AQUI-EL-ID-DE-ANDROID.apps.googleusercontent.com',
     'PEGUE-AQUI-EL-ID-WEB.apps.googleusercontent.com',
   ];
   ```

3. Reemplace cada texto por el identificador que copió. Deje las comillas.
4. Guarde con `Cmd + S`.
5. **Vuelva a publicar:** **Implementar → Administrar implementaciones** →
   el lápiz ✏️ → **Versión: Nueva versión** → **Implementar**.

> **Este paso se olvida siempre.** Si no vuelve a publicar, la dirección sigue
> sirviendo el código viejo y va a parecer que los identificadores no quedaron.
> La dirección `/exec` **no cambia**, sigue siendo la misma de antes.

---

# Lo que me tiene que pasar al final

```
Dirección del servidor: https://script.google.com/macros/s/..../exec
ID de Android:          ........apps.googleusercontent.com
ID Web:                 ........apps.googleusercontent.com
```

Con eso yo hago el lado de Flutter: el "Entrar con Google" y el reemplazo de
Supabase.

---

# Si algo sale mal

| Lo que ve | Qué pasó |
| --- | --- |
| *"Google no ha verificado esta aplicación"* | Normal. Configuración avanzada → Ir a Servidor Cacao. |
| *"Falta la hoja X. Ejecute instalar()"* | No corrió `instalar`, o lo corrió en otra hoja. |
| La dirección `/exec` pide iniciar sesión | En la publicación quedó *Solo yo*. Vuelva a 1.4 y ponga **Cualquier usuario**. |
| *"Se produjo un error en el script"* al abrir `/exec` | El código quedó pegado a medias. Bórrelo y péguelo completo otra vez. |
| No aparece **Aplicación web** al implementar | No tocó el engranaje ⚙️ de *Seleccionar tipo*. |
| `./gradlew` dice *permission denied* | Corra `chmod +x ./gradlew` y vuelva a intentar. |

Lo que **no** hay que hacer:

- No borre ni renombre las pestañas de la hoja, ni cambie la fila de
  encabezados: el servidor las busca por nombre y lee las columnas por orden.
- No edite los datos a mano en la hoja mientras alguien esté sincronizando.
- No comparta la hoja con permiso de edición a quien no necesite: quien pueda
  editar la hoja puede ver y cambiar los datos de todos los productores.
