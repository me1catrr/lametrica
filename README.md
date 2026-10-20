# La métrica

*De la geometría de las superficies a los elementos finitos.*
Geometría diferencial · Cálculo tensorial · Mecánica de láminas.

Libro interactivo hecho con Quarto, Julia y JavaScript. **Estado: prototipo (Fase 2).**

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
Ver `CLAUDE.md` y `planning/`. La documentación científica original (`docs/`) no forma parte del repositorio público.

## Licencias
Pendiente de decidir.
