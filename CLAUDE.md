# La métrica — instrucciones para Claude Code

## Qué es este proyecto
Libro universitario interactivo, en español, sobre **geometría diferencial de superficies, cálculo tensorial y mecánica de láminas** (de las superficies a los elementos finitos). Quarto (libro multipágina) + Julia + JavaScript, publicado en GitHub Pages. Autor: Rafael Castro Triguero (GitHub `me1catrr`). Repositorio público: `https://github.com/me1catrr/lametrica`. Web: `https://me1catrr.github.io/lametrica/`.

Fuente científica primaria: tesis doctoral del autor, *Vibraciones de Estructuras Laminares con forma de Paraboloide Hiperbólico de Planta Rectangular* (Univ. de Sevilla, 2008), en `docs/`. El libro **no es una conversión de la tesis**: es un texto didáctico propio.

## Reglas inviolables
- **`docs/` es solo lectura.** No modificar, mover, borrar ni sobrescribir nada. Está en `.gitignore` y fuera de `project.render`; nunca debe aparecer en `_book/`, en commits ni en GitHub. Antes de cualquier commit, comprobar con `git add -n -A .` que no entra nada de `docs/`.
- **Commits, pushes y publicación:** el autor autorizó (2026-10-21) ejecutar las Fases 1–3 del plan de rediseño (`planning/07-plan-fases.md`) con **commit y push a `main` al cerrar cada fase**, para verlo en la web, tras verificación completa y `bash scripts/comprobar_publicable.sh`. Cualquier otro push, cambio de visibilidad, licencia o publicación fuera de ese cauce exige orden expresa. No instalar dependencias globales sin consultar.
- **No copiar texto de la tesis** (© 2008): redacción nueva, citando fuente y sección.
- **No inventar** referencias, DOI, datos editoriales ni ecuaciones atribuidas a la tesis. Si una ecuación no se ha verificado contra `docs/`, decirlo (“sin verificar”).
- **No presentar como verificado** nada que no se haya ejecutado o contrastado.
- Ante inconsistencias en las fuentes: documentarlas y **preguntar antes** de cambiar la formulación.

## Rigor matemático (prioridad máxima)
- Respetar la notación de la tesis (ver `book/apendices/notacion.qmd`). Distinguir siempre vector `V` de sus componentes `Vⁱ`, `Vᵢ`; índices arriba/abajo; convenio de Einstein; índices griegos 1–2, latinos 1–3.
- Documentar convenios de signo (curvatura `b_{αβ}`, Christoffel). Fijados por el autor (2026-10-20: las discrepancias detectadas se consideran errores de la tesis): `b_{αβ}=â₃·a_{α,β}`, `‖` = derivada covariante en la superficie, `|` = en el espacio 3D. Los pendientes restantes están en el apéndice de notación (componentes físicas en bases no ortogonales, giros de la normal): no fijarlos sin confirmación.
- Separar Kirchhoff–Love de Reissner–Mindlin. Mantener la formulación **específica** de Hu–Washizu por subdominios de la tesis (Elemento, §3.7), no la genérica.
- Toda identidad importante lleva comprobación numérica o simbólica (tests en Julia).
- Distinguir y etiquetar: *calculado*, *analítico*, *ilustrativo*.

## Estructura
```
_quarto.yml, index.qmd     configuración y portada
book/                      capítulos .qmd (01-fundamentos/…) y apendices/
julia/                     paquete Geometria (src/, test/, scripts/)
Project.toml               entorno raíz (usa Geometria vía [sources])
web/ojs/                   módulos JS de las simulaciones; web/tests/ pruebas Node
web/datos/                 JSON generados por Julia (referencias y resultados)
styles/lametrica.scss      tema (colores semánticos, callouts, impresión)
bib/lametrica.bib          ÚNICA fuente bibliográfica
temario.toml               ÍNDICE (bloques→temas): genera _navegacion.yml y book/mapa.qmd
styles/paleta.yml          paleta única (se sincroniza a SCSS, figuras Julia y TikZ)
scripts/                   generar_estructura, sincronizar_paleta, verificar_ejercicios/figuras, *.lua (filtros), compilar_tikz
figures/                   SVG, fuentes TikZ (figures/fuentes/tikz) y figures.yml de procedencia
planning/                  plan, índice, trazabilidad, riesgos y decisiones (ADR)
_freeze/                   resultados Julia cacheados (se versionan)
_book/, .quarto/           generados; no se versionan
```

