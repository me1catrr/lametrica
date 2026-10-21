# 04 · Integración Quarto–Julia–JavaScript

- **Julia**: `engine: julia` nativo, un entorno en `julia/`. Módulos `Geometria.jl` (bases, métrica, Christoffel, curvaturas; `ForwardDiff`/`Symbolics` para comprobaciones) y después `Laminas.jl`. `freeze: auto` y `_freeze/` en git: CI no necesita Julia para publicar. Tests con `Test` en un workflow aparte.
- **JavaScript**: simulaciones iniciales 100 % cliente (Observable JS + módulos ES propios; Plotly.js para 2D/superficies, Three.js para 3D y modos animados). La geometría se reimplementa en JS y se **verifica contra JSON de referencia generado por Julia** (test en Node).
- **Puente**: Julia escribe `web/datos/*.json` con metadatos (`calculado | analítico | ilustrativo`, versión, semilla). JS solo visualiza. Cada figura/simulación muestra su etiqueta.
- **Estilo**: SCSS con callouts definición (azul), teorema (verde), advertencia (ámbar), laboratorio (violeta), demostración/observación (neutro, desplegable). Ecuaciones `#eq-`, figuras `#fig-`, MathJax con macros propias para `\sideset`, citas con popover.
- **Requisito previo** (resuelto): Quarto 1.10.19 instalado y fijado en `publish.yml`. Julia 1.12.3. Node: el de Homebrew está roto desde 2026-10-21 (ver `07-plan-fases.md`).
