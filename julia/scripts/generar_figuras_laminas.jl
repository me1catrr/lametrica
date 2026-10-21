# Figuras del bloque D (elasticidad y teoría de láminas) en figures/svg/*.svg.
#   julia --project=. julia/scripts/generar_figuras_laminas.jl
include(joinpath(@__DIR__, "figuras_lib.jl"))

rot(p, α) = (cos(α) * p[1] - sin(α) * p[2], sin(α) * p[1] + cos(α) * p[2])
suma(a, b) = (a[1] + b[1], a[2] + b[2])
mul(k, a) = (k * a[1], k * a[2])

# Perfil de una lámina (sección transversal): curva media y(x), director en cada punto
function banda(v, X, Y, dir, t, color; relleno = "none", op = 1.0, w = 2.4, discontinuo = "")
    pts_sup = [suma((X[i], Y[i]), mul(t / 2, dir[i])) for i in eachindex(X)]
    pts_inf = [suma((X[i], Y[i]), mul(-t / 2, dir[i])) for i in eachindex(X)]
    linea(v, vcat(pts_sup, reverse(pts_inf), [pts_sup[1]]); color, w, fill = relleno, op, dash = discontinuo)
end

# 1. Cinemática de la lámina: referencia (gris) y deformada con director no normal (tema D3) ----------
function fig_cinematica()
    v = Vista(-0.3, 4.9, -0.7, 3.3; s = 100)
    xs = range(0.0, 4.2; length = 60)
    y0(x) = 1.9 + 0.5 * sin(x * 0.9)
    dy0(x) = 0.45 * cos(x * 0.9)
    n0(x) = (-dy0(x), 1.0) ./ hypot(dy0(x), 1.0)
    X0 = collect(xs); Y0 = y0.(xs); N0 = [n0(x) for x in xs]
    t = 0.42
    s = banda(v, X0, Y0, N0, t, GRIS; relleno = "#f3f4f6", op = 0.9, w = 1.6, discontinuo = "6 4")
    # deformación: desplazamiento de la superficie media y director A₃ rotado y alargado (no normal)
    u(x) = (0.18 * sin(x * 1.2) + 0.1, -0.55 + 0.15 * cos(x * 0.8))
    φ(x) = 0.22 * sin(0.9x + 0.5) + 0.15
    X1 = [x + u(x)[1] for x in xs]; Y1 = [y0(x) + u(x)[2] for x in xs]
    A3 = [suma(mul(1 + 0.08 * sin(x), n0(x)), mul(φ(x), (n0(x)[2], -n0(x)[1]))) for x in xs]
    s *= banda(v, X1, Y1, A3, t, AZUL; relleno = AZUL, op = 0.16, w = 2.4)
    for k in 1:6:length(xs)
        s *= linea(v, [suma((X0[k], Y0[k]), mul(t / 2, N0[k])), suma((X0[k], Y0[k]), mul(-t / 2, N0[k]))]; color = GRIS, w = 1.2, dash = "3 3")
        s *= linea(v, [suma((X1[k], Y1[k]), mul(t / 2, A3[k])), suma((X1[k], Y1[k]), mul(-t / 2, A3[k]))]; color = VIOLETA, w = 1.8)
    end
    k = 25
    s *= flecha(v, (X0[k], Y0[k]), (X1[k], Y1[k]); color = NARANJA, w = 2.2, etiqueta = "u", dx = 6, dy = 14)
    s *= flecha(v, (X1[k], Y1[k]), suma((X1[k], Y1[k]), mul(0.7, A3[k])); color = VIOLETA, w = 2.8, etiqueta = "A₃", dx = 6, dy = -4)
    s *= flecha(v, (X0[k], Y0[k]), suma((X0[k], Y0[k]), mul(0.7, N0[k])); color = GRIS, w = 2.2, etiqueta = "n̂", dx = 6, dy = -4)
    s *= textov(v, (0.0, -0.5), "referencia (gris) y deformada (azul): la línea θ³ pasa a ser una recta de director A₃"; color = GRIS, tam = 13, cursiva = false)
    guardar("cinematica-lamina", "Sección de una lámina: la línea normal de la configuración de referencia se transforma en una recta con director A3, no necesariamente normal ni unitario",
            ancho(v), alto(v), s)
end

