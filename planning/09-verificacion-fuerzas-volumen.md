# 09 · Verificación de `docs/Ejemplos/body_forces.pdf` (serie SD-12)

Fecha: 2026-10-21. Material: apuntes manuscritos del autor (6 págs., sin fecha), **no es de la tesis**: las fuerzas de volumen no aparecen en los `.tex` (0 coincidencias en `Elemento`, `AnexoTeoriaLaminas`, `Codigo`, `Simulacion`).

**Aviso del propio autor.** La pág. 1 dice «**Wrong! See BF-1÷8**». Esas páginas (BF-1…8) **no están en `docs/`**. Todo lo que sigue evalúa SD-12 *tal como está*; no es una valoración de la versión correcta, que no se ha visto.

Código: `julia/scripts/verificar_fuerzas_volumen.jl` (29 comprobaciones, 0 fallos) y `julia/scripts/verificar_apuntes_geometria.jl` (15 comprobaciones, 0 fallos). Semilla fija. Etiqueta: *calculado* = ejecutado; *analítico* = deducido a mano; *sin verificar* = hipótesis.

## Modelo de los apuntes
`δu_α(3D) = μᵖ_α(δu_ρ + θδψ_ρ)`, `μᵖ_α = δᵖ_α − θbᵖ_α`, `dV = μ dθ dF`, `μ = 1 − 2Hθ + Kθ²`, `H = ½bᵅ_α`, `K = det bᵅ_β`. «Exacto» en el script = `∫ δu(θ)·X μ dθ` con `X` un vector fijo (peso propio), sin aproximación alguna de los apuntes. Superficies de prueba: cilindro (`R=2`), esfera (`R=2`) e hypar (`a=1, b=1,2, c=0,15`).

## Veredicto por página

| Pág. | Contenido | Veredicto | Evidencia |
|---|---|---|---|
| 1–2 | Producto de `μᵖ_α bᵅ (δu_ρ+θδψ_ρ)` por `μ`; tachado de potencias impares de θ | **Correctas** (álgebra) | *calculado*: el desarrollo de SD-12/2 reproduce la integral de SD-12/1 con diferencia absoluta ≤ 7·10⁻¹⁸ en los tres casos |
| 3 | Resultado reducido y caso del cilindro | **Dos errores confirmados + una omisión** | ver abajo |
| 4–6 | Descomposición del peso `X` en `â_i` por productos triples; `b̃ⁱ = tγ·pᵢ` | **Correctas para el cilindro** | *calculado*: `λ=1`, `pᵢ` = fórmulas de SD-12/6 (Δ ≤ 2·10⁻¹¹), `X = Σpᵢâᵢ` (3 posiciones) |

### Pág. 3 (lectura confirmada ampliando el escaneo)
1. **Signo.** SD-12/2 da `+2H θ² bᵖ_α bᵅ δu_ρ` (de `−2H·(−θ² …)`); SD-12/3 escribe `−2Hθ² bᵖ_α bᵅ δu_ρ`. *Calculado:* con el signo escrito, la discrepancia con SD-12/1 es 3,5·10⁻⁷ (cilindro); con `+`, 0.
2. **Coeficiente en el cilindro.** `−2H = 1/R` (con `H = −1/2R`, que da `−0,25` para `R=2`: calculado), pero SD-12/3 escribe `2/R` en los dos últimos términos. *Calculado:* con `2/R` el error es 1,0·10⁻⁵; con `1/R`, 1,7·10⁻¹³.
3. **Omisión no declarada** de los términos con `K` y `θ⁴` (que SD-12/2 sí conservaba, subrayados). Exacto en el cilindro (`K=0`); en esfera e hypar el error es de orden `Kt²/12`: *calculado* en traslación rígida, 8,33·10⁻⁴ medido frente a 8,33·10⁻⁴ (esfera, `t/R=0,1`) y 5,99·10⁻⁴ frente a 5,98·10⁻⁴ (hypar).
4. Erratas menores: `b^ρ·u_ρ` en vez de `δu_ρ` en el resultado final; `ρ₀` (pág. 1) sin definir y desaparece después.
5. **«≈ 0» está justificado** si `δψ ~ δu/R`: *calculado*, el error de `t(bᵖδu_ρ + b³δu₃)` frente a la integral exacta decae con pendiente log-log **2,00** en `t/R` (1,7·10⁻⁴ → 1,7·10⁻⁶ → 1,7·10⁻⁸). *(Mi lectura previa, que apuntaba a `O(t/R)`, era incorrecta.)* Si `δψ` fuera del orden de `δu/t` (flexión dominante) no está comprobado.

