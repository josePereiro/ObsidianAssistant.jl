# ------------------------------------------------------------------
function _to_sym_dict(src_d::Dict{K,V}) where {K,V}
    sym_d = Dict{Symbol, V}()
    for (k, v) in src_d
        sym_d[Symbol(k)] = src_d[k]
    end
    return sym_d
end

# ------------------------------------------------------------------
function foreach_mdfile(f::Function, vault; keepout = [".obsidian", ".git"])
    walkdown(vault; keepout) do path
        !endswith(path, ".md") && return
        f(path)
    end
end