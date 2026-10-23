# Figuras de los temas F (validación estática y vibraciones) en figures/svg/*.svg. Todas calculadas con Geometria.
#   julia --project=. julia/scripts/generar_figuras_validacion.jl
include(joinpath(@__DIR__, "figuras_lib.jl"))
include(joinpath(@__DIR__, "figuras_fem_lib.jl"))

leyenda_color(v, x, y, rango, etiqueta) = begin
    s = ""
    for i in 0:19
        t = -1 + 2i / 19
        s *= "<rect x=\"$(f(x + i * 9))\" y=\"$(f(y))\" width=\"9\" height=\"12\" fill=\"$(color_div(t))\"/>\n"
    end
    s *= texto(x, y + 28, "−$(rango)"; tam = 12, color = GRIS, cursiva = false)
    s *= texto(x + 180, y + 28, "+$(rango)"; tam = 12, color = GRIS, cursiva = false, ancla = "end")
    s *= texto(x + 90, y - 6, etiqueta; tam = 12.5, color = "#1f2937", cursiva = false, ancla = "middle")
    s
end

# F1a. Placa simplemente apoyada deformada (flecha en color) ---------------------------------------------
function fig_placa_flecha()
    p = placa_ss(12, 0.01, :subdominios)
    r = placa_oblicua(π / 2); cam = Camara(deg2rad(-50), deg2rad(32))
    w = [p.u[gdl(k, 3)] for k in 1:size(p.nodos, 2)]
    esc = 0.28 / maximum(abs, w)
    v = vista_fe(cam, r, p.nodos; s = 170, margen = 0.35)
    s = superficie_fe(v, cam, r, p.nodos, p.conn, p.u; esc, valor = w, malla = true)
    s *= leyenda_color(v, 20, alto(v) - 38, "w máx", "flecha (deformada exagerada)")
    guardar("placa-flecha", "Placa cuadrada simplemente apoyada con carga uniforme: deformada exagerada coloreada por la flecha", ancho(v), alto(v), s)
end

# F1b. Convergencia de la flecha central de la placa delgada -----------------------------------------------
function fig_placa_conv()
    E, ν, t = 1.0e4, 0.3, 0.001
    D = E * t^3 / (12 * (1 - ν^2)); wref = navier_centro(1.0, 1.0, D)
    ns = [2, 4, 8, 16, 32]
    err(n, m) = (p = placa_ss(n, t, m); abs(-p.u[gdl(nodo_en(p.nodos, [0.5, 0.5]), 3)] / wref - 1))
    es = [err(n, :subdominios) for n in ns]; er = [err(n, :reducida_selectiva) for n in ns]
    guia = [es[2] * (ns[2] / n)^2 for n in ns]
    grafica("placa-convergencia", "Error relativo de la flecha central frente al número de elementos por lado";
        series = [("subdominios", ns, es, AZUL, ""), ("reducida selectiva", ns, er, VIOLETA, "7 4"), ("pendiente 2", ns, guia, GRIS, "3 4")],
        xt = [(n, string(n)) for n in ns], yt = [(y, "10" * Dict(-6 => "⁻⁶", -5 => "⁻⁵", -4 => "⁻⁴", -3 => "⁻³", -2 => "⁻²", -1 => "⁻¹")[round(Int, log10(y))]) for y in (1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1)],
        xlim = (1.7, 36), ylim = (1e-6, 0.3), lx = "elementos por lado", ly = "error relativo",
        xlog = true, ylog = true, leyenda = :derecha,
        aria = "El error de la flecha central de la placa delgada baja con pendiente dos en escala logarítmica con los subdominios y con la integración reducida selectiva")
end

# F1c. Placa oblicua de 60° ---------------------------------------------------------------------------------
function fig_placa_oblicua()
    p = placa_ss(12, 0.01, :subdominios; geom = placa_oblicua(π / 3))
    r = placa_oblicua(π / 3); cam = Camara(deg2rad(-60), deg2rad(32))
    w = [p.u[gdl(k, 3)] for k in 1:size(p.nodos, 2)]
    esc = 0.22 / maximum(abs, w)
    v = vista_fe(cam, r, p.nodos; s = 170, margen = 0.35)
    s = superficie_fe(v, cam, r, p.nodos, p.conn, p.u; esc, valor = w, malla = true)
    s *= leyenda_color(v, 20, alto(v) - 38, "w máx", "flecha (deformada exagerada)")
    guardar("placa-oblicua", "Placa oblicua de 60 grados simplemente apoyada con carga uniforme: deformada exagerada coloreada por la flecha", ancho(v), alto(v), s)
