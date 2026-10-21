# Figuras del bloque E (elementos finitos de lámina) en figures/svg/*.svg. Todas calculadas con Geometria.
#   julia --project=. julia/scripts/generar_figuras_fem.jl
include(joinpath(@__DIR__, "figuras_lib.jl"))
include(joinpath(@__DIR__, "figuras_fem_lib.jl"))
using SparseArrays

# 1. El método de elementos finitos en una barra (tema E1) ---------------------------------------------
function fig_barra()
    n = 4; L = 1.0
    ex(x) = x * (1 - x / 2)                    # EA u'' = −q, u(0)=0, u'(L)=0, q L²/EA = 1
    xs = range(0, L; length = 80)
    v = Vista(-0.12, 1.2, -0.12, 0.62; s = 400, sy = 560)
    nodos = collect(range(0, L; length = n + 1))
    s = ejes(v; ox = 0.0, oy = 0.0, ex = 1.15, ey = 0.58, lx = "x/L", ly = "u")
    # función de forma del nodo 3 (sombreada)
    k = 3; h = L / n
    hat = [(nodos[k-1], 0.0), (nodos[k], 0.2), (nodos[k+1], 0.0)]
    s *= linea(v, vcat(hat, [hat[1]]); color = VIOLETA, w = 2.0, fill = VIOLETA, op = 0.14)
    s *= textov(v, (nodos[k] + 0.01, 0.215), "N$(SUB("k"))"; color = VIOLETA, tam = 14)
    s *= linea(v, [(x, ex(x)) for x in xs]; color = AZUL, w = 3.0)
    s *= linea(v, [(x, ex(x)) for x in nodos]; color = NARANJA, w = 2.6)
    for x in nodos
        s *= punto(v, (x, ex(x)); color = NARANJA, r = 5.5)
        s *= linea(v, [(x, -0.012), (x, 0.012)]; color = GRIS, w = 1.3)
    end
    s *= textov(v, (0.30, 0.54), "solución exacta"; color = AZUL, tam = 13, cursiva = false)
    s *= textov(v, (0.30, 0.50), "elementos finitos (4 elementos)"; color = NARANJA, tam = 13, cursiva = false)
    s *= textov(v, (0.04, -0.075), "En una barra, la solución de Galerkin coincide con la exacta en los nodos"; color = GRIS, tam = 12.5, cursiva = false)
    guardar("fem-barra", "Barra cargada resuelta con cuatro elementos lineales: la solución de elementos finitos coincide con la exacta en los nodos y es una poligonal entre ellos", ancho(v), alto(v), s)
end