## Comandos
Quarto 1.10.19 está disponible en el PATH. Comprobar `command -v quarto` y `quarto --version` antes de asumir otra instalación; no reinstalar herramientas globales.

```bash
quarto render                                   # libro completo → _book/
quarto preview                                  # vista previa local
bash scripts/comprobar_publicable.sh             # antes de preparar cambios y tras git add
julia scripts/generar_estructura.jl             # tras editar temario.toml (--check en CI)
julia scripts/sincronizar_paleta.jl             # tras editar styles/paleta.yml (--check en CI)
julia scripts/verificar_figuras.jl              # SVG registrados y con fig-alt
julia --project=. scripts/verificar_ejercicios.jl  # respuestas numéricas vs Geometria
bash scripts/compilar_tikz.sh                    # regenera las dos aperturas (requiere latex y dvisvgm)
julia --project=julia -e 'using Pkg; Pkg.test()'   # tests de Geometria
julia --project=. julia/scripts/generar_referencia.jl   # regenera web/datos/bases_ref.json
cd web && npm test                              # JS vs. referencia de Julia
```
Flujo para cambiar algo de geometría: Julia (código + test) → regenerar JSON de referencia → JS pasa `npm test` → después el capítulo.

## Convenciones de contenido
- Español de España; término inglés entre paréntesis la primera vez.
- Páginas con código Julia: `engine: julia` en la cabecera. Nunca Jupyter/IJulia. `freeze: auto`: si cambia una página con Julia, renderizarla en local y versionar `_freeze/`.
- Datos aleatorios con semilla fija.
- Bloques semánticos: definición `{#def-…}` (azul), teorema/proposición `{#thm-…}`/`{#prp-…}` (verde), advertencia `callout-warning` (ámbar), laboratorio/ejemplo computacional `callout-tip` o `.laboratorio` (violeta), demostración `callout-note .demostracion collapse="true"` y observación (gris). Ecuaciones `{#eq-…}`, figuras `{#fig-…}`, secciones `{#sec-…}`.
- **Plantilla de tema** (estética y didáctica de la web Resonancia; ejemplo completo: `book/01-fundamentos/03-bases.qmd`; esqueleto: `planning/plantilla-tema.qmd`): portada · pregunta guía · objetivos y prerrequisitos · notación · secciones numeradas con intuición → definición → **ejemplo resuelto** (`#exm-`) → resultado + demostración plegada → figura → «Dos puntos que suelen confundir»/«Errores frecuentes» → **«Pon a prueba lo anterior»** (ejercicios interactivos `.ejercicio`) → **«Un poco de historia»** (`.historia`, solo con fuente verificada y fecha de consulta) · laboratorio JS · práctica guiada en Julia · ejercicios con solución plegable · «La doy por superada si…» · «Fuentes, correcciones y qué queda pendiente». Referencias citadas al margen (`citation-location: margin`) y lista final (`scripts/referencias.lua`).
- Todo ejercicio **numérico** necesita su cálculo de referencia en `scripts/verificar_ejercicios.jl`. Capítulos numerados correlativamente por Quarto: referenciar siempre por etiqueta (`@sec-…`), nunca por número escrito a mano. El índice vive en `temario.toml`; no editar `_navegacion.yml` ni `book/mapa.qmd` a mano.
- Paleta: solo la de `styles/paleta.yml` (azul definiciones/base covariante · naranja base recíproca/énfasis · verde teoremas/resultados · violeta idea clave/normal · gris demostraciones/ejes · ocre historia/pistas). Nunca el color como única señal.
- Figuras: geometría exacta con Julia o TikZ (`figures/fuentes/tikz`, `scripts/compilar_tikz.sh`); FigureLabs solo ilustración conceptual/portadas, con el prompt guardado en `figures/fuentes/figurelabs/` y sin material de `docs/`. Cada SVG, registrado en `figures/figures.yml` y con `fig-alt`.
- Los capítulos **no** citan la tesis (decisión del autor, 2026-10-20): se da por hecho que buena parte de la información procede de ella. La trazabilidad contenido → tesis se mantiene solo en `planning/02-trazabilidad-tesis.md`.
- En salidas OJS no se tipografía LaTeX: usar símbolos Unicode.
- Figuras de geometría exacta: generarlas por código (Julia/JS → SVG). FigureLabs solo para ilustraciones conceptuales y diagramas de flujo; no enviar material de `docs/` a servicios externos sin permiso.
- Bibliografía: solo entradas verificables (partir de `docs/Texto Final Tesis Linux/bibliografia.bib`); datos dudosos con `note = {VERIFICAR}`.

