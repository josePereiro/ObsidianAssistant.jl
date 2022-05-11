function collect_dat(AST, line_type::Symbol, field::String, elT::DataType = Any)
    found = elT[]
    for AST_line in AST
        if AST_line[:type] == line_type
            dat = AST_line[:dat]
            if haskey(dat, field)
                push!(found, dat[field]...)
            end
        end
    end
    unique!(found)
    return found
end

function collect_dat(AST, line_type::Symbol, elT::DataType = Any)
    found = elT[]
    for AST_line in AST
        if AST_line[:type] == line_type
            dat = AST_line[:dat]
            push!(found, dat)
        end
    end
    unique!(found)
    return found
end

collect_tags(AST::Vector) = collect_dat(AST, TEXT_LINE, "tags", Dict{String, String})
collect_links(AST::Vector) = collect_dat(AST, TEXT_LINE, "links", Dict{String, String})
collect_headers(AST::Vector) = collect_dat(AST, HEADER, Dict{String, String})

collect_comments(AST::Vector) = collect_dat(AST, COMMENT_BLOCK, Dict{String, String})