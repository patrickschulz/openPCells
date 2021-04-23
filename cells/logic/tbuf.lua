function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "ifingers", 1 },
        { "ofingers", 1 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    -- inverter
    pcell.push_overwrites("logic/base", {
        rightdummies = _P.ifingers % 2 == 0 and 0 or 1
    })
    local inv = pcell.create_layout("logic/not_gate", { fingers = _P.ifingers }):move_anchor("right")
    pcell.pop_overwrites("logic/base")

    -- clocked inverter
    pcell.push_overwrites("logic/base", {
        leftdummies = _P.ofingers % 2 == 0 and 0 or 1
    })
    local cinv = pcell.create_layout("logic/cinv", { fingers = _P.ofingers }):move_anchor("left")
    pcell.pop_overwrites("logic/base")
    gate:merge_into(inv)
    gate:merge_into(cinv:translate(2000, 0))

    -- draw connection
    local ishift = _P.ifingers % 2 == 0 and 1 or 0
    local oshift = _P.ifingers % 2 == 0 and 1 or 0
    gate:merge_into(geometry.path(generics.metal(1), {
        point.create(-(bp.glength + bp.gspace) + ishift * (bp.glength + bp.gspace) - bp.sdwidth / 2, -bp.separation / 4),
        point.create( (bp.glength + bp.gspace) + oshift * (bp.glength + bp.gspace) + bp.glength + bp.gspace / 2, -bp.separation / 4),
    }, bp.sdwidth))

    --[[
    -- ports
    gate:add_port("I", generics.metal(1), inv:get_anchor("I"))
    gate:add_port("O", generics.metal(1), cinv:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
    --]]
end
