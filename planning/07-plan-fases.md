# 07 · Plan de desarrollo (5 fases)

**Última actualización: 2026-10-21 (Fase 3 del rediseño cerrada en local; commit/push al cerrar).** Libro: 21 de 36 temas publicados (bloques A–D completos) en el nuevo estilo; Fase 1 publicada en `f2c51f8`, Fase 2 en `4dac20a`. Punto de continuación operativo en `CLAUDE.md`.

## Plan de rediseño: estética de Resonancia + índice de 36 temas (5 fases)
Índice: `planning/01-indice-libro.md` y `temario.toml` (fuente de verdad). Plantilla: `planning/plantilla-tema.qmd`. Autorizado por el autor: ejecutar las Fases 1–3, con **commit y push a `main` al cerrar cada fase**; las Fases 4–5 se ejecutan con orden posterior.

| Fase | Contenido | Estado |
|---|---|---|
| **1 · Cimientos y piloto** (publicada, `f2c51f8`) | Paleta única (`styles/paleta.yml` + sincronización a SCSS/Julia/TikZ); cajas e infraestructura de Resonancia (ejercicios interactivos, referencias al margen, historia); `temario.toml` → navegación y «Mapa del libro»; scripts de verificación (figuras, ejercicios, estructura) y job de CI; tema piloto B2 reescrito (3 figuras TikZ, 10 ejercicios, 2 notas históricas con fuente, laboratorio, práctica Julia, cierre) | **Hecha y publicada** |
| **2 · Bloques A–C al nuevo estilo** | Reescritos A1, B1, B3, B4, C1, C2, C3, C5; nuevos A2, B5, C4, C6; 13 temas con portada, pregunta guía, ejemplos resueltos, ejercicios interactivos (29 numéricos verificados con Julia), historia con fuentes y cierre; `Geometria.jl` ampliado (operadores tensoriales, geodésicas, Brioschi/Egregium, Codazzi, superficies tipo) con 40 tests nuevos; 4 laboratorios JS verificados contra Julia (polares, Christoffel, Euler, hypar); portada FigureLabs de A1 | **Hecha en local; commit/push al cerrar** |
| **3 · Bloque D: elasticidad y láminas** | D1–D8 con `Laminas.jl` (cinemática, KL frente a RM, deformaciones, constitutivas) y tests; convenios pendientes (componentes físicas no ortogonales, giros de la normal, g.d.l. físicos) | Pendiente |
| 4 · Bloque E: elementos finitos | E1–E9 hasta Hu–Washizu por subdominios, masa, ensamblaje | Planificada (orden posterior) |
| 5 · Bloques F–G, apéndices, validación | Hypar (curvos/rectos), validación, glosario, chuletas, solucionarios, PDF | Planificada (orden posterior) |

Cierre de cada fase: verificación (render sin avisos, tests Julia/JS, `scripts/verificar_*`, `comprobar_publicable.sh`), `_freeze/` versionado, commit, push, comprobar CI y web, actualizar este documento.

