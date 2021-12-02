@testset "Limited" begin
    @testset "Limited Array" begin
        L1 = Limited([1, 2, 3]; limit = 5)

        @test n_dropped(L1) == 0

        for i = 4:8
            push!(L1, i)
        end

        @test n_dropped(L1) == 3

        L1[1] = 0

        @test L1[1] == 0
    end

    @testset "Limited Dict" begin
        L1 = Limited(Dict("a" => 1, "b" => 2); limit = 1)

        @test n_dropped(L1) == 1

        L1["c"] = 3

        @test_throws KeyError L1["c"]
        @test n_dropped(L1) == 2
    end
end

@testset "StaticAttrs" begin
    A = StaticAttrs()
    @test length(A) == 0

    A1 = StaticAttrs((x = 1, y = -2.0, z = "abcdefg"); value_length_limit = 3)
    @test A1["x"] == 1
    @test A1["z"] == "abc"

    A2 = StaticAttrs((; :x => 1, :y => -2.0, :z => "0"))
    @test A2[:z] == "0"

    @test_throws MethodError StaticAttrs("abc" => nothing)
end

@testset "DynamicAttrs" begin
    d = DynamicAttrs("a" => 1; count_limit = 4, value_length_limit = 5)
    d["b"] = "bbbbb"
    d["c"] = "ccccc" * "extra"
    d["d"] = ["ddddd" * "extra", "dd"]
    d["e"] = "???"

    @test length(d) == 4
    @test n_dropped(d) == 1
    @test d["b"] == "bbbbb"
    @test d["c"] == "ccccc"
    @test d["d"] == ["ddddd", "dd"]

    d["b"] = "bbbbbbbbbb"
    @test d["b"] == "bbbbb"

    # count_limit exceeded
    d["x"] = "abcdefg"
    @test_throws KeyError d["x"]
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
        Threads.@spawn begin
            with_context(; b = "bar") do
                Threads.@spawn begin
                    @test current_context()[:a] == "foo"
                    @test current_context()[:b] == "bar"
                end
            end
        end
    end
end