## Hallazgo principal
Con una **traslación rígida** (`δu = c` constante), el trabajo exacto del peso es `(c·X)(t + Kt³/12)`, identidad que el script reproduce a 10⁻⁹ en los tres casos. En el cilindro (`K=0`) el término de orden cero `t(bᵖδu_ρ + b³δu₃)` es **exacto** (error 1,4·10⁻¹⁶), pero **la expresión de SD-12/1, con el factor `μᵖ_α`, no lo es**: error relativo 1,4·10⁻⁴ (cilindro), 1,9·10⁻⁴ (esfera), 1,7·10⁻⁴ (hypar) con `t/R=0,1`. Es decir, la expresión completa de partida de SD-12 **no reproduce el trabajo de un peso uniforme** aunque sus pasos algebraicos sean correctos.

*Sin verificar (hipótesis):* `μᵖ_α bᵅ` es correcto si `bᵅ` son las componentes contravariantes del peso en la base **`g_α` de la lámina** (que varían con θ), pero las págs. 4–6 calculan `bᵅ` como componentes sobre la base de la **superficie media** `â_i` (constantes en θ), que es lo que hace que los términos impares se anulen. Esa mezcla podría ser lo que el autor marcó como «Wrong». Habría que compararlo con BF-1÷8.

## Componentes físicas (págs. 4–6)
Las `pᵢ` son componentes **sobre `â_i` unitarios** (*calculado*: `p₁ = R·b¹` con `|a₁| = R`, en las tres posiciones). Entonces `δu_ρ` también debe ser físico; si el elemento usa `δu_ρ` covariantes (sobre `a_ρ`) hay un factor `|a_ρ|`. **Pregunta abierta al autor.** Además, en la caja de la pág. 4 se lee `b̃² = tγ(X)`, y la pág. 6 da `p₍₂₎ = Y`; es probable una errata de letra (a confirmar con el autor).

## Versión corregida (derivación propia, 2026-10-21)
**Estado: derivada y comprobada numéricamente; no procede de la tesis ni de BF-1÷8** (el autor no dispone de la versión correcta). Sustituye a SD-12/1–3 para el vector de cargas.

Hipótesis (las de los apuntes, sin contrastar con la cinemática de la tesis): `δu = (δu_ρ + θδψ_ρ) aᵖ + δu₃ â₃` (componentes covariantes `δu_ρ`, `δψ_ρ`; `δu₃` constante en el espesor), `dV = μ dθ dF`, `μ = 1 − 2Hθ + Kθ²`, fuerza por unidad de volumen **constante** `X` (peso propio `X = γ·g`).

Se descompone `X` en la base de la **superficie media**: `Xᵖ = aᵖ·X`, `X³ = â₃·X`, que **no dependen de θ**. Entonces `δu·X = (δu_ρ + θδψ_ρ)Xᵖ + δu₃X³` y no aparece `μᵖ_α` (era el origen de la discrepancia). Con los momentos `∫μ dθ = t(1 + Kt²/12)` y `∫θμ dθ = −Ht³/6`:

```
δW = ∫_F [ t(1 + K t²/12)(Xᵖ δu_ρ + X³ δu₃)  −  (H t³/6) Xᵖ δψ_ρ ] dF          (exacta bajo las hipótesis)
δW ≈ t ∫_F (Xᵖ δu_ρ + X³ δu₃) dF                                              (error relativo O((t/R)²))
```

