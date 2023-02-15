function parameters()
    pcell.add_parameters(
        { "pwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "cinvlatch1separationdummies", 1 },
        { "tgatelatch2separationdummies", 1 },
        { "latch2outbufseparationdummies", 1 }
    )
end

function layout(gate, _P)
    local dff = pcell.create_layout("stdcells/dff", "dffnq", {
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        cinvlatch1separationdummies = _P.cinvlatch1separationdummies,
        tgatelatch2separationdummies = _P.tgatelatch2separationdummies,
        latch2outbufseparationdummies = _P.latch2outbufseparationdummies,
        clockpolarity = "negative",
        enable_Q = true,
        enable_QN = false,
        enable_set = false,
        enable_reset = false,
    })
    gate:exchange(dff)
end
