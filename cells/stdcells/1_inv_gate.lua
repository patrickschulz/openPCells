function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
    pcell.add_parameters(
        { "subgate", "nand_gate", posvals = set("nand_gate", "nor_gate") },
        { "subgatefingers", 1 },
        { "notfingers", 1 },
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.glength + bp.gspace

    local subgateref = pcell.create_layout(string.format("stdcells/%s", _P.subgate), {
        fingers = _P.subgatefingers,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
    })
    gate:merge_into_shallow(subgateref)

    --local isogateref = pcell.create_layout("stdcells/isogate")
    --isogateref:move_anchor("left", subgateref:get_anchor("right"))
    --gate:merge_into_shallow(isogateref)

    local invref = pcell.create_layout("stdcells/not_gate", {
        fingers = _P.notfingers,
        shiftoutput = xpitch / 2,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
    })
    invref:move_anchor("left", subgateref:get_anchor("right"))
    gate:merge_into_shallow(invref)

    -- draw connection
    geometry.path(gate, generics.metal(1), {
        subgateref:get_anchor("O"),
        invref:get_anchor("I"):translate(xpitch - bp.sdwidth / 2 - bp.routingspace, 0)
    }, bp.routingwidth)

    gate:inherit_alignment_box(subgateref)
    gate:inherit_alignment_box(invref)

    -- ports
    gate:add_port("A", generics.metal(1), subgateref:get_anchor("A"))
    gate:add_port("B", generics.metal(1), subgateref:get_anchor("B"))
    gate:add_port("O", generics.metal(1), invref:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), subgateref:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), subgateref:get_anchor("VSS"))
end
