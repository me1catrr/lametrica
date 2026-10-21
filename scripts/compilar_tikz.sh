#!/usr/bin/env bash
# Compila las figuras TikZ de figures/fuentes/tikz/*.tex a SVG en figures/svg/.
# Ruta DVI -> dvisvgm (no necesita Ghostscript); las fuentes se convierten a trazados (--no-fonts)
# para que el SVG se vea igual en cualquier navegador.
# Uso:  scripts/compilar_tikz.sh [nombre ...]      (sin argumentos: todas)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
tmp="${TMPDIR:-/tmp}/lametrica-tikz"; mkdir -p "$tmp"
if [ "$#" -gt 0 ]; then fuentes=(); for n in "$@"; do fuentes+=("figures/fuentes/tikz/$n.tex"); done
else fuentes=(figures/fuentes/tikz/*.tex); fi
for f in "${fuentes[@]}"; do
  n="$(basename "$f" .tex)"
  echo "== $n"
  latex -interaction=nonstopmode -halt-on-error -output-directory="$tmp" "$f" >"$tmp/$n.log" 2>&1 \
    || { echo "ERROR de LaTeX (ver $tmp/$n.log)"; tail -20 "$tmp/$n.log"; exit 1; }
  dvisvgm --no-fonts --exact-bbox -o "figures/svg/$n.svg" "$tmp/$n.dvi" >/dev/null
  ls -l "figures/svg/$n.svg" | awk '{print "   ->", $9, $5, "bytes"}'
done
