# ------------------------------------------------------------------
_has_match(reg::Regex, str::AbstractString) = !isnothing(match(reg, str))

function _match_dict(rmatch::RegexMatch)
    mdict = Dict{String, String}()
    for kstr in keys(rmatch)
        ksym = Symbol(kstr)
        str = rmatch[ksym]
        mdict[kstr] = isnothing(str) ? "" : str
    end
    return mdict
end

_match_dict(::Nothing) = Dict{Symbol, String}()

function _match_dict(reg::Regex, str::AbstractString)
    rmatch = match(reg, str)
    return _match_dict(rmatch)
end

# ------------------------------------------------------------------
function _extract_matches(reg::Regex, str::AbstractString)
    matchs = Dict{String, String}[]
    for rm in eachmatch(reg, str)
        mdict = _match_dict(rm)
        push!(matchs, mdict)
    end
    return unique!(matchs)
end