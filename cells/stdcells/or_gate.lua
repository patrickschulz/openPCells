function parameters()
    pcell.add_parameters(
        { "norfingers", 1 },
        { "notfingers", 1 }
    )
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local baseparameters = {}
    for k, v in pairs(_P) do
        if pcell.has_parameter("stdcells/1_inv_gate", k) then
            baseparameters[k] = v
        end
    end
    local subgate = pcell.create_layout("stdcells/1_inv_gate", "and_gate", util.add_options(baseparameters, {
        subgate = "nor_gate",
        subgatefingers = _P.norfingers,
        notfingers = _P.notfingers,
    }))
    gate:exchange(subgate)
end
