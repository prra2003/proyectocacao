/**
 * Red Nacional de Cacao — servidor en Google Apps Script.
 *
 * Reemplaza a Supabase. La hoja de cálculo hace de base de datos y este script
 * hace de servidor: recibe lo que el teléfono anotó sin señal y le devuelve lo
 * que le falta.
 *
 * Cuatro decisiones que no son obvias:
 *
 *  1. `updated_at` lo escribe SIEMPRE el servidor, nunca el teléfono. Es el
 *     único reloj comparable entre dispositivos: un celular con la hora mal no
 *     puede envenenar la sincronización.
 *
 *  2. `usuario_id` también lo escribe el servidor, en TODAS las tablas, sacado
 *     de la sesión. Así el filtro "cada quien ve lo suyo" es una comparación
 *     directa y no depende de que el teléfono mande el dato correcto.
 *
 *  3. Nada se borra de verdad: `deleted_at` marca la fila como borrada. Si se
 *     borrara la fila, los otros teléfonos nunca se enterarían del borrado.
 *
 *  4. Las fechas viajan y se guardan como texto ISO-8601 en UTC. Si se
 *     guardaran como fecha de Sheets, la hoja les cambiaría la zona horaria y
 *     cada fila se vería "modificada" en cada ciclo: un bucle infinito.
 */

// ------------------------------------------------------------- ajustes ----

/** Identificadores de OAuth de la app (consola de Google Cloud). */
var CLIENTES_AUTORIZADOS = [
  'PEGUE-AQUI-EL-ID-DE-ANDROID.apps.googleusercontent.com',
  'PEGUE-AQUI-EL-ID-WEB.apps.googleusercontent.com',
];

/** Días que dura la sesión antes de pedir otra vez la cuenta de Google. */
var DIAS_DE_SESION = 90;

/** Filas por página en la descarga. El teléfono pide varias veces. */
var MAXIMO_POR_PAGINA = 200;

// --------------------------------------------------------------- tablas ----
//
// Esta lista dice qué columnas debe tener cada hoja. El **orden real** lo
// manda el encabezado de la hoja (ver `encabezados`), no esta lista: así,
// agregar una columna aquí y volver a ejecutar `instalar()` no descoloca las
// filas que ya están guardadas.
// Las cuatro últimas de cada tabla de datos son comunes (ver SyncColumns
// en lib/data/local/tables.dart).

var COMUNES = ['created_at', 'updated_at', 'deleted_at', 'usuario_id'];

var TABLAS = {
  asociaciones: ['id', 'nombre', 'municipio', 'departamento',
                 'created_at', 'updated_at', 'deleted_at'],
  productores: ['id', 'nombre_completo', 'telefono', 'email', 'tipo_documento',
                'numero_documento', 'asociacion_id', 'asociacion_nombre']
               .concat(COMUNES),
  fincas: ['id', 'productor_id', 'nombre', 'latitud', 'longitud', 'municipio',
           'departamento'].concat(COMUNES),
  lotes: ['id', 'finca_id', 'nombre', 'codigo', 'area_sembrada_ha',
          'variedad_cacao', 'fecha_siembra'].concat(COMUNES),
  actividades_agricolas: ['id', 'lote_id', 'tipo_actividad', 'fecha',
                          'observaciones', 'responsable', 'costo', 'foto_path',
                          'subtipo_labor', 'producto', 'cantidad_aplicada',
                          'incidencia', 'arboles_afectados',
                          'edad_cultivo_anios', 'arboles_sembrados',
                          'edad_plantula_meses', 'insumos',
                          'resultado_esperado'].concat(COMUNES),
  cosechas: ['id', 'lote_id', 'fecha', 'cantidad_kg', 'observaciones',
             'tipo_producto', 'foto_path'].concat(COMUNES),
  diagnosticos: ['id', 'lote_id', 'fecha', 'foto_path', 'estado_fenologico',
                 'notas'].concat(COMUNES),
};

/** Catálogo compartido: todos lo bajan, nadie lo sube. */
var TABLAS_PUBLICAS = ['asociaciones'];

var HOJA_SESIONES = '_sesiones';

// ---------------------------------------------------------- instalación ----

/**
 * Se ejecuta UNA vez desde el editor (botón ▷ con `instalar` seleccionado).
 * Crea las hojas que falten con sus encabezados y siembra las asociaciones.
 */
