# Genera las figuras de geometría exacta de la Parte I en figures/svg/*.svg.
#   julia --project=. julia/scripts/generar_figuras.jl
# Sin dependencias: SVG escrito a mano. Las bases usan el paquete Geometria.
include(joinpath(@__DIR__, "figuras_lib.jl"))

# ---------------------------------------------------------------------------
# 1. Un mismo vector, dos bases (Cap. 2)
function fig_vector_dos_bases()
    v = Vista(-0.3, 6.2, -0.3, 5.6)
    r, θ = 3.4, 0.62
    P = (r * cos(θ), r * sin(θ))
    B = base_polar(r, θ)
    g1, g2 = B[:, 1], B[:, 2]
    Vc = (1.5, 0.9)
    s = ejes(v)
    for k in 1:5   # circunferencias y rayos de las polares
        s *= linea(v, arco(k * 1.0, 0, π / 2); color = MALLA, w = 1)
    end
    for a in range(0, π / 2; length = 7)
        s *= linea(v, rayo(a, 0, 6.2); color = MALLA, w = 1)
    end
    s *= flecha(v, P, P .+ g1; color = AZUL, etiqueta = "g₁", dx = 6, dy = 16)
    s *= flecha(v, P, P .+ g2 ./ 2; color = VERDE, etiqueta = "g₂ (mitad de longitud)", dx = -150, dy = -4)
    s *= flecha(v, P, P .+ (1.0, 0.0); color = GRIS, w = 1.8, dash = "5 3", etiqueta = "e$(SUB("x"))", dx = 6, dy = 14)
    s *= flecha(v, P, P .+ (0.0, 1.0); color = GRIS, w = 1.8, dash = "5 3", etiqueta = "e$(SUB("y"))", dx = 6, dy = -2)
    s *= flecha(v, P, P .+ Vc; color = AMBAR, w = 3.4, etiqueta = "V", dx = 8, dy = -2)
    s *= punto(v, P)
    s *= textov(v, (P[1] - 0.15, P[2] - 0.3), "P"; ancla = "end")
    guardar("vector-dos-bases", "Un mismo vector V en la base cartesiana y en la base polar en el punto P",
            ancho(v), alto(v), s)
end

# 2. Jacobiano como razón de áreas (Cap. 2)
function fig_jacobiano()
    v1 = Vista(0, 3.4, -0.25, 1.6; s = 60, sy = 100)
    v2 = Vista(-0.2, 3.2, -0.45, 3.2; s = 60)
    off = ancho(v1) + 30
    H = max(alto(v1), alto(v2))
    s = "<g transform=\"translate(0,$(f(H - alto(v1))))\">\n"
    # panel izquierdo: plano paramétrico (r, θ)
    s *= ejes(v1; ex = 3.4, ey = 1.6, lx = "r", ly = "θ")
    for r in 1:0.5:3
        s *= linea(v1, [(r, 0.15), (r, 1.35)]; color = MALLA, w = 1)
    end
    for t in 0.15:0.2:1.35
        s *= linea(v1, [(1.0, t), (3.0, t)]; color = MALLA, w = 1)
    end
    r0, dr, t0, dt = 2.0, 0.4, 0.6, 0.3
    s *= linea(v1, [(r0, t0), (r0 + dr, t0), (r0 + dr, t0 + dt), (r0, t0 + dt), (r0, t0)];
               color = AMBAR, w = 2.2, fill = AMBAR, op = 0.9)
    s *= textov(v1, (r0 + dr + 0.08, t0 + dt / 2), "dr dθ"; color = AMBAR)
    s *= texto(ancho(v1) / 2, alto(v1) - 4, "plano (r, θ)"; cursiva = false, color = GRIS, ancla = "middle")
    s *= "</g>\n<g transform=\"translate($(f(off)),$(f(H - alto(v2))))\">\n"
    # panel derecho: plano físico (x, y)
    s *= ejes(v2; ex = 3.2, ey = 3.2)
    for r in 1:0.5:3
        s *= linea(v2, arco(r, 0.15, 1.35); color = MALLA, w = 1)
    end
    for t in 0.15:0.2:1.35
        s *= linea(v2, rayo(t, 1.0, 3.0); color = MALLA, w = 1)
    end
    celda = vcat(arco(r0, t0, t0 + dt; n = 20), reverse(arco(r0 + dr, t0, t0 + dt; n = 20)))
    s *= linea(v2, vcat(celda, [celda[1]]); color = AMBAR, w = 2.2, fill = AMBAR, op = 0.9)
    O = (r0 * cos(t0), r0 * sin(t0))
    g1 = base_polar(r0, t0)[:, 1] .* dr
    g2 = base_polar(r0, t0)[:, 2] .* dt
    s *= flecha(v2, O, O .+ g1; color = AZUL, w = 2.6, etiqueta = "g₁ dr", dx = 6, dy = 14)
    s *= flecha(v2, O, O .+ g2; color = VERDE, w = 2.6, etiqueta = "g₂ dθ", dx = -62, dy = -4)
    s *= texto(ancho(v2) / 2, alto(v2) - 4, "plano (x, y): área = r dr dθ"; cursiva = false, color = GRIS, ancla = "middle")
    s *= "</g>\n"
    guardar("jacobiano-area", "Una celda dr dθ del plano paramétrico se transforma en un elemento de área r dr dθ del plano físico",
            off + ancho(v2), H, s)
