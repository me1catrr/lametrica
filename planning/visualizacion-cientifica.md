# Estrategia de visualización científica

> **Estado (2026-10-21):** parcialmente adoptada en el rediseño (`planning/07-plan-fases.md`): ruta TikZ → SVG versionado, paleta única sincronizada (`styles/paleta.yml`), registro y verificación de figuras (`scripts/verificar_figuras.jl`), FigureLabs solo para portadas conceptuales. PGFPlots, el catálogo completo y la validación de figuras en CI siguen como propuesta.

Estado original: **propuesta**. No se ha implementado nada de lo que aquí se propone como nuevo (TikZ, PGFPlots, FigureLabs, CI de figuras). Fecha: 2026-10-20.

## 0. Auditoría del estado actual

**Entorno local (comprobado hoy):**

| Herramienta | Estado |
|---|---|
| Quarto 1.10.19, Pandoc 3.10, Typst 0.15.1 | instalados |
| MacTeX 2025 (`pdflatex`, `lualatex`, `latex`) en `/Library/TeX/texbin` | instalado; `tikz`, `pgfplots`, `standalone`, `tikz-3dplot`, `tikz-cd` presentes. Quarto usa TinyTeX = *no instalado*, pero detecta la instalación del sistema |
| `pdftocairo`, `rsvg-convert`, `gs` (10.06) | instalados |
| `dvisvgm` | instalado, **pero no sirve** para PDF (falta `mutool`/libgs enlazada) y la ruta DVI ignora los `\special` de TikZ (resultado erróneo) |
| `pdf2svg`, `inkscape`, `mutool` | no instalados |
| Julia 1.12, Node 24 | instalados |

**Prueba de concepto realizada (en el directorio temporal de la sesión, no en el repo):** `standalone` + TikZ → `pdflatex` (0,5 s) → `pdftocairo -svg` → SVG correcto (comprobado visualmente tras rasterizar con `rsvg-convert`). El texto matemático sale como trazados de glifos Computer Modern (0 elementos `<text>`), sin dependencias de fuentes en el navegador.

**Estado del repositorio:**
- `figures/svg/` (8 SVG) y `figures/figures.yml` (procedencia) **ya existen**: se generan con `julia/scripts/generar_figuras.jl` a partir de `Geometria` (`base_polar`, `base_esferica`). Son figuras de la Parte I (caps. 2, 4 y 5), creadas antes de recibir este encargo.
- Reservas sobre esas 8 figuras, que la propuesta debe resolver: (a) el script escribe SVG a mano con números dentro del código; las derivadas de la base de la `christoffel-polares` son analíticas y **no** se contrastan automáticamente con `cristoffel()`; (b) su paleta no coincide con el laboratorio del capítulo 3 (allí la base recíproca es ámbar; en las figuras nuevas $\mathbf g_2$ es verde y $\mathbf V$ ámbar); (c) revisión visual humana pendiente.
- CI actual (`.github/workflows`): `tests.yml` (Julia + Node) y `publish.yml` (Quarto sin Julia ni LaTeX; lee `_freeze/`). **No hay LaTeX en CI.**
- La tesis (`docs/`, solo lectura) usa PSTricks y EPS (`Interpolation.eps`, `Subdomain0x.eps`, `Wempner.eps`, `Mallado4elem.eps`, …). No hay fuentes TikZ que reutilizar; los EPS son **referencia visual**, no se reutilizan.

## 1. Elección de tecnología por tipo de figura

Criterio de decisión: precisión matemática (¿los números salen de una única fuente verificable?) > reproducibilidad > calidad tipográfica > mantenimiento > rendimiento.

| Tecnología | Cuándo | Por qué | Límite |
|---|---|---|---|
| **TikZ** | Esquemas con geometría *definida*: bases, coordenadas naturales, elemento de 4 nodos, cinemática de sección, subdominios | Etiquetas con la misma tipografía y macros que las ecuaciones; vectorial; coordenadas exactas | Superficies 3D complejas y oclusión: limitado |
| **PGFPlots** | Curvas, funciones, superficies sencillas ($z=xy$), perfiles de deformación | Ejes, escalas y leyendas rigurosos; lee tablas de datos | Rendimiento y oclusión en 3D con mallas finas |
| **Julia → SVG directo** | Figuras que son **resultados** (mallas, campos, modos propios, convergencia) o que deben coincidir al dígito con un cálculo | La figura y el test comparten el objeto matemático; sin LaTeX | Tipografía propia hay que cuidarla |
| **JavaScript** | Exploración paramétrica 2D/3D (laboratorios) | Interactividad; ya verificado contra Julia (`npm test`) | No sustituye a la figura estática de la definición |
| **FigureLabs** | Solo ilustración conceptual sin geometría verificable (portadas, motivación física, diagramas de flujo del método) | Calidad editorial rápida | **No reproducible**, no garantiza geometría, servicio externo: nunca para figuras con ecuaciones o vectores; nunca subir material de `docs/` sin permiso |

