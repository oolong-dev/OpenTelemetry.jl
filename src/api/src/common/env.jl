# [Source](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/sdk-environment-variables.md)

#####
# General SDK Configuration
#####

"""
Disable the SDK for all signals.

Boolean value. If "true", a no-op SDK implementation will be used for all telemetry signals. Any other value or absence of the variable will have no effect and the SDK will remain enabled. This setting has no effect on propagators configured through the OTEL_PROPAGATORS variable.
"""
function OTEL_SDK_DISABLED()
    flag = get(ENV, "OTEL_SDK_DISABLED", "false")
    FLAG = uppercase(flag)
    if FLAG in ("TRUE", "FALSE")
        FLAG == "TRUE"
    else
        @warn "Unknown `OTEL_SDK_DISABLED` variable detected. Expected `TRUE` or `FALSE`, got $flag. Fallback to `false`."
        false
    end
end

export OTEL_SDK_DISABLED

"""
Sets the value of the [`service.name`](./resource/semantic_conventions/README.md#service) resource attribute.

If `service.name` is also provided in `OTEL_RESOURCE_ATTRIBUTES`, then `OTEL_SERVICE_NAME` takes precedence.
"""
OTEL_SERVICE_NAME() = get(ENV, "OTEL_SERVICE_NAME", "unknown_service:julia")

export OTEL_SERVICE_NAME

"""
Key-value pairs to be used as resource attributes.

See [Resource SDK](./resource/sdk.md#specifying-resource-information-via-an-environment-variable) for more details.
"""
function OTEL_RESOURCE_ATTRIBUTES()
    attrs = extract_attrs(get(ENV, "OTEL_RESOURCE_ATTRIBUTES", ""))
    if haskey(attrs, Symbol("service.name"))
        attrs
    else
        merge(attrs, (; Symbol("service.name") => OTEL_SERVICE_NAME()))
    end
end

export OTEL_RESOURCE_ATTRIBUTES

"""
Log level used by the SDK logger.
"""
OTEL_LOG_LEVEL() = str2logleve(get(ENV, "OTEL_LOG_LEVEL", "info"))

export OTEL_LOG_LEVEL

"""
Propagators to be used as a comma-separated list .

Values MUST be deduplicated in order to register a `Propagator` only once.
"""
OTEL_PROPAGATORS() = split(get(ENV, "OTEL_PROPAGATORS", "tracecontext,baggage"), ',')

export OTEL_PROPAGATORS

"""
Sampler to be used for traces.

See [Sampling](./trace/sdk.md#sampling)
"""
OTEL_TRACES_SAMPLER() = get(ENV, "OTEL_TRACES_SAMPLER", "parentbased_always_on")

export OTEL_TRACES_SAMPLER

"""
String value to be used as the sampler argument.

The specified value will only be used if OTEL_TRACES_SAMPLER is set. Each Sampler type defines its own expected input, if any. Invalid or unrecognized input MUST be logged and MUST be otherwise ignored, i.e. the SDK MUST behave as if OTEL_TRACES_SAMPLER_ARG is not set.
"""
OTEL_TRACES_SAMPLER_ARG() = get(ENV, "OTEL_TRACES_SAMPLER_ARG", nothing)

export OTEL_TRACES_SAMPLER_ARG

#####
# Batch Span Processor
#####

"""
Delay interval (in milliseconds) between two consecutive exports
"""
OTEL_BSP_SCHEDULE_DELAY() = parse(Int, get(ENV, "OTEL_BSP_SCHEDULE_DELAY", "5000"))

export OTEL_BSP_SCHEDULE_DELAY

"""
Maximum allowed time (in milliseconds) to export data
"""
OTEL_BSP_EXPORT_TIMEOUT() = parse(Int, get(ENV, "OTEL_BSP_EXPORT_TIMEOUT", "30000"))

export OTEL_BSP_EXPORT_TIMEOUT

"""
Maximum queue size
"""
OTEL_BSP_MAX_QUEUE_SIZE() = parse(Int, get(ENV, "OTEL_BSP_MAX_QUEUE_SIZE", "2048"))

export OTEL_BSP_MAX_QUEUE_SIZE

