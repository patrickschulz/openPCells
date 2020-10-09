function parameters()
    pcell.add_parameters(
        { "oxidetype",  "0.9" },
        { "pvthtype",   "slvt" },
        { "nvthtype",   "slvt" },
        { "pwidth",       1 },
        { "nwidth",       1 },
        { "glength",    200 },
        { "gext",       100 },
        { "sdwidth",    200 },
        { "gspace",     270 },
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

    -- pfet
    local pmos = celllib.create_layout("transistor",
        {
            channeltype = "pmos",
            fingers = _P.fingers, gatelength = _P.glength, fwidth = _P.pwidth, gatespace = _P.gspace,
            sdwidth = _P.sdwidth,
            gtopext = _P.powerspace + dummycontheight, gbotext = _P.separation / 2,
            drawbotgate = true,
            clipbot = true
        }
    ):move_anchor("botgate")
    inverter:merge_into(pmos)

    -- nfet
    local nmos = celllib.create_layout("transistor",
        {
            channeltype = "nmos",
            fingers = _P.fingers, gatelength = _P.glength, fwidth = _P.pwidth, gatespace = _P.gspace,
            sdwidth = _P.sdwidth,
            gbotext = _P.powerspace + dummycontheight, gtopext = _P.separation / 2,
            drawtopgate = true,
            cliptop = true
        }
    ):move_anchor("topgate")
    inverter:merge_into(nmos)

    -- dummies
    local pmosdummy = celllib.create_layout("transistor",
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
    local nmosdummy = celllib.create_layout("transistor",
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

    --[[
    -- dummy gate contacts
    for i = 1, _P.dummies do
        inverter:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), _P.glength, dummycontheight),
            1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + dummycontheight
        ):translate((i + 0.5 * (_P.fingers - 1)) * xpitch, 0.5 * (_P.pwidth - _P.nwidth)))
        inverter:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), _P.glength, dummycontheight),
            1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + dummycontheight
        ):translate(-(i + 0.5 * (_P.fingers - 1)) * xpitch, 0.5 * (_P.pwidth - _P.nwidth)))
    end
    --]]

    --[[
    -- connections
    inverter:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
        _P.fingers / 2 + 1, 2,
        2 * xpitch, _P.nwidth + _P.pwidth + _P.separation + _P.powerspace
    ):translate(0, 0.5 * (_P.pwidth - _P.nwidth)))
    --]]

    --[[
    -- output connection
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
    --]]

    -- power rails
    inverter:merge_into(geometry.rectangle(generics.metal(1),
        (_P.fingers + 2 * _P.dummies) * xpitch + _P.sdwidth, _P.powerwidth
    ):translate(0, -_P.separation / 2 - _P.nwidth - _P.powerwidth / 2 - _P.powerspace))
    inverter:merge_into(geometry.rectangle(generics.metal(1),
        (_P.fingers + 2 * _P.dummies) * xpitch + _P.sdwidth, _P.powerwidth
    ):translate(0, _P.separation / 2 + _P.pwidth + _P.powerwidth / 2 + _P.powerspace))

    ---[[
    -- connections
    for i = -1, 1, 2 do
        inverter:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
            _P.dummies + 1, 2, xpitch, _P.nwidth + _P.pwidth + _P.separation + _P.powerspace
        ):translate(i * (_P.fingers + _P.dummies) / 2 * xpitch, (_P.pwidth - _P.nwidth) / 2))
    end
    --]]

    return inverter
end
