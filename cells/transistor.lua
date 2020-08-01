local point = require "point"
local object = require "object"
local layout = require "layout"
local pcell = require "pcell"

return function(args)
    pcell.clear()

    -- transistor settings
    local channeltype       = pcell.process_args(args, "channeltype",       "string",   "nmos")
    local oxidetype         = pcell.process_args(args, "oxidetype",         "number",   1)
    local vthtype           = pcell.process_args(args, "vthtype",           "number",   1)
    local fingers           = pcell.process_args(args, "fingers",           "number",   4)
    local fwidth            = pcell.process_args(args, "fwidth",            "number",   1.0)
    local gatelength        = pcell.process_args(args, "gatelength",        "number",   0.1)
    local actext            = pcell.process_args(args, "actext",            "number",   0.03)
    local fspace            = pcell.process_args(args, "fspace",            "number",   0.14)
    local sdwidth           = pcell.process_args(args, "sdwidth",           "number",   0.1)
    local gtopext           = pcell.process_args(args, "gtopext",           "number",   0.2)
    local gbotext           = pcell.process_args(args, "gbotext",           "number",   0.2)
    local typext            = pcell.process_args(args, "typext",            "number",   0.1)
    local cliptop           = pcell.process_args(args, "cliptop",           "number",   false)
    local clipbot           = pcell.process_args(args, "clipbot",           "number",   false)
    local sdwidth           = pcell.process_args(args, "sdwidth",           "number",   0.06)
    local drawtopgate       = pcell.process_args(args, "drawtopgate",       "boolean",  false)
    local drawbotgate       = pcell.process_args(args, "drawbotgate",       "boolean",  false)
    local topgatestrwidth   = pcell.process_args(args, "topgatestrwidth",   "number",   0.12)
    local topgatestrext     = pcell.process_args(args, "topgatestrext",     "number",   1)
    local botgatestrwidth   = pcell.process_args(args, "botgatestrwidth",   "number",   0.12)
    local botgatestrext     = pcell.process_args(args, "botgatestrext",     "number",   1)
    local topgcut           = pcell.process_args(args, "topgcut",           "boolean",  false)
    local botgcut           = pcell.process_args(args, "botgcut",           "boolean",  false)

    pcell.check_args(args)

    -- derived settings
    local actwidth = fingers * gatelength + fingers * fspace + sdwidth + 2 * actext
    local gatepitch = gatelength + fspace
    local gateheight = fwidth + gtopext + gbotext
    local gateoffset = 0.5 * (gtopext - gbotext)
    local clipshift = (cliptop and 0 or 1) - (clipbot and 0 or 1)

    local transistor = object.create()

    -- gates
    transistor:merge_into(layout.multiple(
        layout.rectangle("gate", "drawing", gatelength, gateheight),
        fingers, 1, gatepitch, 0
    ):translate(0, gateoffset))

    --[[
    -- oxide type
    transistor:merge_into(layout.rectangle(
        string.format("oxthick%d", oxidetype), "drawing",
        origin,
        fingers * gatelength + (fingers - 1) * fspace + 2 * actext, fwidth
    ))
    --]]

    -- active
    transistor:merge_into(layout.rectangle(
        "active", "drawing", 
        actwidth, fwidth
    ))
    transistor:merge_into(layout.rectangle(
        (channeltype == "nmos") and "nimpl" or "pimpl", "drawing",
        actwidth + 2 * typext, gateheight + typext * clipshift
    ):translate(0, gateoffset + 0.5 * typext * clipshift))

    -- well
    transistor:merge_into(layout.rectangle(
        (channeltype == "nmos") and "pwell" or "nwell", "drawing",
        actwidth + 2 * typext, gateheight + typext
    ):translate(0, gateoffset))

    -- drain/source contacts
    transistor:merge_into(layout.multiple(
        layout.via("active->M1", sdwidth, fwidth),
        fingers + 1, 1,
        gatepitch, 0
    ))

    -- gate contacts
    if drawtopgate then
        transistor:merge_into(layout.multiple(
            layout.via("gate->M1", gatelength, topgatestrwidth),
            fingers, 1, gatepitch, 0)
            :translate(0, 0.5 * fwidth + gtopext - 0.5 * topgatestrwidth)
        )
        if fingers > 1 then
            transistor:merge_into(layout.rectangle(
                "M1", "drawing",
                (fingers - 1 + topgatestrext) * gatepitch, topgatestrwidth
            ):translate(0, 0.5 * fwidth + gtopext - 0.5 * topgatestrwidth))
        end
    end
    if drawbotgate then
        transistor:merge_into(layout.multiple(
            layout.via("gate->M1", gatelength, botgatestrwidth),
            fingers, 1, gatepitch, 0)
            :translate(0, 0.5 * fwidth + gbotext - 0.5 * botgatestrwidth)
        )
        if fingers > 1 then
            transistor:merge_into(layout.rectangle(
                "M1", "drawing",
                (fingers - 1 + botgatestrext) * gatepitch, botgatestrwidth
            ):translate(0, 0.5 * fwidth + gbotext - 0.5 * botgatestrwidth))
        end
    end

    -- gate cut
    local cutext = 0.5 * fspace
    local cutheight = 0.12
    local cwidth = fingers * gatelength + (fingers - 1) * fspace + 2 * cutext
    if topgcut then
        transistor:merge_into(layout.rectangle(
            "gatecut", "drawing",
            cwidth, cutheight
        ):translate(0, 0.5 * fwidth + gtopext))
    end
    if botgcut then
        transistor:merge_into(layout.rectangle(
            "gatecut", "drawing",
            cwidth, cutheight
        ):translate(0, -0.5 * fwidth - gbotext))
    end

    return transistor
end