function instalar() {
  var libro = SpreadsheetApp.getActiveSpreadsheet();

  Object.keys(TABLAS).forEach(function (nombre) {
    crearHoja(libro, nombre, TABLAS[nombre]);
  });
  crearHoja(libro, HOJA_SESIONES,
            ['token', 'usuario_id', 'correo', 'creada', 'expira']);

  sembrarAsociaciones(libro);
  return 'Listo: ' + (Object.keys(TABLAS).length + 1) + ' hojas revisadas.';
}

function crearHoja(libro, nombre, columnas) {
  var hoja = libro.getSheetByName(nombre) || libro.insertSheet(nombre);
  if (hoja.getLastRow() === 0) {
    hoja.getRange(1, 1, 1, columnas.length).setValues([columnas])
        .setFontWeight('bold');
    hoja.setFrozenRows(1);
  } else {
    // La hoja ya existía: se agregan al final las columnas que falten, sin
    // mover las que ya están. Mover una columna con datos sería mezclar
    // valores de una fila con otra.
    var actuales = encabezados(hoja);
    var faltantes = columnas.filter(function (c) {
      return actuales.indexOf(c) === -1;
    });
    if (faltantes.length) {
      hoja.getRange(1, actuales.length + 1, 1, faltantes.length)
          .setValues([faltantes]).setFontWeight('bold');
    }
  }
  // Todo como texto: sin esto, Sheets convierte las fechas ISO y los UUID
  // con guiones en cosas que ya no son iguales a lo que mandó el teléfono.
  hoja.getRange(1, 1, hoja.getMaxRows(), columnas.length).setNumberFormat('@');
  var sobra = libro.getSheetByName('Hoja 1') || libro.getSheetByName('Sheet1');
  if (sobra && sobra.getLastRow() === 0 && libro.getSheets().length > 1) {
    libro.deleteSheet(sobra);
  }
  return hoja;
}

function sembrarAsociaciones(libro) {
  var hoja = libro.getSheetByName('asociaciones');
  if (hoja.getLastRow() > 1) return;
  var ahora = ahoraIso();
  var base = 'a0000001-0000-4000-8000-00000000000';
  var filas = [
    [base + '1', 'FEDECACAO', 'Bogotá', 'Cundinamarca', ahora, ahora, ''],
    [base + '2', 'FEPCACAO', 'Bucaramanga', 'Santander', ahora, ahora, ''],
    [base + '3', 'ASOMUSTIC', 'San Vicente de Chucurí', 'Santander', ahora, ahora, ''],
    [base + '4', 'APROCAVILLA', 'Villanueva', 'Santander', ahora, ahora, ''],
    [base + '5', 'AMUCAFUE', 'Fuente de Oro', 'Meta', ahora, ahora, ''],
  ];
  hoja.getRange(2, 1, filas.length, filas[0].length).setValues(filas);
}

// ------------------------------------------------------------- entradas ----

/** Prueba rápida desde el navegador: abrir la URL del script. */
function doGet() {
  return responder({ ok: true, servicio: 'Red Nacional de Cacao', version: 1 });
}

/**
 * Todo entra por aquí. El teléfono manda JSON como texto plano
 * (Content-Type: text/plain) a propósito: con application/json el navegador
 * haría una petición previa que Apps Script no contesta, y la versión web
 * dejaría de sincronizar sin decir por qué.
 */
function doPost(e) {
  try {
    var p = JSON.parse((e && e.postData && e.postData.contents) || '{}');
    switch (p.accion) {
      case 'ping':      return responder({ ok: true });
      case 'entrar':    return responder(entrar(p));
      case 'salir':     return responder(salir(p));
      case 'descargar': return responder(descargar(p));
      case 'subir':     return responder(subir(p));
      default:
        return responder({ ok: false, error: 'Acción desconocida: ' + p.accion });
    }
  } catch (error) {
    return responder({ ok: false, error: String(error && error.message || error) });
  }
}

function responder(datos) {
  return ContentService.createTextOutput(JSON.stringify(datos))
      .setMimeType(ContentService.MimeType.JSON);
}

// ------------------------------------------------------------- sesiones ----

/**
 * Cambia el token de Google por una sesión nuestra.
 *
 * El token de Google dura una hora; la sesión dura meses. Sin este cambio, la
 * sincronización empezaría a fallar al rato sin motivo aparente.
 */
