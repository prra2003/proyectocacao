# Repartir actualizaciones sin desinstalar

Para que una APK nueva se instale **encima** de la anterior, conservando los
datos del productor, Android exige dos cosas:

1. Que las dos APK estén firmadas con **la misma llave**.
2. Que el **número de versión suba**.

Si falla la primera, el celular dice *"La aplicación no se instaló"* y toca
desinstalar, lo que **borra todo lo que el productor haya anotado**. Si falla
la segunda, dice que ya hay una versión igual o más nueva.

## 1. La llave del equipo (se hace una sola vez)

Hasta ahora la app se firmaba con la llave de **depuración**, que es distinta
en cada computador. Por eso la APK que compila Diego no se puede instalar
encima de la que compila Quice: para el celular son dos apps de distinto
dueño.

La solución es una llave propia, compartida por el equipo.

### Crearla

Alguien del equipo corre esto **una vez** y guarda bien el archivo y las claves:

```bash
keytool -genkey -v -keystore ~/cacao-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cacao
```

Le va a pedir una contraseña y unos datos (nombre, organización, ciudad). Puede
poner "Red Nacional de Cacao" y su ciudad; lo único que no puede olvidar es
**la contraseña**.

> **Esto es lo más delicado del proyecto.** Si pierden ese archivo o su
> contraseña, **no hay forma de recuperarlo**: nunca más podrán publicar una
> actualización que se instale encima, y a todos los productores les tocaría
> desinstalar y perder sus datos. Guárdenlo en dos sitios distintos (por
> ejemplo, el Drive del equipo y una memoria), y la contraseña aparte.

### Configurarla en el proyecto

Cada persona que compile APK para repartir copia el `.jks` a su computador y
crea el archivo `android/key.properties` (hay una plantilla en
[`android/key.properties.ejemplo`](../android/key.properties.ejemplo)):

```properties
storeFile=/Users/USUARIO/cacao-release.jks
storePassword=LA_CLAVE
keyAlias=cacao
keyPassword=LA_CLAVE
```

Ese archivo **no se sube a GitHub** (ya está en `.gitignore`), igual que el
`.jks`. Con la llave, cualquiera puede firmar una app que los celulares
aceptarían como si fuera la suya.

Si el archivo no existe, la app se sigue compilando con las llaves de
depuración: sirve para trabajar en su computador, **no para repartir**.

### Registrar la huella en Google

El ingreso con Google depende de la huella del certificado. Con la llave nueva,
la huella cambia, así que hay que registrarla o **el ingreso dejará de
funcionar en las APK que repartan** (y el error no dice por qué).

```bash
keytool -list -v -keystore ~/cacao-release.jks -alias cacao | grep SHA1
```

Esa huella se agrega en <https://console.cloud.google.com/auth/clients>, en el
cliente **Cacao Android** del proyecto *Red Cacao*. Un cliente de Android puede
tener varias huellas: deje la de depuración (para probar en el emulador) y
agregue esta.

## 2. Subir la versión en cada entrega

En `pubspec.yaml`:

```yaml
version: 1.1.0+2
```

- El **`1.1.0`** es el nombre que ve la gente.
- El **`+2`** es el número que mira Android. **Tiene que subir siempre**: 2, 3,
  4… Si reparten una APK con el mismo número, el celular la rechaza.

Regla sencilla: cada vez que generen una APK para repartir, suban el número de
después del `+`.

## 3. Generar y repartir

```bash
flutter build apk --release
```

Queda en `build/app/outputs/flutter-apk/app-release.apk`. Conviene renombrarla
con la versión antes de mandarla:

```bash
cp build/app/outputs/flutter-apk/app-release.apk ~/RedNacionalDeCacao-1.1.0.apk
```

El productor solo abre el archivo y toca **Actualizar**. No tiene que
desinstalar nada y **sus datos quedan intactos**.

## Qué pasa con los datos al actualizar

Nada: la base de datos del teléfono no se toca. Si la versión nueva cambió el
modelo de datos, la app aplica sola la migración al abrir (van por la versión 7
del esquema local, ver la documentación técnica). Por eso es importante no
saltarse versiones raras ni repartir APK viejas encima de nuevas.

## Si algo sale mal

| Lo que ve el productor | Qué pasó |
| --- | --- |
| *"La aplicación no se instaló"* | La APK está firmada con otra llave. Alguien compiló sin `key.properties`. |
| *"Aplicación no instalada como paquete en conflicto"* | Lo mismo: firma distinta. |
| No deja instalar y ya tiene una versión más nueva | El número después del `+` no subió. |
| Instala pero no deja entrar con Google | La huella SHA-1 de la llave nueva no está registrada en Google Cloud. |

> Para el primer cambio de llave **sí toca desinstalar una vez**: los celulares
> que hoy tienen la APK firmada con llaves de depuración no pueden recibir la
> primera APK firmada con la llave del equipo. Avísenle a quien esté probando
> que exporte o vuelva a anotar lo que tenga. De ahí en adelante, todas las
> actualizaciones entran encima sin perder nada.