## Peculiaridades de las fuentes
- Los `.tex` de la tesis están en **latin1**: leer con `iconv -f latin1 -t utf-8`.
- Usan `\sideset{_{0}}{}`, `esvect` y `notebook2e` (de Mathematica): MathJax no los admite directamente; convertir con cuidado.
- Los PDF `docs/[12]-*.pdf` son escaneos sin texto; no usar OCR como fuente de ecuaciones.
- El Anexo C de la tesis es código Mathematica; su reescritura en Julia debe contrastarse con resultados de la tesis.

## Estado
Fase 2 (prototipo) hecha. Fase 3 en curso: Partes I (caps. 1–5) y II (caps. 6–9) escritas, con 15 SVG generados por Julia y dos aperturas TikZ en los capítulos 1 y 9 (procedencia en `figures/figures.yml`), y laboratorio de bases (Cap. 3). Partes III–V pendientes. Publicación inicial activa; licencia y publicación definitiva del libro pendientes. Plan completo en `planning/`.

## Punto de continuación — 2026-10-21
- Base verificada: `main` en `ebe70d7` (continuidad posterior a `5185908`); PR #1 fusionada y rama `docs/resumen-publicacion` eliminada localmente y en GitHub. No recrear esa PR ni repetir el cambio de visibilidad.
- GitHub Actions: `Pruebas` y `Publicar` completados correctamente para `ebe70d7`. El repositorio es público y GitHub Pages está operativo.
- Última comprobación local: `quarto render` generó las 12 páginas sin errores ni avisos SCSS; sin recursos/enlaces locales inexistentes, anclas rotas ni referencias Quarto sin resolver. Las 12 páginas publicadas y los dos SVG nuevos respondieron HTTP 200.
- Las aperturas ya tienen pies y texto alternativo. El HTML se comprobó estructuralmente, **no mediante revisión visual ni de interactividad en navegador**. Las figuras siguen con revisión visual humana pendiente.
- `.gitignore` y `scripts/comprobar_publicable.sh` permiten únicamente `figures/fuentes/tikz/apertura-cap01-bases.tex` y `figures/fuentes/tikz/apertura-cap09-hypar.tex`; otros `.tex`, PDF y `docs/` siguen bloqueados. No ampliar las excepciones a todo el directorio.
- Esta preparación de continuidad solo actualiza `CLAUDE.md` y `planning/07-plan-fases.md`; no modifica el contenido científico. Revisar el historial y cualquier diff local al retomar.

### Cómo retomar
1. Leer este archivo, `planning/07-plan-fases.md`, `planning/09-verificacion-fuerzas-volumen.md` y el apéndice de notación; revisar `git status --short --branch` y `git diff` antes de modificar nada.
2. Siguiente trabajo seguro: revisión visual de los 17 SVG en el libro y comprobación del laboratorio de bases en navegador. Registrar solo lo realmente comprobado en `figures/figures.yml`; no marcarlo como revisado por el mero hecho de compilar.
3. Continuar el inventario de materiales y la trazabilidad según el plan, sin modificar ni publicar `docs/`.
4. Antes de desarrollar la Parte III o `Laminas.jl`, confirmar con el autor los convenios pendientes de componentes físicas en bases no ortogonales y de giros de la normal. No deducir autorización de estas notas.
5. Tras cambios de contenido: renderizar, revisar `_freeze/` y ejecutar las pruebas pertinentes. Antes de cualquier commit autorizado: comprobar publicación y lista preparada; no publicar sin nueva autorización expresa.
