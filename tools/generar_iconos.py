"""Genera los íconos PWA de la app (mazorca de cacao) en vez del logo de
Flutter por defecto. Usa la misma paleta que `lib/ui/tema.dart`.

Uso: python tools/generar_iconos.py
"""

import math
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent.parent
ICONOS = RAIZ / "web" / "icons"

VERDE = (0x2F, 0x6B, 0x3A)
CAFE = (0x7A, 0x4A, 0x2B)
VERDE_CLARO = (0xD9, 0xEB, 0xD4)
BLANCO = (0xFF, 0xFF, 0xFF)
SURCO = (0x00, 0x00, 0x00, 40)


def fondo_degradado(size):
    """Degradado diagonal verde -> café, igual a PaletaCacao.cabecera."""
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * size)
            r = round(VERDE[0] + (CAFE[0] - VERDE[0]) * t)
            g = round(VERDE[1] + (CAFE[1] - VERDE[1]) * t)
            b = round(VERDE[2] + (CAFE[2] - VERDE[2]) * t)
            px[x, y] = (r, g, b)
    return img


def punto_cubico(p0, p1, p2, p3, t):
    mt = 1 - t
    x = (mt**3) * p0[0] + 3 * (mt**2) * t * p1[0] + 3 * mt * (t**2) * p2[0] + (t**3) * p3[0]
    y = (mt**3) * p0[1] + 3 * (mt**2) * t * p1[1] + 3 * mt * (t**2) * p2[1] + (t**3) * p3[1]
    return (x, y)


def curva(p0, p1, p2, p3, pasos=24):
    return [punto_cubico(p0, p1, p2, p3, i / pasos) for i in range(pasos + 1)]


def dibujar_mazorca(size, escala):
    """Capa RGBA con la mazorca (y su hoja), del mismo tamaño que el ícono."""
    capa = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    dibujo = ImageDraw.Draw(capa)

    w = h = size * escala
    ox = (size - w) / 2
    oy = (size - h) / 2

    def p(x, y):
        return (ox + x, oy + y)

    alto = h * 0.78
    ancho = w * 0.46
    cx = w * 0.5
    arriba = h * 0.16
    abajo = arriba + alto

    lado_derecho = curva(
        p(cx, arriba),
        p(cx + ancho, arriba + alto * 0.18),
        p(cx + ancho * 0.92, abajo - alto * 0.12),
        p(cx, abajo),
    )
    lado_izquierdo = curva(
        p(cx, abajo),
        p(cx - ancho * 0.92, abajo - alto * 0.12),
        p(cx - ancho, arriba + alto * 0.18),
        p(cx, arriba),
    )
    fruto = lado_derecho + lado_izquierdo

    # Rotación leve, igual que en el widget Mazorca de la app.
    centro = (size / 2, size / 2)
    angulo = math.radians(-10)
    cos_a, sin_a = math.cos(angulo), math.sin(angulo)

    def rotar(pt):
        dx, dy = pt[0] - centro[0], pt[1] - centro[1]
        return (
            centro[0] + dx * cos_a - dy * sin_a,
            centro[1] + dx * sin_a + dy * cos_a,
        )

    fruto_rot = [rotar(pt) for pt in fruto]
    dibujo.polygon(fruto_rot, fill=BLANCO)

    # Surcos.
    grosor = max(2, round(w * 0.02))
    for desvio in (-0.5, 0.0, 0.5):
        surco = curva(
            p(cx + ancho * 0.12 * desvio, arriba + alto * 0.08),
            p(cx + ancho * (0.55 * desvio + 0.06), arriba + alto * 0.35),
            p(cx + ancho * (0.55 * desvio + 0.06), abajo - alto * 0.3),
            p(cx + ancho * 0.12 * desvio, abajo - alto * 0.06),
        )
        surco_rot = [rotar(pt) for pt in surco]
        dibujo.line(surco_rot, fill=SURCO, width=grosor, joint="curve")

    # Pedúnculo.
    tallo = [rotar(p(cx, arriba)), rotar(p(cx - w * 0.04, arriba - h * 0.1))]
    dibujo.line(tallo, fill=BLANCO, width=max(3, round(w * 0.035)))

    # Hoja.
    base = p(cx - w * 0.04, arriba - h * 0.07)
    hoja = [
        base,
        (base[0] + w * 0.2, base[1] - h * 0.14),
        (base[0] + w * 0.28, base[1] - h * 0.02),
        (base[0] + w * 0.16, base[1] + h * 0.06),
        base,
    ]
    hoja_rot = [rotar(pt) for pt in hoja]
    dibujo.polygon(hoja_rot, fill=VERDE_CLARO)

    return capa


def generar(nombre, size, escala):
    base = fondo_degradado(size).convert("RGBA")
    mazorca = dibujar_mazorca(size, escala)
    base.alpha_composite(mazorca)
    destino = ICONOS / nombre
    base.convert("RGB").save(destino, "PNG")
    print(f"escrito {destino} ({size}x{size}, escala {escala})")


def main():
    ICONOS.mkdir(parents=True, exist_ok=True)
    # Normales: la mazorca ocupa casi todo el lienzo.
    generar("Icon-192.png", 192, 0.72)
    generar("Icon-512.png", 512, 0.72)
    # Maskable: el sistema recorta un círculo, así que se deja más margen
    # (zona segura) para que la mazorca no quede cortada.
    generar("Icon-maskable-192.png", 192, 0.52)
    generar("Icon-maskable-512.png", 512, 0.52)

    # Favicon: mismo diseño, chico.
    favicon = fondo_degradado(64).convert("RGBA")
    favicon.alpha_composite(dibujar_mazorca(64, 0.72))
    favicon.convert("RGB").save(RAIZ / "web" / "favicon.png", "PNG")
    print(f"escrito {RAIZ / 'web' / 'favicon.png'} (64x64)")

    # Apple touch icon dedicado (180x180 es lo que espera iOS para el ícono
    # nítido en la pantalla de inicio).
    apple = fondo_degradado(180).convert("RGBA")
    apple.alpha_composite(dibujar_mazorca(180, 0.72))
    apple.convert("RGB").save(ICONOS / "Icon-apple-180.png", "PNG")
    print(f"escrito {ICONOS / 'Icon-apple-180.png'} (180x180)")


if __name__ == "__main__":
    main()
