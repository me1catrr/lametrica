# 02 · Correspondencia capítulos ↔ fuentes de la tesis

Estado: **provisional**. Las referencias de sección se han deducido del orden de `\section` en los `.tex`; faltan verificar numeración final contra `Base.pdf`. Ningún texto se copia: solo referencias (fichero, sección, etiqueta `\label`).

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
