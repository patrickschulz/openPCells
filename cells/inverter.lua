function parameters()
    pcell.add_parameters(
        { "oxidetype",  "0.9" },
        { "pvthtype",   "slvt" },
        { "nvthtype",   "slvt" },
        { "pwidth",    1000 },
        { "nwidth",    1000 },
        { "glength",    200 },
        { "gspace",     270 },
        { "gext",       100 },
        { "sdwidth",     60 },
        { "gstwidth",   100 },
        { "fingers",      4 },
        { "dummies",      2 },
        { "separation", 400 },
        { "ttypeext",   100 },
        { "powerwidth", 200 },
        { "powerspace", 500 },
        { "conngate",     1 },
        { "connmetal",    3 },
        { "connwidth",  100 },
        { "connoffset",   1 }
    )
end

function layout(inverter, _P)
    local xpitch = _P.gspace + _P.glength
    local dummycontheight = 80

    -- common transistor options
    pcell.overwrite_defaults("transistor", {
        fingers = _P.fingers, gatelength = _P.glength, gatespace = _P.gspace,
        sdwidth = _P.sdwidth,
    })

    -- pfet
    local pmos = pcell.create_layout("transistor",
        {
            channeltype = "pmos",
            fwidth = _P.pwidth,
            gtopext = _P.powerspace + dummycontheight,
            drawbotgate = true, botgatestrwidth = _P.gstwidth, botgatestrspace = (_P.separation - _P.gstwidth) / 2,
            clipbot = true
        }
    ):move_anchor("botgate")
    inverter:merge_into(pmos)

    -- nfet
    local nmos = pcell.create_layout("transistor",
        {
            channeltype = "nmos",
            fingers = _P.fingers, gatelength = _P.glength, fwidth = _P.pwidth, gatespace = _P.gspace,
            sdwidth = _P.sdwidth,
            gbotext = _P.powerspace + dummycontheight, gtopext = _P.separation / 2,
            drawtopgate = true, topgatestrwidth = _P.gstwidth, topgatestrspace = (_P.separation - _P.gstwidth) / 2,
            cliptop = true
        }
    ):move_anchor("topgate")
    inverter:merge_into(nmos)

    -- dummies
    local pmosdummy = pcell.create_layout("transistor",
        {
            channeltype = "pmos",
            fingers = _P.dummies, gatelength = _P.glength, fwidth = _P.pwidth, gatespace = _P.gspace,
            sdwidth = _P.sdwidth,
            gtopext = _P.powerspace + dummycontheight, gbotext = _P.separation / 2,
            clipbot = true, botgcut = true
        }
    )
    inverter:merge_into(pmosdummy:move_anchor("leftdrainsource", pmos:get_anchor("rightdrainsource")))
    inverter:merge_into(pmosdummy:move_anchor("rightdrainsource", pmos:get_anchor("leftdrainsource")))
    local nmosdummy = pcell.create_layout("transistor",
        {
            channeltype = "nmos",
            fingers = _P.dummies, gatelength = _P.glength, fwidth = _P.pwidth, gatespace = _P.gspace,
            sdwidth = _P.sdwidth,
            gbotext = _P.powerspace + dummycontheight, gtopext = _P.separation / 2,
            cliptop = true, topgcut = true
        }
    )
    inverter:merge_into(nmosdummy:move_anchor("leftdrainsource", nmos:get_anchor("rightdrainsource")))
    inverter:merge_into(nmosdummy:move_anchor("rightdrainsource", nmos:get_anchor("leftdrainsource")))

    -- dummy gate contacts
    for i = 1, _P.dummies do
        inverter:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), _P.glength, dummycontheight),
            1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + dummycontheight
        ):translate((i + (_P.fingers - 1) / 2) * xpitch, (_P.pwidth - _P.nwidth) / 2))
        inverter:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), _P.glength, dummycontheight),
            1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + dummycontheight
        ):translate(-(i + (_P.fingers - 1) / 2) * xpitch, (_P.pwidth - _P.nwidth) / 2))
    end

    -- signal transistors source connections
    inverter:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
        _P.fingers / 2 + 1, 2,
        2 * xpitch, _P.nwidth + _P.pwidth + _P.separation + _P.powerspace
    ):translate(0, 0.5 * (_P.pwidth - _P.nwidth)))

    -- signal transistors drain connections
    inverter:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(_P.connmetal), (_P.fingers - 1 + _P.connoffset) * xpitch, _P.connwidth),
        1, 2, 0, 0.5 * (_P.nwidth + _P.pwidth) + _P.separation
    ):translate(0.5 * (1 + _P.connoffset) * xpitch, 0.25 * (_P.pwidth - _P.nwidth)))
    inverter:merge_into(geometry.rectangle(
        generics.metal(_P.connmetal), 
        _P.connwidth, 0.5 * (_P.nwidth + _P.pwidth) + _P.separation + _P.connwidth
    ):translate((0.5 * _P.fingers + _P.connoffset) * xpitch, 0.25 * (_P.pwidth - _P.nwidth)))
    for i = 1, math.floor(_P.fingers / 2) do
        inverter:merge_into(geometry.rectangle(
            generics.via(1, _P.connmetal), 
            _P.sdwidth, _P.pwidth
        ):translate((i - 0.25 * _P.fingers - 0.5) * 2 * xpitch, 0.5 * (_P.pwidth + _P.separation)))
        inverter:merge_into(geometry.rectangle(
            generics.via(1, _P.connmetal), 
            _P.sdwidth, _P.nwidth
        ):translate((i - 0.25 * _P.fingers - 0.5) * 2 * xpitch, -0.5 * (_P.pwidth + _P.separation)))
    end

    -- power rails...
    inverter:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), (_P.fingers + 2 * _P.dummies) * xpitch + _P.sdwidth, _P.powerwidth),
        1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
    ):translate(0, (_P.pwidth - _P.nwidth) / 2))
    -- ... with connections
    for i = -1, 1, 2 do
        inverter:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
            _P.dummies + 1, 2, xpitch, _P.separation + _P.pwidth + _P.nwidth + _P.powerspace
        ):translate(i * (_P.fingers + _P.dummies) / 2 * xpitch, (_P.pwidth - _P.nwidth) / 2))
    end
end
