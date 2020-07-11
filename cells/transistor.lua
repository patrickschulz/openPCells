local point = require "point"
local object = require "object"
local layout = require "layout"

return function(args)
    -- transistor settings
    local channeltype       = args.channeltype      or "nmos"
    local fingers           = args.fingers          or 4
    local fwidth            = args.fwidth           or 1.0
    local gatelength        = args.gatelength       or 0.1
    local actext            = args.actext           or 0.03
    local fspace            = args.fspace           or 0.14
    local sdwidth           = args.sdwidth          or 0.1
    local gtopext           = args.gtopext          or 0.2
    local gbotext           = args.gbotext          or 0.2
    local typext            = args.typext           or 0.1
    local cliptop           = args.cliptop          or false
    local clipbot           = args.clipbot          or false
    local sdwidth           = args.sdwidth          or 0.06
    local drawtopgate       = args.drawtopgate      or false
    local drawbotgate       = args.drawbotgate      or false
    local topgatestrwidth   = args.topgatestrwidth  or 0.12
    local topgatestrext     = args.topgatestrext    or 1
    local botgatestrwidth   = args.botgatestrwidth  or 0.12
    local botgatestrext     = args.botgatestrext    or 1
    local topgcut           = args.topgcut          or false
    local botgcut           = args.botgcut          or false

    -- derived settings
    local actwidth = fingers * gatelength + fingers * fspace + sdwidth + 2 * actext
    local gatepitch = gatelength + fspace
    local gateheight = fwidth + gtopext + gbotext
    local gateoffset = 0.5 * (gtopext - gbotext)
    local clipshift = (cliptop and 0 or 1) - (clipbot and 0 or 1)

    local transistor = object.create()

    local origin = point.create(0, 0)

    -- gates
    transistor:add_shape(layout.rectangle(
        "gate", "drawing", 
        gatelength, gateheight, 
        { 
            xrep = fingers, 
            xpitch = gatepitch,
            yoffset = gateoffset
        }
    ))

    -- active
    transistor:add_shape(layout.rectangle(
        "active", "drawing", 
        actwidth, fwidth
    ))
    transistor:add_shape(layout.rectangle(
        (channeltype == "nmos") and "nimpl" or "pimpl",
        "drawing",
        actwidth + 2 * typext,
        gateheight + typext * clipshift,
        {
            yoffset = gateoffset + 0.5 * typext * clipshift
        }
    ))

    -- well
    transistor:add_shape(layout.rectangle(
        "nwell", "drawing",
        actwidth + 2 * typext, gateheight + typext,
        {
            yoffset = gateoffset
        }
    ))

    -- drain/source contacts
    local contacts = layout.via(
        "active->M1", 
        sdwidth, fwidth, 
        { 
            xrep = fingers + 1,
            xpitch = gatepitch
        }
    )
    for _, s in ipairs(contacts) do
        transistor:add_shape(s)
    end

    -- gate contacts
    if drawtopgate then
        local contacts = layout.via(
            "gate->M1", 
            gatelength, topgatestrwidth, 
            { 
                xrep = fingers,
                xpitch = gatepitch,
                yoffset = 0.5 * fwidth + gtopext - 0.5 * topgatestrwidth
            }
        )
        for _, s in ipairs(contacts) do
            transistor:add_shape(s)
        end
        if fingers > 1 then
            transistor:add_shape(layout.rectangle(
                "M1", "drawing",
                (fingers - 1 + topgatestrext) * gatepitch, topgatestrwidth,
                {
                    yoffset = 0.5 * fwidth + gtopext - 0.5 * topgatestrwidth
                }
            ))
        end
    end
    if drawbotgate then
        local contacts = layout.via(
            "gate->M1", 
            gatelength, botgatestrwidth, 
            { 
                xrep = fingers,
                xpitch = gatepitch,
                yoffset = 0.5 * fwidth + gbotext - 0.5 * botgatestrwidth
            }
        )
        for _, s in ipairs(contacts) do
            transistor:add_shape(s)
        end
        if fingers > 1 then
            transistor:add_shape(layout.rectangle(
                "M1", "drawing",
                (fingers - 1 + botgatestrext) * gatepitch, botgatestrwidth,
                {
                    yoffset = 0.5 * fwidth + gbotext - 0.5 * botgatestrwidth
                }
            ))
        end
    end

    -- gate cut
    local cutext = 0.5 * fspace
    local cutheight = 0.12
    local cwidth = fingers * gatelength + (fingers - 1) * fspace + 2 * cutext
    if topgcut then
        transistor:add_shape(layout.rectangle(
            "gatecut", "drawing",
            cwidth, cutheight,
            {
                yoffset = 0.5 * fwidth + gtopext
            }
        ))
    end
    if botgcut then
        transistor:add_shape(layout.rectangle(
            "gatecut", "drawing",
            cwidth, cutheight,
            {
                yoffset = -0.5 * fwidth - gbotext
            }
        ))
    end

    return transistor
end

--[[ skill code for the transistor
procedure(MSCLayoutDrawTransistor(cv @key 
        (typ "p") (oxidetype "0.9") (vthtyp "slvt") 
    )
    let(
        (
        )
        ; oxide type
        when(oxidetype == "1.8"
            MSCLayoutCreateRectangle(pcCellView
                ?layer "EG"
                ?width fingers * gatelength + (fingers - 1) * fspace + 2 * actext
                ?height fwidth
            )
        )
        
        ; threshold voltage type
        if(oxidetype == "0.9"
            then
                MSCLayoutCreateRectangle(pcCellView
                    ?layer upperCase(strcat(vthtyp typ))
                    ?width actwidth + 2 * typext
                    ?height gateheight + typext * (if(clipbot 0 1) + if(cliptop 0 1))
                    ?yoffset gateoffset + 0.5 * typext * (if(cliptop 0 1) - if(clipbot 0 1))
                )
            else
                MSCLayoutCreateRectangle(pcCellView
                    ?layer upperCase(strcat("EG" vthtyp typ))
                    ?width actwidth + 2 * typext
                    ?height gateheight + typext * (if(clipbot 0 1) + if(cliptop 0 1))
                    ?yoffset gateoffset + 0.5 * typext * (if(cliptop 0 1) - if(clipbot 0 1))
                )
                MSCLayoutCreateRectangle(pcCellView
                    ?layer "EG"
                    ?width actwidth + 2 * typext
                    ?height gateheight + typext * (if(clipbot 0 1) + if(cliptop 0 1))
                    ?yoffset gateoffset + 0.5 * typext * (if(cliptop 0 1) - if(clipbot 0 1))
                )
        ) ; if
    ) ; let
) ; MSCLayoutDrawTransistor
--]]
