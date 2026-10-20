# 06 · Bibliografía y figuras

## Bibliografía
- Una única fuente: `bib/lametrica.bib`, partiendo de `bibliografia.bib` de la tesis (171 entradas), depurada **solo con datos presentes**. Campos dudosos → `note = {VERIFICAR}` y consulta al autor. No se añaden DOI ni datos no verificados.
- `bib/fichas.yml`: metadatos propios (temática, dificultad, comentario, itinerarios) por clave BibTeX.
- Biblioteca con búsqueda y filtros en JS, generada en build; vistas previas de citas con popover de Quarto; itinerarios de lectura.

## Figuras
- `figures/{svg,png,fuentes}/` y `figures/figures.yml`: origen, herramienta, archivo fuente o prompt, versión, fecha, capítulo/ecuación asociados, estado de revisión matemática.
- Figuras de geometría exacta (superficies, bases, mallas) → código (Julia/JS → SVG). FigureLabs → ilustraciones conceptuales y diagramas de flujo, nunca geometría que no pueda garantizarse.
- Los EPS de la tesis son referencia visual, no se reutilizan. No se envía material de `docs/` a servicios externos sin autorización.