function entrar(p) {
  var cuenta = verificarTokenDeGoogle(p.idToken);
  if (!cuenta.ok) return cuenta;

  var token = Utilities.getUuid();
  var hoja = hojaDe(HOJA_SESIONES);
  var expira = new Date(Date.now() + DIAS_DE_SESION * 86400000);
  hoja.appendRow([token, cuenta.usuarioId, cuenta.correo, ahoraIso(),
                  expira.toISOString()]);

  return { ok: true, token: token, usuarioId: cuenta.usuarioId,
           correo: cuenta.correo };
}

/** Le pregunta a Google si el token es de verdad y para quién es. */
function verificarTokenDeGoogle(idToken) {
  if (!idToken) return { ok: false, error: 'Falta el token de Google' };

  var respuesta = UrlFetchApp.fetch(
      'https://oauth2.googleapis.com/tokeninfo?id_token=' +
      encodeURIComponent(idToken), { muteHttpExceptions: true });
  if (respuesta.getResponseCode() !== 200) {
    return { ok: false, error: 'Google no reconoce esa cuenta' };
  }

  var datos = JSON.parse(respuesta.getContentText());

  // Sin esta comprobación, el token de CUALQUIER app de Google serviría para
  // entrar a los datos de la Red. Es la línea que sostiene la seguridad.
  if (CLIENTES_AUTORIZADOS.indexOf(datos.aud) === -1) {
    return { ok: false, error: 'Ese token no es de esta aplicación' };
  }
  if (Number(datos.exp) * 1000 < Date.now()) {
    return { ok: false, error: 'El token de Google ya venció' };
  }

  return { ok: true, usuarioId: datos.sub, correo: datos.email || '' };
}

/** Devuelve la sesión viva o null. */
function sesionDe(token) {
  if (!token) return null;
  var filas = hojaDe(HOJA_SESIONES).getDataRange().getValues();
  for (var i = 1; i < filas.length; i++) {
    if (String(filas[i][0]) === String(token)) {
      if (new Date(filas[i][4]).getTime() < Date.now()) return null;
      return { usuarioId: String(filas[i][1]), correo: String(filas[i][2]),
               fila: i + 1 };
    }
  }
  return null;
}

function salir(p) {
  var sesion = sesionDe(p.token);
  if (sesion) hojaDe(HOJA_SESIONES).deleteRow(sesion.fila);
  return { ok: true };
}

// ------------------------------------------------------------- descarga ----

/**
 * Descarga incremental con cursor `(updated_at, id)`.
 *
 * El cursor es la pareja, no solo la fecha: si diez filas se sellan en el mismo
 * milisegundo y el cursor fuera solo la fecha, o se repetirían para siempre o
 * se perderían. Con la pareja, la página siguiente empieza justo después de la
 * última fila entregada.
 */
function descargar(p) {
  var sesion = sesionDe(p.token);
  if (!sesion) return { ok: false, error: 'Sesión vencida', reentrar: true };

  if (!TABLAS[p.entidad]) {
    return { ok: false, error: 'Tabla desconocida: ' + p.entidad };
  }

  var publica = TABLAS_PUBLICAS.indexOf(p.entidad) !== -1;
  var hoja = hojaDe(p.entidad);
  var columnas = encabezados(hoja);
  var valores = hoja.getDataRange().getValues();
  var limite = Math.min(Number(p.limite) || 100, MAXIMO_POR_PAGINA);
  var desde = p.desde || '';
  var desdeId = p.desdeId || '';

  var filas = [];
  for (var i = 1; i < valores.length; i++) {
    var fila = aObjeto(columnas, valores[i]);
    if (!fila.id) continue;
    if (!publica && fila.usuario_id !== sesion.usuarioId) continue;
    if (desde) {
      if (fila.updated_at < desde) continue;
      if (fila.updated_at === desde && desdeId && fila.id <= desdeId) continue;
    }
    filas.push(fila);
  }

  filas.sort(function (a, b) {
    if (a.updated_at === b.updated_at) return a.id < b.id ? -1 : 1;
    return a.updated_at < b.updated_at ? -1 : 1;
  });

  return { ok: true, filas: filas.slice(0, limite) };
}

// ----------------------------------------------------------------- subida --

/**
 * Sube filas nuevas o cambiadas. Devuelve cada fila COMO QUEDÓ en el servidor:
 * el teléfono necesita el `updated_at` sellado aquí para saber que ya está al
 * día y no volver a mandarla.
 */
