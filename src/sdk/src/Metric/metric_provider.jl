struct MeterProvider <: API.AbstractMeterProvider
    resource::Resource
    is_shut_down::Ref{Bool}
end
