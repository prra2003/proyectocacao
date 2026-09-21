/// Datos del servidor en Google Apps Script.
///
/// Nada de esto es secreto: la dirección solo entrega datos a quien traiga una
/// sesión válida, y los identificadores
/// de OAuth viajan dentro de la app, que cualquiera puede descargar. Lo que
/// protege la cuenta es otra cosa: en Android, la huella SHA-1 registrada en
/// Google; en la web, la lista de orígenes autorizados.
///
/// El secreto del cliente (`GOCSPX-...`) **no va aquí ni en ninguna parte del
/// repositorio**: este diseño no lo usa.
library;

/// Dirección del servidor, la que termina en `/exec`.
///
/// Se puede reemplazar al compilar sin tocar el código:
/// `flutter build apk --dart-define=NUBE_URL=https://...`
const String urlNube = String.fromEnvironment(
  'NUBE_URL',
  defaultValue: 'https://script.google.com/macros/s/'
      'AKfycbx2otWwTIS96VgupOshybshpUfhK7DiqtanlcWB6PFR8sL2_rS6OsvOUVps6QuU5Q'
      '/exec',
);

/// Identificador de OAuth de la versión web (va también en `web/index.html`).
const String clienteWeb = String.fromEnvironment(
  'GOOGLE_CLIENTE_WEB',
  defaultValue: '1093616695034-f3hhofhek3urakqgn7p3ibptj5ro0m0u'
      '.apps.googleusercontent.com',
);

/// Identificador de OAuth de Android.
///
/// Android no lo necesita en el código —se resuelve con el paquete y la huella
/// SHA-1 registrados en Google—, pero se deja anotado para saber cuál es el
/// que el servidor tiene que aceptar.
const String clienteAndroid = '1093616695034-uln607b40ono39611khf8vf2u1ih5bqb'
    '.apps.googleusercontent.com';

/// ¿Hay servidor configurado?
///
/// Si no lo hay, la app funciona igual: guarda todo en el teléfono y no
/// sincroniza. El campo no puede quedarse esperando a la nube.
bool get hayNube => urlNube.isNotEmpty;