Regla de oro: **si una figura contiene vectores o curvas con valores concretos, esos valores salen de `Geometria`**, no se teclean.

## 2. Integración TikZ / PGFPlots con Quarto (HTML y PDF)

**Hallazgo:** Quarto no compila TikZ directamente a HTML. Las opciones evaluadas:

| Opción | Veredicto |
|---|---|
| Bloque `{=latex}` en el `.qmd` | Solo funciona en PDF-LaTeX; en HTML se ignora. **Descartada** como vía única |
| Extensión de Quarto / filtro `tikz` que compila en el render | Añade dependencia de LaTeX al render y a CI; frágil. **Descartada** |
| **Compilar fuera de Quarto con `standalone` → PDF → SVG y comitear el SVG** | **Recomendada.** Mismo patrón que `_freeze/`: el render de Quarto y la CI no necesitan LaTeX |
| `dvisvgm --pdf` | No funciona en este equipo (sin `mutool`/libgs) |
| `dvisvgm` por DVI (`latex`) | **Incorrecto** con TikZ (ignora `\special`) |

**Procedimiento propuesto (comprobado en su núcleo):**

```text
figures/fuentes/tikz/<id>.tex          fuente standalone (\documentclass[tikz,border=2pt]{standalone})
figures/fuentes/tikz/datos/<id>.tex    coordenadas AUTOGENERADAS por Julia (\def\gUno{(…)}); no se editan a mano
pdflatex  →  <id>.pdf                  (PDF vectorial, para edición impresa)
pdftocairo -svg  →  figures/svg/<id>.svg   (HTML/GitHub Pages)
```

- Quarto incluye siempre el **SVG** (`![...](figures/svg/<id>.svg)`); para PDF-LaTeX Quarto convierte SVG con `rsvg-convert` (instalado); alternativa: usar el PDF vectorial. *No probado*: se verificará un render PDF real antes de afirmarlo.
- **Caché:** `figures/figures.yml` guarda el SHA-256 de (fuente `.tex` + datos + preámbulo + versión de TeX Live). El script recompila solo si cambia el hash.
- **Orquestación:** un único `Makefile` (o `julia/scripts/figuras.jl`) con objetivos `figuras`, `figuras-verificar`, `figuras-limpiar`. Los artefactos intermedios (`.aux`, `.log`, `.pdf` temporales) van a un directorio ignorado por git.
- **Preámbulo común** `styles/figuras-preambulo.tex` (colores, estilos de vector, tamaño de fuente) y **macros comunes** `styles/macros.tex` usadas *a la vez* por MathJax (`include-in-header`) y por TikZ, para que `\mathbf g_1` sea idéntico en texto y en figura.
- **GitHub Actions:** no instalar TeX Live (≈1 GB, minutos). La CI hace dos cosas baratas: (1) regenera las figuras Julia y falla si `git diff` no es vacío (figuras al día); (2) valida los SVG (§6). La compilación TikZ se hace en local y se versiona el SVG, con el hash en `figures.yml`; un job opcional manual con contenedor TeX puede verificar el hash.
- **MathJax:** las etiquetas TikZ salen en Computer Modern como glifos; MathJax usa por defecto la fuente TeX de MathJax (Computer Modern), así que el aspecto es coherente. Contrapartida: el texto de la figura no se puede seleccionar ni cambia con el tamaño de fuente del lector; se compensa con `fig-alt` y pie descriptivo.

## 3. Convenciones matemáticas (revisadas en la tesis y en el libro)

Leído en `docs/Texto Final Tesis Linux` (`AnexoGeometria.tex`, `AnexoTeoriaLaminas.tex`, `Elemento.tex`). **Estado: leído, ecuaciones sin verificar línea a línea.**

