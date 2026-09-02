# Guía de pruebas — Red Nacional de Cacao

Para la persona que recibe la APK. No hace falta saber programar.

## 1. Instalar

1. Copie el archivo **`RedNacionalDeCacao-v1.0.0.apk`** al teléfono Android
   (por WhatsApp, correo, cable o Drive).
2. Ábralo desde la carpeta de **Descargas**.
3. Android va a advertir que la app no viene de la tienda. Toque
   **Configuración** y active **"Permitir de esta fuente"** o
   **"Instalar aplicaciones desconocidas"** para la app desde la que la está
   abriendo (Archivos, Chrome o WhatsApp).
4. Toque **Instalar** y luego **Abrir**.

> Requiere Android 7 o superior. Ocupa unos 62 MB al descargar.
> Es una versión de prueba, no está en Play Store.

---

## 2. Primera prueba: registrar la finca

1. Abra la aplicación. Debe ver la pantalla verde con la mazorca.
2. Toque **Comenzar registro**.
3. **Paso 1**: escriba su nombre y su teléfono → **Crear perfil**.
4. **Paso 2**: nombre de la finca, municipio y departamento.
   - Si quiere, toque **Marcar en el mapa** y luego **Estoy en la finca** para
     tomar la ubicación con el GPS. Necesita permiso de ubicación.
   - Toque **Registrar finca**.
5. En el inicio, toque **Agregar lote**: nombre, área en hectáreas, variedad
   (hay atajos: CCN-51, ICS-95…) y fecha de siembra.
6. Toque el **botón naranja +** de abajo:
   - **Una labor** → escoja el tipo (poda, fertilización…), la fecha y una nota.
   - Repita y escoja **Una cosecha** → escriba los kilos.
7. Entre al lote (toque su tarjeta) y mire las pestañas **Labores**,
   **Cosechas** y **Estado**.
8. En **Estado**, toque **+ Diagnóstico**, escoja cómo está el cultivo y tome
   una **foto**.
9. **Cierre la aplicación por completo y vuelva a abrirla.**

**Lo que debe pasar:** todo sigue ahí. El inicio muestra los kilos del año, el
número de lotes, las hectáreas, y en cada lote la última labor y su producción.

---

## 3. Prueba sin internet (la más importante)

1. Active **modo avión** o apague los datos y el wifi.
2. Registre una cosecha nueva y una labor.
3. Mire la cinta de arriba: debe decir **"2 cambios sin enviar"**.
4. Siga usando la app: entre a los lotes, agregue otro lote. **Todo debe
   funcionar igual.**
5. Cierre la app y ábrala de nuevo. Los datos siguen ahí.
6. Vuelva a activar internet.
7. Espere unos segundos o toque **Enviar** en la cinta.

**Lo que debe pasar:** la cinta cambia a **"Todo guardado y enviado"**. Nada se
pierde en ningún momento.

---

## 4. Prueba de cuenta

**Use un correo real al que tenga acceso.** La cuenta sirve para recuperar sus
datos si pierde el teléfono, y eso solo funciona con un correo de verdad.

1. Vaya a **Perfil** (abajo a la derecha).
2. En la tarjeta **Sin cuenta**, toque **Crear cuenta**.
3. Escriba su correo y una contraseña (mínimo 6 caracteres), repítala y toque
   **Crear cuenta**.
4. La tarjeta va a decir que **falta confirmar el correo**. Abra su bandeja de
   entrada —revise también correo no deseado—, toque el enlace del mensaje.
5. Vuelva a la app y toque **Ya confirmé mi correo**.

**Lo que debe pasar:** la tarjeta se pone verde con su correo y el mensaje
"Sus datos están respaldados".

> Mientras no confirme, **no podrá entrar desde otro teléfono**. Es a propósito:
> la app prefiere avisarle antes que prometerle un respaldo que no existe.

## 5. Prueba de recuperación en otro teléfono

1. Instale la APK en un segundo teléfono Android.
2. En la pantalla de bienvenida, toque **Ya tengo cuenta**.
3. Entre con el mismo correo y contraseña.

**Lo que debe pasar:** aparece "Recuperando sus datos…" y luego su finca, sus
lotes y sus registros, tal como estaban en el primer teléfono.

> Esta es la prueba que **más nos interesa**. Si algo falla aquí, anótelo con
> detalle.

## 6. Cerrar sesión

En **Perfil** → **Cerrar sesión**. Sirve para volver a empezar de cero en un
teléfono o para probar con otra cuenta.

**Cuidado:** borra los datos **de ese teléfono**. Lo que ya se envió se recupera
volviendo a entrar; lo que estuviera sin enviar se pierde, y la app se lo
advierte antes con el número de cambios pendientes.

---

## 7. Qué anotar

Para cada problema, si puede:

- Qué estaba haciendo, paso a paso.
- Qué esperaba que pasara y qué pasó.
- Una captura de pantalla.
- Marca y modelo del teléfono, y versión de Android.

Interesa especialmente:

- Textos que no se entiendan o se salgan de la pantalla.
- Botones difíciles de acertar con el dedo.
- Algo que se sienta lento o se congele.
- Cualquier dato que aparezca **repetido** o que **desaparezca**.
