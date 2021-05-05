function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "ifingers", 1 },
        { "ofingers", 1 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local isogate = pcell.create_layout("logic/isogate")
    gate:merge_into(isogate)

    -- inverter
    pcell.push_overwrites("logic/base", { rightdummies = 0 })
    local inv = pcell.create_layout("logic/not_gate", { inputpos = "lower", fingers = _P.ifingers }):move_anchor("right", isogate:get_anchor("left"))
    pcell.pop_overwrites("logic/base")
    gate:merge_into(inv)

    -- clocked inverter
    pcell.push_overwrites("logic/base", { leftdummies = 0 })
    local cinv = pcell.create_layout("logic/cinv", { fingers = _P.ofingers }):move_anchor("left", isogate:get_anchor("right"))
    pcell.pop_overwrites("logic/base")
    gate:merge_into(cinv)

    -- connections
    gate:merge_into(geometry.path_yx(generics.metal(1), { inv:get_anchor("O"), cinv:get_anchor("EP") }, bp.gstwidth))
    gate:merge_into(geometry.path(generics.metal(2), { inv:get_anchor("I"), cinv:get_anchor("EN") }, bp.gstwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.gstwidth):translate(inv:get_anchor("I")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.gstwidth):translate(cinv:get_anchor("EN")))

    gate:merge_into(geometry.path(generics.metal(2), { cinv:get_anchor("I"), point.combine_12(inv:get_anchor("I"), cinv:get_anchor("I")) }, bp.gstwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.gstwidth):translate(point.combine_12(inv:get_anchor("I"), cinv:get_anchor("I"))))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.gstwidth):translate(cinv:get_anchor("I")))

    -- ports
    gate:add_port("EN", generics.metal(1), inv:get_anchor("I"))
    gate:add_port("I", generics.metal(1), cinv:get_anchor("I"))
    gate:add_port("O", generics.metal(1), cinv:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), isogate:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), isogate:get_anchor("VSS"))
end