- **Cargas nodales equivalentes (orden cero):** `b̃ᵖ = t·Xᵖ`, `b̃³ = t·X³`. Con `X = γ(X_x, X_y, X_z)` y la base del cilindro de los apuntes, `b̃ⁱ = tγ·pᵢ` con las `pᵢ` de SD-12/6 (**las págs. 4–6 siguen valiendo**, como componentes físicas).
- **Términos que se descartan en el orden cero:** `Kt²/12` (relativo) y el acoplamiento con los giros `−(Ht³/6)Xᵖδψ_ρ`. Con `δψ ~ δu/R` ambos son `O((t/R)²)`.
- **Cilindro** (`K=0`, `H=−1/2R`): `δW = t(Xᵖδu_ρ + X³δu₃) + (t³/12R)Xᵖδψ_ρ`.
- **Componentes físicas:** para base ortogonal en el punto (cilindro, plano, esfera en coordenadas esféricas; **no** el hypar, con `a₁₂ = −4c²θ¹θ² ≠ 0`) `Xᵖδu_ρ = X_(ρ)δu_(ρ)`, de modo que la misma expresión vale con componentes físicas de fuerza, desplazamiento y giro. *Calculado* en el cilindro. **No se ha comprobado para bases no ortogonales** (p. ej. placa oblicua): ahí el convenio de componentes físicas sigue pendiente (apéndice de notación).
- **Pendiente de convenio:** signo y orientación de los giros `δψ_ρ` (cinemática de la lámina, Parte III). El término en `δψ` depende de él.

*Calculado* (`verificar_fuerzas_volumen.jl`, sección 5): la fórmula cerrada coincide con la integral exacta con error relativo ≈ 10⁻¹⁶ en cilindro, esfera e hypar, con `t = 0,2` y `0,05` y `δψ ≠ 0`. **Limitación:** «exacta» está calculada con la misma cinemática; esto valida el álgebra de momentos y la eliminación de `μᵖ_α`, **no** que la cinemática (rotaciones con `aᵖ`, `δu₃` constante) sea la de la tesis. Esa contrastación está pendiente (Parte III).

## Qué se puede y qué no se puede usar
- **No** usar SD-12 como fuente de fórmulas para el libro (marcada «Wrong» por el autor).
- Usar la **versión corregida** de arriba (derivación propia verificada numéricamente), no SD-12.
- BF-1÷8 no está disponible: la versión corregida es la referencia. Si el autor la reencuentra, se compara con ella.

## Contraste adicional (P1): `hypar.pdf` págs. 1–3 y `sphere.pdf` pág. 1
*Calculado*, 15/15 comprobaciones superadas frente a `Geometria.jl` (`julia/scripts/verificar_apuntes_geometria.jl`): vectores básicos, normal, `a_αβ`, `det`, `a^{αβ}`, `a¹`, `a²` (incluida la tercera componente `−2a²cθ²/det`, marcada «OJO!»), `b_αβ`, `bᵅ_β`; esfera con normal saliente (`bαβ` definida negativa, `K = 1/R²`, `H = −1/R`). **Confirma que los apuntes usan el convenio `b_αβ = â₃·a_{α,β}` fijado para el libro.** Solo se han transcrito las págs. 1–3 de `hypar.pdf` y la pág. 1 de `sphere.pdf`; el resto sin leer.

## Limitaciones
- Transcripción manual de letra; las dos lecturas críticas (signo y `2/R` en la pág. 3) se confirmaron ampliando el escaneo, la `X` de la caja de la pág. 4 no.
- Las comprobaciones sobre «SD-12/3 como está escrito» replican mi lectura del texto; no son el cálculo del autor.
- No se ha comparado con ninguna fuente publicada de fuerzas de volumen en láminas.
