#!/usr/bin/env julia
# Comprueba la coherencia de las figuras del libro:
#   1. todo SVG de figures/svg/ figura en figures/figures.yml;
#   2. todo `archivo:` de figures.yml existe;
#   3. toda imagen `![...](...svg){...}` de book/**/*.qmd existe y declara fig-alt;
#   4. todo SVG usado en el libro está registrado.
# Uso: julia scripts/verificar_figuras.jl
raiz = normpath(joinpath(@__DIR__, ".."))
yml = read(joinpath(raiz, "figures", "figures.yml"), String)
todos = Set(m.captures[1] for m in eachmatch(r"archivo:\s*(figures/(?:svg|img)/[^\s]+)", yml))
registrados = Set(f for f in todos if endswith(f, ".svg"))
existentes = Set("figures/svg/" * f for f in readdir(joinpath(raiz, "figures", "svg")) if endswith(f, ".svg"))
errores = String[]
for f in setdiff(existentes, registrados); push!(errores, "SVG sin registrar en figures.yml: $f"); end
for f in setdiff(registrados, existentes); push!(errores, "figures.yml cita un SVG inexistente: $f"); end
for f in todos; isfile(joinpath(raiz, f)) || push!(errores, "figures.yml cita un archivo inexistente: $f"); end
usados = Set{String}()
for (dir, _, fs) in walkdir(joinpath(raiz, "book")), f in fs
    endswith(f, ".qmd") || continue
    txt = read(joinpath(dir, f), String)
    for m in eachmatch(r"!\[[^\]]*\]\(([^)\s]+\.svg)\)(\{[^}]*\})?"s, txt)
        ruta = normpath(joinpath(dir, m.captures[1]))
        push!(usados, relpath(ruta, raiz))
        isfile(ruta) || push!(errores, "$f: imagen inexistente $(m.captures[1])")
        attrs = m.captures[2] === nothing ? "" : m.captures[2]
        occursin("fig-alt=", attrs) || push!(errores, "$f: imagen sin fig-alt: $(m.captures[1])")
    end
end
for f in setdiff(usados, registrados); push!(errores, "SVG usado pero no registrado: $f"); end
if isempty(errores)
    println("OK: $(length(existentes)) SVG registrados; $(length(usados)) usados con fig-alt.")
else
    foreach(e -> println("ERROR: ", e), errores); exit(1)
end
