# 08 · Riesgos y decisiones

## Decisiones (ADR)
- **ADR-001** Nombre del repo y libro: `lametrica` / «La métrica» (decidido por el autor, 2026-10-20).
- **ADR-002** Fuente primaria: los `.tex` de la tesis; los PDF escaneados solo para cotejo.
- **ADR-003** Julia nativo en Quarto con `freeze: auto` (como resonancia).
- **ADR-004** Simulaciones iniciales solo en cliente; Julia → JSON para casos avanzados.
- **ADR-005** SCSS (no CSS plano) para el tema.
- **ADR-006** Una única `.bib`; figuras exactas generadas por código.

## Riesgos abiertos
1. **Quarto no instalado**; versión a fijar (¿1.10.x?). Requiere autorización.
2. **Escaneos sin texto**: OCR no fiable en ecuaciones.
3. **Convenciones de la tesis** (signo de `b_{αβ}`, `Γ̄`, `ẽ`, `‖`, componentes físicas): documentar y confirmar antes de fijar.
4. **KL vs. RM**: mantener separadas las hipótesis cinemáticas.
5. **Hu–Washizu**: conservar la formulación por subdominios; contrastar línea a línea con `Elemento.tex`.
6. **Reproducibilidad**: casos de referencia numéricos del cap. 4 y tolerancias a acordar para comparar Julia con Mathematica.
7. **MathJax**: macros para `\sideset`/`esvect`.
8. **Derechos**: © 2008; redacción nueva, sin copia literal, sin publicar `docs/`; licencia del libro por decidir.
9. **Bibliografía**: tipos dudosos; saneado manual.
10. **Rendimiento web**: JSON ligeros; Three.js solo cuando Plotly no baste.
11. **Carpeta local `geometry`**: no se renombra sin orden del autor.