end

# 3. Galería de coordenadas curvilíneas (Cap. 2)
function fig_galeria()
    paneles = Any[]
    # (a) lineales oblicuas
    va = Vista(-0.3, 3.3, -0.7, 2.5; s = 52)
    sa = ""
    e1, e2 = (1.0, 0.0), (0.55, 0.85)
    P(a, b) = (a * e1[1] + b * e2[1], a * e1[2] + b * e2[2])
    for k in 0:3
        sa *= linea(va, [P(k, 0), P(k, 2.5)]; color = AZUL, w = 1.4)
        sa *= linea(va, [P(0, k * 0.8), P(3, k * 0.8)]; color = VERDE, w = 1.4)
    end
    sa *= textov(va, (1.5, -0.6), "oblicuas lineales"; cursiva = false, color = GRIS, ancla = "middle")
    push!(paneles, (va, sa))
    # (b) polares
    vb = Vista(-0.3, 2.3, -0.7, 2.3; s = 52 * 3.6 / 2.6)
    sb = ""
    for r in 0.4:0.4:2.0
        sb *= linea(vb, arco(r, 0, π / 2); color = AZUL, w = 1.4)
    end
    for a in range(0, π / 2; length = 7)
        sb *= linea(vb, rayo(a, 0, 2.0); color = VERDE, w = 1.4)
    end
    sb *= punto(vb, (0, 0); color = AMBAR, r = 5)
    sb *= textov(vb, (1.0, -0.6), "polares (punto singular r = 0)"; cursiva = false, color = GRIS, ancla = "middle")
    push!(paneles, (vb, sb))
    # (c) elípticas
    vc = Vista(-2.1, 2.1, -2.3, 1.8; s = 52 * 3.6 / 4.2 * 1.1)
    sc = ""
    for u in 0.25:0.25:1.25
        sc *= linea(vc, [(cosh(u) * cos(w), sinh(u) * sin(w)) for w in range(0, 2π; length = 100)]; color = AZUL, w = 1.3)
    end
    for w in range(0, 2π; length = 17)[1:16]
        sc *= linea(vc, [(cosh(u) * cos(w), sinh(u) * sin(w)) for u in range(0, 1.25; length = 30)]; color = VERDE, w = 1.3)
    end
    sc *= textov(vc, (0, -2.1), "elípticas"; cursiva = false, color = GRIS, ancla = "middle")
    push!(paneles, (vc, sc))
    H = maximum(alto(p[1]) for p in paneles)
    cuerpo = ""
    x = 0.0
    for (vv, ss) in paneles
        cuerpo *= "<g transform=\"translate($(f(x)),$(f(H - alto(vv))))\">\n$ss</g>\n"
        x += ancho(vv) + 10
    end
    guardar("galeria-coordenadas", "Tres sistemas de coordenadas del plano: lineales oblicuas, polares y elípticas", x, H, cuerpo)
end

