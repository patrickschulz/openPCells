return function(args)
    pcell.setup(args)

    -- transistor settings
    local channeltype       = pcell.process_args("channeltype",     "nmos")
    local oxidetype         = pcell.process_args("oxidetype",       1)
    local vthtype           = pcell.process_args("vthtype",         1)
    local fingers           = pcell.process_args("fingers",         4)
    local fwidth            = pcell.process_args("fwidth",          1.0)
    local gatelength        = pcell.process_args("gatelength",      0.1)
    local actext            = pcell.process_args("actext",          0.03)
    local fspace            = pcell.process_args("fspace",          0.14)
    local sdwidth           = pcell.process_args("sdwidth",         0.1)
    local gtopext           = pcell.process_args("gtopext",         0.2)
    local gbotext           = pcell.process_args("gbotext",         0.2)
    local typext            = pcell.process_args("typext",          0.1)
    local cliptop           = pcell.process_args("cliptop",         false)
    local clipbot           = pcell.process_args("clipbot",         false)
    local sdwidth           = pcell.process_args("sdwidth",         0.06)
    local drawtopgate       = pcell.process_args("drawtopgate",     false)
    local drawbotgate       = pcell.process_args("drawbotgate",     false)
    local topgatestrwidth   = pcell.process_args("topgatestrwidth", 0.12)
    local topgatestrext     = pcell.process_args("topgatestrext",   1)
    local botgatestrwidth   = pcell.process_args("botgatestrwidth", 0.12)
    local botgatestrext     = pcell.process_args("botgatestrext",   1)
    local topgcut           = pcell.process_args("topgcut",         false)
    local botgcut           = pcell.process_args("botgcut",         false)

    pcell.check_args()

    -- derived settings
    local actwidth = fingers * gatelength + fingers * fspace + sdwidth + 2 * actext
    local gatepitch = gatelength + fspace
    local gateheight = fwidth + gtopext + gbotext
    local gateoffset = 0.5 * (gtopext - gbotext)
    local clipshift = (cliptop and 0 or 1) - (clipbot and 0 or 1)

    local transistor = object.create()

    -- gates
    transistor:merge_into(layout.multiple(
        layout.rectangle(generics.other("gate"), gatelength, gateheight),
        fingers, 1, gatepitch, 0
    ):translate(0, gateoffset))

    --[[
    -- oxide type
    transistor:merge_into(layout.rectangle(
        string.format("oxthick%d", oxidetype), 
        origin,
        fingers * gatelength + (fingers - 1) * fspace + 2 * actext, fwidth
    ))
    --]]

    -- active
    transistor:merge_into(layout.rectangle(
        generics.other("active"), 
        actwidth, fwidth
    ))
    transistor:merge_into(layout.rectangle(
        (channeltype == "nmos") and generics.other("nimpl") or generics.other("pimpl"), 
        actwidth + 2 * typext, gateheight + typext * clipshift
    ):translate(0, gateoffset + 0.5 * typext * clipshift))

    -- well
    transistor:merge_into(layout.rectangle(
        (channeltype == "nmos") and generics.other("pwell") or generics.other("nwell"), 
        actwidth + 2 * typext, gateheight + typext
    ):translate(0, gateoffset))

    -- drain/source contacts
    transistor:merge_into(layout.multiple(
        layout.rectangle(generics.contact("active"), sdwidth, fwidth),
        fingers + 1, 1,
        gatepitch, 0
    ))

    -- gate contacts
    if drawtopgate then
        transistor:merge_into(layout.multiple(
            layout.rectangle(generics.contact("gate"), gatelength, topgatestrwidth),
            fingers, 1, gatepitch, 0)
            :translate(0, 0.5 * fwidth + gtopext - 0.5 * topgatestrwidth)
        )
        if fingers > 1 then
            transistor:merge_into(layout.rectangle(
                generics.other("M1"), 
                (fingers - 1 + topgatestrext) * gatepitch, topgatestrwidth
            ):translate(0, 0.5 * fwidth + gtopext - 0.5 * topgatestrwidth))
        end
    end
    if drawbotgate then
        transistor:merge_into(layout.multiple(
            layout.rectangle(generics.contact("gate"), gatelength, botgatestrwidth),
            fingers, 1, gatepitch, 0)
            :translate(0, -0.5 * fwidth - gbotext + 0.5 * botgatestrwidth)
        )
        if fingers > 1 then
            transistor:merge_into(layout.rectangle(
                generics.other("M1"), 
                (fingers - 1 + botgatestrext) * gatepitch, botgatestrwidth
            ):translate(0, -0.5 * fwidth - gbotext + 0.5 * botgatestrwidth))
        end
    end

    -- gate cut
    local cutext = 0.5 * fspace
    local cutheight = 0.12
    local cwidth = fingers * gatelength + (fingers - 1) * fspace + 2 * cutext
    if topgcut then
        transistor:merge_into(layout.rectangle(
            generics.other("gatecut"), 
            cwidth, cutheight
        ):translate(0, 0.5 * fwidth + gtopext))
    end
    if botgcut then
        transistor:merge_into(layout.rectangle(
            generics.other("gatecut"), 
            cwidth, cutheight
        ):translate(0, -0.5 * fwidth - gbotext))
    end

    return transistor
end
