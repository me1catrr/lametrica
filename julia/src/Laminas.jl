# Elasticidad y teoría de láminas (Bloque D). Se incluye desde Geometria.jl.
#
# Convenio: `base(θ)` devuelve la matriz de columnas gᵢ = ∂r/∂θⁱ (como en Geometria.jl); los
# campos de desplazamiento se dan por sus componentes covariantes uᵢ(θ) = u·gᵢ.

"Constantes de Lamé `(λ, μ)` a partir de `E` y `ν`."
lame(E, ν) = (E * ν / ((1 + ν) * (1 - 2ν)), E / (2 * (1 + ν)))

"""
    hooke_contravariante(ginv, E, ν)

Tensor de elasticidad isótropo `Cⁱʲᵏˡ = λ gⁱʲ gᵏˡ + μ (gⁱᵏ gʲˡ + gⁱˡ gʲᵏ)` (array `3×3×3×3`)
a partir de la métrica contravariante `gⁱʲ` (matriz 3×3). Es un tensor: vale en cualquier base.
"""
function hooke_contravariante(ginv::AbstractMatrix, E, ν)
    λ, μ = lame(E, ν)
    n = size(ginv, 1)
    [λ * ginv[i, j] * ginv[k, l] + μ * (ginv[i, k] * ginv[j, l] + ginv[i, l] * ginv[j, k])
     for i in 1:n, j in 1:n, k in 1:n, l in 1:n]
end

"Tensión `σⁱʲ = Cⁱʲᵏˡ εₖₗ` (matriz) para la deformación covariante `ε` (matriz)."
tension_hooke(C, ε::AbstractMatrix) =
    [sum(C[i, j, k, l] * ε[k, l] for k in axes(ε, 1), l in axes(ε, 2)) for i in axes(ε, 1), j in axes(ε, 2)]

"Densidad de energía de deformación `W = ½ Cⁱʲᵏˡ εᵢⱼ εₖₗ = ½ σⁱʲ εᵢⱼ`."
energia_deformacion(C, ε::AbstractMatrix) = sum(tension_hooke(C, ε) .* ε) / 2

"""
    matriz_tension_plana(E, ν)

Matriz `3×3` (notación de Voigt `(ε₁₁, ε₂₂, 2ε₁₂)`) de la ley de Hooke en **tensión plana**
en una base ortonormal: `E/(1−ν²) [1 ν 0; ν 1 0; 0 0 (1−ν)/2]`.
"""
matriz_tension_plana(E, ν) = E / (1 - ν^2) * [1 ν 0; ν 1 0; 0 0 (1 - ν) / 2]

"""
    gradiente_desplazamiento(base, udn, θ; h = 1e-5)

Derivada covariante del desplazamiento `uᵢ‖ⱼ = ∂ⱼuᵢ − Γᵏᵢⱼ uₖ` (matriz `[i,j]`) para un campo con
componentes covariantes `udn(θ)`.
"""
function gradiente_desplazamiento(base, udn, θ::AbstractVector; h = 1e-5)
    n = length(θ)
    Γ = cristoffel(base, θ)
    u0 = udn(θ)
    du = [(udn(θ .+ h .* (1:n .== j)) - udn(θ .- h .* (1:n .== j))) / 2h for j in 1:n]   # du[j][i] = ∂ⱼuᵢ
    [du[j][i] - sum(Γ[k, i, j] * u0[k] for k in 1:n) for i in 1:n, j in 1:n]
end

"""
    deformacion_pequena(base, udn, θ; h = 1e-5)

Deformación lineal `εᵢⱼ = ½(uᵢ‖ⱼ + uⱼ‖ᵢ)` para un desplazamiento con componentes covariantes `udn(θ)`.
"""
function deformacion_pequena(base, udn, θ::AbstractVector; h = 1e-5)
    D = gradiente_desplazamiento(base, udn, θ; h)
    (D + transpose(D)) / 2
end

"""
    green_lagrange_desde_u(base, udn, θ; h = 1e-5)

Green–Lagrange `Eᵢⱼ = ½(uᵢ‖ⱼ + uⱼ‖ᵢ + uᵏ‖ᵢ uₖ‖ⱼ)` (con `uᵏ‖ᵢ = gᵏˡ uₗ‖ᵢ`) en componentes covariantes.
"""
function green_lagrange_desde_u(base, udn, θ::AbstractVector; h = 1e-5)
    D = gradiente_desplazamiento(base, udn, θ; h)
    ginv = inv(metrica(base(θ)))
    (D + transpose(D) + transpose(D) * ginv * D) / 2
end

"""
    green_lagrange(g0, g)

Deformación de Green–Lagrange covariante `Eᵢⱼ = ½(Gᵢⱼ − gᵢⱼ)` a partir de las métricas de la
configuración deformada `G` (argumento `g`) y de referencia (`g0`), ambas en las mismas
coordenadas materiales. Para `F` cartesiana es `½(FᵀF − I)`.
"""
green_lagrange(g0::AbstractMatrix, g::AbstractMatrix) = (g - g0) / 2

"Tensor de Cauchy–Green derecho `C = FᵀF` del gradiente de deformación `F`."
cauchy_green(F::AbstractMatrix) = transpose(F) * F

"""
    divergencia_tensor(base, σup, θ; h = 1e-5)

Divergencia de un tensor simétrico con componentes contravariantes `σup(θ)` (matriz):
`σⁱʲ‖ⱼ = (1/√g) ∂ⱼ(√g σⁱʲ) + Γⁱⱼₖ σʲᵏ` (vector contravariante). Es el operador de la ecuación
de equilibrio `σⁱʲ‖ⱼ + bⁱ = 0`.
"""
function divergencia_tensor(base, σup, θ::AbstractVector; h = 1e-5)
    n = length(θ)
    F(t) = raiz_g(base, t) .* σup(t)
    dF = [(F(θ .+ h .* (1:n .== j)) - F(θ .- h .* (1:n .== j))) / 2h for j in 1:n]       # ∂ⱼ(√g σⁱᵏ)
    Γ = cristoffel(base, θ)
    σ0 = σup(θ)
    [sum(dF[j][i, j] for j in 1:n) / raiz_g(base, θ) + sum(Γ[i, j, k] * σ0[j, k] for j in 1:n, k in 1:n) for i in 1:n]
end