| Tema | Convención de la tesis | Observación para las figuras |
|---|---|---|
| Superficie de referencia | $\mathbf r=\,{}_0\mathbf r(\theta^1,\theta^2)+\theta^3\hat{\mathbf a}_3$; $\theta^3$ = distancia a lo largo de la normal | Dibujar siempre $\hat{\mathbf a}_3$ **unitaria** y $\perp$ a $\mathbf a_\alpha$ |
| Bases | $\mathbf a_\alpha={}_0\mathbf r_{,\alpha}$; $\mathbf a^\alpha=a^{\alpha\beta}\mathbf a_\beta$; $\mathbf a^\alpha\cdot\mathbf a_\beta=\delta^\alpha_\beta$; $\hat{\mathbf a}_3\cdot\mathbf a_\alpha=0$ | Los $\mathbf a^\alpha$ son tangentes (no normales) a la superficie; la tesis los llama «normales a las superficies $\theta^\alpha$» |
| Christoffel | $\bar\Gamma_{\alpha\beta\gamma}=\mathbf a_\gamma\cdot\mathbf a_{\alpha,\beta}$, $\bar\Gamma^\gamma_{\alpha\beta}=\mathbf a^\gamma\cdot\mathbf a_{\alpha,\beta}$ | El libro usa $\Gamma^k_{ij}=\mathbf g^k\cdot\partial_j\mathbf g_i$: **mismo valor**, notación distinta para los de primera especie |
| **Curvatura (signo)** | $b_{\alpha\beta}=\hat{\mathbf a}_3\cdot\mathbf a_{\alpha,\beta}=-\mathbf a_\alpha\cdot\hat{\mathbf a}_{3,\beta}$; Weingarten $\hat{\mathbf a}_{3,\beta}=-b^\alpha_\beta\mathbf a_\alpha$ | Con normal saliente de una esfera, $b_{\alpha\beta}<0$. **Pendiente de confirmar con el autor**; condiciona todas las figuras de curvatura |
| Base de la lámina | $\mathbf g_\alpha=\mathbf a_\alpha-\theta^3 b_\alpha^\beta\mathbf a_\beta$; $g_{\alpha3}=0$, $g_{33}=1$ | Comprobable numéricamente (ver §7) |
| Derivadas | $\|$ = diferenciación respecto a la superficie; $\mid$ = respecto al espacio 3D | **El capítulo 5 del libro usa $\|$ en sentido genérico**: conflicto de notación por resolver |
| Coordenadas naturales | $\xi=(\theta^1-\bar\theta^1)/\theta^1_0$, $\eta$ análogo; $N_k=\tfrac14(1+\xi_k\xi)(1+\eta_k\eta)$ | Dibujar el cuadrado $[-1,1]^2$ y la numeración de nodos exactamente como en la tesis |
| Elemento | 4 nodos; 5 g.d.l. por nodo ($u_1,u_2,u_3,\varphi_1,\varphi_2$) | — |
| Deformaciones | extensión ${}_0\gamma_{\alpha\beta}$, flexión ${}_1\gamma_{\alpha\beta}$, cortante $\gamma_\alpha$ | Distinguir los tres en color y estilo |
| Subdominios | cuatro subdominios; interpolación «en escalones» | Reproducir el concepto con figura nueva |

**Sin tocar `CLAUDE.md` ni el apéndice de notación hasta su aprobación.** Hay tres decisiones que bloquean figuras: signo de $b_{\alpha\beta}$, uso de $\|$/$\mid$, y definición de componentes físicas.

## 4. Arquitectura de figuras (adaptada a lo existente)

Se conserva `figures/` y `figures/figures.yml` (ya previstos en `planning/06`). No se crea un árbol paralelo por tecnología:

```text
figures/
├── svg/                    EXPORTADOS (únicos que usa Quarto) — versionados
├── pdf/                    EXPORTADOS vectoriales para impresión (solo TikZ/PGFPlots) — versionados
├── fuentes/
│   ├── tikz/               <id>.tex  + datos/<id>.tex (autogenerado)
│   ├── pgfplots/           <id>.tex  + datos/<id>.csv (autogenerado)
│   ├── figurelabs/         prompt + parámetros + captura de versión (la imagen exportada va a svg/ o png/)
│   └── julia/ → ya existe como julia/scripts/generar_figuras.jl (se mantiene allí)
├── png/                    solo ilustraciones FigureLabs rasterizadas
├── figures.yml             metadatos (§ siguiente)
└── README.md               cómo regenerar, convenciones, checklist de revisión
```

