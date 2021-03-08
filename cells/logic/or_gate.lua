function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "norfingers", 1 },
        { "notfingers", 1 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    pcell.push_overwrites("logic/base", {
        rightdummies = 0
    })
    local nor = pcell.create_layout("logic/nor_gate", { fingers = _P.norfingers }):move_anchor("right")
    pcell.pop_overwrites("logic/base")
    pcell.push_overwrites("logic/base", {
        leftdummies = 0
    })
    local inv = pcell.create_layout("logic/not_gate", { fingers = _P.notfingers }):move_anchor("left")
    pcell.pop_overwrites("logic/base")
    gate:merge_into(nor)
    gate:merge_into(inv)

    -- draw connection
    gate:merge_into(geometry.path(generics.metal(1), {
        point.create(-bp.sdwidth / 2, 0),
        point.create(bp.glength + bp.gspace / 2, 0),
    }, bp.sdwidth))

    gate:inherit_alignment_box(nor)
    gate:inherit_alignment_box(inv)

    -- ports
    gate:add_port("A", generics.metal(1), nor:get_anchor("A"))
    gate:add_port("B", generics.metal(1), nor:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), inv:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
