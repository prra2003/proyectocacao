#!/usr/bin/env bash
#
# Publica la versión web en la página de la Red.
#
#     tools/publicar_web.sh
#
# Existe por una razón concreta, no por comodidad: la dirección principal
# —redcacao.vercel.app— está puesta a mano sobre una publicación concreta, no
# atada a "lo último". Un `vercel --prod` a secas deja la página servida en las
# otras direcciones y esta clavada en la versión vieja, sin avisar de nada. Ya
# pasó: la página estuvo 38 días atrás de lo que había en el repositorio y nadie
# lo notó hasta que un cambio nuevo "no aparecía".
#
# Mientras la dirección no se ate en Vercel (proyecto redcacao → Settings →
# Domains), publicar es compilar, subir, reapuntar las tres y comprobar que las
# tres contesten la misma versión. Eso es lo que hace esto.
set -euo pipefail

cd "$(dirname "$0")/.."

PROYECTO=prj_RbrpvY8xL7ajjZ9JQCI8AG14Eyh9
EQUIPO=team_Ee50Y6rUtro2opxe2FOlCMSJ
ALCANCE=cacao3

# La principal va primera: es la que el productor tiene guardada.
DIRECCIONES=(redcacao.vercel.app web-rust-tau-65.vercel.app redcacao-cacao3.vercel.app)

echo "==> Pruebas"
flutter analyze
flutter test

echo "==> Compilando"
flutter build web --release

VERSION=$(sed -n 's/^version: //p' pubspec.yaml)
echo "==> Publicando $VERSION"

mkdir -p build/web/.vercel
cat > build/web/.vercel/project.json <<JSON
{"projectId":"$PROYECTO","orgId":"$EQUIPO","projectName":"redcacao"}
JSON

NUEVA=$(cd build/web && vercel deploy --prod --yes --scope "$ALCANCE" \
  | grep -o 'https://redcacao-[a-z0-9]*-cacao3\.vercel\.app' | head -1)
[ -n "$NUEVA" ] || { echo "No se pudo leer la dirección publicada." >&2; exit 1; }
echo "    $NUEVA"

for direccion in "${DIRECCIONES[@]}"; do
  # Se guarda la salida y solo se muestra si algo falla: en lo normal son
  # tres banners del CLI que tapan lo único que importa, la comprobación.
  if salida=$(vercel alias set "${NUEVA#https://}" "$direccion" \
      --scope "$ALCANCE" 2>&1); then
    echo "    -> $direccion"
  else
    echo "$salida" >&2
    echo "No se pudo apuntar $direccion." >&2
    exit 1
  fi
done

echo "==> Comprobando que las tres contesten lo mismo"
sleep 10
fallo=0
for direccion in "${DIRECCIONES[@]}"; do
  respuesta=$(curl -s --max-time 30 "https://$direccion/version.json" || true)
  if grep -q "\"version\":\"${VERSION%%+*}\"" <<<"$respuesta" &&
     grep -q "\"build_number\":\"${VERSION##*+}\"" <<<"$respuesta"; then
    echo "    ok   $direccion"
  else
    echo "    MAL  $direccion -> ${respuesta:-sin respuesta}"
    fallo=1
  fi
done

[ "$fallo" -eq 0 ] || { echo "Alguna dirección no quedó en $VERSION." >&2; exit 1; }
echo "Listo: $VERSION en https://${DIRECCIONES[0]}"
