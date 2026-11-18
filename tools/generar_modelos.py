"""Dibuja los modelos del sistema que pide el documento del seminario.

    python3 tools/generar_modelos.py

Deja en `docs/modelos/` cuatro SVG —arquitectura, IDEF0 A0, IDEF0 A1 y
entidad-relación— y, en macOS, una copia PNG de cada uno para pegar en el
informe de Word.

Por qué se generan y no se dibujan a mano: los modelos tienen que ser los de la
aplicación de verdad, no los de la propuesta. La propuesta dibujaba cuatro
entidades; la app tiene siete más dos de servicio. Un diagrama hecho a mano en
un editor se queda atrás la primera vez que alguien agrega una columna, y nadie
lo nota hasta la sustentación. Aquí el contenido vive en texto, junto al código,
y volver a dibujar es correr esto.

Si cambia el esquema (`lib/data/local/tables.dart`), se actualiza la sección
ENTIDAD-RELACIÓN de abajo y se vuelve a correr.

Solo usa la biblioteca estándar: no hay que instalar nada.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from html import escape
from pathlib import Path

SALIDA = Path(__file__).resolve().parent.parent / "docs" / "modelos"

FUENTE = "Helvetica, Arial, sans-serif"
TINTA = "#1F1A17"
CAFE = "#5A3A22"
CAFE_CLARO = "#F3E7D6"
VERDE = "#2E5233"
GRIS = "#6B625B"


# --------------------------------------------------------------- dibujo ----


class Lienzo:
    def __init__(self, ancho: int, alto: int, titulo: str):
        self.ancho, self.alto = ancho, alto
        self.partes: list[str] = []
        self.titulo = titulo

    def add(self, s: str) -> None:
        self.partes.append(s)

    def texto(self, x, y, s, tam=15, peso="normal", ancla="start",
              color=TINTA, estilo="normal"):
        self.add(
            f'<text x="{x}" y="{y}" font-size="{tam}" font-weight="{peso}" '
            f'font-style="{estilo}" text-anchor="{ancla}" fill="{color}" '
            f'font-family="{FUENTE}">{escape(s)}</text>'
        )

    def lineas(self, x, y, renglones, tam=15, peso="normal", ancla="start",
               color=TINTA, interlinea=1.25):
        for i, r in enumerate(renglones):
            self.texto(x, y + i * tam * interlinea, r, tam, peso, ancla, color)

    def caja(self, x, y, w, h, relleno="#FFFFFF", borde=TINTA, grueso=2,
             radio=0):
        self.add(
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{radio}" '
            f'fill="{relleno}" stroke="{borde}" stroke-width="{grueso}"/>'
        )

    def flecha(self, puntos, color=TINTA, grueso=1.8, punta=True,
               discontinua=False):
        d = " ".join(f"{x},{y}" for x, y in puntos)
        guion = ' stroke-dasharray="6 5"' if discontinua else ""
        marca = ' marker-end="url(#punta)"' if punta else ""
        self.add(
            f'<polyline points="{d}" fill="none" stroke="{color}" '
            f'stroke-width="{grueso}"{guion}{marca}/>'
        )

    def puente(self, x, y):
        """Hueco blanco donde una flecha cruza a otra sin tocarla."""
        self.add(f'<rect x="{x - 5}" y="{y - 5}" width="10" height="10" '
                 f'fill="#FFFFFF"/>')

    def svg(self) -> str:
        cabeza = (
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.ancho}" '
            f'height="{self.alto}" viewBox="0 0 {self.ancho} {self.alto}">'
            f"<title>{escape(self.titulo)}</title>"
            '<defs><marker id="punta" viewBox="0 0 10 10" refX="9" refY="5" '
            'markerWidth="9" markerHeight="9" orient="auto-start-reverse">'
            f'<path d="M0,0 L10,5 L0,10 z" fill="{TINTA}"/></marker></defs>'
            f'<rect width="100%" height="100%" fill="#FFFFFF"/>'
        )
        return cabeza + "".join(self.partes) + "</svg>\n"


def partir(texto: str, ancho: int) -> list[str]:
    """Parte un texto en renglones de a lo sumo `ancho` caracteres."""
    renglones, actual = [], ""
    for palabra in texto.split():
        prueba = f"{actual} {palabra}".strip()
        if len(prueba) > ancho and actual:
            renglones.append(actual)
            actual = palabra
        else:
            actual = prueba
    if actual:
        renglones.append(actual)
    return renglones


def actividad(lz: Lienzo, x, y, w, h, nombre, nodo, ancho_texto=24):
    """Una caja de IDEF0: el verbo adentro y el número en la esquina."""
    lz.caja(x, y, w, h, relleno="#FFFFFF", grueso=2.4)
    renglones = partir(nombre, ancho_texto)
    alto_texto = len(renglones) * 17 * 1.25
    lz.lineas(x + w / 2, y + h / 2 - alto_texto / 2 + 14, renglones, tam=17,
              peso="bold", ancla="middle")
    lz.texto(x + w - 8, y + h - 8, nodo, tam=14, peso="bold", ancla="end",
             color=CAFE)


def pie(lz: Lienzo, nodo, titulo, numero):
    """El marco de abajo que lleva todo diagrama IDEF0."""
    y = lz.alto - 44
    lz.add(f'<line x1="0" y1="{y}" x2="{lz.ancho}" y2="{y}" stroke="{TINTA}" '
           'stroke-width="1.5"/>')
    lz.texto(20, y + 28, "NODO:", tam=13, peso="bold", color=GRIS)
    lz.texto(78, y + 28, nodo, tam=15, peso="bold")
    lz.texto(170, y + 28, "TÍTULO:", tam=13, peso="bold", color=GRIS)
    lz.texto(238, y + 28, titulo, tam=15, peso="bold")
    lz.texto(lz.ancho - 20, y + 28, numero, tam=13, ancla="end", color=GRIS)


# ------------------------------------------------------- IDEF0: el A0 ----

# Lo que entra, lo que controla, lo que sale y con qué se hace. Los códigos
# (I1, C1…) son los mismos en el A0 y en el A1: así se sigue cada flecha de
# un nivel al otro.
ENTRADAS = [
    ("I1", "Datos del productor, la finca y los lotes"),
    ("I2", "Labores hechas en el campo y lo que costaron"),
    ("I3", "Cosechas recogidas"),
    ("I4", "Estado observado del cultivo"),
]
CONTROLES = [
    ("C1", "Buenas Prácticas Agrícolas (Res. ICA 30021 de 2017)"),
    ("C2", "Plazo de 7 días para corregir un registro"),
    ("C3", "Reglas de sincronización y conflictos"),
    ("C4", "Política de privacidad y condiciones de uso"),
    ("C5", "Datos mínimos para el costo: kilos y costo de cada labor"),
]
SALIDAS = [
    ("O1", "Historial de labores, cosechas y diagnósticos"),
    ("O2", "Indicadores y reportes por finca y por lote"),
    ("O3", "Costo de producción por kilo"),
    ("O4", "Recordatorios de labores pendientes"),
    ("O5", "Información consolidada para la Red y el técnico"),
]
MECANISMOS = [
    ("M1", "Productor con teléfono Android o navegador"),
    ("M2", "Aplicación Cacaiva (Flutter)"),
    ("M3", "Base de datos local SQLite (Drift)"),
    ("M4", "Google Apps Script y Google Sheets"),
    ("M5", "GPS y dictado por voz del teléfono"),
]


def idef0_a0() -> Lienzo:
    lz = Lienzo(1500, 1000, "IDEF0 A0 — Cacaiva")
    bx, by, bw, bh = 560, 380, 380, 190

    # Entradas: por la izquierda.
    for i, (cod, txt) in enumerate(ENTRADAS):
        y = by + 35 + i * 40
        lz.flecha([(30, y), (bx, y)])
        lz.texto(40, y - 8, f"{cod}  {txt}", tam=14)

    # Controles: por arriba. Se escalonan para que los rótulos no choquen.
    xs = [bx + 40 + i * 75 for i in range(len(CONTROLES))]
    for i, ((cod, txt), x) in enumerate(zip(CONTROLES, xs)):
        y0 = 40 + i * 50
        lz.flecha([(x, y0), (x, by)])
        lz.texto(x + 8, y0 + 4, cod, tam=14, peso="bold")
        lz.lineas(x + 42, y0 + 4, partir(txt, 46), tam=14)

    # Salidas: por la derecha.
    for i, (cod, txt) in enumerate(SALIDAS):
        y = by + 25 + i * 35
        lz.flecha([(bx + bw, y), (1470, y)])
        lz.texto(bx + bw + 12, y - 8, f"{cod}  {txt}", tam=14)

    # Mecanismos: por abajo, hacia arriba.
    xs = [bx + 30 + i * 80 for i in range(len(MECANISMOS))]
    for i, ((cod, txt), x) in enumerate(zip(MECANISMOS, xs)):
        y0 = 920 - i * 52
        lz.flecha([(x, y0), (x, by + bh)])
        lz.texto(x + 8, y0 - 4, cod, tam=14, peso="bold")
        lz.lineas(x + 42, y0 - 4, partir(txt, 40), tam=14)

    actividad(lz, bx, by, bw, bh,
              "Gestionar la información productiva del cultivo de cacao",
              "A0", ancho_texto=26)
    pie(lz, "A-0", "Gestionar la información productiva del cultivo de cacao",
        "Cacaiva · Seminario 2026-2")
    return lz


# ------------------------------------------------------- IDEF0: el A1 ----


def idef0_a1() -> Lienzo:
    lz = Lienzo(1500, 1000, "IDEF0 A1 — Cacaiva")
    W, H = 250, 120
    a1 = (130, 150)
    a2 = (440, 390)
    a3 = (900, 150)
    a4 = (900, 420)
    a5 = (900, 690)

    # -- Entradas desde el borde izquierdo.
    y = a1[1] + 45
    lz.flecha([(20, y), a1[0:1] + (y,)])
    lz.texto(26, y - 8, "I1", tam=14, peso="bold")
    lz.lineas(26, y + 20, partir(ENTRADAS[0][1], 14), tam=13, color=GRIS)
    for i, (cod, _) in enumerate(ENTRADAS[1:]):
        y = a2[1] + 55 + i * 22
        lz.flecha([(20, y), (a2[0], y)])
        lz.texto(26, y - 5, cod, tam=14, peso="bold")
    lz.lineas(70, a2[1] + 140, ["I2 Labores y sus costos",
                                "I3 Cosechas recogidas",
                                "I4 Estado del cultivo"], tam=13, color=GRIS)

    # -- A1 → A2: el perfil y los lotes que quedan registrados.
    ya1 = a1[1] + 80
    yin = a2[1] + 30
    lz.flecha([(a1[0] + W, ya1), (410, ya1), (410, yin), (a2[0], yin)])
    lz.lineas(416, ya1 + 22, ["Productor,", "finca y lotes", "registrados"],
              tam=13)

    # -- A2 → A3, A4, A5: los registros guardados en el teléfono.
    yout = a2[1] + H / 2
    bus = 790
    lz.flecha([(a2[0] + W, yout), (bus, yout)], punta=False)
    lz.flecha([(bus, a3[1] + 40), (bus, a5[1] + 40)], punta=False)
    for caja in (a3, a4, a5):
        lz.flecha([(bus, caja[1] + 40), (caja[0], caja[1] + 40)])
    lz.lineas(a2[0] + W + 8, yout + 22, ["Registros",
                                          "guardados en", "el teléfono"],
              tam=13)

    # -- A3 devuelve a la base lo que bajó del servidor: la información de
    #    los otros teléfonos de la misma cuenta.
    yr = a3[1] + 85
    lz.flecha([(a3[0], yr), (840, yr), (840, a2[1] - 40),
               (a2[0] + 190, a2[1] - 40), (a2[0] + 190, a2[1])],
              discontinua=True)
    lz.lineas(a2[0] + 196, a2[1] - 95, ["Datos bajados de",
                                         "otros teléfonos", "de la cuenta"],
              tam=13, color=GRIS)

    # -- Controles desde arriba.
    def control(x, caja, cods, alto=40):
        lz.flecha([(x, alto), (x, caja[1])])
        lz.texto(x + 6, alto + 14, cods, tam=14, peso="bold")

    control(a1[0] + 125, a1, "C4")
    control(a2[0] + 70, a2, "C1")
    control(a2[0] + 120, a2, "C2")
    control(a3[0] + 125, a3, "C3, C4")
    # C5 baja por fuera, a la derecha, y cruza las salidas de A4 con un puente.
    xc5 = 1210
    lz.flecha([(xc5, 40), (xc5, a5[1] - 30), (a5[0] + 125, a5[1] - 30),
               (a5[0] + 125, a5[1])])
    lz.texto(xc5 + 6, 54, "C5", tam=14, peso="bold")

    # -- Salidas hacia el borde derecho.
    def salida(caja, dy, cod, puente=False):
        y = caja[1] + dy
        lz.flecha([(caja[0] + W, y), (1480, y)])
        if puente:
            lz.puente(xc5, y)
            lz.flecha([(xc5, y - 6), (xc5, y + 6)], punta=False)
        lz.texto(1455, y - 10, cod, tam=14, peso="bold", ancla="end")

    salida(a3, 45, "O5", puente=True)
    salida(a4, 30, "O1", puente=True)
    salida(a4, 60, "O2", puente=True)
    salida(a4, 90, "O4", puente=True)
    salida(a5, 60, "O3")

    # -- Mecanismos: un tramo corto debajo de cada caja con sus códigos. Los
    #    mismos M1-M3 sirven a todas; dibujar cada uno desde el borde
    #    cruzaría todas las entradas.
    def mecanismos(caja, cods):
        x = caja[0] + W / 2
        lz.flecha([(x, caja[1] + H + 34), (x, caja[1] + H)])
        lz.texto(x, caja[1] + H + 52, cods, tam=13, ancla="middle",
                 color=GRIS)

    mecanismos(a1, "M1 · M2 · M3 · M5")
    mecanismos(a2, "M1 · M2 · M3 · M5")
    mecanismos(a3, "M2 · M3 · M4")
    mecanismos(a4, "M1 · M2 · M3")
    mecanismos(a5, "M1 · M2 · M3")

    actividad(lz, *a1, W, H, "Registrar productor, finca y lotes", "A1", 20)
    actividad(lz, *a2, W, H, "Registrar labores, cosechas y diagnósticos",
              "A2", 22)
    actividad(lz, *a3, W, H, "Sincronizar con la nube", "A3", 20)
    actividad(lz, *a4, W, H, "Consultar historial, reportes y recordatorios",
              "A4", 22)
    actividad(lz, *a5, W, H, "Calcular el costo por kilo", "A5", 20)

    pie(lz, "A0", "Gestionar la información productiva del cultivo de cacao",
        "Cacaiva · Seminario 2026-2")
    return lz


# -------------------------------------------------------- arquitectura ----


def arquitectura() -> Lienzo:
    lz = Lienzo(1400, 900, "Arquitectura de Cacaiva")

    def capa(x, y, w, h, titulo, detalle, relleno, borde=CAFE):
        lz.caja(x, y, w, h, relleno=relleno, borde=borde, grueso=2, radio=12)
        lz.texto(x + w / 2, y + 34, titulo, tam=19, peso="bold",
                 ancla="middle", color=borde)
        lz.lineas(x + w / 2, y + 62, detalle, tam=14, ancla="middle")

    lz.texto(60, 50, "EN EL TELÉFONO", tam=14, peso="bold", color=GRIS)
    lz.add(f'<rect x="40" y="62" width="760" height="760" rx="18" '
           f'fill="none" stroke="{GRIS}" stroke-width="1.5" '
           'stroke-dasharray="8 6"/>')

    capa(80, 90, 680, 120, "1 · Interfaz de usuario (Flutter)",
         ["Inicio · Lote · Anotar · Reportes · Costo por kilo · Perfil",
          "Lo que ve y toca el productor"], CAFE_CLARO)
    capa(80, 270, 680, 140, "2 · Lógica de la aplicación",
         ["Repositorios: Perfil · Lote · Reportes",
          "Recordatorios · Costo por kilo · Plazo de 7 días",
          "Reglas de negocio, sin pantallas ni red"], "#FFFFFF")
    capa(80, 470, 680, 130, "3 · Base de datos local (Drift / SQLite)",
         ["FUENTE DE VERDAD: todo se guarda aquí primero",
          "Funciona sin señal"], "#E6F0E8", borde=VERDE)
    capa(80, 660, 680, 130, "Servicio de sincronización",
         ["Sube lo pendiente, baja lo nuevo",
          "Borrado suave · sellos del servidor · conflictos"], "#FFFFFF",
         borde=GRIS)

    for y1, y2 in ((210, 270), (410, 470), (600, 660)):
        lz.flecha([(420, y1), (420, y2)])
        lz.flecha([(440, y2), (440, y1)])

    lz.texto(880, 585, "EN LA NUBE", tam=14, peso="bold", color=GRIS)
    capa(880, 600, 460, 220, "Google Apps Script",
         ["Sesiones con la cuenta de Google",
          "Recibe y entrega los registros",
          "", "Google Sheets", "Una hoja por tabla"], "#FFFFFF", borde=CAFE)
    lz.flecha([(760, 715), (880, 715)])
    lz.flecha([(880, 745), (760, 745)])
    lz.texto(840, 700, "HTTPS", tam=13, ancla="middle", color=GRIS)
    lz.lineas(840, 772, ["cuando", "hay señal"], tam=13, ancla="middle",
              color=GRIS)

    lz.texto(880, 140, "La aplicación es offline-first", tam=17, peso="bold",
             color=CAFE)
    for i, (titulo, cuerpo) in enumerate([
        ("Nunca espera al servidor.",
         ["Todo se guarda primero en el teléfono."]),
        ("Cada registro queda «pendiente».",
         ["Con señal, se sube lo pendiente", "y se baja lo nuevo."]),
        ("Las capas 1, 2 y 3",
         ["son los tres componentes que pide", "el documento del seminario."]),
        ("La nube permite compartir una cuenta",
         ["entre dos teléfonos, y que la Red", "vea la información consolidada."]),
    ]):
        y = 190 + i * 92
        lz.texto(880, y, titulo, tam=15, peso="bold")
        lz.lineas(880, y + 22, cuerpo, tam=15, color=GRIS)
    return lz


# ---------------------------------------------------- entidad-relación ----

# (nombre en la base, atributos). Una marca al comienzo dice qué es:
#   "PK " llave primaria · "FK " llave foránea · "   " atributo
ENTIDADES = {
    "asociaciones": [
        "PK id", "   nombre", "   municipio", "   departamento"],
    "productores": [
        "PK id", "FK asociacion_id (opcional)", "   usuario_id",
        "   nombre_completo", "   tipo_documento", "   numero_documento",
        "   telefono", "   email"],
    "fincas": [
        "PK id", "FK productor_id", "   nombre", "   municipio",
        "   departamento", "   latitud, longitud"],
    "lotes": [
        "PK id", "FK finca_id", "   codigo", "   nombre",
        "   area_sembrada_ha", "   variedad_cacao", "   fecha_siembra",
        "   latitud, longitud"],
    "actividades_agricolas": [
        "PK id", "FK lote_id", "   tipo_actividad", "   fecha",
        "   subtipo_labor", "   responsable", "   costo",
        "   costo_total_compartido", "   producto, cantidad_aplicada",
        "   incidencia", "   arboles_afectados, arboles_sembrados",
        "   edad_cultivo_anios, edad_plantula_meses", "   insumos",
        "   resultado_esperado", "   observaciones"],
    "cosechas": [
        "PK id", "FK lote_id", "   fecha", "   cantidad_kg",
        "   tipo_producto", "   observaciones"],
    "diagnosticos": [
        "PK id", "FK lote_id", "   fecha", "   estado_fenologico",
        "   notas"],
}

COLUMNAS_COMUNES = [
    "created_at · updated_at", "deleted_at (borrado suave)",
    "server_updated_at", "sync_status · sync_error"]


def entidad(lz: Lienzo, x, y, w, nombre, atributos) -> tuple[int, int, int, int]:
    alto_fila = 22
    h = 38 + alto_fila * len(atributos) + 10
    lz.caja(x, y, w, h, relleno="#FFFFFF", borde=CAFE, grueso=2, radio=6)
    lz.add(f'<rect x="{x}" y="{y}" width="{w}" height="36" rx="6" '
           f'fill="{CAFE}"/>')
    lz.add(f'<rect x="{x}" y="{y + 20}" width="{w}" height="16" '
           f'fill="{CAFE}"/>')
    lz.texto(x + w / 2, y + 24, nombre, tam=16, peso="bold", ancla="middle",
             color="#FFFFFF")
    for i, a in enumerate(atributos):
        marca, texto = a[:2].strip(), a[3:]
        yy = y + 58 + i * alto_fila
        if marca:
            lz.texto(x + 10, yy, marca, tam=12, peso="bold",
                     color=VERDE if marca == "PK" else CAFE)
        lz.texto(x + 42, yy, texto, tam=14,
                 peso="bold" if marca == "PK" else "normal")
    return x, y, w, h


def pata_de_gallo(lz: Lienzo, x, y, hacia: str):
    """El extremo «muchos» de una relación, en el punto (x, y)."""
    d = 14
    if hacia == "abajo":    # la entidad hija queda abajo
        lz.add(f'<path d="M{x - 9},{y} L{x},{y - d} L{x + 9},{y}" '
               f'fill="none" stroke="{TINTA}" stroke-width="1.8"/>')
        lz.add(f'<circle cx="{x}" cy="{y - d - 7}" r="5" fill="#FFFFFF" '
               f'stroke="{TINTA}" stroke-width="1.8"/>')
    elif hacia == "derecha":
        lz.add(f'<path d="M{x},{y - 9} L{x - d},{y} L{x},{y + 9}" '
               f'fill="none" stroke="{TINTA}" stroke-width="1.8"/>')
        lz.add(f'<circle cx="{x - d - 7}" cy="{y}" r="5" fill="#FFFFFF" '
               f'stroke="{TINTA}" stroke-width="1.8"/>')


def uno_obligatorio(lz: Lienzo, x, y, vertical: bool):
    """El extremo «exactamente uno»: dos rayas."""
    for k in (8, 16):
        if vertical:
            lz.add(f'<line x1="{x - 8}" y1="{y + k}" x2="{x + 8}" '
                   f'y2="{y + k}" stroke="{TINTA}" stroke-width="1.8"/>')
        else:
            lz.add(f'<line x1="{x + k}" y1="{y - 8}" x2="{x + k}" '
                   f'y2="{y + 8}" stroke="{TINTA}" stroke-width="1.8"/>')


def entidad_relacion() -> Lienzo:
    lz = Lienzo(1500, 1130, "Modelo entidad-relación — Cacaiva")
    W = 300

    aso = entidad(lz, 60, 40, 250, "asociaciones", ENTIDADES["asociaciones"])
    pro = entidad(lz, 420, 40, W, "productores", ENTIDADES["productores"])
    fin = entidad(lz, 820, 40, 260, "fincas", ENTIDADES["fincas"])
    lot = entidad(lz, 1180, 40, 280, "lotes", ENTIDADES["lotes"])

    act = entidad(lz, 520, 480, 380, "actividades_agricolas",
                  ENTIDADES["actividades_agricolas"])
    cos = entidad(lz, 960, 480, 250, "cosechas", ENTIDADES["cosechas"])
    dia = entidad(lz, 1240, 480, 230, "diagnosticos", ENTIDADES["diagnosticos"])

    def horizontal(padre, hijo, y, etiqueta, opcional_padre=False):
        x1 = padre[0] + padre[2]
        x2 = hijo[0]
        lz.flecha([(x1, y), (x2, y)], punta=False)
        if opcional_padre:
            lz.add(f'<circle cx="{x1 + 22}" cy="{y}" r="5" fill="#FFFFFF" '
                   f'stroke="{TINTA}" stroke-width="1.8"/>')
            lz.add(f'<line x1="{x1 + 10}" y1="{y - 8}" x2="{x1 + 10}" '
                   f'y2="{y + 8}" stroke="{TINTA}" stroke-width="1.8"/>')
        else:
            uno_obligatorio(lz, x1, y, vertical=False)
        pata_de_gallo(lz, x2, y, "derecha")
        lz.texto((x1 + x2) / 2, y - 12, etiqueta, tam=13, ancla="middle",
                 color=GRIS, estilo="italic")

    horizontal(aso, pro, 110, "agrupa", opcional_padre=True)
    horizontal(pro, fin, 110, "tiene")
    horizontal(fin, lot, 110, "se divide en")

    # Lote → sus tres registros: una barra horizontal que baja a cada uno.
    xl = lot[0] + lot[2] / 2
    ybarra = 440
    lz.flecha([(xl, lot[1] + lot[3]), (xl, ybarra)], punta=False)
    uno_obligatorio(lz, xl, lot[1] + lot[3], vertical=True)
    xs = [act[0] + act[2] / 2, cos[0] + cos[2] / 2, dia[0] + dia[2] / 2]
    lz.flecha([(min(xs), ybarra), (max(xs[-1], xl), ybarra)], punta=False)
    for x in xs:
        lz.flecha([(x, ybarra), (x, 480)], punta=False)
        pata_de_gallo(lz, x, 480, "abajo")
    lz.texto(xl + 10, ybarra - 12, "registra", tam=13, color=GRIS,
             estilo="italic")

    # Columnas comunes y tablas de servicio.
    y0 = 520
    lz.caja(60, y0, 400, 150, relleno=CAFE_CLARO, borde=CAFE, grueso=1.5,
            radio=8)
    lz.texto(80, y0 + 28, "En todas las tablas de datos", tam=15, peso="bold",
             color=CAFE)
    lz.lineas(80, y0 + 54, ["id: UUID creado en el teléfono"] +
              COLUMNAS_COMUNES, tam=14)

    y1 = 720
    lz.texto(60, y1, "TABLAS DE SERVICIO (no son del negocio)", tam=13,
             peso="bold", color=GRIS)
    for i, (nombre, attrs) in enumerate([
        ("sesion", ["una sola fila", "usuario_id · correo",
                    "token de la nube"]),
        ("sync_meta", ["una fila por tabla", "hasta dónde se bajó",
                       "(cursor de sincronización)"]),
    ]):
        x = 60 + i * 210
        lz.caja(x, y1 + 14, 190, 116, relleno="#FFFFFF", borde=GRIS,
                grueso=1.5, radio=6)
        lz.add(f'<rect x="{x}" y="{y1 + 14}" width="190" height="4" '
               f'fill="{GRIS}"/>')
        lz.texto(x + 95, y1 + 42, nombre, tam=15, peso="bold", ancla="middle",
                 color=GRIS)
        lz.lineas(x + 95, y1 + 66, attrs, tam=13, ancla="middle",
                  color=GRIS)

    # Leyenda.
    yl = 900
    lz.texto(60, yl, "CÓMO SE LEE", tam=13, peso="bold", color=GRIS)
    uno_obligatorio(lz, 60, yl + 30, vertical=False)
    lz.flecha([(60, yl + 30), (120, yl + 30)], punta=False)
    lz.texto(135, yl + 35, "exactamente uno", tam=14)
    lz.flecha([(60, yl + 64), (120, yl + 64)], punta=False)
    pata_de_gallo(lz, 120, yl + 64, "derecha")
    lz.texto(135, yl + 69, "cero o muchos", tam=14)
    lz.flecha([(60, yl + 98), (120, yl + 98)], punta=False)
    lz.add(f'<circle cx="82" cy="{yl + 98}" r="5" fill="#FFFFFF" '
           f'stroke="{TINTA}" stroke-width="1.8"/>')
    lz.add(f'<line x1="70" y1="{yl + 90}" x2="70" y2="{yl + 106}" '
           f'stroke="{TINTA}" stroke-width="1.8"/>')
    lz.texto(135, yl + 103, "cero o uno (opcional)", tam=14)
    lz.lineas(400, yl + 35, [
        "Un productor puede no pertenecer a ninguna asociación.",
        "Toda finca es de un productor; todo lote, de una finca; y toda",
        "labor, cosecha o diagnóstico, de un lote. Nada se borra de verdad:",
        "se marca deleted_at, para que el borrado viaje a los otros teléfonos.",
    ], tam=14, color=GRIS)
    return lz


# ------------------------------------------------------------- salida ----


def a_png(svg: Path, lz: Lienzo) -> bool:
    """Copia PNG con lo que trae macOS. En otro sistema, se sigue sin ella.

    `qlmanage` siempre entrega un cuadrado y **recorta** lo que no cabe, así
    que un diagrama apaisado perdía todo el lado derecho. Se le pasa el mismo
    dibujo centrado en un lienzo cuadrado y después `sips` le quita las
    franjas blancas que sobran.
    """
    if sys.platform != "darwin" or not (
            shutil.which("qlmanage") and shutil.which("sips")):
        return False
    lado = max(lz.ancho, lz.alto)
    px = 3000
    dx, dy = (lado - lz.ancho) / 2, (lado - lz.alto) / 2
    cuadrado = lz.svg().replace(
        f'width="{lz.ancho}" height="{lz.alto}" '
        f'viewBox="0 0 {lz.ancho} {lz.alto}"',
        f'width="{lado}" height="{lado}" '
        f'viewBox="{-dx} {-dy} {lado} {lado}"', 1)
    with tempfile.TemporaryDirectory() as tmp:
        fuente = Path(tmp) / svg.name
        fuente.write_text(cuadrado, encoding="utf-8")
        subprocess.run(["qlmanage", "-t", "-s", str(px), "-o", tmp,
                        str(fuente)], check=False, capture_output=True)
        hecho = Path(tmp) / (svg.name + ".png")
        if not hecho.exists():
            return False
        alto = round(px * lz.alto / lado)
        ancho = round(px * lz.ancho / lado)
        subprocess.run(["sips", "-c", str(alto), str(ancho), str(hecho)],
                       check=False, capture_output=True)
        shutil.move(str(hecho), svg.with_suffix(".png"))
    return True


def main() -> None:
    SALIDA.mkdir(parents=True, exist_ok=True)
    figuras = {
        "arquitectura": arquitectura(),
        "idef0-a0": idef0_a0(),
        "idef0-a1": idef0_a1(),
        "entidad-relacion": entidad_relacion(),
    }
    for nombre, lz in figuras.items():
        destino = SALIDA / f"{nombre}.svg"
        destino.write_text(lz.svg(), encoding="utf-8")
        png = "y .png" if a_png(destino, lz) else "(sin .png)"
        print(f"  {destino.relative_to(SALIDA.parent.parent)} {png}")


if __name__ == "__main__":
    main()
