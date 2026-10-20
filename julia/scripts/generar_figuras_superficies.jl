# Figuras de la Parte II (superficies) en figures/svg/*.svg.
#   julia --project=. julia/scripts/generar_figuras_superficies.jl
# Todos los vectores se calculan con Geometria y se verifican (aserciones) antes de dibujarlos.
include(joinpath(@__DIR__, "figuras_lib.jl"))

const NEGRO = "#1f2937"
const Rx, Ry = 3.0, -3.0                       # paraboloide de bordes curvos del ejemplo
const sup = paraboloide_curvo(Rx, Ry)
const rr(u, v) = sup([u, v])
const cam = Camara(0.9, 0.55)

relleno_plano = "#ede9fe"

# 1. Triada en un punto de la superficie (Cap. 6) --------------------------------
function fig_triada()
    θ = [1.8, -1.4]
    A = base_superficie(sup, θ); a = metrica(A)
    n = normal_unitaria(A); Ar = A * inv(a)
    @assert transpose(Ar) * A ≈ I(2) atol = 1e-8       # a^α·a_β = δ^α_β
    @assert abs(dot(n, A[:, 1])) < 1e-8 && abs(dot(n, A[:, 2])) < 1e-8 && norm(n) ≈ 1
    @assert dot(cross(A[:, 1], A[:, 2]), n) > 0           # orientación: a₁×a₂ ∥ +n̂
    P = rr(θ...)
    k = 1.5                                              # factor de ampliación (se indica en el pie)
    A, Ar, n = k .* A, k .* Ar, k .* n
    extremos = [P .+ A[:, 1], P .+ A[:, 2], P .+ Ar[:, 1], P .+ Ar[:, 2], P .+ n]
    pts = vcat([proy(cam, rr(u, w)) for u in (-2.2, 2.2) for w in (-2.2, 2.2)], [proy(cam, e) for e in extremos])
    v = ventana(pts; s = 95, margen = 0.35)
    s = parches(v, cam, rr, (-2.2, 2.2), (-2.2, 2.2))
    for u in -2:2
        s *= curva3(v, cam, [rr(u, w) for w in range(-2.2, 2.2; length = 40)]; color = "#94a3b8", w = 0.9)
        s *= curva3(v, cam, [rr(w, u) for w in range(-2.2, 2.2; length = 40)]; color = "#94a3b8", w = 0.9)
    end
    s *= flecha3(v, cam, P, P .+ Ar[:, 1]; color = AMBAR, w = 2.4, dash = "6 4", etiqueta = "a¹", dx = 6, dy = -8)
    s *= flecha3(v, cam, P, P .+ Ar[:, 2]; color = AMBAR, w = 2.4, dash = "6 4", etiqueta = "a²", dx = 6, dy = 14)
    s *= flecha3(v, cam, P, P .+ A[:, 1]; color = AZUL, w = 2.8, etiqueta = "a₁", dx = 6, dy = 16)
    s *= flecha3(v, cam, P, P .+ A[:, 2]; color = AZUL, w = 2.8, etiqueta = "a₂", dx = 6, dy = -6)
    s *= flecha3(v, cam, P, P .+ n; color = VIOLETA, w = 3, etiqueta = "n", dx = 8, dy = -2)
    s *= punto(v, proy(cam, P))
    guardar("hypar-triada", "Paraboloide hiperbólico con la base tangente a₁, a₂, la recíproca a¹, a² y la normal n en un punto",
            ancho(v), alto(v), s)
end