function subir(p) {
  var sesion = sesionDe(p.token);
  if (!sesion) return { ok: false, error: 'Sesión vencida', reentrar: true };

  if (!TABLAS[p.entidad]) {
    return { ok: false, error: 'Tabla desconocida: ' + p.entidad };
  }
  if (TABLAS_PUBLICAS.indexOf(p.entidad) !== -1) {
    return { ok: false, error: 'Esa tabla es de solo lectura' };
  }

  var entrantes = p.filas || [];
  if (!entrantes.length) return { ok: true, filas: [] };

  // Sin candado, dos teléfonos sincronizando al tiempo se pisan la misma fila
  // de la hoja. Esperar es preferible a perder un registro.
  var candado = LockService.getScriptLock();
  if (!candado.tryLock(30000)) {
    return { ok: false, error: 'El servidor está ocupado, intente otra vez' };
  }

  try {
    var hoja = hojaDe(p.entidad);
    var columnas = encabezados(hoja);
    var valores = hoja.getDataRange().getValues();
    var dondeEsta = {};
    for (var i = 1; i < valores.length; i++) {
      if (valores[i][0]) dondeEsta[String(valores[i][0])] = i + 1;
    }

    var guardadas = [];
    var nuevas = [];
    entrantes.forEach(function (entrante) {
      if (!entrante.id) return;
      var numeroDeFila = dondeEsta[String(entrante.id)];

      if (numeroDeFila) {
        var actual = aObjeto(columnas, valores[numeroDeFila - 1]);
        // Nadie puede escribir encima de los datos de otro productor.
        if (actual.usuario_id && actual.usuario_id !== sesion.usuarioId) return;
      }

      var fila = {};
      columnas.forEach(function (c) {
        fila[c] = entrante[c] === undefined || entrante[c] === null
            ? '' : String(entrante[c]);
      });
      fila.usuario_id = sesion.usuarioId;
      fila.updated_at = nuevoSello();
      if (!fila.created_at) fila.created_at = fila.updated_at;

      if (numeroDeFila) {
        hoja.getRange(numeroDeFila, 1, 1, columnas.length)
            .setValues([aLista(columnas, fila)]);
      } else {
        nuevas.push(aLista(columnas, fila));
      }
      guardadas.push(fila);
    });

    if (nuevas.length) {
      hoja.getRange(hoja.getLastRow() + 1, 1, nuevas.length, columnas.length)
          .setValues(nuevas);
    }
    SpreadsheetApp.flush();
    return { ok: true, filas: guardadas };
  } finally {
    candado.releaseLock();
  }
}

// ------------------------------------------------------------- utilidades --

/// Los nombres de columna tal como están en la hoja, en su orden real.
///
/// Todo se lee y se escribe por este orden y no por el de TABLAS: así, si
/// alguien agrega una columna o el script gana campos nuevos, las filas que ya
/// existen siguen cuadrando.
function encabezados(hoja) {
  var ancho = hoja.getLastColumn();
  if (!ancho) return [];
  return hoja.getRange(1, 1, 1, ancho).getValues()[0].map(String);
}

function hojaDe(nombre) {
  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var hoja = libro.getSheetByName(nombre);
  if (!hoja) throw new Error('Falta la hoja "' + nombre + '". Ejecute instalar().');
  return hoja;
}

function aObjeto(columnas, valores) {
  var fila = {};
  columnas.forEach(function (c, i) {
    fila[c] = valores[i] === undefined || valores[i] === null
        ? '' : String(valores[i]);
  });
  return fila;
}

function aLista(columnas, fila) {
  return columnas.map(function (c) { return fila[c]; });
}

function ahoraIso() {
  return new Date().toISOString();
}

/**
 * Sello de tiempo que nunca se repite ni retrocede.
 *
 * Dos filas guardadas en el mismo milisegundo tendrían el mismo `updated_at`, y
 * el cursor de descarga se volvería ambiguo. Aquí se empuja un milisegundo.
 */
function nuevoSello() {
  var memoria = PropertiesService.getScriptProperties();
  var ultimo = Number(memoria.getProperty('ultimoSello') || 0);
  var ahora = Math.max(Date.now(), ultimo + 1);
  memoria.setProperty('ultimoSello', String(ahora));
  return new Date(ahora).toISOString();
}
