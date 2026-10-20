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
       desde_contravariantes, reciprocidad, base_polar,
       base_esferica, jacobiana_numerica, transformar_contra, transformar_cov,
       transformar_tensor_contra, transformar_tensor_cov, comps_fisicas,
       cristoffel, cristoffel_desde_metrica, derivada_cov_contra, derivada_cov_cov,
       paraboloide_curvo, paraboloide_recto, base_superficie, normal_unitaria,
       derivadas_segundas, segunda_forma, tensor_curvatura_mixto, curvaturas_principales,
       curvatura_normal, base_lamina, cristoffel_superficie, area_relativa

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

"""
    base_esferica(r, θ, φ)

Base covariante natural de las coordenadas esféricas `(θ¹,θ²,θ³) = (r,θ,φ)`
(`θ` colatitud, `φ` azimut), con columnas `gᵢ = ∂x/∂θⁱ`. Métrica
`gᵢⱼ = diag(1, r², r² sin²θ)`.
"""
base_esferica(r, θ, φ) = [sin(θ)*cos(φ)  r*cos(θ)*cos(φ)  -r*sin(θ)*sin(φ);
                          sin(θ)*sin(φ)  r*cos(θ)*sin(φ)   r*sin(θ)*cos(φ);
                          cos(θ)        -r*sin(θ)          0.0]

"""
    jacobiana_numerica(f, θ; h = 1e-6)

Matriz `J[i,j] = ∂fⁱ/∂θʲ` por diferencias centradas. `f` devuelve un vector.
"""
function jacobiana_numerica(f, θ::AbstractVector; h = 1e-6)
    n = length(θ)
    cols = map(1:n) do j
        e = zeros(n); e[j] = h
        (f(θ .+ e) .- f(θ .- e)) ./ (2h)
    end
    reduce(hcat, cols)
end

"""
    transformar_contra(J, V)

Ley de transformación de componentes contravariantes, `V'ⁱ = Jⁱⱼ Vʲ`, con
`J = ∂θ'/∂θ` (`@eq-transformacion` del libro).
"""
transformar_contra(J::AbstractMatrix, V::AbstractVector) = J * V

"""
    transformar_cov(J, V)

Componentes covariantes: `V'ᵢ = (J⁻¹)ʲᵢ Vⱼ`, con `J = ∂θ'/∂θ`.
"""
transformar_cov(J::AbstractMatrix, V::AbstractVector) = transpose(inv(J)) * V

"""
    transformar_tensor_contra(J, T)

Tensor de orden dos contravariante: `T'ⁱʲ = Jⁱₖ Jʲₗ Tᵏˡ`.
"""
transformar_tensor_contra(J::AbstractMatrix, T::AbstractMatrix) = J * T * transpose(J)

"""
    transformar_tensor_cov(J, T)

Tensor de orden dos covariante: `T'ᵢⱼ = (J⁻¹)ᵏᵢ (J⁻¹)ˡⱼ Tₖₗ`.
"""
function transformar_tensor_cov(J::AbstractMatrix, T::AbstractMatrix)
    K = inv(J)
    transpose(K) * T * K
end

"""
    comps_fisicas(B, Vup)

Componentes físicas de un vector en una base **ortogonal**: coordenadas de `V`
respecto a la base normalizada, `V⁽ⁱ⁾ = √gᵢᵢ Vⁱ` (sin suma).
"""
function comps_fisicas(B::AbstractMatrix, Vup::AbstractVector)
    g = metrica(B)
    @assert isapprox(g, Diagonal(diag(g)); atol = 1e-10) "la base no es ortogonal"
    sqrt.(diag(g)) .* Vup
end

"""
    cristoffel(base, θ; h = 1e-5)

Símbolos de Christoffel de segunda especie `Γᵏᵢⱼ = gᵏ·∂gᵢ/∂θʲ` (array `Γ[k,i,j]`),
a partir de la función `base(θ)` (columnas `gᵢ`), con derivadas por diferencias
centradas. Válido para espacios planos en coordenadas curvilíneas.
"""
function cristoffel(base, θ::AbstractVector; h = 1e-5)
    n = length(θ)
    B = base(θ)
    Gr = base_reciproca(B)
    Γ = zeros(n, n, n)
    for j in 1:n
        e = zeros(n); e[j] = h
        dB = (base(θ .+ e) .- base(θ .- e)) ./ (2h)   # columnas ∂gᵢ/∂θʲ
        for i in 1:n, k in 1:n
            Γ[k, i, j] = dot(Gr[:, k], dB[:, i])
        end
    end
    Γ
