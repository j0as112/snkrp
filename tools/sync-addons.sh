#!/bin/sh
# Sincroniza el codigo (.lua + addon.json) de los addons propios desde la carpeta maestra del Escritorio
# (la que usa el servidor por enlace) hacia este repo. Ejecutar antes de commitear cambios en SNKtitanes/SNKarmas.
for a in SNKtitanes SNKarmas; do
  (cd "/c/Users/r380/Desktop/$a" && find . -type f \( -name "*.lua" -o -name "addon.json" \) -print0 | xargs -0 -I{} cp --parents {} "/d/snk/addons/$a/")
done
echo "Addons sincronizados."