# 2. Plano tangente: base y recíproca, con la métrica del punto (Cap. 6) ------------
function fig_plano_tangente()
    θ = [1.8, -1.4]
    A = base_superficie(sup, θ); a = metrica(A)
    a1 = [sqrt(a[1, 1]), 0.0]
    a2 = [a[1, 2] / sqrt(a[1, 1]), sqrt(det(a) / a[1, 1])]
    B = hcat(a1, a2)
    @assert transpose(B) * B ≈ a atol = 1e-12            # misma métrica que en el espacio
    Br = B * inv(a)
    @assert transpose(Br) * B ≈ I(2) atol = 1e-12
    v = Vista(-1.4, 2.6, -1.1, 2.0; s = 130)
    O = (0.0, 0.0)
    s = linea(v, [O, Tuple(a1), Tuple(a1 .+ a2), Tuple(a2), O]; color = MALLA, w = 1.2, fill = "#eff6ff")
    s *= flecha(v, O, Tuple(a1); color = AZUL, w = 3, etiqueta = "a₁", dx = 6, dy = 16)
    s *= flecha(v, O, Tuple(a2); color = AZUL, w = 3, etiqueta = "a₂", dx = 8, dy = -2)
    s *= flecha(v, O, Tuple(Br[:, 1]); color = AMBAR, w = 2.6, dash = "6 4", etiqueta = "a¹  (⊥ a₂)", dx = 6, dy = 4)
    s *= flecha(v, O, Tuple(Br[:, 2]); color = AMBAR, w = 2.6, dash = "6 4", etiqueta = "a²  (⊥ a₁)", dx = -52, dy = -6)
    s *= punto(v, O)
    guardar("plano-tangente-bases", "Plano tangente: base covariante a₁, a₂ y su recíproca a¹, a² con la métrica del punto",
            ancho(v), alto(v), s)
end

# 3. Fórmula de Gauss: aα,β = Γ aγ + b n (Cap. 7) -----------------------------------
function fig_gauss()
    θ = [1.8, -1.4]
    A = base_superficie(sup, θ); a = metrica(A); n = normal_unitaria(A)
    D = derivadas_segundas(sup, θ); Γ = cristoffel_superficie(sup, θ); b = segunda_forma(sup, θ)
    for α in 1:2, β in 1:2
        @assert D[:, α, β] ≈ A * Γ[:, α, β] + b[α, β] * n atol = 1e-6
    end
    P = rr(θ...)
    k = 3.0                                             # factor de ampliación de los vectores derivada
    tang = k .* (A * Γ[:, 1, 1]); norm_ = k .* (b[1, 1] .* n); tot = k .* D[:, 1, 1]
    @assert tang .+ norm_ ≈ tot atol = 1e-6
    plano = [P .- 0.7A[:, 1] .- 0.7A[:, 2], P .+ 0.7A[:, 1] .- 0.7A[:, 2], P .+ 0.7A[:, 1] .+ 0.7A[:, 2], P .- 0.7A[:, 1] .+ 0.7A[:, 2]]
    pts = vcat([proy(cam, rr(u, w)) for u in (0.4, 3.2) for w in (-2.8, 0.0)],
               [proy(cam, p) for p in (P .+ tang, P .+ norm_, P .+ tot, P .+ n .* 0.8)])
    v = ventana(pts; s = 130, margen = 0.9)
    s = parches(v, cam, rr, (0.4, 3.2), (-2.8, 0.0))
    s *= linea(v, [proy(cam, p) for p in vcat(plano, [plano[1]])]; color = VIOLETA, w = 1.2, fill = relleno_plano, op = 0.75)
    s *= flecha3(v, cam, P, P .+ 0.8n; color = VIOLETA, w = 1.6, dash = "3 3", etiqueta = "n", dx = 8, dy = -2)
    s *= linea(v, [proy(cam, P .+ tang), proy(cam, P .+ tot), proy(cam, P .+ norm_)]; color = GRIS, w = 1, dash = "4 3")
    s *= flecha3(v, cam, P, P .+ tang; color = AZUL, w = 2.6, etiqueta = "Γᵞ₁₁aᵞ", dx = -64, dy = -6)
    s *= flecha3(v, cam, P, P .+ norm_; color = VIOLETA, w = 2.6, etiqueta = "b₁₁ n", dx = 8, dy = 14)
    s *= flecha3(v, cam, P, P .+ tot; color = NEGRO, w = 3.2, etiqueta = "a₁,₁", dx = 8, dy = 4)
    s *= punto(v, proy(cam, P))
    guardar("gauss-descomposicion", "Descomposición de a₁,₁ en una parte tangente (símbolos de Christoffel) y una normal (b₁₁)",
            ancho(v), alto(v), s)
end

