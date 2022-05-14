## ------------------------------------------------------------------
const WAIT_FOR_TRIGGER_SLEEP_TIMER = SleepTimer(0.5, 15.0, 0.01)
function _wait_for_trigger(vault)
    #check trigger
    println("="^60)
    @info("waiting for trigger")
    while true
        if !_has_trigger(vault)
            sleep!(WAIT_FOR_TRIGGER_SLEEP_TIMER)
            continue
        end
        break
    end
    reset!(WAIT_FOR_TRIGGER_SLEEP_TIMER)
    @info("Boom!!! triggered")
end