# 2. El cuadrilátero isoparamétrico (tema E2) ----------------------------------------------------------
function fig_isoparam()
    gp = 1 / sqrt(3)
    vL = Vista(-1.5, 1.5, -1.5, 1.5; s = 90); vR = Vista(-0.3, 4.0, -0.3, 3.2; s = 90)
    sL = linea(vL, [(-1, -1), (1, -1), (1, 1), (-1, 1), (-1, -1)]; color = AZUL, w = 2.4, fill = AZUL, op = 0.10)
    sL *= ejes(vL; ox = 0.0, oy = 0.0, ex = 1.45, ey = 1.45, lx = "ξ", ly = "η")
    for (i, (a, b)) in enumerate(((-1, -1), (1, -1), (1, 1), (-1, 1)))
        sL *= punto(vL, (a, b); color = AZUL, r = 5)
        sL *= textov(vL, (a * 1.0 + (a < 0 ? -0.22 : 0.08), b * 1.0 + (b < 0 ? -0.2 : 0.1)), string(i); color = AZUL, tam = 15)
    end
    for a in (-gp, gp), b in (-gp, gp)
        sL *= punto(vL, (a, b); color = NARANJA, r = 5.5)
    end
    sL *= textov(vL, (0.0, -1.38), "plano de referencia"; ancla = "middle", color = GRIS, tam = 13, cursiva = false)
    X = [(0.2, 0.1), (3.4, 0.4), (3.0, 2.6), (0.5, 2.9)]
    N(ξ, η) = [(1 - ξ) * (1 - η), (1 + ξ) * (1 - η), (1 + ξ) * (1 + η), (1 - ξ) * (1 + η)] ./ 4
    mapa(ξ, η) = (sum(N(ξ, η)[k] * X[k][1] for k in 1:4), sum(N(ξ, η)[k] * X[k][2] for k in 1:4))
    sR = linea(vR, vcat(X, [X[1]]); color = AZUL, w = 2.4, fill = AZUL, op = 0.10)
    for t in (-0.5, 0.0, 0.5)
        sR *= linea(vR, [mapa(t, -1), mapa(t, 1)]; color = MALLA, w = 1.2)
        sR *= linea(vR, [mapa(-1, t), mapa(1, t)]; color = MALLA, w = 1.2)
    end
    for (i, p) in enumerate(X)
        sR *= punto(vR, p; color = AZUL, r = 5)
        sR *= textov(vR, (p[1] + (p[1] < 1.5 ? -0.25 : 0.1), p[2] + (p[2] < 1.5 ? -0.25 : 0.12)), string(i); color = AZUL, tam = 15)
    end
    for a in (-gp, gp), b in (-gp, gp)
        sR *= punto(vR, mapa(a, b); color = NARANJA, r = 5.5)
    end
    sR *= textov(vR, (1.9, -0.2), "elemento real: x = Σ N$(SUB("k"))(ξ,η) x$(SUB("k"))"; ancla = "middle", color = GRIS, tam = 13, cursiva = false)
    H = max(alto(vL), alto(vR)); w1 = ancho(vL)
    cuerpo = "<g transform=\"translate(0,$(f(H - alto(vL))))\">\n$sL</g>\n<g transform=\"translate($(f(w1 + 20)),$(f(H - alto(vR))))\">\n$sR</g>\n"
    guardar("cuadrilatero-isoparametrico", "El cuadrado de referencia con sus cuatro puntos de Gauss se transforma en el cuadrilátero real mediante las funciones de forma bilineales", w1 + ancho(vR) + 20, H, cuerpo)
end

# 3. El elemento de lámina de cuatro nodos sobre una superficie curva (tema E3) --------------------------
function fig_elemento()
    R = 1.0; r = cil_x(R); cam = Camara(deg2rad(-35), deg2rad(25))
    nodos, conn = malla_rectangular((0.0, 1.2), (-0.55, 0.55), 1, 1)
    sub, subc = malla_rectangular((0.0, 1.2), (-0.55, 0.55), 6, 6)
    v = vista_fe(cam, r, nodos; s = 150, margen = 0.55)
    s = superficie_fe(v, cam, r, sub, subc, nothing; malla = true)
    # contorno del elemento
    borde = vcat([(t, -0.55) for t in range(0, 1.2; length = 20)], [(1.2, t) for t in range(-0.55, 0.55; length = 20)],
                 [(t, 0.55) for t in range(1.2, 0; length = 20)], [(0.0, t) for t in range(0.55, -0.55; length = 20)])
    s *= curva3(v, cam, [r(p) for p in borde]; color = AZUL, w = 3.4)
    for k in 1:4
        P = r(nodos[:, conn[k, 1]]); s *= punto(v, proy(cam, P); color = NARANJA, r = 6)
    end
    # nodo 1: tres desplazamientos y dos giros (flechas)
    c = [conn[1, 1], conn[2, 1], conn[3, 1], conn[4, 1]]
    for (k, etq) in enumerate(("1", "2", "3", "4"))
        P = r(nodos[:, c[k]]); p = proy(cam, P)
        s *= textov(v, (p[1] + (k in (1, 4) ? -0.14 : 0.07), p[2] + (k in (1, 2) ? -0.11 : 0.06)), etq; color = NARANJA, tam = 16)
    end
    g = geometria_punto(r, nodos[:, c[1]])
    P0 = r(nodos[:, c[1]])
    a1 = g.A[:, 1] ./ norm(g.A[:, 1]); a2 = g.A[:, 2] ./ norm(g.A[:, 2])
    s *= flecha3(v, cam, P0, P0 .+ 0.42 .* a1; color = AZUL, w = 3, etiqueta = "u₁", dx = 4, dy = 18)
    s *= flecha3(v, cam, P0, P0 .+ 0.42 .* a2; color = AZUL, w = 3, etiqueta = "u₂", dx = 8, dy = -8)
    s *= flecha3(v, cam, P0, P0 .+ 0.45 .* g.n; color = VIOLETA, w = 3, etiqueta = "u₃", dx = 6, dy = -2)
    s *= flecha3(v, cam, P0 .+ 0.45 .* g.n, P0 .+ 0.45 .* g.n .+ 0.30 .* a1; color = NARANJA, w = 2.4, dash = "5 3", etiqueta = "φ₁", dx = 4, dy = -4)
    s *= flecha3(v, cam, P0 .+ 0.45 .* g.n, P0 .+ 0.45 .* g.n .+ 0.30 .* a2; color = NARANJA, w = 2.4, dash = "5 3", etiqueta = "φ₂", dx = -22, dy = -2)
    guardar("elemento-lamina-4nodos", "Elemento de lámina de cuatro nodos sobre una superficie curva: en cada nodo, tres desplazamientos u1, u2, u3 y dos giros phi1, phi2 del director", ancho(v), alto(v), s)
