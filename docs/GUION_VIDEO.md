# Guion para el video de presentación

Para explicarle la aplicación al equipo, pantalla por pantalla, **explicando el
porqué de cada decisión**. Duración estimada: **8 a 9 minutos**.

Cada sección trae tres cosas:

- **Se ve** — lo que muestras en la grabación.
- **Se dice** — el hilo. No hay que leerlo palabra por palabra.
- **Si les preguntan** — respuestas cortas a lo que probablemente pregunten.

---

## 0 · Antes de grabar

- Borra los datos de la app para arrancar desde la bienvenida.
- Ten listo un lote con una labor y una cosecha, para la parte del detalle.
  Grábalo en dos tomas si es más fácil.
- Silencia las notificaciones.

---

## 1 · Apertura: la decisión que manda (50 s)

**Se ve:** la pantalla de bienvenida.

> Esta es la aplicación para la Red Nacional de Cacao. La usa **el productor**,
> no el técnico: un cacaotero en su finca, con un celular sencillo y muchas
> veces sin señal.
>
> Quédense con esta frase, porque de ahí sale todo lo demás: **en la finca no hay
> internet**.
>
> Eso define la arquitectura. La aplicación es *offline-first*, que significa que
> **la base de datos del teléfono es la fuente de verdad**, no el servidor. Todo
> se guarda primero local y se manda a la nube después. La pantalla nunca espera
> una respuesta del servidor para mostrar algo.
>
> Si algún día alguien propone "que la app consulte el servidor para mostrar los
> lotes", ahí se rompe todo el diseño. Es la regla que no se negocia.

**Si les preguntan:**

- *¿Qué base de datos usa el teléfono?* → SQLite, con una librería que se llama
  Drift que nos deja escribir las consultas en Dart con tipos, así los errores
  salen al compilar y no en el celular del productor.
- *¿Y si nunca hay internet?* → La aplicación funciona completa. La nube es
  respaldo y puente entre teléfonos, no es requisito para usarla.

---

## 2 · Registro en dos pasos (1 min)

**Se ve:** *Comenzar registro*, paso 1 y paso 2 encadenados.

> El registro son dos pasos: los datos de la persona y los de la finca. El
> segundo se abre solo al terminar el primero, porque antes había que devolverse
> y adivinar qué faltaba.
>
> Algo que pasa aquí y no se ve: **en el primer arranque la aplicación se genera
> una identidad local**, un identificador único, y lo hace **sin red**. Por eso
> se puede registrar la finca completa sin haber tenido nunca internet.

**Se ve:** la sección de ubicación GPS.

> La ubicación se puede marcar tocando el mapa o con *Estoy en la finca*, que
> toma el GPS.
>
> Y ojo con la diferencia, porque es la que importa en campo: **el GPS funciona
> sin datos** —es satélite—, pero **el mapa necesita internet** para descargar
> las imágenes. Por eso el botón del GPS es el camino principal y el mapa es el
> ajuste fino.

**Si les preguntan:**

- *¿Por qué guardan municipio y departamento si ya tienen las coordenadas?* →
  Para pedir el clima por municipio más adelante sin tener que convertir
  coordenadas en nombres, que es un servicio aparte y de pago.
- *¿Por qué se guarda la fecha de siembra y no la edad del lote?* → Porque la
  edad se desactualiza sola. La calculamos cada vez que se muestra.

---

## 3 · Inicio: cómo va mi finca (1 min 40 s)

**Se ve:** la pantalla de inicio.

> Esta es la pantalla del día a día. Antes tenía arriba el nombre y el teléfono
> del productor y lo quitamos: eso se lee una vez en la vida. Esta pantalla
> responde a otra pregunta, que es **cómo va mi finca**.

**Se señala:** la cinta de sincronización.

> Esta cinta muestra el estado de la sincronización. Cada dato que se guarda
> queda marcado como **pendiente**; cuando llega al servidor pasa a
> **enviado**.
>
> Si están sin señal y anotan tres cosechas, aquí dirá *"3 cambios sin enviar"*,
> y esa cuenta sale de una consulta que mira las seis tablas. Cuando vuelve la
> señal, la app sincroniza sola —hay un detector de conexión— o pueden tocar
> *Enviar*.
>
> Esto no es decoración: es la forma de decirle al productor **"lo suyo está
> guardado, tranquilo"**, aunque no haya llegado a la nube.

**Se señala:** los tres indicadores y las tarjetas de lote.

> Los tres números del año: kilos, lotes y hectáreas. Los kilos salen de una
> suma que hace la base de datos, no de un número guardado, así que **si anotan
> una cosecha, el número cambia solo**. Toda la pantalla está conectada a
> consultas reactivas: cambia el dato, se repinta.
>
> Y cada lote muestra **la última labor y cuándo fue**, y **los kilos del año**.
> Eso es lo que un productor necesita para decidir a cuál lote le toca, sin
> entrar a ningún lado.

