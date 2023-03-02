function parameters()
    pcell.add_parameters(
        { "nandfingers", 1 },
        { "notfingers", 1 },
        { "pwidthoffset", 0 },
        { "nwidthoffset", 0 }
    )
end

function layout(gate, _P)
    local subgate = pcell.create_layout("stdcells/1_inv_gate", "and_gate", {
        subgate = "nand_gate",
        subgatefingers = _P.nandfingers,
        notfingers = _P.notfingers,
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset
    })
    gate:exchange(subgate)
end
