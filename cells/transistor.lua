function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                      "nmos" },
        { "oxidetype(Oxide Thickness Type)",                1 },
        { "vthtype(Threshold Voltage Type)",                1 },
        { "fingers(Number of Fingers)",                     4, "integer", "1-..." },
        { "fwidth(Finger Width)",                           1.0 },
        { "gatelength(Gate Length)",                        0.15 },
        { "fspace(Gate Spacing)",                           0.27 },
        { "actext(Active Extension)",                       0.03 },
        { "sdwidth(Source/Drain Metal Width)",              0.2 },
        { "sdconnwidth(Source/Drain Rails Metal Width)",    0.2 },
        { "sdconnspace(Source/Drain Rails Metal Space)",    0.2 },
        { "gtopext(Gate Top Extension)",                    0.0 },
        { "gbotext(Gate Bottom Extension)",                 0.0 },
        { "typext(Type Marker Extension)",                  0.1 },
        { "cliptop(Clip Top Marker Layers)",                false },
        { "clipbot(Clip Bottom Marker Layers)",             false },
        { "drawtopgate(Draw Top Gate Strap)",               false },
        { "topgatestrwidth(Top Gate Strap Width)",          0.12 },
        { "topgatestrext(Top Gate Strap Extension)",        1 },
        { "topgatestrspace(Top Gate Strap Space)",          0.2 },
        { "drawbotgate(Draw Bottom Gate Strap)",            false },
        { "botgatestrwidth(Bottom Gate Strap Width)",       0.12 },
        { "botgatestrext(Bottom Gate Strap Extension)",     1 },
        { "botgatestrspace(Bottom Gate Strap Space)",       0.2 },
        { "topgcut(Draw Top Gate Cut)",                     false },
        { "botgcut(Draw Bottom Gate Cut)",                  false },
        { "connectsource(Connect Source)",                  false },
        { "connectdrain(Connect Drain)",                    false }
    )
end