end

# 4. Mapa de las matrices deformación–desplazamiento (tema E4) --------------------------------------------
function fig_mapaH()
    R = 1.0; r = cil_x(R); t = 0.05
    X = [0.0 0.4 0.4 0.0; 0.0 0.0 0.4 0.4]
    X[1, :] .*= 1.0
    g, N, dN, dA, CE, CB, CS = punto_elemento(r, X, 0.3, -0.2, 1.0, 0.3, t)
    HE, HB, HS = matrices_H(g, N, dN)
    paneles = ((HE, "γ⁰: extensión (3×20)", ("γ⁰₁₁", "γ⁰₂₂", "2γ⁰₁₂")), (HB, "γ¹: flexión (3×20)", ("γ¹₁₁", "γ¹₂₂", "2γ¹₁₂")), (HS, "γ: cortante (2×20)", ("γ₁", "γ₂")))
    cel = 22.0; mx = 70.0; my = 40.0
    W = mx + 20cel + 20.0; Hh = my + 3cel + 28
    cuerpo = ""; yoff = 0.0
    H_total = 3 * (my + 3cel + 6) + 70
    nombres = ("u₁", "u₂", "u₃", "φ₁", "φ₂")
    for (M, tit, filas) in paneles
        mmax = maximum(abs, M) + 1e-30
        cuerpo *= texto(10, yoff + 20, tit; color = "#1f2937", tam = 14, cursiva = false)
        for (i, fl) in enumerate(filas), j in 1:20
            val = abs(M[i, j]) / mmax
            x = mx + (j - 1) * cel; y = yoff + my + (i - 1) * cel
            cuerpo *= "<rect x=\"$(f(x))\" y=\"$(f(y))\" width=\"$cel\" height=\"$cel\" fill=\"$(color_sec(val^0.6))\" stroke=\"#ffffff\" stroke-width=\"1\"/>\n"
            val < 1e-9 && (cuerpo *= "<line x1=\"$(f(x + 6))\" y1=\"$(f(y + cel / 2))\" x2=\"$(f(x + cel - 6))\" y2=\"$(f(y + cel / 2))\" stroke=\"$GRIS\" stroke-width=\"1\"/>\n")
        end
        for (i, fl) in enumerate(filas)
            cuerpo *= texto(mx - 8, yoff + my + (i - 1) * cel + 16, fl; color = "#1f2937", tam = 12, ancla = "end", cursiva = false)
        end
        for k in 1:4, c in 1:5
            cuerpo *= texto(mx + ((k - 1) * 5 + c - 1) * cel + cel / 2, yoff + my - 6, nombres[c]; color = c <= 3 ? AZUL : NARANJA, tam = 10, ancla = "middle", cursiva = false)
        end
        yoff += my + (length(filas)) * cel + 16
    end
    for k in 1:4
        x0 = mx + (k - 1) * 5 * cel
        cuerpo *= "<line x1=\"$(f(x0))\" y1=\"22\" x2=\"$(f(x0))\" y2=\"$(f(yoff - 10))\" stroke=\"$GRIS\" stroke-width=\"1.4\" stroke-dasharray=\"4 3\"/>\n"
        cuerpo *= texto(x0 + 5 * cel / 2, yoff + 6, "nodo $k"; color = GRIS, tam = 12, ancla = "middle", cursiva = false)
    end
    guardar("matrices-H", "Mapa de calor del valor absoluto de las matrices deformación-desplazamiento de un elemento sobre un cilindro: cada grupo de cinco columnas corresponde a un nodo", mx + 20cel + 16, yoff + 22, cuerpo)
