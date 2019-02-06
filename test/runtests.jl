using FeatureTemplates, Test

@testset "FeatureTemplates" begin
    @test 1 == 1

    @testset "Simplest" begin
        @fx function features()
            f("bias")
        end

        @test features() == ["bias"]
    end

    @testset "Simple" begin
        @fx function features(x)
            f("bias")
            f(x)
        end

        @test features("hi") == ["bias", "x=hi"]
        @test features(1) == ["bias", "x=1"]
    end

    @testset "Duplicates" begin
        @fx function nodupes(x)
            f(x)
            f(x)
            f(x)
        end
        @test nodupes("hi") == ["x=hi"]
    end

    @testset "Loops" begin
        @fx function feats(xs)
            f(length(xs))
            for i in 1:length(xs)
                f(i, xs[i])
            end
        end

        @test feats(1:3) == ["length(xs)=3", "i=1,xs[i]=1", "i=2,xs[i]=2", "i=3,xs[i]=3"]
    end
end