# 4. Componentes físicas en polares (Cap. 4)
function fig_fisicas()
    v = Vista(-0.3, 5.4, -0.3, 4.4; s = 70)
    r, θ = 2.6, 0.55
    P = (r * cos(θ), r * sin(θ))
    B = base_polar(r, θ)
    ĝ1, ĝ2 = B[:, 1], B[:, 2] ./ r
    Vf = (1.5, 1.0)                      # componentes físicas (V⁽¹⁾, V⁽²⁾)
    s = ejes(v)
    for k in 1:5
        s *= linea(v, arco(float(k), 0, π / 2); color = MALLA, w = 1)
    end
    for a in range(0, π / 2; length = 7)
        s *= linea(v, rayo(a, 0, 5.4); color = MALLA, w = 1)
    end
    Q1 = P .+ Vf[1] .* ĝ1
    Q2 = P .+ Vf[2] .* ĝ2
    V = P .+ Vf[1] .* ĝ1 .+ Vf[2] .* ĝ2
    s *= linea(v, [P, Q1, V, Q2, P]; color = AMBAR, w = 1.3, dash = "5 4")
    s *= flecha(v, P, P .+ B[:, 2]; color = VERDE, w = 1.6, dash = "7 4", etiqueta = "g₂ (|g₂| = r)", dx = -92, dy = -6)
    s *= flecha(v, P, P .+ ĝ1; color = AZUL, etiqueta = "ĝ₁ = g₁", dx = 8, dy = 18)
    s *= flecha(v, P, P .+ ĝ2; color = VERDE, etiqueta = "ĝ₂ = g₂/r", dx = -80, dy = 18)
    s *= flecha(v, P, V; color = AMBAR, w = 3.4, etiqueta = "V", dx = 8, dy = -2)
    s *= punto(v, P)
    guardar("componentes-fisicas", "Componentes físicas de un vector en polares: coordenadas respecto a la base normalizada",
            ancho(v), alto(v), s)
end

# 5. Derivada de la base y símbolos de Christoffel en polares (Cap. 5)
function fig_christoffel()
    v = Vista(-0.3, 9.6, -0.3, 3.8; s = 70)
    r = 2.4
    s = ejes(v)
    for k in 1:3
        s *= linea(v, arco(float(k), 0, π / 2); color = MALLA, w = 1)
    end
    for a in range(0, π / 2; length = 7)
        s *= linea(v, rayo(a, 0, 4.0); color = MALLA, w = 1)
    end
    s *= linea(v, arco(r, 0, π / 2); color = GRIS, w = 1.4)
    for θ in (0.3, 0.8, 1.3)
        P = (r * cos(θ), r * sin(θ))
        B = base_polar(r, θ)
        s *= flecha(v, P, P .+ B[:, 1]; color = AZUL, w = 2.2)
        s *= flecha(v, P, P .+ B[:, 2] ./ r; color = VERDE, w = 2.2)
        s *= punto(v, P; r = 3)
    end
    θ = 0.8
    P = (r * cos(θ), r * sin(θ))
    B = base_polar(r, θ)
    s *= textov(v, P .+ B[:, 1] .+ (0.05, -0.1), "g₁"; color = AZUL)
    s *= textov(v, P .+ B[:, 2] ./ r .+ (-0.7, 0.12), "g₂/r"; color = VERDE)
    # ∂g₁/∂θ = g₂/r   y   ∂g₂/∂θ = −r g₁ (trasladados a una zona libre)
    Q = (4.8, 3.0)
    dg1 = B[:, 2] ./ r
    dg2 = -r .* B[:, 1]
    s *= flecha(v, Q, Q .+ dg1; color = AMBAR, w = 3)
    s *= textov(v, Q .+ (0.15, 0.05), "∂g₁/∂θ = g₂/r = Γ²₁₂ g₂"; color = AMBAR, tam = 14)
    R = (5.2, 2.2)
    s *= flecha(v, R, R .+ dg2 .* 0.5; color = VIOLETA, w = 3)
    s *= textov(v, R .+ (0.2, 0.2), "∂g₂/∂θ = −r g₁ = Γ¹₂₂ g₁  (×0,5)"; color = VIOLETA, tam = 14)
    guardar("christoffel-polares", "Derivada de la base polar respecto de θ: el giro de la base define los símbolos de Christoffel",
            ancho(v), alto(v), s)
