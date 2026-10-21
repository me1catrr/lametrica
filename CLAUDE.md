# La métrica — instrucciones para Claude Code

## Qué es este proyecto
Libro universitario interactivo, en español, sobre **geometría diferencial de superficies, cálculo tensorial y mecánica de láminas** (de las superficies a los elementos finitos). Quarto (libro multipágina) + Julia + JavaScript, publicado en GitHub Pages. Autor: Rafael Castro Triguero (GitHub `me1catrr`). Repositorio público: `https://github.com/me1catrr/lametrica`. Web: `https://me1catrr.github.io/lametrica/`.

Fuente científica primaria: tesis doctoral del autor, *Vibraciones de Estructuras Laminares con forma de Paraboloide Hiperbólico de Planta Rectangular* (Univ. de Sevilla, 2008), en `docs/`. El libro **no es una conversión de la tesis**: es un texto didáctico propio.

## Reglas inviolables
- **`docs/` es solo lectura.** No modificar, mover, borrar ni sobrescribir nada. Está en `.gitignore` y fuera de `project.render`; nunca debe aparecer en `_book/`, en commits ni en GitHub. Antes de cualquier commit, comprobar con `git add -n -A .` que no entra nada de `docs/`.
- **No hacer commits, pushes ni publicar** (GitHub Actions/Pages) sin autorización expresa. No instalar dependencias globales sin consultar.
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
figures/                   SVG, fuentes originales TikZ y figures.yml de procedencia
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
- Plantilla de capítulo: objetivos · motivación · desarrollo riguroso · interpretación geométrica · figuras · simulación · ejemplo Julia · demostraciones desplegables · ejercicios · trazabilidad con la tesis · referencias comentadas.
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
- Base verificada: `main` en `5185908`; PR #1 fusionada y rama `docs/resumen-publicacion` eliminada localmente y en GitHub. No recrear esa PR ni repetir el cambio de visibilidad.
- GitHub Actions: `Pruebas` y `Publicar` completados correctamente para ese commit. El repositorio es público y GitHub Pages está operativo.
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