# 4. Secciones normales en el punto de silla (Cap. 8) -------------------------------
function fig_secciones()
    θ = [0.0, 0.0]
    A = base_superficie(sup, θ); a = metrica(A); b = segunda_forma(sup, θ); n = normal_unitaria(A)
    pc = curvaturas_principales(a, b)
    @assert pc.κ ≈ [-1 / Rx, 1 / Rx] atol = 1e-6 || pc.κ ≈ sort([-1 / Rx, -1 / Ry]) atol = 1e-6
    sec(φ) = [(t * cos(φ), t * sin(φ), rr(t * cos(φ), t * sin(φ))[3]) for t in range(-2.1, 2.1; length = 60)]
    pts = vcat([proy(cam, rr(u, w)) for u in (-2.2, 2.2) for w in (-2.2, 2.2)], [proy(cam, (0, 0, 1.0))])
    v = ventana(pts; s = 95, margen = 0.5)
    s = parches(v, cam, rr, (-2.2, 2.2), (-2.2, 2.2))
    c1 = curvatura_normal(a, b, [1.0, 0.0]); c2 = curvatura_normal(a, b, [0.0, 1.0])
    c45 = curvatura_normal(a, b, [1.0, 1.0])
    @assert c1 < 0 && c2 > 0 && abs(c45) < 1e-6
    s *= curva3(v, cam, sec(0.0); color = AMBAR, w = 3.4)
    s *= curva3(v, cam, sec(π / 2); color = AZUL, w = 3.4)
    s *= curva3(v, cam, sec(π / 4); color = GRIS, w = 2.6, dash = "7 4")
    s *= curva3(v, cam, sec(3π / 4); color = GRIS, w = 2.6, dash = "7 4")
    s *= flecha3(v, cam, (0.0, 0.0, 0.0), (0.0, 0.0, 1.0); color = VIOLETA, w = 3, etiqueta = "n", dx = 8, dy = -2)
    pe(p) = proy(cam, p)
    s *= textov(v, pe((2.1, 0.0, rr(2.1, 0.0)[3])) .+ (0.05, -0.2), "κ &lt; 0"; color = AMBAR, tam = 14)
    s *= textov(v, pe((0.0, 2.1, rr(0.0, 2.1)[3])) .+ (0.05, 0.12), "κ &gt; 0"; color = AZUL, tam = 14)
    s *= textov(v, pe((1.5, 1.5, 0.0)) .+ (0.1, 0.1), "κ = 0"; color = GRIS, tam = 14)
    s *= punto(v, pe((0.0, 0.0, 0.0)))
    guardar("secciones-normales", "Secciones normales del paraboloide hiperbólico en el punto de silla: curvatura negativa, positiva y nula",
            ancho(v), alto(v), s)
end

# 5. Fórmula de Euler: κ(φ) en polares (Cap. 8) ------------------------------------
function fig_euler()
    θ = [0.0, 0.0]
    A = base_superficie(sup, θ); a = metrica(A); b = segunda_forma(sup, θ)
    pc = curvaturas_principales(a, b)
    κ1, κ2 = pc.κ
    κ(φ) = κ1 * cos(φ)^2 + κ2 * sin(φ)^2
    for φ in (0.3, 1.0, 2.2)                               # comprobación con curvatura_normal
        λ = cos(φ) * pc.λ[:, 1] + sin(φ) * pc.λ[:, 2]
        @assert curvatura_normal(a, b, λ) ≈ κ(φ) atol = 1e-8
    end
    esc = 1.3 / max(abs(κ1), abs(κ2))
    v = Vista(-1.6, 1.6, -1.6, 1.6; s = 110)
    s = linea(v, [(-1.5, 0.0), (0.0, 0.0)]; color = GRIS, w = 1.2) * linea(v, [(0.0, -1.5), (0.0, 0.0)]; color = GRIS, w = 1.2)
    s *= ejes(v; ox = 0.0, oy = 0.0, ex = 1.55, ey = 1.55, lx = "λ₁", ly = "λ₂")
    φs = range(0, 2π; length = 721)
    runs = Vector{Vector{Float64}}(); cur = Float64[]; signo = sign(κ(φs[1] + 1e-9))
    for φ in φs
        sg = sign(κ(φ))
        if sg != signo && !isempty(cur); push!(runs, cur); cur = Float64[]; signo = sg; end
        push!(cur, φ)
    end
    push!(runs, cur)
    for φ in runs
        isempty(φ) && continue
        m = κ(φ[cld(length(φ), 2)])
        col = m > 0 ? AZUL : AMBAR
        pts = vcat([(0.0, 0.0)], [(esc * abs(κ(t)) * cos(t), esc * abs(κ(t)) * sin(t)) for t in φ])
        s *= linea(v, vcat(pts, [(0.0, 0.0)]); color = col, w = 1.8, fill = col, op = 0.35)
    end
    s *= textov(v, (1.0, 0.12), "κ₁"; color = AMBAR, tam = 14)
    s *= textov(v, (0.12, 1.2), "κ₂"; color = AZUL, tam = 14)
    s *= textov(v, (0.0, -1.55), "κ(φ) = κ₁cos²φ + κ₂sin²φ"; ancla = "middle", cursiva = false, color = GRIS, tam = 14)
    guardar("curvatura-euler", "Curvatura normal en función del ángulo: los lóbulos azules son positivos y los ámbar negativos",
            ancho(v), alto(v), s)
