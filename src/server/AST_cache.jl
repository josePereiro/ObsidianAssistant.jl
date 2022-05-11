const AST_CACHE_MTIME_EVENT = FileMTimeEvent()
const AST_CACHE = Dict()


function reset_AST_cache!()
    empty!(AST_CACHE)
    reset!(AST_CACHE_MTIME_EVENT)
end

function get_AST!(mdfile::AbstractString)
    if has_event!(AST_CACHE_MTIME_EVENT, mdfile) || !haskey(AST_CACHE, mdfile)
        # This invalidates the cache
        AST = parse_md(eachline(mdfile))
        AST_CACHE[mdfile] = AST
    end
    return AST_CACHE[mdfile]
end