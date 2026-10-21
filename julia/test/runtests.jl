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

@testset "Análisis tensorial en curvilíneas (tema B5)" begin
    polar(t) = base_polar(t[1], t[2])
    esf(t) = base_esferica(t[1], t[2], t[3])
    t0 = [1.7, 0.6]
    @test raiz_g(polar, t0) ≈ 1.7 atol = 1e-9
    # Divergencia: campo posición (x,y) = r ĝ₁ → Vʳ = r, Vᶿ = 0 → div = 2
    @test divergencia(polar, t -> [t[1], 0.0], t0) ≈ 2 atol = 1e-6
    # Campo constante (1,0): Vʳ = cos θ, Vᶿ = −sen θ / r → div = 0
    @test divergencia(polar, t -> [cos(t[2]), -sin(t[2]) / t[1]], t0) ≈ 0 atol = 1e-6
    # Esféricas: div(r ĝ_r) = 3 (campo posición)
    @test divergencia(esf, t -> [t[1], 0.0, 0.0], [1.3, 0.8, 0.5]) ≈ 3 atol = 1e-6
    # Gradiente de f = x² + y² = r²: ∇f = 2r ĝ_r → componentes contravariantes (2r, 0)
    @test gradiente(polar, t -> t[1]^2, t0) ≈ [2 * 1.7, 0.0] atol = 1e-6
    # Gradiente de una función de θ: f = θ → (∇f)ᶿ = 1/r²
    @test gradiente(polar, t -> t[2], t0) ≈ [0.0, 1 / 1.7^2] atol = 1e-6
    # Laplaciano: Δ(r²) = 4 y Δ(ln r) = 0 (armónica); Δ(x) con f = r cosθ = x → 0
    @test laplaciano(polar, t -> t[1]^2, t0) ≈ 4 atol = 1e-4
    @test laplaciano(polar, t -> log(t[1]), t0) ≈ 0 atol = 1e-4
    @test laplaciano(polar, t -> t[1] * cos(t[2]), t0) ≈ 0 atol = 1e-4
    # Teorema de la divergencia en el disco: ∫ div(x,y) dA = 2πR² = ∮ V·n ds
    R = 2.0; N = 400
    integral = sum(divergencia(polar, t -> [t[1], 0.0], [(i - 0.5) * R / N, 0.3]) * (i - 0.5) * R / N * (R / N) * 2π for i in 1:N)
    @test integral ≈ 2π * R^2 atol = 1e-3
    # Símbolo de permutación y producto vectorial: gᵢ × gⱼ = εᵢⱼₖ gᵏ con εᵢⱼₖ = √g [ijk]
    e = levi_civita(3); B = esf([1.3, 0.8, 0.5]); Br = base_reciproca(B); sg = raiz_g(esf, [1.3, 0.8, 0.5])
    for i in 1:3, j in 1:3
        @test cross(B[:, i], B[:, j]) ≈ sum(sg * e[i, j, k] * Br[:, k] for k in 1:3) atol = 1e-9
    end
    # Rotacional de V = (−y, x, 0) = rotación rígida: curl = (0,0,2). Componentes covariantes en cilíndricas
    cilindricas(t) = [cos(t[2]) -t[1] * sin(t[2]) 0.0; sin(t[2]) t[1] * cos(t[2]) 0.0; 0.0 0.0 1.0]
    campo_dn(t) = transpose(cilindricas(t)) * [-t[1] * sin(t[2]), t[1] * cos(t[2]), 0.0]   # Vᵢ = V·gᵢ
    curlup = rotacional(cilindricas, campo_dn, [1.4, 0.9, 0.3])
    @test curlup ≈ [0.0, 0.0, 2.0] atol = 1e-5      # (∇×V)ᶻ = 2 (con g_z unitario)
end

