function layout(toplevel)
    local inverter = -- create inverter layout
    -- copy inverter and translate it
    local width = 1000 -- the width needs to be known
    local inverter1 = inverter:copy():translate(0 * width, 0)
    local inverter2 = inverter:copy():translate(1 * width, 0)
    local inverter3 = inverter:copy():translate(2 * width, 0)
    -- merge into toplevel
    toplevel:merge_into(inverter1)
    toplevel:merge_into(inverter2)
    toplevel:merge_into(inverter3)
end
