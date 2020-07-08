local point = require "point"
local object = require "object"
local layout = require "layout"

return function()
    -- transistor settings
    local channeltype = "nmos"
    local fingers = 4
    local fwidth = 1
    local gatelength = 0.2
    local actext = 0.03
    local fspace = 0.14
    local sdwidth = 0.1
    local gtopext = 0.2
    local gbotext = 0.2
    local typext = 0.1
    local cliptop = false
    local clipbot = false

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
        origin, 
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
        origin, 
        actwidth, fwidth
    ))
    transistor:add_shape(layout.rectangle(
        (channeltype == "nmos") and "nimpl" or "pimpl",
        "drawing",
        origin,
        actwidth + 2 * typext,
        gateheight + typext * clipshift,
        {
            yoffset = gateoffset + 0.5 * typext * clipshift
        }
    ))

    -- well
    transistor:add_shape(layout.rectangle(
        "nwell", "drawing",
        origin,
        actwidth + 2 * typext, gateheight + typext,
        {
            yoffset = gateoffset
        }
    ))
    return transistor
end

--[[ skill code for the transistor
procedure(MSCLayoutDrawTransistor(cv @key 
        (typ "p") (oxidetype "0.9") (vthtyp "slvt") 
        (drawtopgate nil) (topgatestrwidth 0.12) (topgatestrext 1) (drawbotgate nil) (botgatestrwidth 0.12) (botgatestrext 1) (topgatecolor "grayColor") (botgatecolor "grayColor")
         (sdwidth 0.06)  (wellext 0.1)
        (scolor "mask1Color") (dcolor "mask2Color")
        (topgcut nil) (botgcut nil)
    )
    let(
        (
        )
        ; gate contacts
        let(
        	(shape)
	        when(drawtopgate
	            for(i 1 fingers
	                MSCLayoutCreateVia(pcCellView "PCCBM1" gatelength topgatestrwidth ?x (i - 0.5 * (fingers + 1)) * gatepitch ?y 0.5 * fwidth + gtopext - 0.5 * topgatestrwidth)
					shape = MSCLayoutCreateRectangle(pcCellView ?layer "M1" ?width gatelength ?height topgatestrwidth ?xoffset (i - 0.5 * (fingers + 1)) * gatepitch ?yoffset 0.5 * fwidth + gtopext - 0.5 * topgatestrwidth)
					MSCLayoutColorShapes(shape topgatecolor)	            
	            )
	            when(fingers > 1
		            shape = MSCLayoutCreateRectangle(pcCellView ?layer "M1" ?width (fingers - 1 + topgatestrext) * gatepitch ?height topgatestrwidth ?yoffset 0.5 * fwidth + gtopext - 0.5 * topgatestrwidth)
	            	MSCLayoutColorShapes(shape topgatecolor)
	            )
	        )
	        when(drawbotgate
	            for(i 1 fingers
	                MSCLayoutCreateVia(pcCellView "PCCBM1" gatelength botgatestrwidth ?x (i - 0.5 * (fingers + 1)) * gatepitch ?y 0.5 * fwidth - gbotext + 0.5 * botgatestrwidth)
					shape = MSCLayoutCreateRectangle(pcCellView ?layer "M1" ?width gatelength ?height botgatestrwidth ?xoffset (i - 0.5 * (fingers + 1)) * gatepitch ?yoffset 0.5 * fwidth - gbotext + 0.5 * botgatestrwidth)			
					MSCLayoutColorShapes(shape topgatecolor)
	            )
	            when(fingers > 1
		            shape = MSCLayoutCreateRectangle(pcCellView ?layer "M1" ?width (fingers - 1 + botgatestrext) * gatepitch ?height botgatestrwidth ?yoffset 0.5 * fwidth - gbotext + 0.5 * botgatestrwidth)
					MSCLayoutColorShapes(shape topgatecolor)	            
	            )
	        )
        )
        
        ; contacts and coloring
        for(i 1 fingers + 1
            MSCLayoutCreateVia(pcCellView "RXCAM1" sdwidth fwidth ?x (i - 0.5 * (fingers + 1) - 0.5) * gatepitch)
            let(
            	(shape)
            	shape = MSCLayoutCreateRectangle(pcCellView ?layer "M1" ?width sdwidth ?height fwidth ?xoffset (i - 0.5 * (fingers + 1) - 0.5) * gatepitch)
            	MSCLayoutColorShapes(shape if(evenp(i) dcolor scolor))
        	)
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
        
        
        ; gate cut
        letseq(
            (
                (cutext 0.5 * fspace)
                (cutheight 0.12)
                (cwidth fingers * gatelength + (fingers - 1) * fspace + 2 * cutext)
            )
            when(topgcut
                MSCLayoutCreateRectangle(pcCellView
                    ?layer "CT"
                    ?width cwidth
                    ?height cutheight
                    ?yoffset 0.5 * fwidth + gtopext
                )
            )
            when(botgcut
                MSCLayoutCreateRectangle(pcCellView
                    ?layer "CT"
                    ?width cwidth
                    ?height cutheight
                    ?yoffset - 0.5 * fwidth - gbotext
                )
            )
    	) ; letseq
    ) ; let
) ; MSCLayoutDrawTransistor
--]]
