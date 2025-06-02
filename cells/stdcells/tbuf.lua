function parameters()
    pcell.add_parameters(
        { "ifingers", 1 },
        { "ofingers", 1 }
    )
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    -- inverter
    local inv = pcell.create_layout("stdcells/not_gate", "inv", { inputpos = "lower1", fingers = _P.ifingers })
    gate:merge_into(inv)

    local isogate = pcell.create_layout("stdcells/isogate", "isogate")
    isogate:abut_right(inv)
    gate:merge_into(isogate)

    -- clocked inverter
    local cinv = pcell.create_layout("stdcells/cinv", "cinv", { fingers = _P.ofingers })
    cinv:abut_right(isogate)
    gate:merge_into(cinv)

    -- connections
    geometry.path(gate, generics.metal(1), 
        geometry.path_points_yx(inv:get_anchor("O"), { 
        cinv:get_anchor("EP") 
        }), _P.routingwidth)
    geometry.path(gate, generics.metal(2), { inv:get_anchor("I"), cinv:get_anchor("EN") }, _P.routingwidth)
    geometry.viabltr(gate, 1, 2, 
        inv:get_anchor("I"):translate(-_P.gatelength / 2, -_P.routingwidth / 2),
        inv:get_anchor("I"):translate( _P.gatelength / 2,  _P.routingwidth / 2)
    )
    geometry.viabltr(gate, 1, 2, 
        cinv:get_anchor("EN"):translate(-_P.gatelength / 2, -_P.routingwidth / 2),
        cinv:get_anchor("EN"):translate( _P.gatelength / 2,  _P.routingwidth / 2)
    )

    geometry.path(gate, generics.metal(2), { cinv:get_anchor("I"), point.combine_12(inv:get_anchor("I"), cinv:get_anchor("I")) }, _P.routingwidth)
    geometry.viabltr(gate, 1, 2, 
        point.combine_12(inv:get_anchor("I"), cinv:get_anchor("I")):translate(-_P.gatelength / 2, -_P.routingwidth / 2),
        point.combine_12(inv:get_anchor("I"), cinv:get_anchor("I")):translate( _P.gatelength / 2,  _P.routingwidth / 2)
    )
    geometry.viabltr(gate, 1, 2, 
        cinv:get_anchor("I"):translate(-_P.gatelength / 2, -_P.routingwidth / 2),
        cinv:get_anchor("I"):translate( _P.gatelength / 2,  _P.routingwidth / 2)
    )

    -- ports
    gate:add_port_with_anchor("EN", generics.metalport(1), inv:get_anchor("I"))
    gate:add_port_with_anchor("I", generics.metalport(1), cinv:get_anchor("I"))
    gate:add_port_with_anchor("O", generics.metalport(1), cinv:get_anchor("O"))
    gate:add_port("VDD", generics.metalport(1), isogate:get_anchor("VDD"))
    gate:add_port("VSS", generics.metalport(1), isogate:get_anchor("VSS"))
end