end

# 6. Paraboloide reglado z = c x y (Cap. 9) -----------------------------------------
function fig_generatrices()
    c0 = 0.8
    rec = paraboloide_recto(c0)
    rg(u, w) = rec([u, w])
    cm = Camara(0.45, 0.5)
    pts = [proy(cm, rg(u, w)) for u in (-1.0, 1.0) for w in (-1.0, 1.0)]
    v = ventana(pts; s = 150, margen = 0.2)
    s = parches(v, cm, rg, (-1, 1), (-1, 1); n = 16)
    for u in range(-1, 1; length = 9)
        # recta: componentes lineales (θ², c u θ²) ⇒ aα,α = 0 ⇒ b_αα = 0
        s *= curva3(v, cm, [rg(u, -1.0), rg(u, 1.0)]; color = AZUL, w = 1.6)
        s *= curva3(v, cm, [rg(-1.0, u), rg(1.0, u)]; color = VERDE, w = 1.6)
    end
    guardar("hypar-generatrices", "Paraboloide hiperbólico z = c x y: las dos familias de generatrices rectas",
            ancho(v), alto(v), s)
end

# 7. Bordes curvos y bordes rectos en planta (Cap. 9) -------------------------------
function fig_bordes()
    v = Vista(-2.3, 2.3, -2.5, 2.0; s = 105)
    s = ejes(v; ox = -2.2, oy = 0.0, ex = 2.2, ey = 1.9, lx = "X", ly = "Y")
    s *= linea(v, [(-2.2, 0.0), (2.2, 0.0)]; color = GRIS, w = 1.2) * linea(v, [(0.0, -1.9), (0.0, 1.9)]; color = GRIS, w = 1.2)
    a, b = 1.5, 1.0
    s *= linea(v, [(-a, -b), (a, -b), (a, b), (-a, b), (-a, -b)]; color = AZUL, w = 2.6, fill = AZUL, op = 0.12)
    R(p) = ((p[1] - p[2]) / sqrt(2), (p[1] + p[2]) / sqrt(2))      # giro de 45°
    q = 1.1
    cuad = [(-q, -q), (q, -q), (q, q), (-q, q), (-q, -q)]
    s *= linea(v, [R(p) for p in cuad]; color = VERDE, w = 2.6, fill = VERDE, op = 0.12)
    s *= linea(v, [R((-2.0, 0.0)), R((2.0, 0.0))]; color = VERDE, w = 1.2, dash = "7 4")
    s *= linea(v, [R((0.0, -1.5)), R((0.0, 1.5))]; color = VERDE, w = 1.2, dash = "7 4")
    s *= textov(v, (1.2, -1.15), "bordes curvos"; color = AZUL, tam = 14, cursiva = false)
    s *= textov(v, (0.12, 1.62), "bordes rectos"; color = VERDE, tam = 14, cursiva = false)
    s *= textov(v, (0.0, -2.3), "planta: ejes principales (X, Y) y ejes de las generatrices (a 45°)"; ancla = "middle", cursiva = false, color = GRIS, tam = 12)
    guardar("hypar-bordes", "Vista en planta: rectángulo con bordes paralelos a los ejes principales (curvos) o a las generatrices (rectos)",
            ancho(v), alto(v), s)
end

println("Generando figuras de superficies:")
fig_triada(); fig_plano_tangente(); fig_gauss(); fig_secciones(); fig_euler(); fig_generatrices(); fig_bordes()
