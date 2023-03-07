using Test

using OpenTelemetryAPI
using OpenTelemetrySDK
using OpenTelemetryExporterPrometheus
using HTTP

@testset "PrometheusExporter" begin
    p = MeterProvider()

    m = Meter("my_metrics"; provider = p)
    c = Counter{Int}("fruit.counter", m)

    c(; name = "apple", color = "red")
    c(2; name = "lemon", color = "yellow")
    c(1; name = "lemon", color = "yellow")
    c(2; name = "apple", color = "green")
    c(5; name = "apple", color = "red")
    c(4; name = "lemon", color = "yellow")

    h = Histogram{Float64}("latency", m)

    h(0.1; code = 666)
    h(1; code = 666)
    h(21; code = 666)
    h(321; code = 666)
    h(4321; code = 666)

    h(0.1; code = 888)
    h(1; code = 888)
    h(21; code = 888)
    h(321; code = 888)
    h(4321; code = 888)

    e = PrometheusExporter()
    r = MetricReader(p, e)

    resp = HTTP.request("GET", "http://localhost:9496")
    body = split(String(resp.body), "\n"; keepempty = false)
    expected = split(
        """
        # HELP latency 
        # TYPE latency histogram
        latency_bucket{code="888",le="0.0"} 0
        latency_bucket{code="888",le="5.0"} 2
        latency_bucket{code="888",le="10.0"} 2
        latency_bucket{code="888",le="25.0"} 3
        latency_bucket{code="888",le="50.0"} 3
        latency_bucket{code="888",le="75.0"} 3
        latency_bucket{code="888",le="100.0"} 3
        latency_bucket{code="888",le="250.0"} 3
        latency_bucket{code="888",le="500.0"} 4
        latency_bucket{code="888",le="1000.0"} 4
        latency_bucket{code="888",le="+Inf"} 5
        latency_count{code="888"} 5
        latency_sum{code="888"} 4664.1
        latency_bucket{code="666",le="0.0"} 0
        latency_bucket{code="666",le="5.0"} 2
        latency_bucket{code="666",le="10.0"} 2
        latency_bucket{code="666",le="25.0"} 3
        latency_bucket{code="666",le="50.0"} 3
        latency_bucket{code="666",le="75.0"} 3
        latency_bucket{code="666",le="100.0"} 3
        latency_bucket{code="666",le="250.0"} 3
        latency_bucket{code="666",le="500.0"} 4
        latency_bucket{code="666",le="1000.0"} 4
        latency_bucket{code="666",le="+Inf"} 5
        latency_count{code="666"} 5
        latency_sum{code="666"} 4664.1
        # HELP fruit_counter 
        # TYPE fruit_counter counter
        fruit_counter{color="red",name="apple"} 6
        fruit_counter{color="green",name="apple"} 2
        fruit_counter{color="yellow",name="lemon"} 7
        """,
        "\n";
        keepempty = false,
    )

    for (expect, real) in zip(sort(expected), sort(body))
        @test startswith(real, expect)
    end
end
