function parameters()
    pcell.add_parameters(
        { "oxidetype(Oxide Type)",                                                  1 },
        { "gatemarker(Gate Marker Index)",                                          1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",                                 1 },
        { "nvthtype(NMOS Threshold Voltage Type)",                                  1 },
        { "pmosflippedwell(PMOS Flipped Well) ",                                    false },
        { "nmosflippedwell(NMOS Flipped Well)",                                     false },
        { "pwidth(PMOS Finger Width)",                                              technology.get_dimension("Minimum Gate Width"), posvals = even() },
        { "nwidth(NMOS Finger Width)",                                              technology.get_dimension("Minimum Gate Width"), posvals = even() },
        { "separation(Separation Between Active Regions)",                          technology.get_dimension("Minimum Active Space") },
        { "separationautocalc(Automatically Calculate Separation)",                 false },
        { "ignoreseparationchecks(Ignore Separation Checks)",                       false },
        { "gatelength(Gate Length)",                                                technology.get_dimension("Minimum Gate Length"), argtype = "integer" },
        { "gatespace(Gate Spacing)",                                                technology.get_dimension("Minimum Gate XSpace"), argtype = "integer" },
        { "actext(Active Extension)",                                               0, },
        { "sdwidth(Source/Drain Metal Width)",                                      technology.get_dimension("Minimum M1 Width"), posvals = even() },
        { "innergatestraps(Number of Inner Gate Straps)",                           3 },
        { "gatestrapwidth(Gate Strap Metal Width)",                                 technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace(Gate Strap Metal Space)",                                 technology.get_dimension("Minimum M1 Space") },
        { "gatecontactsplitshift(Gate Contact Split Shift)",                        technology.get_dimension("Minimum M1 Width") + technology.get_dimension("Minimum M1 Space") },
        { "powerwidth(Power Rail Metal Width)",                                     technology.get_dimension("Minimum M1 Width") },
        { "npowerspace(NMOS Power Rail Space)",                                     technology.get_dimension("Minimum M1 Space"), posvals = positive() },
        { "ppowerspace(PMOS Power Rail Space)",                                     technology.get_dimension("Minimum M1 Space"), posvals = positive() },
        { "pgateext(pMOS Gate Extension)",                                          0 },
        { "ngateext(nMOS Gate Extension)",                                          0 },
        { "overwriteinnergateextensions",                                           false },
        { "innerpgateext(Inner pMOS Gate Extensions)",                              0 },
        { "innerngateext(Inner pMOS Gate Extensions)",                              0 },
        { "psdheight(PMOS Source/Drain Contact Height)",                            0 },
        { "nsdheight(NMOS Source/Drain Contact Height)",                            0 },
        { "psdpowerheight(PMOS Source/Drain Contact Height)",                       0 },
        { "nsdpowerheight(NMOS Source/Drain Contact Height)",                       0 },
        { "psddummyouterheight(PMOS Source/Drain Outer Dummy Contact Height)",      0 },
        { "nsddummyouterheight(NMOS Source/Drain Outer Dummy Contact Height)",      0 },
        { "psddummyinnerheight(PMOS Source/Drain Inner Dummy Contact Height)",      0 },
        { "nsddummyinnerheight(NMOS Source/Drain Inner Dummy Contact Height)",      0 },
        { "isoutputcontact",                                                        { } },
        { "outputmetal",                                                            1 },
        { "nsplitoutputvias",                                                       false },
        { "psplitoutputvias",                                                       false },
        { "outputwidth",                                                            technology.get_dimension("Minimum M1 Width") },
        { "noutputinlineoffset",                                                    0 },
        { "poutputinlineoffset",                                                    0 },
        { "cutwidth",                                                               0, follow = "gatelength" }, -- FIXME: allow expressions for follower parameters
        { "cutheight",                                                              technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace") },
        { "poutercutyshift",                                                        0 },
        { "noutercutyshift",                                                        0 },
        { "compact(Compact Layout)",                                                true },
        { "connectoutput",                                                          true },
        { "drawtransistors",                                                        true },
        { "drawactive",                                                             true },
        { "drawrails",                                                              true },
        { "drawgatecontacts",                                                       true },
        { "outergatestrapwidth(Outer Gate Strap Metal Width)",                      technology.get_dimension("Minimum M1 Width") },
        { "outergatestrapspace(Outer Gate Strap Metal Space)",                      technology.get_dimension("Minimum M1 Space") },
        { "outergateshift(Outer Gate Strap Metal Shift)",                           0 },
        { "gatecontactpos",                                                         { "center" }, argtype = "strtable" },
        { "gatenames",                                                              {}, argtype = "strtable" },
        { "shiftgatecontacts",                                                      0 },
        { "pcontactpos",                                                            {}, argtype = "strtable" },
        { "ncontactpos",                                                            {}, argtype = "strtable" },
        { "shiftpcontactsinner",                                                    0 },
        { "shiftpcontactsouter",                                                    0 },
        { "shiftncontactsinner",                                                    0 },
        { "shiftncontactsouter",                                                    0 },
        { "drawdummygatecontacts",                                                  true },
        { "drawdummyactivecontacts",                                                true },
        { "drawoutergatecut",                                                       false },
        { "drawgatecuteverywhere",                                                  false },
        { "drawdummygatecut",                                                       true },
        { "dummycontheight(Dummy Gate Contact Height)",                             technology.get_dimension("Minimum M1 Width") },
        { "dummycontshift(Dummy Gate Shift)",                                       0 },
        { "drawnmoswelltap(Draw nMOS Well Tap)",                                    false },
        { "nmoswelltapspace(nMOS Well Tap Space)",                                  technology.get_dimension("Minimum M1 Space") },
        { "nmoswelltapwidth(nMOS Well Tap Width)",                                  technology.get_dimension("Minimum M1 Width") },
        { "drawpmoswelltap(Draw pMOS Well Tap)",                                    false },
        { "pmoswelltapspace(pMOS Well Tap Space)",                                  technology.get_dimension("Minimum M1 Space") },
        { "pmoswelltapwidth(pMOS Well Tap Width)",                                  technology.get_dimension("Minimum M1 Width") },
        { "welltapcontinuouscontact(Well Tap Draw Continuous Contacts)",            true },
        { "welltapextendleft",                                                      0 },
        { "welltapextendright",                                                     0 },
        { "drawactivedummy",                                                        false },
        { "activedummywidth",                                                       0 },
        { "activedummyspace",                                                       0 },
        { "drawleftstopgate",                                                       false },
        { "drawrightstopgate",                                                      false },
        { "leftpolylines",                                                          {} },
        { "rightpolylines",                                                         {} },
        { "implantalignwithactive",                                                 false },
        { "implantalignleftwithactive",         false, follow = "implantalignwithactive" },
        { "implantalignrightwithactive",        false, follow = "implantalignwithactive" },
        { "implantaligntopwithactive",          false, follow = "implantalignwithactive" },
        { "implantalignbottomwithactive",       false, follow = "implantalignwithactive" },
        { "oxidetypealignwithactive",           false },
        { "oxidetypealignleftwithactive",       false, follow = "oxidetypealignwithactive" },
        { "oxidetypealignrightwithactive",      false, follow = "oxidetypealignwithactive" },
        { "oxidetypealigntopwithactive",        false, follow = "oxidetypealignwithactive" },
        { "oxidetypealignbottomwithactive",     false, follow = "oxidetypealignwithactive" },
        { "vthtypealignwithactive",             false },
        { "vthtypealignleftwithactive",         false, follow = "vthtypealignwithactive" },
        { "vthtypealignrightwithactive",        false, follow = "vthtypealignwithactive" },
        { "vthtypealigntopwithactive",          false, follow = "vthtypealignwithactive" },
        { "vthtypealignbottomwithactive",       false, follow = "vthtypealignwithactive" },
        { "extendalltop",                       0 },
        { "extendallbottom",                    0 },
        { "extendallleft",                      0 },
        { "extendallright",                     0 },
        { "extendoxidetypetop",                 0, follow = "extendalltop" },
        { "extendoxidetypebottom",              0, follow = "extendallbottom" },
        { "extendoxidetypeleft",                0, follow = "extendallleft" },
        { "extendoxidetyperight",               0, follow = "extendallright" },
        { "extendvthtypetop",                   0, follow = "extendalltop" },
        { "extendvthtypebottom",                0, follow = "extendallbottom" },
        { "extendvthtypeleft",                  0, follow = "extendallleft" },
        { "extendvthtyperight",                 0, follow = "extendallright" },
        { "extendimplanttop",                   0, follow = "extendalltop" },
        { "extendimplantbottom",                0, follow = "extendallbottom" },
        { "extendimplantleft",                  0, follow = "extendallleft" },
        { "extendimplantright",                 0, follow = "extendallright" },
        { "extendwelltop",                      0, follow = "extendalltop" },
        { "extendwellbottom",                   0, follow = "extendallbottom" },
        { "extendwellleft",                     0, follow = "extendallleft" },
        { "extendwellright",                    0, follow = "extendallright" },
        { "extendlvsmarkertop",                 0, follow = "extendalltop" },
        { "extendlvsmarkerbottom",              0, follow = "extendallbottom" },
        { "extendlvsmarkerleft",                0, follow = "extendallleft" },
        { "extendlvsmarkerright",               0, follow = "extendallright" },
        { "extendrotationmarkertop",            0, follow = "extendalltop" },
        { "extendrotationmarkerbottom",         0, follow = "extendallbottom" },
        { "extendrotationmarkerleft",           0, follow = "extendallleft" },
        { "extendrotationmarkerright",          0, follow = "extendallright" },
        { "extendanalogmarkertop",              0, follow = "extendalltop" },
        { "extendanalogmarkerbottom",           0, follow = "extendallbottom" },
        { "extendanalogmarkerleft",             0, follow = "extendallleft" },
        { "extendanalogmarkerright",            0, follow = "extendallright" },
        { "drawanalogmarker",                   false }
    )
end

function check(_P)
    -- check separation
    if not _P.ignoreseparationchecks then
        if (_P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace) > _P.separation then
            return false, string.format("can't fit all gate straps into the separation between nmos and pmos: %d > %d", _P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace, _P.separation)
        end
        if (_P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace) ~= _P.separation then
            return false, string.format("the separation between nmos and pmos must have the exact size to fit %d rows of gate contacts (%d vs. %d)", _P.innergatestraps, _P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace, _P.separation)
        end
    end
    -- check number of gate and source/drain contacts
    if #_P.pcontactpos ~= #_P.ncontactpos then
        return false, "the number of the source/drain contacts must be equal for nmos and pmos"
    end
    if (#_P.gatecontactpos + 1) ~= #_P.ncontactpos then
        return false, string.format("the number of the source/drain contacts must match the gate contacts + 1 (%d vs. %d)", #_P.gatecontactpos + 1, #_P.ncontactpos)
    end
    -- check if gate cut width and gatelength match
    if (_P.gatelength % 2) ~= (_P.cutwidth % 2) then
        return false, "gatelength and cutwidth must both be either odd or even"
    end
    -- check if gate cut height and separation match
    if (_P.separation % 2) ~= (_P.cutheight % 2) then
        return false, "separation and cutheight must both be either odd or even"
    end
    -- check if gate names are valid
    if (#_P.gatenames > 0) and (#_P.gatenames ~= #_P.gatecontactpos) then
        moderror(string.format("basic/cmos: number of entries in 'gatenames' must match 'gatecontactpos' (got %d, must be %d)", #_P.gatenames, #_P.gatecontactpos))
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

    local leftndrainarea, rightndrainarea
    local leftpdrainarea, rightpdrainarea
    local leftnmoswell, rightnmoswell
    local leftpmoswell, rightpmoswell
    local leftnmosimplant, rightnmosimplant
    local leftpmosimplant, rightpmosimplant
    local firstgate
    if _P.drawtransistors then
        -- common transistor options
        local baseopt = {
            gatelength = _P.gatelength,
            gatespace = _P.gatespace,
            actext = _P.actext,
            sdwidth = _P.sdwidth,
            oxidetype = _P.oxidetype,
            gatemarker = _P.gatemarker,
            drawactive = _P.drawactive,
            topgatecutheight = _P.cutheight,
            botgatecutheight = _P.cutheight,
            topgatecutleftext = (_P.cutwidth - _P.gatelength) / 2,
            topgatecutrightext = (_P.cutwidth - _P.gatelength) / 2,
            botgatecutleftext = (_P.cutwidth - _P.gatelength) / 2,
            botgatecutrightext = (_P.cutwidth - _P.gatelength) / 2,
            topgatewidth = _P.gatestrapwidth,
            botgatewidth = _P.gatestrapwidth,
            drawanalogmarker = _P.drawanalogmarker,
        }

        -- pmos
        local popt = util.add_options(baseopt, {
            channeltype = "pmos",
            vthtype = _P.pvthtype,
            flippedwell = _P.pmosflippedwell,
            fingerwidth = _P.pwidth,
            gbotext = _P.overwriteinnergateextensions and _P.innerpgateext or _P.separation / 2,
            gtopext = _P.pgateext,
            topgatecutspace = -_P.powerwidth / 2,
            drawtopactivedummy = _P.drawactivedummy,
            topactivedummywidth = _P.activedummywidth,
            topactivedummyspace = _P.activedummyspace,
            botgatecutspace = _P.separation / 2 - _P.cutheight / 2,
            extendoxidetypetop = _P.extendoxidetypetop,
            extendoxidetypebottom = _P.separation / 2,
            extendoxidetypeleft = _P.extendoxidetypeleft,
            extendoxidetyperight = _P.extendoxidetyperight,
            extendvthtypetop = _P.extendvthtypetop,
            extendvthtypebottom = _P.separation / 2,
            extendvthtypeleft = _P.extendvthtypeleft,
            extendvthtyperight = _P.extendvthtyperight,
            extendimplanttop = _P.extendimplanttop,
            extendimplantbottom = _P.separation / 2,
            extendimplantleft = _P.extendimplantleft,
            extendimplantright = _P.extendimplantright,
            extendwelltop = _P.extendwelltop,
            extendwellbottom = _P.separation / 2,
            extendwellleft = _P.extendwellleft,
            extendwellright = _P.extendwellright,
            extendlvsmarkertop = _P.extendlvsmarkertop,
            extendlvsmarkerbottom = _P.separation / 2,
            extendlvsmarkerleft = _P.extendlvsmarkerleft,
            extendlvsmarkerright = _P.extendlvsmarkerright,
            extendrotationmarkertop = _P.extendrotationmarkertop,
            extendrotationmarkerbottom = _P.separation / 2,
            extendrotationmarkerleft = _P.extendrotationmarkerleft,
            extendrotationmarkerright = _P.extendrotationmarkerright,
            extendanalogmarkertop = _P.extendanalogmarkertop,
            extendanalogmarkerbottom = _P.separation / 2,
            extendanalogmarkerleft = _P.extendanalogmarkerleft,
            extendanalogmarkerright = _P.extendanalogmarkerright,
            connectsourceinlineoffset = _P.poutputinlineoffset,
            implantalignleftwithactive = _P.implantalignleftwithactive,
            implantalignrightwithactive = _P.implantalignrightwithactive,
            implantaligntopwithactive = _P.implantaligntopwithactive,
            implantalignbottomwithactive = true,
            oxidetypealignleftwithactive = _P.oxidetypealignleftwithactive,
            oxidetypealignrightwithactive = _P.oxidetypealignrightwithactive,
            oxidetypealigntopwithactive = _P.oxidetypealigntopwithactive,
            oxidetypealignbottomwithactive = true,
            vthtypealignleftwithactive = _P.vthtypealignleftwithactive,
            vthtypealignrightwithactive = _P.vthtypealignrightwithactive,
            vthtypealigntopwithactive = _P.vthtypealigntopwithactive,
            vthtypealignbottomwithactive = true,
        })
        local nopt = util.add_options(baseopt, {
            channeltype = "nmos",
            vthtype = _P.nvthtype,
            flippedwell = _P.nmosflippedwell,
            fingerwidth = _P.nwidth,
            gtopext = _P.overwriteinnergateextensions and _P.innerngateext or _P.separation / 2,
            gbotext = _P.ngateext,
            botgatecutspace = _P.powerwidth / 2,
            drawbotgatecut = false,
            drawbottomactivedummy = _P.drawactivedummy,
            bottomactivedummywidth = _P.activedummywidth,
            bottomactivedummyspace = _P.activedummyspace,
            topgatecutspace = _P.separation / 2 - _P.cutheight / 2,
            extendoxidetypetop = _P.separation / 2,
            extendoxidetypebottom = _P.extendoxidetypebottom,
            extendoxidetypeleft = _P.extendoxidetypeleft,
            extendoxidetyperight = _P.extendoxidetyperight,
            extendvthtypetop = _P.separation / 2,
            extendvthtypebottom = _P.extendvthtypebottom,
            extendvthtypeleft = _P.extendvthtypeleft,
            extendvthtyperight = _P.extendvthtyperight,
            extendimplanttop = _P.separation / 2,
            extendimplantbottom = _P.extendimplantbottom,
            extendimplantleft = _P.extendimplantleft,
            extendimplantright = _P.extendimplantright,
            extendwelltop = _P.separation / 2,
            extendwellbottom = _P.extendwellbottom,
            extendwellleft = _P.extendwellleft,
            extendwellright = _P.extendwellright,
            extendlvsmarkertop = _P.separation / 2,
            extendlvsmarkerbottom = _P.extendlvsmarkerbottom,
            extendlvsmarkerleft = _P.extendlvsmarkerleft,
            extendlvsmarkerright = _P.extendlvsmarkerright,
            extendrotationmarkertop = _P.separation / 2,
            extendrotationmarkerbottom = _P.extendrotationmarkerbottom,
            extendrotationmarkerleft = _P.extendrotationmarkerleft,
            extendrotationmarkerright = _P.extendrotationmarkerright,
            extendanalogmarkertop = _P.separation / 2,
            extendanalogmarkerbottom = _P.extendanalogmarkerbottom,
            extendanalogmarkerleft = _P.extendanalogmarkerleft,
            extendanalogmarkerright = _P.extendanalogmarkerright,
            connectsourceinlineoffset = _P.noutputinlineoffset,
            implantalignleftwithactive = _P.implantalignleftwithactive,
            implantalignrightwithactive = _P.implantalignrightwithactive,
            implantaligntopwithactive = true,
            implantalignbottomwithactive = _P.implantalignbottomwithactive,
            oxidetypealignleftwithactive = _P.oxidetypealignleftwithactive,
            oxidetypealignrightwithactive = _P.oxidetypealignrightwithactive,
            oxidetypealigntopwithactive = true,
            oxidetypealignbottomwithactive = _P.oxidetypealignbottomwithactive,
            vthtypealignleftwithactive = _P.vthtypealignleftwithactive,
            vthtypealignrightwithactive = _P.vthtypealignrightwithactive,
            vthtypealigntopwithactive = true,
            vthtypealignbottomwithactive = _P.vthtypealignbottomwithactive,
        })
        -- main
        for i = 1, fingers do
            local nopt_current = util.clone_shallow(nopt)
            local popt_current = util.clone_shallow(popt)
            if i == 1 then
                nopt_current.leftpolylines = _P.leftpolylines
                popt_current.leftpolylines = _P.leftpolylines
                if _P.drawleftstopgate then
                    nopt_current.drawleftstopgate = true
                    nopt_current.drawstopgatetopgatecut = true
                    nopt_current.drawstopgatebotgatecut = false
                    popt_current.drawleftstopgate = true
                    popt_current.drawstopgatetopgatecut = false
                    popt_current.drawstopgatebotgatecut = true
                end
            end
            if i == fingers then
                nopt_current.rightpolylines = _P.rightpolylines
                popt_current.rightpolylines = _P.rightpolylines
                if _P.drawrightstopgate then
                    nopt_current.drawrightstopgate = true
                    nopt_current.drawstopgatetopgatecut = true
                    nopt_current.drawstopgatebotgatecut = false
                    popt_current.drawrightstopgate = true
                    popt_current.drawstopgatetopgatecut = false
                    popt_current.drawstopgatebotgatecut = true
                end
            end
            -- gate contact positions
            local ngatey = (_P.separation - _P.gatestrapwidth) / 2 + _P.shiftgatecontacts
            local pgatey = (_P.separation - _P.gatestrapwidth) / 2 + _P.shiftgatecontacts
            local gateanchors = {}
            local evenoddgatestrapshift = (_P.innergatestraps % 2 == 0) and (_P.gatestrapwidth + _P.gatestrapspace) / 2 or 0
            if _P.gatecontactpos[i] == "center" then
                if _P.innergatestraps % 2 == 0 then
                    moderror("requested 'center' gate contact position, but the number of inner gate straps is even. The center gate strap only exists with an odd number of inner gate straps")
                end
                nopt_current.drawtopgate = true
                ngatey = ngatey + 0
                table.insert(gateanchors, {
                    nmos = {
                        source = "topgatestrap",
                        target = string.format("G%d", i)
                    }
                })
            elseif string.match(_P.gatecontactpos[i], "upper") then
                local index = string.match(_P.gatecontactpos[i], "upper(%d+)")
                if not index then
                    moderror(string.format("bad gate contact position format: [%d] = '%s' (should be 'upperNUMBER')", i, _P.gatecontactpos[i]))
                end
                index = tonumber(index)
                if index > math.floor(_P.innergatestraps / 2) then
                    moderror(string.format("upper gate contact is outside of inner gate strap range: gate strap %d requested, but only %d is/are available", index, math.floor(_P.innergatestraps / 2)))
                end
                nopt_current.drawtopgate = true
                ngatey = ngatey + index * (_P.gatestrapwidth + _P.gatestrapspace) - evenoddgatestrapshift
                table.insert(gateanchors, {
                    nmos = {
                        source = "topgatestrap",
                        target = string.format("G%d", i)
                    }
                })
            elseif string.match(_P.gatecontactpos[i], "lower") then
                local index = string.match(_P.gatecontactpos[i], "lower(%d+)")
                if not index then
                    moderror(string.format("bad gate contact position format: [%d] = '%s' (should be 'lowerNUMBER')", i, _P.gatecontactpos[i]))
                end
                index = tonumber(index)
                if index > math.floor(_P.innergatestraps / 2) then
                    moderror(string.format("lower gate contact is outside of inner gate strap range: gate strap %d requested, but only %d is/are available", index, math.floor(_P.innergatestraps / 2)))
                end
                nopt_current.drawtopgate = true
                ngatey = ngatey - index * (_P.gatestrapwidth + _P.gatestrapspace) + evenoddgatestrapshift
                table.insert(gateanchors, {
                    nmos = {
                        source = "topgatestrap",
                        target = string.format("G%d", i)
                    }
                })
            elseif _P.gatecontactpos[i] == "split" then
                -- FIXME: could add support for splitN
                nopt_current.drawtopgate = true
                popt_current.drawbotgate = true
                ngatey = ngatey - 1 * (_P.gatestrapwidth + _P.gatestrapspace) + evenoddgatestrapshift
                pgatey = pgatey - 1 * (_P.gatestrapwidth + _P.gatestrapspace) + evenoddgatestrapshift
                nopt_current.drawtopgatecut = true
                table.insert(gateanchors, {
                    nmos = {
                        source = "topgatestrap",
                        target = string.format("Glower%d", i)
                    },
                    pmos = {
                        source = "botgatestrap",
                        target = string.format("Gupper%d", i)
                    }
                })
            elseif _P.gatecontactpos[i] == "dummy" then
                nopt_current.drawbotgate = true
                nopt_current.botgatewidth = _P.dummycontheight
                popt_current.drawtopgate = true
                popt_current.topgatewidth = _P.dummycontheight
                nopt_current.drawtopgatecut = _P.drawdummygatecut
                ngatey = _P.npowerspace
                pgatey = _P.ppowerspace
                table.insert(gateanchors, {
                    nmos = {
                        source = "botgatestrap",
                        target = string.format("G%d", i)
                    }
                })
            elseif _P.gatecontactpos[i] == "outer" then
                nopt_current.drawbotgate = true
                popt_current.drawtopgate = true
                nopt_current.drawtopgatecut = true
                ngatey = _P.outergatestrapspace
                pgatey = _P.outergatestrapspace
                table.insert(gateanchors, {
                    nmos = {
                        source = "botgatestrap",
                        target = string.format("Gn%d", i)
                    },
                    pmos = {
                        source = "topgatestrap",
                        target = string.format("Gp%d", i)
                    }
                })
            elseif _P.gatecontactpos[i] == "unused" then
                -- do nothing
            else
                moderror(string.format("unknown gate contact position: [%d] = '%s'", i, _P.gatecontactpos[i]))
            end
            nopt_current.topgatespace = ngatey
            nopt_current.botgatespace = ngatey
            popt_current.topgatespace = pgatey
            popt_current.botgatespace = pgatey
            local pcontactheight = (_P.psdheight > 0) and _P.psdheight or aux.make_even(_P.pwidth / 2)
            local ncontactheight = (_P.nsdheight > 0) and _P.nsdheight or aux.make_even(_P.nwidth / 2)
            local pcontactpowerheight = (_P.psdpowerheight > 0) and _P.psdpowerheight or aux.make_even(_P.pwidth / 2)
            local ncontactpowerheight = (_P.nsdpowerheight > 0) and _P.nsdpowerheight or aux.make_even(_P.nwidth / 2)
            local pcontactinnerdummyheight = (_P.psddummyinnerheight > 0) and _P.psddummyouterheight or aux.make_even(_P.pwidth / 2)
            local ncontactinnerdummyheight = (_P.nsddummyinnerheight > 0) and _P.nsddummyouterheight or aux.make_even(_P.nwidth / 2)
            local pcontactouterdummyheight = (_P.psddummyouterheight > 0) and _P.psddummyouterheight or aux.make_even(_P.pwidth / 2)
            local ncontactouterdummyheight = (_P.nsddummyouterheight > 0) and _P.nsddummyouterheight or aux.make_even(_P.nwidth / 2)
            -- source/drain contact positions (nmos)
            local excludeleftncontact = false
            local excluderightncontact = true
            if _P.ncontactpos[i] == "power" then
                nopt_current.sourcesize = ncontactpowerheight
                nopt_current.sourcealign = "bottom"
            elseif _P.ncontactpos[i] == "outer" then
                nopt_current.sourcesize = ncontactheight
                nopt_current.sourcealign = "bottom"
            elseif _P.ncontactpos[i] == "inner" then
                nopt_current.sourcesize = ncontactheight
                nopt_current.sourcealign = "top"
            elseif _P.ncontactpos[i] == "dummyouterpower" or _P.ncontactpos[i] == "dummyouter" then
                nopt_current.sourcesize = ncontactouterdummyheight
                nopt_current.sourcealign = "bottom"
            elseif _P.ncontactpos[i] == "dummyinner" then
                nopt_current.sourcesize = ncontactinnerdummyheight
                nopt_current.sourcealign = "top"
            elseif _P.ncontactpos[i] == "full" or _P.ncontactpos[i] == "fullpower" then
                -- defaults apply
            elseif not _P.ncontactpos[i] or _P.ncontactpos[i] == "unused" then
                excludeleftncontact = true
            else
                moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'\nshould be one of 'power', 'outer', 'inner', 'dummyouterpower', 'dummyinner', 'full' or 'unused'", i, _P.ncontactpos[i]))
            end
            -- extra handling for last source/drain contact
            if i == fingers then
                excluderightncontact = false
                if _P.ncontactpos[i + 1] == "power" then
                    nopt_current.drainsize = ncontactpowerheight
                    nopt_current.drainalign = "bottom"
                elseif _P.ncontactpos[i + 1] == "outer" then
                    nopt_current.drainsize = ncontactheight
                    nopt_current.drainalign = "bottom"
                elseif _P.ncontactpos[i + 1] == "inner" then
                    nopt_current.drainsize = ncontactheight
                    nopt_current.drainalign = "top"
                elseif _P.ncontactpos[i + 1] == "dummyouterpower" or _P.ncontactpos[i + 1] == "dummyouter" then
                    nopt_current.drainsize = ncontactouterdummyheight
                    nopt_current.drainalign = "bottom"
                elseif _P.ncontactpos[i + 1] == "dummyinner" then
                    nopt_current.drainsize = ncontactinnerdummyheight
                    nopt_current.drainalign = "top"
                elseif _P.ncontactpos[i + 1] == "full" or _P.ncontactpos[i + 1] == "fullpower" then
                    -- defaults apply
                elseif not _P.ncontactpos[i + 1] or _P.ncontactpos[i + 1] == "unused" then
                    excluderightncontact = true
                else
                    moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'\nshould be one of 'power', 'outer', 'inner', 'dummyouterpower', 'dummyinner', 'full' or 'unused'", i + 1, _P.ncontactpos[i]))
                end
            end
            nopt_current.excludesourcedraincontacts = {}
            if excludeleftncontact then
                table.insert(nopt_current.excludesourcedraincontacts, 1)
            end
            if excluderightncontact then
                table.insert(nopt_current.excludesourcedraincontacts, 2)
            end
            -- source/drain contact positions (pmos)
            local excludeleftpcontact = false
            local excluderightpcontact = true
            if _P.pcontactpos[i] == "power" then
                popt_current.sourcesize = pcontactpowerheight
                popt_current.sourcealign = "top"
            elseif _P.pcontactpos[i] == "outer" then
                popt_current.sourcesize = pcontactheight
                popt_current.sourcealign = "top"
            elseif _P.pcontactpos[i] == "inner" then
                popt_current.sourcesize = pcontactheight
                popt_current.sourcealign = "bottom"
            elseif _P.pcontactpos[i] == "dummyouterpower" or _P.pcontactpos[i] == "dummyouter" then
                popt_current.sourcesize = pcontactouterdummyheight
                popt_current.sourcealign = "top"
            elseif _P.pcontactpos[i] == "dummyinner" then
                popt_current.sourcesize = pcontactinnerdummyheight
                popt_current.sourcealign = "bottom"
            elseif _P.pcontactpos[i] == "full" or _P.pcontactpos[i] == "fullpower" then
                -- defaults apply
            elseif not _P.pcontactpos[i] or _P.pcontactpos[i] == "unused" then
                excludeleftpcontact = true
            else
                moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'\nshould be one of 'power', 'outer', 'inner', 'dummyouterpower', 'dummyinner', 'full' or 'unused'", i, _P.pcontactpos[i]))
            end
            -- extra handling for last source/drain contact
            if i == fingers then
                excluderightpcontact = false
                if _P.pcontactpos[i + 1] == "power" then
                    popt_current.drainsize = pcontactpowerheight
                    popt_current.drainalign = "top"
                elseif _P.pcontactpos[i + 1] == "outer" then
                    popt_current.drainsize = pcontactheight
                    popt_current.drainalign = "top"
                elseif _P.pcontactpos[i + 1] == "inner" then
                    popt_current.drainsize = pcontactheight
                    popt_current.drainalign = "bottom"
                elseif _P.pcontactpos[i + 1] == "dummyouterpower" or _P.pcontactpos[i + 1] == "dummyouter" then
                    popt_current.drainsize = pcontactouterdummyheight
                    popt_current.drainalign = "top"
                elseif _P.pcontactpos[i + 1] == "dummyinner" then
                    popt_current.drainsize = pcontactinnerdummyheight
                    popt_current.drainalign = "bottom"
                elseif _P.pcontactpos[i + 1] == "full" or _P.pcontactpos[i + 1] == "fullpower" then
                    -- defaults apply
                elseif not _P.pcontactpos[i + 1] or _P.pcontactpos[i + 1] == "unused" then
                    excluderightpcontact = true
                else
                    moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'\nshould be one of 'power', 'outer', 'inner', 'dummyouterpower', 'dummyinner', 'full' or 'unused'", i + 1, _P.pcontactpos[i]))
                end
            end
            popt_current.excludesourcedraincontacts = {}
            if excludeleftpcontact then
                table.insert(popt_current.excludesourcedraincontacts, 1)
            end
            if excluderightpcontact then
                table.insert(popt_current.excludesourcedraincontacts, 2)
            end
            -- output drain/source vias
            if util.any_of(i, _P.isoutputcontact) then
                nopt_current.sourcemetal = _P.outputmetal
                nopt_current.splitsourcevias = _P.nsplitoutputvias
                nopt_current.connectsourcewidth = _P.outputwidth
                popt_current.sourcemetal = _P.outputmetal
                popt_current.splitsourcevias = _P.psplitoutputvias
                popt_current.connectsourcewidth = _P.outputwidth
            end
            local shift = (i - 1) * gatepitch
            local nfet = pcell.create_layout("basic/mosfet", "nfet", nopt_current)
            nfet:translate(shift, 0)
            cmos:merge_into(nfet)
            local pfet = pcell.create_layout("basic/mosfet", "pfet", popt_current)
            pfet:abut_area_anchor_top(
                "active",
                nfet,
                "active"
            )
            pfet:translate(shift, _P.separation)
            cmos:merge_into(pfet)
            -- connect source/drain region to power bar
            if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "fullpower" or _P.ncontactpos[i] == "dummyouterpower" then
                geometry.rectanglebltr(
                    cmos, generics.metal(1), 
                    point.create(nfet:get_area_anchor("sourcedrain1").l, nfet:get_area_anchor("sourcedrain1").b - _P.npowerspace),
                    point.create(nfet:get_area_anchor("sourcedrain1").r, nfet:get_area_anchor("sourcedrain1").b)
                )
            end
            if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "fullpower" or _P.pcontactpos[i] == "dummyouterpower" then
                geometry.rectanglebltr(
                    cmos, generics.metal(1), 
                    point.create(pfet:get_area_anchor("sourcedrain1").l, pfet:get_area_anchor("sourcedrain1").t),
                    point.create(pfet:get_area_anchor("sourcedrain1").r, pfet:get_area_anchor("sourcedrain1").t + _P.ppowerspace)
                )
            end
            if i == fingers then
                if _P.ncontactpos[i + 1] == "power" or _P.ncontactpos[i + 1] == "fullpower" or _P.ncontactpos[i + 1] == "dummyouterpower" then
                    geometry.rectanglebltr(
                        cmos, generics.metal(1), 
                        point.create(nfet:get_area_anchor("sourcedrain2").l, nfet:get_area_anchor("sourcedrain2").b - _P.npowerspace),
                        point.create(nfet:get_area_anchor("sourcedrain2").r, nfet:get_area_anchor("sourcedrain2").b)
                    )
                end
                if _P.pcontactpos[i + 1] == "power" or _P.pcontactpos[i + 1] == "fullpower" or _P.pcontactpos[i + 1] == "dummyouterpower" then
                    geometry.rectanglebltr(
                        cmos, generics.metal(1), 
                        point.create(pfet:get_area_anchor("sourcedrain2").l, pfet:get_area_anchor("sourcedrain2").t),
                        point.create(pfet:get_area_anchor("sourcedrain2").r, pfet:get_area_anchor("sourcedrain2").t + _P.ppowerspace)
                    )
                end
            end
            -- gate anchors
            for _, entry in ipairs(gateanchors) do
                if entry.nmos then
                    cmos:inherit_area_anchor_as(nfet, entry.nmos.source, entry.nmos.target)
                end
                if entry.pmos then
                    cmos:inherit_area_anchor_as(pfet, entry.pmos.source, entry.pmos.target)
                end
            end
            -- gate x-anchors
            cmos:add_area_anchor_bltr(
                string.format("Gbase%d", i),
                nfet:get_area_anchor("gate1").bl,
                pfet:get_area_anchor("gate1").tr
            )
                    
            -- source/drain anchors
            cmos:inherit_area_anchor_as(nfet, "sourcedrain1", string.format("nSD%d", i))
            cmos:inherit_area_anchor_as(nfet, "sourcedrain1", string.format("nSD%d", i - fingers - 2))
            cmos:inherit_area_anchor_as(pfet, "sourcedrain1", string.format("pSD%d", i))
            cmos:inherit_area_anchor_as(pfet, "sourcedrain1", string.format("pSD%d", i - fingers - 2))
            if i == fingers then
                cmos:inherit_area_anchor_as(nfet, "sourcedrain2", string.format("nSD%d", i + 1))
                cmos:inherit_area_anchor_as(nfet, "sourcedrain2", string.format("nSD%d", i + 1 - fingers - 2))
                cmos:inherit_area_anchor_as(pfet, "sourcedrain2", string.format("pSD%d", i + 1))
                cmos:inherit_area_anchor_as(pfet, "sourcedrain2", string.format("pSD%d", i + 1 - fingers - 2))
            end
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
        leftnmosimplant.bl,
        rightnmosimplant.tr
    )
    cmos:add_area_anchor_bltr("pmos_implant",
        leftpmosimplant.bl,
        rightpmosimplant.tr
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