end

# 5. Bloqueo (tema E5) -----------------------------------------------------------------------------------
function resultados_bloqueo()
    E, ν = 1.0e4, 0.3
    D(t) = E * t^3 / (12 * (1 - ν^2))
    wc(n, t, modo) = (p = placa_ss(n, t, modo); -p.u[gdl(nodo_en(p.nodos, [0.5, 0.5]), 3)])
    ns = [2, 4, 8, 16]
    conv = Dict(m => [wc(n, 0.01, m) / navier_centro(1.0, 1.0, D(0.01)) for n in ns] for m in (:desplazamientos, :reducida_selectiva, :subdominios))
    ts = [0.2, 0.1, 0.05, 0.02, 0.01, 0.005, 0.002]
    espesor = Dict(m => [wc(8, t, m) / navier_centro(1.0, 1.0, D(t)) for t in ts] for m in (:desplazamientos, :reducida_selectiva, :subdominios))
    (ns, conv, ts, espesor)
end

function fig_bloqueo()
    ns, conv, ts, esp = resultados_bloqueo()
    nombres = Dict(:desplazamientos => "desplazamientos (2×2)", :reducida_selectiva => "integración reducida selectiva", :subdominios => "subdominios (Hu–Washizu)")
    cols = Dict(:desplazamientos => NARANJA, :reducida_selectiva => VIOLETA, :subdominios => AZUL)
    dash = Dict(:desplazamientos => "", :reducida_selectiva => "7 4", :subdominios => "")
    grafica("bloqueo-convergencia", "Flecha central relativa frente al número de elementos por lado";
        series = [(nombres[m], ns, conv[m], cols[m], dash[m]) for m in (:desplazamientos, :reducida_selectiva, :subdominios)],
        xt = [(n, string(n)) for n in ns], yt = [(y, string(y)) for y in (0.0, 0.25, 0.5, 0.75, 1.0)],
        xlim = (1.5, 17), ylim = (0.0, 1.08), lx = "elementos por lado", ly = "w_centro / w_Navier",
        horizontales = [(1.0, "solución exacta", GRIS)], xlog = true, leyenda = :derecha,
        aria = "Convergencia de la flecha central de una placa delgada simplemente apoyada: el elemento de desplazamientos puros se bloquea, la integración reducida y los subdominios convergen")
    grafica("bloqueo-espesor", "Flecha central relativa frente al espesor";
        series = [(nombres[m], ts, esp[m], cols[m], dash[m]) for m in (:desplazamientos, :reducida_selectiva, :subdominios)],
        xt = [(t, string(t)) for t in (0.2, 0.05, 0.01, 0.002)], yt = [(y, string(y)) for y in (0.0, 0.25, 0.5, 0.75, 1.0, 1.25)],
        xlim = (0.0017, 0.25), ylim = (0.0, 1.3), lx = "espesor t / L (malla de 8×8 elementos)", ly = "w_centro / w_Navier",
        horizontales = [(1.0, "", GRIS)], xlog = true, leyenda = :derecha,
        aria = "El bloqueo por cortante empeora cuando el espesor disminuye en el elemento de desplazamientos puros y no afecta a los subdominios")
