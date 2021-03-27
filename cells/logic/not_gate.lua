function parameters()
    pcell.reference_cell("basic/transistor")
    pcell.reference_cell("logic/base")
    pcell.reference_cell("logic/isogate")
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("shiftinput", 0)
    pcell.add_parameter("connectoutput", true)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength

    gate:merge_into(pcell.create_layout("logic/harness", { fingers = _P.fingers }))

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
    gate:merge_into(geometry.multiple_x(
        geometry.rectangle(generics.contact("gate"), bp.glength, bp.gstwidth),
        _P.fingers, xpitch
    ):translate(0, _P.shiftinput))
    gate:merge_into(geometry.rectangle(
        generics.metal(1),
        _P.fingers * bp.glength + (_P.fingers - 1) * bp.gspace, bp.gstwidth
    ):translate(0, _P.shiftinput))

    -- signal transistors source connections
    gate:merge_into(geometry.multiple_xy(
        geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
        _P.fingers / 2 + 1, 2,
        2 * xpitch, bp.nwidth + bp.pwidth + bp.separation + bp.powerspace
    ):translate(0, (bp.pwidth - bp.nwidth) / 2))

    -- signal transistors drain connections
    if _P.fingers > 2 then
        gate:merge_into(geometry.path(
            generics.metal(1),
            {
                point.create(-_P.fingers * xpitch / 2 + xpitch, (bp.separation + bp.sdwidth) / 2),
                point.create(_P.fingers * xpitch / 2,  (bp.separation + bp.sdwidth) / 2),
            },
            bp.sdwidth,
            true
        ))
        gate:merge_into(geometry.path(
            generics.metal(1),
            {
                point.create(_P.fingers * xpitch / 2, -(bp.separation + bp.sdwidth) / 2),
                point.create(-_P.fingers * xpitch / 2 + xpitch, -(bp.separation + bp.sdwidth) / 2),
            },
            bp.sdwidth,
            true
        ))
    end
    if _P.connectoutput then
        if bp.compact then
            gate:merge_into(geometry.path(
                generics.metal(1),
                {
                    point.create(_P.fingers * xpitch / 2,  (bp.separation + bp.sdwidth) / 2),
                    point.create(_P.fingers * xpitch / 2, -(bp.separation + bp.sdwidth) / 2),
                },
                bp.sdwidth,
                true
            ))
        else
            gate:merge_into(geometry.path(
                generics.metal(1),
                {
                    point.create(_P.fingers * xpitch / 2,  (bp.separation + bp.sdwidth) / 2),
                    point.create(_P.fingers * xpitch,  (bp.separation + bp.sdwidth) / 2),
                    point.create(_P.fingers * xpitch, -(bp.separation + bp.sdwidth) / 2),
                    point.create(_P.fingers * xpitch / 2, -(bp.separation + bp.sdwidth) / 2),
                },
                bp.sdwidth,
                true
            ))
        end
    end

    -- alignement box
    gate:set_alignment_box(
        point.create(
            -_P.fingers * xpitch / 2 - bp.leftdummies * xpitch, 
            -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2
        ),
        point.create(
            _P.fingers * xpitch / 2 + bp.rightdummies * xpitch, 
            bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2
        )
    )

    -- anchors
    local ls = (_P.fingers == 1) and 1 or -math.max(_P.fingers - 2, 0)
    local rs = (_P.fingers % 2 == 0) and math.max(_P.fingers - 2, 0) or _P.fingers
    gate:add_anchor("OTL", point.create(ls * xpitch / 2,  bp.separation / 2 + bp.sdwidth / 2))
    gate:add_anchor("OTR", point.create(rs * xpitch / 2,  bp.separation / 2 + bp.sdwidth / 2))
    gate:add_anchor("OBL", point.create(ls * xpitch / 2, -bp.separation / 2 - bp.sdwidth / 2))
    gate:add_anchor("OBR", point.create(rs * xpitch / 2, -bp.separation / 2 - bp.sdwidth / 2))

    -- ports
    gate:add_port("I", generics.metal(1), point.create(0, _P.shiftinput))
    if bp.compact then
        gate:add_port("O", generics.metal(1), point.create(_P.fingers * xpitch / 2, 0))
    else
        gate:add_port("O", generics.metal(1), point.create(_P.fingers * xpitch, 0))
    end
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
