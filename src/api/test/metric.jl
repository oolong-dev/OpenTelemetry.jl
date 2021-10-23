@testset "metric" begin
    m1 = Meter("test")

    counter = Counter{Int}(m1, "counter")
    counter(1)
    counter(3, "m.a" => 1, "m.b" => "b", "m.c" => 3.)

    hist = Histogram{Float64}(m1, "hist")
    hist(1)
    hist(3, "m.a" => 1, "m.b" => "b", "m.c" => 3.)

    up_down_counter = Histogram{Float64}(m1, "up_down_counter")
    up_down_counter(1)
    up_down_counter(3, "m.a" => 1, "m.b" => "b", "m.c" => 3.)

    obs_counter = ObservableCounter{Int}(m1, "obs_counter") do
        rand(1:10)
    end
    obs_counter()

    obs_gauge = ObservableGauge{Int}(m1, "obs_gauge") do
        rand(1:10)
    end
    obs_gauge()

    obs_up_down_counter = ObservableUpDownCounter{Int}(m1, "obs_up_down_counter") do
        rand(1:10)
    end
    obs_up_down_counter()

    p = global_meter_provider()
    @test length(p) == 1
    @test p["test"] === m1
end