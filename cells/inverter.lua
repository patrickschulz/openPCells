function parameters()
    pcell.add_parameters(
        { "oxidetype",  "0.9" },
        { "pvthtype",   "slvt" },
        { "nvthtype",   "slvt" },
        { "pwidth",     1 },
        { "nwidth",     1 },
        { "glength",    0.2 },
        { "gext",       0.1 },
        { "sdwidth",    0.2 },
        { "gspace",     0.27 },
        { "gstwidth",   0.1 },
        { "fingers",    4 },
        { "dummies",    2 },
        { "separation", 0.4 },
        { "ttypeext",   0.1 },
        { "powerwidth", 0.2 },
        { "powerspace", 0.5 },
        { "conngate",   1 },
        { "connmetal",  3 },
        { "connwidth",  0.1 },
        { "connoffset", 1 }
    )
end

function layout()
    local P = pcell.get_params()

    local xpitch = P.gspace + P.glength
    local dummycontheight = 0.08

    local inverter = object.create()

    -- pfet
    local pmos = celllib.create_layout("transistor",
        {
            channeltype = "pmos",
            fingers = P.fingers, gatelength = P.glength, fwidth = P.pwidth, fspace = P.gspace,
            sdwidth = P.sdwidth,
            gtopext = P.powerspace + dummycontheight, gbotext = 0.5 * P.separation,
            drawbotgate = true,
            clipbot = true
        }
    ):move_anchor("botgate")
    inverter:merge_into(pmos)

    -- nfet
    local nmos = celllib.create_layout("transistor",
        {
            channeltype = "nmos",
            fingers = P.fingers, gatelength = P.glength, fwidth = P.pwidth, fspace = P.gspace,
            sdwidth = P.sdwidth,
            gbotext = P.powerspace + dummycontheight, gtopext = 0.5 * P.separation,
            drawtopgate = true,
            cliptop = true
        }
    ):move_anchor("topgate")
    inverter:merge_into(nmos)

    -- dummies
    local pmosdummy = celllib.create_layout("transistor",
        {
            channeltype = "pmos",
            fingers = P.dummies, gatelength = P.glength, fwidth = P.pwidth, fspace = P.gspace,
            sdwidth = P.sdwidth,
            gtopext = P.powerspace + dummycontheight, gbotext = 0.5 * P.separation,
            clipbot = true, botgcut = true
        }
    )
    inverter:merge_into(pmosdummy:move_anchor("leftdrainsource", pmos:get_anchor("rightdrainsource")))
    inverter:merge_into(pmosdummy:move_anchor("rightdrainsource", pmos:get_anchor("leftdrainsource")))
    local nmosdummy = celllib.create_layout("transistor",
        {
            channeltype = "nmos",
            fingers = P.dummies, gatelength = P.glength, fwidth = P.pwidth, fspace = P.gspace,
            sdwidth = P.sdwidth,
            gbotext = P.powerspace + dummycontheight, gtopext = 0.5 * P.separation,
            cliptop = true, topgcut = true
        }
    )
    inverter:merge_into(nmosdummy:move_anchor("leftdrainsource", nmos:get_anchor("rightdrainsource")))
    inverter:merge_into(nmosdummy:move_anchor("rightdrainsource", nmos:get_anchor("leftdrainsource")))

    --[[
    -- dummy gate contacts
    for i = 1, P.dummies do
        inverter:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), P.glength, dummycontheight),
            1, 2, 0, P.separation + P.pwidth + P.nwidth + 2 * P.powerspace + dummycontheight
        ):translate((i + 0.5 * (P.fingers - 1)) * xpitch, 0.5 * (P.pwidth - P.nwidth)))
        inverter:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), P.glength, dummycontheight),
            1, 2, 0, P.separation + P.pwidth + P.nwidth + 2 * P.powerspace + dummycontheight
        ):translate(-(i + 0.5 * (P.fingers - 1)) * xpitch, 0.5 * (P.pwidth - P.nwidth)))
    end
    --]]

    --[[
    -- connections
    inverter:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), P.sdwidth, P.powerspace),
        P.fingers / 2 + 1, 2,
        2 * xpitch, P.nwidth + P.pwidth + P.separation + P.powerspace
    ):translate(0, 0.5 * (P.pwidth - P.nwidth)))
    --]]

    --[[
    -- output connection
    inverter:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(P.connmetal), (P.fingers - 1 + P.connoffset) * xpitch, P.connwidth),
        1, 2, 0, 0.5 * (P.nwidth + P.pwidth) + P.separation
    ):translate(0.5 * (1 + P.connoffset) * xpitch, 0.25 * (P.pwidth - P.nwidth)))
    inverter:merge_into(geometry.rectangle(
        generics.metal(P.connmetal), 
        P.connwidth, 0.5 * (P.nwidth + P.pwidth) + P.separation + P.connwidth
    ):translate((0.5 * P.fingers + P.connoffset) * xpitch, 0.25 * (P.pwidth - P.nwidth)))
    for i = 1, math.floor(P.fingers / 2) do
        inverter:merge_into(geometry.rectangle(
            generics.via(1, P.connmetal), 
            P.sdwidth, P.pwidth
        ):translate((i - 0.25 * P.fingers - 0.5) * 2 * xpitch, 0.5 * (P.pwidth + P.separation)))
        inverter:merge_into(geometry.rectangle(
            generics.via(1, P.connmetal), 
            P.sdwidth, P.nwidth
        ):translate((i - 0.25 * P.fingers - 0.5) * 2 * xpitch, -0.5 * (P.pwidth + P.separation)))
    end
    --]]

    -- power rails
    inverter:merge_into(geometry.rectangle(generics.metal(1),
        (P.fingers + 2 * P.dummies) * xpitch + P.sdwidth, P.powerwidth
    ):translate(0, -0.5 * P.separation - P.nwidth - 0.5 * P.powerwidth - P.powerspace))
    inverter:merge_into(geometry.rectangle(generics.metal(1),
        (P.fingers + 2 * P.dummies) * xpitch + P.sdwidth, P.powerwidth
    ):translate(0, 0.5 * P.separation + P.pwidth + 0.5 * P.powerwidth + P.powerspace))

    ---[[
    -- connections
    for i = -1, 1, 2 do
        inverter:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), P.sdwidth, P.powerspace),
            P.dummies + 1, 2, xpitch, P.nwidth + P.pwidth + P.separation + P.powerspace
        ):translate(i * 0.5 * (P.fingers + P.dummies) * xpitch, 0.5 * (P.pwidth - P.nwidth)))
    end
    --]]

    return inverter
end
