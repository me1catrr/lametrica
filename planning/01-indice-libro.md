# 01 · Título e índice del libro

**Repositorio:** `lametrica` → `me1catrr.github.io/lametrica` · **Título:** *La métrica* · **Lema:** Geometría diferencial · Cálculo tensorial · Mecánica de láminas · **Subtítulo:** De la geometría de las superficies a los elementos finitos.

**Fuente de verdad del índice: `temario.toml`** (bloques → temas, estado, prerrequisitos). `scripts/generar_estructura.jl` genera de él `_navegacion.yml` y la página pública «Mapa del libro» (`book/mapa.qmd`). Este documento recoge, además, la correspondencia interna con el material de `docs/` (solo lectura; nunca se cita en el texto del libro).

**Estética y didáctica:** las de la web Resonancia (paleta única en `styles/paleta.yml`, cajas, ejercicios intercalados, historia, referencias al margen, cierre «La doy por superada si…»). Plantilla de tema: `planning/plantilla-tema.qmd`; tema piloto: `book/01-fundamentos/03-bases.qmd`.

**Hilo narrativo:** Candela construye cáscaras de centímetros de espesor con forma de paraboloide hiperbólico → ¿cómo medimos sobre una superficie curva? (tensores) → ¿qué es y cómo se curva una superficie? (geometría) → ¿cómo se deforma una lámina y qué energía almacena? (elasticidad) → ¿cómo lo calcula un ordenador sin bloquearse? (elementos finitos) → ¿a qué frecuencias vibra un hypar y cuánto nos podemos fiar? (vibraciones y validación).

**Ejemplos recurrentes:** coordenadas polares y cilíndricas → cilindro → esfera → **placa oblicua** (métrica no ortogonal) → **paraboloide hiperbólico** (protagonista) → cilindro pinzado (benchmark).

**Numeración:** los capítulos se numeran correlativamente (Quarto); los identificadores A1…G1 son internos de planificación. Los temas nuevos desplazarán la numeración: las referencias cruzadas se hacen por etiqueta (`@sec-…`), nunca por número escrito a mano.

Leyenda: ★ nuevo · ↻ reescritura de capítulo existente. *Docs* = material interno que lo alimenta.

## Bloque A · Preludio: la forma que resiste
| # | Tema | Contenido | Docs |
|---|---|---|---|
| A1 ★↻ | La cáscara y el paraboloide hiperbólico | Historia (Candela, hypar de pocos centímetros, Oceanogràfic); por qué una lámina curva resiste; mapa del libro | `Introduccion.tex` |
| A2 ★ | Los objetos físicos no dependen de las coordenadas | Vector frente a componentes; repaso mínimo de álgebra y cálculo | – |

## Bloque B · Cálculo tensorial
| # | Tema | Contenido | Docs |
|---|---|---|---|
| B1 ↻ | Transformación de coordenadas y tensores | Jacobiana, leyes de transformación, invariantes | `AnexoGeometria` |
| B2 ↻ **piloto hecho** | Bases covariantes y contravariantes | Reciprocidad, laboratorio; placa oblicua | `skew_plate_2.pdf` |
| B3 ↻ | Tensor métrico y componentes físicas | Longitud, ángulo, área; componentes físicas | – |
| B4 ↻ | Símbolos de Christoffel y derivada covariante | Giro de la base, campo constante en polares | – |
| B5 ★ | Álgebra y análisis tensorial en curvilíneas | ε, gradiente, divergencia, teorema de la divergencia | – |

## Bloque C · Geometría de superficies
| # | Tema | Contenido | Docs |
|---|---|---|---|
| C1 ↻ | Superficies parametrizadas | Base tangente, normal, métrica `a_αβ` | `AnexoGeometria` |
| C2 ↻ | Formas fundamentales y Gauss–Weingarten | `b_αβ = â₃·a_{α,β}`; derivada sobre la superficie (`‖`) | idem |
| C3 ↻ | Curvaturas | Normal, principal, Gauss, media, Euler; `√g` de la lámina | idem |
| C4 ★ | Curvas sobre superficies: geodésicas y compatibilidad | Curvatura geodésica, torsión, *Theorema Egregium*, Codazzi | `AnexoGeometria` |
| C5 ↻ | El paraboloide hiperbólico | Bordes rectos y curvos, reglada, *shallow* | `Simulacion.tex`, `hypar.pdf` |
| C6 ★ | Bestiario de láminas | Cilindro, esfera y placa oblicua paso a paso | `cylindrical_2.pdf`, `sphere.pdf`, `skew_plate_2.pdf` |