"""
Maximum batch size

Must be less than or equal to OTEL_BSP_MAX_QUEUE_SIZE
"""
OTEL_BSP_MAX_EXPORT_BATCH_SIZE() = min(
    parse(Int, get(ENV, "OTEL_BSP_MAX_EXPORT_BATCH_SIZE", "512")),
    OTEL_BSP_MAX_QUEUE_SIZE(),
)

export OTEL_BSP_MAX_EXPORT_BATCH_SIZE

#####
# Batch LogRecord Processor
#####

"""
Delay interval (in milliseconds) between two consecutive exports
"""
OTEL_BLRP_SCHEDULE_DELAY() = parse(Int, get(ENV, "OTEL_BLRP_SCHEDULE_DELAY", "5000"))

export OTEL_BLRP_SCHEDULE_DELAY

"""
Maximum allowed time (in milliseconds) to export data
"""
OTEL_BLRP_EXPORT_TIMEOUT() = parse(Int, get(ENV, "OTEL_BLRP_EXPORT_TIMEOUT", "30000"))

export OTEL_BLRP_EXPORT_TIMEOUT

"""
Maximum queue size
"""
OTEL_BLRP_MAX_QUEUE_SIZE() = parse(Int, get(ENV, "OTEL_BLRP_MAX_QUEUE_SIZE", "2048"))

export OTEL_BLRP_MAX_QUEUE_SIZE

"""
Maximum batch size
Must be less than or equal to OTEL_BLRP_MAX_QUEUE_SIZE
"""
OTEL_BLRP_MAX_EXPORT_BATCH_SIZE() = min(
    parse(Int, get(ENV, "OTEL_BLRP_MAX_EXPORT_BATCH_SIZE", "512")),
    OTEL_BLRP_MAX_QUEUE_SIZE(),
)

export OTEL_BLRP_MAX_EXPORT_BATCH_SIZE

#####
# Attribute Limits
#####

"""
Maximum allowed attribute value size
"""
OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT() =
    parse(Int, get(ENV, "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT", "$(typemax(Int))"))

export OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT

"""
Maximum allowed span attribute count
"""
OTEL_ATTRIBUTE_COUNT_LIMIT() = parse(Int, get(ENV, "OTEL_ATTRIBUTE_COUNT_LIMIT", "128"))

export OTEL_ATTRIBUTE_COUNT_LIMIT

#####
# Span Limits
#####

"""
Maximum allowed attribute value size
"""
OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT() =
    if haskey(ENV, "OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT")
        parse(Int, ENV["OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT"])
    else
        OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT()
    end

export OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT

"""
Maximum allowed span attribute count
"""
OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT() =
    if haskey(ENV, "OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT")
        parse(Int, ENV["OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT"])
    else
        OTEL_ATTRIBUTE_COUNT_LIMIT()
    end

export OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT

"""
Maximum allowed span event count
"""
OTEL_SPAN_EVENT_COUNT_LIMIT() =
    if haskey(ENV, "OTEL_SPAN_EVENT_COUNT_LIMIT")
        parse(Int, ENV["OTEL_SPAN_EVENT_COUNT_LIMIT"])
    else
        OTEL_ATTRIBUTE_COUNT_LIMIT()
    end

export OTEL_SPAN_EVENT_COUNT_LIMIT

"""
Maximum allowed span link count
"""
OTEL_SPAN_LINK_COUNT_LIMIT() =
    if haskey(ENV, "OTEL_SPAN_LINK_COUNT_LIMIT")
        parse(Int, ENV["OTEL_SPAN_LINK_COUNT_LIMIT"])
    else
        OTEL_ATTRIBUTE_COUNT_LIMIT()
    end

export OTEL_SPAN_LINK_COUNT_LIMIT

"""
Maximum allowed attribute per span event count
"""
OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT() =
    if haskey(ENV, "OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT")
        parse(Int, ENV["OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT"])
    else
        OTEL_ATTRIBUTE_COUNT_LIMIT()
    end

export OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT

"""
Maximum allowed attribute per span link count
"""
OTEL_LINK_ATTRIBUTE_COUNT_LIMIT() =
    if haskey(ENV, "OTEL_LINK_ATTRIBUTE_COUNT_LIMIT")
        parse(Int, ENV["OTEL_LINK_ATTRIBUTE_COUNT_LIMIT"])
    else
        OTEL_ATTRIBUTE_COUNT_LIMIT()
    end

export OTEL_LINK_ATTRIBUTE_COUNT_LIMIT