end

# 6. Espectro de rigidez del elemento plano: modos de energía nula (tema E5) ------------------------------
function fig_espectro()
    X = [0.0 1 1 0; 0 0 1 1]; plana = placa_oblicua(π / 2)
    modos = ((:desplazamientos, "desplazamientos 2×2"), (:reducida_selectiva, "reducida selectiva"), (:subdominios, "subdominios"))
    cel = 22.0; mx = 20.0; W = mx + 20cel + 150; Hp = 150.0
    cuerpo = ""
    for (i, (m, nom)) in enumerate(modos)
        ev = eigvals(Symmetric(rigidez_elemento(plana, X, 1.0, 0.3, 0.1; modo = m)))
        mx_ = maximum(ev)
        nz = count(<(1e-9 * mx_), ev)
        y0 = (i - 1) * Hp + 118
        cuerpo *= texto(mx, y0 - 108, "$nom — $nz autovalores nulos" * (nz == 6 ? " (solo sólido rígido)" : " (¡$(nz - 6) modos espurios!)"); color = nz == 6 ? "#1f2937" : NARANJA, tam = 14, cursiva = false)
        for (j, λ) in enumerate(ev)
            h = λ < 1e-9 * mx_ ? 4.0 : 90 * (λ / mx_)^0.3
            col = λ < 1e-9 * mx_ ? (j <= 6 ? GRIS : NARANJA) : AZUL
            cuerpo *= "<rect x=\"$(f(mx + (j - 1) * cel + 2))\" y=\"$(f(y0 - h))\" width=\"$(cel - 4)\" height=\"$h\" fill=\"$col\"/>\n"
        end
        cuerpo *= "<line x1=\"$mx\" y1=\"$y0\" x2=\"$(f(mx + 20cel))\" y2=\"$y0\" stroke=\"$GRIS\" stroke-width=\"1.3\"/>\n"
    end
    cuerpo *= texto(mx, 3 * Hp + 6, "20 autovalores de la matriz de rigidez, de menor a mayor (escala raíz)"; color = GRIS, tam = 12.5, cursiva = false)
    guardar("espectro-rigidez", "Autovalores de la matriz de rigidez de un elemento plano para tres formulaciones: seis nulos (sólido rígido) en desplazamientos y subdominios, ocho en integración reducida selectiva", W, 3 * Hp + 20, cuerpo)
end

# 7. Interpolación de deformaciones: lineal frente a escalones (tema E6) -----------------------------------
function fig_interp_def()
    v = Vista(-1.25, 1.4, -0.35, 1.25; s = 150)
    ε(η) = 0.25 + 0.55η + 0.22η^2 - 0.1η^3          # deformación «real» de un elemento (ilustrativa)
    s = ejes(v; ox = -1.15, oy = 0.0, ex = 1.35, ey = 1.2, lx = "η", ly = "ε₁₁")
    s *= linea(v, [(-1, -0.05), (-1, 0.05)]; color = GRIS) * linea(v, [(1, -0.05), (1, 0.05)]; color = GRIS)
    s *= textov(v, (-1, -0.17), "−1"; ancla = "middle", color = GRIS, tam = 12, cursiva = false)
    s *= textov(v, (1, -0.17), "1"; ancla = "middle", color = GRIS, tam = 12, cursiva = false)
    ηs = range(-1, 1; length = 60)
    s *= linea(v, [(η, ε(η)) for η in ηs]; color = GRIS, w = 3.0)
    media(a, b) = sum(ε(η) for η in range(a, b; length = 200)) / 200
    mA, mB = media(-1, 0), media(0, 1)
    s *= linea(v, [(-1, mA), (0, mA), (0, mB), (1, mB)]; color = NARANJA, w = 3.4)
    s *= linea(v, [(-1, ε(-1)), (1, ε(1))]; color = AZUL, w = 2.6, dash = "7 4")
    s *= textov(v, (-0.95, 1.02), "deformación del campo de desplazamientos"; color = GRIS, tam = 12.5, cursiva = false)
    s *= textov(v, (-0.95, 0.95), "interpolación lineal en η"; color = AZUL, tam = 12.5, cursiva = false)
    s *= textov(v, (-0.95, 0.88), "subdominios: un valor por mitad"; color = NARANJA, tam = 12.5, cursiva = false)
    guardar("interpolacion-subdominios", "Una deformación que varía a lo largo del elemento, su interpolación lineal y su aproximación por dos escalones constantes (una por subdominio)", ancho(v), alto(v), s)
