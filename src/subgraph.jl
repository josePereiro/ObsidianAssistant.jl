function subgraph(isroot::Function, vault::AbstractString;
        deep::Int = 2,
        keepout = (dir) -> startswith(basename(dir), ".")
    )

    mdfiles = filterdown((f) -> endswith(f, ".md"), vault; 
        keepout
    )

    tree = Vector{Vector{String}}()
    roots = filter(isroot, mdfiles)
    isempty(roots) && return tree
    push!(tree, roots)

    # extract links
    for _ in 1:deep
        curr_level = String[]
        parents = last(tree)
        for mdfile in parents
            str = read(mdfile, String)
            links = _extract_links(str)
            # TODO: Create all possible paths by finding all dirs (better performance)
            walkdown(vault; keepout) do path
                name = replace(basename(path), r".md$" => "")
                (name in links) && push!(curr_level, path)
            end
        end
        isempty(curr_level) && return tree
        push!(tree, curr_level)
    end
    return tree
end