function parameters()
    pcell.inherit_all_parameters("logic/_base")
    pcell.add_parameters(
        { "ifingers", 1 },
        { "ofingers", 1 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/_base")

    pcell.push_overwrites("logic/_base", {
        rightdummies = 0
    })
    local iinv = pcell.create_layout("logic/not_gate", { fingers = _P.ifingers }):move_anchor("right")
    pcell.pop_overwrites("logic/_base")
    pcell.push_overwrites("logic/_base", {
        leftdummies = 0
    })
    local oinv = pcell.create_layout("logic/not_gate", { fingers = _P.ofingers }):move_anchor("left")
    pcell.pop_overwrites("logic/_base")
    gate:merge_into(iinv)
    gate:merge_into(oinv)

    -- draw connection
    gate:merge_into(geometry.path(generics.metal(1), {
        point.create(-bp.sdwidth / 2, 0),
        point.create(bp.glength + bp.gspace / 2, 0),
    }, bp.sdwidth))

    -- ports
    gate:add_port("I", generics.metal(1), iinv:get_anchor("I"))
    gate:add_port("O", generics.metal(1), oinv:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
