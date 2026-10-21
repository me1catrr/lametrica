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
                 ancho = 560, alto = 340, leyenda = :derecha, aria = titulo, xlog = false)
    mI, mD, mS, mB = 62.0, 24.0, 18.0, 52.0
    wpx, hpx = ancho - mI - mD, alto - mS - mB
    fx(x) = mI + (xlog ? (log10(x) - log10(xlim[1])) / (log10(xlim[2]) - log10(xlim[1])) : (x - xlim[1]) / (xlim[2] - xlim[1])) * wpx
    fy(y) = mS + (1 - (y - ylim[1]) / (ylim[2] - ylim[1])) * hpx
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
