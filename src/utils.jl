# ------------------------------------------------------------------
_has_match(reg::Regex, str::AbstractString) = !isnothing(match(reg, str))
_get_match(m::RegexMatch, k::Symbol, dflt = nothing) = haskey(m, k) ? m[k] : dflt


# ------------------------------------------------------------------
function _foreach_line(f::Function, file::AbstractString)
    for line in eachline(file)
        flag = f(line)
        (flag === true) && return
    end
    return
end

function _foreach_world(f::Function, file::AbstractString)
    for line in eachline(file)
        for word in split(line; keepempty = false)
            flag = f(word)
            (flag === true) && return
        end
    end
    return
end

# ------------------------------------------------------------------
function _occursin_file(test::Function, file::AbstractString)
    str = read(String, file)
    return test(str)
end
_occursin_file(reg::Regex, file::AbstractString) = 
    _occursin_file((str) -> _has_match(reg, str), file)
_occursin_file(ref::AbstractString, file::AbstractString) = 
    _occursin_file((str) -> occursin(ref, str), file)

function _occursin_line(test::Function, file::AbstractString)
    flag = false
    _foreach_line(file) do line
        flag |= test(line)
        return flag
    end
    return flag
end
_occursin_line(reg::Regex, file::AbstractString) = 
    _occursin_line((str) -> _has_match(reg, str), file)
_occursin_line(ref::AbstractString, file::AbstractString) = 
    _occursin_line((str) -> occursin(ref, str), file)

function _occursin_world(test::Function, file::AbstractString)
    flag = false
    _foreach_world(file) do world
        flag |= test(world)
        return flag
    end
    return flag
end
_occursin_world(reg::Regex, file::AbstractString) = 
    _occursin_world((str) -> _has_match(reg, str), file)
_occursin_world(ref::AbstractString, file::AbstractString) = 
    _occursin_world((str) -> occursin(ref, str), file)

# ------------------------------------------------------------------
# _extract_matchs(reg::Regex, str::AbstractString) = (string(m.match) for m in eachmatch(reg, str))