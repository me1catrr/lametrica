using Test
using LinearAlgebra
using Geometria

@testset "Bases covariantes y contravariantes" begin
    @testset "Aritmética exacta (racionales)" begin
        B = [2//1 1//1; 0//1 3//1]   # g₁ = (2,0), g₂ = (1,3): oblicua
        V = [5//1, 4//1]
        @test metrica(B) == [4//1 2//1; 2//1 10//1]
        @test reciprocidad(B) == Matrix{Rational{Int}}(I, 2, 2)
        Vup = comps_contravariantes(B, V)
        Vdn = comps_covariantes(B, V)
        @test desde_contravariantes(B, Vup) == V             # V = Vⁱ gᵢ
        @test Vdn == metrica(B) * Vup                          # Vᵢ = gᵢⱼ Vʲ
        @test dot(Vup, Vdn) == dot(V, V)                       # |V|² = Vⁱ Vᵢ
    end

    @testset "Coordenadas polares" begin
        for (r, θ) in ((1.0, 0.3), (2.5, 1.9), (0.7, -2.2))
            B = base_polar(r, θ)
            @test metrica(B) ≈ [1.0 0.0; 0.0 r^2] atol = 1e-12
            @test reciprocidad(B) ≈ I(2) atol = 1e-12
            V = [0.4, -1.3]
            @test desde_contravariantes(B, comps_contravariantes(B, V)) ≈ V atol = 1e-12
            # Con base ortogonal: Vⁱ = Vᵢ / gᵢᵢ (sin suma)
            Vup, Vdn = comps_contravariantes(B, V), comps_covariantes(B, V)
            @test Vup ≈ [Vdn[1], Vdn[2] / r^2] atol = 1e-12
        end
    end

    @testset "Invariantes de la base" begin
        B = [1.3 -0.4; 0.2 0.9]
        g = metrica(B)
        @test issymmetric(g)
        @test isposdef(g)
        @test det(g) ≈ det(B)^2
    end
end

@testset "Transformación de coordenadas" begin
    # cartesianas (x,y) → polares (r,θ)
    inv_polar(x) = [hypot(x[1], x[2]), atan(x[2], x[1])]
    r, θ = 2.0, 0.7
    x = [r*cos(θ), r*sin(θ)]
    J = jacobiana_numerica(inv_polar, x)            # ∂(r,θ)/∂(x,y)
    B = base_polar(r, θ)                            # ∂(x,y)/∂(r,θ)
    @test J * B ≈ I(2) atol = 1e-8                  # matrices inversas
    V = [0.4, -1.3]                                  # componentes cartesianas
    Vp = transformar_contra(J, V)
    @test Vp ≈ comps_contravariantes(B, V) atol = 1e-8
    @test transformar_cov(J, V) ≈ comps_covariantes(B, V) atol = 1e-8
    # invariante Vⁱ Wᵢ
    W = [-0.9, 0.5]
    @test dot(Vp, transformar_cov(J, W)) ≈ dot(V, W) atol = 1e-8
    # tensor de orden dos: la métrica cartesiana (δ) se transforma en gⁱʲ / gᵢⱼ
    @test transformar_tensor_cov(J, Matrix(1.0I, 2, 2)) ≈ metrica(B) atol = 1e-8
    @test transformar_tensor_contra(J, Matrix(1.0I, 2, 2)) ≈ inv(metrica(B)) atol = 1e-8
    # det J = 1/r
    @test det(J) ≈ 1 / r atol = 1e-8
end

@testset "Componentes físicas" begin
    r, θ = 1.7, 0.4
    B = base_polar(r, θ)
    Vcart = [0.3, 0.8]
    Vup = comps_contravariantes(B, Vcart)
    Vf = comps_fisicas(B, Vup)
    # componentes físicas = proyecciones sobre los vectores unitarios ĝᵢ
    @test Vf ≈ [dot(Vcart, B[:, 1]), dot(Vcart, B[:, 2]) / r] atol = 1e-12
    @test norm(Vf) ≈ norm(Vcart) atol = 1e-12
    @test_throws AssertionError comps_fisicas([1.0 0.5; 0.0 1.0], [1.0, 1.0])
end

@testset "Símbolos de Christoffel y derivada covariante" begin
    # Polares: Γ¹₂₂ = −r, Γ²₁₂ = Γ²₂₁ = 1/r, el resto nulos
    r, θ = 1.6, 0.9
    Γ = cristoffel(t -> base_polar(t[1], t[2]), [r, θ])
    esperado = zeros(2, 2, 2)
    esperado[1, 2, 2] = -r
    esperado[2, 1, 2] = esperado[2, 2, 1] = 1 / r
    @test Γ ≈ esperado atol = 1e-7
    # Misma cosa solo con la métrica (fórmula de Christoffel)
    gpolar(t) = metrica(base_polar(t[1], t[2]))
    @test cristoffel_desde_metrica(gpolar, [r, θ]) ≈ esperado atol = 1e-7
    # Simetría en los índices inferiores
    @test Γ ≈ permutedims(Γ, (1, 3, 2)) atol = 1e-7

    # Esféricas (r,θ,φ)
    r, θ, φ = 1.3, 0.8, 0.5
    Γe = cristoffel(t -> base_esferica(t...), [r, θ, φ])
    @test Γe[1, 2, 2] ≈ -r atol = 1e-6
    @test Γe[1, 3, 3] ≈ -r * sin(θ)^2 atol = 1e-6
    @test Γe[2, 1, 2] ≈ 1 / r atol = 1e-6
    @test Γe[2, 3, 3] ≈ -sin(θ) * cos(θ) atol = 1e-6
    @test Γe[3, 1, 3] ≈ 1 / r atol = 1e-6
    @test Γe[3, 2, 3] ≈ cos(θ) / sin(θ) atol = 1e-6
    gesf(t) = metrica(base_esferica(t...))
    @test cristoffel_desde_metrica(gesf, [r, θ, φ]) ≈ Γe atol = 1e-6

    # Un campo cartesiano constante es paralelo: su derivada covariante es nula
    constante(t) = [cos(t[2]), -sin(t[2]) / t[1]]    # Vⁱ de V = (1,0) en polares
    t0 = [r, 0.9]
    dV = jacobiana_numerica(constante, t0)
    Γ = cristoffel(t -> base_polar(t[1], t[2]), t0)
    @test derivada_cov_contra(Γ, constante(t0), dV) ≈ zeros(2, 2) atol = 1e-6
    # ... mientras que la derivada parcial NO lo es
    @test norm(dV) > 0.1

    # Compatibilidad con la métrica: gᵢⱼ‖ₖ = ∂ₖgᵢⱼ − Γˡᵢₖ gₗⱼ − Γˡⱼₖ gᵢₗ = 0
    g = gpolar(t0)
    for k in 1:2
        e = zeros(2); e[k] = 1e-5
        dg = (gpolar(t0 .+ e) .- gpolar(t0 .- e)) ./ 2e-5
        for i in 1:2, j in 1:2
            @test dg[i, j] - sum(Γ[l, i, k] * g[l, j] + Γ[l, j, k] * g[i, l] for l in 1:2) ≈ 0 atol = 1e-6
        end
    end

    # Derivada covariante de un campo covariante: Vᵢ = gᵢⱼ Vʲ del mismo campo
    cov(t) = metrica(base_polar(t[1], t[2])) * constante(t)
    @test derivada_cov_cov(Γ, cov(t0), jacobiana_numerica(cov, t0)) ≈ zeros(2, 2) atol = 1e-6
end

@testset "Superficies: paraboloide hiperbólico de bordes curvos" begin
    # Contraste con las expresiones analíticas del paraboloide z = −½(x²/Rx + y²/Ry)
    Rx, Ry = 3.0, -2.0
    θ = [0.7, -0.4]
    r = paraboloide_curvo(Rx, Ry)
    A = base_superficie(r, θ)
    a = metrica(A)
    w2 = 1 + (θ[1] / Rx)^2 + (θ[2] / Ry)^2          # = a (determinante de aαβ)
    D = Rx^2 * Ry^2 * w2                              # = Ry²θ₁² + Rx²(Ry² + θ₂²)
    @test A[:, 1] ≈ [1, 0, -θ[1] / Rx] atol = 1e-8
    @test A[:, 2] ≈ [0, 1, -θ[2] / Ry] atol = 1e-8
    @test a ≈ [1+(θ[1]/Rx)^2  θ[1]*θ[2]/(Rx*Ry); θ[1]*θ[2]/(Rx*Ry)  1+(θ[2]/Ry)^2] atol = 1e-8
    @test det(a) ≈ w2 atol = 1e-8
    n = normal_unitaria(A)
    @test n ≈ [θ[1] / Rx, θ[2] / Ry, 1] / sqrt(w2) atol = 1e-8
    @test norm(n) ≈ 1
    @test abs(dot(n, A[:, 1])) < 1e-8
    @test abs(dot(n, A[:, 2])) < 1e-8
    # Base recíproca tangente y reciprocidad
    Ar = A * inv(a)
    @test transpose(Ar) * A ≈ I(2) atol = 1e-8
    @test abs(dot(Ar[:, 1], n)) < 1e-8
    # Contravariante: a¹¹, a²², a¹²
    ainv = inv(a)
    @test ainv[1, 1] ≈ Rx^2 * (Ry^2 + θ[2]^2) / D atol = 1e-8
    @test ainv[2, 2] ≈ Ry^2 * (Rx^2 + θ[1]^2) / D atol = 1e-8
    @test ainv[1, 2] ≈ -Rx * Ry * θ[1] * θ[2] / D atol = 1e-8
    # Segunda forma (convenio bαβ = n̂·aα,β)
    b = segunda_forma(r, θ)
    w = sqrt(w2)
    @test b ≈ [-1/(Rx*w) 0; 0 -1/(Ry*w)] atol = 1e-6
    bm = tensor_curvatura_mixto(a, b)
    @test bm[1, 1] ≈ -(1 + (θ[2]/Ry)^2) / (Rx * w2^1.5) atol = 1e-6
    @test bm[2, 2] ≈ -(1 + (θ[1]/Rx)^2) / (Ry * w2^1.5) atol = 1e-6
    @test bm[2, 1] ≈ Ry * θ[1] * θ[2] / (w * D) atol = 1e-6
    @test bm[1, 2] ≈ Rx * θ[1] * θ[2] / (w * D) atol = 1e-6
    # Christoffel de la superficie
    Γ = cristoffel_superficie(r, θ)
    @test Γ[1, 1, 1] ≈ Ry^2 * θ[1] / D atol = 1e-6
    @test Γ[1, 2, 2] ≈ Rx * Ry * θ[1] / D atol = 1e-6
    @test Γ[2, 1, 1] ≈ Rx * Ry * θ[2] / D atol = 1e-6
    @test Γ[2, 2, 2] ≈ Rx^2 * θ[2] / D atol = 1e-6        # por simetría (derivado aquí)
    @test Γ[1, 1, 2] ≈ 0 atol = 1e-6
    @test Γ[2, 1, 2] ≈ 0 atol = 1e-6
    # Fórmulas de Gauss: aα,β = Γᵞαβ aγ + bαβ n̂
    Dd = derivadas_segundas(r, θ)
    for α in 1:2, β in 1:2
        @test Dd[:, α, β] ≈ A * Γ[:, α, β] + b[α, β] * n atol = 1e-6
    end
    # Fórmulas de Weingarten: n̂,β = −bᵅᵦ aα
    h = 1e-6
    for β in 1:2
        e = zeros(2); e[β] = h
        dn = (normal_unitaria(base_superficie(r, θ .+ e)) - normal_unitaria(base_superficie(r, θ .- e))) / (2h)
        @test dn ≈ -A * bm[:, β] atol = 1e-5
    end
    # Curvatura de Gauss y media; ecuación κ² − 2Hκ + K = 0
    c = curvaturas_principales(a, b)
    @test c.K ≈ 1 / (Rx * Ry * w2^2) atol = 1e-6
    @test c.K < 0                                    # punto hiperbólico
    @test c.κ[1] * c.κ[2] ≈ c.K atol = 1e-8
    @test c.κ[1] + c.κ[2] ≈ 2c.H atol = 1e-8
    # Direcciones principales ortogonales (respecto a aαβ) y κ = bαβλλ
    @test c.λ[:, 1]' * a * c.λ[:, 2] ≈ 0 atol = 1e-8
    for j in 1:2
        @test curvatura_normal(a, b, c.λ[:, j]) ≈ c.κ[j] atol = 1e-8
    end
    # Fórmula de Euler: κ(φ) = κ₁cos²φ + κ₂sin²φ, con φ medido desde λ₁ (base ortonormal tangente)
    for φ in (0.3, 1.1, 2.4)
        λ = cos(φ) * c.λ[:, 1] + sin(φ) * c.λ[:, 2]
        @test curvatura_normal(a, b, λ) ≈ c.κ[1] * cos(φ)^2 + c.κ[2] * sin(φ)^2 atol = 1e-8
    end
    # Lámina: gαβ = aαβ − 2θ³bαβ + (θ³)² bαγ bᵞβ y √g = √a(1 − 2Hθ³ + Kθ³²)
    for θ3 in (0.0, 0.05, -0.08)
        G = base_lamina(A, bm, θ3)
        g = metrica(G)
        @test g ≈ a - 2θ3 * b + θ3^2 * b * inv(a) * b atol = 1e-6
        @test sqrt(det(g)) / sqrt(det(a)) ≈ area_relativa(c.H, c.K, θ3) atol = 1e-6
        # Volumen: g₃·(g₁×g₂) = √g con g₃ = n̂ (g_{α3} = 0, g_{33} = 1)
        @test dot(n, cross(G[:, 1], G[:, 2])) ≈ sqrt(det(g)) atol = 1e-6
        @test abs(dot(n, G[:, 1])) < 1e-6
    end
end

@testset "Superficies: paraboloide de bordes rectos y esfera" begin
    # z = c·x·y en el origen: κ = ±c, direcciones a 45° de los ejes
    c0 = 0.4
    r = paraboloide_recto(c0)
    θ = [0.0, 0.0]
    A = base_superficie(r, θ); a = metrica(A); b = segunda_forma(r, θ)
    @test a ≈ I(2) atol = 1e-8
    @test b ≈ [0 c0; c0 0] atol = 1e-6
    pc = curvaturas_principales(a, b)
    @test pc.κ ≈ [-c0, c0] atol = 1e-6
    @test abs(abs(pc.λ[1, 1]) - 1 / sqrt(2)) < 1e-6
    # Las curvas coordenadas son rectas: aα,α = 0 ⇒ bαα = 0 en todo punto
    θ2 = [0.6, -0.3]
    @test segunda_forma(r, θ2)[1, 1] ≈ 0 atol = 1e-6
    @test segunda_forma(r, θ2)[2, 2] ≈ 0 atol = 1e-6
    # Relación con el paraboloide curvo: Rx = −Ry = R, c = −1/R tras girar 45°
    R = 2.5
    cur = paraboloide_curvo(R, -R)
    rect = paraboloide_recto(-1 / R)
    X = [0.4, 0.9]                                     # (x', y') ejes principales
    xy = [(X[1] - X[2]) / sqrt(2), (X[1] + X[2]) / sqrt(2)]   # (x, y) en ejes de las generatrices
    @test cur(X)[3] ≈ rect(xy)[3] atol = 1e-12
    # Esfera de radio ρ con normal saliente: bαβ < 0, K = 1/ρ², H = −1/ρ
    ρ = 1.7
    esf(t) = ρ .* [sin(t[1]) * cos(t[2]), sin(t[1]) * sin(t[2]), cos(t[1])]
    t0 = [0.9, 0.4]
    Ae = base_superficie(esf, t0); ae = metrica(Ae); be = segunda_forma(esf, t0)
    pe = curvaturas_principales(ae, be)
    @test pe.K ≈ 1 / ρ^2 atol = 1e-6
    @test pe.H ≈ -1 / ρ atol = 1e-6
    @test all(pe.κ .< 0)
end

@testset "Derivada de un vector sobre la superficie y reglada" begin
    # Un vector constante C = Cᵅ aα + C³ n̂ tiene derivada nula: aplica Gauss y Weingarten
    Rx, Ry = 3.0, -2.0
    r = paraboloide_curvo(Rx, Ry)
    θ = [0.7, -0.4]
    Cc = [0.3, -0.2, 0.9]
    comps(t) = begin
        A = base_superficie(r, t); n = normal_unitaria(A)
        vcat(transpose(A * inv(metrica(A))) * Cc, dot(n, Cc))      # (V¹, V², V³)
    end
    h = 1e-5
    dV = [(comps(θ .+ (j == 1 ? [h, 0] : [0, h])) .- comps(θ .- (j == 1 ? [h, 0] : [0, h]))) ./ 2h for j in 1:2]
    A = base_superficie(r, θ); a = metrica(A); b = segunda_forma(r, θ)
    Γ = cristoffel_superficie(r, θ); bm = tensor_curvatura_mixto(a, b)
    V = comps(θ)
    for α in 1:2
        for μ in 1:2   # V^μ‖α − V³ b^μ_α = 0
            @test dV[α][μ] + sum(Γ[μ, β, α] * V[β] for β in 1:2) - V[3] * bm[μ, α] ≈ 0 atol = 1e-5
        end
        # componente normal: V³,α + V^β b_αβ = 0
        @test dV[α][3] + sum(V[β] * b[α, β] for β in 1:2) ≈ 0 atol = 1e-5
    end
    # Reglada z = c x y: a = 1 + c²(x²+y²), K = −c²/a²
    c0 = 0.8; rec = paraboloide_recto(c0); t = [0.5, -0.7]
    Ar = base_superficie(rec, t); ar = metrica(Ar); br = segunda_forma(rec, t)
    ap = 1 + c0^2 * (t[1]^2 + t[2]^2)
    @test det(ar) ≈ ap atol = 1e-8
    @test br ≈ [0 c0/sqrt(ap); c0/sqrt(ap) 0] atol = 1e-6
    @test curvaturas_principales(ar, br).K ≈ -c0^2 / ap^2 atol = 1e-6
    # Lámina esférica con normal saliente: √g/√a = (1 + θ³/ρ)²
    ρ = 2.0
    esf(t) = ρ .* [sin(t[1]) * cos(t[2]), sin(t[1]) * sin(t[2]), cos(t[1])]
    te = [1.0, 0.3]; Ae = base_superficie(esf, te); ae = metrica(Ae); be = segunda_forma(esf, te)
    pe = curvaturas_principales(ae, be)
    @test area_relativa(pe.H, pe.K, 0.1) ≈ (1 + 0.1 / ρ)^2 atol = 1e-6
end

@testset "Base oblicua a 60° (ejemplo del tema de bases covariantes y contravariantes)" begin
    B = [1.0 0.5; 0.0 sqrt(3) / 2]          # g₁ = (1,0), g₂ = (1/2, √3/2)
    V = [2.0, 1.5]
    @test metrica(B) ≈ [1 0.5; 0.5 1] atol = 1e-12
    @test det(metrica(B)) ≈ 3 / 4
    Br = base_reciproca(B)
    @test Br[:, 1] ≈ [1, -1 / sqrt(3)] atol = 1e-12            # g¹
    @test Br[:, 2] ≈ [0, 2 / sqrt(3)] atol = 1e-12             # g²
    @test reciprocidad(B) ≈ I(2) atol = 1e-12
    @test norm(Br[:, 1]) ≈ 2 / sqrt(3) atol = 1e-12
    Vup = comps_contravariantes(B, V); Vdn = comps_covariantes(B, V)
    @test Vup ≈ [2 - 1.5 / sqrt(3), 3 / sqrt(3)] atol = 1e-12  # V¹, V²
    @test Vdn ≈ [2, 1 + 3 * sqrt(3) / 4] atol = 1e-12          # V₁, V₂
    @test desde_contravariantes(B, Vup) ≈ V atol = 1e-12
    @test dot(Vup, Vdn) ≈ dot(V, V) atol = 1e-12
end