#####
# LogRecord Limits
#####
"""
Maximum allowed attribute value size
"""
OTEL_LOGRECORD_ATTRIBUTE_VALUE_LENGTH_LIMIT() =
    if haskey(ENV, "OTEL_LOGRECORD_ATTRIBUTE_VALUE_LENGTH_LIMIT")
        parse(Int, ENV["OTEL_LOGRECORD_ATTRIBUTE_VALUE_LENGTH_LIMIT"])
    else
        OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT()
    end

export OTEL_LOGRECORD_ATTRIBUTE_VALUE_LENGTH_LIMIT

"""
Maximum allowed log record attribute count
"""
OTEL_LOGRECORD_ATTRIBUTE_COUNT_LIMIT() =
    if haskey(ENV, "OTEL_LOGRECORD_ATTRIBUTE_COUNT_LIMIT")
        parse(Int, ENV["OTEL_LOGRECORD_ATTRIBUTE_COUNT_LIMIT"])
    else
        OTEL_ATTRIBUTE_COUNT_LIMIT()
    end

export OTEL_LOGRECORD_ATTRIBUTE_COUNT_LIMIT

#####
# OTLP Exporter
#####

# TODO!

#####
# Jaeger Exporter
#####

# TODO!

#####
# Zipkin Exporter
#####

# TODO!

#####
# Prometheus Exporter
#####
"""
Host used by the Prometheus exporter
"""
OTEL_EXPORTER_PROMETHEUS_HOST() = get(ENV, "OTEL_EXPORTER_PROMETHEUS_HOST", "localhost")

export OTEL_EXPORTER_PROMETHEUS_HOST

"""
Port used by the Prometheus exporter
"""
OTEL_EXPORTER_PROMETHEUS_PORT() =
    if haskey(ENV, "OTEL_EXPORTER_PROMETHEUS_PORT")
        parse(Int, ENV["OTEL_EXPORTER_PROMETHEUS_PORT"])
    else
        9496
    end

export OTEL_EXPORTER_PROMETHEUS_PORT

#####
# Exporter Selection
#####
"""
Trace exporter to be used
"""
OTEL_TRACES_EXPORTER() = get(ENV, "OTEL_TRACES_EXPORTER", "otlp")

export OTEL_TRACES_EXPORTER
"""
Metrics exporter to be used
"""
OTEL_METRICS_EXPORTER() = get(ENV, "OTEL_METRICS_EXPORTER", "otlp")

export OTEL_METRICS_EXPORTER

"""
Logs exporter to be used
"""
OTEL_LOGS_EXPORTER() = get(ENV, "OTEL_LOGS_EXPORTER", "otlp")

export OTEL_LOGS_EXPORTER

#####
# Metrics SDK Configuration
#####

"""
Filter for which measurements can become Exemplars.
"""
OTEL_METRICS_EXEMPLAR_FILTER() = get(ENV, "OTEL_METRICS_EXEMPLAR_FILTER", "trace_based")

export OTEL_METRICS_EXEMPLAR_FILTER

#####
# Periodic exporting MetricReader
#####
"""
The time interval (in milliseconds) between the start of two export attempts.
"""
OTEL_METRIC_EXPORT_INTERVAL() = parse(Int, get(ENV, "OTEL_METRIC_EXPORT_INTERVAL", "60000"))

export OTEL_METRIC_EXPORT_INTERVAL

"""
Maximum allowed time (in milliseconds) to export data.
"""
OTEL_METRIC_EXPORT_TIMEOUT() = parse(Int, get(ENV, "OTEL_METRIC_EXPORT_TIMEOUT", "30000"))

export OTEL_METRIC_EXPORT_TIMEOUT

#####
# Julia specific variables
#####

OTEL_JULIA_MAX_POINTS_APPROX_PER_METRIC() =
    parse(Int, get(ENV, "OTEL_JULIA_MAX_POINTS_APPROX_PER_METRIC", "2000"))

export OTEL_JULIA_MAX_POINTS_APPROX_PER_METRIC

OTEL_JULIA_MAX_METRICS_APPROX_PER_PROVIDER() =
    parse(Int, get(ENV, "OTEL_JULIA_MAX_METRICS_APPROX_PER_PROVIDER", "2000"))

export OTEL_JULIA_MAX_METRICS_APPROX_PER_PROVIDER