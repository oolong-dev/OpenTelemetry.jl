module OpenTelemetry

using Reexport

@reexport using OpenTelemetryAPI
@reexport using OpenTelemetrySDK
@reexport using OpenTelemetryExporterOtlpProtoGrpc
@reexport using OpenTelemetryExporterPrometheus
@reexport using OpenTelemetryProto

function __init__()
    if global_tracer_provider() isa OpenTelemetryAPI.DummyTracerProvider
        global_tracer_provider(
            TracerProvider(
                span_processor = CompositSpanProcessor(
                    SimpleSpanProcessor(ConsoleExporter()),
                ),
            ),
        )
    end

    if global_meter_provider() isa OpenTelemetryAPI.DummyMeterProvider
        global_meter_provider(MeterProvider())
    end
end

end