# 2 y 3. Kirchhoff–Love y Reissner–Mindlin en una sección (temas D4 y D5) ----------------------------
function fig_perfil(nombre, titulo, rm::Bool)
    v = Vista(-0.2, 4.4, -0.7, 2.6; s = 105)
    xs = range(0.0, 3.8; length = 60)
    w(x) = 0.5 * (x / 3.8)^2 * 2.2 + 0.0
    dw(x) = 2 * 0.5 * x / 3.8^2 * 2.2
    t = 0.5
    N(x) = (-dw(x), 1.0) ./ hypot(dw(x), 1.0)
    y00 = 0.4
    X0 = collect(xs); Y0 = fill(y00, length(xs)); D0 = [(0.0, 1.0) for _ in xs]
    s = banda(v, X0, Y0, D0, t, GRIS; relleno = "#f3f4f6", w = 1.5, discontinuo = "6 4")
    X1 = collect(xs); Y1 = [y00 + w(x) for x in xs]
    γ(x) = rm ? 0.45 * (1 - x / 3.8) + 0.05 : 0.0         # cortante transversal (ángulo entre director y normal)
    D1 = [rot(N(x), -γ(x)) for x in xs]
    s *= banda(v, X1, Y1, D1, t, AZUL; relleno = AZUL, op = 0.16, w = 2.4)
    for k in 1:6:length(xs)
        s *= linea(v, [suma((X1[k], Y1[k]), mul(t / 2, D1[k])), suma((X1[k], Y1[k]), mul(-t / 2, D1[k]))]; color = VIOLETA, w = 2)
        rm && (s *= linea(v, [suma((X1[k], Y1[k]), mul(t / 2, N(xs[k]))), suma((X1[k], Y1[k]), mul(-t / 2, N(xs[k])))]; color = NARANJA, w = 1.2, dash = "3 3"))
    end
    k = 31
    s *= flecha(v, (X1[k], Y1[k]), suma((X1[k], Y1[k]), mul(0.75, D1[k])); color = VIOLETA, w = 3, etiqueta = rm ? "director" : "n̂", dx = 8, dy = 14)
    if rm
        s *= flecha(v, (X1[k], Y1[k]), suma((X1[k], Y1[k]), mul(0.75, N(xs[k]))); color = NARANJA, w = 2.2, dash = "5 3", etiqueta = "normal a la deformada", dx = -150, dy = -6)
        s *= textov(v, (X1[k] + 0.35, Y1[k] + 0.25), "γ"; color = NARANJA, tam = 16)
    end
    s *= textov(v, (0.0, 2.35), titulo; color = GRIS, tam = 13, cursiva = false)
    guardar(nombre, titulo, ancho(v), alto(v), s)
end

# 4. Los tres modos de deformación: extensión, flexión y cortante (tema D6) -----------------------------
function fig_modos()
    paneles = Any[]
    for (nom, tipo) in (("extensión γ⁰", :ext), ("flexión γ¹", :flex), ("cortante γ", :cort))
        v = Vista(-0.3, 3.1, -0.8, 1.7; s = 90)
        s = ""
        ref = [(0.0, 0.0), (2.4, 0.0), (2.4, 0.5), (0.0, 0.5)]
        s *= linea(v, vcat(ref, [ref[1]]); color = GRIS, w = 1.5, dash = "5 4", fill = "#f3f4f6")
        if tipo == :ext
            def = [(0.0, 0.0), (2.9, 0.0), (2.9, 0.5), (0.0, 0.5)]
            s *= linea(v, vcat(def, [def[1]]); color = AZUL, w = 2.4, fill = AZUL, op = 0.18)
            s *= flecha(v, (2.4, 0.25), (2.9, 0.25); color = NARANJA, w = 2.4)
        elseif tipo == :flex
            R = 3.2
            xs = range(0.0, 2.4; length = 40)
            arriba = [(R + 0.25) * sin(x / R) |> y -> (y, R - (R + 0.25) * cos(x / R) - 0.0) for x in xs]
            abajo = [(R - 0.25) * sin(x / R) |> y -> (y, R - (R - 0.25) * cos(x / R)) for x in xs]
            pts = vcat([(p[1], p[2] * 0.0 + (R - sqrt(max(R^2 - p[1]^2, 0))) * 0.0) for p in abajo[1:1]], [])
            sup = [((R + 0.25) * sin(x / R), -(R + 0.25) * cos(x / R) + R + 0.25) for x in xs]
            inf = [((R - 0.25) * sin(x / R), -(R - 0.25) * cos(x / R) + R + 0.25) for x in xs]
            s *= linea(v, vcat(sup, reverse(inf), [sup[1]]); color = AZUL, w = 2.4, fill = AZUL, op = 0.18)
            for k in 1:10:length(xs)
                s *= linea(v, [sup[k], inf[k]]; color = VIOLETA, w = 1.6)
            end
        else
            def = [(0.0, 0.0), (2.4, 0.0), (2.4 + 0.45, 0.5), (0.45, 0.5)]
            s *= linea(v, vcat(def, [def[1]]); color = AZUL, w = 2.4, fill = AZUL, op = 0.18)
            s *= linea(v, [(0.225, 0.25), (0.225, 0.25)]; color = AZUL)
            for x in 0.3:0.6:2.4
                s *= linea(v, [(x, 0.0), (x + 0.45, 0.5)]; color = VIOLETA, w = 1.6)
            end
        end
        s *= textov(v, (1.4, -0.6), nom; ancla = "middle", cursiva = false, color = "#1f2937", tam = 14)
        push!(paneles, (v, s))
    end
    H = maximum(alto(p[1]) for p in paneles); cuerpo = ""; x = 0.0
    for (vv, ss) in paneles
        cuerpo *= "<g transform=\"translate($(f(x)),$(f(H - alto(vv))))\">\n$ss</g>\n"
        x += ancho(vv) + 4
    end
    guardar("modos-deformacion-lamina", "Tres modos de deformación de una lámina: extensión de la superficie media, flexión (cambio de curvatura) y cortante transversal", x, H, cuerpo)
