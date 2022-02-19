function GarishPrint.pprint_struct(
    io::GarishPrint.GarishIO,
    mime::MIME"text/plain",
    @nospecialize(x),
    fields,
)
    t = typeof(x)
    isstructtype(t) || throw(ArgumentError("expect a struct type, got $t"))
    GarishPrint.pprint_struct_type(io, mime, t)
    print(io.bland_io, "(")

    nf = nfields(x)::Int
    nf == 0 && return print(io.bland_io, ")")

    io.compact || println(io.bland_io)

    # findout fields to print
    fields_to_print = Int[]
    for i in 1:nf
        f = fieldname(t, i)
        value = getfield(x, i)
        if !io.include_defaults && GarishPrint.is_option(x) && value == GarishPrint.field_default(t, f)
        elseif f in fields  # !!! only change
            push!(fields_to_print, i)
        end
    end

    GarishPrint.within_nextlevel(io) do
        for i in fields_to_print
            f = fieldname(t, i)
            value = getfield(x, i)
            GarishPrint.print_indent(io)
            GarishPrint.print_token(io, :fieldname, f)
            if io.compact
                print(io.bland_io, "=")
            else
                print(io.bland_io, " = ")
                io.state.offset = 3 + length(string(f))
            end

            if !isdefined(x, f) # print undef as comment color
                pprint(io, undef)
            else
                new_io = GarishPrint.GarishIO(io; limit = true)
                GarishPrint.pprint_field(new_io, mime, value)
            end

            if !io.compact || i != last(fields_to_print)
                print(io.bland_io, ", ")
            end

            if i != last(fields_to_print)
                io.compact || println(io.bland_io)
            end
        end
    end
    io.compact || println(io.bland_io)
    GarishPrint.print_indent(io)
    print(io.bland_io, ")")
end

function GarishPrint.pprint_struct(
    io::GarishPrint.GarishIO,
    mime::MIME"text/plain",
    a::MeterProvider,
)
    GarishPrint.pprint_struct(io, mime, a, (:resource, :views, :n_max_metrics))
end

function GarishPrint.pprint_struct(
    io::GarishPrint.GarishIO,
    mime::MIME"text/plain",
    a::AggregationStore,
)
    GarishPrint.pprint_struct(io, mime, a, (:unique_points, :n_max_points, :n_max_attrs))
end