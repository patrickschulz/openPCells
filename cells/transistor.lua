function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",     "nmos" },
        { "oxidetype",       1 },
        { "vthtype",         1 },
        { "fingers",         4 },
        { "fwidth",          1.0 },
        { "gatelength",      0.15 },
        { "fspace",          0.27 },
        { "actext",          0.03 },
        { "sdwidth",         0.2 },
        { "gtopext",         0.2 },
        { "gbotext",         0.2 },
        { "typext",          0.1 },
        { "cliptop",         false },
        { "clipbot",         false },
        { "drawtopgate",     false },
        { "drawbotgate",     false },
        { "topgatestrwidth", 0.12 },
        { "topgatestrext",   1 },
        { "botgatestrwidth", 0.12 },
        { "botgatestrext",   1 },
        { "topgcut",         false },
        { "botgcut",         false }
    )
end

function layout()
    local P = pcell.get_params()

    local actwidth = P.fingers * (P.gatelength + P.fspace) + P.sdwidth + 2 * P.actext
    local gatepitch = P.gatelength + P.fspace
    local gateheight = P.fwidth + P.gtopext + P.gbotext
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
            :translate(0, 0.5 * P.fwidth + P.gtopext - 0.5 * P.topgatestrwidth)
        )
        if P.fingers > 1 then
            transistor:merge_into(geometry.rectangle(
                generics.metal(1), 
                (P.fingers - 1 + P.topgatestrext) * gatepitch, P.topgatestrwidth
            ):translate(0, 0.5 * P.fwidth + P.gtopext - 0.5 * P.topgatestrwidth))
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
            ):translate(0, -0.5 * P.fwidth - P.gbotext + 0.5 * P.botgatestrwidth))
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

    -- add anchors
    transistor:add_anchor("topgate", point.create(0,  0.5 * P.fwidth + P.gtopext - 0.5 * P.topgatestrwidth))
    transistor:add_anchor("botgate", point.create(0, -0.5 * P.fwidth - P.gbotext + 0.5 * P.botgatestrwidth))
    transistor:add_anchor("leftdrainsource",  point.create(-0.5 * P.fingers * (P.gatelength + P.fspace), 0))
    transistor:add_anchor("rightdrainsource", point.create( 0.5 * P.fingers * (P.gatelength + P.fspace), 0))

    return transistor
end