@testset "Superficies tipo, curvas y Theorema Egregium (tema C4 y C6)" begin
    # Tabla de superficies tipo: aαβ, K y H
    R = 1.8
    for (r, t, a_esp, K_esp, H_esp) in (
            (cilindro(R), [0.7, 0.4], [R^2 0; 0 1], 0.0, -1 / (2R)),
            (esfera(R), [1.0, 0.4], [R^2 0; 0 R^2 * sin(1.0)^2], 1 / R^2, -1 / R),
            (cono(0.6), [0.5, 1.3], [(1.3 * sin(0.6))^2 0; 0 1], 0.0, nothing))
        A = base_superficie(r, t); a = metrica(A); b = segunda_forma(r, t)
        @test a ≈ a_esp atol = 1e-6
        pc = curvaturas_principales(a, b)
        @test pc.K ≈ K_esp atol = 1e-5
        H_esp === nothing || @test pc.H ≈ H_esp atol = 1e-5
    end
    # Placa oblicua: plana, no ortogonal
    φ = π / 3; po = placa_oblicua(φ); A = base_superficie(po, [0.2, 0.3]); a = metrica(A)
    @test a ≈ [1 cos(φ); cos(φ) 1] atol = 1e-8
    @test segunda_forma(po, [0.2, 0.3]) ≈ zeros(2, 2) atol = 1e-8
    # Theorema Egregium: K desde la métrica (Brioschi) = det(b)/det(a)
    for (r, t) in ((esfera(1.5), [1.1, 0.4]), (cilindro(1.5), [0.3, 0.2]),
                   (paraboloide_curvo(3.0, -2.0), [0.7, -0.4]), (paraboloide_recto(0.8), [0.5, -0.7]))
        a = metrica_superficie(r, t); b = segunda_forma(r, t)
        @test curvatura_gauss_brioschi(r, t) ≈ det(b) / det(a) atol = 1e-4
    end
    # Curvaturas de una curva: paralelo de la esfera de colatitud θ₀ = 1,0, radio ρ
    ρ = 2.0; θ0 = 1.0
    paralelo(t) = [θ0, t]
    κ, κn, κg = curvaturas_curva(esfera(ρ), paralelo, 0.7)
    @test κ ≈ 1 / (ρ * sin(θ0)) atol = 1e-5
    @test κn ≈ -1 / ρ atol = 1e-5                          # normal saliente → κn < 0
    @test abs(κg) ≈ cos(θ0) / (ρ * sin(θ0)) atol = 1e-5    # cot θ₀ / ρ
    @test κ^2 ≈ κn^2 + κg^2 atol = 1e-8
    # El ecuador es geodésica: κg = 0; un meridiano también
    @test curvaturas_curva(esfera(ρ), t -> [π / 2, t], 0.4)[3] ≈ 0 atol = 1e-5
    @test curvaturas_curva(esfera(ρ), t -> [t, 0.3], 0.9)[3] ≈ 0 atol = 1e-5
    # Geodésica integrada: gran círculo oblicuo; velocidad constante y κg ≈ 0
    θs, vs = geodesica(esfera(1.0), [π / 2, 0.0], [0.3, 0.7]; T = 2.0, n = 200)
    rapidez(θ, v) = sqrt(v' * metrica_superficie(esfera(1.0), θ) * v)
    @test rapidez(θs[:, 1], vs[:, 1]) ≈ rapidez(θs[:, end], vs[:, end]) atol = 1e-6
    P = hcat([esfera(1.0)(θs[:, k]) for k in 1:size(θs, 2)]...)
    # un gran círculo está en un plano que pasa por el origen: det de tres puntos ≈ 0
    @test abs(det(hcat(P[:, 1], P[:, 80], P[:, 170]))) < 1e-5
    # Codazzi
    for (r, t) in ((esfera(1.5), [1.1, 0.4]), (paraboloide_curvo(3.0, -2.0), [0.7, -0.4]), (cilindro(1.5), [0.3, 0.2]))
        c = codazzi(r, t)
        @test abs(c[1]) < 1e-4 && abs(c[2]) < 1e-4
    end
end

@testset "Bestiario de láminas (tema C6)" begin
    # Placa oblicua: base recíproca a¹ = (1, −cot φ), a² = (0, 1/sen φ); a¹² = −cos φ / sen² φ
    φ = π / 3; po = placa_oblicua(φ); A = base_superficie(po, [0.4, 0.2])[1:2, :]; a = metrica(A)
    Ar = base_reciproca(A)
    @test Ar[:, 1] ≈ [1, -cos(φ) / sin(φ)] atol = 1e-8
    @test Ar[:, 2] ≈ [0, 1 / sin(φ)] atol = 1e-8
    @test inv(a)[1, 2] ≈ -cos(φ) / sin(φ)^2 atol = 1e-8
    @test det(a) ≈ sin(φ)^2 atol = 1e-8
    # Cilindro: Γ = 0, b = diag(−R,0), H = −1/(2R)
    R = 1.8; t = [0.7, 0.4]
    @test cristoffel_superficie(cilindro(R), t) ≈ zeros(2, 2, 2) atol = 1e-6
    @test segunda_forma(cilindro(R), t) ≈ [-R 0; 0 0] atol = 1e-5
    # Esfera (θ¹ colatitud, θ² azimut): Γ¹₂₂ = −senθ cosθ, Γ²₁₂ = cot θ; b = −a/R
    θ = 1.0; te = [θ, 0.4]; Γ = cristoffel_superficie(esfera(R), te)
    @test Γ[1, 2, 2] ≈ -sin(θ) * cos(θ) atol = 1e-6
    @test Γ[2, 1, 2] ≈ cos(θ) / sin(θ) atol = 1e-6
    @test segunda_forma(esfera(R), te) ≈ -metrica_superficie(esfera(R), te) / R atol = 1e-5
    # Cono de semiángulo α con (θ¹, θ²) = (φ, t): a = diag(t² sen²α, 1); Γ¹₁₂ = 1/t, Γ²₁₁ = −t sen²α; b₁₁ = −t senα cosα
    α = 0.6; tc = [0.5, 2.0]; K = cono(α)
    ac = metrica_superficie(K, tc)
    @test ac ≈ [tc[2]^2 * sin(α)^2 0; 0 1] atol = 1e-6
    Γc = cristoffel_superficie(K, tc)
    @test Γc[1, 1, 2] ≈ 1 / tc[2] atol = 1e-5
    @test Γc[2, 1, 1] ≈ -tc[2] * sin(α)^2 atol = 1e-5
    bc = segunda_forma(K, tc)
    @test bc[1, 1] ≈ -tc[2] * sin(α) * cos(α) atol = 1e-5
    @test abs(bc[1, 2]) + abs(bc[2, 2]) < 1e-5
    pc = curvaturas_principales(ac, bc)
    @test pc.K ≈ 0 atol = 1e-6
    @test pc.H ≈ -cos(α) / (2 * tc[2] * sin(α)) atol = 1e-5
end

@testset "Elasticidad del sólido (tema D1 y D2)" begin
    E, ν = 210e3, 0.3
    λ, μ = lame(E, ν)
    @test μ ≈ E / (2 * (1 + ν))
    @test λ ≈ E * ν / ((1 + ν) * (1 - 2ν))
    # Hooke cartesiano: σ = λ tr(ε) I + 2μ ε
    C = hooke_contravariante(Matrix(1.0I, 3, 3), E, ν)
    ε = [1e-3 2e-4 0; 2e-4 -5e-4 1e-4; 0 1e-4 3e-4]
    σ = tension_hooke(C, ε)
    @test σ ≈ λ * tr(ε) * I(3) + 2μ * ε atol = 1e-8
    @test energia_deformacion(C, ε) ≈ sum(σ .* ε) / 2
    # Tensión plana (Voigt): coincide con la reducción de Hooke con σ₃₃ = 0
    D = matriz_tension_plana(E, ν)
    εp = [1e-3, -4e-4, 2 * 3e-4]
    σp = D * εp
    ε3 = [1e-3 3e-4 0; 3e-4 -4e-4 0; 0 0 -ν / (1 - ν) * (1e-3 - 4e-4)]
    @test tension_hooke(C, ε3)[3, 3] ≈ 0 atol = 1e-8                 # εzz libre ⇒ σzz = 0
    @test [tension_hooke(C, ε3)[1, 1], tension_hooke(C, ε3)[2, 2], tension_hooke(C, ε3)[1, 2]] ≈ [σp[1], σp[2], σp[3]] atol = 1e-6
    # Hooke es un tensor: la energía es invariante al pasar a polares
    pol(t) = [cos(t[2]) -t[1] * sin(t[2]) 0; sin(t[2]) t[1] * cos(t[2]) 0; 0 0 1]
    t0 = [1.4, 0.7]; B = pol(t0)
    Cpol = hooke_contravariante(inv(metrica(B)), E, ν)
    εpol = transpose(B) * ε * B                                     # componentes covariantes εᵢⱼ en polares
    @test energia_deformacion(Cpol, εpol) ≈ energia_deformacion(C, ε) atol = 1e-8
    # Deformación pequeña en curvilíneas: expansión uniforme u = x ⇒ ε = g
    uexp(t) = transpose(base_polar(t[1], t[2])) * [t[1] * cos(t[2]), t[1] * sin(t[2])]
    @test deformacion_pequena(t -> base_polar(t[1], t[2]), uexp, t0) ≈ metrica(base_polar(t0...)) atol = 1e-6
    # Giro rígido infinitesimal u = ω×x en el plano: ε = 0
    urot(t) = transpose(base_polar(t[1], t[2])) * [-t[1] * sin(t[2]), t[1] * cos(t[2])]
    @test deformacion_pequena(t -> base_polar(t[1], t[2]), urot, t0) ≈ zeros(2, 2) atol = 1e-6
    # Cauchy–Green y Green–Lagrange
    F = [1.1 0.2; 0.0 0.9]
    @test cauchy_green(F) ≈ F' * F
    @test green_lagrange(Matrix(1.0I, 2, 2), cauchy_green(F)) ≈ (F' * F - I) / 2
    Fs = I(2) + 1e-6 * [0.3 0.1; -0.2 0.5]
    @test green_lagrange(Matrix(1.0I, 2, 2), cauchy_green(Fs)) ≈ 1e-6 * [0.3 -0.05; -0.05 0.5] atol = 1e-11   # ≈ ε pequeña
    # Equilibrio: un tensor cartesiano uniforme tiene divergencia nula, también en componentes polares
    S = [2.0 0.5; 0.5 -1.0]
    σpol(t) = (J = inv(base_polar(t[1], t[2])); J * S * J')
    @test divergencia_tensor(t -> base_polar(t[1], t[2]), σpol, t0) ≈ zeros(2) atol = 1e-6
end

@testset "Green–Lagrange en curvilíneas (tema D1)" begin
    base(t) = base_polar(t[1], t[2])
    t0 = [1.4, 0.7]
    # Desplazamiento cartesiano no lineal u(x,y); componentes covariantes uᵢ = u·gᵢ
    ucart(x) = [0.05 * x[1] * x[2], 0.02 * x[1]^2 - 0.03 * x[2]]
    xcart(t) = [t[1] * cos(t[2]), t[1] * sin(t[2])]
    udn(t) = transpose(base(t)) * ucart(xcart(t))
    # Deformada directa: R(θ) = x(θ) + u(x(θ)); G = métrica de ∂R/∂θ
    R(t) = xcart(t) + ucart(xcart(t))
    G = metrica(jacobiana_numerica(R, t0; h = 1e-6))
    E_directa = green_lagrange(metrica(base(t0)), G)
    @test green_lagrange_desde_u(base, udn, t0) ≈ E_directa atol = 1e-6
    # La parte lineal es la deformación pequeña y el término cuadrático es de orden |∇u|²
    @test norm(green_lagrange_desde_u(base, udn, t0) - deformacion_pequena(base, udn, t0)) < 0.02
    # Giro rígido finito (rotación de ángulo α): Eᵢⱼ = 0 aunque F ≠ I
    α = 0.4
    Rg(t) = [cos(α) -sin(α); sin(α) cos(α)] * xcart(t)
    Grot = metrica(jacobiana_numerica(Rg, t0; h = 1e-6))
    @test green_lagrange(metrica(base(t0)), Grot) ≈ zeros(2, 2) atol = 1e-8
end

@testset "Cinemática de láminas (temas D3–D6)" begin
    r = paraboloide_curvo(3.0, -2.0); θ = [0.7, -0.4]
    # campos suaves arbitrarios (componentes covariantes de u sobre aα y giro φ del director)
    udn(t) = [0.30 * sin(t[1]) + 0.1 * t[2], 0.20 * cos(t[2]) - 0.05 * t[1]]
    u3(t) = 0.25 * t[1] * t[2] + 0.1 * cos(t[1])
    φdn(t) = [0.12 * t[2] - 0.05, -0.08 * t[1] + 0.03 * sin(t[2])]
    # (1) Linealización: las deformaciones exactas / s → fórmulas lineales
    s = 1e-6
    R0, A3 = campos_lamina(r, udn, u3, φdn, s)
    γ0, γ1, γS = deformacion_lamina_lineal(r, udn, u3, φdn, θ)
    γ_exacta(θ3) = deformacion_lamina_exacta(r, R0, A3, θ, θ3; h = 1e-5) / s
    @test γ_exacta(0.0)[1:2, 1:2] ≈ γ0 atol = 2e-4                        # membrana en θ³ = 0
    # parte lineal en θ³: ∂γαβ/∂θ³ = γ¹αβ ;  ∂²/∂θ³² = O(s) (término cuadrático)
    d(θ3) = (γ_exacta(θ3)[1:2, 1:2] - γ_exacta(-θ3)[1:2, 1:2]) / (2θ3)
    @test d(0.05) ≈ γ1 atol = 2e-3
    # cortante: 2γα3 = φα + u₃,α + bᵅρ uρ  (exactamente en θ³ y a orden lineal)
    @test 2 .* [γ_exacta(0.0)[1, 3], γ_exacta(0.0)[2, 3]] ≈ γS atol = 2e-4
    @test 2 .* [γ_exacta(0.05)[1, 3], γ_exacta(0.05)[2, 3]] ≈ γS atol = 2e-4   # sin dependencia en θ³
    # (2) Límite de Kirchhoff: φα = −(u₃,α + bᵅρ uρ) ⇒ cortante nulo y A₃ ≈ normal de la deformada
    a = metrica_superficie(r, θ); b = segunda_forma(r, θ); bm = tensor_curvatura_mixto(a, b)
    function φkl(t)
        h = 1e-5
        bmt = tensor_curvatura_mixto(metrica_superficie(r, t), segunda_forma(r, t))
        du3 = [(u3(t .+ h .* (1:2 .== α)) - u3(t .- h .* (1:2 .== α))) / 2h for α in 1:2]
        -(du3 .+ [sum(bmt[ρ, α] * udn(t)[ρ] for ρ in 1:2) for α in 1:2])
    end
    _, _, γSkl = deformacion_lamina_lineal(r, udn, u3, φkl, θ)
    @test γSkl ≈ zeros(2) atol = 1e-7
    # Kirchhoff exacto: director = normal de la superficie deformada ⇒ γα3 = γ33 = 0 a O(s²) y γ¹ = b − B
    R0k, _ = campos_lamina(r, udn, u3, φkl, s)
    A3k(t) = normal_unitaria(base_superficie(R0k, t))
    γk = deformacion_lamina_exacta(r, R0k, A3k, θ, 0.0; h = 1e-5)
    @test abs(γk[1, 3]) + abs(γk[2, 3]) + abs(γk[3, 3]) < 5e-7
    Bk = segunda_forma(R0k, θ)
    d1 = (deformacion_lamina_exacta(r, R0k, A3k, θ, 0.02; h = 1e-5)[1:2, 1:2] - deformacion_lamina_exacta(r, R0k, A3k, θ, -0.02; h = 1e-5)[1:2, 1:2]) / 0.04
    @test d1 ≈ b - Bk atol = 2e-6                                          # γ¹ = −(Bαβ − bαβ)
    # (3) Placa plana: γ¹ = −u₃,αβ (curvatura de Kirchhoff), γ⁰ = deformación en el plano
    plana = placa_oblicua(π / 2)
    w(t) = 0.3 * sin(t[1]) * cos(t[2])
    φpl(t) = -[0.3 * cos(t[1]) * cos(t[2]), -0.3 * sin(t[1]) * sin(t[2])]       # φ = −∇w
    _, g1p, _ = deformacion_lamina_lineal(plana, t -> [0.0, 0.0], w, φpl, [0.4, 0.5])
    @test g1p ≈ -[-0.3 * sin(0.4) * cos(0.5)  -0.3 * cos(0.4) * sin(0.5); -0.3 * cos(0.4) * sin(0.5)  -0.3 * sin(0.4) * cos(0.5)] atol = 1e-5
end

@testset "Rigidez de la lámina (tema D7)" begin
    E, ν, t = 210e3, 0.3, 0.1
    # Base ortonormal: la matriz de membrana es la de tensión plana por el espesor
    CE, CB, CS = rigidez_lamina(Matrix(1.0I, 2, 2), E, ν, t)
    @test CE ≈ t * matriz_tension_plana(E, ν) atol = 1e-6
    @test CB ≈ t^3 / 12 * matriz_tension_plana(E, ν) atol = 1e-6
    @test CS ≈ t * E / (2 * (1 + ν)) * I(2) atol = 1e-6
    # Base oblicua: la condensación estática de γ₃₃ del Hooke 3D da el mismo tensor plano
    φ = π / 3; a = [1 cos(φ); cos(φ) 1]
    ginv3 = zeros(3, 3); ginv3[1:2, 1:2] = inv(a); ginv3[3, 3] = 1
    C3 = hooke_contravariante(ginv3, E, ν)
    Cplana(α, β, γ, δ) = C3[α, β, γ, δ] - C3[3, 3, α, β] * C3[3, 3, γ, δ] / C3[3, 3, 3, 3]
    CEo, CBo, CSo = rigidez_lamina(a, E, ν, t)
    # U de membrana con un γ⁰ cualquiera: ½ t Cᵃᵇᶜᵈ γαβ γγδ  (comparación con la forma de Voigt)
    γ = [2e-3 5e-4; 5e-4 -1e-3]
    U_tensor = 0.5 * t * sum(Cplana(α, β, γd, δ) * γ[α, β] * γ[γd, δ] for α in 1:2, β in 1:2, γd in 1:2, δ in 1:2)
    v = [γ[1, 1], γ[2, 2], 2γ[1, 2]]
    @test 0.5 * v' * CEo * v ≈ U_tensor atol = 1e-9
    # cortante: Eᵅ³ᵝ³ = μ aᵅᵝ
    μ = E / (2 * (1 + ν))
    @test CSo ≈ t * μ * inv(a) atol = 1e-8
    @test C3[1, 3, 2, 3] ≈ μ * inv(a)[1, 2] atol = 1e-8
end
