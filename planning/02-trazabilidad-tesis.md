# 02 · Correspondencia capítulos ↔ fuentes de la tesis

Estado: **numeración verificada contra el índice de `Base.pdf` (2026-10-21, solo el índice, no el cuerpo)**; el contenido de cada sección sigue por contrastar al escribir cada capítulo. Ningún texto se copia: solo referencias (fichero, sección, etiqueta `\label`).

Abreviaturas: A = `AnexoGeometria.tex` · B = `AnexoTeoriaLaminas.tex` · E = `Elemento.tex` · S = `Simulacion.tex` · AC = `Arte.tex` · C = `Codigo.tex`.

| Cap. libro | Fuente (tesis) | Notas |
|---|---|---|
| 1 Motivación | Introducción (`Introduccion.tex`) | Contenido nuevo; la tesis solo motiva |
| 2 Transformación de coordenadas | A (introducción) | Parte nueva |
| 3 Bases cov./contrav. | A «Vectores básicos y tensor métrico» | Verificar reciprocidad `a_i·a^j=δ_i^j` |
| 4 Tensor métrico, comp. físicas | A «Vectores básicos…», «Tensor métrico en 3D»; E «Componentes físicas…» | |
| 5 Christoffel, derivada cov. | A «Derivadas de los vectores básicos», «Derivadas de vectores» | Documentar signo/convención de `Γ̄` |
| 6 Superficies parametrizadas | A «Vectores básicos…», «Producto de vectores básicos» | |
| 7 Formas fundamentales | A «Formas fundamentales» | |
| 8 Curvaturas | A «Curvatura y torsión», «Diferenciales de volumen y área» | Signo de `b_{αβ}` |
| 9 Paraboloide hiperbólico | S «Geometría» (bordes curvos y rectos) | |
| 10 Cinemática, Cauchy–Green | B «Cinemática», «Tensor de deformación de Cauchy–Green» | |
| 11 KL vs. RM | B «Hipótesis de Kirchhoff»; AC «Teoría general de láminas» | Separar hipótesis |
| 12 Def.–despl., constitutivas | B «Pequeñas deformaciones», «Relación deformación–desplazamiento…»; E 3.5 | |
| 13 Variacionales mixtos | E 3.7 (introducción); AC | Contenido nuevo parcial |
| 14 Elemento cuadrilátero | E 3.2, 3.3 (funciones de forma bilineales, área) | |
| 15 Extensión/flexión/cortante | E 3.4 | |
| 16 Hu–Washizu y subdominios | E 3.6, 3.7 | **Formulación específica, no genérica** |
| 17 Masa consistente | E 3.8 | |
| 18 Ensamblaje, contorno, autovalores | C (ensamblaje, condiciones de contorno); E | |
| 19 Modos de PH | S «Casos prácticos» | Valores de referencia |
| 20 Julia vs. Mathematica | C (todos los módulos) | Tests de igualdad |

Cada ecuación del libro llevará en un YAML (`trazabilidad/ecuaciones.yml`, Fase 3) su origen: documento, capítulo/anexo, sección, número/etiqueta, estado (`verificada` / `no verificada` / `derivada por el autor`).

## Numeración real (índice de `Base.pdf`, 244 págs.)
Contrastada con `pdftotext` sobre el índice; algunas líneas del índice no se capturaron (p. ej. 3.4.4, 3.7), así que no es un listado completo.

- **Cap. 3 Elemento:** 3.1 Introducción (p. 55) · 3.2 Interpolación (56) y 3.2.1 Funciones de forma bilineales (58) · 3.3 Área (59) · 3.4 Relación deformación–desplazamiento (60): 3.4.1 extensión, 3.4.2 flexión, 3.4.3 cortante, 3.4.5 matrices (63) · 3.5 Leyes constitutivas (64), 3.5.1 en componentes físicas (66) · 3.6 Interpolación de las deformaciones (68), 3.6.1 lineal, 3.6.2 **subdominios** (69) · 3.7.1 **Principio variacional de Hu–Washizu** (71) · 3.8 Matriz de masa consistente (79).
- **Cap. 4 Simulaciones:** 4.2 bordes curvos (86; 4.2.1 Geometría, 4.2.2 Casos prácticos, p. 91) · 4.3 bordes rectos (118; 4.3.1 Geometría, 4.3.2 Casos prácticos, p. 122).
- **Anexo A (p. 139):** A.2 Vectores básicos y tensor métrico (140) · A.3 Producto (142) · A.4 Derivadas de los vectores básicos (143) · A.5 Tensor métrico 3D (145) · A.6 Formas fundamentales (145) · A.7 Curvatura y torsión (146) · A.8 Diferenciales de volumen y área (150) · A.9 Derivadas de vectores (152).
- **Anexo B (p. 155):** B.2 Cinemática (156) · B.3 Cauchy–Green (158) · B.4 Hipótesis de Kirchhoff (159) · B.5 Pequeñas deformaciones (161) · B.6 Relación deformación–desplazamiento (164).
- **Anexo C (p. 169):** C.2 Datos de entrada · C.3 Mallado · C.4 Interpolación · C.6 Geometría de la superficie (183) · C.8 Deformación–desplazamientos (185) · C.9 Constitutivas · C.10 Rigidez · C.11 Masa · C.13 Ensamblaje (187) · C.14 Condiciones de contorno (187) · C.16 Programa final.

Consecuencia: el cap. 9 apunta a «Simulaciones» 4.2.1 y 4.3.1 (Geometría), y la *formulación específica* de Hu–Washizu está en 3.6.2 y 3.7.1 (no 3.6–3.7 genérico). Correcciones a la tabla de arriba pendientes de aplicar al escribir los caps. 14–17.

## Material que no procede de la tesis: apuntes del autor
Lo basado en `docs/Ejemplos/` y `Hu_Washizu_resume.pdf` son **apuntes manuscritos del autor**, no de la tesis (ver `00-inventario-docs.md`). Las **fuerzas de volumen** no aparecen en ningún `.tex` de la tesis; ver `09-verificacion-fuerzas-volumen.md`.
