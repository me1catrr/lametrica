# Elemento finito de lámina de 4 nodos (Bloque E). Se incluye desde Geometria.jl.
#
# Superficie media `r(θ¹,θ²)`; malla rectangular en el plano paramétrico. Cinco g.d.l. por nodo,
# en este orden: `u₁, u₂` (componentes covariantes del desplazamiento tangente), `u₃` (normal) y
# `φ₁, φ₂` (componentes covariantes del giro del director), como en los temas D5–D6. Los 20 g.d.l.
# del elemento van nodo a nodo: `[u₁ u₂ u₃ φ₁ φ₂]` del nodo 1, luego del 2, etc. Nodos en sentido
# antihorario: 1=(−1,−1), 2=(1,−1), 3=(1,1), 4=(−1,1) en coordenadas naturales (ξ,η).
#
# Tres variantes de rigidez (`modo`), pensadas para compararlas en el tema E5:
#   :desplazamientos     formulación de desplazamientos con integración completa 2×2,
#   :reducida_selectiva  membrana y flexión 2×2, cortante en un punto,
#   :subdominios         deformaciones constantes a trozos en los cuatro subdominios (tema E6–E7).

using SparseArrays

"Funciones de forma bilineales `Nₖ = ¼(1+ξₖξ)(1+ηₖη)` y sus derivadas `(N, ∂N/∂ξ, ∂N/∂η)`."
function formas_bilineales(ξ, η)
    sξ = (-1, 1, 1, -1); sη = (-1, -1, 1, 1)
    N = [(1 + sξ[k] * ξ) * (1 + sη[k] * η) / 4 for k in 1:4]
    dξ = [sξ[k] * (1 + sη[k] * η) / 4 for k in 1:4]
    dη = [sη[k] * (1 + sξ[k] * ξ) / 4 for k in 1:4]
    (N, dξ, dη)
end

"Geometría de la superficie en un punto: `a`, `a⁻¹`, `√a`, `b`, `bᵅᵦ` mixto, Christoffel y normal."
function geometria_punto(r, θ::AbstractVector)
    A = base_superficie(r, θ); a = metrica(A); b = segunda_forma(r, θ)
    (a = a, ai = inv(a), sa = sqrt(det(a)), b = b, bm = tensor_curvatura_mixto(a, b),
     Γ = cristoffel_superficie(r, θ), A = A, n = normal_unitaria(A))
end

"""
    matrices_H(g, dN)

Matrices deformación–desplazamiento `(HE, HB, HS)` (`3×20`, `3×20`, `2×20`) en un punto de geometría
`g` (de `geometria_punto`) y derivadas `dN[β,k] = ∂Nₖ/∂θᵝ` (`2×4`). Son las relaciones lineales del
tema D6 con las incógnitas interpoladas: `γ⁰ = HE·δ`, `γ¹ = HB·δ`, `γ_S = HS·δ`, con
`γ⁰ = (γ⁰₁₁, γ⁰₂₂, 2γ⁰₁₂)` (igual `γ¹`) y `γ_S = (γ₁, γ₂)`.
"""
function matrices_H(g, N::AbstractVector, dN::AbstractMatrix)
    HE = zeros(3, 20); HB = zeros(3, 20); HS = zeros(2, 20)
    Γ, b, bm = g.Γ, g.b, g.bm
    for k in 1:4, c in 1:5
        u = zeros(2); u3 = 0.0; φ = zeros(2)
        du = zeros(2, 2); dφ = zeros(2, 2); du3 = zeros(2)        # du[α,β] = ∂β uα
        if c <= 2
            u[c] = N[k]; du[c, :] = dN[:, k]
        elseif c == 3
            u3 = N[k]; du3 = dN[:, k]
        else
            φ[c-3] = N[k]; dφ[c-3, :] = dN[:, k]
        end
        Du = [du[α, β] - sum(Γ[γ, α, β] * u[γ] for γ in 1:2) for α in 1:2, β in 1:2]
        Dφ = [dφ[α, β] - sum(Γ[γ, α, β] * φ[γ] for γ in 1:2) for α in 1:2, β in 1:2]
        bu(α, β) = sum(bm[μ, α] * Du[μ, β] for μ in 1:2)
        bb(α, β) = sum(bm[μ, α] * b[μ, β] for μ in 1:2)
        γ0 = [(Du[α, β] + Du[β, α]) / 2 - b[α, β] * u3 for α in 1:2, β in 1:2]
        γ1 = [(Dφ[α, β] + Dφ[β, α] - bu(α, β) - bu(β, α) + 2 * bb(α, β) * u3) / 2 for α in 1:2, β in 1:2]
        γS = [φ[α] + du3[α] + sum(bm[ρ, α] * u[ρ] for ρ in 1:2) for α in 1:2]
        col = 5 * (k - 1) + c
        HE[:, col] = [γ0[1, 1], γ0[2, 2], 2γ0[1, 2]]
        HB[:, col] = [γ1[1, 1], γ1[2, 2], 2γ1[1, 2]]
        HS[:, col] = γS
    end
    (HE, HB, HS)
