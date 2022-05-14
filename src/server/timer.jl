mutable struct SleepTimer
    tmin::Float64
    tmax::Float64
    dt::Float64
    t::Float64
end

function SleepTimer(tmin, tmax, dt) 
    st = SleepTimer(tmin, tmax, dt, 0)
    reset!(st)
    return st
end

Base.sleep(st::SleepTimer) = sleep(st.t)

set_t!(st::SleepTimer, t::Float64) = (st.t = clamp(t, st.tmin, st.tmax))
update!(st::SleepTimer) = set_t!(st, st.t + st.dt)
sleep!(st::SleepTimer) = (sleep(st); update!(st))
reset!(st::SleepTimer) = set_t!(st, st.dt > 0 ? st.tmin : st.tmax)