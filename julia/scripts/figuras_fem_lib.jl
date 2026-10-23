# Utilidades para las figuras de los bloques E y F (gráficas, mallas y deformadas de elementos finitos).
# Se incluye después de figuras_lib.jl.
using Geometria, LinearAlgebra

"Mapa de color divergente azul → blanco → naranja para `t ∈ [-1, 1]` (hex)."
function color_div(t)
    t = clamp(t, -1, 1)
    a = t < 0 ? (0x1b, 0x6c, 0xa8) : (0xd9, 0x5f, 0x02)
    s = abs(t)
    c = ntuple(i -> round(Int, 255 * (1 - s) + a[i] * s), 3)
    "#" * join((string(x, base = 16, pad = 2) for x in c))
end

"Mapa secuencial blanco → azul para `t ∈ [0, 1]`."
function color_sec(t)
    t = clamp(t, 0, 1)
    a = (0x1b, 0x6c, 0xa8)
    c = ntuple(i -> round(Int, 255 * (1 - t) + a[i] * t), 3)
    "#" * join((string(x, base = 16, pad = 2) for x in c))
end

"""
    grafica(nombre, titulo; series, xt, yt, xlim, ylim, lx, ly, ...)

Gráfica de líneas con marcadores en SVG. `series` es una lista de `(etiqueta, xs, ys, color, dash)`.
`xt`/`yt` son listas de `(valor, texto)` para las marcas. `horizontales` dibuja líneas de referencia
`(y, texto, color)`.
"""
function grafica(nombre, titulo; series, xt, yt, xlim, ylim, lx = "", ly = "", horizontales = [],
                 ancho = 560, alto = 340, leyenda = :derecha, aria = titulo, xlog = false, ylog = false)
    mI, mD, mS, mB = 62.0, 24.0, 18.0, 52.0
    wpx, hpx = ancho - mI - mD, alto - mS - mB
    fx(x) = mI + (xlog ? (log10(x) - log10(xlim[1])) / (log10(xlim[2]) - log10(xlim[1])) : (x - xlim[1]) / (xlim[2] - xlim[1])) * wpx
    fy(y) = mS + (1 - (ylog ? (log10(y) - log10(ylim[1])) / (log10(ylim[2]) - log10(ylim[1])) : (y - ylim[1]) / (ylim[2] - ylim[1]))) * hpx
    s = "<rect x=\"$mI\" y=\"$mS\" width=\"$wpx\" height=\"$hpx\" fill=\"#fcfcfd\" stroke=\"$GRIS\" stroke-width=\"1.2\"/>\n"
    for (x, e) in xt
        s *= "<line x1=\"$(f(fx(x)))\" y1=\"$mS\" x2=\"$(f(fx(x)))\" y2=\"$(f(mS + hpx))\" stroke=\"$MALLA\" stroke-width=\"0.7\"/>\n"
        s *= texto(fx(x), mS + hpx + 18, e; color = GRIS, tam = 12, ancla = "middle", cursiva = false)
    end
    for (y, e) in yt
        s *= "<line x1=\"$mI\" y1=\"$(f(fy(y)))\" x2=\"$(f(mI + wpx))\" y2=\"$(f(fy(y)))\" stroke=\"$MALLA\" stroke-width=\"0.7\"/>\n"
        s *= texto(mI - 8, fy(y) + 4, e; color = GRIS, tam = 12, ancla = "end", cursiva = false)
    end
    for (y, e, c) in horizontales
        s *= "<line x1=\"$mI\" y1=\"$(f(fy(y)))\" x2=\"$(f(mI + wpx))\" y2=\"$(f(fy(y)))\" stroke=\"$c\" stroke-width=\"1.6\" stroke-dasharray=\"7 4\"/>\n"
        s *= texto(mI + wpx - 4, fy(y) - 6, e; color = c, tam = 12, ancla = "end", cursiva = false)
    end
    for (k, (et, xs, ys, c, dash)) in enumerate(series)
        pts = join(("$(f(fx(x))),$(f(fy(y)))" for (x, y) in zip(xs, ys)), " ")
        da = isempty(dash) ? "" : " stroke-dasharray=\"$dash\""
        s *= "<polyline points=\"$pts\" fill=\"none\" stroke=\"$c\" stroke-width=\"2.4\"$da stroke-linejoin=\"round\"/>\n"
        for (x, y) in zip(xs, ys)
            mk = k % 3 == 1 ? "<circle cx=\"$(f(fx(x)))\" cy=\"$(f(fy(y)))\" r=\"3.8\" fill=\"$c\"/>\n" :
                 k % 3 == 2 ? "<rect x=\"$(f(fx(x) - 3.6))\" y=\"$(f(fy(y) - 3.6))\" width=\"7.2\" height=\"7.2\" fill=\"$c\"/>\n" :
                              "<polygon points=\"$(f(fx(x))),$(f(fy(y) - 4.6)) $(f(fx(x) - 4.2)),$(f(fy(y) + 3.4)) $(f(fx(x) + 4.2)),$(f(fy(y) + 3.4))\" fill=\"$c\"/>\n"
            s *= mk
        end
    end
    # leyenda
    lx0 = leyenda == :derecha ? mI + wpx - 175 : mI + 12; ly0 = leyenda == :derecha ? mS + hpx - 14 - 22 * length(series) : mS + 18
    for (k, (et, _, _, c, dash)) in enumerate(series)
        yy = ly0 + 22 * (k - 1)
        da = isempty(dash) ? "" : " stroke-dasharray=\"$dash\""
        s *= "<line x1=\"$lx0\" y1=\"$(f(yy))\" x2=\"$(f(lx0 + 26))\" y2=\"$(f(yy))\" stroke=\"$c\" stroke-width=\"2.4\"$da/>\n"
        s *= texto(lx0 + 32, yy + 4, et; color = "#1f2937", tam = 12.5, cursiva = false)
    end
    isempty(lx) || (s *= texto(mI + wpx / 2, alto - 10, lx; color = "#1f2937", tam = 14, ancla = "middle"))
    isempty(ly) || (s *= "<text transform=\"translate(16,$(f(mS + hpx / 2))) rotate(-90)\" fill=\"#1f2937\" font-size=\"14\" text-anchor=\"middle\" font-family=\"Georgia, serif\" font-style=\"italic\">$ly</text>\n")
    guardar(nombre, aria, ancho, alto, s)
