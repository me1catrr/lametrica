# Contraste de los apuntes del autor docs/Ejemplos/hypar.pdf (págs. 1–3) y sphere.pdf (pág. 1)
# con Geometria.jl. Las expresiones de los apuntes se han transcrito a mano (sin verificar
# hasta que este script las compara).
#
# Uso (desde la raíz del repositorio):
#   julia --project=julia julia/scripts/verificar_apuntes_geometria.jl

using Geometria
using LinearAlgebra
using Printf

n_ok = 0
fallos = String[]
function chequeo(nombre, cond)
    global n_ok
    cond ? (n_ok += 1) : push!(fallos, nombre)
    @printf("  [%s] %s\n", cond ? "OK " : "FALLO", nombre)
end

# ------------------------------------------------------------------ hypar.pdf
# r = (aθ¹, bθ², c((θ¹)²−(θ²)²))
a, b, c = 1.0, 1.2, 0.15
θ1, θ2 = 0.7, -0.4
r = θ -> [a * θ[1], b * θ[2], c * (θ[1]^2 - θ[2]^2)]
A = base_superficie(r, [θ1, θ2])
g = metrica(A)
n = normal_unitaria(A)
bαβ = segunda_forma(r, [θ1, θ2])
println("hypar.pdf (a, b, c) = ($a, $b, $c), θ = ($θ1, $θ2)")

det_ap = (a * b)^2 + (2b * c * θ1)^2 + (2a * c * θ2)^2             # DG-1
W = sqrt((a * b)^2 + 4 * ((b * c * θ1)^2 + (a * c * θ2)^2))
chequeo("DG-1: a₁ = (a, 0, 2cθ¹), a₂ = (0, b, −2cθ²)", isapprox(A, [a 0; 0 b; 2c * θ1 -2c * θ2]; atol = 1e-7))
chequeo("DG-1: â₃ = (−2bcθ¹, 2acθ², ab)/W", isapprox(n, [-2b * c * θ1, 2a * c * θ2, a * b] / W; atol = 1e-8))
chequeo("DG-1: a₁₁ = a²+4c²(θ¹)², a₂₂ = b²+(2cθ²)², a₁₂ = −4c²θ¹θ²",
        isapprox(g, [a^2 + 4c^2 * θ1^2  -4c^2 * θ1 * θ2; -4c^2 * θ1 * θ2  b^2 + (2c * θ2)^2]; atol = 1e-7))
chequeo("DG-1: det = (ab)²+(2bcθ¹)²+(2acθ²)²", isapprox(det(g), det_ap; atol = 1e-7))
ainv = inv(g)
chequeo("DG-2: a¹¹ = a₂₂/det, a²² = a₁₁/det, a¹² = −a₁₂/det",
        isapprox(ainv, [g[2, 2] -g[1, 2]; -g[1, 2] g[1, 1]] / det_ap; atol = 1e-7))
Ar = A * ainv
chequeo("DG-2: a¹ = [a(b²+(2cθ²)²), 4bc²θ¹θ², 2b²cθ¹]/det",
        isapprox(Ar[:, 1], [a * (b^2 + (2c * θ2)^2), 4b * c^2 * θ1 * θ2, 2b^2 * c * θ1] / det_ap; atol = 1e-7))
chequeo("DG-2 («OJO!»): a² = [4ac²θ¹θ², b(a²+(2cθ¹)²), −2a²cθ²]/det",
        isapprox(Ar[:, 2], [4a * c^2 * θ1 * θ2, b * (a^2 + (2c * θ1)^2), -2a^2 * c * θ2] / det_ap; atol = 1e-7))
chequeo("DG-2: aα·aᵝ = δ", isapprox(transpose(Ar) * A, I(2); atol = 1e-8))
chequeo("DG-3: b₁₁ = 2abc/W, b₂₂ = −2abc/W, b₁₂ = 0 (convenio bαβ = â₃·aα,β)",
        isapprox(bαβ, [2a * b * c / W 0; 0 -2a * b * c / W]; atol = 1e-5))
bm = tensor_curvatura_mixto(g, bαβ)
# apuntes: b¹₁, b²₂, b²₁ (= +8abc³θ¹θ²/(det W)), b¹₂ (= −8abc³θ¹θ²/(det W)); bm[α,β] = bᵅ_β
bm_ap = [2a * b * c * (b^2 + 4c^2 * θ2^2)   -8a * b * c^3 * θ1 * θ2;
         8a * b * c^3 * θ1 * θ2             -2a * b * c * (a^2 + 4c^2 * θ1^2)] / (det_ap * W)
chequeo("DG-3: b¹₁, b²₂, b²₁, b¹₂ de los apuntes", isapprox(bm, bm_ap; atol = 1e-5))

# ------------------------------------------------------------------ sphere.pdf (SPHG-01)
println("\nsphere.pdf (R = 2, θ¹ = θ azimut, θ² = φ latitud)")
R = 2.0; th, ph = 0.5, 0.3
rs = θ -> [R * cos(θ[2]) * cos(θ[1]), R * cos(θ[2]) * sin(θ[1]), R * sin(θ[2])]
As = base_superficie(rs, [th, ph])
ns = normal_unitaria(As)
chequeo("SPHG-01: a₁ = (−R cosφ sinθ, R cosφ cosθ, 0)", isapprox(As[:, 1], [-R * cos(ph) * sin(th), R * cos(ph) * cos(th), 0]; atol = 1e-7))
chequeo("SPHG-01: a₂ = (−R sinφ cosθ, −R sinφ sinθ, R cosφ)", isapprox(As[:, 2], [-R * sin(ph) * cos(th), -R * sin(ph) * sin(th), R * cos(ph)]; atol = 1e-7))
chequeo("SPHG-01: |a₁×a₂| = R² cosφ", isapprox(norm(cross(As[:, 1], As[:, 2])), R^2 * cos(ph); atol = 1e-6))
chequeo("SPHG-01: â₃ = (cosφ cosθ, cosφ sinθ, sinφ) (saliente)", isapprox(ns, [cos(ph) * cos(th), cos(ph) * sin(th), sin(ph)]; atol = 1e-8))
chequeo("convenio: esfera con normal saliente ⇒ bαβ definida negativa, K = 1/R², H = −1/R",
        let gs = metrica(As), bs = segunda_forma(rs, [th, ph]), cp = curvaturas_principales(gs, bs)
            all(<(0), eigvals(Symmetric(bs))) && isapprox(cp.K, 1 / R^2; atol = 1e-6) && isapprox(cp.H, -1 / R; atol = 1e-6)
        end)

println("\nResumen: ", n_ok, " comprobaciones superadas, ", length(fallos), " con fallo")
foreach(f -> println("  FALLO: ", f), fallos)