function layout()
    local P = pcell.get_params()

    local actwidth = P.fingers * (P.gatelength + P.fspace) + P.sdwidth + 2 * P.actext
    local gatepitch = P.gatelength + P.fspace
    local gateheight = P.fwidth + P.gtopext + P.gbotext
    --[[ FIXME
    local gateheight = P.fwidth + math.max(
        P.gtopext + P.gbotext, 
        enable(P.drawtopgate, P.topgatestrspace) + enable(P.drawbotgate, P.botgatestrspace) + P.topgatestrwidth + P.botgatestrwidth
    )
    --]]
    local gateoffset = 0.5 * (P.gtopext - P.gbotext)
    local clipshift = (P.cliptop and 0 or 1) - (P.clipbot and 0 or 1)

    local transistor = object.create()

    -- gates
    transistor:merge_into(geometry.multiple(
        geometry.rectangle(generics.other("gate"), P.gatelength, gateheight),
        P.fingers, 1, gatepitch, 0
    ):translate(0, gateoffset))

    -- oxide type
    transistor:merge_into(geometry.rectangle(
        generics.other(string.format("oxthick%d", P.oxidetype)),
        P.fingers * P.gatelength + (P.fingers - 1) * P.fspace + 2 * P.actext, P.fwidth
    ))
    
    -- threshold voltage
    transistor:merge_into(geometry.rectangle(
        generics.other(string.format("vthtype%d", P.vthtype)),
        P.fingers * P.gatelength + (P.fingers - 1) * P.fspace + 2 * P.actext, P.fwidth
    ))

    -- active
    transistor:merge_into(geometry.rectangle(
        generics.other("active"), 
        actwidth, P.fwidth
    ))
    transistor:merge_into(geometry.rectangle(
        (P.channeltype == "nmos") and generics.other("nimpl") or generics.other("pimpl"), 
        actwidth + 2 * P.typext, gateheight + P.typext * clipshift
    ):translate(0, gateoffset + 0.5 * P.typext * clipshift))

    -- well
    transistor:merge_into(geometry.rectangle(
        (P.channeltype == "nmos") and generics.other("pwell") or generics.other("nwell"), 
        actwidth + 2 * P.typext, gateheight + P.typext
    ):translate(0, gateoffset))

    -- drain/source contacts
    transistor:merge_into(geometry.multiple(
        geometry.rectangle(generics.contact("active"), P.sdwidth, P.fwidth),
        P.fingers + 1, 1,
        gatepitch, 0
    ))

    -- gate contacts
    if P.drawtopgate then
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), P.gatelength, P.topgatestrwidth),
            P.fingers, 1, gatepitch, 0)
            :translate(0, 0.5 * P.fwidth + P.topgatestrspace + 0.5 * P.topgatestrwidth)
        )
        if P.fingers > 1 then
            transistor:merge_into(geometry.rectangle(
                generics.metal(1), 
                (P.fingers - 1 + P.topgatestrext) * gatepitch, P.topgatestrwidth
            ):translate(0, 0.5 * P.fwidth + P.topgatestrspace + 0.5 * P.topgatestrwidth))
        end
    end
    if P.drawbotgate then
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), P.gatelength, P.botgatestrwidth),
            P.fingers, 1, gatepitch, 0)
            :translate(0, -0.5 * P.fwidth - P.gbotext + 0.5 * P.botgatestrwidth)
        )
        if P.fingers > 1 then
            transistor:merge_into(geometry.rectangle(
                generics.metal(1), 
                (P.fingers - 1 + P.botgatestrext) * gatepitch, P.botgatestrwidth
            ):translate(0, -0.5 * P.fwidth - P.gbotext - 0.5 * P.botgatestrwidth))
        end
    end

    -- gate cut
    local cutext = 0.5 * P.fspace
    local cutheight = 0.12
    local cwidth = P.fingers * P.gatelength + (P.fingers - 1) * P.fspace + 2 * cutext
    if P.topgcut then
        transistor:merge_into(geometry.rectangle(
            generics.other("gatecut"), 
            cwidth, cutheight
        ):translate(0, 0.5 * P.fwidth + P.gtopext))
    end
    if P.botgcut then
        transistor:merge_into(geometry.rectangle(
            generics.other("gatecut"), 
            cwidth, cutheight
        ):translate(0, -0.5 * P.fwidth - P.gbotext))
    end

    if P.connectsource then
        transistor:merge_into(geometry.rectangle(generics.metal(1),
            P.fingers * (P.gatelength + P.fspace) + P.sdwidth, P.sdconnwidth
        ):translate(0, -0.5 * P.fwidth - 0.5 * P.sdconnwidth - P.sdconnspace))
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), P.sdwidth, P.sdconnspace),
            math.floor(0.5 * P.fingers) + 1, 1, 2 * (P.gatelength + P.fspace), 0
        ):translate(0, -0.5 * (P.fwidth + P.sdconnspace)))
    end
    if P.connectdrain then
        transistor:merge_into(geometry.rectangle(generics.metal(1),
            (P.fingers - 2) * (P.gatelength + P.fspace) + P.sdwidth, P.sdconnwidth
        ):translate(0, 0.5 * P.fwidth + 0.5 * P.sdconnwidth + P.sdconnspace))
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), P.sdwidth, P.sdconnspace),
            math.floor(0.5 * P.fingers), 1, 2 * (P.gatelength + P.fspace), 0
        ):translate(0, 0.5 * (P.fwidth + P.sdconnspace)))
    end

    -- add anchors
    transistor:add_anchor("topgate", point.create(0,  0.5 * P.fwidth + P.gtopext - 0.5 * P.topgatestrwidth))
    transistor:add_anchor("botgate", point.create(0, -0.5 * P.fwidth - P.gbotext + 0.5 * P.botgatestrwidth))
    transistor:add_anchor("leftdrainsource",  point.create(-0.5 * P.fingers * (P.gatelength + P.fspace), 0))
    transistor:add_anchor("rightdrainsource", point.create( 0.5 * P.fingers * (P.gatelength + P.fspace), 0))

    return transistor
end