end

const GAUSS2 = (-1 / sqrt(3), 1 / sqrt(3))

"Cuadrantes (subdominios) `AI…AIV` como rangos en `(ξ,η)`: I=(−,−), II=(+,−), III=(+,+), IV=(−,+)."
const CUADRANTES = (((-1.0, 0.0), (-1.0, 0.0)), ((0.0, 1.0), (-1.0, 0.0)),
                    ((0.0, 1.0), (0.0, 1.0)), ((-1.0, 0.0), (0.0, 1.0)))

"""
    puntos_gauss(rangoξ, rangoη, n)

Puntos y pesos de Gauss `n×n` (n = 1 o 2) sobre el rectángulo `rangoξ × rangoη` de las coordenadas naturales.
"""
function puntos_gauss(rξ, rη, n)
    pts = n == 1 ? ((0.0,), (2.0,)) : (GAUSS2, (1.0, 1.0))
    mξ, hξ = (rξ[1] + rξ[2]) / 2, (rξ[2] - rξ[1]) / 2
    mη, hη = (rη[1] + rη[2]) / 2, (rη[2] - rη[1]) / 2
    [(mξ + hξ * xi, mη + hη * xj, wi * wj * hξ * hη) for (xi, wi) in zip(pts[1], pts[2]) for (xj, wj) in zip(pts[1], pts[2])]
end

"""
    punto_elemento(r, X, ξ, η, E, ν, t)

Todo lo que hace falta en un punto natural `(ξ,η)` de un elemento de esquinas `X` (`2×4`, coordenadas
paramétricas de los nodos): `(g, N, dN, dA, CE, CB, CS)`, con `dA` el área por unidad de peso en `(ξ,η)`.
"""
function punto_elemento(r, X::AbstractMatrix, ξ, η, E, ν, t)
    N, dξ, dη = formas_bilineales(ξ, η)
    h1 = (X[1, 2] - X[1, 1]) / 2; h2 = (X[2, 4] - X[2, 1]) / 2          # θ¹₀, θ²₀
    θ = [sum(N[k] * X[1, k] for k in 1:4), sum(N[k] * X[2, k] for k in 1:4)]
    dN = vcat((dξ ./ h1)', (dη ./ h2)')
    g = geometria_punto(r, θ)
    CE, CB, CS = rigidez_lamina(g.a, E, ν, t)
    (g, N, dN, g.sa * h1 * h2, CE, CB, CS)
end