end

"""
    cristoffel_desde_metrica(g, θ; h = 1e-5)

`Γᵏᵢⱼ = ½ gᵏˡ (∂ᵢ gₗⱼ + ∂ⱼ gₗᵢ − ∂ₗ gᵢⱼ)` a partir de la función `g(θ)` que
devuelve la matriz métrica. Solo usa la métrica (geometría intrínseca).
"""
function cristoffel_desde_metrica(g, θ::AbstractVector; h = 1e-5)
    n = length(θ)
    dg = zeros(n, n, n)                                # dg[i,j,k] = ∂ₖ gᵢⱼ
    for k in 1:n
        e = zeros(n); e[k] = h
        dg[:, :, k] = (g(θ .+ e) .- g(θ .- e)) ./ (2h)
    end
    ginv = inv(g(θ))
    Γ = zeros(n, n, n)
    for i in 1:n, j in 1:n, k in 1:n
        Γ[k, i, j] = 0.5 * sum(ginv[k, l] * (dg[l, j, i] + dg[l, i, j] - dg[i, j, l]) for l in 1:n)
    end
    Γ
end

"""
    derivada_cov_contra(Γ, V, dV)

Derivada covariante `Vⁱ‖ⱼ = ∂ⱼVⁱ + Γⁱₖⱼ Vᵏ` (matriz `[i,j]`). `dV[i,j] = ∂ⱼVⁱ`.
"""
function derivada_cov_contra(Γ, V, dV)
    n = length(V)
    [dV[i, j] + sum(Γ[i, k, j] * V[k] for k in 1:n) for i in 1:n, j in 1:n]
end

"""
    derivada_cov_cov(Γ, V, dV)

Derivada covariante `Vᵢ‖ⱼ = ∂ⱼVᵢ − Γᵏᵢⱼ Vₖ` (matriz `[i,j]`). `dV[i,j] = ∂ⱼVᵢ`.
"""
function derivada_cov_cov(Γ, V, dV)
    n = length(V)
    [dV[i, j] - sum(Γ[k, i, j] * V[k] for k in 1:n) for i in 1:n, j in 1:n]
end

# ---------------------------------------------------------------------------
# Superficies parametrizadas  r(θ¹,θ²) ⊂ ℝ³  (Parte II)
#
# Convenios (Cap. 6–8): aα = ∂r/∂θᵅ (columnas de la matriz 3×2 `A`);
# n̂ = a₁×a₂/|a₁×a₂|;  bαβ = n̂·∂²r/∂θᵅ∂θᵝ = n̂·aα,β  (segunda forma);
# con n̂ saliente en una esfera, bαβ < 0.

"""
    paraboloide_curvo(Rx, Ry)

Superficie `r(θ¹,θ²) = (θ¹, θ², −½(θ¹²/Rx + θ²²/Ry))` (con `Rx·Ry < 0`: paraboloide
hiperbólico con bordes, en planta, paralelos a los ejes principales).
"""
paraboloide_curvo(Rx, Ry) = θ -> [θ[1], θ[2], -(θ[1]^2 / Rx + θ[2]^2 / Ry) / 2]

"""
    paraboloide_recto(c)

Superficie `r(θ¹,θ²) = (θ¹, θ², c θ¹θ²)`: las curvas coordenadas son rectas (reglada).
Equivale al paraboloide curvo con `Rx = −Ry = R`, `c = −1/R`, tras un giro de 45° en planta.
"""
paraboloide_recto(c) = θ -> [θ[1], θ[2], c * θ[1] * θ[2]]

"""
    base_superficie(r, θ; h = 1e-6)

Matriz 3×2 de columnas `aα = ∂r/∂θᵅ` por diferencias centradas.
"""
base_superficie(r, θ::AbstractVector; h = 1e-6) = jacobiana_numerica(r, θ; h)

"""
    normal_unitaria(A)

Normal unitaria `n̂ = a₁×a₂ / |a₁×a₂|` de la base tangente `A` (3×2).
"""
function normal_unitaria(A::AbstractMatrix)
    n = cross(A[:, 1], A[:, 2])
    n / norm(n)
