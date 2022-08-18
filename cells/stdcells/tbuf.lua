function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
    pcell.add_parameters(
        { "ifingers", 1 },
        { "ofingers", 1 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")

    -- inverter
    local inv = pcell.create_layout("stdcells/not_gate", { inputpos = "lower", fingers = _P.ifingers })
    gate:merge_into_shallow(inv)

    local isogate = pcell.create_layout("stdcells/isogate")
    isogate:move_anchor("left", inv:get_anchor("right"))
    gate:merge_into_shallow(isogate)

    -- clocked inverter
    local cinv = pcell.create_layout("stdcells/cinv", { fingers = _P.ofingers }):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into_shallow(cinv)

    -- connections
    geometry.path(gate, generics.metal(1), 
        geometry.path_points_yx(inv:get_anchor("O"), { 
        cinv:get_anchor("EP") 
        }), bp.routingwidth)
    geometry.path(gate, generics.metal(2), { inv:get_anchor("I"), cinv:get_anchor("EN") }, bp.routingwidth)
    geometry.viabltr(gate, 1, 2, 
        inv:get_anchor("I"):translate(-bp.glength / 2, -bp.routingwidth / 2),
        inv:get_anchor("I"):translate( bp.glength / 2,  bp.routingwidth / 2)
    )
    geometry.viabltr(gate, 1, 2, 
        cinv:get_anchor("EN"):translate(-bp.glength / 2, -bp.routingwidth / 2),
        cinv:get_anchor("EN"):translate( bp.glength / 2,  bp.routingwidth / 2)
    )

    geometry.path(gate, generics.metal(2), { cinv:get_anchor("I"), point.combine_12(inv:get_anchor("I"), cinv:get_anchor("I")) }, bp.routingwidth)
    geometry.viabltr(gate, 1, 2, 
        point.combine_12(inv:get_anchor("I"), cinv:get_anchor("I")):translate(-bp.glength / 2, -bp.routingwidth / 2),
        point.combine_12(inv:get_anchor("I"), cinv:get_anchor("I")):translate( bp.glength / 2,  bp.routingwidth / 2)
    )
    geometry.viabltr(gate, 1, 2, 
        cinv:get_anchor("I"):translate(-bp.glength / 2, -bp.routingwidth / 2),
        cinv:get_anchor("I"):translate( bp.glength / 2,  bp.routingwidth / 2)
    )

    -- ports
    gate:add_port("EN", generics.metal(1), inv:get_anchor("I"))
    gate:add_port("I", generics.metal(1), cinv:get_anchor("I"))
    gate:add_port("O", generics.metal(1), cinv:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), isogate:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), isogate:get_anchor("VSS"))
end
