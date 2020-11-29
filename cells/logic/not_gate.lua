function parameters()
    pcell.inherit_all_parameters("logic/_base")
    pcell.add_parameter("fingers", 1)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/_base")
    local xpitch = bp.gspace + bp.glength

    gate:merge_into(pcell.create_layout("logic/_harness", { fingers = _P.fingers }))

    -- common transistor options
    pcell.push_overwrites("basic/transistor", {
        fingers = _P.fingers,
        gatelength = bp.glength,
        gatespace = bp.gspace,
        sdwidth = bp.sdwidth,
    })

    -- pfet
    local pmos = pcell.create_layout("basic/transistor",
        {
            channeltype = "pmos",
            fwidth = bp.pwidth,
            gtopext = bp.powerspace + bp.dummycontheight / 2 + bp.powerwidth / 2,
            gbotext = bp.separation / 2,
            clipbot = true,
            sourcesize = bp.pwidth / 2,
            sourcealign = "top",
            drainsize = bp.pwidth / 2,
            drainalign = "bottom"
        }
    ):move_anchor("botgate")
    gate:merge_into(pmos)

    -- nfet
    local nmos = pcell.create_layout("basic/transistor",
        {
            channeltype = "nmos",
            fwidth = bp.nwidth,
            gbotext = bp.powerspace + bp.dummycontheight / 2 + bp.powerwidth / 2,
            gtopext = bp.separation / 2,
            cliptop = true,
            sourcesize = bp.nwidth / 2,
            sourcealign = "bottom",
            drainsize = bp.nwidth / 2,
            drainalign = "top"
        }
    ):move_anchor("topgate")
    gate:merge_into(nmos)

    pcell.pop_overwrites("basic/transistor")

    -- gate contact
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.contact("gate"), bp.glength, bp.gstwidth),
        _P.fingers, 1, xpitch, 0
    ))
    gate:merge_into(geometry.rectangle(
        generics.metal(1),
        _P.fingers * bp.glength + (_P.fingers - 1) * bp.gspace, bp.gstwidth
    ))

    -- signal transistors source connections
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
        _P.fingers / 2 + 1, 2,
        2 * xpitch, bp.nwidth + bp.pwidth + bp.separation + bp.powerspace
    ):translate(0, (bp.pwidth - bp.nwidth) / 2))

    -- signal transistors drain connections
    gate:merge_into(geometry.path(
        generics.metal(1),
        {
            point.create(-_P.fingers * xpitch / 2 + xpitch, (bp.separation + bp.sdwidth) / 2),
            point.create(_P.fingers * xpitch / 2,  (bp.separation + bp.sdwidth) / 2),
            point.create(_P.fingers * xpitch / 2, -(bp.separation + bp.sdwidth) / 2),
            point.create(-_P.fingers * xpitch / 2 + xpitch, -(bp.separation + bp.sdwidth) / 2),
        },
        bp.sdwidth,
        true
    ))

    -- ports
    gate:add_port("I", generics.metal(1), point.create(0, 0))
    gate:add_port("O", generics.metal(1), point.create(_P.fingers * xpitch / 2, 0))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))

    -- anchors
    gate:add_anchor("left", point.create(-_P.fingers * xpitch / 2 + bp.leftdummies * xpitch, 0))
    gate:add_anchor("right", point.create(_P.fingers * xpitch / 2 + bp.rightdummies * xpitch, 0))
end