`figures.yml` — campos por figura: `id` (= etiqueta Quarto `fig-…`), `titulo`, `capitulo`, `fuente_matematica` (sección/ecuación del libro o referencia bibliográfica), `tecnologia`, `fuente` (ruta editable), `salidas`, `descripcion`, `convenciones` (signo de $b$, orientación, normal), `hash_fuente`, `verificacion_automatica` (nombre del test), `revision_humana` (`pendiente|ok:<fecha>`). Hay ya un `figures.yml` mínimo con estos conceptos; se ampliaría.

Los temporales de compilación (`.aux`, `.log`, `.dvi`, PDF intermedios) se ignoran en `.gitignore`.

## 5. Estilo gráfico común

**Roles de color (no por figura, por *objeto matemático*)** — coherentes con el tema SCSS y con el laboratorio del capítulo 3:

| Objeto | Color | Trazo |
|---|---|---|
| Base covariante $\mathbf g_i,\mathbf a_\alpha$ | azul `#1d4ed8` | continuo; $\mathbf g_1,\mathbf g_2$ distinguidos por etiqueta |
| Base recíproca $\mathbf g^i,\mathbf a^\alpha$ | ámbar `#b45309` | discontinuo |
| Vector genérico $\mathbf V$ | gris casi negro `#1f2937` | grueso |
| Normal $\hat{\mathbf a}_3$, director | violeta `#6d28d9` | continuo |
| Configuración deformada / resultados | verde `#15803d` | continuo (referencia en gris discontinuo) |
| Mallas, ejes, coordenadas | gris claro `#cbd5e1` / `#4b5563` | fino |

Accesibilidad: verde y ámbar se confunden en deuteranopía → **nunca depender solo del color** (estilo de línea y etiqueta); verificación automática con simulación de daltonismo (ver §7). Alternativa si falla: paleta Okabe–Ito.

**Tipografía y tamaños:** etiquetas en Computer Modern (TikZ) o `Georgia`/serif con subíndices unicode (Julia) — a decidir; mínimo **12 px a ancho de diseño 520 px** (legible en móvil al escalar a 360 px ≈ 8,3 px; por eso el ancho de diseño recomendado es 400–520). Trazos: ejes 1,2; mallas 1; vectores 2,4–3; énfasis 3,4. Flechas en cabeza `Stealth`.

**Convenciones visuales:**
- Ejes etiquetados $x,y,z$ en gris; sistema curvilíneo con mallas azul/verde finas.
- Superficie original: gris claro, borde continuo; **deformada**: verde, con la original discontinua; incluir factor de amplificación en el pie («deformación ×50»).
- Vectores a escala **real** salvo que se avise; si se reduce (como $\mathbf g_2$ en `vector-dos-bases`), etiquetarlo («×½»).
- Pie de figura: qué se ve, convenio de signo, escala y origen de los datos («calculado con `Geometria`»).
- Proporciones: 4:3 (principal) o 16:9 (paneles); `viewBox` sin dimensiones fijas, `width="85–100%"`, `fig-alt` obligatorio.

## 6. Integración editorial en Quarto

- Referencias cruzadas `@fig-…`, pies descriptivos, numeración automática, subfiguras con `layout-ncol` y `fig-subcap`; reutilización de una figura en varios capítulos referenciando el mismo SVG (no copiándolo).
- Ya funciona para HTML (8 figuras renderizadas). PDF: pendiente de prueba real.
- Sin dependencias nuevas en Quarto: solo `<img>` de SVG estáticos.

## 7. Catálogo inicial (15 figuras prioritarias)

Estado: ✔ = hecha con Julia→SVG (pendiente de revisión visual y de reencaje con el estilo definitivo); — = no iniciada.

