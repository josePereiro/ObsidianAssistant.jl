const OBA_PLUGIN_TRIGGER_FILE_CONTENT_EVENT = FileContentEvent()
const RUNNER_FILE_CONTENT_EVENT = FileContentEvent()

_trigger_file(vault) = joinpath(vault, ".obsidian", "plugins", "oba-plugin", "trigger-signal.json")

_has_trigger(vault) = has_event!(OBA_PLUGIN_TRIGGER_FILE_CONTENT_EVENT, _trigger_file(vault))
_up_trigger_event(vault) = update!(OBA_PLUGIN_TRIGGER_FILE_CONTENT_EVENT, _trigger_file(vault))


# running globals
__VAULT__ = nothing
__JLFILE__ = nothing
__MDFILE__ = nothing
__AST_LINE__ = nothing
__AST_MDFILE__ = nothing
__EXTRAS__ = nothing  # To communicate between scripts and backend runs

const _COMMENT_SCRIPT_TAG = "#!julia"

## ------------------------------------------------------------------
function _reset_server()
    # Events
    reset!(OBA_PLUGIN_TRIGGER_FILE_CONTENT_EVENT)
    reset!(RUNNER_FILE_CONTENT_EVENT)

    # running globals
    global __VAULT__ = nothing
    global __JLFILE__ = nothing
    global __MDFILE__ = nothing
    global __AST_LINE__ = nothing
    global __AST_MDFILE__ = nothing

    return nothing
end

## ------------------------------------------------------------------
function _run_startup_jl(vault)

    # pre-warm
    _up_trigger_event(vault)

    println()
    println("="^60)
    @info("Running startup.oba.jl")
    
    jlfile = find_startup(vault)
        
    println()
    println("-"^60)
    @show jlfile
    println()

    # prepare globals
    global __VAULT__ = vault
    global __JLFILE__ = jlfile
    global __MDFILE__ = nothing
    global __AST_LINE__ = nothing
    global __AST_MDFILE__ = nothing

    # eval
    include_string(ObsidianAssistant, read(jlfile, String))

    return nothing
end


function _run_mdfiles(vault)

    println()
    println("="^60)
    @info("Running md files")

    mdfiles = findall_files(vault, ".md")
    for mdfile in mdfiles

        # for each comment-scripts
        # prepare globals
        global __VAULT__ = vault
        global __JLFILE__ = nothing
        global __MDFILE__ = mdfile

        processed = UInt64[]
        for _ in 1:1000 # The run deep
            
            evaluated = false

            AST = parse_md(eachline(mdfile))
            
            for AST_line in AST

                # check type
                (AST_line[:type] !== COMMENT_BLOCK) && continue
                
                # get dat
                dat = get(AST_line, :dat, nothing)
                isnothing(dat) && continue
                
                # check if processed
                src = strip(get(dat, "txt", ""))
                line = get(AST_line, :line, 0)
                hash_ = hash((line, src))
                (hash_ in processed) && continue
                push!(processed, hash_)
                
                # check is script comment
                if startswith(src, _COMMENT_SCRIPT_TAG)

                    # prepare globals
                    global __AST_MDFILE__ = AST
                    global __AST_LINE__ = AST_line

                    # info
                    println()
                    println("-"^60)
                    @info("Running", src, mdfile = string(mdfile, ":", line))
                    println()
                    
                    # eval
                    src = replace(src, _COMMENT_SCRIPT_TAG => "")
                    include_string(ObsidianAssistant, src)

                    evaluated = true

                    println()
                    
                    # because an script can modified its own file
                    # I rerun the file 
                    break
                end                    
            
            end # for AST_line in AST

            !evaluated && break
        
        end # The run deep
    
    end # for mdfile in mdfiles
end

## ------------------------------------------------------------------
function run_server(vault=pwd())

    # reset
    reset!(OBA_PLUGIN_TRIGGER_FILE_CONTENT_EVENT)
    reset!(RUNNER_FILE_CONTENT_EVENT)

    # jlfiles
    _run_startup_jl(vault)

    while true

        # trigger
        _wait_for_trigger(vault)
        
        # mdfiles
        _run_mdfiles(vault)

        println()
    
    end
end