#!/usr/bin/env julia
# Genera la estructura del libro a partir de temario.toml:
#   _navegacion.yml   capítulos de la barra lateral (solo temas con archivo existente)
#   book/mapa.qmd     «Mapa del libro» (índice público con estado y prerrequisitos)
# Uso:  julia scripts/generar_estructura.jl            (escribe)
#       julia scripts/generar_estructura.jl --check    (falla si hay desajustes)
using TOML
raiz = normpath(joinpath(@__DIR__, ".."))
t = TOML.parsefile(joinpath(raiz, "temario.toml"))
bloques = t["bloque"]
estados = Dict("publicado" => "● publicado", "borrador" => "◐ en reescritura", "pendiente" => "○ por escribir")

# --- validación
ids = String[]
for b in bloques, tm in b["tema"]; push!(ids, tm["id"]); end
@assert length(unique(ids)) == length(ids) "ids repetidos"
errores = String[]
for b in bloques, tm in b["tema"]
    for r in get(tm, "requiere", String[])
        r in ids || push!(errores, "$(tm["id"]) requiere $r, que no existe")
    end
    a = get(tm, "archivo", "")
    if tm["estado"] != "pendiente" && (isempty(a) || !isfile(joinpath(raiz, a)))
        push!(errores, "$(tm["id"]) está $(tm["estado"]) pero su archivo no existe: '$a'")
    end
    if tm["estado"] == "pendiente" && !isempty(a) && isfile(joinpath(raiz, a))
        push!(errores, "$(tm["id"]) figura como pendiente pero ya tiene archivo $a")
    end
end
if !isempty(errores)
    foreach(e -> println("ERROR: ", e), errores); exit(1)
end

# --- _navegacion.yml
io = IOBuffer()
println(io, "# GENERADO por scripts/generar_estructura.jl a partir de temario.toml. No editar a mano.")
println(io, "book:\n  chapters:\n    - index.qmd\n    - book/mapa.qmd")
for b in bloques
    con_archivo = [tm for tm in b["tema"] if !isempty(get(tm, "archivo", "")) && tm["estado"] != "pendiente"]
    isempty(con_archivo) && continue
    println(io, "    - part: \"Bloque $(b["id"]) · $(b["titulo"])\"\n      chapters:")
    for tm in con_archivo; println(io, "        - ", tm["archivo"]); end
end
println(io, "    - book/referencias.qmd")
println(io, "  appendices:\n    - book/apendices/notacion.qmd")
nav = String(take!(io))

# --- mapa.qmd
io = IOBuffer()
println(io, "# Mapa del libro {.unnumbered}\n\n*Siete bloques y 36 temas, de la geometría a los elementos finitos.*\n")
println(io, "<!-- GENERADO por scripts/generar_estructura.jl a partir de temario.toml. No editar a mano. -->\n")
println(io, "Este es el recorrido completo del libro. Cada bloque responde a una pregunta y cada tema se apoya en los anteriores. Los temas marcados como *por escribir* aparecerán a medida que avance el libro.\n")
n = sum(length(b["tema"]) for b in bloques)
publ = count(tm["estado"] == "publicado" for b in bloques for tm in b["tema"])
bor = count(tm["estado"] == "borrador" for b in bloques for tm in b["tema"])
println(io, "**Estado:** $publ temas publicados, $bor en reescritura y $(n - publ - bor) por escribir (de $n).\n")
for b in bloques
    println(io, "## Bloque $(b["id"]) · $(b["titulo"]) {.unnumbered}\n")
    println(io, "::: {.pregunta-guia}\n$(strip(b["pregunta"], ['?', '¿']))\n:::\n")
    println(io, "| Tema | Título | Estado | Se apoya en |\n|:--|:--|:--|:--|")
    for tm in b["tema"]
        titulo = tm["titulo"]
        a = get(tm, "archivo", "")
        if tm["estado"] != "pendiente" && !isempty(a)
            rel = relpath(joinpath(raiz, a), joinpath(raiz, "book"))
            titulo = "[$titulo]($(replace(rel, ".qmd" => ".html")))"
        end
        req = isempty(get(tm, "requiere", String[])) ? "—" : join(tm["requiere"], ", ")
        println(io, "| $(tm["id"]) | $titulo | $(estados[tm["estado"]]) | $req |")
    end
    println(io)
end
mapa = String(take!(io))

if "--check" in ARGS
    ok = read(joinpath(raiz, "_navegacion.yml"), String) == nav && read(joinpath(raiz, "book", "mapa.qmd"), String) == mapa
    println(ok ? "OK: estructura al día." : "DESACTUALIZADO: ejecuta scripts/generar_estructura.jl")
    exit(ok ? 0 : 1)
end
write(joinpath(raiz, "_navegacion.yml"), nav)
write(joinpath(raiz, "book", "mapa.qmd"), mapa)
println("escrito: _navegacion.yml y book/mapa.qmd ($n temas)")
