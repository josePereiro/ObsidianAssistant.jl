# Move subgraph
function _move_subgraph(src_vault::AbstractString, dest_vault::AbstractString; 
        vault_tag_reg::Regex = Regex("^#Vault/$(basename(dest_vault))\$"), 
        verbose = false,
        kwargs...
    )

    tree = subgraph(src_vault; kwargs...) do mdfile
        _occursin_world(vault_tag_reg, mdfile)
    end

    to_copy = String[]
    for lvl in tree
        push!(to_copy, lvl...)
    end
    unique!(to_copy)

    for src_mdfile in to_copy
        dest_mdfile = replace(src_mdfile, src_vault => dest_vault)
        mkpath(dirname(dest_mdfile))
        cp(src_mdfile, dest_mdfile; force = true)
        verbose && println(basename(src_mdfile), " copied!")
    end
end
