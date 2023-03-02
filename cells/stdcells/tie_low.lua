function parameters()
    pcell.add_parameters(
        { "pwidthoffset", 0 },
        { "nwidthoffset", 0 },
        { "fingers", 2, posvals = even() }
    )
end

function layout(cell, _P)
    local base = pcell.create_layout("stdcells/tie_highlow", "tie_low", {
        high = false,
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset,
        fingers = _P.fingers
    })
    cell:exchange(base)
end
