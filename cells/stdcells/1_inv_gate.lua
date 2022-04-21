function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
    pcell.add_parameters(
        { "subgate", "nand_gate", posvals = set("nand_gate", "nor_gate") },
        { "subgatefingers", 1 },
        { "notfingers", 1 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.glength + bp.gspace

    pcell.push_overwrites("stdcells/harness", { rightdummies = 0 })
    local subgateref = pcell.create_layout(string.format("stdcells/%s", _P.subgate), { fingers = _P.subgatefingers })
    pcell.pop_overwrites("stdcells/harness")
    gate:merge_into_shallow(subgateref)

    local isogateref = pcell.create_layout("stdcells/isogate")
    isogateref:move_anchor("left", subgateref:get_anchor("right"))
    gate:merge_into_shallow(isogateref)

    pcell.push_overwrites("stdcells/harness", { leftdummies = 0, rightdummies = 1 })
    local invref = pcell.create_layout("stdcells/not_gate", { fingers = _P.notfingers, shiftoutput = xpitch / 2 })
    pcell.pop_overwrites("stdcells/harness")
    invref:move_anchor("left", isogateref:get_anchor("right"))
    gate:merge_into_shallow(invref)

    -- draw connection
    geometry.path(gate, generics.metal(1), {
        subgateref:get_anchor("O"),
        invref:get_anchor("I"):translate(xpitch - bp.sdwidth / 2 - bp.gstspace, 0)
    }, bp.gstwidth)

    gate:inherit_alignment_box(subgateref)
    gate:inherit_alignment_box(invref)

    -- ports
    gate:add_port("A", generics.metal(1), subgateref:get_anchor("A"))
    gate:add_port("B", generics.metal(1), subgateref:get_anchor("B"))
    gate:add_port("O", generics.metal(1), invref:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), subgateref:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), subgateref:get_anchor("VSS"))
end
