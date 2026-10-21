# Verificación numérica de los apuntes del autor docs/Ejemplos/body_forces.pdf (serie SD-12).
# Los apuntes están marcados por el autor como «Wrong! See BF-1÷8»; esas páginas no están
# disponibles, así que esto evalúa SD-12 tal como está, sin darlo por válido ni por inválido.
#
# Modelo (notación de los apuntes): desplazamiento virtual a través del espesor
#   δu(θ) = (δu_ρ + θ δψ_ρ) aᵖ + δu₃ â₃,   dV = μ dθ dF,   μ = 1 − 2Hθ + Kθ²,
#   δu_α(3D) = μᵖ_α (δu_ρ + θ δψ_ρ),       μᵖ_α = δᵖ_α − θ bᵖ_α.
# «Exacto» = ∫ δu(θ)·b dV con b un vector fijo (peso propio): no depende de ninguna
# aproximación de los apuntes.
#
# Uso (desde la raíz del repositorio):
#   julia --project=julia julia/scripts/verificar_fuerzas_volumen.jl
# (en el sandbox de Claude Code: JULIA_DEPOT_PATH="$TMPDIR/depot:$HOME/.julia")

using Geometria
using LinearAlgebra
using Printf
using Random

Random.seed!(20261021)

# ---------------------------------------------------------------- utilidades

# Cuadratura de Gauss–Legendre de 3 puntos en [−t/2, t/2]: exacta hasta grado 5.
function integrar_espesor(f, t)
    nodos = (-sqrt(3 / 5), 0.0, sqrt(3 / 5))
    pesos = (5 / 9, 8 / 9, 5 / 9)
    (t / 2) * sum(w * f(t / 2 * x) for (x, w) in zip(nodos, pesos))
end

# Datos geométricos de la superficie media en un punto.
function geom(r, θ)
    A = base_superficie(r, θ)
    a = metrica(A)
    b = segunda_forma(r, θ)
    n = normal_unitaria(A)
    bm = tensor_curvatura_mixto(a, b)             # bm[ρ,α] = bᵖ_α
    cp = curvaturas_principales(a, b)
    (; A, a, b, n, bm, H = cp.H, K = cp.K, κ = cp.κ, Ar = A * inv(a))
end

