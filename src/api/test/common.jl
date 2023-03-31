@testset "common" begin
    @testset "BoundedAttributes" begin
        @testset "Dict" begin
            withenv(
                "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT" => "2",
                "OTEL_ATTRIBUTE_COUNT_LIMIT" => "1",
            ) do
                attrs = Dict("a" => 1, "b" => "bbb")
                A = BoundedAttributes(attrs)

                @test n_dropped(A) == 1
                @test length(pairs(A)) == 1
                @test length(collect(A)) == 1

                # should only work for OrderedDict
                # @test A["b"] == "bb"

                A["c"] = ["ccc", "cccc"]
                @test length(A) == 1
                @test A["c"] == ["cc", "cc"]
                @test repr(A) == "c=[\"cc\", \"cc\"]"
                @test n_dropped(A) == 2
            end
        end

        @testset "NamedTuple" begin
            withenv(
                "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT" => "2",
                "OTEL_ATTRIBUTE_COUNT_LIMIT" => "2",
            ) do
                attrs = (x = 1, y = -2.0, z = "abcdefg")
                A = BoundedAttributes(attrs)
                @test length(A) == 2
                @test n_dropped(A) == 1
                @test A[:y] == -2.0
                @test A[:z] == "ab"
                @test repr(A) == "y=-2.0,z=ab"
            end
        end
    end

    @testset "context" begin
        @test isnothing(get(current_context(), :say, nothing))

        with_context(; say = "foo") do
            @test current_context()[:say] == "foo"
            with_context(; say = "bar") do
                @test current_context()[:say] == "bar"
            end
            @test current_context()[:say] == "foo"
        end

        @test isnothing(get(current_context(), :say, nothing))

        with_context(; a = "foo") do
            with_context(; b = "bar") do
                @test current_context()[:a] == "foo"
                @test current_context()[:b] == "bar"
            end
        end
    end

    @testset "Resource" begin
        r1 = Resource((a = 1, b = 2))
        r2 = Resource((b = 3, c = 4))
        @test merge(r1, r2) == Resource((a = 1, b = 3, c = 4))
    end
end