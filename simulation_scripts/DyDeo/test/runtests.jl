using DyDeo
using Base.Test
using TestSetExtensions




# write your own tests here
@testset ExtendedTestSet "All the tests" begin
    @testset "Level1" begin
        @test true
        @test 1 == 1
    end
    @testset "2nd level" begin
        @test true
        @test false
        @test 1 == 1
    end
end

