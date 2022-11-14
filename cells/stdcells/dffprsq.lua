function parameters()
    pcell.add_parameters(
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") }
    )
end

function layout(gate, _P)
    local dff = pcell.create_layout("stdcells/dff", "dfprsq", {
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        clockpolarity = "positive",
        enable_Q = true,
        enable_QN = false,
        enable_set = true,
        enable_reset = true,
    })
    gate:exchange(dff)
end
