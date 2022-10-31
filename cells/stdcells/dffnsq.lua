function layout(gate, _P)
    local dff = pcell.create_layout("stdcells/dff", "dffnsq", {
        clockpolarity = "negative",
        enable_Q = true,
        enable_QN = false,
        enable_set = true,
        enable_reset = false,
    })
    gate:exchange(dff)
end
