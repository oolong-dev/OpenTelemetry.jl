module OpenTelemetrySDKDownloadsExt

using OpenTelemetrySDK

if isdefined(Base, :get_extension)
    import Downloads
else
    import ..Downloads
end

#####
# TODO: Support client side metrics and spans
# watch https://github.com/JuliaLang/Downloads.jl/issues/220
#####

const OLD_EASY_HOOK = Ref{Union{Missing,Nothing,Function}}(missing)

struct OtelEasyHook{H}
    old_hook::H
end

function (h::OtelEasyHook)(easy, info)
    n = length(info.headers)
    inject_context!(info.headers)
    N = length(info.headers)
    Downloads.add_headers(easy, @view info.headers[n+1:N]) # !!! old info.headers are already added
    h.old_hook !== nothing && h.old_hook(easy, info)
end

function OpenTelemetrySDK.instrument!(::Val{:Downloads})
    if OLD_EASY_HOOK[] === missing
        old_easy_hook = Downloads.EASY_HOOK[]
        OLD_EASY_HOOK[] = old_easy_hook
        Downloads.EASY_HOOK[] = (easy, info) -> OtelEasyHook(old_easy_hook)(easy, info)
        Downloads.DOWNLOADER[] = Downloads.Downloader()
    else
        @error "Downloads.jl is already instrumented!"
    end
end

function OpenTelemetrySDK.uninstrument!(::Val{:Downloads})
    if OLD_EASY_HOOK[] === missing
        @warn "Downloads.jl is not instrumented yet!"
    else
        Downloads.EASY_HOOK[] = OLD_EASY_HOOK[]
        OLD_EASY_HOOK[] = missing
        Downloads.DOWNLOADER[] = nothing
    end
end

end