"""
    rigidez_elemento(r, X, E, ν, t; modo = :subdominios)

Matriz de rigidez `20×20` del elemento de lámina de esquinas `X` (`2×4`, parámetros `θ¹,θ²` de los
nodos; el elemento es un rectángulo del plano paramétrico). Con `modo = :subdominios` es la
formulación de Hu–Washizu con deformaciones constantes a trozos en cuatro subdominios (`ε₁₁`, `κ₁₁`, `γ₁`
una por mitad en `η`; `ε₂₂`, `κ₂₂`, `γ₂` una por mitad en `ξ`; `ε₁₂`, `κ₁₂` constantes), cuya
condensación estática da `K = Eᵀ A⁻¹ D̄ A⁻¹ E` en cada familia de deformaciones.
"""
function rigidez_elemento(r, X::AbstractMatrix, E, ν, t; modo::Symbol = :subdominios)
    K = zeros(20, 20)
    if modo == :desplazamientos || modo == :reducida_selectiva
        for (ξ, η, w) in puntos_gauss((-1.0, 1.0), (-1.0, 1.0), 2)
            g, N, dN, dA, CE, CB, CS = punto_elemento(r, X, ξ, η, E, ν, t)
            HE, HB, HS = matrices_H(g, N, dN)
            K .+= (HE' * CE * HE + HB' * CB * HB) .* (w * dA)
            modo == :desplazamientos && (K .+= HS' * CS * HS .* (w * dA))
        end
        if modo == :reducida_selectiva
            for (ξ, η, w) in puntos_gauss((-1.0, 1.0), (-1.0, 1.0), 1)
                g, N, dN, dA, CE, CB, CS = punto_elemento(r, X, ξ, η, E, ν, t)
                _, _, HS = matrices_H(g, N, dN)
                K .+= HS' * CS * HS .* (w * dA)
            end
        end
        return K
    elseif modo == :subdominios
        # Selección: fila j de ε̄ ↔ componente local. 5 parámetros (extensión y flexión), 4 (cortante).
        # ε₁₁: mitad η<0 (cuadrantes I,II) y η>0 (III,IV); ε₂₂: ξ<0 (I,IV) y ξ>0 (II,III); ε₁₂: todo.
        fila11 = (1, 1, 2, 2); fila22 = (3, 4, 4, 3)
        DE = zeros(5, 5); DB = zeros(5, 5); DS = zeros(4, 4)
        EE = zeros(5, 20); EB = zeros(5, 20); ES = zeros(4, 20)
        AN = zeros(5); AS = zeros(4)
        for q in 1:4
            for (ξ, η, w) in puntos_gauss(CUADRANTES[q][1], CUADRANTES[q][2], 2)
                g, N, dN, dA, CE, CB, CS = punto_elemento(r, X, ξ, η, E, ν, t)
                HE, HB, HS = matrices_H(g, N, dN)
                P = zeros(5, 3); P[fila11[q], 1] = 1; P[fila22[q], 2] = 1; P[5, 3] = 1
                PS = zeros(4, 2); PS[fila11[q], 1] = 1; PS[fila22[q], 2] = 1
                s = w * dA
                DE .+= P * CE * P' .* s; DB .+= P * CB * P' .* s; DS .+= PS * CS * PS' .* s
                EE .+= P * HE .* s; EB .+= P * HB .* s; ES .+= PS * HS .* s
                for j in (fila11[q], fila22[q], 5); AN[j] += s; end
                for j in (fila11[q], fila22[q]); AS[j] += s; end
            end
        end
        AN = Diagonal(AN); AS = Diagonal(AS[1:4])
        return EE' * (AN \ DE / AN) * EE + EB' * (AN \ DB / AN) * EB + ES' * (AS \ DS / AS) * ES
    else
        error("modo desconocido: $modo (usa :desplazamientos, :reducida_selectiva o :subdominios)")
    end
end

"""
    masa_elemento(r, X, ρ, t)

Matriz de masa consistente `20×20`. Energía cinética por unidad de superficie con el desarrollo exacto
del jacobiano en el espesor `μ = 1 − 2Hθ³ + Kθ³²`:
`T = ½ρ[(t + K t³/12)|u̇|² − (4H t³/12) u̇·ϑ̇ + (t³/12)|ϑ̇|²]`, con `u̇ = u̇_α aᵅ + u̇₃ n̂`, `ϑ̇ = φ̇_α aᵅ`.
"""
function masa_elemento(r, X::AbstractMatrix, ρ, t)
    M = zeros(20, 20)
    for (ξ, η, w) in puntos_gauss((-1.0, 1.0), (-1.0, 1.0), 2)
        N, _, _ = formas_bilineales(ξ, η)
        h1 = (X[1, 2] - X[1, 1]) / 2; h2 = (X[2, 4] - X[2, 1]) / 2
        θ = [sum(N[k] * X[1, k] for k in 1:4), sum(N[k] * X[2, k] for k in 1:4)]
        g = geometria_punto(r, θ)
        K = det(g.bm); H = tr(g.bm) / 2
        Tu = zeros(2, 20); T3 = zeros(1, 20); Tφ = zeros(2, 20)
        for k in 1:4
            for α in 1:2
                Tu[α, 5(k-1)+α] = N[k]; Tφ[α, 5(k-1)+3+α] = N[k]
            end
            T3[1, 5(k-1)+3] = N[k]
        end
        cuu = Tu' * g.ai * Tu + T3' * T3
        cuφ = Tu' * g.ai * Tφ
        cφφ = Tφ' * g.ai * Tφ
        M .+= ρ .* ((t + K * t^3 / 12) .* cuu .- (2H * t^3 / 12) .* (cuφ .+ cuφ') .+ (t^3 / 12) .* cφφ) .* (w * g.sa * h1 * h2)
    end
    M
end

"""
    cargas_elemento(r, X, f)

Vector de cargas nodales consistentes `20×1` de una carga superficial `f(θ)` (vector cartesiano por
unidad de superficie de la superficie media): `δW = ∫ (δu_α aᵅ·f + δu₃ n̂·f) dA`.
"""
function cargas_elemento(r, X::AbstractMatrix, f)
    F = zeros(20)
    for (ξ, η, w) in puntos_gauss((-1.0, 1.0), (-1.0, 1.0), 2)
        N, _, _ = formas_bilineales(ξ, η)
        h1 = (X[1, 2] - X[1, 1]) / 2; h2 = (X[2, 4] - X[2, 1]) / 2
        θ = [sum(N[k] * X[1, k] for k in 1:4), sum(N[k] * X[2, k] for k in 1:4)]
        g = geometria_punto(r, θ)
        fv = f(θ); Ar = g.A * g.ai
        for k in 1:4
            for α in 1:2
                F[5(k-1)+α] += N[k] * dot(Ar[:, α], fv) * w * g.sa * h1 * h2
            end
            F[5(k-1)+3] += N[k] * dot(g.n, fv) * w * g.sa * h1 * h2
        end
    end
    F
end

"""
    malla_rectangular(rangoθ1, rangoθ2, n1, n2)

Malla estructurada de `n1×n2` elementos en el rectángulo paramétrico. Devuelve `(nodos, conn)`:
`nodos` es `2×Nn` (coordenadas `θ¹,θ²`) y `conn` es `4×Ne` (conectividad antihoraria).
"""
function malla_rectangular(r1, r2, n1::Integer, n2::Integer)
    xs = range(r1[1], r1[2]; length = n1 + 1); ys = range(r2[1], r2[2]; length = n2 + 1)
    id(i, j) = (j - 1) * (n1 + 1) + i
    nodos = hcat([[xs[i], ys[j]] for j in 1:n2+1 for i in 1:n1+1]...)
    conn = hcat([[id(i, j), id(i + 1, j), id(i + 1, j + 1), id(i, j + 1)] for j in 1:n2 for i in 1:n1]...)
    (nodos, conn)
end

"Posiciones de los g.d.l. globales del elemento `e` (`20`), nodo a nodo."
gdl_elemento(conn, e) = vcat([collect(5(n-1)+1:5n) for n in conn[:, e]]...)

"""
    ensamblar(r, nodos, conn, E, ν, t; modo, ρ = nothing, f = nothing)

Ensambla la rigidez global `K` (dispersa) y, si se dan, la masa `M` (`ρ`) y el vector de cargas `F`
(`f(θ)`, carga superficial cartesiana). Devuelve `(K, M, F)` con `nothing` en lo no pedido.
"""
function ensamblar(r, nodos, conn, E, ν, t; modo::Symbol = :subdominios, ρ = nothing, f = nothing)
    nd = 5 * size(nodos, 2); ne = size(conn, 2)
    IK = Int[]; JK = Int[]; VK = Float64[]; VM = Float64[]
    F = f === nothing ? nothing : zeros(nd)
    for e in 1:ne
        X = nodos[:, conn[:, e]]; dofs = gdl_elemento(conn, e)
        Ke = rigidez_elemento(r, X, E, ν, t; modo)
        Me = ρ === nothing ? nothing : masa_elemento(r, X, ρ, t)
        for j in 1:20, i in 1:20
            push!(IK, dofs[i]); push!(JK, dofs[j]); push!(VK, Ke[i, j])
            Me === nothing || push!(VM, Me[i, j])
        end
        f === nothing || (F[dofs] .+= cargas_elemento(r, X, f))
    end
    K = sparse(IK, JK, VK, nd, nd)
    M = ρ === nothing ? nothing : sparse(IK, JK, VM, nd, nd)
    (K, M, F)
end

"Índice global del g.d.l. `c` (1…5) del nodo `n`."
gdl(n::Integer, c::Integer) = 5 * (n - 1) + c

"""
    resolver_estatica(K, F, fijos)

Resuelve `K u = F` con los g.d.l. de `fijos` a cero. Devuelve el vector completo `u`.
"""
function resolver_estatica(K, F, fijos)
    libres = setdiff(1:length(F), fijos)
    u = zeros(length(F))
    u[libres] = Matrix(K[libres, libres]) \ F[libres]
    u
end

"""
    frecuencias(K, M, fijos; n = 6)

Primeras `n` frecuencias angulares `ω` (rad/s) y modos del problema `(K − ω²M)u = 0` con los g.d.l. de
`fijos` eliminados. Devuelve `(ω, modos)` con los modos en el espacio completo (ceros en `fijos`).
"""
function frecuencias(K, M, fijos; n::Integer = 6)
    libres = setdiff(1:size(K, 1), fijos)
    F = eigen(Symmetric(Matrix(K[libres, libres])), Symmetric(Matrix(M[libres, libres])))
    ω = sqrt.(max.(F.values[1:n], 0.0))
    V = zeros(size(K, 1), n); V[libres, :] = F.vectors[:, 1:n]
    (ω, V)
end

"Desplazamiento cartesiano `u_α aᵅ + u₃ n̂` del nodo `n` (vector de 3 componentes) para el vector global `u`."
function desplazamiento_cartesiano(r, nodos, u, n::Integer)
    g = geometria_punto(r, nodos[:, n]); Ar = g.A * g.ai
    Ar * u[gdl(n, 1):gdl(n, 2)] .+ u[gdl(n, 3)] .* g.n
end

"""
    deformaciones_medias(r, nodos, conn, e, u, E, ν, t)

Deformaciones medias del elemento `e` (`γ⁰`, `γ¹`, `γ_S`) y sus resultantes `(N, M, Q)`: `H·δ` promediado
sobre el área y multiplicado por `(CE, CB, CS)` en el centro del elemento.
"""
function deformaciones_medias(r, nodos, conn, e, u, E, ν, t)
    X = nodos[:, conn[:, e]]; δ = u[gdl_elemento(conn, e)]
    A = 0.0; SE = zeros(3); SB = zeros(3); SS = zeros(2)
    for (ξ, η, w) in puntos_gauss((-1.0, 1.0), (-1.0, 1.0), 2)
        g, N, dN, dA, _, _, _ = punto_elemento(r, X, ξ, η, E, ν, t)
        HE, HB, HS = matrices_H(g, N, dN)
        A += w * dA; SE .+= HE * δ .* (w * dA); SB .+= HB * δ .* (w * dA); SS .+= HS * δ .* (w * dA)
    end
    γ0, γ1, γS = SE ./ A, SB ./ A, SS ./ A
    g, _, _, _, CE, CB, CS = punto_elemento(r, X, 0.0, 0.0, E, ν, t)
    (γ0 = γ0, γ1 = γ1, γS = γS, N = CE * γ0, M = CB * γ1, Q = CS * γS)
end
