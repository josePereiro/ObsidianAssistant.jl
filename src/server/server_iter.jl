const OBA_PLUGIN_TRIGGER_FILE_CONTENT_EVENT = FileContentEvent()
const RUNNER_FILE_CONTENT_EVENT = FileContentEvent()

_trigger_file(vault) = joinpath(vault, ".obsidian", "plugins", "oba-plugin", "trigger-signal.json")

_has_trigger(vault) = has_event!(OBA_PLUGIN_TRIGGER_FILE_CONTENT_EVENT, _trigger_file(vault))

# running globals
__VAULT__ = nothing
__JLFILE__ = nothing
__MDFILE__ = nothing
__AST_LINE__ = nothing
__AST__ = nothing
__SRC__ = nothing

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
    global __AST__ = nothing
    global __SRC__ = nothing

    return nothing
end

## ------------------------------------------------------------------
function _wait_for_trigger(vault)
    #check trigger
    println("="^60)
    @info("waiting for trigger")
    while true
        if !_has_trigger(vault)
            sleep(3.0)
            continue
        end
        break
    end
    @info("Boom!!! triggered")
end

function _run_jlfiles(vault)

    println()
    println("="^60)
    @info("Running jl files")
    foreach_file(vault, ".oba.jl") do jlfile
        
        _track_flag = !istraking(RUNNER_FILE_CONTENT_EVENT, jlfile)
        _event_flag = has_event!(RUNNER_FILE_CONTENT_EVENT, jlfile)
        @show _track_flag _event_flag

        if _track_flag || _event_flag
            
            println()
            println("-"^60)
            @show jlfile
            println()

            # prepare globals
            global __VAULT__ = vault
            global __JLFILE__ = jlfile
            global __MDFILE__ = nothing
            global __AST_LINE__ = nothing
            global __AST__ = nothing
            global __SRC__ = nothing

            # eval
            include_string(ObsidianAssistant, read(jlfile, String))

        end

        return nothing
    end
end


function _run_mdfiles(vault)

    println()
    println("="^60)
    @info("Running md files")

    foreach_file(vault, ".md") do mdfile
        
        _track_flag = !istraking(RUNNER_FILE_CONTENT_EVENT, mdfile)
        _event_flag = has_event!(RUNNER_FILE_CONTENT_EVENT, mdfile)
        @show _track_flag _event_flag

        if _track_flag || _event_flag
            
            println()
            println("-"^60)
            @show mdfile
            println()

            # for each comment-scripts
            # prepare globals
            global __VAULT__ = vault
            global __JLFILE__ = nothing
            global __MDFILE__ = mdfile

            processed = UInt64[]
            for _ in 1:1000 # The run deep

                AST = parse_md(eachline(mdfile))
                
                for AST_line in AST

                    # check type
                    (AST_line[:type] !== COMMENT_BLOCK) && continue
                    
                    # get dat
                    dat = get(AST_line, :dat, nothing)
                    isnothing(dat) && continue
                    
                    # check if processed
                    src = strip(get(dat, "txt", ""))
                    hash_ = hash((get(AST_line, :line, 0), src))
                    (hash_ in processed) && continue
                    push!(processed, hash_)
                    
                    @info("In block", src)
                    
                    # check is script comment
                    if startswith(src, _COMMENT_SCRIPT_TAG)

                        # prepare globals
                        global __AST__ = AST
                        global __AST_LINE__ = AST_line

                        # eval
                        src = replace(src, _COMMENT_SCRIPT_TAG => "")
                        @info("Running", src)
                        include_string(ObsidianAssistant, src)
                        
                        # because an script can modified its own file
                        # I rerun the file 
                        break
                    end                    
                end # The run deep

                break
            end
            


        end
        return nothing
    end
end

## ------------------------------------------------------------------
function run_server(vault)

    # reset
    reset!(OBA_PLUGIN_TRIGGER_FILE_CONTENT_EVENT)
    reset!(RUNNER_FILE_CONTENT_EVENT)

    while true

        # trigger
        _wait_for_trigger(vault)
        
        # jlfiles
        _run_jlfiles(vault)
        
        # mdfiles
        _run_mdfiles(vault)

        println()
    
    end
end