end

# 6. Un campo constante tiene componentes polares variables (Cap. 5)
function fig_campo_constante()
    v = Vista(-0.6, 3.8, -0.7, 3.4; s = 90)
    r = 2.6
    s = ejes(v)
    s *= linea(v, arco(r, 0, π / 2); color = MALLA, w = 1.2)
    for θ in (0.0, 0.4, 0.8, 1.2, 1.5)
        P = (r * cos(θ), r * sin(θ))
        c = cos(θ)            # V^r (componente sobre g₁)
        t = -sin(θ) / r       # V^θ (componente sobre g₂)
        B = base_polar(r, θ)
        A = P .+ c .* B[:, 1]
        s *= flecha(v, P, A; color = AZUL, w = 2, dash = "")
        s *= flecha(v, A, A .+ t .* B[:, 2]; color = VERDE, w = 2)
        s *= flecha(v, P, P .+ (1.0, 0.0); color = AMBAR, w = 3.2)
        s *= punto(v, P; r = 3)
    end
    s *= texto(X(v, (1.6, -0.55)), Y(v, (1.6, -0.55)), "V constante (ámbar) = componente radial (azul) + tangencial (verde)"; cursiva = false, color = GRIS, ancla = "middle", tam = 13)
    guardar("campo-constante-polares", "Un campo vectorial constante visto en polares: sus componentes Vʳ y Vᶿ cambian de un punto a otro",
            ancho(v), alto(v), s)
end

# 7. Coordenadas esféricas sobre una superficie (Cap. 5, puente a la Parte II)
function fig_esfera()
    az, el = 1.25, 0.4
    d = (cos(el) * cos(az), cos(el) * sin(az), sin(el))
    proy(p) = (-sin(az) * p[1] + cos(az) * p[2],
               -sin(el) * cos(az) * p[1] - sin(el) * sin(az) * p[2] + cos(el) * p[3])
    visible(p) = dot(p, d) > 0
    pos(θ, φ) = (sin(θ) * cos(φ), sin(θ) * sin(φ), cos(θ))
    v = Vista(-1.25, 1.9, -1.25, 1.25; s = 150)
    s = "<circle cx=\"$(f(X(v, (0, 0))))\" cy=\"$(f(Y(v, (0, 0))))\" r=\"$(f(150))\" fill=\"#f8fafc\" stroke=\"$GRIS\" stroke-width=\"1.5\"/>\n"
    function trazo(curva, color)
        seg = Tuple{Float64,Float64}[]
        out = ""
        for p in curva
            if visible(p)
                push!(seg, proy(p))
            elseif !isempty(seg)
                out *= linea(v, seg; color, w = 1.2); seg = Tuple{Float64,Float64}[]
            end
        end
        isempty(seg) || (out *= linea(v, seg; color, w = 1.2))
        out
    end
    for θ in range(π / 6, 5π / 6; length = 5)
        s *= trazo([pos(θ, φ) for φ in range(0, 2π; length = 120)], AZUL)
    end
    for φ in range(0, 2π; length = 13)[1:12]
        s *= trazo([pos(θ, φ) for θ in range(0, π; length = 80)], VERDE)
    end
    θ0, φ0 = 1.05, 0.55
    P = pos(θ0, φ0)
    gθ = (cos(θ0) * cos(φ0), cos(θ0) * sin(φ0), -sin(θ0))
    gφ = (-sin(φ0), cos(φ0), 0.0)
    n = P
    mas(a, b, k) = a .+ k .* b
    sp = proy(P)
    s *= flecha(v, sp, proy(mas(P, gθ, 0.55)); color = AZUL, w = 3, etiqueta = "g$(SUB("θ"))/r", dx = 6, dy = 16)
    s *= flecha(v, sp, proy(mas(P, gφ, 0.55)); color = VERDE, w = 3, etiqueta = "g$(SUB("φ"))/(r sin θ)", dx = 6, dy = -6)
    s *= flecha(v, sp, proy(mas(P, n, 0.55)); color = VIOLETA, w = 3, etiqueta = "n", dx = 6, dy = -4)
    s *= punto(v, sp)
    guardar("esfera-coordenadas", "Coordenadas esféricas sobre una esfera: base tangente (g_θ, g_φ) y normal n en un punto",
            ancho(v), alto(v), s)