end


# F2a. Techo de Scordelis–Lo deformado ------------------------------------------------------------------------
function fig_scordelis()
    r, nodos, conn, u, w = scordelis(14)
    cam = Camara(deg2rad(-125), deg2rad(22))
    vz = [desplazamiento_cartesiano(r, nodos, u, k)[3] for k in 1:size(nodos, 2)]
    esc = 8.0
    v = vista_fe(cam, r, nodos; s = 22, margen = 4)
    s = superficie_fe(v, cam, r, nodos, conn, u; esc, valor = vz, malla = true)
    s *= leyenda_color(v, 20, alto(v) - 38, "máx", "desp. vertical (×8)")
    guardar("scordelis-lo", "Techo cilíndrico de Scordelis-Lo, un cuarto del modelo: deformada coloreada por el desplazamiento vertical", ancho(v), alto(v), s)
end

# F2b. Cilindro pinzado deformado --------------------------------------------------------------------------
function fig_pinzado()
    r, nodos, conn, u, w = pinzado(14)
    cam = Camara(deg2rad(-45), deg2rad(25))
    vr = [dot(desplazamiento_cartesiano(r, nodos, u, k), r(nodos[:, k]) .* [0, 1, 1] ./ 300) for k in 1:size(nodos, 2)]
    esc = 0.45 / maximum(abs, vr) * 30
    v = vista_fe(cam, r, nodos; s = 0.55, margen = 40)
    s = superficie_fe(v, cam, r, nodos, conn, u; esc, valor = vr, malla = true)
    s *= leyenda_color(v, 20, alto(v) - 38, "máx", "desp. radial (exagerado)")
    guardar("cilindro-pinzado", "Un octavo del cilindro pinzado con diafragmas: deformada coloreada por el desplazamiento radial", ancho(v), alto(v), s)
end

# F2c. Convergencia frente a las referencias ------------------------------------------------------------------
function fig_conv_cilindros()
    ns = [4, 8, 16, 32]
    sl = [abs(scordelis(n)[5]) / 0.3024 for n in ns]
    pz = [abs(pinzado(n)[5]) / 1.8248e-5 for n in ns]
    sld = [abs(scordelis(n; modo = :desplazamientos)[5]) / 0.3024 for n in ns]
    pzd = [abs(pinzado(n; modo = :desplazamientos)[5]) / 1.8248e-5 for n in ns]
    grafica("cilindros-convergencia", "Convergencia en los dos benchmarks de cilindro";
        series = [("S–L, subdominios", ns, sl, AZUL, ""), ("pinzado, subdominios", ns, pz, VERDE, ""),
                  ("S–L, desplazamientos", ns, sld, AZUL, "7 4"), ("pinzado, despl.", ns, pzd, VERDE, "7 4")],
        xt = [(n, string(n)) for n in ns], yt = [(y, string(y)) for y in (0.0, 0.25, 0.5, 0.75, 1.0)],
        xlim = (3.2, 40), ylim = (0.0, 1.12), lx = "elementos por lado", ly = "valor calculado / referencia",
        horizontales = [(1.0, "referencia", GRIS)], xlog = true, leyenda = :derecha, ancho = 600, alto = 360,
        aria = "Convergencia del desplazamiento del techo de Scordelis-Lo y del cilindro pinzado: los subdominios se acercan a uno, los desplazamientos puros quedan muy por debajo")
end

# F3a. Hypar deformado ----------------------------------------------------------------------------------------
function fig_hypar_def()
    r, nodos, conn, u = hypar_estatico(14, 0.5)
    cam = Camara(deg2rad(-55), deg2rad(28))
    w = [u[gdl(k, 3)] for k in 1:size(nodos, 2)]
    esc = 4.0
    v = vista_fe(cam, r, nodos; s = 150, margen = 0.4)
    s = superficie_fe(v, cam, r, nodos, conn, u; esc, valor = w, malla = true)
    s *= leyenda_color(v, 20, alto(v) - 38, "máx", "flecha (deformada ×4)")
    guardar("hypar-deformada", "Paraboloide hiperbólico de bordes rectos bajo carga vertical uniforme: deformada coloreada por la flecha", ancho(v), alto(v), s)
