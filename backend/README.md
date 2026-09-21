# Servidor en Google Apps Script

Reemplazo de Supabase para la Red Nacional de Cacao. La hoja de cálculo es la
base de datos; [`Codigo.gs`](Codigo.gs) es el servidor.

La app **no cambia por dentro**: todo el acceso a la nube vive detrás de
`ApiRemota` (`lib/data/sync/api_remota.dart`). Esto solo reemplaza la
implementación `ApiSupabase` por una nueva, `ApiAppsScript`.

## Qué hace y qué no

| Hace | No hace |
| --- | --- |
| Guarda las 7 tablas en hojas | No valida datos del cultivo (eso lo hace la app) |
| Sella `updated_at` con la hora del servidor | No borra filas: solo marca `deleted_at` |
| Filtra por `usuario_id` en cada petición | No guarda fotos (irían a Drive, Fase 2) |
| Entrega páginas con cursor `(updated_at, id)` | No maneja contraseñas: eso es de Google |

## Instalación, paso a paso

### 1. La hoja de cálculo

1. Cree una hoja nueva en Google Sheets y llámela **Red Nacional de Cacao**.
2. Menú **Extensiones → Apps Script**.
3. Borre lo que haya en el editor y pegue todo [`Codigo.gs`](Codigo.gs).
4. Guarde (💾) y póngale de nombre al proyecto **Servidor Cacao**.
5. Arriba, escoja la función **`instalar`** y toque **▷ Ejecutar**.
   - La primera vez Google pide permiso: **Revisar permisos → su cuenta →
     Configuración avanzada → Ir a Servidor Cacao → Permitir**.
   - Sale la advertencia de "app no verificada" porque el proyecto es suyo y
     no está publicado. Es normal.
6. Vuelva a la hoja: deben aparecer 8 pestañas y las 5 asociaciones sembradas.

### 2. Los identificadores de Google (esto lo hace el equipo)

En <https://console.cloud.google.com> con la misma cuenta:

1. Cree un proyecto, por ejemplo **Red Cacao**.
2. **APIs y servicios → Pantalla de consentimiento de OAuth**: tipo *Externo*,
   nombre de la app, correo de soporte. Mientras esté en *Prueba*, agregue como
   usuarios de prueba los correos del equipo y de los productores que vayan a
   probar.
3. **Credenciales → Crear credenciales → ID de cliente de OAuth**, dos veces:
   - **Android**: paquete `com.redcacao.cacao_app` y la huella **SHA-1**.
   - **Aplicación web**: para la versión de Vercel.
4. Copie los dos identificadores dentro de `CLIENTES_AUTORIZADOS`, arriba en
   `Codigo.gs`, y guarde.

La huella SHA-1 se saca así, desde la carpeta `android` del proyecto:

```bash
./gradlew signingReport
```

> **Cuidado con esto:** hoy la app se firma con las llaves de depuración. Si
> publican con llaves nuevas y no registran ese SHA-1, el inicio de sesión deja
> de funcionar en los celulares y el error no dice por qué.

### 3. Publicar el servidor

1. En el editor de Apps Script: **Implementar → Nueva implementación**.
2. Tipo: **Aplicación web**.
3. **Ejecutar como:** *Yo* (el dueño de la hoja).
4. **Quién tiene acceso:** *Cualquier usuario*.
   Esto no abre los datos: sin una sesión válida, el script no devuelve nada.
5. Copie la **URL de la aplicación web** (termina en `/exec`). Esa URL va en la
   app, en `lib/data/sync/config_nube.dart`.

> Cada vez que cambien el código hay que hacer **Nueva implementación** (o
> *Administrar implementaciones → editar → Versión: Nueva*). Si no, la URL
> sigue sirviendo el código viejo y parece que el cambio no hubiera servido.

## Cómo se habla con el servidor

Todo es `POST` a la URL del `/exec`, con el cuerpo en JSON pero enviado como
**`text/plain`**. No es capricho: con `application/json` el navegador hace una
petición previa que Apps Script no contesta, y la versión web se queda sin
sincronizar.

| Acción | Manda | Devuelve |
| --- | --- | --- |
| `ping` | — | `{ok:true}` |
| `entrar` | `idToken` de Google | `token`, `usuarioId`, `correo` |
| `descargar` | `token`, `entidad`, `desde`, `desdeId`, `limite` | `filas` |
| `subir` | `token`, `entidad`, `filas` | `filas` como quedaron |
| `salir` | `token` | `{ok:true}` |

Ejemplo de prueba desde la terminal:

```bash
curl -s -L -X POST "URL_DEL_EXEC" -H "Content-Type: text/plain" -d '{"accion":"ping"}'
```

> `-L` es necesario: Apps Script siempre responde con una redirección antes de
> entregar el resultado. El cliente en Dart también tiene que seguirla.

## Los límites que hay que tener presentes

- **Cuenta gratuita de Gmail:** 90 minutos de ejecución al día. Con cuenta de
  Workspace del SENA sube a 6 horas.
- **Escrituras:** se hacen de a una y con candado, así que dos productores
  sincronizando al mismo tiempo se turnan. Con decenas de usuarios va bien; con
  cientos, se sentiría lento.
- **Tamaño:** una hoja aguanta 10 millones de celdas. Con 12 columnas son unas
  800 mil filas por tabla. No es el problema cercano.

## Seguridad: las tres líneas que sostienen todo

1. `CLIENTES_AUTORIZADOS` — sin esa comprobación, el token de cualquier app de
   Google serviría para entrar.
2. `sesionDe(token)` — toda acción de datos empieza por ahí.
3. El servidor **sobrescribe** `usuario_id` con el de la sesión y nunca confía
   en el que mande el teléfono.

Si alguien toca una de esas tres, se abre la puerta a que un productor vea los
datos de otro.