end

# 5. Distribución de tensiones en el espesor: membrana y flexión (tema D7) -----------------------------
function fig_espesor()
    v = Vista(-0.6, 6.6, -1.4, 1.5; s = 90)
    t = 2.0
    s = ejes(v; ox = 0.0, oy = -1.1, ex = 5.2, ey = 1.3, lx = "σ", ly = "θ³")
    s = ""
    caja = [(0.0, -1.0), (0.0, 1.0)]
    for (x0, nombre, f) in ((0.3, "membrana: σ = N/t", _ -> 0.9), (2.9, "flexión: σ = 12 M θ³ / t³", y -> 0.9 * y), (5.2, "suma", y -> 0.9 + 0.5 * y))
        s *= linea(v, [(x0, -1.0), (x0, 1.0)]; color = GRIS, w = 1.8)
        puntos = [(x0, -1.0), (x0 + f(-1.0), -1.0), (x0 + f(1.0), 1.0), (x0, 1.0)]
        s *= linea(v, vcat(puntos, [puntos[1]]); color = nombre == "suma" ? VERDE : AZUL, w = 2.2, fill = nombre == "suma" ? VERDE : AZUL, op = 0.2)
        for y in -0.8:0.4:0.8
            s *= flecha(v, (x0, y), (x0 + f(y), y); color = nombre == "suma" ? VERDE : AZUL, w = 1.4, tam = 6)
        end
        s *= textov(v, (x0 - 0.1, -1.3), nombre; color = "#1f2937", tam = 12, cursiva = false)
    end
    guardar("tensiones-espesor", "Distribución de la tensión en el espesor: constante para la membrana, lineal para la flexión, y su suma", ancho(v), alto(v), s)
end

# 6. Árbol de principios variacionales (tema D8) -----------------------------------------------------
function fig_principios()
    v = Vista(0.0, 8.8, 0.0, 3.8; s = 70)
    caja(x, y, w, h, color, t1, t2) = linea(v, [(x, y), (x + w, y), (x + w, y + h), (x, y + h), (x, y)]; color, w = 2.4, fill = color, op = 0.13) *
        textov(v, (x + w / 2, y + h * 0.62), t1; ancla = "middle", cursiva = false, color, tam = 14) *
        textov(v, (x + w / 2, y + h * 0.28), t2; ancla = "middle", cursiva = false, color = "#1f2937", tam = 12)
    s = caja(0.2, 2.3, 2.6, 1.3, AZUL, "Energía potencial", "campos: u")
    s *= caja(3.1, 2.3, 2.6, 1.3, VERDE, "Hellinger–Reissner", "campos: u, σ")
    s *= caja(6.0, 2.3, 2.6, 1.3, VIOLETA, "Hu–Washizu", "campos: u, ε, σ")
    s *= flecha(v, (2.8, 2.95), (3.1, 2.95); color = GRIS, w = 2)
    s *= flecha(v, (5.7, 2.95), (6.0, 2.95); color = GRIS, w = 2)
    s *= textov(v, (0.2, 1.7), "Se añaden campos y multiplicadores de Lagrange:"; color = "#1f2937", tam = 13, cursiva = false)
    s *= textov(v, (0.2, 1.3), "ε − ε(u) = 0 (compatibilidad) y σ = ∂W/∂ε (constitutiva)."; color = "#1f2937", tam = 13, cursiva = false)
    s *= textov(v, (0.2, 0.7), "Cada principio se hace estacionario: da equilibrio, compatibilidad y constitutiva."; color = GRIS, tam = 12, cursiva = false)
    guardar("principios-variacionales", "Tres principios variacionales de la elasticidad: energía potencial (campo u), Hellinger-Reissner (u y sigma) y Hu-Washizu (u, epsilon y sigma)", ancho(v), alto(v), s)
end

println("Generando figuras del bloque D:")
fig_cinematica(); fig_perfil("kirchhoff-love", "Kirchhoff–Love: el director es la normal a la deformada", false)
fig_perfil("reissner-mindlin", "Reissner–Mindlin: el director gira y forma un ángulo γ con la normal", true)
fig_modos(); fig_espesor(); fig_principios()
