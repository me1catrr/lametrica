# Utilidades comunes para los generadores de figuras SVG (sin dependencias).
using Geometria, LinearAlgebra

const SALIDA = joinpath(@__DIR__, "..", "..", "figures", "svg")
mkpath(SALIDA)

# Paleta semántica del libro (styles/lametrica.scss)
# PALETA-INICIO (generado por scripts/sincronizar_paleta.jl; no editar a mano)
const AZUL, NARANJA, VERDE, VIOLETA, GRIS, MALLA, OCRE =
    "#1b6ca8", "#d95f02", "#2a9d8f", "#6f42c1", "#6b7280", "#cbd5e1", "#8a5a00"
const AMBAR = NARANJA   # alias heredado de las primeras figuras
# PALETA-FIN

f(x) = string(round(x; digits = 2))

"Ventana mundo → pantalla con escalas independientes `sx`, `sy` (px por unidad)."
struct Vista
    xmin::Float64; xmax::Float64; ymin::Float64; ymax::Float64
    sx::Float64; sy::Float64; m::Float64
end
Vista(xmin, xmax, ymin, ymax; s = 70.0, sy = s, m = 28.0) =
    Vista(xmin, xmax, ymin, ymax, s, sy, m)
ancho(v::Vista) = (v.xmax - v.xmin) * v.sx + 2v.m
alto(v::Vista) = (v.ymax - v.ymin) * v.sy + 2v.m
X(v::Vista, p) = v.m + (p[1] - v.xmin) * v.sx
Y(v::Vista, p) = alto(v) - v.m - (p[2] - v.ymin) * v.sy

function linea(v, pts; color = GRIS, w = 1.5, dash = "", op = 1.0, fill = "none")
    d = join(("$(f(X(v, p))),$(f(Y(v, p)))" for p in pts), " ")
    da = isempty(dash) ? "" : " stroke-dasharray=\"$dash\""
    tag = fill == "none" ? "polyline" : "polygon"
    "<$tag points=\"$d\" fill=\"$fill\" stroke=\"$color\" stroke-width=\"$w\" opacity=\"$op\"$da stroke-linejoin=\"round\"/>\n"
end

function flecha(v, a, b; color = GRIS, w = 2.4, dash = "", etiqueta = "", dx = 7, dy = -7, tam = 10)
    xa, ya, xb, yb = X(v, a), Y(v, a), X(v, b), Y(v, b)
    ang = atan(yb - ya, xb - xa)
    p1 = (xb - tam * cos(ang - 0.4), yb - tam * sin(ang - 0.4))
    p2 = (xb - tam * cos(ang + 0.4), yb - tam * sin(ang + 0.4))
    da = isempty(dash) ? "" : " stroke-dasharray=\"$dash\""
    s = "<line x1=\"$(f(xa))\" y1=\"$(f(ya))\" x2=\"$(f(xb))\" y2=\"$(f(yb))\" stroke=\"$color\" stroke-width=\"$w\"$da/>\n"
    s *= "<polygon points=\"$(f(xb)),$(f(yb)) $(f(p1[1])),$(f(p1[2])) $(f(p2[1])),$(f(p2[2]))\" fill=\"$color\"/>\n"
    isempty(etiqueta) || (s *= texto(xb + dx, yb + dy, etiqueta; color))
    s
end

SUB(t) = "<tspan dy=\"3\" font-size=\"11\">$t</tspan><tspan dy=\"-3\"> </tspan>"
texto(x, y, t; color = "#1f2937", tam = 15, ancla = "start", cursiva = true) =
    "<text x=\"$(f(x))\" y=\"$(f(y))\" fill=\"$color\" font-size=\"$tam\" text-anchor=\"$ancla\" font-family=\"Georgia, 'Times New Roman', serif\"$(cursiva ? " font-style=\"italic\"" : "")>$t</text>\n"

textov(v, p, t; kw...) = texto(X(v, p), Y(v, p), t; kw...)
punto(v, p; color = "#1f2937", r = 4) =
    "<circle cx=\"$(f(X(v, p)))\" cy=\"$(f(Y(v, p)))\" r=\"$r\" fill=\"$color\"/>\n"

function guardar(nombre, titulo, w, h, cuerpo)
    open(joinpath(SALIDA, nombre * ".svg"), "w") do io
        print(io, "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 $(f(w)) $(f(h))\" role=\"img\" aria-label=\"$titulo\">\n",
              "<title>$titulo</title>\n<rect width=\"100%\" height=\"100%\" fill=\"#ffffff\"/>\n", cuerpo, "</svg>\n")
    end
    println("  figures/svg/$nombre.svg")
end

arco(r, a, b; n = 60) = [(r * cos(t), r * sin(t)) for t in range(a, b; length = n)]
rayo(a, r0, r1) = [(r0 * cos(a), r0 * sin(a)), (r1 * cos(a), r1 * sin(a))]
ejes(v; ox = 0.0, oy = 0.0, ex = v.xmax, ey = v.ymax, lx = "x", ly = "y") =
    flecha(v, (ox, oy), (ex - 0.05, oy); color = GRIS, w = 1.2, etiqueta = lx, dx = 4, dy = 16) *
    flecha(v, (ox, oy), (ox, ey - 0.05); color = GRIS, w = 1.2, etiqueta = ly, dx = 8, dy = 6)


# ---------------------------------------------------------------------------
# Proyección ortográfica 3D → 2D (az: acimut, el: elevación) y utilidades de malla
struct Camara
    az::Float64
    el::Float64
end
dirvista(c::Camara) = (cos(c.el) * cos(c.az), cos(c.el) * sin(c.az), sin(c.el))
proy(c::Camara, p) = (-sin(c.az) * p[1] + cos(c.az) * p[2],
                      -sin(c.el) * cos(c.az) * p[1] - sin(c.el) * sin(c.az) * p[2] + cos(c.el) * p[3])
prof(c::Camara, p) = dot(p, dirvista(c))           # mayor = más cerca del observador

"Vista ajustada a un conjunto de puntos 2D."
function ventana(pts; s = 90.0, margen = 0.15)
    xs = first.(pts); ys = last.(pts)
    Vista(minimum(xs) - margen, maximum(xs) + margen, minimum(ys) - margen, maximum(ys) + margen; s)
end

"Superficie 3D por parches con algoritmo del pintor. `r(u,v)`; devuelve SVG."
function parches(v, c::Camara, r, urng, vrng; n = 14, relleno = "#e8edf6", borde = "#b8c4d9", op = 0.95)
    us = range(urng...; length = n + 1); vs = range(vrng...; length = n + 1)
    celdas = []
    for i in 1:n, j in 1:n
        P = [r(us[i], vs[j]), r(us[i+1], vs[j]), r(us[i+1], vs[j+1]), r(us[i], vs[j+1])]
        push!(celdas, (sum(prof(c, p) for p in P) / 4, [proy(c, p) for p in P]))
    end
    sort!(celdas; by = first)
    join((linea(v, vcat(q, [q[1]]); color = borde, w = 0.6, fill = relleno, op = op) for (_, q) in celdas))
end

"Curva 3D proyectada."
curva3(v, c::Camara, pts; kw...) = linea(v, [proy(c, p) for p in pts]; kw...)
flecha3(v, c::Camara, a, b; kw...) = flecha(v, proy(c, a), proy(c, b); kw...)