end

# F3b. Resultante de cortante en la fila central ---------------------------------------------------------------
function fig_hypar_n12()
    c = 0.25; n = 24; E, ν, t = 1.0e4, 0.3, 0.01
    xs, art, emp = Float64[], Float64[], Float64[]
    r, nodos, conn, u = hypar_estatico(n, c; t)
    fila = n12_fila_central(r, nodos, conn, u, E, ν, t)
    r2, nodos2, conn2, u2 = hypar_estatico(n, c; t, apoyo = :empotrado)
    fila2 = n12_fila_central(r2, nodos2, conn2, u2, E, ν, t)
    # dos filas centrales: promediar por x
    prom(fl) = [(x, sum(v for (xx, v) in fl if xx == x) / count(==(x), first.(fl))) for x in unique(first.(fl))]
    a1 = prom(fila); a2 = prom(fila2)
    grafica("hypar-n12", "Resultante de cortante a lo largo del eje central";
        series = [("bordes articulados", first.(a1), last.(a1), AZUL, ""), ("bordes empotrados", first.(a2), last.(a2), NARANJA, "7 4")],
        xt = [(x, string(x)) for x in (-1.0, -0.5, 0.0, 0.5, 1.0)], yt = [(y, string(y)) for y in (0.0, 0.5, 1.0, 1.5, 2.0, 2.5)],
        xlim = (-1.05, 1.05), ylim = (0.0, 2.6), lx = "x / a", ly = "N¹² (p = 1)",
        horizontales = [(1 / (2c), "membrana p/(2c) = 2", VERDE)], leyenda = :izquierda, ancho = 600, alto = 340,
        aria = "La resultante de cortante N12 es casi constante e igual a p dividido por dos c en el interior del paraboloide, y se aparta de ese valor cerca de los bordes")
end

# F4a. Modos de vibración de la placa simplemente apoyada ---------------------------------------------------
function fig_modos_placa()
    t = 0.01; n = 14
    p = placa_ss(n, t, :subdominios; ρ = 1.0, carga = false)
    ω, V = frecuencias(p.K, p.M, p.fijos; n = 6)
    D = 1.0e4 * t^3 / (12 * (1 - 0.3^2)); λ = ω .* sqrt(t / D)
    r = placa_oblicua(π / 2); cam = Camara(deg2rad(-50), deg2rad(30))
    elegidos = (1, 2, 4, 5); paneles = Any[]
    for (i, k) in enumerate(elegidos)
        u = V[:, k]; w = [u[gdl(j, 3)] for j in 1:size(p.nodos, 2)]
        w ./= maximum(abs, w); u = u ./ maximum(abs, [u[gdl(j, 3)] for j in 1:size(p.nodos, 2)])
        v = vista_fe(cam, r, p.nodos; s = 95, margen = 0.5)
        s = superficie_fe(v, cam, r, p.nodos, p.conn, u; esc = 0.35, valor = w, rango = 1.0, malla = false)
        s *= textov(v, (0.0, v.ymin + 0.1), "modo $k: λ = $(round(λ[k], digits = 2))"; color = "#1f2937", tam = 14, cursiva = false, ancla = "middle")
        push!(paneles, (v, s))
    end
    H = maximum(alto(q[1]) for q in paneles); W = ancho(paneles[1][1])
    cuerpo = ""
    for (i, (v, s)) in enumerate(paneles)
        cuerpo *= "<g transform=\"translate($(f(((i - 1) % 2) * W)),$(f(((i - 1) ÷ 2) * H)))\">\n$s</g>\n"
    end
    guardar("modos-placa", "Cuatro modos de vibración de una placa cuadrada simplemente apoyada: el fundamental, el segundo y los modos de la cuarta y quinta frecuencias, con las zonas que suben en naranja y las que bajan en azul", 2W, 2H, cuerpo)
end

