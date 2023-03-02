function parameters()
    pcell.add_parameters(
        { "norfingers", 1 },
        { "notfingers", 1 },
        { "pwidthoffset", 0 },
        { "nwidthoffset", 0 }
    )
end

function layout(gate, _P)
    local subgate = pcell.create_layout("stdcells/1_inv_gate", "or_gate", {
        subgate = "nor_gate",
        subgatefingers = _P.norfingers,
        notfingers = _P.notfingers,
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset
    })
    gate:exchange(subgate)
end
