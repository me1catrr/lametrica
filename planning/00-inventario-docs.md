# 00 · Inventario de `docs/`

Auditoría realizada el 2026-10-20. Todo lo de esta tabla se ha comprobado con `ls`, `pdfinfo`, `pdfimages -list`, `iconv -f latin1` y `grep`. `docs/` no se ha modificado.

| Elemento | Naturaleza | Utilidad |
|---|---|---|
| `Texto Final Tesis Linux/*.tex` (10 ficheros, ~560 KB, codificación **latin1**) | Fuente LaTeX original de la tesis | **Máxima**: ecuaciones exactas sin OCR |
| `Base.tex` + `Base.pdf` (244 pp.) | Documento maestro y PDF compilado | Alta: orden, numeración y cotejo visual |
| `bibliografia.bib` (171 entradas) | BibTeX de la tesis (2007): 101 `@book`, 34 `@article`, 22 `@manual`, 5 `@phdthesis`, 3 `@proceedings`, 3 `@misc`, 3 `@unpublished` | Alta, pero requiere depuración (muchos `@book`/`@manual` parecen mal clasificados) |
| 132 `.eps` en la tesis + 54 en `Presentación Tesis/`, `mesh3x3.ai` | Figuras originales | Media: referencia visual; se regeneran en SVG |
| `Presentación Tesis/Slides.tex/.pdf` (beamer, 2008) | Resumen pedagógico | Media: secuencia de exposición |
| `1-2, 1-3, 2-1, 2-2, 2-3, 2-4.pdf` (92–130 pp.) | **Escaneos sin capa de texto** (CCITT 200 dpi, apaisados); `2-4` abre con «ANEXOS» | Baja: duplican contenido; solo cotejo visual. OCR (hay `tesseract`) no fiable en ecuaciones |
| `*.aux .bak .tex~ .mtc* .log .dvi .ps` | Auxiliares | Ignorar |

## Estructura real de la tesis (orden de `Base.tex`)

Introducción (cap. 1) · Nomenclatura · Estado actual (2) · Elemento (3) · Simulaciones (4) · Conclusiones (5) · Anexo A Geometría diferencial de superficies · Anexo B Teoría de láminas · Anexo C Programación en Mathematica.

`Elemento.tex`: 3.1 Introducción · 3.2 Interpolación · 3.3 Área · 3.4 Deformación–desplazamiento (extensión, flexión, cortante, componentes físicas) · 3.5 Leyes constitutivas · 3.6 Interpolación de deformaciones · **3.7 Hu–Washizu y subdominios** · **3.8 Matriz de masa consistente**. La numeración se deduce del orden de `\section` y **debe verificarse contra `Base.pdf`** en la Fase 2.

## Notación observada (a documentar y confirmar)

Índices griegos 1–2, latinos 1–3; `θ^i`; `r`, `₀r`; `g_i`, `a_i`, `a^i`; `a_{αβ}`, `b_{αβ}`; `Γ̄`; `ẽ`; derivada covariante con `‖`; `k̃` curvatura gaussiana, `h̃` principal. Hu–Washizu: Π(u,ε,σ) = ∫U dV − ∫σᵀ(ε − Du) dV con deformaciones por tramos en subdominios A_I…A_IV.

## Advertencias

- Los `.tex` usan `\sideset{_{0}}{}` y `notebook2e`/`esvect` (Mathematica): no renderiza MathJax directamente.
- El Anexo C está en Mathematica; se reescribirá en Julia y se contrastará.
- La tesis tiene © 2008: no se publica `docs/` ni texto literal.
