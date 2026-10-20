# Genera web/datos/bases_ref.json: casos de referencia calculados con Geometria.jl
# para verificar la implementación JavaScript (web/ojs/bases.js).
#
# Uso (desde la raíz del repositorio):
#   julia --project=. julia/scripts/generar_referencia.jl

using Geometria

casos = [
    (g1 = [1.0, 0.0], g2 = [0.0, 1.0], V = [2.0, -1.0]),
    (g1 = [2.0, 0.0], g2 = [1.0, 3.0], V = [5.0, 4.0]),
    (g1 = [1.0, 0.0], g2 = [cos(deg2rad(70)), sin(deg2rad(70))], V = [1.2, 0.8]),
    (g1 = [1.5, 0.0], g2 = [-0.4, 0.9], V = [-0.7, 1.1]),
]

vec(v) = "[" * join(v, ", ") * "]"
mat(M) = "[" * join((vec(M[i, :]) for i in 1:size(M, 1)), ", ") * "]"

io = IOBuffer()
println(io, "{")
println(io, "  \"generado_por\": \"julia/scripts/generar_referencia.jl\",")
println(io, "  \"tipo\": \"calculado\",")
println(io, "  \"julia\": \"$(VERSION)\",")
println(io, "  \"casos\": [")
for (k, c) in enumerate(casos)
    B = hcat(c.g1, c.g2)
    d = base_reciproca(B)
    println(io, "    {")
    println(io, "      \"g1\": $(vec(c.g1)), \"g2\": $(vec(c.g2)), \"V\": $(vec(c.V)),")
    println(io, "      \"g\": $(mat(metrica(B))),")
    println(io, "      \"d1\": $(vec(d[:, 1])), \"d2\": $(vec(d[:, 2])),")
    println(io, "      \"contra\": $(vec(comps_contravariantes(B, c.V))),")
    println(io, "      \"co\": $(vec(comps_covariantes(B, c.V)))")
    println(io, "    }" * (k < length(casos) ? "," : ""))
end
println(io, "  ]")
println(io, "}")

ruta = joinpath(@__DIR__, "..", "..", "web", "datos", "bases_ref.json")
mkpath(dirname(ruta))
write(ruta, take!(io))
println("Escrito ", normpath(ruta))
