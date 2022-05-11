# ------------------------------------------------------------------
function parse_yaml(src::AbstractString)
    dat_ = Dict{String, Any}()
    dat_["src"] = src
    dat_["yaml"] =  YAML.load(src)
    return dat_
end

function parse_header(src::AbstractString)
    return _match_dict(HEADER_LINE_PARSER_REGEX, src)
end

function parse_comment(src::AbstractString)
    return _match_dict(COMMENT_BLOCK_PARSER_REGEX, src)
end

function parse_code_block(src::AbstractString)
    return _match_dict(CODE_BLOCK_PARSER_REGEX, src)
end


function parse_text(src::AbstractString)
    dat_ = Dict{String, Any}()
    dat_["src"] = src
    # digest starting for the links (To avoid tags-like labels)
    dat_["links"] = _extract_matches(FILE_LINK_PARSE_REGEX, src)
    for link in dat_["links"]
        src = replace(src, link["src"] => "")
    end
    dat_["tags"] = _extract_matches(TAG_PARSE_REGEX, src)
    return dat_
end

function parse_latex_block(src::AbstractString)
    dat_ = Dict{String, Any}()
    dat_["src"] = src
    dat_["tag"] = _match_dict(LATEX_TAG_PARSE_REGEX, src)
    return dat_
end

# ------------------------------------------------------------------
function parse_md(lines)
    AST = _parse_lines(lines)
    return _parse_dat!(AST)
end
