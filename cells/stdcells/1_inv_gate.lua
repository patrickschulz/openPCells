function parameters()
    pcell.add_parameters(
        { "subgate", "nand_gate", posvals = set("nand_gate", "nor_gate", "xor_gate") },
        { "subgatefingers", 1 },
        { "notfingers", 1 }
    )
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local xpitch = _P.gatelength + _P.gatespace

    local subgatename = string.format("stdcells/%s", _P.subgate)

    local subgate_baseparameters = {}
    for k, v in pairs(_P) do
        if pcell.has_parameter(subgatename, k) then
            subgate_baseparameters[k] = v
        end
    end
    local subgateref = pcell.create_layout(subgatename, "subgate", util.add_options(subgate_baseparameters, {
        fingers = _P.subgatefingers,
    }))
    gate:merge_into(subgateref)

    local notgate_baseparameters = {}
    for k, v in pairs(_P) do
        if pcell.has_parameter("stdcells/not_gate", k) then
            notgate_baseparameters[k] = v
        end
    end
    local invref = pcell.create_layout("stdcells/not_gate", "inv", util.add_options(notgate_baseparameters, {
        fingers = _P.notfingers,
        shiftoutput = xpitch / 2,
    }))
    invref:abut_right(subgateref)
    gate:merge_into(invref)

    -- draw connection
    geometry.rectanglebltr(gate, generics.metal(1),
        subgateref:get_anchor("O") .. invref:get_anchor("I"):translate(xpitch - _P.sdwidth / 2 - _P.routingatespace, 0),
        invref:get_anchor("I"):translate(xpitch - _P.sdwidth / 2 - _P.routingatespace, _P.routingwidth)
    )

    gate:inherit_alignment_box(subgateref)
    gate:inherit_alignment_box(invref)

    -- ports
    gate:add_port("A", generics.metalport(1), subgateref:get_anchor("A"))
    gate:add_port("B", generics.metalport(1), subgateref:get_anchor("B"))
    gate:add_port("O", generics.metalport(1), invref:get_anchor("O"))
    gate:add_port("VDD", generics.metalport(1), subgateref:get_anchor("VDD"))
    gate:add_port("VSS", generics.metalport(1), subgateref:get_anchor("VSS"))
end
