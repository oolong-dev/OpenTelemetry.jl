@testset "propagators" begin
    test_trace_id = TraceIdType(12345678901234567890123456789012)
    test_span_id = SpanIdType(1234567890123456)
    tracestate_value = "foo=1,bar=2,baz=3"
    header = [
        "traceparent" => "00-$test_trace_id-$test_span_id-00",
        "tracestate" => tracestate_value,
    ]

    with_context(; x = 123) do
        ctx = extract_context(header)
        @test ctx[:x] == 123
        @test ctx |> current_span |> span_status == SpanStatus(SPAN_STATUS_UNSET)

        sc = span_context(ctx)
        @test sc.trace_id == test_trace_id
        @test sc.span_id == test_span_id
        @test string(sc.trace_state) ==
              string(TraceState("foo" => "1", "bar" => "2", "baz" => "3"))
        @test sc.trace_flag == TraceFlag(false)
    end

    header = Dict("Content-Type" => "text/plain")
    with_span("test") do
        inject_context!(header)
        @test header["traceparent"] ==
              "00-00000000000000000000000000000000-0000000000000000-00"  # invalid trace parent
        @test !haskey(header, "tracestate")
    end

    inject_context!(nothing)  # Should not throw error
    extract_context(nothing)  # Should not throw error
end
