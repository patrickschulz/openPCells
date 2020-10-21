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
            drawbotgate = true, botgatestrwidth = _P.gstwidth, botgatestrspace = (_P.separation - _P.gstwidth) / 2,
            clipbot = true,
            innersourcedrainsize = _P.pwidth / 2,
            innersourcedrainalign = "top",
            outersourcedrainsize = _P.pwidth / 2,
            outersourcedrainalign = "top"
        }
    ):move_anchor("botgate")
    gate:merge_into(pmos)

    -- nfet
    local nmos = pcell.create_layout("basic/transistor",
        {
            channeltype = "nmos",
            fwidth = _P.nwidth,
            gbotext = _P.powerspace + _P.dummycontheight, 
            drawtopgate = true, topgatestrwidth = _P.gstwidth, topgatestrspace = (_P.separation - _P.gstwidth) / 2,
            cliptop = true,
            innersourcedrainsize = _P.nwidth / 2,
            innersourcedrainalign = "bottom",
            outersourcedrainsize = _P.nwidth / 2,
            outersourcedrainalign = "bottom"
        }
    ):move_anchor("topgate")
    gate:merge_into(nmos)

    pcell.pop_overwrites("basic/transistor")

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

    -- anchors
    gate:add_anchor("left", point.create(-(_P.fingers + _P.leftdummies) * xpitch / 2, 0))
    gate:add_anchor("right", point.create((_P.fingers + _P.rightdummies) * xpitch / 2, 0))
end