## Bloque D · Elasticidad: del sólido a la lámina
| # | Tema | Contenido | Docs |
|---|---|---|---|
| D1 ★ | Deformación y tensión en el sólido | Gradiente, Cauchy–Green, pequeñas deformaciones, equilibrio | `AnexoTeoriaLaminas` |
| D2 ★ | Ley de Hooke y energía de deformación | Simetrías, isotropía, tensión plana | `plane_stress.pdf`, `Elemento` |
| D3 ★ | Cinemática de la lámina | Superficie media, normal, desplazamiento lineal en el espesor | `AnexoTeoriaLaminas` |
| D4 ★ | La hipótesis de Kirchhoff–Love | Normal recta e inextensible; membrana y flexión | `AnexoTeoriaLaminas` |
| D5 ★ | Reissner–Mindlin: el cortante transversal | Giros independientes; comparación con KL | `AnexoTeoriaLaminas`, `Elemento` |
| D6 ★ | Relaciones deformación–desplazamiento | Extensión, flexión, cortante; componentes físicas | `Elemento`, `cylindrical.pdf` |
| D7 ★ | Leyes constitutivas de la lámina | Resultantes N, M, Q; reducción 3D→2D | `Elemento` |
| D8 ★ | Principios variacionales | Trabajo virtual, energía, Hellinger–Reissner, Hu–Washizu genérico | `hypar.pdf` p. 15, `Hu_Washizu_resume.pdf` |

## Bloque E · Elementos finitos de lámina
| # | Tema | Contenido | Docs |
|---|---|---|---|
| E1 ★ | El método de elementos finitos en una barra | Galerkin, ensamblaje, contorno; laboratorio | – |
| E2 ★ | El cuadrilátero bilineal en tensión plana | Coordenadas naturales, isoparamétrico, Gauss | `plane_stress.pdf` |
| E3 ★ | El elemento lámina de cuatro nodos | Interpolación, 5 g.d.l./nodo, área | `Elemento` |
| E4 ★ | Matrices deformación–desplazamiento | `B` de extensión, flexión y cortante | `Elemento`, `cylindrical.pdf` |
| E5 ★ | Bloqueo y modos espurios | Integración reducida, EAS, deformaciones supuestas | `Arte.tex` |
| E6 ★ | Interpolación de deformaciones | Lineal frente a subdominios | `Elemento` |
| E7 ★ | Hu–Washizu por subdominios | Formulación específica; rigidez | `Elemento`, `Slides.pdf` |
| E8 ★ | Cargas y matriz de masa | Fuerzas de volumen (versión corregida), masa consistente | `body_forces.pdf`, `planning/09`, `flat_shell.pdf`, `skew_plate.pdf` |
| E9 ★ | Ensamblaje, condiciones de contorno y autovalores | Conectividad, apoyos, `(K−ω²M)u=0` | `Codigo.tex`, `pinched_cylinder.pdf` |

## Bloque F · Vibraciones y validación
| # | Tema | Contenido | Docs |
|---|---|---|---|
| F1 ★ | Vibraciones de láminas | De 1 GDL a láminas; modos y parámetros adimensionales | `Arte`, `Simulacion` |
| F2 ★ | Validación estática | Patch test, placa oblicua, cilindro pinzado | `pinched_cylinder.pdf` |
| F3 ★ | El hypar de bordes curvos | Esquinas, SSSS, CCCC, mixtas; convergencia | `Simulacion`, `Arte` |
| F4 ★ | El hypar de bordes rectos | Esquinas, SSSS, CCCC | `Simulacion` |
| F5 ★ | Implementación reproducible en Julia | De Mathematica a Julia; contraste | `Codigo.tex` |

## Bloque G · Cierre
| # | Tema | Contenido | Docs |
|---|---|---|---|
| G1 ★ | Conclusiones y futuro | Límites del modelo, líneas futuras | `Conclusiones.tex` |

## Apéndices
A Notación y convenios (existe) · B Glosario · C Chuletas de fórmulas · D Bibliografía comentada · E Solucionarios · F Fuentes y correcciones (registro de errores detectados en las fuentes de partida).
