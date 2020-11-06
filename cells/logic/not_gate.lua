function parameters()
    pcell.inherit_all_parameters("logic/_base")
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength

    local _PH = pcell.clone_parameters(_P)
    _PH.fingers = _P.fingers
    gate:merge_into(pcell.create_layout("logic/_harness", _PH))

    -- common transistor options
    pcell.push_overwrites("basic/transistor", {
        fingers = _P.fingers,
        gatelength = _P.glength,
        gatespace = _P.gspace,
        sdwidth = _P.sdwidth,
    })

    -- pfet
    local pmos = pcell.create_layout("basic/transistor",
        {
            channeltype = "pmos",
            fwidth = _P.pwidth,
            gtopext = _P.powerspace + _P.dummycontheight,
            gbotext = _P.separation / 2,
            clipbot = true,
            sourcesize = _P.pwidth / 2,
            sourcealign = "top",
            drainsize = _P.pwidth / 2,
            drainalign = "top"
        }
    ):move_anchor("botgate")
    gate:merge_into(pmos)

    -- nfet
    local nmos = pcell.create_layout("basic/transistor",
        {
            channeltype = "nmos",
            fwidth = _P.nwidth,
            gbotext = _P.powerspace + _P.dummycontheight,
            gtopext = _P.separation / 2,
            cliptop = true,
            sourcesize = _P.nwidth / 2,
            sourcealign = "bottom",
            drainsize = _P.nwidth / 2,
            drainalign = "bottom"
        }
    ):move_anchor("topgate")
    gate:merge_into(nmos)

    pcell.pop_overwrites("basic/transistor")

    -- gate contact
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.contact("gate"), _P.glength, _P.gstwidth),
        _P.fingers, 1, xpitch, 0
    ))
    gate:merge_into(geometry.rectangle(
        generics.metal(1),
        _P.fingers * _P.glength + (_P.fingers - 1) * _P.gspace, _P.gstwidth
    ))

    -- signal transistors source connections
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
        _P.fingers / 2 + 1, 2,
        2 * xpitch, _P.nwidth + _P.pwidth + _P.separation + _P.powerspace
    ):translate(0, (_P.pwidth - _P.nwidth) / 2))

    -- signal transistors drain connections
    gate:merge_into(geometry.path(
        generics.metal(1),
        {
            point.create(-_P.fingers * xpitch / 2 + xpitch, (_P.separation + _P.sdwidth) / 2),
            point.create(_P.fingers * xpitch / 2,  (_P.separation + _P.sdwidth) / 2),
            point.create(_P.fingers * xpitch / 2, -(_P.separation + _P.sdwidth) / 2),
            point.create(-_P.fingers * xpitch / 2 + xpitch, -(_P.separation + _P.sdwidth) / 2),
        },
        _P.sdwidth,
        true
    ))
    local xrep = (_P.fingers % 2 == 0) and
        _P.fingers / 2 or
        (_P.fingers + 1) / 2
    local xshift = (_P.fingers % 2 == 0) and
        0 or xpitch / 2
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), _P.sdwidth, _P.pwidth),
        xrep, 1,
        2 * xpitch, 0
    ):translate(xshift, (_P.separation + _P.pwidth) / 2))
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), _P.sdwidth, _P.nwidth),
        xrep, 1,
        2 * xpitch, 0
    ):translate(xshift, -(_P.separation + _P.nwidth) / 2))

    -- ports
    gate:add_port("I", generics.metal(1), point.create(0, 0))
    gate:add_port("O", generics.metal(1), point.create(_P.fingers * xpitch / 2, 0))
    gate:add_port("VDD", generics.metal(1), point.create(0,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2))

    -- anchors
    gate:add_anchor("left", point.create(-(_P.fingers + _P.leftdummies) * xpitch / 2, 0))
    gate:add_anchor("right", point.create((_P.fingers + _P.rightdummies) * xpitch / 2, 0))
end
