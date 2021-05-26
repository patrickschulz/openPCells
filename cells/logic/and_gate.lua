function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "nandfingers", 1 },
        { "notfingers", 1 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    pcell.push_overwrites("logic/base", { rightdummies = 0 })
    local nand = pcell.create_layout("logic/nand_gate", { fingers = _P.nandfingers })
    pcell.pop_overwrites("logic/base")
    nand:move_anchor("right")
    gate:add_child(nand, "nand_gate")

    pcell.push_overwrites("logic/base", { leftdummies = 0 })
    local inv = pcell.create_layout("logic/not_gate", { fingers = _P.notfingers })
    pcell.pop_overwrites("logic/base")
    inv:move_anchor("left")
    gate:add_child(inv, "not_gate")

    -- draw connection
    gate:merge_into(geometry.path(generics.metal(1), {
        nand:get_anchor("Z"),
        inv:get_anchor("I")
    }, bp.sdwidth))

    gate:set_alignment_box(nand:get_anchor("bottomleft") - nand:get_anchor("right"), inv:get_anchor("topright") - inv:get_anchor("left"))

    -- ports
    gate:add_port("A", generics.metal(1), nand:get_anchor("A"))
    gate:add_port("B", generics.metal(1), nand:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), inv:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), nand:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), nand:get_anchor("VSS"))
end
