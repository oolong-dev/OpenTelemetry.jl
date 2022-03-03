using OpenTelemetryProto: OpentelemetryClients
using Test

@testset "OpenTelemetryProto.jl" begin
    trace_req =
        OpentelemetryClients.opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest(
            resource_spans = [
                OpentelemetryClients.opentelemetry.proto.trace.v1.ResourceSpans(
                    resource = OpentelemetryClients.opentelemetry.proto.resource.v1.Resource(
                        dropped_attributes_count = 0,
                    ),
                    instrumentation_library_spans = [
                        OpentelemetryClients.opentelemetry.proto.trace.v1.InstrumentationLibrarySpans(
                            instrumentation_library = OpentelemetryClients.opentelemetry.proto.common.v1.InstrumentationLibrary(;
                                name = "julia",
                                version = "1.0.0",
                            ),
                            spans = [
                                OpentelemetryClients.opentelemetry.proto.trace.v1.Span(
                                    trace_id = reinterpret(UInt8, rand(UInt128, 1)),
                                    span_id = reinterpret(UInt8, rand(UInt64, 1)),
                                    trace_state = "",
                                    parent_span_id = [],
                                    name = "JJJJJJJJJJJJJJJJJJ",
                                    kind = 0,
                                    start_time_unix_nano = 0xe3c6aac9ebe5b6f8,
                                    end_time_unix_nano = 0xe3c6aac9ebe5b6f9,
                                ),
                            ],
                            schema_url = "http://localhost:7777",
                        ),
                    ],
                    schema_url = "http://localhost:8888",
                ),
            ],
        )

    trace_client = OpentelemetryClients.TraceServiceBlockingClient("http://localhost:4317")

    # OpentelemetryClients.Export(client, req)

    metrics_req =
        OpentelemetryClients.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest(
            resource_metrics = [
                OpentelemetryClients.opentelemetry.proto.metrics.v1.ResourceMetrics(
                    resource = OpentelemetryClients.opentelemetry.proto.resource.v1.Resource(
                        dropped_attributes_count = 0,
                    ),
                    instrumentation_library_metrics = [
                        OpentelemetryClients.opentelemetry.proto.metrics.v1.InstrumentationLibraryMetrics(
                            instrumentation_library = OpentelemetryClients.opentelemetry.proto.common.v1.InstrumentationLibrary(;
                                name = "julia",
                                version = "1.0.0",
                            ),
                            metrics = [
                                OpentelemetryClients.opentelemetry.proto.metrics.v1.Metric(
                                    name = "test_metric",
                                    description = "just for test",
                                    unit = "",
                                    gauge = OpentelemetryClients.opentelemetry.proto.metrics.v1.Gauge(
                                        data_points = [
                                            OpentelemetryClients.opentelemetry.proto.metrics.v1.NumberDataPoint(
                                                start_time_unix_nano = 0xe3c6aac9ebe5b6f8,
                                                time_unix_nano = 0xe3c6aac9ebe5b6f9,
                                                as_int = 123,
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                            schema_url = "http://localhost:7777",
                        ),
                    ],
                    schema_url = "http://localhost:8888",
                ),
            ],
        )

    log_req =
        OpentelemetryClients.opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest(
            resource_logs = [
                OpentelemetryClients.opentelemetry.proto.logs.v1.ResourceLogs(
                    resource = OpentelemetryClients.opentelemetry.proto.resource.v1.Resource(
                        dropped_attributes_count = 0,
                    ),
                    instrumentation_library_logs = [
                        OpentelemetryClients.opentelemetry.proto.logs.v1.InstrumentationLibraryLogs(
                            instrumentation_library = OpentelemetryClients.opentelemetry.proto.common.v1.InstrumentationLibrary(;
                                name = "julia",
                                version = "1.0.0",
                            ),
                            log_records = [
                                OpentelemetryClients.opentelemetry.proto.logs.v1.LogRecord(
                                    time_unix_nano = 0xe3c6aac9ebe5b6f9,
                                    observed_time_unix_nano = 0xe3c6aac9ebe5b6f8,
                                    severity_number = OpentelemetryClients.opentelemetry.proto.logs.v1.SeverityNumber.SEVERITY_NUMBER_ERROR,
                                    severity_text = "ERROR",
                                    body = OpentelemetryClients.opentelemetry.proto.common.v1.AnyValue(
                                        string_value = "Oh no!",
                                    ),
                                    attributes = [],
                                    dropped_attributes_count = 0,
                                    trace_id = reinterpret(UInt8, rand(UInt128, 1)),
                                    span_id = reinterpret(UInt8, rand(UInt64, 1)),
                                ),
                            ],
                            schema_url = "http://localhost:7777",
                        ),
                    ],
                    schema_url = "http://localhost:8888",
                ),
            ],
        )
end
