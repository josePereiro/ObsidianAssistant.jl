# ------------------------------------------------------------------
function _join_src(line_AST)
    if haskey(line_AST, :src)
        return join(line_AST[:src], "\n")
    end
    return ""
end