| # | Figura | Tecnología recomendada y motivo | Estado |
|---|---|---|---|
| 1 | Transformaciones de coordenadas (cartesianas↔polares, jacobiano) | Julia→SVG (datos de `base_polar`) o TikZ+datos Julia | ✔ (`vector-dos-bases`, `jacobiano-area`, `galeria-coordenadas`) |
| 2 | Bases covariante y contravariante en el plano | **TikZ** + datos Julia (definición con paralelogramos y proyecciones ortogonales); la simulación JS ya existe | — (hay laboratorio JS) |
| 3 | Bases duales en superficie curva ($\mathbf a_\alpha,\mathbf a^\alpha,\hat{\mathbf a}_3$) | **PGFPlots** (superficie, datos Julia) + TikZ (vectores) | — |
| 4 | Tensor métrico y elemento de área | TikZ+datos Julia | ✔ parcial (`metrica-arcos`) |
| 5 | Derivadas de los vectores base | TikZ+datos Julia | ✔ (`christoffel-polares`) |
| 6 | Símbolos de Christoffel, transporte de campos | Julia→SVG | ✔ (`campo-constante-polares`, `esfera-coordenadas`) |
| 7 | Curvaturas principales | PGFPlots/TikZ: secciones normales de $z=xy$ y de la esfera; **bloqueada por el signo de $b$** | — |
| 8 | Primera y segunda formas fundamentales | TikZ+datos Julia (plano tangente y distancia a él) | — |
| 9 | Lámina de espesor finito ($\theta^3$, $\mathbf a_\alpha$, $\mathbf g_\alpha$) | **TikZ** + datos Julia | — |
| 10 | Cinemática de Reissner–Mindlin (normal que no permanece ⟂) | **TikZ** (sección 2D) | — |
| 11 | Deformaciones de membrana, flexión y cortante | TikZ (tres paneles) | — |
| 12 | Elemento cuadrilátero de 4 nodos y coordenadas naturales | **TikZ** | — |
| 13 | Subdominios de interpolación («escalones») | TikZ + PGFPlots (perfiles) | — |
| 14 | Campos de deformación sobre el elemento | **Julia→SVG** (resultado numérico) | — |
| 15 | Modos propios del paraboloide hiperbólico | **Julia→SVG/JS 3D** (resultado numérico) | — |

**Las cinco primeras recomendadas para desarrollar tras la aprobación** (cada una prueba un eslabón distinto de la cadena):

1. **#2 Bases dual/covariante en el plano** (TikZ+Julia): valida el procedimiento completo (datos Julia → TikZ → SVG → Quarto) y se enlaza con el laboratorio JS ya existente (§8).
2. **#3 Bases duales sobre el paraboloide hiperbólico** (PGFPlots+TikZ): objeto central del libro; prueba superficies 3D y la distinción tangente/normal/recíproca.
3. **#9 Lámina de espesor finito** (TikZ): fija la geometría $\mathbf r={}_0\mathbf r+\theta^3\hat{\mathbf a}_3$ que usarán todos los capítulos de láminas.
4. **#10 Cinemática de Reissner–Mindlin** (TikZ): figura conceptual clave; exige separar claramente de Kirchhoff–Love.
5. **#12 Cuadrilátero de 4 nodos con coordenadas naturales** (TikZ): puerta a la Parte IV y a los subdominios (#13).

La #7 (curvaturas) se pospone hasta confirmar el signo de $b_{\alpha\beta}$.

## 8. Continuidad figura estática ↔ Julia ↔ simulación JS

Un solo objeto matemático por figura, definido en `Geometria`:

```text
Geometria.jl  ─►  datos (JSON + \def de TikZ + CSV de PGFPlots)  ─┬─►  figura estática (TikZ/PGFPlots/SVG)
      │                                                           ├─►  tests Julia (identidades)
      └─►  web/datos/*_ref.json  ─►  web/ojs/*.js (npm test)      └─►  laboratorio JS
```

La figura TikZ de la definición, el ejemplo Julia (`@eq-reciprocidad` verificada) y el laboratorio JS del capítulo 3 comparten la misma base $\{\mathbf g_i\}$ de ejemplo. Las fórmulas **no se duplican a mano**: el JS ya se contrasta con la referencia de Julia; las figuras estáticas leerán el mismo `datos.json`.

## 9. Validación automática

