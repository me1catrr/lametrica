# La métrica

*De la geometría de las superficies a los elementos finitos.*
Geometría diferencial · Cálculo tensorial · Mecánica de láminas.

Libro interactivo hecho con Quarto, Julia y JavaScript. **Estado: desarrollo (Fase 3) — Partes I y II escritas; ver `planning/07-plan-fases.md`.**

## Visibilidad del repositorio
El 21 de octubre de 2026 se cambió la visibilidad de [me1catrr/lametrica](https://github.com/me1catrr/lametrica) de privado a **público** mediante la API de GitHub.
La verificación posterior confirmó `visibility: public` y `private: false`; la rama predeterminada es `main` y el repositorio no está archivado ni deshabilitado.
Este cambio permite consultar el repositorio públicamente; no supone la concesión de una licencia de uso (ver «Licencias»).

## Requisitos
- Quarto 1.10.x · Julia 1.12 · Node 24 (solo para las pruebas JS)

## Compilar en local
```bash
quarto render      # genera _book/
quarto preview
```

## Pruebas
```bash
julia --project=julia -e 'using Pkg; Pkg.test()'
cd web && npm test
```

## Estructura
Ver `CLAUDE.md` y `planning/`. La documentación científica original (`docs/`) no forma parte del repositorio.

## Licencias
Pendiente de decidir.
