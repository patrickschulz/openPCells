function parameters()
    pcell.add_parameters(
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "fingers", 4, posvals = even() }
    )
    pcell.reference_cell("stdcells/base")
end

function layout(cell, _P)
    local base = pcell.create_layout("stdcells/tie_highlow", {
        high = false,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        fingers = _P.fingers
    })
    cell:exchange(base)
end