**Si les preguntan:**

- *¿Los kilos del año se guardan en algún campo?* → No. Se calculan sumando las
  cosechas del año. Un total guardado se desincroniza apenas alguien borra o
  edita algo.
- *¿Cómo sabe la app que volvió la señal?* → Con `connectivity_plus`, que avisa
  cuando cambia la conexión. Ahí intenta sincronizar; si falla, no pasa nada,
  los datos siguen marcados como pendientes.

---

## 4 · El botón de anotar (40 s)

**Se ve:** tocar el botón naranja y registrar una cosecha.

> Este botón está en todas las pantallas y es el corazón de la aplicación.
> Pregunta en cuál lote —si hay uno solo se lo salta— y luego si es labor o
> cosecha. Tres toques.
>
> Está aquí por una razón de uso real: el señor acaba de podar, tiene el celular
> en la mano y quiere anotarlo ahí mismo. Si tuviera que entrar al lote y buscar
> una pestaña, no lo haría, y una aplicación que no se usa no sirve de nada.

---

## 5 · Detalle del lote y el borrado (1 min 20 s)

**Se ve:** entrar al lote, recorrer las tres pestañas.

> Al entrar vemos variedad, área, edad y producción del año. Y tres pestañas:
> **Labores**, **Cosechas** y **Estado**, que es el diagnóstico del cultivo con
> foto: floración, cuajado, maduración.
>
> Esa foto, por ahora, **se queda en el teléfono**: al servidor viaja la ruta,
> no la imagen. Subirlas es un trabajo aparte y está pendiente.

**Se ve:** deslizar un registro y luego borrar el lote.

> Y aquí está una de las decisiones más importantes del diseño: **nada se borra
> de verdad**. Cuando borran algo, se le pone una marca de borrado y la fila se
> queda ahí.
>
> ¿Por qué? Porque si se borrara de verdad, un teléfono que estuvo un mes sin
> señal **nunca se enteraría** de que ese dato ya no existe. Al volver, lo
> volvería a subir. Con la marca, el borrado también viaja.
>
> Y al borrar un lote se marcan también sus labores, sus cosechas y sus
> diagnósticos, todo en una sola operación. Si no, quedarían registros colgando
> de un lote que ya no existe.

**Si les preguntan:**

- *¿Entonces la base crece para siempre?* → Sí, y para el volumen de una finca
  —decenas o cientos de filas al año— no es problema. Limpiar lo borrado sería
  otra funcionalidad, con cuidado.
- *¿Por qué los identificadores son esos códigos largos y no números?* → Son
  UUID y **los genera el teléfono**. Si fueran números consecutivos, dos
  celulares sin señal crearían el "lote 5" cada uno y chocarían al sincronizar.

---

## 6 · Perfil, cuenta e identidad (1 min 30 s)

**Se ve:** la pestaña Perfil.

> En Perfil están los datos que se leen una vez: la persona y la finca.
>
> Y esta es la tarjeta de la cuenta. Lo primero: **la aplicación funciona
> completa sin cuenta**. Se registra todo, se anota todo. Pero los datos viven
> solo en ese teléfono; si se pierde, se perdieron.
>
> Aquí hay una parte de diseño que vale la pena entender, porque es la más
> confusa. Manejamos **dos identidades distintas**:
>
> La **identidad de la instalación**, que es de este teléfono y se genera sin
> internet. Y la **identidad de la cuenta**, que es la de Supabase.
>
> ¿Por qué separadas? Porque la app tiene que funcionar **antes** de que exista
> una cuenta. Si el dueño de los datos fuera la cuenta, no se podría anotar nada
> hasta tener internet y registrarse.

**Se ve:** crear la cuenta.

> Al crear la cuenta con correo y contraseña, pasa algo importante: **no se
> registra un usuario nuevo, se vincula el que ya existe**. La sesión anónima que
> la app abrió sola se convierte en cuenta, **conservando el mismo
> identificador**.
>
> Si en vez de vincular registráramos, se crearía otro usuario con otro
> identificador y **todo lo que ya se había subido quedaría huérfano**: el
> servidor no se lo entregaría a nadie. Es la regla dura del código.
>
> Y hay que confirmar el correo. Mientras no se confirme, la app lo dice y no
> promete un respaldo que todavía no existe.

**Se ve:** el botón *Ya tengo cuenta* / *Cerrar sesión*.

> En otro teléfono, se entra con el mismo correo y baja la finca completa. Los
> datos se descargan y **el teléfono nuevo los adopta con su propia identidad de
> instalación**, sin cambiar un solo identificador de fila ni romper las
> relaciones entre lotes y cosechas.