end

# 4b. El mismo dθ recorre más distancia a mayor r (Cap. 4)
function fig_arcos()
    v = Vista(-0.3, 4.6, -0.3, 3.4; s = 80)
    s = ejes(v)
    for k in 1:4
        s *= linea(v, arco(float(k), 0, π / 2); color = MALLA, w = 1)
    end
    t0, dt = 0.35, 0.5
    for (r, col) in ((1.2, AZUL), (3.0, VERDE))
        s *= linea(v, rayo(t0, 0, 4.2); color = GRIS, w = 1, dash = "4 3")
        s *= linea(v, rayo(t0 + dt, 0, 4.2); color = GRIS, w = 1, dash = "4 3")
        s *= linea(v, arco(r, t0, t0 + dt; n = 30); color = col, w = 5)
        m = (r * cos(t0 + dt / 2), r * sin(t0 + dt / 2))
        s *= textov(v, m .+ (0.15, 0.05), "ds = r dθ = $(r) dθ"; color = col, tam = 14)
    end
    s *= textov(v, (0.55, 0.3), "dθ"; color = GRIS)
    guardar("metrica-arcos", "El mismo incremento dθ recorre un arco de longitud r dθ, mayor cuanto mayor es r",
            ancho(v), alto(v), s)
end

# 0a. Ejes cartesianos girados: el mismo vector, otras componentes (tema A2)
function fig_ejes_girados()
    v = Vista(-2.6, 5.6, -0.9, 4.9; s = 70)
    α = π / 6
    e1 = (cos(α), sin(α)); e2 = (-sin(α), cos(α))
    V = (3.0, 4.0)
    Vp = (V[1] * e1[1] + V[2] * e1[2], V[1] * e2[1] + V[2] * e2[2])       # componentes en los ejes girados
    @assert hypot(Vp...) ≈ hypot(V...) atol = 1e-12                        # la norma no cambia
    @assert all(isapprox.((Vp[1] * e1[1] + Vp[2] * e2[1], Vp[1] * e1[2] + Vp[2] * e2[2]), V; atol = 1e-12))
    s = ""
    s *= flecha(v, (0, 0), (5.3, 0); color = GRIS, w = 1.6, etiqueta = "x", dx = 4, dy = 16)
    s *= flecha(v, (0, 0), (0, 4.6); color = GRIS, w = 1.6, etiqueta = "y", dx = 8, dy = 6)
    s *= flecha(v, (0, 0), 5.2 .* e1; color = NARANJA, w = 1.6, dash = "6 4", etiqueta = "x′", dx = 4, dy = -8)
    s *= flecha(v, (0, 0), 4.0 .* e2; color = NARANJA, w = 1.6, dash = "6 4", etiqueta = "y′", dx = -22, dy = -4)
    s *= linea(v, [V, (V[1], 0.0)]; color = GRIS, w = 1.2, dash = "2 4")
    s *= linea(v, [V, (0.0, V[2])]; color = GRIS, w = 1.2, dash = "2 4")
    s *= linea(v, [V, Vp[1] .* e1]; color = NARANJA, w = 1.2, dash = "2 4")
    s *= linea(v, [V, Vp[2] .* e2]; color = NARANJA, w = 1.2, dash = "2 4")
    s *= flecha(v, (0, 0), V; color = VIOLETA, w = 3.4, etiqueta = "V", dx = 8, dy = -2)
    s *= textov(v, (3.15, -0.55), "V = (3, 4)  en  (x, y)"; color = GRIS, tam = 13, cursiva = false)
    s *= textov(v, (1.2, 4.55), "V = ($(round(Vp[1]; digits = 2)); $(round(Vp[2]; digits = 2)))  en  (x′, y′)"; color = NARANJA, tam = 13, cursiva = false)
    s *= punto(v, (0, 0))
    guardar("ejes-girados", "El mismo vector V en dos sistemas cartesianos girados 30 grados: cambian las componentes, no el vector ni su longitud",
            ancho(v), alto(v), s)
