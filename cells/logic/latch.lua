function parameters()
    pcell.reference_cell("logic/base")
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    -- clock inverter/buffer
    local clockbuf = pcell.create_layout("logic/buf"):move_anchor("right")
    gate:merge_into(clockbuf)

    -- first clocked inverter
    pcell.push_overwrites("logic/base", {
        leftdummies = 1
    })
    local cinv1 = pcell.create_layout("logic/cinv"):move_anchor("left", clockbuf:get_anchor("right"))
    pcell.pop_overwrites("logic/base")
    gate:merge_into(cinv1)

    -- intermediate inverter
    pcell.push_overwrites("logic/base", {
    })
    local inv = pcell.create_layout("logic/not_gate"):move_anchor("left", cinv1:get_anchor("right"))
    pcell.pop_overwrites("logic/base")
    gate:merge_into(inv)
    
    -- second clocked inverter
    pcell.push_overwrites("logic/base", {
        leftdummies = 1
    })
    local cinv2 = pcell.create_layout("logic/cinv"):move_anchor("left", inv:get_anchor("right"))
    pcell.pop_overwrites("logic/base")
    gate:merge_into(cinv2)

    -- draw connections
    gate:merge_into(geometry.path(generics.metal(2), {
        clockbuf:get_anchor("bout"),
        cinv1:get_anchor("EP")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(clockbuf:get_anchor("bout")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(cinv1:get_anchor("EP")))
    gate:merge_into(geometry.path(generics.metal(1), {
        clockbuf:get_anchor("iout"),
        cinv1:get_anchor("EP")
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), {
        cinv1:get_anchor("EP"),
        point.combine_xy(cinv1:get_anchor("EP"), cinv2:get_anchor("EN")),
        cinv2:get_anchor("EN")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(cinv2:get_anchor("EN")))
    gate:merge_into(geometry.path(generics.metal(1), {
        cinv1:get_anchor("EN"),
        cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0),
        point.combine_xy(cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0), cinv2:get_anchor("EP")),
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), {
        point.combine_xy(cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0), cinv2:get_anchor("EP")),
        cinv2:get_anchor("EP"),
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(
        generics.via(1, 2), bp.sdwidth, bp.sdwidth
    ):translate(point.combine_xy(cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0), cinv2:get_anchor("EP"))))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(cinv2:get_anchor("EP")))

    gate:merge_into(geometry.path(generics.metal(1), {
        cinv1:get_anchor("O"),
        inv:get_anchor("in")
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), {
        inv:get_anchor("O"),
        cinv2:get_anchor("EP")
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), {
        cinv2:get_anchor("O"),
        inv:get_anchor("in")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(cinv2:get_anchor("O")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(inv:get_anchor("in")))

    -- ports
    gate:add_port("D", generics.metal(1), inv:get_anchor("I"))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
