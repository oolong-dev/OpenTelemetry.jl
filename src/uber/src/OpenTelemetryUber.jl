module OpenTelemetryUber

using Reexport

@reexport using OpenTelemetryAPI
@reexport using OpenTelemetrySDK
@reexport using OpenTelemetryExporterOtlpProtoGrpc
@reexport using OpenTelemetryExporterPrometheus
@reexport using OpenTelemetryProto

# instrumentations
@reexport using OpenTelemetryInstrumentationBase
@reexport using OpenTelemetryInstrumentationDownloads

function init(;
    meter_provider = global_meter_provider(),
    tracer_provider = global_tracer_provider(),
)
    global_meter_provider!(meter_provider)
    global_tracer_provider!(tracer_provider)
    OpenTelemetryInstrumentationBase.init(;
        meter_provider = meter_provider,
        tracer_provider = tracer_provider,
    )

    OpenTelemetryInstrumentationDownloads.init(;
        meter_provider = meter_provider,
        tracer_provider = tracer_provider,
    )
end

end # module
