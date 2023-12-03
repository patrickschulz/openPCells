function layout(toplevel)
    local inverter = -- create inverter layout
    -- copy inverters
    local inverter1 = inverter:copy()
    local inverter2 = inverter:copy()
    local inverter3 = inverter:copy()
    
    -- get required displacement for inverter2
    local output1 = inverter1:get_anchor("output")
    local input2 = inverter2:get_anchor("input")
    -- translate inverter2
    local inverter2 = inverter2:translate(output1 - input2)

    -- get required displacement for inverter3
    local output2 = inverter2:get_anchor("output")
    local input3 = inverter3:get_anchor("input")
    -- translate inverter3
    local inverter3 = inverter3:translate(output2 - input3)

    -- merge inverters into toplevel
    toplevel:merge_into(inverter1)
    toplevel:merge_into(inverter2)
    toplevel:merge_into(inverter3)
end