end

# 8. Los cuatro subdominios y las deformaciones que se reparten (tema E7) ---------------------------------
function fig_cuadrantes()
    v = Vista(-1.9, 2.3, -1.65, 1.6; s = 100)
    cols = (AZUL, VERDE, NARANJA, VIOLETA)
    quads = (((-1, -1), (0, 0)), ((0, -1), (1, 0)), ((0, 0), (1, 1)), ((-1, 0), (0, 1)))
    nombres = ("A$(SUB("I"))", "A$(SUB("II"))", "A$(SUB("III"))", "A$(SUB("IV"))")
    s = ""
    for (q, ((x0, y0), (x1, y1))) in enumerate(quads)
        s *= linea(v, [(x0, y0), (x1, y0), (x1, y1), (x0, y1), (x0, y0)]; color = cols[q], w = 2.0, fill = cols[q], op = 0.2)
        s *= textov(v, ((x0 + x1) / 2, (y0 + y1) / 2 - 0.04), nombres[q]; ancla = "middle", color = cols[q], tam = 15, cursiva = false)
    end
    s *= flecha(v, (-1.0, 0.0), (1.0, 0.0); color = GRIS, w = 1.2, etiqueta = "ξ", dx = -4, dy = -8) * flecha(v, (0.0, -1.0), (0.0, 1.0); color = GRIS, w = 1.2, etiqueta = "η", dx = 8, dy = 6)
    # llaves: ε₁₁ por mitades de η (derecha); ε₂₂ por mitades de ξ (abajo)
    s *= linea(v, [(1.12, -1), (1.2, -1), (1.2, 0), (1.12, 0)]; color = GRIS, w = 1.6)
    s *= textov(v, (1.26, -0.5), "ε₁₁ (A): I + II"; color = "#1f2937", tam = 13, cursiva = false)
    s *= linea(v, [(1.12, 0), (1.2, 0), (1.2, 1), (1.12, 1)]; color = GRIS, w = 1.6)
    s *= textov(v, (1.26, 0.5), "ε₁₁ (B): III + IV"; color = "#1f2937", tam = 13, cursiva = false)
    s *= linea(v, [(-1, -1.12), (-1, -1.2), (0, -1.2), (0, -1.12)]; color = GRIS, w = 1.6)
    s *= textov(v, (-0.5, -1.38), "ε₂₂ (C): I + IV"; ancla = "middle", color = "#1f2937", tam = 13, cursiva = false)
    s *= linea(v, [(0, -1.12), (0, -1.2), (1, -1.2), (1, -1.12)]; color = GRIS, w = 1.6)
    s *= textov(v, (0.5, -1.38), "ε₂₂ (D): II + III"; ancla = "middle", color = "#1f2937", tam = 13, cursiva = false)
    s *= textov(v, (-1.85, 1.35), "ε₁₂ = constante en todo el elemento"; color = OCRE, tam = 13, cursiva = false)
    guardar("subdominios-cuadrantes", "El elemento se divide en cuatro cuadrantes: la deformación longitudinal en una dirección toma un valor en cada mitad, la de la otra dirección también, y la deformación de cortante es única", ancho(v), alto(v), s)
end

