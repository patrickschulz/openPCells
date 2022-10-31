function layout(gate, _P)
    local dff = pcell.create_layout("stdcells/dff", "dffnrq", {
        clockpolarity = "negative",
        enable_Q = true,
        enable_QN = false,
        enable_set = false,
        enable_reset = true,
    })
    gate:exchange(dff)
end
