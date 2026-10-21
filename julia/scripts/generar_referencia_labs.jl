# Genera web/datos/labs_ref.json: valores de referencia (Geometria) para los laboratorios JS
# de web/ojs/laboratorios.js.   julia --project=. julia/scripts/generar_referencia_labs.jl
using Geometria, LinearAlgebra
raiz = normpath(joinpath(@__DIR__, "..", ".."))
nums(x) = "[" * join((repr(Float64(v)) for v in x), ",") * "]"
fila(M) = "[" * join((nums(M[i, :]) for i in 1:size(M, 1)), ",") * "]"

polares = [(1.7, 0.6, [1.0, 0.0]), (2.0, π / 6, [1.0, 0.0]), (0.8, 2.2, [-0.4, 1.3])]
hypars = [(3.0, -2.0, 0.7, -0.4), (3.0, -3.0, 0.0, 0.0), (2.5, -4.0, 1.1, 0.9)]
eulers = [(-0.3, 0.46, 0.8), (0.5, 0.5, 1.3), (-1.0, 2.0, 2.4)]

io = IOBuffer()
println(io, "{\n  \"polares\": [")
println(io, join((let B = base_polar(r, t)
    "    {\"r\": $r, \"t\": $t, \"V\": $(nums(V)), \"g\": $(fila(metrica(B))), \"up\": $(nums(comps_contravariantes(B, V))), \"dn\": $(nums(comps_covariantes(B, V)))}"
end for (r, t, V) in polares), ",\n"))
println(io, "  ],\n  \"hypar\": [")
println(io, join((let rr = paraboloide_curvo(Rx, Ry), th = [x, y]
    a = metrica_superficie(rr, th); b = segunda_forma(rr, th); pc = curvaturas_principales(a, b)
    "    {\"Rx\": $Rx, \"Ry\": $Ry, \"x\": $x, \"y\": $y, \"a\": $(fila(a)), \"b\": $(fila(b)), \"K\": $(pc.K), \"H\": $(pc.H), \"k\": $(nums(pc.κ))}"
end for (Rx, Ry, x, y) in hypars), ",\n"))
println(io, "  ],\n  \"euler\": [")
println(io, join(("    {\"k1\": $k1, \"k2\": $k2, \"phi\": $φ, \"kappa\": $(k1 * cos(φ)^2 + k2 * sin(φ)^2)}" for (k1, k2, φ) in eulers), ",\n"))
println(io, "  ]\n}")
write(joinpath(raiz, "web", "datos", "labs_ref.json"), String(take!(io)))
println("escrito web/datos/labs_ref.json")