**Si les preguntan:**

- *¿Alguien puede ver los datos de otro?* → No. Lo impide el servidor, no la
  aplicación: hay políticas de seguridad por fila que solo entregan lo que
  pertenece al usuario que pregunta.
- *¿La llave de Supabase que está en el código no es un riesgo?* → Esa llave es
  pública por diseño, va en todas las apps que usan Supabase. Lo que protege los
  datos son esas políticas. La llave secreta no está en el proyecto ni puede
  estarlo.
- *¿Y si alguien no tiene correo?* → Puede usar la aplicación completa sin
  cuenta. El correo solo hace falta para recuperar los datos o usar dos
  teléfonos.

---

## 7 · Cómo funciona la sincronización (1 min 30 s)

**Se ve:** un esquema, o la app quieta.

> Vamos a lo que no se ve. Cada vez que se sincroniza pasan dos cosas, **siempre
> en este orden**: primero **sube** lo pendiente, después **baja** lo nuevo.
>
> Y sube en orden: productor, finca, lotes, y por último labores, cosechas y
> diagnósticos. Si un lote llegara antes que su finca, el servidor lo rechazaría
> porque no existiría el padre.
>
> Al subir, **el servidor le pone la hora**, no el teléfono. Eso es a propósito:
> si comparáramos el reloj de un celular con el de otro, bastaría uno con la hora
> mal puesta para dañar la sincronización de todos.
>
> Al bajar, no se trae todo cada vez: se guarda una marca de por dónde iba y solo
> se piden los cambios nuevos. Y si la descarga se corta a la mitad, esa marca no
> avanza, así que la próxima vez se repite ese tramo y no se pierde nada.

**Se dice, sobre conflictos:**

> ¿Y si dos personas cambian lo mismo? La regla es **gana el último que
> sincroniza** —no el último que editó—, y como el orden es subir antes de
> bajar, es predecible.
>
> Con una excepción que sí importa: **lo que ustedes anotaron y todavía no se ha
> enviado nunca lo pisa lo que baja del servidor**. Se conserva lo local, se
> sube después, y el choque queda registrado.

**Si les preguntan:**

- *¿Qué pasa si sincronizo dos veces seguidas?* → Nada. La operación es
  idempotente: si la fila que llega ya es la que tenemos, se ignora.
- *¿Y si llega una cosecha de un lote que este teléfono no tiene todavía?* → Se
  aplaza y se reintenta en la siguiente sincronización, cuando ya haya llegado el
  lote. No se aplica a medias.

---

## 8 · Cómo está organizado el código (50 s)

**Se ve:** el repositorio en GitHub.

> Para que sepan dónde meter mano, el proyecto está en capas:
>
> **`lib/ui`** son las pantallas. **`lib/data/local`** son las tablas y las
> migraciones. **`lib/data/daos`** las consultas. **`lib/data/repositories`** es
> la fachada: **la interfaz nunca habla con la base directamente**, siempre pasa
> por ahí. Y **`lib/data/sync`** es el motor de sincronización, que es la parte
> más delicada.
>
> Hay **121 pruebas automáticas** y corren solas en GitHub cada vez que alguien
> sube un cambio. Si algo rompe la sincronización, se sabe ahí y no en el
> teléfono de un productor. De hecho gracias a ellas encontramos dos errores
> serios: uno que dejaba la descarga en un bucle infinito y otro que perdía filas
> en silencio.
>
> En el repositorio está el README, una documentación técnica más a fondo y una
> guía de cómo trabajamos con ramas y revisiones.

---

## 9 · Cierre (40 s)

> Eso es lo que hay hoy funcionando: la app en Android, la versión web publicada
> y el servidor en Supabase.
>
> Lo que falta y ya está identificado: subir las fotos a la nube, recuperación de
> contraseña, terminar de probar la versión web y dejar registrada la prueba con
> dos teléfonos.
>
> Y lo más importante: **esperemos la reunión con el SENA** antes de decidir qué
> sigue. Que la prioridad la pongan ellos, no nosotros adivinando.

---

## Las siete ideas, por si prefieres explicarlo a tu manera

1. **En la finca no hay señal** — de ahí sale toda la arquitectura.
2. **La base del teléfono es la fuente de verdad**; la nube es respaldo y puente.
3. **Pendiente / enviado** — así se sabe siempre qué falta por subir.
4. **Nada se borra de verdad**, o los otros teléfonos no se enterarían.
5. **Los identificadores los genera el teléfono**, para que dos celulares sin
   señal no choquen.
6. **Instalación y cuenta son cosas distintas**, para poder trabajar sin
   internet y sin cuenta.
7. **Gana el último que sincroniza**, pero lo local pendiente nunca se pisa.
