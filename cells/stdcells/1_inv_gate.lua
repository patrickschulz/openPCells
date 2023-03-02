function parameters()
    pcell.add_parameters(
        { "subgate", "nand_gate", posvals = set("nand_gate", "nor_gate", "xor_gate") },
        { "subgatefingers", 1 },
        { "notfingers", 1 },
        { "pwidthoffset", 0 },
        { "nwidthoffset", 0 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.glength + bp.gspace

    local subgateref = pcell.create_layout(string.format("stdcells/%s", _P.subgate), "subgate", {
        fingers = _P.subgatefingers,
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset,
    })
    gate:merge_into(subgateref)

    local invref = pcell.create_layout("stdcells/not_gate", "inv", {
        fingers = _P.notfingers,
        shiftoutput = xpitch / 2,
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset,
    })
    invref:abut_right(subgateref)
    gate:merge_into(invref)

    -- draw connection
    geometry.rectanglebltr(gate, generics.metal(1),
        subgateref:get_anchor("O") .. invref:get_anchor("I"):translate(xpitch - bp.sdwidth / 2 - bp.routingspace, 0),
        invref:get_anchor("I"):translate(xpitch - bp.sdwidth / 2 - bp.routingspace, bp.routingwidth)
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
