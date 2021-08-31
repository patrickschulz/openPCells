function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.add_parameters(
        { "nandfingers", 1 },
        { "notfingers", 1 }
    )
end

function layout(gate, _P)
    local subgate = pcell.create_layout("stdcells/1_inv_gate", { subgate = "nand_gate", subgatefingers = _P.nandfingers, notfingers = _P.notfingers })
    gate:exchange(subgate)
end
