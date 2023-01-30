using Logging

# ??? what if value contains `,`? escape?
"""
Turn `"a=b,c=d"` into a `NamedTuple`
"""
extract_attrs(s) = NamedTuple(let (k, v) = split(kv, '=')
    Symbol(k) => v
end for kv in split(s, ',') if !isempty(kv))

function str2loglevel(s)
    S = uppercase(s)

    if S == "DEBUG"
        Debug
    elseif S == "INFO"
        Info
    elseif S == "WARN"
        Warn
    elseif S == "ERROR"
        Error
    else
        throw(ArgumentError("Unknown log level: $s"))
    end
end