# F4b. Convergencia de los parámetros de frecuencia -----------------------------------------------------------
function fig_lambda_conv()
    ns = [4, 6, 8, 12, 16]; E, ν, t = 1.0e4, 0.3, 0.001; D = E * t^3 / (12 * (1 - ν^2))
    exacta = [2π^2, 5π^2, 5π^2, 8π^2]
    datos = Dict(n => (p = placa_ss(n, t, :subdominios; ρ = 1.0, carga = false); frecuencias(p.K, p.M, p.fijos; n = 4)[1] .* sqrt(t / D)) for n in ns)
    series = [("λ₁ = 2π²", ns, [datos[n][1] / exacta[1] for n in ns], AZUL, ""), ("λ₂ = 5π²", ns, [datos[n][2] / exacta[2] for n in ns], VERDE, ""),
              ("λ₄ = 8π²", ns, [datos[n][4] / exacta[4] for n in ns], NARANJA, "7 4")]
    grafica("lambda-convergencia", "Frecuencias de la placa: cociente con la solución exacta";
        series = series, xt = [(n, string(n)) for n in ns], yt = [(y, string(y)) for y in (1.0, 1.1, 1.2, 1.3)],
        xlim = (3.5, 17), ylim = (0.98, 1.32), lx = "elementos por lado", ly = "λ calculada / λ exacta", horizontales = [(1.0, "", GRIS)],
        leyenda = :derecha, aria = "Los parámetros de frecuencia de la placa simplemente apoyada tienden a los valores exactos por encima al refinar la malla; los modos superiores convergen más despacio")
end

# F4c. Efecto de la curvatura: panel cilíndrico ------------------------------------------------------------------
function fig_panel_curvatura()
    E, ν, ρ, t = 1.0e4, 0.3, 1.0, 0.01; D = E * t^3 / (12 * (1 - ν^2))
    function panel(R)
        r = cil_x(R); nodos, conn = malla_rectangular((0, 1.0), (0, 1.0 / R), 12, 12)
        K, M, _ = ensamblar(r, nodos, conn, E, ν, t; ρ)
        fij = Int[]
        for k in 1:size(nodos, 2)
            x, φ = nodos[:, k]
            (x ≈ 0 || x ≈ 1) && append!(fij, [gdl(k, 2), gdl(k, 3), gdl(k, 5)])
            (φ ≈ 0 || φ ≈ 1 / R) && append!(fij, [gdl(k, 1), gdl(k, 3), gdl(k, 4)])
        end
        frecuencias(K, M, unique(fij); n = 1)[1][1] * sqrt(ρ * t / D)
    end
    cs = [0.0, 0.05, 0.1, 0.2, 0.5, 1.0]            # curvatura 1/R (a = 1)
    ls = [panel(c == 0 ? 1.0e6 : 1 / c) for c in cs]
    grafica("panel-curvatura", "Primera frecuencia de un panel cilíndrico";
        series = [("panel cilíndrico", cs, ls, AZUL, "")], xt = [(c, string(c)) for c in (0.0, 0.2, 0.5, 1.0)],
        yt = [(y, string(y)) for y in (20, 40, 60, 80)], xlim = (-0.03, 1.05), ylim = (10, 90),
        lx = "curvatura a/R", ly = "λ₁ = ω a² √(ρt/D)", horizontales = [(2π^2, "placa plana 2π²", GRIS)], leyenda = :izquierda,
        aria = "La primera frecuencia adimensional de un panel cilíndrico simplemente apoyado crece con la curvatura desde el valor de la placa plana")
end

# F5a. Modos del hypar ----------------------------------------------------------------------------------------
function fig_modos_hypar()
    casos = ((paraboloide_curvo(2.0, -2.0), 1, "bordes curvos, modo 1"), (paraboloide_curvo(2.0, -2.0), 2, "bordes curvos, modo 2"),
             (paraboloide_recto(0.5), 1, "bordes rectos, modo 1"), (paraboloide_recto(0.5), 3, "bordes rectos, modo 3"))
    cam = Camara(deg2rad(-50), deg2rad(30)); paneles = Any[]
    for (r, k, tit) in casos
        λ, ω, nodos, conn, V = hypar_frecuencias(r, 14, 0.01, :SSSS; k = 4)
        u = V[:, k]; w = [desplazamiento_cartesiano(r, nodos, u, j)[3] for j in 1:size(nodos, 2)]
        m = maximum(abs, [norm(desplazamiento_cartesiano(r, nodos, u, j)) for j in 1:size(nodos, 2)])
        u = u ./ m; w ./= m
        v = vista_fe(cam, r, nodos; s = 95, margen = 0.55)
        s = superficie_fe(v, cam, r, nodos, conn, u; esc = 0.3, valor = w, rango = 1.0, malla = false)
        s *= textov(v, (0.0, v.ymin + 0.08), "$tit: λ = $(round(λ[k], digits = 1))"; color = "#1f2937", tam = 13, cursiva = false, ancla = "middle")
        push!(paneles, (v, s))
    end
    H = maximum(alto(q[1]) for q in paneles); W = ancho(paneles[1][1]); cuerpo = ""
    for (i, (v, s)) in enumerate(paneles)
        cuerpo *= "<g transform=\"translate($(f(((i - 1) % 2) * W)),$(f(((i - 1) ÷ 2) * H)))\">\n$s</g>\n"
    end
    guardar("modos-hypar", "Modos de vibración de un paraboloide hiperbólico simplemente apoyado con bordes curvos (arriba) y con bordes rectos (abajo)", 2W, 2H, cuerpo)
