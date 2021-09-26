using OpenTelemetryProto: OpentelemetryClients
using Test

@testset "OpenTelemetryProto.jl" begin

req = OpentelemetryClients.opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest(
    resource_spans=[
        OpentelemetryClients.opentelemetry.proto.trace.v1.ResourceSpans(
            resource = OpentelemetryClients.opentelemetry.proto.resource.v1.Resource(
                dropped_attributes_count = 0
            ),
            instrumentation_library_spans = [
                OpentelemetryClients.opentelemetry.proto.trace.v1.InstrumentationLibrarySpans(
                    instrumentation_library = OpentelemetryClients.opentelemetry.proto.common.v1.InstrumentationLibrary(;
                        name="julia",
                        version="1.0.0"
                    ),
                    spans=[
                        OpentelemetryClients.opentelemetry.proto.trace.v1.Span(
                            trace_id = reinterpret(UInt8, rand(UInt128, 1)),
                            span_id = reinterpret(UInt8, rand(UInt64, 1)),
                            trace_state="",
                            parent_span_id=[],
                            name="JJJJJJJJJJJJJJJJJJ",
                            kind=0,
                            start_time_unix_nano=0xe3c6aac9ebe5b6f8,
                            end_time_unix_nano=0xe3c6aac9ebe5b6f9,
                        )
                    ],
                    schema_url="http://localhost:7777"
                )
            ],
            schema_url="http://localhost:8888"
        )
    ]
)

client = OpentelemetryClients.TraceServiceBlockingClient("http://localhost:4317")

# OpentelemetryClients.Export(client, req)

end