# 9. Masa consistente frente a masa concentrada (tema E8) -------------------------------------------------
function fig_masa()
    ns = collect(1:10)
    function razon(n, modo)
        h = 1.0 / n
        K = zeros(n, n); M = zeros(n, n)           # barra empotrada en x = 0, libre en x = L; E = ρ = A = L = 1
        for e in 1:n
            ke = [1 -1; -1 1] ./ h
            me = modo == :consistente ? h / 6 .* [2 1; 1 2] : h / 2 .* [1 0; 0 1]
            idx = [e - 1, e]
            for a in 1:2, b in 1:2
                (idx[a] >= 1 && idx[b] >= 1) || continue
                K[idx[a], idx[b]] += ke[a, b]; M[idx[a], idx[b]] += me[a, b]
            end
        end
        sqrt(minimum(eigvals(Symmetric(K), Symmetric(M)))) / (π / 2)
    end
    grafica("masa-barra", "Primera frecuencia de una barra: masa consistente y concentrada";
        series = [("consistente (por encima)", ns, [razon(n, :consistente) for n in ns], AZUL, ""),
                  ("concentrada (por debajo)", ns, [razon(n, :concentrada) for n in ns], NARANJA, "7 4")],
        xt = [(n, string(n)) for n in (1, 2, 4, 6, 8, 10)], yt = [(y, string(y)) for y in (0.7, 0.8, 0.9, 1.0, 1.1)],
        xlim = (0.5, 10.5), ylim = (0.65, 1.12), lx = "elementos", ly = "ω_h / ω_exacta",
        horizontales = [(1.0, "frecuencia exacta", GRIS)], leyenda = :derecha,
        aria = "La masa consistente da frecuencias por encima de la exacta y la masa concentrada por debajo; ambas convergen al refinar la malla")
end

# 10. Ensamblaje: numeración de nodos y elementos (tema E9) ----------------------------------------------
function fig_malla_ensamblaje()
    n1, n2 = 3, 2
    v = Vista(-0.5, 3.9, -0.55, 2.6; s = 90)
    nodos, conn = malla_rectangular((0.0, 3.0), (0.0, 2.0), n1, n2)
    s = ""
    for e in axes(conn, 2)
        P = [(nodos[1, k], nodos[2, k]) for k in conn[:, e]]
        resalta = e == 4
        s *= linea(v, vcat(P, [P[1]]); color = resalta ? NARANJA : AZUL, w = resalta ? 3.2 : 2.0, fill = resalta ? NARANJA : AZUL, op = resalta ? 0.18 : 0.06)
        cx = sum(p[1] for p in P) / 4; cy = sum(p[2] for p in P) / 4
        s *= textov(v, (cx, cy - 0.03), "elem. $e"; ancla = "middle", color = resalta ? NARANJA : GRIS, tam = 14, cursiva = false)
    end
    for k in 1:size(nodos, 2)
        p = (nodos[1, k], nodos[2, k]); s *= punto(v, p; color = "#1f2937", r = 5)
        s *= textov(v, (p[1] - 0.17, p[2] + 0.09), string(k); color = "#1f2937", tam = 15, cursiva = false)
    end
    d = gdl_elemento(conn, 4)
    s *= textov(v, (-0.45, 2.45), "Elemento 4: nodos $(join(conn[:, 4], ', '))  →  g.d.l. globales"; color = NARANJA, tam = 13.5, cursiva = false)
    s *= textov(v, (-0.45, 2.27), "$(d[1]):$(d[5]), $(d[6]):$(d[10]), $(d[11]):$(d[15]), $(d[16]):$(d[20])"; color = NARANJA, tam = 13.5, cursiva = false)
    s *= textov(v, (-0.45, -0.38), "5 g.d.l. por nodo × 12 nodos = 60 incógnitas"; color = GRIS, tam = 13, cursiva = false)
    guardar("malla-ensamblaje", "Malla de tres por dos elementos con numeración de nodos y elementos; el elemento 4 enlaza los grados de libertad globales de sus cuatro nodos", ancho(v), alto(v), s)
end

println("Figuras del bloque E:")
fig_barra(); fig_isoparam(); fig_elemento(); fig_mapaH(); fig_bloqueo(); fig_espectro()
fig_interp_def(); fig_cuadrantes(); fig_masa(); fig_malla_ensamblaje()
