function parameters()
    pcell.add_parameters(
        { "contype",      "p" },
        { "width",        5.0 },
        { "height",       5.0 },
        { "ringwidth",    0.2 },
        { "extension",    0.05 },
        { "fillwell",     true },
        { "drawdeepwell", false }
    )
end

function layout()
    local guardring = object.create()

    -- active, implant and SOI opening
    guardring:merge_into(geometry.ring(generics.other("active"), _P.width, _P.height, _P.ringwidth))
    guardring:merge_into(geometry.ring(generics.other(string.format("%simpl", _P.contype)), _P.width, _P.height, _P.ringwidth + _P.extension))
    guardring:merge_into(geometry.ring(generics.other("soiopen"), _P.width, _P.height, _P.ringwidth + _P.extension))

    -- well
    if _P.fillwell then
        guardring:merge_into(geometry.rectangle(generics.other(string.format("%swell", _P.contype)), _P.width + _P.ringwidth + _P.extension, _P.height + _P.ringwidth + _P.extension))
    else
        guardring:merge_into(geometry.ring(generics.other(string.format("%swell", _P.contype)), _P.width, _P.height, _P.ringwidth + _P.extension))
    end
    -- draw deep n/p-well
    if _P.drawdeepwell then
        guardring:merge_into(geometry.rectangle(generics.other(string.format("deep%swell", _P.contype)), _P.width + _P.ringwidth + _P.extension, _P.height + _P.ringwidth + _P.extension))
    end

    return guardring
end

--[[
pcDefinePCell( list(ddGetObj(lib) cell "layout") 
    (
        (position   string      "tblr")
        (topmetal   string      "M1")
        (m1color		string		"mask1Color")
        (m2color		string		"mask1Color")
        (contype    string      "n")
        (rxwidth    float       0.2)
        (rxlength   float       1.0)
        (rxheight   float       1.0)
        (caspace    float       0.14)
        (rxenc      float       0.03)
        (nwext      float       0.1)
        (nppext     float       0.095)
        (hybridext  float       0.028)
        (dnwoffset  float       0.15)
		(drawdnwell	boolean		nil)
		(dnwelltype	string		"S3")
    )
    let(
        (
            (caviadef techFindViaDefByName(techGetTechFile(pcCellView) "RXCAM1"))
            (canum fix((rxwidth + 0.14 - 2 * rxenc) / (0.14 + 0.04)))  
            (cacols fix((rxlength + rxwidth + caspace - 2 * rxenc)/ (caspace + 0.04)))  
            (carows fix((rxheight + rxwidth + caspace - 2 * rxenc)/ (caspace + 0.04)))
            (dpmetallist list(list("M1" m1color) list("M2" m2color)))
            (metallist list("M1" "M2" "C1" "C2" "C3" "C4" "C5"))
            shapes
        )
        
        
        ;draw metals with correct color
        foreach(layer member(topmetal reverse(metallist))
            shapes = MSCLayoutCreateRing(pcCellView
                ?layer layer
                ?width rxwidth 
                ?height rxheight 
                ?length rxlength
            )
            foreach(colorpair dpmetallist
            	when(eq(layer car(colorpair))
		            foreach(shape shapes 
		            	unless(cadr(colorpair) == "none"
			            	dbSetShapeColor(shape cadr(colorpair))
			            	dbSetShapeColorLocked(shape t)
		            	) ; unless
		            ) ; foreach
		        ) ; when
		    ) ; foreach
        )
		
        dbCreateVia(pcCellView caviadef 
            list(
                0
                -0.5 * rxheight
            )
            "R0" 
            list(list("cutWidth" 0.04) list("cutHeight" 0.04) 
                 list("cutSpacing" list(caspace 0.14)) 
                 list("cutRows" canum) list("cutColumns" cacols) 
                 list("layer1Enc" list(0 0 0 0))
                 list("layer2Enc" list(0 0 0 0))
            )
        )
        dbCreateVia(pcCellView caviadef 
            list(
                0
                0.5 * rxheight
            )
            "R0" 
            list(list("cutWidth" 0.04) list("cutHeight" 0.04) 
                 list("cutSpacing" list(caspace 0.14)) 
                 list("cutRows" canum) list("cutColumns" cacols) 
                 list("layer1Enc" list(0 0 0 0))
                 list("layer2Enc" list(0 0 0 0))
            )
        )
        dbCreateVia(pcCellView caviadef 
            list(
            	-0.5 * rxlength
                0
            )
            "R0" 
            list(list("cutWidth" 0.04) list("cutHeight" 0.04) 
                 list("cutSpacing" list(0.14 caspace)) 
                 list("cutRows" carows) list("cutColumns" canum) 
                 list("layer1Enc" list(0 0 0 0))
                 list("layer2Enc" list(0 0 0 0))
            )
        )
        dbCreateVia(pcCellView caviadef 
            list(
                0.5 * rxlength
                0
            )
            "R0" 
            list(list("cutWidth" 0.04) list("cutHeight" 0.04) 
                 list("cutSpacing" list(0.14 caspace)) 
                 list("cutRows" carows) list("cutColumns" canum) 
                 list("layer1Enc" list(0 0 0 0))
                 list("layer2Enc" list(0 0 0 0))
            )
        )
        
    ) ; let
) ; pcDefinePCell
--]]
