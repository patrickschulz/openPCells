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
        { "separation(Separation Between Active Regions)",     technology.get_dimension("Minimum Active Space") },
        { "gatelength(Gate Length)",                           technology.get_dimension("Minimum Gate Length"), argtype = "integer" },
        { "gatespace(Gate Spacing)",                           technology.get_dimension("Minimum Gate XSpace"), argtype = "integer" },
        { "sdwidth(Source/Drain Metal Width)",                 technology.get_dimension("Minimum M1 Width"), posvals = even() },
        { "innergatestraps(Number of Inner Gate Straps)",      3 },
        { "gatestrapwidth(Gate Strap Metal Width)",                  technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace(Gate Strap Metal Space)",                  technology.get_dimension("Minimum M1 Space") },
        { "gatecontactsplitshift(Gate Contact Split Shift)",   technology.get_dimension("Minimum M1 Width") + technology.get_dimension("Minimum M1 Space") },
        { "powerwidth(Power Rail Metal Width)",                technology.get_dimension("Minimum M1 Width") },
        { "npowerspace(NMOS Power Rail Space)",                technology.get_dimension("Minimum M1 Space"), posvals = positive() },
        { "ppowerspace(PMOS Power Rail Space)",                technology.get_dimension("Minimum M1 Space"), posvals = positive() },
        { "pgateext(pMOS Gate Extension)",                     0 },
        { "ngateext(nMOS Gate Extension)",                     0 },
        { "psdheight(PMOS Source/Drain Contact Height)",       0 },
        { "nsdheight(NMOS Source/Drain Contact Height)",       0 },
        { "psdpowerheight(PMOS Source/Drain Contact Height)",  0 },
        { "nsdpowerheight(NMOS Source/Drain Contact Height)",  0 },
        { "psddummyouterheight(PMOS Source/Drain Outer Dummy Contact Height)",  0 },
        { "nsddummyouterheight(NMOS Source/Drain Outer Dummy Contact Height)",  0 },
        { "psddummyinnerheight(PMOS Source/Drain Inner Dummy Contact Height)",  0 },
        { "nsddummyinnerheight(NMOS Source/Drain Inner Dummy Contact Height)",  0 },
        { "cutwidth",                                          0, follow = "gatelength" }, -- FIXME: allow expressions for follower parameters
        { "cutheight",                                         technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace") },
        { "poutercutyshift",                                   0 },
        { "noutercutyshift",                                   0 },
        { "compact(Compact Layout)",                           true },
        { "connectoutput",                                     true },
        { "drawtransistors", true },
        { "drawactive", true },
        { "drawrails", true },
        { "drawgatecontacts", true },
        { "outergatestrapwidth(Outer Gate Strap Metal Width)",  technology.get_dimension("Minimum M1 Width") },
        { "outergatestrapspace(Outer Gate Strap Metal Space)",  technology.get_dimension("Minimum M1 Space") },
        { "outergateshift(Outer Gate Strap Metal Shift)",  0 },
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
        { "drawoutergatecut", false },
        { "drawgatecuteverywhere", false },
        { "dummycontheight(Dummy Gate Contact Height)",        technology.get_dimension("Minimum M1 Width") },
        { "dummycontshift(Dummy Gate Shift)",                  0 },
        { "drawnmoswelltap(Draw nMOS Well Tap)", false },
        { "nmoswelltapspace(nMOS Well Tap Space)", technology.get_dimension("Minimum M1 Space") },
        { "nmoswelltapwidth(nMOS Well Tap Width)", technology.get_dimension("Minimum M1 Width") },
        { "drawpmoswelltap(Draw pMOS Well Tap)", false },
        { "pmoswelltapspace(pMOS Well Tap Space)", technology.get_dimension("Minimum M1 Space") },
        { "pmoswelltapwidth(pMOS Well Tap Width)", technology.get_dimension("Minimum M1 Width") },
        { "welltapcontinuouscontact(Well Tap Draw Continuous Contacts)", true },
        { "welltapextendleft", 0 },
        { "welltapextendright", 0 },
        { "nsplitsourcevias", false },
        { "psplitsourcevias", false },
        { "nsplitdrainvias", false },
        { "psplitdrainvias", false },
        { "drawactivedummy", false },
        { "activedummywidth", 0 },
        { "activedummyspace", 0 },
        { "drawleftstopgate", false },
        { "drawrightstopgate", false },
        { "leftpolylines", {} },
        { "rightpolylines", {} },
        { "extendimplanttop", 0 },
        { "extendimplantbottom", 0 },
        { "extendimplantleft", 0 },
        { "extendimplantright", 0 },
        { "extendoxidetypetop", 0 },
        { "extendoxidetypebottom", 0 },
        { "extendoxidetypeleft", 0 },
        { "extendoxidetyperight", 0 },
        { "extendvthtypetop", 0 },
        { "extendvthtypebottom", 0 },
        { "extendvthtypeleft", 0 },
        { "extendvthtyperight", 0 },
        { "extendwelltop", 0 },
        { "extendwellbottom", 0 },
        { "extendwellleft", 0 },
        { "extendwellright", 0 }
    )
end

function check(_P)
    -- check separation
    if (_P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace) > _P.separation then
        return false, string.format("can't fit all gate straps into the separation between nmos and pmos: %d > %d", _P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace, _P.separation)
    end
    -- FIXME: this check is not necessary, but the current implementation is broken if this condition is met
    if (_P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace) ~= _P.separation then
        return false, string.format("the separation between nmos and pmos must have the exact size to fit three rows of gate contacts (%d vs. %d)", _P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace, _P.separation)
    end
    -- check number of gate and source/drain contacts
    if #_P.pcontactpos ~= #_P.ncontactpos then
        return false, "the number of the source/drain contacts must be equal for nmos and pmos"
    end
    if (#_P.gatecontactpos + 1) ~= #_P.ncontactpos then
        return false, "the number of the source/drain contacts must match the gate contacts (+1)"
    end
    -- check if gate cut width and gatelength match
    if (_P.gatelength % 2) ~= (_P.cutwidth % 2) then
        return false, "gatelength and cutwidth must both be either odd or even"
    end
    -- check if gate cut height and separation match
    if (_P.separation % 2) ~= (_P.cutheight % 2) then
        return false, "separation and cutheight must both be either odd or even"
    end
    return true
end

function layout(cmos, _P)
    local gatepitch = _P.gatespace + _P.gatelength
    local fingers = #_P.gatecontactpos

    -- check if outer gates are drawn
    local outergateshift = 0
    if _P.drawgatecontacts then
        if util.any_of("outer", _P.gatecontactpos) then
            outergateshift = _P.outergateshift + _P.gatestrapwidth
        end
    end

    -- check if gate names are valid
    if (#_P.gatenames > 0) and (#_P.gatenames ~= #_P.gatecontactpos) then
        moderror(string.format("basic/cmos: number of entries in 'gatenames' must match 'gatecontactpos' (got %d, must be %d)", #_P.gatenames, #_P.gatecontactpos))
    end

    local leftndrainarea, rightndrainarea
    local leftpdrainarea, rightpdrainarea
    local leftnmoswell, rightnmoswell
    local leftpmoswell, rightpmoswell
    local leftnmosimplant, rightnmosimplant
    local leftpmosimplant, rightpmosimplant
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
            topgatecutheight = _P.cutheight,
            botgatecutheight = _P.cutheight,
            topgatecutleftext = (_P.cutwidth - _P.gatelength) / 2,
            topgatecutrightext = (_P.cutwidth - _P.gatelength) / 2,
            botgatecutleftext = (_P.cutwidth - _P.gatelength) / 2,
            botgatecutrightext = (_P.cutwidth - _P.gatelength) / 2,
        })

        -- pmos
        local popt = {
            channeltype = "pmos",
            vthtype = _P.pvthtype,
            flippedwell = _P.pmosflippedwell,
            fingerwidth = _P.pwidth,
            gbotext = _P.separation / 2,
            gtopext = _P.pgateext,
            topgatecutspace = -_P.powerwidth / 2,
            drawtopactivedummy = _P.drawactivedummy,
            topactivedummywidth = _P.activedummywidth,
            topactivedummyspace = _P.activedummyspace,
            botgatecutspace = _P.separation / 2 - _P.cutheight / 2,
            extendwelltop = _P.ppowerspace,
            extendimplanttop = _P.extendimplanttop,
            extendimplantleft = _P.extendimplantleft,
            extendimplantright = _P.extendimplantright,
            extendoxidetypetop = _P.extendoxidetypetop,
            extendoxidetypeleft = _P.extendoxidetypeleft,
            extendoxidetyperight = _P.extendoxidetyperight,
            extendvthtypetop = _P.extendvthtypetop,
            extendvthtypeleft = _P.extendvthtypeleft,
            extendvthtyperight = _P.extendvthtyperight,
            extendwelltop = _P.extendwelltop,
            extendwellleft = _P.extendwellleft,
            extendwellright = _P.extendwellright,
            splitsourcevias = _P.psplitsourcevias,
            splitdrainvias = _P.psplitdrainvias,
        }
        local nopt = {
            channeltype = "nmos",
            vthtype = _P.nvthtype,
            flippedwell = _P.nmosflippedwell,
            fingerwidth = _P.nwidth,
            gtopext = _P.separation / 2,
            gbotext = _P.ngateext,
            botgatecutspace = _P.powerwidth / 2,
            drawbotgatecut = false,
            drawbottomactivedummy = _P.drawactivedummy,
            bottomactivedummywidth = _P.activedummywidth,
            bottomactivedummyspace = _P.activedummyspace,
            topgatecutspace = _P.separation / 2 - _P.cutheight / 2,
            extendwellbottom = _P.npowerspace,
            extendimplantbottom = _P.extendimplantbottom,
            extendimplantleft = _P.extendimplantleft,
            extendimplantright = _P.extendimplantright,
            extendoxidetypebottom = _P.extendoxidetypebottom,
            extendoxidetypeleft = _P.extendoxidetypeleft,
            extendoxidetyperight = _P.extendoxidetyperight,
            extendvthtypebottom = _P.extendvthtypebottom,
            extendvthtypeleft = _P.extendvthtypeleft,
            extendvthtyperight = _P.extendvthtyperight,
            extendwellbottom = _P.extendwellbottom,
            extendwellleft = _P.extendwellleft,
            extendwellright = _P.extendwellright,
            splitsourcevias = _P.nsplitsourcevias,
            splitdrainvias = _P.nsplitdrainvias,
        }
        -- main
        for i = 1, fingers do
            nopt.leftpolylines = {}
            popt.leftpolylines = {}
            nopt.drawleftstopgate = false
            popt.drawleftstopgate = false
            nopt.rightpolylines = {}
            popt.rightpolylines = {}
            nopt.drawrightstopgate = false
            popt.drawrightstopgate = false
            if i == 1 then
                nopt.leftpolylines = _P.leftpolylines
                popt.leftpolylines = _P.leftpolylines
                if _P.drawleftstopgate then
                    nopt.drawleftstopgate = true
                    nopt.drawstopgatetopgatecut = true
                    nopt.drawstopgatebotgatecut = false
                    popt.drawleftstopgate = true
                    popt.drawstopgatetopgatecut = false
                    popt.drawstopgatebotgatecut = true
                end
            end
            if i == fingers then
                nopt.rightpolylines = _P.rightpolylines
                popt.rightpolylines = _P.rightpolylines
                if _P.drawrightstopgate then
                    nopt.drawrightstopgate = true
                    nopt.drawstopgatetopgatecut = true
                    nopt.drawstopgatebotgatecut = false
                    popt.drawrightstopgate = true
                    popt.drawstopgatetopgatecut = false
                    popt.drawstopgatebotgatecut = true
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
                leftndrainarea = nfet:get_area_anchor("sourcedrainactiveleft")
                leftpdrainarea = pfet:get_area_anchor("sourcedrainactiveleft")
                firstgatearea = nfet:get_area_anchor("gate1")
                leftnmoswell = nfet:get_area_anchor("well")
                leftpmoswell = pfet:get_area_anchor("well")
                leftnmosimplant = nfet:get_area_anchor("implant")
                leftpmosimplant = pfet:get_area_anchor("implant")
            end
            if i == fingers then
                rightndrainarea = nfet:get_area_anchor("sourcedrainactiveright")
                rightpdrainarea = pfet:get_area_anchor("sourcedrainactiveright")
                rightnmoswell = nfet:get_area_anchor("well")
                rightpmoswell = pfet:get_area_anchor("well")
                rightnmosimplant = nfet:get_area_anchor("implant")
                rightpmosimplant = pfet:get_area_anchor("implant")
            end
        end
        nopt.drawtopgatecut = true
        popt.drawbotgatecut = true
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

    -- well anchors
    cmos:add_area_anchor_bltr("nmos_well",
        leftnmoswell.bl,
        rightnmoswell.tr
    )
    cmos:add_area_anchor_bltr("pmos_well",
        leftpmoswell.bl,
        rightpmoswell.tr
    )

    -- implant anchors
    cmos:add_area_anchor_bltr("nmos_implant",
        leftndrainarea.bl,
        rightndrainarea.tr
    )
    cmos:add_area_anchor_bltr("pmos_implant",
        leftpdrainarea.bl,
        rightpdrainarea.tr
    )

    -- active anchors
    cmos:add_area_anchor_bltr("nmos_active",
        leftndrainarea.bl,
        rightndrainarea.tr
    )
    cmos:add_area_anchor_bltr("pmos_active",
        leftpdrainarea.bl,
        rightpdrainarea.tr
    )

    -- well taps (can't use the mosfet pcell well taps, as only single fingers are instantiated)
    local welltapwidth = rightpdrainarea.tr:getx() - leftpdrainarea.tl:getx()
    if _P.drawpmoswelltap then
        cmos:merge_into(pcell.create_layout("auxiliary/welltap", "pmoswelltap", {
            contype = _P.pmosflippedwell and "p" or "n",
            width = welltapwidth,
            height = _P.pmoswelltapwidth,
            xcontinuous = _P.welltapcontinuouscontact
        }):translate(leftpdrainarea.tl:getx(), _P.nwidth + _P.separation + _P.pwidth + _P.ppowerspace + _P.powerwidth + _P.pmoswelltapspace))
    end
    if _P.drawnmoswelltap then
        cmos:merge_into(pcell.create_layout("auxiliary/welltap", "nmoswelltap", {
            contype = _P.nmosflippedwell and "n" or "p",
            width = welltapwidth,
            height = _P.nmoswelltapwidth,
            xcontinuous = _P.welltapcontinuouscontact
        }):translate(leftpdrainarea.tl:getx(), -_P.nmoswelltapwidth - _P.npowerspace - _P.powerwidth - _P.nmoswelltapspace))
    end

    -- draw gate contacts
    if _P.drawgatecontacts then
        for i = 1, fingers do
            local entries = {}
            local x = firstgatearea.bl:getx() + (i - 1) * gatepitch
            local y = leftndrainarea.tl:gety() + _P.shiftgatecontacts
            if _P.gatecontactpos[i] == "center" then -- do nothing
                table.insert(entries, {
                    yheight = _P.gatestrapwidth,
                    --yshift = (_P.innergatestraps - 1) * _P.gatestrapspace + (_P.innergatestraps - 2) * _P.gatestrapwidth,
                    yshift = _P.gatestrapspace,
                    index = i,
                })
            elseif string.match(_P.gatecontactpos[i], "upper") then
                local index = string.match(_P.gatecontactpos[i], "upper(%d+)")
                if not index then
                    moderror(string.format("bad gate contact position format: [%d] = '%s' (should be 'upperNUMBER')", i, _P.gatecontactpos[i]))
                end
                table.insert(entries, {
                    yshift = _P.innergatestraps * _P.gatestrapspace + (_P.innergatestraps - 1) * _P.gatestrapwidth,
                    yheight = _P.gatestrapwidth,
                    index = i,
                })
            elseif string.match(_P.gatecontactpos[i], "lower") then
                local index = string.match(_P.gatecontactpos[i], "lower(%d+)")
                if not index then
                    moderror(string.format("bad gate contact position format: [%d] = '%s' (should be 'lowerNUMBER')", i, _P.gatecontactpos[i]))
                end
                table.insert(entries, {
                    yshift = _P.innergatestraps * _P.gatestrapspace + (_P.innergatestraps - 1) * _P.gatestrapwidth,
                    yheight = _P.gatestrapwidth,
                    index = i,
                })
            elseif _P.gatecontactpos[i] == "split" then
                table.insert(entries, {
                    yshift = 3 * _P.gatestrapspace + 2 * _P.gatestrapwidth,
                    yheight = _P.gatestrapwidth,
                    index = i,
                    prefix = "upper",
                })
                table.insert(entries, {
                    yshift = 1 * _P.gatestrapspace,
                    yheight = _P.gatestrapwidth,
                    index = i,
                    prefix = "lower",
                })
                local cutxshift = (_P.gatelength - _P.cutwidth) / 2
                local cutyshift = (_P.separation - _P.cutheight) / 2
                geometry.rectanglebltr(cmos, generics.other("gatecut"), 
                    point.create(x + cutxshift,               y + cutyshift),
                    point.create(x + cutxshift + _P.cutwidth, y + cutyshift + _P.cutheight)
                )
            elseif _P.gatecontactpos[i] == "dummy" then
                table.insert(entries, {
                    yshift = -_P.nwidth - _P.npowerspace - _P.dummycontheight,
                    yheight = _P.dummycontheight,
                    index = i,
                })
                table.insert(entries, {
                    yshift = _P.separation + _P.pwidth + _P.ppowerspace,
                    yheight = _P.dummycontheight,
                    index = i,
                })
                local cutxshift = (_P.gatelength - _P.cutwidth) / 2
                local cutyshift = (_P.separation - _P.cutheight) / 2
                geometry.rectanglebltr(cmos, generics.other("gatecut"), 
                    point.create(x + cutxshift,               y + cutyshift),
                    point.create(x + cutxshift + _P.cutwidth, y + cutyshift + _P.cutheight)
                )
            elseif _P.gatecontactpos[i] == "outer" then
                table.insert(entries, {
                    yshift = _P.separation + _P.pwidth + _P.outergatestrapspace,
                    yheight = _P.outergatestrapwidth,
                    index = i,
                    prefix = "p",
                })
                table.insert(entries, {
                    yshift = -_P.nwidth - _P.outergatestrapspace - _P.outergatestrapwidth,
                    yheight = _P.outergatestrapwidth,
                    index = i,
                    prefix = "n",
                })
                local cutxshift = (_P.gatelength - _P.cutwidth) / 2
                local cutyshift = (_P.separation - _P.cutheight) / 2
                geometry.rectanglebltr(cmos, generics.other("gatecut"), 
                    point.create(x + cutxshift,               y + cutyshift),
                    point.create(x + cutxshift + _P.cutwidth, y + cutyshift + _P.cutheight)
                )
            elseif _P.gatecontactpos[i] == "unused" then
                -- do nothing
            else
                moderror(string.format("unknown gate contact position: [%d] = '%s'", i, _P.gatecontactpos[i]))
            end
            for _, entry in ipairs(entries) do
                local yshift = entry.yshift or 0
                local yheight = entry.yheight
                local index = entry.index
                local gnames = { string.format("G%s%d", entry.prefix or "", index) }
                if _P.gatenames[i] then
                    table.insert(gnames, _P.gatenames[i])
                end
                local bl = point.create(x,                 y + yshift)
                local tr = point.create(x + _P.gatelength, y + yshift + yheight)
                -- add anchors
                for _, gatename in ipairs(gnames) do
                    cmos:add_area_anchor_bltr(gatename, bl, tr)
                end
                -- create contact
                geometry.contactbltr(cmos, "gate", bl, tr)
            end
            if _P.gatecontactpos[i] ~= "dummy" then
                if _P.drawoutergatecut and not _P.drawgatecuteverywhere then
                    geometry.rectanglebltr(
                        cmos, generics.other("gatecut"),
                        point.create(x + (_P.gatelength - _P.cutwidth) / 2, -_P.noutercutyshift - _P.cutheight),
                        point.create(x + (_P.gatelength + _P.cutwidth) / 2, -_P.noutercutyshift)
                    )
                    geometry.rectanglebltr(
                        cmos, generics.other("gatecut"),
                        point.create(x + (_P.gatelength - _P.cutwidth) / 2, _P.nwidth + _P.pwidth + _P.separation + _P.poutercutyshift),
                        point.create(x + (_P.gatelength + _P.cutwidth) / 2, _P.nwidth + _P.pwidth + _P.separation + _P.poutercutyshift + _P.cutheight)
                    )
                end
            end
        end
    end
    if _P.drawoutergatecut and _P.drawgatecuteverywhere then
        geometry.rectanglebltr(cmos, generics.other("gatecut"),
            cmos:get_area_anchor("PRp").bl:translate(0, (_P.powerwidth - _P.cutheight) / 2),
            cmos:get_area_anchor("PRp").br:translate(0, (_P.powerwidth - _P.cutheight) / 2 + _P.cutheight)
        )
        geometry.rectanglebltr(cmos, generics.other("gatecut"),
            cmos:get_area_anchor("PRn").tl:translate(0, -(_P.powerwidth - _P.cutheight) / 2 - _P.cutheight),
            cmos:get_area_anchor("PRn").tr:translate(0, -(_P.powerwidth - _P.cutheight) / 2)
        )
    end
    -- add always-available gate anchors for all three positions (lower, upper, center)
    -- the x coordinate does not make any sense, these anchors are just for y alignment
    local basey = leftndrainarea.tl:gety() + _P.shiftgatecontacts
    cmos:add_area_anchor_bltr("Glowerbase",
        point.create(0, basey + 1 * _P.gatestrapspace + 0 * _P.gatestrapwidth),
        point.create(0, basey + 1 * _P.gatestrapspace + 1 * _P.gatestrapwidth)
    )
    cmos:add_area_anchor_bltr("Gcenterbase",
        point.create(0, basey + 2 * _P.gatestrapspace + 1 * _P.gatestrapwidth),
        point.create(0, basey + 2 * _P.gatestrapspace + 2 * _P.gatestrapwidth)
    )
    cmos:add_area_anchor_bltr("Gupperbase",
        point.create(0, basey + 3 * _P.gatestrapspace + 2 * _P.gatestrapwidth),
        point.create(0, basey + 3 * _P.gatestrapspace + 3 * _P.gatestrapwidth)
    )

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
        elseif _P.pcontactpos[i] == "dummyouterpower" or _P.pcontactpos[i] == "dummyouter" then
            y = y - _P.psddummyouterheight
            yheight = _P.psddummyouterheight
        elseif _P.pcontactpos[i] == "dummyinner" then
            y = y - _P.pwidth
            yheight = _P.psddummyinnerheight
        elseif _P.pcontactpos[i] == "full" or _P.pcontactpos[i] == "fullpower" then
            y = y - _P.pwidth
            yheight = _P.pwidth
        elseif _P.pcontactpos[i] == "unused" then
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
            cmos:add_area_anchor_bltr(string.format("pSD%d", i - fingers - 2),
                point.create(x, y),
                point.create(x + _P.sdwidth, y + yheight)
            )
        end

        -- connect source/drain region to power bar
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "fullpower" or _P.pcontactpos[i] == "dummyouterpower" then
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
            elseif _P.ncontactpos[i] == "dummyouterpower" or _P.ncontactpos[i] == "dummyouter" then
                yheight = _P.nsddummyouterheight
            elseif _P.ncontactpos[i] == "dummyinner" then
                y = y + _P.nwidth - _P.nsddummyinnerheight
                yheight = _P.psddummyinnerheight
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
                cmos:add_area_anchor_bltr(string.format("nSD%d", i - fingers - 2),
                    point.create(x, y),
                    point.create(x + _P.sdwidth, y + yheight)
                )
            end

            -- connect source/drain region to power bar
            if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "fullpower" or _P.ncontactpos[i] == "dummyouterpower" then
                geometry.rectanglebltr(
                    cmos, generics.metal(1), 
                    point.create(x, y - _P.npowerspace),
                    point.create(x + _P.sdwidth, y)
                )
            end
        end
    end

    -- alignment box
    local ybottom = -_P.separation / 2 - _P.nwidth - _P.npowerspace - _P.powerwidth / 2
    local ytop =  _P.separation / 2 + _P.pwidth + _P.ppowerspace + _P.powerwidth / 2
    if _P.drawpmoswelltap then
        ytop = ytop + _P.powerwidth / 2 + _P.pmoswelltapspace + _P.pmoswelltapwidth / 2
    end
    if _P.drawnmoswelltap then
        ybottom = ybottom - _P.powerwidth / 2 - _P.nmoswelltapspace - _P.nmoswelltapwidth / 2
    end
    cmos:set_alignment_box(
        leftndrainarea.bl:copy():translate(0, -_P.npowerspace - _P.powerwidth),
        rightpdrainarea.tr:copy():translate(0, _P.ppowerspace + _P.powerwidth),
        leftndrainarea.br:copy():translate(0, -_P.npowerspace),
        rightpdrainarea.tl:copy():translate(0, _P.ppowerspace)
    )
end