# Las tres integrales «de los apuntes» para un caso (g = geom, X = vector fijo,
# δu_ρ, δψ_ρ covariantes, δu₃).
function trabajos(g, X, duc, dpsi, du3, t)
    (; A, n, bm, H, K, Ar) = g
    bα = Ar' * X                                  # bα = aα·X (componentes contravariantes en aα)
    b3 = dot(n, X)
    μ(θ) = 1 - 2H * θ + K * θ^2
    # Exacto: ∫ δu(θ)·X μ dθ
    exacto = integrar_espesor(θ -> dot(Ar * (duc + θ * dpsi) + n * du3, X) * μ(θ), t)
    # Primera línea de SD-12/1: ∫ μᵖ_α bα (δu_ρ + θδψ_ρ) μ dθ + b³δu₃ μ  (bα constante en θ)
    sd12 = integrar_espesor(θ -> (dot((I - θ * bm)' * (duc + θ * dpsi), bα) + b3 * du3) * μ(θ), t)
    # Desarrollo de SD-12/2, potencias pares (∫θ² = t³/12, ∫θ⁴ = t⁵/80)
    m0, m2, m4 = t, t^3 / 12, t^5 / 80
    Suu, Sψ = dot(bα, duc), dot(bα, dpsi)
    bb = bm * bα
    Bu, Bψ = dot(bb, duc), dot(bb, dpsi)
    base = m0 * (Suu + b3 * du3)
    p2 = base + m2 * (-Bψ - 2H * Sψ + 2H * Bu + K * Suu + K * b3 * du3) - m4 * K * Bψ
    p2_signo_menos = base + m2 * (-Bψ - 2H * Sψ - 2H * Bu + K * Suu + K * b3 * du3) - m4 * K * Bψ
    # SD-12/3 «como está escrito» (signo − en 2Hθ² bᵖ_α bα δu_ρ; sin términos en K ni θ⁴)
    p3_escrito = base + m2 * (-Bψ - 2H * Sψ - 2H * Bu)
    # SD-12/3 con el signo que da el desarrollo de la pág. 2
    p3_corregido = base + m2 * (-Bψ - 2H * Sψ + 2H * Bu)
    (; exacto, sd12, p2, p2_signo_menos, p3_escrito, p3_corregido, hoja = base, bα, b3)
end

relerr(x, ref) = abs(x - ref) / abs(ref)
const ok_ = Ref(0)
const fallos = String[]
function chequeo(nombre, cond)
    cond ? (ok_[] += 1) : push!(fallos, nombre)
    @printf("  [%s] %s\n", cond ? "OK " : "FALLO", nombre)
end

# ---------------------------------------------------------------- superficies de los apuntes
R = 2.0
cilindro = (nombre = "cilindro (cylindrical.pdf)",
            r = θ -> [R * sin(θ[1]), θ[2], R * cos(θ[1])], θ = [0.4, 0.3])
esfera = (nombre = "esfera (sphere.pdf)",
          r = θ -> [R * cos(θ[2]) * cos(θ[1]), R * cos(θ[2]) * sin(θ[1]), R * sin(θ[2])], θ = [0.5, 0.3])
ha, hb, hc = 1.0, 1.2, 0.15
hypar = (nombre = "hypar (hypar.pdf)",
         r = θ -> [ha * θ[1], hb * θ[2], hc * (θ[1]^2 - θ[2]^2)], θ = [0.7, -0.4])
casos = (cilindro, esfera, hypar)

println("="^78)
println("0. Convenio de los apuntes: H = ½ bᵅ_α, K = det bᵅ_β con la normal de a₁×a₂")
for c in casos
    g = geom(c.r, c.θ)
    @printf("  %-28s H = %+.6f   K = %+.6f\n", c.nombre, g.H, g.K)
end
gc = geom(cilindro.r, cilindro.θ)
chequeo("cilindro: H = −1/(2R) (SD-12/2) y K = 0", isapprox(gc.H, -1 / (2R); atol = 1e-6) && abs(gc.K) < 1e-6)
chequeo("μ = det(I − θ b) = 1 − 2Hθ + Kθ² (esfera, θ = 0,3)",
        let g = geom(esfera.r, esfera.θ); isapprox(det(I - 0.3 * g.bm), 1 - 2g.H * 0.3 + g.K * 0.09; atol = 1e-8) end)

# ---------------------------------------------------------------- 1. álgebra págs. 1–3
println("\n", "="^78)
println("1. Álgebra de SD-12/1–3 (datos aleatorios, semilla fija, t = 0,1)")
t = 0.1
for c in casos
    g = geom(c.r, c.θ)
    X = randn(3); duc = randn(2); dpsi = randn(2); du3 = randn()
    w = trabajos(g, X, duc, dpsi, du3, t)
    println("  ", c.nombre, "   (K = ", @sprintf("%+.4f", g.K), ")")
    @printf("    exacto                         %+.12e\n", w.exacto)
    @printf("    SD-12/1 (integrada)            %+.12e   |Δ|/|exacto| = %.2e\n", w.sd12, relerr(w.sd12, w.exacto))
    @printf("    SD-12/2 (desarrollo)           %+.12e   |Δ| frente a SD-12/1 = %.2e\n", w.p2, abs(w.p2 - w.sd12))
    @printf("    SD-12/2 con −2H·Bu (signo p.3) %+.12e   |Δ| frente a SD-12/1 = %.2e\n", w.p2_signo_menos, abs(w.p2_signo_menos - w.sd12))
    @printf("    SD-12/3 como está escrito      %+.12e   |Δ| frente a SD-12/1 = %.2e\n", w.p3_escrito, abs(w.p3_escrito - w.sd12))
    @printf("    SD-12/3 con signo corregido    %+.12e   |Δ| frente a SD-12/1 = %.2e\n", w.p3_corregido, abs(w.p3_corregido - w.sd12))
    @printf("    solo término t·(bᵖδu_ρ+b³δu₃) %+.12e   |Δ| frente a SD-12/1 = %.2e\n", w.hoja, abs(w.hoja - w.sd12))
    chequeo(c.nombre * ": el desarrollo de SD-12/2 reproduce la integral de SD-12/1", isapprox(w.p2, w.sd12; rtol = 1e-10))
    chequeo(c.nombre * ": SD-12/3 con signo '−2H·Bu' (como está escrito) NO coincide", !isapprox(w.p3_escrito, w.p3_corregido; rtol = 1e-10) || abs(g.H) < 1e-12)
    # SD-12/3 corregido solo difiere de SD-12/1 por los términos en K (y θ⁴) descartados
    chequeo(c.nombre * ": SD-12/3 corregido = SD-12/1 si K = 0 (si no, difiere por términos en K)",
            abs(g.K) < 1e-6 ? isapprox(w.p3_corregido, w.sd12; rtol = 1e-9) : !isapprox(w.p3_corregido, w.sd12; rtol = 1e-9))
end

# Coeficientes de SD-12/3 en el cilindro: «(1/R)·b¹δψ₁ + (2/R)·bᵖδψ_ρ + (2/R)·b¹₁ b¹ δu₁» (a mano)
println("\n  Cilindro, términos de SD-12/3 «como están escritos» (coef. 2/R) frente a la integral de SD-12/1:")
let g = gc, c = cilindro
    X = randn(3); duc = randn(2); dpsi = randn(2); du3 = randn()
    w = trabajos(g, X, duc, dpsi, du3, t)
    bα = w.bα
    base = t * (dot(bα, duc) + w.b3 * du3)
    m2 = t^3 / 12
    p3_manual_2R = base + m2 * ((1 / R) * bα[1] * dpsi[1] + (2 / R) * dot(bα, dpsi) + (2 / R) * g.bm[1, 1] * bα[1] * duc[1])
    p3_manual_1R = base + m2 * ((1 / R) * bα[1] * dpsi[1] + (1 / R) * dot(bα, dpsi) - (1 / R) * g.bm[1, 1] * bα[1] * duc[1])
    @printf("    coef. 2/R (escrito):  %+.12e   |Δ| = %.2e\n", p3_manual_2R, abs(p3_manual_2R - w.sd12))
    @printf("    coef. 1/R (−2H = 1/R): %+.12e  |Δ| = %.2e\n", p3_manual_1R, abs(p3_manual_1R - w.sd12))
    chequeo("cilindro: el coeficiente de bᵖδψ_ρ es 1/R (=−2H), no 2/R",
            abs(p3_manual_1R - w.sd12) < abs(p3_manual_2R - w.sd12))
end

# ---------------------------------------------------------------- 2. orden del error
println("\n", "="^78)
println("2. Orden del error de «≈ 0»: cilindro, R = 2, δψ ~ δu/R (rotaciones ≈ u/R)")
println("   t/R      err.rel. t·(bᵖδu_ρ+b³δu₃) frente al exacto")
let g = gc
    X = [0.3, -0.5, 0.8]; duc = [1.0, -0.7]; du3 = 0.4
    dpsi = [0.9, -0.3] ./ R
    ε = Float64[]; hs = Float64[]
    for tr in (0.1, 0.01, 0.001)
        tt = tr * R
        w = trabajos(g, X, duc, dpsi, du3, tt)
        push!(ε, relerr(w.hoja, w.exacto)); push!(hs, tr)
        @printf("   %-7g  %.3e   (exacto − hoja)/exacto, SD-12/3 corregido: %.2e\n", tr, ε[end], relerr(w.p3_corregido, w.exacto))
    end
    pendiente = log(ε[1] / ε[3]) / log(hs[1] / hs[3])
    @printf("   pendiente log-log del error frente a t/R: %.2f\n", pendiente)
    chequeo("error de la aproximación de orden cero en t: decae como (t/R)^p con p ≈ 2", isapprox(pendiente, 2; atol = 0.1))
end

# ---------------------------------------------------------------- 3. traslación rígida
println("\n", "="^78)
println("3. Traslación rígida δu = c constante  →  trabajo exacto = (c·X)(t + K t³/12)")
for c in casos
    g = geom(c.r, c.θ)
    X = randn(3); cv = randn(3)
    duc = g.A' * cv; dpsi = zeros(2); du3 = dot(g.n, cv)
    κmax = maximum(abs, g.κ); tt = 0.1 / max(κmax, 1e-9)   # t = 0,1·R_mín
    tt = κmax < 1e-9 ? 0.1 : tt
    w = trabajos(g, X, duc, dpsi, du3, tt)
    teorico = dot(cv, X) * (tt + g.K * tt^3 / 12)
    @printf("  %-28s t = %.4f  K = %+.4f  t/R = %.3f\n", c.nombre, tt, g.K, tt * κmax)
    @printf("    exacto               = %+.10e   (c·X)(t+Kt³/12) = %+.10e\n", w.exacto, teorico)
    @printf("    t·(bᵖδu_ρ+b³δu₃)    err.rel = %.2e    (Kt²/12 = %.2e)\n", relerr(w.hoja, w.exacto), abs(g.K) * tt^2 / 12)
    @printf("    SD-12/1 (con μᵖ_α)   err.rel = %.2e\n", relerr(w.sd12, w.exacto))
    chequeo(c.nombre * ": el trabajo exacto coincide con (c·X)(t+Kt³/12)", isapprox(w.exacto, teorico; rtol = 1e-9))
end

# ---------------------------------------------------------------- 4. descomposición del peso (SD-12/5–6)
println("\n", "="^78)
println("4. Componentes pᵢ = X·(âⱼ×âₖ)/λ, λ = â₁·(â₂×â₃) (SD-12/5–6), cilindro")
X = [0.7, -1.1, 0.4]
for θ1 in (0.0, 0.4, -0.9)
    g = geom(cilindro.r, [θ1, 0.3])
    â1 = g.A[:, 1] / norm(g.A[:, 1]); â2 = g.A[:, 2] / norm(g.A[:, 2]); â3 = g.n
    λ = dot(â1, cross(â2, â3))
    p = [dot(X, cross(â2, â3)), dot(X, cross(â3, â1)), dot(X, cross(â1, â2))] ./ λ
    cerrado = [X[1] * cos(θ1) - X[3] * sin(θ1), X[2], X[1] * sin(θ1) + X[3] * cos(θ1)]
    contra = comps_contravariantes(hcat(g.A, g.n), X)       # pⁱ sobre aᵢ (|a₁| = R)
    @printf("  θ¹ = %+.1f   λ = %.6f   pᵢ = [%+.5f %+.5f %+.5f]\n", θ1, λ, p...)
    @printf("             fórmulas cerradas de SD-12/6  Δ = %.2e   |X − Σ pᵢ âᵢ| = %.2e\n",
            norm(p - cerrado), norm(X - (p[1] * â1 + p[2] * â2 + p[3] * â3)))
    @printf("             contravariantes sobre aᵢ (a₁ de longitud R): [%+.5f %+.5f %+.5f]   p₁/b¹ = %.4f (= |a₁| = R)\n", contra..., p[1] / contra[1])
    chequeo("θ¹=$(θ1): λ = 1 y pᵢ = fórmulas cerradas de SD-12/6", isapprox(λ, 1; atol = 1e-8) && isapprox(p, cerrado; atol = 1e-6))
    chequeo("θ¹=$(θ1): las pᵢ son componentes FÍSICAS (sobre âᵢ unitarios): p₁ = R·b¹", isapprox(p[1], R * contra[1]; atol = 1e-6))
end

# ---------------------------------------------------------------- 5. versión corregida
# Con las componentes X^ρ = aᵖ·X y X³ = â₃·X del peso sobre la base de la SUPERFICIE MEDIA
# (independientes de θ), δu·X = (δu_ρ + θδψ_ρ)X^ρ + δu₃X³ y no aparece μᵖ_α. Los momentos
# de μ = 1 − 2Hθ + Kθ² dan:
#     ∫ μ dθ = t(1 + K t²/12),      ∫ θ μ dθ = −H t³/6.
# Versión corregida (exacta bajo la cinemática de los apuntes):
#     δW = ∫_F [ t(1 + K t²/12)(X^ρ δu_ρ + X³ δu₃) − (H t³/6) X^ρ δψ_ρ ] dF
# y, a orden (t/R)² relativo:  δW ≈ t ∫_F (X^ρ δu_ρ + X³ δu₃) dF.
function trabajo_corregido(g, X, duc, dpsi, du3, t)
    Xρ = g.Ar' * X
    X3 = dot(g.n, X)
    t * (1 + g.K * t^2 / 12) * (dot(Xρ, duc) + X3 * du3) - (g.H * t^3 / 6) * dot(Xρ, dpsi)
end

println("\n", "="^78)
println("5. Versión corregida δW = t(1+Kt²/12)(X^ρδu_ρ+X³δu₃) − (H t³/6) X^ρδψ_ρ  (datos aleatorios, δψ ≠ 0)")
for c in casos, tt in (0.2, 0.05)
    g = geom(c.r, c.θ)
    local Xa = randn(3); local duc = randn(2); local dpsi = randn(2); local du3 = randn()
    w = trabajos(g, Xa, duc, dpsi, du3, tt)
    wc = trabajo_corregido(g, Xa, duc, dpsi, du3, tt)
    w0 = tt * (dot(w.bα, duc) + w.b3 * du3)
    @printf("  %-28s t = %.2f   |corregida − exacta|/|exacta| = %.1e   (solo orden cero: %.1e;  SD-12/1: %.1e)\n",
            c.nombre, tt, relerr(wc, w.exacto), relerr(w0, w.exacto), relerr(w.sd12, w.exacto))
    chequeo(c.nombre * ", t=$tt: la versión corregida coincide con la integral exacta", isapprox(wc, w.exacto; rtol = 1e-10))
end

# Componentes físicas en el cilindro (base ortogonal): X^ρδu_ρ = X_(ρ) δu_(ρ), con
# X_(ρ) = X·âρ (= pᵢ de SD-12/6) y δu_(ρ) = δu·âρ.
let g = gc
    X = randn(3); duc = randn(2); dpsi = randn(2); du3 = randn(); tt = 0.2
    â = [g.A[:, k] / norm(g.A[:, k]) for k in 1:2]
    Xf = [dot(X, â[k]) for k in 1:2]
    duf = [duc[k] / norm(g.A[:, k]) for k in 1:2]      # δu_(ρ) = δu_ρ/|aρ|
    dpf = [dpsi[k] / norm(g.A[:, k]) for k in 1:2]
    wfis = tt * (1 + g.K * tt^2 / 12) * (dot(Xf, duf) + dot(g.n, X) * du3) - (g.H * tt^3 / 6) * dot(Xf, dpf)
    chequeo("cilindro: la misma expresión en componentes físicas (X_(ρ), δu_(ρ), δψ_(ρ)) da el mismo valor",
            isapprox(wfis, trabajo_corregido(g, X, duc, dpsi, du3, tt); rtol = 1e-10))
end

println("\n", "="^78)
@printf("Resumen: %d comprobaciones superadas, %d con fallo\n", ok_[], length(fallos))
foreach(f -> println("  FALLO: ", f), fallos)
