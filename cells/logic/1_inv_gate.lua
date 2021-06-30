function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "subgate", "nand_gate", posvals = set("nand_gate", "nor_gate") },
        { "subgatefingers", 1 },
        { "notfingers", 1 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.glength + bp.gspace

    pcell.push_overwrites("logic/base", { rightdummies = 0 })
    local subgateref = pcell.create_layout(string.format("logic/%s", _P.subgate), { fingers = _P.subgatefingers })
    pcell.pop_overwrites("logic/base")
    local subgate = gate:add_child(subgateref, _P.subgate)

    local isogateref = pcell.create_layout("logic/isogate")
    local isogate = gate:add_child(isogateref, "isogate")
    isogate:move_anchor("left", subgate:get_anchor("right"))

    pcell.push_overwrites("logic/base", { leftdummies = 0 })
    local invref = pcell.create_layout("logic/not_gate", { fingers = _P.notfingers, shiftoutput = xpitch / 2 })
    pcell.pop_overwrites("logic/base")
    local inv = gate:add_child(invref, "not_gate")
    inv:move_anchor("left", isogate:get_anchor("right"))

    -- draw connection
    gate:merge_into_shallow(geometry.path(generics.metal(1), {
        subgate:get_anchor("Z"),
        inv:get_anchor("I"):translate(xpitch - bp.sdwidth / 2 - bp.gstspace, 0)
    }, bp.gstwidth))

    gate:inherit_alignment_box(subgate)
    gate:inherit_alignment_box(inv)

    -- ports
    gate:add_port("A", generics.metal(1), subgate:get_anchor("A"))
    gate:add_port("B", generics.metal(1), subgate:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), inv:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), subgate:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), subgate:get_anchor("VSS"))
end