**Automatizable (Julia `Test`, ejecutable en CI):**
- Bases recíprocas: $\mathbf a^\alpha\cdot\mathbf a_\beta=\delta^\alpha_\beta$ con los vectores *exactos* que se dibujan.
- Normal: $\|\hat{\mathbf a}_3\|=1$, $\hat{\mathbf a}_3\cdot\mathbf a_\alpha=0$ y orientación $\mathbf a_1\times\mathbf a_2\parallel\hat{\mathbf a}_3$ (signo documentado).
- Curvatura: signo de $b_{\alpha\beta}$ en esfera y paraboloide con la convención fijada; identidad $g_{\alpha\beta}=a_{\alpha\beta}-2\theta^3b_{\alpha\beta}+(\theta^3)^2b_{\alpha\gamma}b^\gamma_\beta$ (numérica).
- Índices altos/bajos: $V^i=g^{ij}V_j$, $V^iV_i=\|\mathbf V\|^2$ con los datos de la figura.
- Consistencia Julia↔figura: el generador emite `datos.json`; un test compara el JSON con `Geometria`, y un segundo test extrae los vectores del SVG/`\def` y comprueba que coinciden con el JSON (tolerancia de dibujo).
- Hash fuente↔exportado; SVG válido: `viewBox`, `<title>`, sin referencias externas, tamaño de texto mínimo, ancho de diseño.
- Contraste y daltonismo: $\Delta E$ mínimo entre colores de roles distintos bajo simulación de protanopía/deuteranopía.
- Figuras Julia regeneradas y sin diferencias (`git diff --exit-code`).
- Notación: lista de etiquetas permitidas (`$\mathbf a^\alpha$`, no `a_alpha`) y chequeo de que las macros de figura son las de `styles/macros.tex`.

**Requieren revisión humana (checklist firmada en `figures.yml`):** índices arriba/abajo correctos en cada etiqueta, orientación y sentido de giro, que lo dibujado «se vea» como lo calculado, escalas que no engañen (vectores acortados, deformaciones amplificadas), colisión de etiquetas, legibilidad en móvil, y que el signo de $b$ sea el acordado.

## 10. Dependencias y riesgos de mantenimiento

| Riesgo | Mitigación |
|---|---|
| LaTeX solo en local (reproducibilidad) | SVG versionado + hash; documentar versión TeX Live 2025; contenedor opcional |
| `dvisvgm` inservible aquí | Ruta `pdflatex → pdftocairo` (probada); no depender de `dvisvgm` |
| Divergencia entre macros del texto y de la figura | `styles/macros.tex` único |
| PGFPlots 3D lento o con oclusión pobre | Mallas gruesas en la figura; resultados densos → Julia→SVG |
| FigureLabs: no reproducible, términos de servicio, privacidad | Solo conceptual; guardar prompt y versión; no subir `docs/`; revisión humana siempre |
| Figuras ya hechas con otro estilo | Reconciliar paleta (script único) tras aprobar §5; no mezclar estilos |
| Crecimiento del repo por SVG/PDF | SVG sin fuentes embebidas; límite de tamaño por figura en la validación |
| Signo de $b_{\alpha\beta}$ y notación $\|$ sin cerrar | Decisión del autor antes de figuras de curvatura |
| Derechos de la tesis (© 2008) | Redibujar, no reutilizar EPS; citar fuente en `figures.yml` |

## 11. Reglas permanentes propuestas para `CLAUDE.md` (no aplicadas)

1. Los datos numéricos de una figura salen de `Geometria`; prohibido teclear coordenadas en `.tex` de figura.
2. Toda figura se registra en `figures/figures.yml` con su test de verificación antes de usarse en un capítulo.
3. Se usa solo el SVG de `figures/svg/` en los `.qmd`; no se compila LaTeX en `quarto render` ni en CI.
4. Roles de color y tipografía según `planning/visualizacion-cientifica.md` §5.
5. FigureLabs únicamente para ilustración conceptual, con prompt guardado y sin material de `docs/`.
6. No dibujar una figura de curvatura hasta que el signo de $b_{\alpha\beta}$ esté confirmado.
7. Una figura no pasa a «revisada» sin la checklist humana firmada.

## 12. Decisiones que necesito del autor

1. ¿Aprobada la arquitectura (§4) y la ruta `pdflatex → pdftocairo` (§2)?
2. ¿Se rehacen en TikZ las figuras ya creadas con Julia, o se mantienen como Julia→SVG ajustando solo la paleta?
3. Signo de $b_{\alpha\beta}$ (tesis: $\hat{\mathbf a}_3\cdot\mathbf a_{\alpha,\beta}$) y uso de $\|$ frente a $\mid$.
4. Paleta (§5) y ancho de diseño 520 px.
5. ¿Se permite FigureLabs, y para qué figuras concretas?
