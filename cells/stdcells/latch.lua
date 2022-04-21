function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")

    -- clock inverter/buffer
    local clockbuf = pcell.create_layout("stdcells/buf"):move_anchor("right")
    gate:merge_into_shallow(clockbuf)

    -- first clocked inverter
    pcell.push_overwrites("stdcells/harness", {
        leftdummies = 1
    })
    local cinv1 = pcell.create_layout("stdcells/cinv"):move_anchor("left", clockbuf:get_anchor("right"))
    pcell.pop_overwrites("stdcells/harness")
    gate:merge_into_shallow(cinv1)

    -- intermediate inverter
    pcell.push_overwrites("stdcells/harness", {
    })
    local inv = pcell.create_layout("stdcells/not_gate"):move_anchor("left", cinv1:get_anchor("right"))
    pcell.pop_overwrites("stdcells/harness")
    gate:merge_into_shallow(inv)
    
    -- second clocked inverter
    pcell.push_overwrites("stdcells/harness", {
        leftdummies = 1
    })
    local cinv2 = pcell.create_layout("stdcells/cinv"):move_anchor("left", inv:get_anchor("right"))
    pcell.pop_overwrites("stdcells/harness")
    gate:merge_into_shallow(cinv2)

    -- draw connections
    geometry.path(gate, generics.metal(2), 
        geometry.path_points_yx(clockbuf:get_anchor("bout"), {
        cinv1:get_anchor("EP")
    }), bp.sdwidth)
    geometry.viabltr(gate, 1, 2, 
        clockbuf:get_anchor("bout"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        clockbuf:get_anchor("bout"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2, 
        cinv1:get_anchor("EP"):translate(-bp.glength / 2, -bp.sdwidth / 2),
        cinv1:get_anchor("EP"):translate( bp.glength / 2,  bp.sdwidth / 2)
    )
    geometry.path(gate, generics.metal(3), {
        clockbuf:get_anchor("iout"),
        cinv1:get_anchor("EP")
    }, bp.sdwidth)
    geometry.path(gate, generics.metal(2), {
        cinv1:get_anchor("EP"),
        point.combine_12(cinv1:get_anchor("EP"), cinv2:get_anchor("EN")),
        cinv2:get_anchor("EN")
    }, bp.sdwidth)
    --[[
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(cinv2:get_anchor("EN")))
    gate:merge_into_shallow(geometry.path(generics.metal(1), {
        cinv1:get_anchor("EN"),
        cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0),
        point.combine_12(cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0), cinv2:get_anchor("EP")),
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(2), {
        point.combine_12(cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0), cinv2:get_anchor("EP")),
        cinv2:get_anchor("EP"),
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(
        generics.via(1, 2), bp.sdwidth, bp.sdwidth
    ):translate(point.combine_12(cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0), cinv2:get_anchor("EP"))))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(cinv2:get_anchor("EP")))

    gate:merge_into_shallow(geometry.path(generics.metal(1), {
        cinv1:get_anchor("O"),
        inv:get_anchor("I")
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), {
        inv:get_anchor("O"),
        cinv2:get_anchor("EP")
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(2), {
        cinv2:get_anchor("O"),
        inv:get_anchor("I")
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(cinv2:get_anchor("O")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(inv:get_anchor("I")))
    --]]

    -- ports
    gate:add_port("D", generics.metal(1), inv:get_anchor("I"))
    gate:add_port("VDD", generics.metal(1), inv:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), inv:get_anchor("VSS"))
end
