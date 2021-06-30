function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "norfingers", 1 },
        { "notfingers", 1 }
    )
end

function layout(gate, _P)
    local subgate = pcell.create_layout("logic/1_inv_gate", { subgate = "nor_gate", subgatefingers = _P.norfingers, notfingers = _P.notfingers })
    gate:exchange(subgate)
end
