#!/usr/bin/env julia
# Copia styles/paleta.yml a los tres lugares que usan colores (SCSS, figuras Julia, TikZ).
# Uso:  julia scripts/sincronizar_paleta.jl          (reescribe los bloques marcados)
#       julia scripts/sincronizar_paleta.jl --check  (falla si algo está desincronizado)
# Los bloques se delimitan con líneas que contienen PALETA-INICIO y PALETA-FIN.
raiz = normpath(joinpath(@__DIR__, ".."))
paleta = Dict{String,String}()
for l in eachline(joinpath(raiz, "styles", "paleta.yml"))
    m = match(r"^(\w+):\s*\"(#[0-9a-fA-F]{6})\"", l)
    m === nothing || (paleta[m.captures[1]] = lowercase(m.captures[2]))
end
orden = ["azul", "naranja", "verde", "gris", "violeta", "ocre", "malla"]
@assert all(haskey(paleta, k) for k in orden) "faltan colores en paleta.yml"

scss() = join(("\$$k: $(paleta[k]);" for k in orden), "\n")
julia() = "const AZUL, NARANJA, VERDE, VIOLETA, GRIS, MALLA, OCRE =\n    " *
          join(("\"$(paleta[k])\"" for k in ["azul", "naranja", "verde", "violeta", "gris", "malla", "ocre"]), ", ") *
          "\nconst AMBAR = NARANJA   # alias heredado de las primeras figuras"
tikz() = join(("\\definecolor{$k}{HTML}{$(uppercase(paleta[k][2:end]))}" for k in orden), "\n")

objetivos = [
    ("styles/lametrica.scss", "//", scss),
    ("julia/scripts/figuras_lib.jl", "#", julia),
]
for f in readdir(joinpath(raiz, "figures", "fuentes", "tikz"); join = true)
    endswith(f, ".tex") && push!(objetivos, (relpath(f, raiz), "%", tikz))
end

comprobar = "--check" in ARGS
fallos = 0
for (ruta, com, gen) in objetivos
    p = joinpath(raiz, ruta)
    txt = read(p, String)
    r = Regex("(?s)(\\Q$com PALETA-INICIO\\E[^\n]*\n).*?(\\Q$com PALETA-FIN\\E)")
    if !occursin(r, txt)
        ruta == "styles/lametrica.scss" || ruta == "julia/scripts/figuras_lib.jl" || startswith(ruta, "figures/") || continue
        println("AVISO: $ruta no tiene bloque PALETA-INICIO/FIN"); global fallos += 1; continue
    end
    m = match(r, txt)
    nuevo = txt[1:m.offset-1] * m.captures[1] * gen() * "\n" * m.captures[2] * txt[m.offset+ncodeunits(m.match):end]
    if nuevo != txt
        if comprobar
            println("DESINCRONIZADO: $ruta"); global fallos += 1
        else
            write(p, nuevo); println("actualizado: $ruta")
        end
    end
end
comprobar && fallos == 0 && println("OK: la paleta está sincronizada.")
exit(fallos == 0 ? 0 : 1)
