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

# ---------------------------------------------------------------------------
# Cinemática de láminas (temas D3–D7)
#
# Superficie media de referencia `r(θ¹,θ²)`; punto de la lámina `r + θ³ n̂`. Configuración deformada:
# `R = R₀(θ) + θ³ A₃(θ)` (hipótesis lineal en el espesor). Convenios del libro: `bαβ = n̂·aα,β`,
# `‖` derivada covariante de la superficie, `φα` = componentes covariantes del incremento del director.

"""
    deformacion_lamina_exacta(r, R0, A3, θ, θ3; h = 1e-5)

Deformación de Green–Lagrange **exacta** `γᵢⱼ = ½(Gᵢⱼ − gᵢⱼ)` (matriz 3×3) en el punto `(θ, θ³)`, con
`gᵢ = ∂(r + θ³ n̂)/∂θⁱ` y `Gᵢ = ∂(R₀ + θ³ A₃)/∂θⁱ`. `R0(θ)` y `A3(θ)` devuelven vectores de ℝ³.
"""
function deformacion_lamina_exacta(r, R0, A3, θ::AbstractVector, θ3; h = 1e-5)
    nref(t) = normal_unitaria(base_superficie(r, t))
    X(q) = r(q[1:2]) .+ q[3] .* nref(q[1:2])
    Y(q) = R0(q[1:2]) .+ q[3] .* A3(q[1:2])
    q0 = vcat(θ, θ3)
    JX = jacobiana_numerica(X, q0; h); JY = jacobiana_numerica(Y, q0; h)
    (metrica(JY) - metrica(JX)) / 2
end

"""
    deformacion_lamina_lineal(r, udn, u3, φdn, θ; h = 1e-5)

Deformaciones **lineales** de la lámina para el desplazamiento `u = uβ aᵝ + u₃ n̂` de la superficie
media y el giro del director `ϑ = φβ aᵝ` (funciones de `θ`: `udn(θ)`, `φdn(θ)` vectores de 2
componentes covariantes y `u3(θ)` escalar). Devuelve `(γ0, γ1, γS)`:

- extensión `γ⁰αβ = ½(uα‖β + uβ‖α) − bαβ u₃`,
- flexión `γ¹αβ = ½(φα‖β + φβ‖α − bᵅμ uμ‖β − bᵝμ uμ‖α + 2 bᵅμ bμβ u₃)`,
- cortante `γα = φα + u₃,α + bᵅρ uρ` (= `2γα3`).
"""
function deformacion_lamina_lineal(r, udn, u3, φdn, θ::AbstractVector; h = 1e-5)
    A = base_superficie(r, θ); a = metrica(A); b = segunda_forma(r, θ)
    bm = tensor_curvatura_mixto(a, b)                       # bᵅᵦ [α,β]
    Γ = cristoffel_superficie(r, θ)
    e = [[h, 0.0], [0.0, h]]
    dcov(f) = begin                                          # fα‖β = ∂βfα − Γᵞαβ fγ
        f0 = f(θ)
        [(f(θ .+ e[β])[α] - f(θ .- e[β])[α]) / 2h - sum(Γ[γ, α, β] * f0[γ] for γ in 1:2) for α in 1:2, β in 1:2]
    end
    Du = dcov(udn); Dφ = dcov(φdn)
    u0 = udn(θ); u30 = u3(θ)
    # bᵅμ = bm[μ, α] (simétrico en la forma mixta con un índice subido): bᵅμ uμ‖β = Σμ bm[μ,α] Du[μ,β]
    bu(α, β) = sum(bm[μ, α] * Du[μ, β] for μ in 1:2)
    bb(α, β) = sum(bm[μ, α] * b[μ, β] for μ in 1:2)
    γ0 = [0.5 * (Du[α, β] + Du[β, α]) - b[α, β] * u30 for α in 1:2, β in 1:2]
    γ1 = [0.5 * (Dφ[α, β] + Dφ[β, α] - bu(α, β) - bu(β, α) + 2 * bb(α, β) * u30) for α in 1:2, β in 1:2]
    du3 = [(u3(θ .+ e[α]) - u3(θ .- e[α])) / 2h for α in 1:2]
    γS = [φdn(θ)[α] + du3[α] + sum(bm[ρ, α] * u0[ρ] for ρ in 1:2) for α in 1:2]
    (γ0, γ1, γS)
end

"""
    campos_lamina(r, udn, u3, φdn, s)

Superficie media deformada `R₀(θ) = r + s(uβ aᵝ + u₃ n̂)` y director `A₃(θ) = n̂ + s φβ aᵝ`
(funciones de `θ`), para comparar con `deformacion_lamina_exacta`.
"""
function campos_lamina(r, udn, u3, φdn, s)
    function geom(t)
        A = base_superficie(r, t); n = normal_unitaria(A); Ar = A * inv(metrica(A))
        (Ar, n)
    end
    R0(t) = (g = geom(t); r(t) .+ s .* (g[1] * udn(t) .+ u3(t) .* g[2]))
    A3(t) = (g = geom(t); g[2] .+ s .* (g[1] * φdn(t)))
    (R0, A3)
end

"""
    rigidez_lamina(a, E, ν, t)

Matrices de rigidez de la lámina (tensión plana en el espesor, base cualquiera con métrica `aαβ`)
en notación de Voigt: devuelve `(CE, CB, CS)` con `U = ½[γ⁰ᵀ CE γ⁰ + γ¹ᵀ CB γ¹ + γSᵀ CS γS]`,
`γ⁰ = (γ⁰₁₁, γ⁰₂₂, 2γ⁰₁₂)`, `γ¹` análogo y `γS = (γ₁, γ₂)` (cortante de ingeniería).
`CE = t·Cᵃᵇᶜᵈ`, `CB = t³/12·Cᵃᵇᶜᵈ` y `CS = t·μ·aᵅᵝ` (sin factor de corrección de cortante), con
`Cᵃᵇᶜᵈ = λ* aᵅᵝ aᵞᵟ + μ(aᵅᵞ aᵝᵟ + aᵅᵟ aᵝᵞ)`, `λ* = Eν/(1−ν²)`, `μ = E/(2(1+ν))`.
"""
function rigidez_lamina(a::AbstractMatrix, E, ν, t)
    ai = inv(a); μ = E / (2 * (1 + ν)); λs = E * ν / (1 - ν^2)
    C(α, β, γ, δ) = λs * ai[α, β] * ai[γ, δ] + μ * (ai[α, γ] * ai[β, δ] + ai[α, δ] * ai[β, γ])
    # Voigt: v = (γ₁₁, γ₂₂, 2γ₁₂). La componente 3 agrupa los pares (1,2) y (2,1), cada uno con γ = v₃/2.
    pares = (((1, 1),), ((2, 2),), ((1, 2), (2, 1)))
    CV = [sum(C(p[1], p[2], q[1], q[2]) for p in pares[i], q in pares[j]) / ((i == 3 ? 2 : 1) * (j == 3 ? 2 : 1))
          for i in 1:3, j in 1:3]
    (t .* CV, t^3 / 12 .* CV, t * μ * ai)
end