end

"""
    superficie_fe(v, cam, r, nodos, conn, u; esc = 0.0, valor = nothing, rango = nothing, malla = true)

Dibuja la malla de lámina en 3D por el algoritmo del pintor. `u` es el vector global de g.d.l. (o `nothing`);
la posición de cada nodo es `r(θ) + esc·u_cartesiano`. `valor` (vector por nodo) colorea cada elemento con
el mapa divergente (`rango` = máximo absoluto).
"""
function superficie_fe(v, cam::Camara, r, nodos, conn, u; esc = 0.0, valor = nothing, rango = nothing, malla = true, sec = false)
    nn = size(nodos, 2)
    pos = [r(nodos[:, k]) .+ (u === nothing ? zeros(3) : esc .* desplazamiento_cartesiano(r, nodos, u, k)) for k in 1:nn]
    rg = rango === nothing ? (valor === nothing ? 1.0 : maximum(abs, valor) + 1e-30) : rango
    celdas = []
    for e in axes(conn, 2)
        P = [pos[k] for k in conn[:, e]]
        val = valor === nothing ? 0.0 : sum(valor[k] for k in conn[:, e]) / 4
        push!(celdas, (sum(prof(cam, p) for p in P) / 4, [proy(cam, p) for p in P], val))
    end
    sort!(celdas; by = first)
    join((linea(v, vcat(q, [q[1]]); color = malla ? "#8a96a8" : "none", w = 0.7,
                fill = valor === nothing ? "#e8edf6" : (sec ? color_sec(val / rg) : color_div(val / rg)), op = 1.0) for (_, q, val) in celdas))
end

"Vista que encuadra la proyección de la malla (con o sin deformada)."
function vista_fe(cam::Camara, r, nodos; s = 60.0, margen = 0.2, extra = [])
    pts = [proy(cam, r(nodos[:, k])) for k in 1:size(nodos, 2)]
    ventana(vcat(pts, [proy(cam, p) for p in extra]); s, margen)
end

# --- Ensamblaje y condiciones de contorno de los casos de validación (reutilizados en E y F) ----------

"Cilindro de eje x: `r(θ¹,θ²) = (θ¹, R sen θ², R cos θ²)`, normal exterior."
cil_x(R) = θ -> [θ[1], R * sin(θ[2]), R * cos(θ[2])]

