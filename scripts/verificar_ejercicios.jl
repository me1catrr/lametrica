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
    "e1-despl-medio" => (2e4 .* [2.0 -1; -1 1] \ [2500.0, 1250.0])[1],
    "e2-area" => let X = [0.0 4 5 0; 0 0 3 2]
        sum(det(vcat(formas_bilineales(ξ, η)[2]', formas_bilineales(ξ, η)[3]') * X') for ξ in Geometria.GAUSS2, η in Geometria.GAUSS2)
    end,
    "e2-k11" => (D = matriz_tension_plana(1.0, 0.3); (D[1, 1] + D[3, 3]) / 3),
    "e3-area" => let R = 500.0, X = [0.0 100 100 0; 0 0 0.1 0.1]
        r = θ -> [θ[1], R * sin(θ[2]), R * cos(θ[2])]
        sum(w * punto_elemento(r, X, ξ, η, 1.0, 0.3, 1.0)[4] for (ξ, η, w) in Geometria.puntos_gauss((-1.0, 1.0), (-1.0, 1.0), 2))
    end,
    "e4-hoop" => let R = 500.0, X = [0.0 100 100 0; 0 0 0.1 0.1]
        r = θ -> [θ[1], R * sin(θ[2]), R * cos(θ[2])]
        g, N, dN = punto_elemento(r, X, 0.3, -0.2, 1.0, 0.3, 1.0)
        δ = zeros(20); δ[3:5:20] .= 0.01
        (matrices_H(g, N, dN)[1] * δ)[2] / g.a[2, 2]
    end,
    "e4-cortante-nodo" => let X = [0.0 1 1 0; 0 0 1 1]
        g, N, dN = punto_elemento(placa_oblicua(π / 2), X, -1.0, 0.0, 1.0, 0.3, 1.0)
        δ = zeros(20); δ[3:5:20] = X[1, :].^2 ./ 2; δ[4:5:20] = -X[1, :]
        (matrices_H(g, N, dN)[3] * δ)[1]
    end,
    "e5-rigidez-espuria" => let L = 100.0, EI = 1 / 12, GA = 1 / (2 * (1 + 0.3))
        w = [GA / L -GA / 2; -GA / 2 EI / L + GA * L / 3] \ [1.0, 0.0]
        (L^3 / (3EI) + L / GA) / w[1]
    end,
    "e6-escalon" => sum((η = (1 + ξ) / 2; η + η^2) for ξ in Geometria.GAUSS2) / 2,
    "e7-energia" => let X = [0.0 1 1 0; 0 0 1 1]
        δ = zeros(20); δ[1:5:20] = 0.01 .* X[1, :]
        dot(δ, rigidez_elemento(placa_oblicua(π / 2), X, 1.0, 0.0, 1.0) * δ) / 2
    end,
    "e8-carga-nodal" => abs(cargas_elemento(placa_oblicua(π / 2), [0.0 100 100 0; 0 0 50 50], θ -> [0, 0, -0.01])[3]),
    "e8-masa" => let R = 0.5, X = [0.0 0.1 0.1 0; 0 0 0.1 0.1]
        r = θ -> [θ[1], R * sin(θ[2]), R * cos(θ[2])]
        δ = zeros(20); δ[1:5:20] .= 1.0
        dot(δ, masa_elemento(r, X, 7850.0, 0.005) * δ)
    end,
    "d3-aro-interior" => 1 / 1950,
    "d4-fibra-extrema" => (let L = 1000.0, w0 = 5.0
        w(t) = w0 * sin(π * t[1] / L)
        _, g1, _ = deformacion_lamina_lineal(placa_oblicua(π / 2), t -> [0.0, 0.0], w, t -> [-w0 * π / L * cos(π * t[1] / L), 0.0], [L / 2, 0.0])
        g1[1, 1] * 10.0
    end),
    "d5-ratio-cortante" => 8 * (1 + 0.3) / 5 * 0.1^2,
    "d6-membrana" => (let r = cilindro(2000.0), θ = [0.9, 0.3]
        γ0, _, _ = deformacion_lamina_lineal(r, t -> [0.0, 0.0], t -> 1.0, t -> [0.0, 0.0], θ)
        γ0[1, 1] / metrica_superficie(r, θ)[1, 1]
    end),
    "d6-flexion" => (let r = cilindro(2000.0), θ = [0.9, 0.3]
        _, γ1, _ = deformacion_lamina_lineal(r, t -> [0.0, 0.0], t -> 1.0, t -> [0.0, 0.0], θ)
        γ1[1, 1] / metrica_superficie(r, θ)[1, 1]
    end),
    "d7-membrana" => rigidez_lamina(Matrix(1.0I, 2, 2), 210e3, 0.3, 10.0)[1][1, 1],
    "d7-flexion" => rigidez_lamina(Matrix(1.0I, 2, 2), 210e3, 0.3, 10.0)[2][1, 1],
    "d8-barra" => 10_000.0 * 2000.0 / (210e3 * 100.0),
    "d2-mu" => lame(210e3, 0.3)[2],
    "d2-d11" => matriz_tension_plana(210e3, 0.3)[1, 1],
    "d2-d12" => matriz_tension_plana(210e3, 0.3)[1, 2],
    "d1-e11" => green_lagrange(Matrix(1.0I, 2, 2), cauchy_green([1.15 0.25; 0.0 0.95]))[1, 1],
    "d1-e12" => green_lagrange(Matrix(1.0I, 2, 2), cauchy_green([1.0 0.2; 0.0 1.0]))[1, 2],
    "c6-a12inv" => inv(metrica(base_superficie(placa_oblicua(π / 3), [0.4, 0.2])[1:2, :]))[1, 2],
    "c6-sector" => 2π * sin(π / 6),
    "c4-kg" => abs(curvaturas_curva(esfera(1.0), t -> [1.0, t], 0.7)[3]),
    "c5-k" => let r = paraboloide_curvo(3.0, -3.0), t = [1.0, -1.0]
        curvaturas_principales(metrica_superficie(r, t), segunda_forma(r, t)).K
    end,
    "c3-k45" => let r = cilindro(2.0), t = [0.7, 0.4]
        a = metrica_superficie(r, t); b = segunda_forma(r, t)
        pc = curvaturas_principales(a, b)
        # dirección a 45° de la circunferencia: λ = (cos45/|a₁|, sin45/|a₂|) en componentes contravariantes
        curvatura_normal(a, b, [cos(π / 4) / sqrt(a[1, 1]), sin(π / 4) / sqrt(a[2, 2])])
    end,
    "c3-kgauss" => let r = esfera(2.0), t = [1.0, 0.4]
        curvaturas_principales(metrica_superficie(r, t), segunda_forma(r, t)).K
    end,
    "c2-b11" => segunda_forma(cilindro(2.0), [0.7, 0.4])[1, 1],
    "c2-b11m" => (a = metrica_superficie(cilindro(2.0), [0.7, 0.4]); tensor_curvatura_mixto(a, segunda_forma(cilindro(2.0), [0.7, 0.4]))[1, 1]),
    "c1-sqrta" => sqrt(det(metrica_superficie(esfera(2.0), [1.0, 0.4]))),
    "a2-xp" => (R = [cos(π / 6) sin(π / 6); -sin(π / 6) cos(π / 6)]; (R * [3.0, 4.0])[1]),
    "a2-norma" => norm([3.0, 4.0]),
    "a2-det" => det(metrica(B60)),
    "b5-lap" => laplaciano(t -> base_polar(t[1], t[2]), t -> t[1]^3, [2.0, 0.3]),
    "b5-div-esf" => divergencia(t -> base_esferica(t[1], t[2], t[3]), t -> [t[1], 0.0, 0.0], [1.3, 0.8, 0.5]),
    "b4-g122" => cristoffel(t -> base_polar(t[1], t[2]), [2.0, π / 6])[1, 2, 2],
    "b4-dparcial" => -sin(π / 6),
    "b3-angulo" => acosd(metrica(B60)[1, 2] / sqrt(metrica(B60)[1, 1] * metrica(B60)[2, 2])),
    "b3-area" => sqrt(det(metrica(B60))),
    "b3-esfera" => let N = 600, r = esfera(2.0)
        sum(sqrt(det(metrica_superficie(r, [(i - 0.5) * π / N, (j - 0.5) * 2π / N]))) for i in 1:N, j in 1:N) * (π / N) * (2π / N)
    end,
    "b1-detj" => let r = 2.0, θ = π / 6
        a_polar(x) = [hypot(x[1], x[2]), atan(x[2], x[1])]
        det(jacobiana_numerica(a_polar, [r * cos(θ), r * sin(θ)]))
    end,
    "b1-vth" => let r = 2.0, θ = π / 6
        a_polar(x) = [hypot(x[1], x[2]), atan(x[2], x[1])]
        transformar_contra(jacobiana_numerica(a_polar, [r * cos(θ), r * sin(θ)]), [0.0, 1.0])[2]
    end,
    "a1-esbeltez" => 32 / 0.04,
    "a1-g22" => metrica(base_polar(2.0, π / 6))[2, 2],
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
