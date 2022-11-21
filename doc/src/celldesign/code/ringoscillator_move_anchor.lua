function layout(toplevel)
    local inverter = -- create inverter layout
    -- copy inverter and move it to the origin
    local inverter1 = inverter:copy():move_anchor("input")
    -- copy and translate inverter2
    local inverter2 = inverter:copy()
        :move_anchor("input", inverter1:get_anchor("output"))
    -- copy and translate inverter3
    local inverter3 = inverter:copy()
        :move_anchor("input", inverter2:get_anchor("output"))
    -- merge inverters into toplevel
    toplevel:merge_into(inverter1)
    toplevel:merge_into(inverter2)
    toplevel:merge_into(inverter3)
end
