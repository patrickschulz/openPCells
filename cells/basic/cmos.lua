function parameters()
    pcell.add_parameters(
        { "oxidetype(Oxide Type)",                             1 },
        { "gatemarker(Gate Marker Index)",                     1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",            1 },
        { "nvthtype(NMOS Threshold Voltage Type)",             1 },
        { "pmosflippedwell(PMOS Flipped Well) ",            false },
        { "nmosflippedwell(NMOS Flipped Well)",             false },
        { "pwidth(PMOS Finger Width)",                         tech.get_dimension("Minimum Gate Width"), posvals = even() },
        { "nwidth(NMOS Finger Width)",                         tech.get_dimension("Minimum Gate Width"), posvals = even() },
        { "separation(Separation Between Active Regions)",     tech.get_dimension("Minimum Active Space"), posvals = even() },
        { "gatelength(Gate Length)",                           tech.get_dimension("Minimum Gate Length"), argtype = "integer", posvals = even() },
        { "gatespace(Gate Spacing)",                           tech.get_dimension("Minimum Gate XSpace"), argtype = "integer", posvals = even() },
        { "sdwidth(Source/Drain Metal Width)",                 tech.get_dimension("Minimum M1 Width"), posvals = even() },
        { "gstwidth(Gate Strap Metal Width)",                  tech.get_dimension("Minimum M1 Width") },
        { "gstspace(Gate Strap Metal Space)",                  tech.get_dimension("Minimum M1 Space") },
        { "gatecontactsplitshift(Gate Contact Split Shift)",   tech.get_dimension("Minimum M1 Width") + tech.get_dimension("Minimum M1 Space") },
        { "powerwidth(Power Rail Metal Width)",                tech.get_dimension("Minimum M1 Width") },
        { "npowerspace(NMOS Power Rail Space)",                tech.get_dimension("Minimum M1 Space"), posvals = positive() },
        { "ppowerspace(PMOS Power Rail Space)",                tech.get_dimension("Minimum M1 Space"), posvals = positive() },
        { "gateext(Gate Extension)",                           0 },
        { "psdheight(PMOS Source/Drain Contact Height)",       0 },
        { "nsdheight(NMOS Source/Drain Contact Height)",       0 },
        { "psdpowerheight(PMOS Source/Drain Contact Height)",  0 },
        { "nsdpowerheight(NMOS Source/Drain Contact Height)",  0 },
        { "cutheight",                                         tech.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace"), posvals = even() },
        { "compact(Compact Layout)",                           true },
        { "connectoutput",                                     true },
        { "drawtransistors", true },
        { "drawactive", true },
        { "drawrails", true },
        { "drawgatecontacts", true },
        { "outergstwidth(Outer Gate Strap Metal Width)",  tech.get_dimension("Minimum M1 Width") },
        { "outergstspace(Outer Gate Strap Metal Space)",  tech.get_dimension("Minimum M1 Space") },
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
        { "dummycontheight(Dummy Gate Contact Height)",        tech.get_dimension("Minimum M1 Width") },
        { "dummycontshift(Dummy Gate Shift)",                  0 },
        { "drawnmoswelltap(Draw nMOS Well Tap)", false },
        { "nmoswelltapspace(nMOS Well Tap Space)", tech.get_dimension("Minimum M1 Space") },
        { "nmoswelltapwidth(nMOS Well Tap Width)", tech.get_dimension("Minimum M1 Width") },
        { "drawpmoswelltap(Draw pMOS Well Tap)", false },
        { "pmoswelltapspace(pMOS Well Tap Space)", tech.get_dimension("Minimum M1 Space") },
        { "pmoswelltapwidth(pMOS Well Tap Width)", tech.get_dimension("Minimum M1 Width") },
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
            cutheight = _P.cutheight,
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
            topgcutoffset = -_P.powerwidth / 2,
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
            botgcutoffset = _P.powerwidth / 2,
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
            if _P.gatecontactpos[i] == "dummy" or _P.gatecontactpos[i] == "split" then
                nopt.drawtopgcut = true
                nopt.drawbotgcut = false
                popt.drawtopgcut = false
                popt.drawbotgcut = true
            else
                nopt.drawtopgcut = false
                nopt.drawbotgcut = false
                popt.drawtopgcut = false
                popt.drawbotgcut = false
            end
            local shift = (i - 1) * gatepitch
            local nfet = pcell.create_layout("basic/mosfet", "nfet", nopt)
            nfet:move_anchor("gate1tc")
            nfet:translate(shift, 0)
            cmos:merge_into(nfet)
            local pfet = pcell.create_layout("basic/mosfet", "pfet", popt)
            pfet:move_anchor("gate1bc")
            pfet:translate(shift, 0)
            cmos:merge_into(pfet)
        end
        nopt.drawtopgcut = true
        popt.drawbotgcut = true
        -- pop general transistor settings
        pcell.pop_overwrites("basic/mosfet")
    end

    -- power rails
    if _P.drawrails then
        geometry.rectangle(cmos,
            generics.metal(1), 
            fingers * gatepitch + _P.sdwidth, _P.powerwidth,
            (fingers - 1) * gatepitch / 2, (_P.pwidth - _P.nwidth) / 2 + (_P.ppowerspace - _P.npowerspace) / 2,
            1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + _P.ppowerspace + _P.npowerspace + _P.powerwidth
        )
    end
    cmos:add_anchor_area(
        "PRp",
        fingers * gatepitch + _P.sdwidth, _P.powerwidth,
        (fingers - 1) * gatepitch / 2, _P.separation / 2 + _P.pwidth + _P.ppowerspace + _P.powerwidth / 2
    )
    cmos:add_anchor_area(
        "PRn",
        fingers * gatepitch + _P.sdwidth, _P.powerwidth,
        (fingers - 1) * gatepitch / 2, -_P.separation / 2 - _P.nwidth - _P.npowerspace - _P.powerwidth / 2
    )

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
            local x = (i - 1) * gatepitch
            local y = _P.shiftgatecontacts
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
                cmos:add_anchor_area(string.format("Gupper%d", i), _P.gatelength, _P.gstwidth, x, y + _P.gatecontactsplitshift / 2)
                cmos:add_anchor_area(string.format("Glower%d", i), _P.gatelength, _P.gstwidth, x, y - _P.gatecontactsplitshift / 2)
                geometry.rectangle(cmos, generics.other("gatecut"), gatepitch, _P.cutheight, x, 0)
            elseif _P.gatecontactpos[i] == "dummy" then
                y = 0
                yshift = (_P.pwidth - _P.nwidth) / 2 + (_P.ppowerspace - _P.npowerspace) / 2
                yheight = _P.dummycontheight
                yrep = 2 
                ypitch = _P.separation + _P.pwidth + _P.nwidth + _P.ppowerspace + _P.npowerspace + _P.powerwidth + 2 * _P.dummycontshift
                geometry.rectangle(cmos, generics.other("gatecut"), gatepitch, _P.cutheight, x, 0)
            elseif _P.gatecontactpos[i] == "outer" then
                y = 0
                yshift = (_P.pwidth - _P.nwidth) / 2 + (_P.ppowerspace - _P.npowerspace) / 2
                yheight = _P.dummycontheight
                yrep = 2 
                ypitch = _P.separation + _P.pwidth + _P.nwidth + _P.ppowerspace + _P.npowerspace + 2 * _P.powerwidth + 2 * _P.outergstspace + _P.gstwidth
                cmos:add_anchor_area(string.format("Gp%d", i), _P.gatelength, _P.gstwidth, x, _P.separation / 2 + _P.pwidth + _P.outergstspace + _P.outergstwidth / 2 + _P.powerwidth + _P.ppowerspace)
                cmos:add_anchor_area(string.format("Gn%d", i), _P.gatelength, _P.gstwidth, x, -_P.separation / 2 - _P.nwidth - _P.outergstspace - _P.outergstwidth / 2 - _P.powerwidth - _P.npowerspace)
                geometry.rectangle(cmos, generics.other("gatecut"), gatepitch, _P.cutheight, x, 0)
            elseif _P.gatecontactpos[i] == "unused" then
                ignore = true
            else
                moderror(string.format("unknown gate contact position: [%d] = '%s'", i, _P.gatecontactpos[i]))
            end
            if not ignore then
                cmos:add_anchor_area(string.format("G%d", i), _P.gatelength, yheight, x, y + yshift)
                if (#_P.gatenames > 0) then
                    cmos:add_anchor_area(_P.gatenames[i], _P.gatelength, yheight, x, y + yshift)
                end
                geometry.contactbltr(
                    cmos, "gate", 
                    point.create(x - _P.gatelength / 2, y + yshift - yheight / 2),
                    point.create(x + _P.gatelength / 2, y + yshift + yheight / 2),
                    1, yrep, 0, ypitch
                )
            end
            if _P.gatecontactpos[i] ~= "dummy" then
                if _P.drawgcut and not _P.drawgcuteverywhere then
                geometry.rectanglebltr(
                    cmos, generics.other("gatecut"),
                    point.create(x - gatepitch / 2, (_P.pwidth - _P.nwidth) / 2 + (_P.ppowerspace - _P.npowerspace) / 2 - _P.cutheight / 2),
                    point.create(x + gatepitch / 2, (_P.pwidth - _P.nwidth) / 2 + (_P.ppowerspace - _P.npowerspace) / 2 + _P.cutheight / 2),
                    1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + _P.ppowerspace + _P.npowerspace + _P.powerwidth
                )
                end
            end
        end
    end
    if _P.drawgcut and _P.drawgcuteverywhere then
        geometry.rectangle(cmos,
            generics.other("gatecut"), 
            fingers * gatepitch + _P.sdwidth, _P.cutheight,
            (fingers - 1) * gatepitch / 2, (_P.pwidth - _P.nwidth) / 2 + (_P.ppowerspace - _P.npowerspace) / 2,
            1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + _P.ppowerspace + _P.npowerspace + _P.powerwidth
        )
    end

    -- draw source/drain contacts
    local pcontactheight = (_P.psdheight > 0) and _P.psdheight or aux.make_even(_P.pwidth / 2)
    local ncontactheight = (_P.nsdheight > 0) and _P.nsdheight or aux.make_even(_P.nwidth / 2)
    local pcontactpowerheight = (_P.psdpowerheight > 0) and _P.psdpowerheight or aux.make_even(_P.pwidth / 2)
    local ncontactpowerheight = (_P.nsdpowerheight > 0) and _P.nsdpowerheight or aux.make_even(_P.nwidth / 2)
    for i = 1, fingers + 1 do
        local x = (i - 1) * gatepitch - gatepitch / 2
        local y = _P.separation / 2 + _P.pwidth / 2
        local yshift = 0
        local cheight = _P.pcontactpos[i] == "power" and pcontactpowerheight or pcontactheight
        local yheight
        local ignore = false
        -- p contacts
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "outer" then
            yshift = _P.pwidth / 2 - _P.shiftpcontactsouter - cheight / 2
            yheight = cheight
        elseif _P.pcontactpos[i] == "inner" then
            yshift = -_P.shiftpcontactsouter - cheight / 2
            yheight = cheight
        elseif _P.pcontactpos[i] == "full" or _P.pcontactpos[i] == "fullpower" then
            yheight = _P.pwidth
        elseif not _P.pcontactpos[i] or _P.pcontactpos[i] == "unused" then
            ignore = true
        else
            moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'", i, _P.pcontactpos[i]))
        end
        if not ignore then
            cmos:add_anchor_area(string.format("pSD%d", i), _P.sdwidth, yheight, x, y + yshift)
            geometry.contactbltr(
                cmos, "sourcedrain", 
                point.create(x - _P.sdwidth / 2, y + yshift - yheight / 2),
                point.create(x + _P.sdwidth / 2, y + yshift + yheight / 2)
            )
        end

        -- connect source/drain region to power bar
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "fullpower" then
            geometry.rectanglebltr(
                cmos, generics.metal(1), 
                point.create(x - _P.sdwidth / 2, y + _P.pwidth / 2 + _P.ppowerspace / 2 - _P.shiftpcontactsouter - _P.ppowerspace / 2),
                point.create(x + _P.sdwidth / 2, y + _P.pwidth / 2 + _P.ppowerspace / 2 - _P.shiftpcontactsouter + _P.ppowerspace / 2)
            )
        end

        -- n contacts
        do
            local x = (i - 1) * gatepitch - gatepitch / 2
            local y = -_P.separation / 2 - _P.nwidth / 2
            local yshift = 0
            local cheight = _P.ncontactpos[i] == "power" and ncontactpowerheight or ncontactheight
            local yheight
            local ignore = false
            if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "outer" then
                yshift = -_P.nwidth / 2 - _P.shiftncontactsouter + cheight / 2
                yheight = cheight
            elseif _P.ncontactpos[i] == "inner" then
                yshift = -_P.shiftncontactsouter + cheight / 2
                yheight = cheight
            elseif _P.ncontactpos[i] == "full" or _P.ncontactpos[i] == "fullpower" then
                yheight = _P.nwidth
            elseif not _P.ncontactpos[i] or _P.ncontactpos[i] == "unused" then
                ignore = true
            else
                moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'", i, _P.ncontactpos[i]))
            end
            if not ignore then
                cmos:add_anchor_area(string.format("nSD%d", i), _P.sdwidth, yheight, x, y + yshift)
                geometry.contactbltr(
                    cmos, "sourcedrain", 
                    point.create(x - _P.sdwidth / 2, y + yshift - yheight / 2),
                    point.create(x + _P.sdwidth / 2, y + yshift + yheight / 2)
                )
            end

            -- connect source/drain region to power bar
            if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "fullpower" then
                geometry.rectanglebltr(
                    cmos, generics.metal(1), 
                    point.create(x - _P.sdwidth / 2, y - _P.nwidth / 2 - _P.npowerspace / 2 + _P.shiftncontactsouter - _P.npowerspace / 2),
                    point.create(x + _P.sdwidth / 2, y - _P.nwidth / 2 - _P.npowerspace / 2 + _P.shiftncontactsouter + _P.npowerspace / 2)
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
        point.create(-1 * (_P.gatelength + _P.gatespace) / 2, ybot),
        point.create( (2 * fingers - 1) * (_P.gatelength + _P.gatespace) / 2, ytop)
    )
end
