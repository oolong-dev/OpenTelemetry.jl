module OpenTelemetry

using Logging
using Reexport

@reexport using OpenTelemetryAPI
@reexport using OpenTelemetrySDK
@reexport using OpenTelemetryExporterOtlpProtoHttp
@reexport using OpenTelemetryExporterPrometheus

function __init__()
    if !OTEL_SDK_DISABLED()
        global_logger(OtelSimpleLogger())
        global_tracer_provider(TracerProvider())
        global_meter_provider(MeterProvider())
    end
end

end
