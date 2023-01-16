function parameters()
    pcell.add_parameters(
        { "norfingers", 1 },
        { "notfingers", 1 },
        { "pwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * technology.get_dimension("Minimum Gate Width") }
    )
end

function layout(gate, _P)
    local subgate = pcell.create_layout("stdcells/1_inv_gate", "or_gate", {
        subgate = "nor_gate",
        subgatefingers = _P.norfingers,
        notfingers = _P.notfingers,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth
    })
    gate:exchange(subgate)
end