"Navier para placa simplemente apoyada rectangular `a×a` con carga uniforme `q` (flecha central, `D` rigidez)."
navier_centro(a, q, D; N = 199) =
    16q / (π^6 * D) * sum(sin(m * π / 2) * sin(n * π / 2) / (m * n * (m^2 + n^2)^2 / a^4) for m in 1:2:N, n in 1:2:N)

"""
    placa_ss(n, t, modo; E, ν, L, q, geom, ρ)

Placa cuadrada simplemente apoyada (apoyo «duro»: `u₃ = 0` y giro tangente nulo en el borde; en el plano
todo fijo porque no interviene). Devuelve `(nodos, conn, u, K, M)`.
"""
function placa_ss(n, t, modo; E = 1.0e4, ν = 0.3, L = 1.0, q = 1.0, ρ = nothing, geom = placa_oblicua(π / 2), carga = true)
    nodos, conn = malla_rectangular((0, L), (0, L), n, n)
    K, M, F = ensamblar(geom, nodos, conn, E, ν, t; modo, ρ, f = carga ? (θ -> [0, 0, -q]) : nothing)
    fij = Int[]
    for k in 1:size(nodos, 2)
        x, y = nodos[:, k]
        append!(fij, [gdl(k, 1), gdl(k, 2)])
        (x ≈ 0 || x ≈ L || y ≈ 0 || y ≈ L) && push!(fij, gdl(k, 3))
        (x ≈ 0 || x ≈ L) && push!(fij, gdl(k, 5))
        (y ≈ 0 || y ≈ L) && push!(fij, gdl(k, 4))
    end
    fij = unique(fij)
    u = carga ? resolver_estatica(K, F, fij) : nothing
    (nodos = nodos, conn = conn, u = u, K = K, M = M, fijos = fij)
end

"Nodo más cercano al punto paramétrico `p`."
nodo_en(nodos, p) = argmin([norm(nodos[:, k] .- p) for k in 1:size(nodos, 2)])

"""
    scordelis(n; modo)

Techo cilíndrico de Scordelis–Lo (R = 25, L = 50, t = 0.25, E = 4.32e8, ν = 0, peso 90 por unidad de superficie),
un cuarto del modelo con `n×n` elementos: `θ¹ = x ∈ [0, L/2]`, `θ² = φ ∈ [0, 40°]`. Extremo con diafragma
(`u₂ = u₃ = 0`), simetrías en `x = L/2` (`u₁ = φ₁ = 0`) y `φ = 0` (`u₂ = φ₂ = 0`). Devuelve `(r, nodos, conn, u, w)`
con `w` el desplazamiento vertical del punto medio del borde libre.
"""
function scordelis(n; modo = :subdominios)
    R, L, t, E, ν = 25.0, 50.0, 0.25, 4.32e8, 0.0
    φm = deg2rad(40); r = cil_x(R)
    nodos, conn = malla_rectangular((0, L / 2), (0, φm), n, n)
    K, _, F = ensamblar(r, nodos, conn, E, ν, t; modo, f = θ -> [0, 0, -90.0])
    fij = Int[]
    for k in 1:size(nodos, 2)
        x, φ = nodos[:, k]
        x ≈ 0 && append!(fij, [gdl(k, 2), gdl(k, 3)])
        x ≈ L / 2 && append!(fij, [gdl(k, 1), gdl(k, 4)])
        φ ≈ 0 && append!(fij, [gdl(k, 2), gdl(k, 5)])
    end
    u = resolver_estatica(K, F, unique(fij))
    c = nodo_en(nodos, [L / 2, φm])
    (r, nodos, conn, u, desplazamiento_cartesiano(r, nodos, u, c)[3])
end