end

# F5b. Convergencia de λ₁ del hypar con h² --------------------------------------------------------------------
function fig_hypar_conv()
    ns = [8, 12, 16, 24, 32]
    l1(r) = [hypar_frecuencias(r, n, 0.01, :SSSS; k = 1)[1][1] for n in ns]
    a = l1(paraboloide_curvo(2.0, -2.0)); b = l1(paraboloide_recto(0.5))
    h2 = (1 ./ ns) .^ 2
    extrap(l) = l[end] - (l[end-1] - l[end]) / ((ns[end] / ns[end-1])^2 - 1)
    grafica("hypar-convergencia", "Primera frecuencia del hypar frente al tamaño de elemento";
        series = [("bordes curvos", h2, a, AZUL, ""), ("bordes rectos", h2, b, NARANJA, "")],
        xt = [(0.0, "0"), (0.005, "0,005"), (0.01, "0,01"), (0.015, "0,015")], yt = [(y, string(y)) for y in (40, 60, 80, 100, 120)],
        xlim = (-0.0005, 0.017), ylim = (35, 115), lx = "(1/n)² (n = elementos por lado)", ly = "λ₁",
        horizontales = [(extrap(a), "extrapolación curvos ≈ $(round(extrap(a), digits = 1))", AZUL), (extrap(b), "extrapolación rectos ≈ $(round(extrap(b), digits = 1))", NARANJA)],
        leyenda = :izquierda, aria = "La primera frecuencia adimensional de los dos hypar decrece casi linealmente con el cuadrado del tamaño de elemento, lo que permite extrapolar un valor límite")
end

# F6. Pirámide de pruebas -------------------------------------------------------------------------------------
function fig_piramide()
    niveles = ["Verificación de los ejercicios", "Benchmarks (Scordelis–Lo, pinzado)", "Soluciones analíticas (Navier, presión)",
               "Patch test", "Propiedades del elemento", "Identidades (reciprocidad, Christoffel, H = D6)"]
    colores = [VIOLETA, OCRE, VERDE, NARANJA, AZUL, GRIS]
    W, H = 720.0, 330.0; h = 46.0; cuerpo = ""
    for (i, (nom, c)) in enumerate(zip(niveles, colores))
        y = 12 + (i - 1) * (h + 4)
        ancho_i = 190 + (i - 1) * 90; x = (W - ancho_i) / 2
        cuerpo *= "<rect x=\"$(f(x))\" y=\"$(f(y))\" width=\"$(f(ancho_i))\" height=\"$h\" rx=\"4\" fill=\"$c\" fill-opacity=\"0.16\" stroke=\"$c\" stroke-width=\"2.2\"/>\n"
        cuerpo *= texto(W / 2, y + 28, "$(7 - i). $nom"; color = "#1f2937", tam = 13, ancla = "middle", cursiva = false)
    end
    guardar("piramide-pruebas", "Pirámide de seis niveles de pruebas: de las identidades algebraicas en la base a la verificación de los ejercicios en la cúspide", W, H, cuerpo)
end

println("Figuras de los temas F:")
fig_placa_flecha(); fig_placa_conv(); fig_placa_oblicua()
fig_scordelis(); fig_pinzado(); fig_conv_cilindros()
fig_hypar_def(); fig_hypar_n12()
fig_modos_placa(); fig_lambda_conv(); fig_panel_curvatura()
fig_modos_hypar(); fig_hypar_conv(); fig_piramide()
