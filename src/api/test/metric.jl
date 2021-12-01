@testset "metric" begin
    m1 = Meter("test")

    counter = Counter{Int}("counter", m1)
    counter(1)
    counter(3; a = 1, m = "b", c = 3.0)
    @test_throws ArgumentError counter(-1)

    hist = Histogram{Float64}("hist", m1)
    hist(1)
    hist(3; a = 1, b = "b", c = 3.0)

    up_down_counter = UpDownCounter{Int}("up_down_counter", m1)
    up_down_counter(1)
    up_down_counter(3; a = 1, b = "b", c = 3.0)

    obs_counter = ObservableCounter{Int}("obs_counter", m1) do
        rand(1:10)
    end
    obs_counter()

    obs_gauge = ObservableGauge{Int}("obs_gauge", m1) do
        rand(1:10)
    end
    obs_gauge()

    obs_up_down_counter = ObservableUpDownCounter{Int}("obs_up_down_counter", m1) do
        rand(1:10)
    end
    obs_up_down_counter()
end