"""
    pinzado(n; modo)

Cilindro pinzado con diafragmas (R = 300, L = 600, t = 3, E = 3e6, ν = 0.3), un octavo del modelo con `n×n`
elementos y carga `P/4 = 0.25` radial en el vértice `(x = L/2, φ = 0)` (P = 1 en el cilindro completo).
Devuelve `(r, nodos, conn, u, w)` con `w` el desplazamiento radial bajo la carga.
"""
function pinzado(n; modo = :subdominios)
    R, L, t, E, ν = 300.0, 600.0, 3.0, 3.0e6, 0.3
    r = cil_x(R)
    nodos, conn = malla_rectangular((0, L / 2), (0, π / 2), n, n)
    K, _, _ = ensamblar(r, nodos, conn, E, ν, t; modo)
    nn = size(nodos, 2); F = zeros(5nn)
    c = nodo_en(nodos, [L / 2, 0.0]); F[gdl(c, 3)] = -0.25
    fij = Int[]
    for k in 1:nn
        x, φ = nodos[:, k]
        x ≈ 0 && append!(fij, [gdl(k, 2), gdl(k, 3)])
        x ≈ L / 2 && append!(fij, [gdl(k, 1), gdl(k, 4)])
        (φ ≈ 0 || φ ≈ π / 2) && append!(fij, [gdl(k, 2), gdl(k, 5)])
    end
    u = resolver_estatica(K, F, unique(fij))
    (r, nodos, conn, u, u[gdl(c, 3)])
end

"""
    hypar_estatico(n, c; t, E, ν, p, a, apoyo)

Paraboloide hiperbólico `z = c x y` en `[−a, a]²` con carga vertical `p` por unidad de **planta** y los cuatro bordes
apoyados (`:articulado`: `u₁ = u₂ = u₃ = 0`; `:empotrado`: además `φ₁ = φ₂ = 0`). Devuelve `(r, nodos, conn, u)`.
"""
function hypar_estatico(n, c; t = 0.01, E = 1.0e4, ν = 0.3, p = 1.0, a = 1.0, apoyo = :articulado)
    r = paraboloide_recto(c)
    nodos, conn = malla_rectangular((-a, a), (-a, a), n, n)
    f = θ -> [0.0, 0.0, -p / geometria_punto(r, θ).sa]
    K, _, F = ensamblar(r, nodos, conn, E, ν, t; f)
    fij = Int[]
    for k in 1:size(nodos, 2)
        x, y = nodos[:, k]
        if abs(x) ≈ a || abs(y) ≈ a
            append!(fij, [gdl(k, 1), gdl(k, 2), gdl(k, 3)])
            apoyo == :empotrado && append!(fij, [gdl(k, 4), gdl(k, 5)])
        end
    end
    (r, nodos, conn, resolver_estatica(K, F, unique(fij)))
end

"Resultante `N¹²` de los elementos de la fila central (`y ≈ 0`), como lista ordenada `(x_centro, N¹²)`."
function n12_fila_central(r, nodos, conn, u, E, ν, t)
    out = Tuple{Float64,Float64}[]
    h = nodos[2, conn[4, 1]] - nodos[2, conn[1, 1]]
    for e in axes(conn, 2)
        X = nodos[:, conn[:, e]]
        yc = (X[2, 1] + X[2, 4]) / 2
        abs(yc) <= h * 1.001 / 2 + 1e-12 || continue
        push!(out, ((X[1, 1] + X[1, 2]) / 2, deformaciones_medias(r, nodos, conn, e, u, E, ν, t).N[3]))
    end
    sort(out)
end

"""
    hypar_frecuencias(r, n, t, bc; k, a, E, ν, ρ)

Primeras `k` frecuencias de un hypar sobre `[−a,a]²` con `n×n` elementos. `bc = :SSSS` (diafragma de corte: sin desplazamiento
tangencial ni normal y sin giro tangente) o `:CCCC` (empotrado). Devuelve `(λ, ω, nodos, conn, V)` con `λ = ω L² √(ρt/D)`, `L = 2a`.
"""
function hypar_frecuencias(r, n, t, bc; k = 6, a = 1.0, E = 1.0e4, ν = 0.3, ρ = 1.0)
    nodos, conn = malla_rectangular((-a, a), (-a, a), n, n)
    K, M, _ = ensamblar(r, nodos, conn, E, ν, t; ρ)
    fij = Int[]
    for j in 1:size(nodos, 2)
        x, y = nodos[:, j]; e1 = abs(x) ≈ a; e2 = abs(y) ≈ a
        if bc == :SSSS
            e1 && append!(fij, [gdl(j, 2), gdl(j, 3), gdl(j, 5)])
            e2 && append!(fij, [gdl(j, 1), gdl(j, 3), gdl(j, 4)])
        else
            (e1 || e2) && append!(fij, gdl(j, 1):gdl(j, 5))
        end
    end
    ω, V = frecuencias(K, M, unique(fij); n = k)
    D = E * t^3 / (12 * (1 - ν^2))
    (ω .* (2a)^2 .* sqrt(ρ * t / D), ω, nodos, conn, V)
end
