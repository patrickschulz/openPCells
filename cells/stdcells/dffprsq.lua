function layout(gate, _P)
    local dff = pcell.create_layout("stdcells/dff", "dfprsq", {
        clockpolarity = "positive",
        enable_Q = true,
        enable_QN = false,
        enable_set = true,
        enable_reset = true,
    })
    gate:exchange(dff)
end
