# ------------------------------------------------------------------
function _to_sym_dict(src_d::Dict{K,V}) where {K,V}
    sym_d = Dict{Symbol, V}()
    for (k, v) in src_d
        sym_d[Symbol(k)] = src_d[k]
    end
    return sym_d
end

# ------------------------------------------------------------------
function foreach_file(f::Function, vault, ext = ".md"; keepout = [".obsidian", ".git"])
    walkdown(vault; keepout) do path
        !endswith(path, ext) && return
        f(path)
    end
end

# ------------------------------------------------------------------
function findall_files(vault::AbstractString, ext = ".md";
        sortby = mtime, sortrev = false, keepout = [".obsidian", ".git"]
    )

    files = filterdown((path) -> endswith(path, ext), vault; keepout)
    
    sort!(files; by = sortby, rev = sortrev)

    return files
end


# ------------------------------------------------------------------
const START_UP_FILE_NAME = "startup.oba.jl"
function find_startup(vault; keepout = [".obsidian", ".git"])
    path = ""
    walkdown(vault; keepout) do path_
        if basename(path_) == "startup.oba.jl"
            path = path_
            return true
        end
        return false
    end
    return path
end