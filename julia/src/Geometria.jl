"""
    Geometria

Operadores elementales de geometría diferencial para *La métrica*.

Convenio de este módulo (Cap. 3 del libro): una base `{g₁,…,gₙ}` se guarda como
una matriz `B` cuyas **columnas** son los vectores `gᵢ`, expresados en una base
cartesiana ortonormal. Los índices altos y bajos se distinguen por el nombre:
`Vup` son las componentes contravariantes `Vⁱ` y `Vdn` las covariantes `Vᵢ`.

Fuente conceptual en la tesis: Anexo A (`AnexoGeometria.tex`), sección
«Vectores básicos y tensor métrico de una superficie». Numeración por verificar.
"""
module Geometria

using LinearAlgebra

export metrica, base_reciproca, comps_contravariantes, comps_covariantes,
       desde_contravariantes, reciprocidad, base_polar

"""
    metrica(B)

Tensor métrico covariante `gᵢⱼ = gᵢ·gⱼ` de la base de columnas `B`.
"""
metrica(B::AbstractMatrix) = transpose(B) * B

"""
    base_reciproca(B)

Base recíproca (contravariante) `gⁱ = gⁱʲ gⱼ`, con `gⁱʲ = (gᵢⱼ)⁻¹`.
Devuelve una matriz cuyas columnas son los `gⁱ`.
"""
base_reciproca(B::AbstractMatrix) = B * inv(metrica(B))

"""
    reciprocidad(B)

Matriz `gⁱ·gⱼ`. Debe ser la identidad (delta de Kronecker).
"""
reciprocidad(B::AbstractMatrix) = transpose(base_reciproca(B)) * B

"""
    comps_contravariantes(B, V)

Componentes `Vⁱ = V·gⁱ` del vector cartesiano `V`, de modo que `V = Vⁱ gᵢ`.
"""
comps_contravariantes(B::AbstractMatrix, V::AbstractVector) =
    transpose(base_reciproca(B)) * V

"""
    comps_covariantes(B, V)

Componentes `Vᵢ = V·gᵢ` del vector cartesiano `V`, de modo que `V = Vᵢ gⁱ`.
"""
comps_covariantes(B::AbstractMatrix, V::AbstractVector) = transpose(B) * V

"""
    desde_contravariantes(B, Vup)

Reconstruye el vector cartesiano `V = Vⁱ gᵢ`.
"""
desde_contravariantes(B::AbstractMatrix, Vup::AbstractVector) = B * Vup

"""
    base_polar(r, θ)

Base covariante natural de las coordenadas polares `(θ¹,θ²) = (r,θ)`:
`g₁ = ∂x/∂r = (cos θ, sin θ)`, `g₂ = ∂x/∂θ = (−r sin θ, r cos θ)`.
Es ortogonal pero **no** ortonormal: `gᵢⱼ = diag(1, r²)`.
"""
base_polar(r, θ) = [cos(θ) -r*sin(θ); sin(θ) r*cos(θ)]

end # module