## Hecho el 2026-10-21 (antes del rediseño)
- Tests de Julia: 123 comprobaciones, 7 conjuntos, **pasan** (en el sandbox hace falta `JULIA_DEPOT_PATH="$TMPDIR/depot:$HOME/.julia"`).
- **P0 hecho:** verificación de `docs/Ejemplos/body_forces.pdf` → `09-verificacion-fuerzas-volumen.md` (`julia/scripts/verificar_fuerzas_volumen.jl`, 29/29). Resumen: págs. 1–2 y 4–6 correctas; pág. 3 con un error de signo, un coeficiente `2/R` (debe ser `1/R`) y una omisión de términos en `K`; y la expresión de partida con `μᵖ_α` **no reproduce el trabajo de un peso uniforme** (error ≈ 10⁻⁴ con `t/R = 0,1`). El propio autor la marca «Wrong! See BF-1÷8» y esas páginas no están en `docs/`. **Decisión del autor:** no dispone de la versión correcta; se adopta la **versión corregida** derivada aquí (`δW = t(1+Kt²/12)(Xᵖδu_ρ+X³δu₃) − (Ht³/6)Xᵖδψ_ρ`, comprobada numéricamente en cilindro, esfera e hypar), que sustituye a SD-12. Limitación: valida el álgebra, no que la cinemática coincida con la de la tesis.
- **P1 hecho:** `hypar.pdf` págs. 1–3 y `sphere.pdf` pág. 1 coinciden con `Geometria.jl` (15/15, `julia/scripts/verificar_apuntes_geometria.jl`), incluido el convenio `b_αβ = â₃·a_{α,β}`.
- **P2 hecho:** inventario de `docs/Ejemplos` en `00-inventario-docs.md`.
- **P3 hecho (parcial):** numeración de secciones de la tesis contrastada con el índice de `Base.pdf`, en `02-trazabilidad-tesis.md` (solo el índice; falta contrastar contenido capítulo a capítulo).
- Poppler ya estaba instalado (26.10.0). **Node reinstalado por el autor** (v26.12.0): `npm test` pasa, 6/6 (JS coincide con Julia 1.12.3).
- Repositorio público `me1catrr/lametrica`; `main` local y remoto verificados en `ebe70d7` (continuidad posterior a la PR #1, ya fusionada; rama de trabajo eliminada). Workflows `Pruebas` y `Publicar` correctos para `ebe70d7`; GitHub Pages publica desde `gh-pages` y la portada responde HTTP 200. Tests de Julia (123) y de JS (6) re-ejecutados en local con resultado correcto.

## Estado de la Fase 3 (bloque D: elasticidad y láminas)

Hecha en local: D1–D8 escritos (`book/D-elasticidad/`), `Laminas.jl` con tests (cinemática exacta y lineal, rigideces), 6+3 figuras SVG de Julia, 42 ejercicios numéricos verificados. Convenios pendientes del autor marcados «por confirmar» en D5, D6 y D7 (componentes físicas no ortogonales, giros del director, factor de corrección de cortante). Lo siguiente (Fase 4, requiere orden): bloque E.

> Tabla heredada de la versión previa del plan (capítulos antiguos); el estado vigente es `temario.toml`.

### Capítulos
| Parte | Caps. | Estado |
|---|---|---|
| I — Fundamentos tensoriales | 1–5 | Escritos (el 1 es breve; sus lecturas de apoyo aún no se han leído para el libro) |
| II — Geometría de superficies | 6–9 | Escritos |
| III — Mecánica de láminas | 10–12 | **Pendiente** |
| IV — Elementos finitos de lámina | 13–17 | **Pendiente** |
| V — Vibraciones y aplicaciones | 18–20 | **Pendiente** |

Apéndice A (notación) existe; B, C y D del índice, no.

### Código y verificación
- `julia/src/Geometria.jl` (345 líneas). `Laminas.jl` aún no existe.
- Tests de JS (`web/tests/bases.test.mjs`): **6/6 pasan** (tras reinstalar Node).
- `quarto render`: completado tras la fusión, 12 páginas sin errores ni avisos SCSS. `_freeze/` de los capítulos 1 y 9 actualizado y versionado. Verificación estructural: sin enlaces/recursos locales inexistentes, anclas rotas ni referencias Quarto sin resolver; las 12 páginas publicadas y las dos aperturas SVG responden HTTP 200. Falta revisión visual y de interactividad en navegador.

### Simulaciones (1 de 12)
Hecha: #3 (bases cov./contrav.). Pendientes: el resto. Los caps. 2 y 4–9 usan figuras SVG estáticas.

### Figuras, bibliografía, trazabilidad
- 15 SVG geométricos generados por Julia y dos aperturas ilustrativas TikZ (caps. 1 y 9) = 17 SVG en `figures/svg/`, **todos con revisión visual humana pendiente**. De la propuesta `visualizacion-cientifica.md` solo se ha adoptado la ruta TikZ para esas dos aperturas; el resto (PGFPlots, FigureLabs, catálogo de 15 figuras, validación de figuras en CI, reconciliación de paleta) **sigue como propuesta, sin aprobar**. Las dos fuentes TikZ originales y el script de compilación están versionados con excepciones cerradas en la protección de publicación; sin figuras de FigureLabs.
- `bib/lametrica.bib`: 15 de las 171 entradas de la tesis, 1 con `VERIFICAR`; `fichas.yml` no existe.
- `02-trazabilidad-tesis.md`: numeración verificada (solo índice); `trazabilidad/ecuaciones.yml` no creado.

## Materiales aportados por el autor (`docs/Ejemplos`, `Hu_Washizu_resume.pdf`)
Apuntes manuscritos, **no la tesis**. Detalle en `00-inventario-docs.md`.

| Material | Uso previsto | Estado |
|---|---|---|
| `hypar.pdf`, `sphere.pdf` | Contraste de los caps. 6–9; posibles ejemplos resueltos | Págs. 1–3 y 1 verificadas; resto sin leer |
| `flat_shell.pdf`, `cylindrical*.pdf`, `Hu_Washizu_resume.pdf` | Ejemplos de elemento (caps. 14–16) | Solo la primera página de cada uno |
| `skew_plate*.pdf`, `pinched_cylinder.pdf`, `plane_stress.pdf` | Casos de referencia y datos (caps. 12, 18–20; contraste Julia–Mathematica) | Sin leer en detalle |
| `body_forces.pdf` | Vector de cargas (cap. 17 o 18); **contenido propio, sin fuente en la tesis** | Verificado; sustituido por la versión corregida de `09-…` (BF-1÷8 no disponible) |

## Orden de trabajo propuesto (siguientes sesiones)
1. **Fuerzas de volumen:** versión corregida adoptada. Pendiente de confirmar: que los grados de libertad sean componentes físicas (el autor cree que sí, **sin confirmar**) y el convenio de los giros `δψ_ρ`. Contrastar con la cinemática de la tesis al escribir la Parte III.
2. **Leer y catalogar el resto de `docs/Ejemplos`** (~150 págs.), empezando por `skew_plate*.pdf` y `pinched_cylinder.pdf` (probables valores de referencia) y `flat_shell.pdf`/`cylindrical*.pdf` (elemento); anotar páginas y datos en el inventario.
3. **Cerrar Partes I–II:** revisión visual de las 17 figuras y del laboratorio de bases en navegador. El render completo y los enlaces cruzados ya se comprobaron tras la PR #1; repetir después de modificar contenido. CI de Julia y JavaScript pasa en `ebe70d7`.
4. **Parte III (caps. 10–12):** crear `Laminas.jl` (cinemática, Cauchy–Green, KL vs. RM) con tests; antes, fijar los dos convenios pendientes del apéndice A (componentes físicas en bases no ortogonales; giros de la normal) → decisión del autor. `plane_stress.pdf` puede alimentar el cap. 12.
5. **Partes IV–V (caps. 13–20):** Hu–Washizu por subdominios contrastado con `Elemento.tex` (§3.6.2 y 3.7.1, p. 69–71 de `Base.pdf`); Anexo C (p. 169) reescrito en Julia; casos de las simulaciones (tesis §4.2.2, §4.3.2) y de `skew_plate` para validar.
6. **Trazabilidad y bibliografía:** `trazabilidad/ecuaciones.yml` a medida que se escriba; entradas del `.bib` solo verificables; `fichas.yml` al final de la Parte III.

## Pendiente de decisión del autor
- ¿Los grados de libertad `δu_ρ, δψ_ρ` del elemento son componentes **físicas**? El autor cree que sí, sin confirmar (afecta al vector de cargas).
- Placa oblicua: componentes físicas en base **no** ortogonal (la versión corregida solo se ha comprobado con base ortogonal).
- Convenios: componentes físicas no ortogonales; giros de la normal.
- Licencia del libro y del código; alcance de la publicación definitiva (Fase 5). El acceso público y el despliegue inicial ya fueron autorizados y realizados; no equivalen a conceder una licencia ni autorizan nuevos pushes.