end

"""
    derivadas_segundas(r, θ; h = 1e-4)

Array 3×2×2 con `D[:,α,β] = ∂²r/∂θᵅ∂θᵝ` por diferencias centradas de segundo orden.
"""
function derivadas_segundas(r, θ::AbstractVector; h = 1e-4)
    D = zeros(3, 2, 2)
    e = [[h, 0.0], [0.0, h]]
    r0 = r(θ)
    for α in 1:2
        D[:, α, α] = (r(θ .+ e[α]) .- 2 .* r0 .+ r(θ .- e[α])) ./ h^2
    end
    D12 = (r(θ .+ e[1] .+ e[2]) .- r(θ .+ e[1] .- e[2]) .- r(θ .- e[1] .+ e[2]) .+ r(θ .- e[1] .- e[2])) ./ (4h^2)
    D[:, 1, 2] = D12
    D[:, 2, 1] = D12
    D
end

"""
    segunda_forma(r, θ)

Componentes `bαβ = n̂·∂²r/∂θᵅ∂θᵝ` (matriz 2×2).
"""
function segunda_forma(r, θ::AbstractVector)
    n = normal_unitaria(base_superficie(r, θ))
    D = derivadas_segundas(r, θ)
    [dot(n, D[:, α, β]) for α in 1:2, β in 1:2]
end

"""
    tensor_curvatura_mixto(a, b)

Componentes mixtas `bᵅᵦ = aᵅᵞ bᵞᵦ` (matriz `[α,β]`).
"""
tensor_curvatura_mixto(a::AbstractMatrix, b::AbstractMatrix) = inv(a) * b

"""
    curvaturas_principales(a, b)

Raíces de `|bαβ − κ aαβ| = 0`. Devuelve `(κ, λ, K, H)`: curvaturas principales
(orden creciente), direcciones principales `λ` (columnas, componentes
contravariantes normalizadas con `aαβ λᵅ λᵝ = 1`), curvatura de Gauss
`K = det(bᵅᵦ)` y curvatura media `H = ½ bᵅₐ`.
"""
function curvaturas_principales(a::AbstractMatrix, b::AbstractMatrix)
    bm = tensor_curvatura_mixto(a, b)
    F = eigen(bm)
    κ = real.(F.values)
    ord = sortperm(κ)
    λ = real.(F.vectors[:, ord])
    for j in 1:2
        λ[:, j] ./= sqrt(λ[:, j]' * a * λ[:, j])
    end
    (κ = κ[ord], λ = λ, K = det(bm), H = tr(bm) / 2)
end

"""
    curvatura_normal(a, b, λ)

Curvatura normal en la dirección `λ`: `κ = bαβ λᵅ λᵝ / (aαβ λᵅ λᵝ)`.
"""
curvatura_normal(a::AbstractMatrix, b::AbstractMatrix, λ::AbstractVector) =
    (λ' * b * λ) / (λ' * a * λ)

"""
    base_lamina(A, bm, θ3)

Base covariante de la lámina a distancia `θ³` de la superficie media:
`gα = aα − θ³ bᵝα aᵦ`, columnas de una matriz 3×2 (`bm` = `bᵅᵦ` mixto).
"""
base_lamina(A::AbstractMatrix, bm::AbstractMatrix, θ3) = A * (I - θ3 * bm)

"""
    cristoffel_superficie(r, θ)

Símbolos `Γᵞαβ = aᵞ·aα,β` de la superficie (array `[γ,α,β]`), con `aᵞ` la base
recíproca tangente.
"""
function cristoffel_superficie(r, θ::AbstractVector)
    A = base_superficie(r, θ)
    Ar = A * inv(metrica(A))
    D = derivadas_segundas(r, θ)
    [dot(Ar[:, γ], D[:, α, β]) for γ in 1:2, α in 1:2, β in 1:2]
end

"""
    area_relativa(h, k, θ3)

Cociente `√g/√a = 1 − 2H θ³ + K (θ³)²` entre el elemento de área a distancia
`θ³` de la superficie media y el de la propia superficie.
"""
area_relativa(H, K, θ3) = 1 - 2H * θ3 + K * θ3^2

end # module
