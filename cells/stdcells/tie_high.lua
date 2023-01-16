function parameters()
    pcell.add_parameters(
        { "pwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "fingers", 2, posvals = even() }
    )
end

function layout(cell, _P)
    local base = pcell.create_layout("stdcells/tie_highlow", "tie_high", {
        high = true,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        fingers = _P.fingers
    })
    cell:exchange(base)
end