end

# 0b. Celda curvilínea y flujo: divergencia (tema B5)
function fig_celda_divergencia()
    v = Vista(-0.2, 4.4, -0.2, 3.6; s = 100)
    r1, r2, t1, t2 = 1.7, 2.9, 0.35, 0.95
    s = ejes(v; ox = 0.0, oy = 0.0, ex = 4.3, ey = 3.5)
    for k in 1:4
        s *= linea(v, arco(float(k) * 0.9, 0, π / 2); color = MALLA, w = 1)
    end
    for a in range(0, π / 2; length = 8)
        s *= linea(v, rayo(a, 0, 4.3); color = MALLA, w = 1)
    end
    celda = vcat(arco(r1, t1, t2; n = 30), reverse(arco(r2, t1, t2; n = 30)))
    s *= linea(v, vcat(celda, [celda[1]]); color = AZUL, w = 2.4, fill = AZUL, op = 0.18)
    P(r, t) = (r * cos(t), r * sin(t))
    tm, rm = (t1 + t2) / 2, (r1 + r2) / 2
    # normales salientes en el punto medio de cada cara
    for (p, dir, et, dx, dy) in ((P(r2, tm), P(1, tm), "r₂ dθ", 8, -6),
                                 (P(r1, tm), (-cos(tm), -sin(tm)), "r₁ dθ", -62, 14),
                                 (P(rm, t2), (-sin(t2), cos(t2)), "dr", -34, -8),
                                 (P(rm, t1), (sin(t1), -cos(t1)), "dr", 6, 16))
        s *= flecha(v, p, (p[1] + 0.5 * dir[1], p[2] + 0.5 * dir[2]); color = VIOLETA, w = 2.4, etiqueta = et, dx = dx, dy = dy)
    end
    s *= textov(v, (0.3, 3.3), "flujo neto por las 4 caras = div V · (r dr dθ)"; color = GRIS, tam = 13, cursiva = false)
    guardar("celda-divergencia", "Celda polar dr por d theta con las normales salientes de sus cuatro caras: el flujo neto de V a través de ellas es la divergencia por el área",
            ancho(v), alto(v), s)
end

# 0c. Deformación de un cuadrado unidad (tema D1) -----------------------------------------
function fig_deformacion()
    F = [1.15 0.25; 0.0 0.95]
    E = green_lagrange(Matrix(1.0I, 2, 2), cauchy_green(F))
    @assert E ≈ [0.16125 0.14375; 0.14375 -0.0175] atol = 1e-12
    v = Vista(-0.5, 2.3, -0.4, 1.6; s = 120)
    C = [(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)]
    D = [Tuple(F * [p...]) for p in C]
    s = ejes(v; ox = 0.0, oy = 0.0, ex = 2.2, ey = 1.55)
    s *= linea(v, vcat(C, [C[1]]); color = GRIS, w = 1.6, dash = "6 4", fill = "#f3f4f6")
    s *= linea(v, vcat(D, [D[1]]); color = AZUL, w = 2.6, fill = AZUL, op = 0.18)
    for k in 2:4
        s *= flecha(v, C[k], D[k]; color = NARANJA, w = 1.8)
    end
    s *= flecha(v, (0.0, 0.0), (1.0, 0.0); color = GRIS, w = 2.2, etiqueta = "g₁", dx = 4, dy = 16)
    s *= flecha(v, (0.0, 0.0), (0.0, 1.0); color = GRIS, w = 2.2, etiqueta = "g₂", dx = -26, dy = 4)
    s *= flecha(v, (0.0, 0.0), D[2]; color = AZUL, w = 3, etiqueta = "G₁", dx = 20, dy = -8)
    s *= flecha(v, (0.0, 0.0), D[4]; color = AZUL, w = 3, etiqueta = "G₂", dx = 6, dy = -4)
    guardar("deformacion-cuadrado", "Un cuadrado de referencia (gris discontinuo) se deforma en un paralelogramo (azul) con el gradiente F; las bases g1, g2 pasan a G1, G2",
            ancho(v), alto(v), s)
end

