function layout(gate, _P)
    local dff = pcell.create_layout("stdcells/dff", {
        clockpolarity = "negative",
        enable_Q = true,
        enable_QN = false,
        enable_set = false,
        enable_reset = false,
    })
    gate:exchange(dff)
end
