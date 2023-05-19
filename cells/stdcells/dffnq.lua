function parameters()
    pcell.add_parameters(
        { "pwidthoffset", 0 },
        { "nwidthoffset", 0 },
        { "cinvlatch1separationdummies", 1 },
        { "tgatelatch2separationdummies", 1 },
        { "latch2outbufseparationdummies", 1 }
    )
end

function layout(gate, _P)
    local dff = pcell.create_layout("stdcells/dff", "dffnq", {
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset,
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
