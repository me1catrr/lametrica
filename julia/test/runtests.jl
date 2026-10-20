using Test
using LinearAlgebra
using Geometria

@testset "Bases covariantes y contravariantes" begin
    @testset "Aritmética exacta (racionales)" begin
        B = [2//1 1//1; 0//1 3//1]   # g₁ = (2,0), g₂ = (1,3): oblicua
        V = [5//1, 4//1]
        @test metrica(B) == [4//1 2//1; 2//1 10//1]
        @test reciprocidad(B) == Matrix{Rational{Int}}(I, 2, 2)
        Vup = comps_contravariantes(B, V)
        Vdn = comps_covariantes(B, V)
        @test desde_contravariantes(B, Vup) == V             # V = Vⁱ gᵢ
        @test Vdn == metrica(B) * Vup                          # Vᵢ = gᵢⱼ Vʲ
        @test dot(Vup, Vdn) == dot(V, V)                       # |V|² = Vⁱ Vᵢ
    end

    @testset "Coordenadas polares" begin
        for (r, θ) in ((1.0, 0.3), (2.5, 1.9), (0.7, -2.2))
            B = base_polar(r, θ)
            @test metrica(B) ≈ [1.0 0.0; 0.0 r^2] atol = 1e-12
            @test reciprocidad(B) ≈ I(2) atol = 1e-12
            V = [0.4, -1.3]
            @test desde_contravariantes(B, comps_contravariantes(B, V)) ≈ V atol = 1e-12
            # Con base ortogonal: Vⁱ = Vᵢ / gᵢᵢ (sin suma)
            Vup, Vdn = comps_contravariantes(B, V), comps_covariantes(B, V)
            @test Vup ≈ [Vdn[1], Vdn[2] / r^2] atol = 1e-12
        end
    end

    @testset "Invariantes de la base" begin
        B = [1.3 -0.4; 0.2 0.9]
        g = metrica(B)
        @test issymmetric(g)
        @test isposdef(g)
        @test det(g) ≈ det(B)^2
    end
end
