@testset "attributes" begin
    a = Attributes()

    @test_throws MethodError a["?"] = 1

    b1 = Attributes("m.x" => 1, "m.y" => -2.)
    b2 = Attributes("m.y" => -2., "m.x" => 1)
    @test b1 == b2
    @test b1["m.x"] == 1
    @test b2["m.y"] == -2.

    c1 = Attributes((x=1, y=-2.))
    c2 = Attributes("y" => -2., "x" => 1)
    @test c1 == c2
    @test c1["x"] == 1
    @test c2[:y] == -2.

    d = Attributes(;count_limit=3,value_length_limit=5, is_mutable=true)
    d["a"] = 1
    d["b"] = "bbbbb"
    d["c"] = "ccccc" * "extra"
    d["d"] = "???"

    @test length(d) == 3
    @test n_dropped(d) == 1
    @test d["b"] == "bbbbb"
    @test d["c"] == "ccccc"
end