# 0d. Elemento con tensiones (tema D2) --------------------------------------------------
function fig_elemento_tensiones()
    v = Vista(-1.2, 2.2, -1.2, 2.2; s = 105)
    s = linea(v, [(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0), (0.0, 0.0)]; color = GRIS, w = 2, fill = "#eef5fb")
    a = 0.55
    # tensiones normales (salientes en cada cara con σ > 0)
    s *= flecha(v, (1.0, 0.5), (1.0 + a, 0.5); color = AZUL, w = 3, etiqueta = "σ¹¹", dx = 4, dy = -8)
    s *= flecha(v, (0.0, 0.5), (-a, 0.5); color = AZUL, w = 3)
    s *= flecha(v, (0.5, 1.0), (0.5, 1.0 + a); color = VERDE, w = 3, etiqueta = "σ²²", dx = 8, dy = 4)
    s *= flecha(v, (0.5, 0.0), (0.5, -a); color = VERDE, w = 3)
    # tensiones tangenciales σ¹² = σ²¹
    s *= flecha(v, (1.0, 0.8), (1.0, 0.8 + a * 0.8); color = NARANJA, w = 2.6, etiqueta = "σ¹²", dx = 6, dy = -2)
    s *= flecha(v, (0.0, 0.2), (0.0, 0.2 - a * 0.8); color = NARANJA, w = 2.6)
    s *= flecha(v, (0.2, 1.0), (0.2 + a * 0.8, 1.0); color = NARANJA, w = 2.6, etiqueta = "σ²¹", dx = 4, dy = -8)
    s *= flecha(v, (0.8, 0.0), (0.8 - a * 0.8, 0.0); color = NARANJA, w = 2.6)
    s *= texto(X(v, (0.5, 0.5)), Y(v, (0.5, 0.5)) + 5, "dV"; ancla = "middle", color = GRIS, tam = 15)
    s *= textov(v, (-1.0, -0.95), "Equilibrio de momentos: σ¹² = σ²¹"; color = GRIS, tam = 13, cursiva = false)
    guardar("elemento-tensiones", "Elemento diferencial con sus tensiones normales sigma11 y sigma22 y tangenciales sigma12 y sigma21 sobre las cuatro caras",
            ancho(v), alto(v), s)
end

# 0e. Ley de Hooke y energía de deformación (tema D2) ------------------------------------------
function fig_hooke()
    v = Vista(-0.5, 5.4, -0.6, 3.6; s = 100)
    s = ejes(v; ox = 0.0, oy = 0.0, ex = 5.2, ey = 3.4, lx = "ε", ly = "σ")
    εy = 2.6; E = 1.0
    s *= linea(v, [(0.0, 0.0), (εy, εy * E)]; color = AZUL, w = 3)
    cola = [(εy + x, εy * E + 0.55 * (1 - exp(-1.6 * x))) for x in range(0, 2.2; length = 30)]
    s *= linea(v, cola; color = AZUL, w = 2.4, dash = "6 4")
    ε0 = 1.7
    s *= linea(v, [(0.0, 0.0), (ε0, 0.0), (ε0, ε0 * E), (0.0, 0.0)]; color = NARANJA, w = 2, fill = NARANJA, op = 0.25)
    s *= linea(v, [(ε0, 0.0), (ε0, ε0 * E)]; color = GRIS, w = 1.2, dash = "3 3")
    s *= textov(v, (1.55, 0.5), "W = ½ σ ε"; color = NARANJA, tam = 14, cursiva = false)
    s *= textov(v, (0.5, 1.15), "pendiente E"; color = AZUL, tam = 14, cursiva = false)
    s *= textov(v, (εy + 0.1, εy * E - 0.3), "límite elástico"; color = GRIS, tam = 13, cursiva = false)
    guardar("hooke-uniaxial", "Ley de Hooke uniaxial: tension proporcional a la deformacion hasta el limite elastico, con la energia de deformacion como area del triangulo", ancho(v), alto(v), s)
end

println("Generando figuras:")
fig_vector_dos_bases(); fig_jacobiano(); fig_galeria(); fig_fisicas()
fig_ejes_girados(); fig_celda_divergencia(); fig_deformacion(); fig_elemento_tensiones(); fig_hooke(); fig_arcos(); fig_christoffel(); fig_campo_constante(); fig_esfera()
