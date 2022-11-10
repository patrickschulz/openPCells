function parameters()
    pcell.add_parameters(
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") }
    )
end

function layout(gate, _P)
    local dff = pcell.create_layout("stdcells/dff", "dffnrq", {
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        clockpolarity = "negative",
        enable_Q = true,
        enable_QN = false,
        enable_set = false,
        enable_reset = true,
    })
    gate:exchange(dff)
end
