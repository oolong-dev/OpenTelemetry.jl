# Tips for Developers

## Instrument a Package

If you have write permission to the package, you can add the dependency of `OpenTelemetryAPI` and modify the code as you wish. Otherwise, you need to write an independent instrumentation package. Here are some general conventions.

1. Each instrumentation package should implement the `init(;tracer_provider=global_tracer_provider(), meter_provider=global_meter_provider())` function. Note that this function shouldn't be exported to avoid confliction. In the module `__init__()` function, call `init()` to instrument the target library instantly.
1. The name of [`Meter`](@ref) or [`AbstractInstrument`](@ref) should have at least have the  module (and its parent modules) name as a prefix. Usually people use `.` to connect different parts.