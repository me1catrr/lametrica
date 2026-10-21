# 07 · Plan de desarrollo (5 fases)

**Última actualización: 2026-10-21 (tarde).** Fase 3 en curso: 9 de 20 capítulos escritos (45 %).

1. **Auditoría y planificación** — hecha.
2. **Prototipo** — hecha (commit `3e53b62`).
3. **Desarrollo científico** — en curso (commit `d48fe78`: Partes I y II). Nuevo material del autor disponible (ver abajo).
4. **Validación** — pendiente (parte adelantada en los tests y scripts de verificación).
5. **Publicación** — pendiente; solo con orden expresa.

Reglas: sin commits ni pushes sin autorización; sin instalaciones globales sin consulta; `docs/` intacto.

## Hecho hoy (2026-10-21)
- Tests de Julia: 123 comprobaciones, 7 conjuntos, **pasan** (en el sandbox hace falta `JULIA_DEPOT_PATH="$TMPDIR/depot:$HOME/.julia"`).
- **P0 hecho:** verificación de `docs/Ejemplos/body_forces.pdf` → `09-verificacion-fuerzas-volumen.md` (`julia/scripts/verificar_fuerzas_volumen.jl`, 29/29). Resumen: págs. 1–2 y 4–6 correctas; pág. 3 con un error de signo, un coeficiente `2/R` (debe ser `1/R`) y una omisión de términos en `K`; y la expresión de partida con `μᵖ_α` **no reproduce el trabajo de un peso uniforme** (error ≈ 10⁻⁴ con `t/R = 0,1`). El propio autor la marca «Wrong! See BF-1÷8» y esas páginas no están en `docs/`. **Decisión del autor:** no dispone de la versión correcta; se adopta la **versión corregida** derivada aquí (`δW = t(1+Kt²/12)(Xᵖδu_ρ+X³δu₃) − (Ht³/6)Xᵖδψ_ρ`, comprobada numéricamente en cilindro, esfera e hypar), que sustituye a SD-12. Limitación: valida el álgebra, no que la cinemática coincida con la de la tesis.
- **P1 hecho:** `hypar.pdf` págs. 1–3 y `sphere.pdf` pág. 1 coinciden con `Geometria.jl` (15/15, `julia/scripts/verificar_apuntes_geometria.jl`), incluido el convenio `b_αβ = â₃·a_{α,β}`.
- **P2 hecho:** inventario de `docs/Ejemplos` en `00-inventario-docs.md`.
- **P3 hecho (parcial):** numeración de secciones de la tesis contrastada con el índice de `Base.pdf`, en `02-trazabilidad-tesis.md` (solo el índice; falta contrastar contenido capítulo a capítulo).
- Poppler ya estaba instalado (26.10.0). **Node reinstalado por el autor** (v26.12.0): `npm test` pasa, 6/6 (JS coincide con Julia 1.12.3).
- El remoto `origin` (`me1catrr/lametrica`) existe y `main` coincide con `origin/main` (`d48fe78`); existe la rama `gh-pages` (la publicación parece activa, no verificado desde aquí).

## Estado de la Fase 3

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
- `quarto render`: no relanzado hoy; `_book/` y `_freeze/` son del 2026-10-20.

### Simulaciones (1 de 12)
Hecha: #3 (bases cov./contrav.). Pendientes: el resto. Los caps. 2 y 4–9 usan figuras SVG estáticas.

### Figuras, bibliografía, trazabilidad
- 15 SVG exactos generados por código; **todos con revisión visual humana pendiente**; sin figuras conceptuales (FigureLabs).
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
3. **Cerrar Parte II:** revisión visual de las 15 figuras, `quarto render` completo, enlaces cruzados; `npm test` ya pasa.
4. **Parte III (caps. 10–12):** crear `Laminas.jl` (cinemática, Cauchy–Green, KL vs. RM) con tests; antes, fijar los dos convenios pendientes del apéndice A (componentes físicas en bases no ortogonales; giros de la normal) → decisión del autor. `plane_stress.pdf` puede alimentar el cap. 12.
5. **Partes IV–V (caps. 13–20):** Hu–Washizu por subdominios contrastado con `Elemento.tex` (§3.6.2 y 3.7.1, p. 69–71 de `Base.pdf`); Anexo C (p. 169) reescrito en Julia; casos de las simulaciones (tesis §4.2.2, §4.3.2) y de `skew_plate` para validar.
6. **Trazabilidad y bibliografía:** `trazabilidad/ecuaciones.yml` a medida que se escriba; entradas del `.bib` solo verificables; `fichas.yml` al final de la Parte III.

## Pendiente de decisión del autor
- ¿Los grados de libertad `δu_ρ, δψ_ρ` del elemento son componentes **físicas**? El autor cree que sí, sin confirmar (afecta al vector de cargas).
- Placa oblicua: componentes físicas en base **no** ortogonal (la versión corregida solo se ha comprobado con base ortogonal).
- Convenios: componentes físicas no ortogonales; giros de la normal.
- Licencia del libro y del código; publicación (Fase 5).
