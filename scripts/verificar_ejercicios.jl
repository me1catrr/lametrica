#!/usr/bin/env julia
# Comprueba que las respuestas numéricas de los ejercicios interactivos de book/**/*.qmd
# coinciden con el cálculo de referencia hecho con Geometria. Cada ejercicio numérico debe
# tener su cálculo en `referencia` (id → valor); si falta, falla.
# Uso:  julia --project=. scripts/verificar_ejercicios.jl
using Geometria, LinearAlgebra
raiz = normpath(joinpath(@__DIR__, ".."))

# --- Cálculos de referencia (la única fuente de las respuestas numéricas) -----------------
const B60 = [1.0 0.5; 0.0 sqrt(3) / 2]      # base oblicua a 60°
const V60 = [2.0, 1.5]
referencia = Dict{String,Float64}(
    "b2-g12" => metrica(B60)[1, 2],
    "b2-v1" => comps_contravariantes(B60, V60)[1],
    "b2-gr1" => norm(base_reciproca(B60)[:, 1]),
    "b2-v2cov" => comps_covariantes(B60, V60)[2],
    "b2-polar-vtheta" => let r = 2.0, θ = π / 6
        comps_contravariantes(base_polar(r, θ), [1.0, 0.0])[2]
    end,
    "b2-polar-vcov2" => let r = 2.0, θ = π / 6
        comps_covariantes(base_polar(r, θ), [1.0, 0.0])[2]
    end,
)

# --- Lectura de los .qmd ------------------------------------------------------------------
fallos = 0; vistos = 0
for (dir, _, ficheros) in walkdir(joinpath(raiz, "book")), f in ficheros
    endswith(f, ".qmd") || continue
    txt = read(joinpath(dir, f), String)
    for m in eachmatch(r"\.ejercicio[^}]*tipo=\"numerico\"[^}]*\}", txt)
        cab = m.match
        id = match(r"id=\"([^\"]+)\"", cab); resp = match(r"respuesta=\"([^\"]+)\"", cab)
        tol = match(r"tol=\"([^\"]+)\"", cab)
        (id === nothing || resp === nothing) && (println("ERROR: ejercicio numérico sin id/respuesta en $f"); global fallos += 1; continue)
        global vistos += 1
        if !haskey(referencia, id.captures[1])
            println("ERROR: $(id.captures[1]) ($f) no tiene cálculo de referencia"); global fallos += 1; continue
        end
        esperado = referencia[id.captures[1]]
        dado = parse(Float64, replace(resp.captures[1], "," => "."))
        t = tol === nothing ? "1%" : tol.captures[1]
        rel = endswith(t, "%") ? parse(Float64, t[1:end-1]) / 100 : parse(Float64, replace(t, "abs:" => ""))
        lim = endswith(t, "%") ? abs(esperado) * rel : rel
        # la respuesta publicada debe estar dentro de una décima de la tolerancia admitida
        if abs(dado - esperado) > max(lim / 5, 1e-9)
            println("ERROR: $(id.captures[1]): respuesta del texto $dado ≠ referencia $esperado"); global fallos += 1
        end
    end
end
println(fallos == 0 ? "OK: $vistos ejercicios numéricos coinciden con Geometria." : "$fallos errores.")
exit(fallos == 0 ? 0 : 1)
