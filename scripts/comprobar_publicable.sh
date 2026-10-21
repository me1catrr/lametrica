#!/usr/bin/env bash
# Comprueba que nada ajeno va a publicarse. Falla (código 1) si encuentra:
#   - archivos de docs/ versionados o preparados para subir,
#   - formatos de documento/figura de terceros (pdf, eps, tex, docx...) versionados,
#     salvo las fuentes TikZ propias de figures/fuentes/tikz/,
#   - rutas locales (/Users/...) en archivos versionados.
# Uso manual:   scripts/comprobar_publicable.sh
# Como hook:    ln -sf ../../scripts/comprobar_publicable.sh .git/hooks/pre-push
set -u
cd "$(git rev-parse --show-toplevel)"
fallo=0

# Excepción por carpeta (solo fuentes TikZ propias), en consonancia con .gitignore.
tikz_originales='^figures/fuentes/tikz/[A-Za-z0-9_-]+\.tex$'
malos=$(git ls-files | grep -E '^docs/|\.(pdf|eps|ai|ps|dvi|tex|docx|pptx|zip)$' | grep -v -E "$tikz_originales" || true)
if [ -n "$malos" ]; then
  echo "ERROR: archivos versionados que no deberían publicarse:"; echo "$malos"; fallo=1
fi

preparados=$(git diff --cached --name-only | grep -E '^docs/|\.(pdf|eps|ai|ps|dvi|tex|docx|pptx|zip)$' | grep -v -E "$tikz_originales" || true)
if [ -n "$preparados" ]; then
  echo "ERROR: archivos preparados (staged) que no deberían publicarse:"; echo "$preparados"; fallo=1
fi

rutas=$(git grep -l -I -E '/Users/[A-Za-z0-9._-]+' -- . ':(exclude)scripts/comprobar_publicable.sh' || true)
if [ -n "$rutas" ]; then
  echo "AVISO: rutas locales en archivos versionados:"; echo "$rutas"; fallo=1
fi

# Un push a una rama no debe incluir commits que toquen docs/ (historial)
if git log --all --name-only --pretty=format: | grep -qE '^docs/'; then
  echo "ERROR: el historial contiene archivos de docs/"; fallo=1
fi

[ "$fallo" -eq 0 ] && echo "OK: nada ajeno detectado (docs/, pdf/eps/tex/..., rutas locales)."
exit "$fallo"
