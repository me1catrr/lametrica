# 03 · Arquitectura del repositorio

Referencia: `me1catrr/resonancia` (Quarto + Julia, `temario.yml` como fuente de verdad, `freeze: auto`, `publish.yml`). Añadimos SCSS, JavaScript, tests y figuras con procedencia.

```
lametrica/                      # hoy: carpeta local "geometry" (no se renombra sin orden)
├─ docs/                        # INTACTO; fuera de render y de git público
├─ planning/                    # estos documentos
├─ _quarto.yml  temario.yml  CLAUDE.md  README.md  CITATION.cff  LICENSE*
├─ book/                        # capítulos .qmd por parte
├─ julia/                       # Project.toml, Manifest.toml, src/, test/
├─ web/                         # ojs/, sims/<nombre>/, datos/ (JSON de Julia)
├─ figures/                     # svg/, png/, fuentes/, figures.yml
├─ bib/                         # lametrica.bib, fichas.yml, csl/
├─ styles/                      # SCSS
├─ scripts/                     # generar_estructura.jl, trazabilidad
├─ _freeze/                     # resultados Julia cacheados
└─ .github/workflows/           # tests.yml, publish.yml (no activar sin autorización)
```

Principios: separar fuentes / generado / publicación; `docs/` solo se lee en local para producir metadatos de trazabilidad; nada de `docs/` entra en commits públicos.
