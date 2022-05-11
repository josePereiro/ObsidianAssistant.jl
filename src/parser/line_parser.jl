
# ------------------------------------------------------------------
# Types and Scope
const INIT_SCOPE = :INIT
const GLOBAL_SCOPE = :GLOBAL
const YAML_BLOCK = :YAML_BLOCK
const COMMENT_BLOCK = :COMMENT_BLOCK
const COMMENT_LINE = :COMMENT_LINE
const LATEX_BLOCK = :LATEX_BLOCK
const HEADER = :HEADER
const TEXT_LINE = :TEXT_LINE
const EMPTY_LINE = :EMPTY_LINE

# ------------------------------------------------------------------
# This assume a per-line compatible file. Obsidian is more flexible.
# The main restriction is that no block element is started in a midline. 
# TODO: write error code to detect it
function _parse_lines(lines)

    AST = Dict{Symbol, Any}[]
    scope = INIT_SCOPE
    multi_line_obj = nothing

    for (li, line) in enumerate(lines)

        # @info "-" line scope

        # ----------------------------------------------------------------
        # yaml section start
        rmatch = match(YAML_BLOCK_START_LINE_REGEX, line)
        if scope === INIT_SCOPE && !isnothing(rmatch)
            multi_line_obj = Dict(
                :type => YAML_BLOCK, 
                :line => li, 
                :src => [line]
            )
            push!(AST, multi_line_obj)
            scope = YAML_BLOCK
            continue
        end

        # yaml section content/end
        if scope === YAML_BLOCK
            push!(multi_line_obj[:src], line)
            rmatch = match(YAML_BLOCK_END_LINE_REGEX, line)
            if !isnothing(rmatch)
                scope = GLOBAL_SCOPE
                multi_line_obj = nothing
            end
            continue
        end

        # ----------------------------------------------------------------
        # unvalidate INIT_SCOPE
        rmatch = match(BLACK_LINE_REGEX, line)
        if scope === INIT_SCOPE && isnothing(rmatch)
            scope = GLOBAL_SCOPE
        end

        # ----------------------------------------------------------------
        # header
        rmatch = match(HEADER_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            push!(AST, 
                Dict(:type => HEADER, 
                    :line => li, 
                    :src => [line]
                )
            )
            continue
        end

        # ----------------------------------------------------------------
        # comment line
        rmatch = match(COMMENT_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            push!(AST, 
                Dict(
                    :type => COMMENT_LINE, 
                    :line => li, 
                    :src => [line]
                )
            )
            continue
        end

        # ----------------------------------------------------------------
        # comment block start
        rmatch = match(COMMENT_BLOCK_START_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            multi_line_obj = Dict(
                :type => COMMENT_BLOCK, 
                :line => li, 
                :src => [line]
            )
            # enter block
            push!(AST, multi_line_obj)
            scope = COMMENT_BLOCK
            continue
        end

        # comment block section content/end
        if scope === COMMENT_BLOCK
            push!(multi_line_obj[:src], line)
            rmatch = match(COMMENT_BLOCK_END_LINE_REGEX, line)
            
            if !isnothing(rmatch)
                # exit block
                scope = GLOBAL_SCOPE
                multi_line_obj = nothing
            end
            continue
        end

        # ----------------------------------------------------------------
        # latex block start
        rmatch = match(LATEX_BLOCK_START_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            multi_line_obj = Dict(
                :type => LATEX_BLOCK, 
                :line => li, 
                :src => [line]
            )

            # enter block
            push!(AST, multi_line_obj)
            scope = LATEX_BLOCK
            continue
        end

        # latex block section content/end
        if scope === LATEX_BLOCK
            push!(multi_line_obj[:src], line)
            rmatch = match(LATEX_BLOCK_END_LINE_REGEX, line)
            if !isnothing(rmatch)
                # exit block
                scope = GLOBAL_SCOPE
                multi_line_obj = nothing
            end
            continue
        end

        # ----------------------------------------------------------------
        # Text line
        rmatch = match(BLACK_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && isnothing(rmatch)
            push!(AST, 
                Dict(
                    :type => TEXT_LINE, 
                    :line => li, 
                    :src => [line]
                )
            )
            continue
        end

        # ----------------------------------------------------------------
        # empty line
        rmatch = match(BLACK_LINE_REGEX, line)
        if scope === GLOBAL_SCOPE && !isnothing(rmatch)
            push!(AST, 
                Dict(
                    :type => EMPTY_LINE, 
                    :line => li, 
                    :src => [line]
                )
            )
            continue
        end

    end

    # Check closing objects
    scope !== GLOBAL_SCOPE && !isnothing(multi_line_obj) && error(
        "Parsing failed, block ", scope, " starting at line ", multi_line_obj[:line], " unclosed!"
    )

    return AST
end

# ------------------------------------------------------------------
function _parse_dat!(AST::Vector)

    # Parse dat
    for line_AST in AST
        type = line_AST[:type]
        src = _join_src(line_AST)

        # YAML block
        if type == YAML_BLOCK
            line_AST[:dat] = parse_yaml(src)
            continue
        end

        # HEAD line
        if type == HEADER
            line_AST[:dat] = parse_header(src)
            continue
        end

        # COMMENTS
        if type == COMMENT_LINE || type == COMMENT_BLOCK
            line_AST[:dat] = parse_comment(src)
            continue
        end

        # TEXT
        if type == TEXT_LINE
            line_AST[:dat] = parse_text(src)
            continue
        end

        # LATEX BLOCK
        if type == LATEX_BLOCK
            line_AST[:dat] = parse_latex_block(src)
            continue
        end
    end

    return AST
end


