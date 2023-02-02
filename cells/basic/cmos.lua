function parameters()
    pcell.add_parameters(
        { "oxidetype(Oxide Type)",                             1 },
        { "gatemarker(Gate Marker Index)",                     1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",            1 },
        { "nvthtype(NMOS Threshold Voltage Type)",             1 },
        { "pmosflippedwell(PMOS Flipped Well) ",            false },
        { "nmosflippedwell(NMOS Flipped Well)",             false },
        { "pwidth(PMOS Finger Width)",                         technology.get_dimension("Minimum Gate Width"), posvals = even() },
        { "nwidth(NMOS Finger Width)",                         technology.get_dimension("Minimum Gate Width"), posvals = even() },
        { "separation(Separation Between Active Regions)",     technology.get_dimension("Minimum Active Space"), posvals = even() },
        { "gatelength(Gate Length)",                           technology.get_dimension("Minimum Gate Length"), argtype = "integer", posvals = even() },
        { "gatespace(Gate Spacing)",                           technology.get_dimension("Minimum Gate XSpace"), argtype = "integer", posvals = even() },
        { "sdwidth(Source/Drain Metal Width)",                 technology.get_dimension("Minimum M1 Width"), posvals = even() },
        { "gstwidth(Gate Strap Metal Width)",                  technology.get_dimension("Minimum M1 Width") },
        { "gstspace(Gate Strap Metal Space)",                  technology.get_dimension("Minimum M1 Space") },
        { "gatecontactsplitshift(Gate Contact Split Shift)",   technology.get_dimension("Minimum M1 Width") + technology.get_dimension("Minimum M1 Space") },
        { "powerwidth(Power Rail Metal Width)",                technology.get_dimension("Minimum M1 Width") },
        { "npowerspace(NMOS Power Rail Space)",                technology.get_dimension("Minimum M1 Space"), posvals = positive() },
        { "ppowerspace(PMOS Power Rail Space)",                technology.get_dimension("Minimum M1 Space"), posvals = positive() },
        { "gateext(Gate Extension)",                           0 },
        { "psdheight(PMOS Source/Drain Contact Height)",       0 },
        { "nsdheight(NMOS Source/Drain Contact Height)",       0 },
        { "psdpowerheight(PMOS Source/Drain Contact Height)",  0 },
        { "nsdpowerheight(NMOS Source/Drain Contact Height)",  0 },
        { "cutheight",                                         technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace"), posvals = even() },
        { "compact(Compact Layout)",                           true },
        { "connectoutput",                                     true },
        { "drawtransistors", true },
        { "drawactive", true },
        { "drawrails", true },
        { "drawgatecontacts", true },
        { "outergstwidth(Outer Gate Strap Metal Width)",  technology.get_dimension("Minimum M1 Width") },
        { "outergstspace(Outer Gate Strap Metal Space)",  technology.get_dimension("Minimum M1 Space") },
        { "gatecontactpos", { "center" }, argtype = "strtable" },
        { "gatenames", {}, argtype = "strtable" },
        { "shiftgatecontacts", 0 },
        { "pcontactpos", {}, argtype = "strtable" },
        { "ncontactpos", {}, argtype = "strtable" },
        { "shiftpcontactsinner", 0 },
        { "shiftpcontactsouter", 0 },
        { "shiftncontactsinner", 0 },
        { "shiftncontactsouter", 0 },
        { "drawdummygatecontacts", true },
        { "drawdummyactivecontacts", true },
        { "drawgcut", false },
        { "drawgcuteverywhere", false },
        { "dummycontheight(Dummy Gate Contact Height)",        technology.get_dimension("Minimum M1 Width") },
        { "dummycontshift(Dummy Gate Shift)",                  0 },
        { "drawnmoswelltap(Draw nMOS Well Tap)", false },
        { "nmoswelltapspace(nMOS Well Tap Space)", technology.get_dimension("Minimum M1 Space") },
        { "nmoswelltapwidth(nMOS Well Tap Width)", technology.get_dimension("Minimum M1 Width") },
        { "drawpmoswelltap(Draw pMOS Well Tap)", false },
        { "pmoswelltapspace(pMOS Well Tap Space)", technology.get_dimension("Minimum M1 Space") },
        { "pmoswelltapwidth(pMOS Well Tap Width)", technology.get_dimension("Minimum M1 Width") },
        { "welltapextendleft", 0 },
        { "welltapextendright", 0 },
        { "drawactivedummy", false },
        { "activedummywidth", 0 },
        { "activedummysep", 0 },
        { "drawleftstopgate", false },
        { "drawrightstopgate", false },
        { "leftpolylines", {} },
        { "rightpolylines", {} }
    )
end

function layout(cmos, _P)
    local gatepitch = _P.gatespace + _P.gatelength
    local fingers = #_P.gatecontactpos

    -- check if outer gates are drawn
    local outergatepresent = false
    if _P.drawgatecontacts then
        for i = 1, fingers do
            if _P.gatecontactpos[i] == "outer" then
                outergatepresent = true
            end
        end
    end
    local outergateshift = outergatepresent and _P.outergstspace + _P.gstwidth or 0

    -- check if gate names are valid
    if (#_P.gatenames > 0) and (#_P.gatenames ~= #_P.gatecontactpos) then
        moderror(string.format("basic/cmos: number of entries in 'gatenames' must match 'gatecontactpos' (got %d, must be %d)", #_P.gatenames, #_P.gatecontactpos))
    end

    local leftndrainarea, rightndrainarea
    local leftpdrainarea, rightpdrainarea
    local firstgate
    if _P.drawtransistors then
        -- common transistor options
        pcell.push_overwrites("basic/mosfet", {
            gatelength = _P.gatelength,
            gatespace = _P.gatespace,
            sdwidth = _P.sdwidth,
            oxidetype = _P.oxidetype,
            gatemarker = _P.gatemarker,
            drawsourcedrain = "none",
            drawactive = _P.drawactive,
            topgcutwidth = _P.cutheight,
            botgcutwidth = _P.cutheight,
        })
        local n_ext, p_ext
        if aux.any_of("dummy", _P.gatecontactpos) then
            n_ext = math.max(_P.npowerspace + outergateshift + _P.gateext + math.max(_P.cutheight / 2, _P.dummycontheight))
            p_ext = math.max(_P.ppowerspace + outergateshift + _P.gateext + math.max(_P.cutheight / 2, _P.dummycontheight))
        else
            n_ext = math.max(outergateshift, math.max(_P.gateext, _P.cutheight / 2, _P.dummycontheight / 2))
            p_ext = math.max(outergateshift, math.max(_P.gateext, _P.cutheight / 2, _P.dummycontheight / 2))
        end

        -- pmos
        local popt = {
            channeltype = "pmos",
            vthtype = _P.pvthtype,
            flippedwell = _P.pmosflippedwell,
            fwidth = _P.pwidth,
            gbotext = _P.separation / 2,
            gtopext = p_ext,
            topgcutspace = -_P.powerwidth / 2,
            clipbot = true,
            drawtopactivedummy = _P.drawactivedummy,
            topactivedummywidth = _P.activedummywidth,
            topactivedummysep = _P.activedummysep,
            extendwelltop = _P.ppowerspace,
        }
        local nopt = {
            channeltype = "nmos",
            vthtype = _P.nvthtype,
            flippedwell = _P.nmosflippedwell,
            fwidth = _P.nwidth,
            gtopext = _P.separation / 2,
            gbotext = n_ext,
            botgcutspace = _P.powerwidth / 2,
            cliptop = true,
            drawbotgcut = false,
            drawbotactivedummy = _P.drawactivedummy,
            botactivedummywidth = _P.activedummywidth,
            botactivedummysep = _P.activedummysep,
            extendwellbot = _P.npowerspace,
        }
        -- main
        for i = 1, fingers do
            if i == 1 then
                nopt.leftpolylines = _P.leftpolylines
                popt.leftpolylines = _P.leftpolylines
                if _P.drawleftstopgate then
                    nopt.drawleftstopgate = true
                    nopt.drawstopgatetopgcut = true
                    nopt.drawstopgatebotgcut = false
                    popt.drawleftstopgate = true
                    popt.drawstopgatetopgcut = false
                    popt.drawstopgatebotgcut = true
                end
            end
            if i == fingers then
                nopt.rightpolylines = _P.rightpolylines
                popt.rightpolylines = _P.rightpolylines
                if _P.drawrightstopgate then
                    nopt.drawrightstopgate = true
                    nopt.drawstopgatetopgcut = true
                    nopt.drawstopgatebotgcut = false
                    popt.drawrightstopgate = true
                    popt.drawstopgatetopgcut = false
                    popt.drawstopgatebotgcut = true
                end
            end
            local shift = (i - 1) * gatepitch
            local nfet = pcell.create_layout("basic/mosfet", "nfet", nopt)
            nfet:translate(shift, 0)
            cmos:merge_into(nfet)
            local pfet = pcell.create_layout("basic/mosfet", "pfet", popt)
            pfet:abut_area_anchor_top(
                "gate1",
                nfet,
                "gate1"
            )
            pfet:translate(shift, 0)
            cmos:merge_into(pfet)
            -- save anchors for later use
            if i == 1 then
                leftndrainarea = nfet:get_area_anchor("sourcedrainleft")
                leftpdrainarea = pfet:get_area_anchor("sourcedrainleft")
                firstgatearea = nfet:get_area_anchor("gate1")
            end
            if i == fingers then
                rightndrainarea = nfet:get_area_anchor("sourcedrainright")
                rightpdrainarea = pfet:get_area_anchor("sourcedrainright")
            end
        end
        nopt.drawtopgcut = true
        popt.drawbotgcut = true
        -- pop general transistor settings
        pcell.pop_overwrites("basic/mosfet")
    end

    -- power rails
    if _P.drawrails then
        cmos:add_area_anchor_bltr(
            "PRp",
            leftpdrainarea.tl:copy():translate(0, _P.ppowerspace),
            rightpdrainarea.tr:copy():translate(0, _P.ppowerspace + _P.powerwidth)
        )
        cmos:add_area_anchor_bltr(
            "PRn",
            leftndrainarea.bl:copy():translate(0, -_P.npowerspace - _P.powerwidth),
            rightndrainarea.br:copy():translate(0, -_P.npowerspace)
        )
        geometry.rectanglebltr(cmos,
            generics.metal(1), 
            cmos:get_area_anchor("PRn").bl,
            cmos:get_area_anchor("PRn").tr
        )
        geometry.rectanglebltr(cmos,
            generics.metal(1), 
            cmos:get_area_anchor("PRp").bl,
            cmos:get_area_anchor("PRp").tr
        )
    end

    -- well taps (can't use the mosfet pcell well taps, as only single fingers are instantiated)
    -- FIXME: this does not fit well with different gates
    local welltapwidth = fingers * gatepitch + _P.welltapextendleft + _P.welltapextendright
    if _P.drawpmoswelltap then
        cmos:merge_into(pcell.create_layout("auxiliary/welltap", "pmoswelltap", {
            contype = _P.pmosflippedwell and "p" or "n",
            width = welltapwidth,
            height = _P.pmoswelltapwidth,
            xcontinuous = true
        }):translate(gatepitch / 2 + (_P.welltapextendright - _P.welltapextendleft) / 2 + welltapwidth / 2 - gatepitch, _P.separation / 2 + _P.pwidth + _P.ppowerspace + _P.powerwidth + _P.pmoswelltapspace + _P.pmoswelltapwidth / 2))
    end
    if _P.drawnmoswelltap then
        cmos:merge_into(pcell.create_layout("auxiliary/welltap", "nmoswelltap", {
            contype = _P.nmosflippedwell and "n" or "p",
            width = welltapwidth,
            height = _P.nmoswelltapwidth,
            xcontinuous = true
        }):translate(gatepitch / 2 + (_P.welltapextendright - _P.welltapextendleft) / 2 + welltapwidth / 2 - gatepitch, -_P.separation / 2 - _P.nwidth - _P.npowerspace - _P.powerwidth - _P.nmoswelltapspace - _P.nmoswelltapwidth / 2))
    end

    -- draw gate contacts
    if _P.drawgatecontacts then
        for i = 1, fingers do
            local x = firstgatearea.bl:getx() + (i - 1) * gatepitch
            local y = firstgatearea.tl:gety() + _P.shiftgatecontacts
            local yshift = 0
            local yheight = _P.gstwidth
            local yrep = 1
            local ypitch = 0
            local ignore = false
            if _P.gatecontactpos[i] == "center" then -- do nothing
            elseif _P.gatecontactpos[i] == "upper" then
                yshift = _P.gatecontactsplitshift / 2
            elseif _P.gatecontactpos[i] == "lower" then
                yshift = -_P.gatecontactsplitshift / 2
            elseif _P.gatecontactpos[i] == "split" then
                yrep = 2
                ypitch = _P.gatecontactsplitshift
                cmos:add_area_anchor_bltr(string.format("Gupper%d", i), 
                    point.create(x, y + _P.gatecontactsplitshift / 2 - _P.gstwidth / 2),
                    point.create(x + _P.gatelength, y + _P.gatecontactsplitshift / 2 + _P.gstwidth / 2)
                )
                cmos:add_area_anchor_bltr(string.format("Glower%d", i), 
                    point.create(x, y - _P.gatecontactsplitshift / 2 - _P.gstwidth / 2),
                    point.create(x + _P.gatelength, y - _P.gatecontactsplitshift / 2 + _P.gstwidth / 2)
                )
                geometry.rectanglebltr(cmos, generics.other("gatecut"), 
                    point.create(x, -_P.cutheight / 2),
                    point.create(x + gatepitch, _P.cutheight / 2)
                )
            elseif _P.gatecontactpos[i] == "dummy" then
                y = y - _P.shiftgatecontacts
                yshift = (_P.pwidth - _P.nwidth) / 2 + (_P.ppowerspace - _P.npowerspace) / 2
                yheight = _P.dummycontheight
                yrep = 2 
                ypitch = _P.separation + _P.pwidth + _P.nwidth + _P.ppowerspace + _P.npowerspace + _P.powerwidth + 2 * _P.dummycontshift
                geometry.rectanglebltr(cmos, generics.other("gatecut"), 
                    point.create(x, y - _P.cutheight / 2),
                    point.create(x + _P.gatelength, y + _P.cutheight / 2)
                )
            elseif _P.gatecontactpos[i] == "outer" then
                y = 0
                yshift = (_P.pwidth - _P.nwidth) / 2 + (_P.ppowerspace - _P.npowerspace) / 2
                yheight = _P.dummycontheight
                yrep = 2 
                ypitch = _P.separation + _P.pwidth + _P.nwidth + _P.ppowerspace + _P.npowerspace + 2 * _P.powerwidth + 2 * _P.outergstspace + _P.gstwidth
                cmos:add_area_anchor_bltr(string.format("Gp%d", i),
                    point.create(x, _P.separation / 2 + _P.pwidth + _P.outergstspace + _P.outergstwidth / 2 + _P.powerwidth + _P.ppowerspace - _P.gstwidth / 2),
                    point.create(x + _P.gatelength, _P.separation / 2 + _P.pwidth + _P.outergstspace + _P.outergstwidth / 2 + _P.powerwidth + _P.ppowerspace + _P.gstwidth / 2)
                )
                cmos:add_area_anchor_bltr(string.format("Gn%d", i),
                    point.create(x, -_P.separation / 2 - _P.nwidth - _P.outergstspace - _P.outergstwidth / 2 - _P.powerwidth - _P.npowerspace - _P.gstwidth / 2),
                    point.create(x + _P.gatelength, -_P.separation / 2 - _P.nwidth - _P.outergstspace - _P.outergstwidth / 2 - _P.powerwidth - _P.npowerspace + _P.gstwidth / 2)
                )
                geometry.rectanglebltr(cmos, generics.other("gatecut"), 
                    point.create(x, -_P.cutheight / 2),
                    point.create(x + gatepitch,  _P.cutheight / 2)
                )
            elseif _P.gatecontactpos[i] == "unused" then
                ignore = true
            else
                moderror(string.format("unknown gate contact position: [%d] = '%s'", i, _P.gatecontactpos[i]))
            end
            if not ignore then
                cmos:add_area_anchor_bltr(string.format("G%d", i),
                    point.create(x, y + yshift - yheight / 2),
                    point.create(x + _P.gatelength, y + yshift + yheight / 2)
                )
                if _P.gatenames[i] then
                    cmos:add_area_anchor_bltr(_P.gatenames[i],
                        point.create(x, y + yshift - yheight / 2),
                        point.create(x + _P.gatelength, y + yshift + yheight / 2)
                    )
                end
                dprint(yrep, yheight)
                geometry.contactbltr(
                    cmos, "gate", 
                    point.create(x, y + yshift - yheight / 2),
                    point.create(x + _P.gatelength, y + yshift + yheight / 2),
                    1, yrep, 0, ypitch
                )
            end
            if _P.gatecontactpos[i] ~= "dummy" then
                if _P.drawgcut and not _P.drawgcuteverywhere then
                geometry.rectanglebltr(
                    cmos, generics.other("gatecut"),
                    point.create(x, (_P.pwidth - _P.nwidth) / 2 + (_P.ppowerspace - _P.npowerspace) / 2 - _P.cutheight / 2),
                    point.create(x + gatepitch, (_P.pwidth - _P.nwidth) / 2 + (_P.ppowerspace - _P.npowerspace) / 2 + _P.cutheight / 2),
                    1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + _P.ppowerspace + _P.npowerspace + _P.powerwidth
                )
                end
            end
        end
    end
    if _P.drawgcut and _P.drawgcuteverywhere then
        geometry.rectanglebltr(cmos, generics.other("gatecut"),
            cmos:get_area_anchor("PRp").bl:translate(0, (_P.powerwidth - _P.cutheight) / 2),
            cmos:get_area_anchor("PRp").br:translate(0, (_P.powerwidth - _P.cutheight) / 2 + _P.cutheight)
        )
        geometry.rectanglebltr(cmos, generics.other("gatecut"),
            cmos:get_area_anchor("PRn").tl:translate(0, -(_P.powerwidth - _P.cutheight) / 2 - _P.cutheight),
            cmos:get_area_anchor("PRn").tr:translate(0, -(_P.powerwidth - _P.cutheight) / 2)
        )
    end

    -- draw source/drain contacts
    local pcontactheight = (_P.psdheight > 0) and _P.psdheight or aux.make_even(_P.pwidth / 2)
    local ncontactheight = (_P.nsdheight > 0) and _P.nsdheight or aux.make_even(_P.nwidth / 2)
    local pcontactpowerheight = (_P.psdpowerheight > 0) and _P.psdpowerheight or aux.make_even(_P.pwidth / 2)
    local ncontactpowerheight = (_P.nsdpowerheight > 0) and _P.nsdpowerheight or aux.make_even(_P.nwidth / 2)
    for i = 1, fingers + 1 do
        local x = leftndrainarea.bl:getx() + (i - 1) * gatepitch
        local y = leftpdrainarea.tl:gety()
        local cheight = _P.pcontactpos[i] == "power" and pcontactpowerheight or pcontactheight
        local yheight
        local ignore = false
        -- p contacts
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "outer" then
            y = y - cheight
            yheight = cheight
        elseif _P.pcontactpos[i] == "inner" then
            y = y - _P.pwidth
            yheight = cheight
        elseif _P.pcontactpos[i] == "full" or _P.pcontactpos[i] == "fullpower" then
            y = y - _P.pwidth
            yheight = _P.pwidth
        elseif not _P.pcontactpos[i] or _P.pcontactpos[i] == "unused" then
            ignore = true
        else
            moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'", i, _P.pcontactpos[i]))
        end
        if not ignore then
            geometry.contactbltr(
                cmos, "sourcedrain", 
                point.create(x, y),
                point.create(x + _P.sdwidth, y + yheight)
            )
            cmos:add_area_anchor_bltr(string.format("pSD%d", i),
                point.create(x, y),
                point.create(x + _P.sdwidth, y + yheight)
            )
        end

        -- connect source/drain region to power bar
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "fullpower" then
            geometry.rectanglebltr(
                cmos, generics.metal(1), 
                point.create(x, y + yheight),
                point.create(x + _P.sdwidth, y + yheight + _P.ppowerspace)
            )
        end

        -- n contacts
        do
            local y = leftndrainarea.bl:gety()
            local yheight
            local ignore = false
            if _P.ncontactpos[i] == "power" then
                yheight = ncontactpowerheight
            elseif _P.ncontactpos[i] == "outer" then
                yheight = ncontactheight
            elseif _P.ncontactpos[i] == "inner" then
                y = y + _P.nwidth - ncontactheight
                yheight = ncontactheight
            elseif _P.ncontactpos[i] == "full" or _P.ncontactpos[i] == "fullpower" then
                yheight = _P.nwidth
            elseif not _P.ncontactpos[i] or _P.ncontactpos[i] == "unused" then
                ignore = true
            else
                moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'", i, _P.ncontactpos[i]))
            end
            if not ignore then
                geometry.contactbltr(
                    cmos, "sourcedrain", 
                    point.create(x, y),
                    point.create(x + _P.sdwidth, y + yheight)
                )
                cmos:add_area_anchor_bltr(string.format("nSD%d", i),
                    point.create(x, y),
                    point.create(x + _P.sdwidth, y + yheight)
                )
            end

            -- connect source/drain region to power bar
            if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "fullpower" then
                geometry.rectanglebltr(
                    cmos, generics.metal(1), 
                    point.create(x, y - _P.npowerspace),
                    point.create(x + _P.sdwidth, y)
                )
            end
        end
    end

    -- alignment box
    local ybot = -_P.separation / 2 - _P.nwidth - _P.npowerspace - _P.powerwidth / 2
    local ytop =  _P.separation / 2 + _P.pwidth + _P.ppowerspace + _P.powerwidth / 2
    if _P.drawpmoswelltap then
        ytop = ytop + _P.powerwidth / 2 + _P.pmoswelltapspace + _P.pmoswelltapwidth / 2
    end
    if _P.drawnmoswelltap then
        ybot = ybot - _P.powerwidth / 2 - _P.nmoswelltapspace - _P.nmoswelltapwidth / 2
    end
    cmos:set_alignment_box(
        leftndrainarea.bl:copy():translate(0, -_P.npowerspace - _P.powerwidth),
        rightpdrainarea.tr:copy():translate(0, _P.ppowerspace + _P.powerwidth),
        leftndrainarea.br:copy():translate(0, -_P.npowerspace),
        rightpdrainarea.tl:copy():translate(0, _P.ppowerspace)
    )
end
