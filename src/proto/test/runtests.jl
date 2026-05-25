using OpenTelemetryProto
using ProtoBuf
using Test

const C = OpenTelemetryProto.opentelemetry.proto.common.v1
const R = OpenTelemetryProto.opentelemetry.proto.resource.v1
const T = OpenTelemetryProto.opentelemetry.proto.trace.v1
const COLL_T = OpenTelemetryProto.opentelemetry.proto.collector.trace.v1
const L = OpenTelemetryProto.opentelemetry.proto.logs.v1
const COLL_L = OpenTelemetryProto.opentelemetry.proto.collector.logs.v1

roundtrip(x::T) where {T} = begin
    io = IOBuffer()
    ProtoBuf.encode(ProtoEncoder(io), x)
    seekstart(io)
    ProtoBuf.decode(ProtoDecoder(io), T)
end

@testset "OpenTelemetryProto.jl" begin
    @testset "KeyValue scalar roundtrip" begin
        for (sym, val) in (
            (:string_value, "hello"),
            (:bool_value, true),
            (:int_value, Int64(-7)),
            (:double_value, 3.14),
            (:bytes_value, UInt8[0x01, 0x02, 0x03]),
        )
            kv = C.KeyValue("k", C.AnyValue(OneOf(sym, val)))
            kv2 = roundtrip(kv)
            @test kv2.key == "k"
            @test kv2.value.value.name === sym
            @test kv2.value.value[] == val
        end
    end

    @testset "Nested ArrayValue and KeyValueList" begin
        arr = C.AnyValue(OneOf(:array_value, C.ArrayValue([
            C.AnyValue(OneOf(:string_value, "a")),
            C.AnyValue(OneOf(:int_value, Int64(1))),
        ])))
        kv = C.KeyValue("arr", arr)
        kv2 = roundtrip(kv)
        @test kv2.value.value.name === :array_value
        @test length(kv2.value.value[].values) == 2
        @test kv2.value.value[].values[1].value[] == "a"
        @test kv2.value.value[].values[2].value[] == Int64(1)

        kvl = C.AnyValue(OneOf(:kvlist_value, C.KeyValueList([
            C.KeyValue("k1", C.AnyValue(OneOf(:string_value, "v1"))),
            C.KeyValue("k2", C.AnyValue(OneOf(:int_value, Int64(2)))),
        ])))
        kv3 = roundtrip(C.KeyValue("kvl", kvl))
        @test kv3.value.value.name === :kvlist_value
        @test kv3.value.value[].values[1].key == "k1"
        @test kv3.value.value[].values[2].value.value[] == Int64(2)
    end

    @testset "ExportTraceServiceRequest deeply nested" begin
        attrs = [
            C.KeyValue("service.name", C.AnyValue(OneOf(:string_value, "demo"))),
            C.KeyValue("count", C.AnyValue(OneOf(:int_value, Int64(42)))),
        ]
        res = R.Resource(attrs, UInt32(0))
        ins = C.InstrumentationScope("mylib", "1.0", C.KeyValue[], UInt32(0))
        sp = T.Span(
            UInt8[i for i in 1:16],
            UInt8[i for i in 1:8],
            "",
            UInt8[],
            "my-span",
            T.var"Span.SpanKind".SPAN_KIND_INTERNAL,
            UInt64(1),
            UInt64(2),
            attrs,
            UInt32(0),
            T.var"Span.Event"[],
            UInt32(0),
            T.var"Span.Link"[],
            UInt32(0),
            T.Status("ok", T.var"Status.StatusCode".STATUS_CODE_OK),
        )
        rs = T.ResourceSpans(res, [T.ScopeSpans(ins, [sp], "")], "")
        req = COLL_T.ExportTraceServiceRequest([rs])
        req2 = roundtrip(req)

        @test length(req2.resource_spans) == 1
        rs2 = req2.resource_spans[1]
        @test rs2.resource.attributes[1].key == "service.name"
        @test rs2.resource.attributes[1].value.value[] == "demo"
        @test rs2.resource.attributes[2].value.value[] == Int64(42)
        @test length(rs2.scope_spans) == 1
        ss = rs2.scope_spans[1]
        @test ss.scope.name == "mylib"
        @test ss.scope.version == "1.0"
        @test length(ss.spans) == 1
        s = ss.spans[1]
        @test s.name == "my-span"
        @test s.kind == T.var"Span.SpanKind".SPAN_KIND_INTERNAL
        @test s.start_time_unix_nano == 1
        @test s.end_time_unix_nano == 2
        @test s.status.code == T.var"Status.StatusCode".STATUS_CODE_OK
        @test s.status.message == "ok"
    end

    @testset "ExportLogsServiceRequest with body" begin
        attrs = [C.KeyValue("a", C.AnyValue(OneOf(:string_value, "b")))]
        res = R.Resource(attrs, UInt32(0))
        ins = C.InstrumentationScope("logger", "0.1", C.KeyValue[], UInt32(0))
        lr = L.LogRecord(
            UInt64(100),
            UInt64(101),
            L.SeverityNumber.SEVERITY_NUMBER_INFO,
            "INFO",
            C.AnyValue(OneOf(:string_value, "hello log")),
            attrs,
            UInt32(0),
            UInt32(1),
            UInt8[i for i in 1:16],
            UInt8[i for i in 1:8],
        )
        rl = L.ResourceLogs(res, [L.ScopeLogs(ins, [lr], "")], "")
        req = COLL_L.ExportLogsServiceRequest([rl])
        req2 = roundtrip(req)

        rl2 = req2.resource_logs[1]
        @test rl2.resource.attributes[1].key == "a"
        lr2 = rl2.scope_logs[1].log_records[1]
        @test lr2.body.value[] == "hello log"
        @test lr2.severity_number == L.SeverityNumber.SEVERITY_NUMBER_INFO
        @test lr2.severity_text == "INFO"
    end

    @testset "Unknown fields are skipped" begin
        # Encode a KeyValue, then prepend a stray unknown tag (field 99, varint)
        # to verify decoders properly invoke `skip` for unknown wire data.
        kv = C.KeyValue("k", C.AnyValue(OneOf(:string_value, "v")))
        io = IOBuffer()
        ProtoBuf.encode(ProtoEncoder(io), kv)
        body = take!(io)

        io2 = IOBuffer()
        # tag for field 99, varint wire type (0): (99 << 3) | 0 = 792 → varint bytes
        write(io2, UInt8(0x98), UInt8(0x31)) # 792 as varint
        write(io2, UInt8(0x00))              # varint value 0
        write(io2, body)
        seekstart(io2)
        kv2 = ProtoBuf.decode(ProtoDecoder(io2), C.KeyValue)
        @test kv2.key == "k"
        @test kv2.value.value[] == "v"
    end
end
