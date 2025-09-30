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
        { "powerwidth(Power Rail Width)",                                           technology.get_dimension("Minimum M1 Width"), posvals = positive() },
        { "powerspace(Power Rail Space)",                                           technology.get_dimension("Minimum M1 Width"),  },
        { "npowerspace(NMOS Power Rail Space)",                                     technology.get_dimension("Minimum M1 Space"), follow = "powerspace" },
        { "ppowerspace(PMOS Power Rail Space)",                                     technology.get_dimension("Minimum M1 Space"), follow = "powerspace" },
        { "powerrailleftrightextension(Power Rail Left/Right Extension)",           0 },
        { "powerrailleftextension(Power Rail Left Extension)",                      0, follow = "powerrailleftrightextension" },
        { "powerrailrightextension(Power Rail Right Extension)",                    0, follow = "powerrailleftrightextension" },
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
        { "drawnmoslowerwelltap(Draw nMOS Lower Well Tap)",                         false },
        { "drawnmosleftwelltap(Draw nMOS Left Well Tap)",                           false },
        { "drawnmosrightwelltap(Draw nMOS Right Well Tap)",                         false },
        { "nmoswelltapspace(nMOS Well Tap Space)",                                  technology.get_dimension("Minimum M1 Space") },
        { "nmoswelltapwidth(nMOS Well Tap Width)",                                  technology.get_dimension("Minimum M1 Width") },
        { "nmoswelltapextension(nMOS Well Tap Extension)",                          0 },
        { "nmoswelltapimplantleftextension",                                        0 },
        { "nmoswelltapimplantrightextension",                                       0 },
        { "nmoswelltapimplanttopextension",                                         0 },
        { "nmoswelltapimplantbottomextension",                                      0 },
        { "nmoswelltapsoiopenleftextension",                                        0 },
        { "nmoswelltapsoiopenrightextension",                                       0 },
        { "nmoswelltapsoiopentopextension",                                         0 },
        { "nmoswelltapsoiopenbottomextension",                                      0 },
        { "nmoswelltapwellleftextension",                                           0 },
        { "nmoswelltapwellrightextension",                                          0 },
        { "nmoswelltapwelltopextension",                                            0 },
        { "nmoswelltapwellbottomextension",                                         0 },
        { "drawpmosupperwelltap(Draw pMOS Upper Well Tap)",                         false },
        { "drawpmosleftwelltap(Draw pMOS Left Well Tap)",                           false },
        { "drawpmosrightwelltap(Draw pMOS Right Well Tap)",                         false },
        { "pmoswelltapspace(pMOS Well Tap Space)",                                  technology.get_dimension("Minimum M1 Space") },
        { "pmoswelltapwidth(pMOS Well Tap Width)",                                  technology.get_dimension("Minimum M1 Width") },
        { "pmoswelltapextension(pMOS Well Tap Extension)",                          0 },
        { "pmoswelltapimplantleftextension",                                        0 },
        { "pmoswelltapimplantrightextension",                                       0 },
        { "pmoswelltapimplanttopextension",                                         0 },
        { "pmoswelltapimplantbottomextension",                                      0 },
        { "pmoswelltapsoiopenleftextension",                                        0 },
        { "pmoswelltapsoiopenrightextension",                                       0 },
        { "pmoswelltapsoiopentopextension",                                         0 },
        { "pmoswelltapsoiopenbottomextension",                                      0 },
        { "pmoswelltapwellleftextension",                                           0 },
        { "pmoswelltapwellrightextension",                                          0 },
        { "pmoswelltapwelltopextension",                                            0 },
        { "pmoswelltapwellbottomextension",                                         0 },
        { "welltapcontinuouscontact(Well Tap Draw Continuous Contacts)",            true },
        { "drawactivedummy",                                                        false },
        { "activedummywidth",                                                       0 },
        { "activedummyspace",                                                       0 },
        { "drawleftstopgate",                                                       false },
        { "drawrightstopgate",                                                      false },
        { "excludestopgatesfromcutregions",                                         true },
        { "endleftwithgate",                                                        false, follow = "drawleftstopgate" },
        { "leftendgatelength",                                                      0, follow = "gatelength" },
        { "leftendgatespace",                                                       0, follow = "gatespace" },
        { "endrightwithgate",                                                       false, follow = "drawrightstopgate" },
        { "rightendgatelength",                                                     0, follow = "gatelength" },
        { "rightendgatespace",                                                      0, follow = "gatespace" },
        { "leftpolylines",                                                          {} },
        { "rightpolylines",                                                         {} },
        { "implantalignwithactive",                                                 false },
        { "implantalignleftwithactive",         false, follow = "implantalignwithactive" },
        { "implantalignrightwithactive",        false, follow = "implantalignwithactive" },
        { "implantaligntopwithactive",          false, follow = "implantalignwithactive" },
        { "implantalignbottomwithactive",       false, follow = "implantalignwithactive" },
        { "wellalignwithactive",                false },
        { "wellalignleftwithactive",            false, follow = "wellalignwithactive" },
        { "wellalignrightwithactive",           false, follow = "wellalignwithactive" },
        { "wellaligntopwithactive",             false, follow = "wellalignwithactive" },
        { "wellalignbottomwithactive",          false, follow = "wellalignwithactive" },
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

function anchors()
    pcell.add_area_anchor_documentation(
        "gate%d",
        "area of nth gate"
    )
    pcell.add_area_anchor_documentation(
        "Gcenterase",
        "y-coordinates (bottom/top) of the 'center gate contact regions. The x-valus are only dummy values"
    )
    pcell.add_area_anchor_documentation(
        "Glowerbase",
        "y-coordinates (bottom/top) of the 'lower' gate contact regions. The x-valus are only dummy values"
    )
    pcell.add_area_anchor_documentation(
        "Gupperbase",
        "y-coordinates (bottom/top) of the 'upper' gate contact regions. The x-valus are only dummy values"
    )
    pcell.add_area_anchor_documentation(
        "PRp",
        "area of upper/pMOS ('vdd') power rail"
    )
    pcell.add_area_anchor_documentation(
        "PRn",
        "area of lower/nMOS ('vss') power rail"
    )
    pcell.add_area_anchor_documentation(
        "nmos_active",
        "area of nMOS active region"
    )
    pcell.add_area_anchor_documentation(
        "pmos_active",
        "area of pMOS active region"
    )
    pcell.add_area_anchor_documentation(
        "nmos_well",
        "area of nMOS well region"
    )
    pcell.add_area_anchor_documentation(
        "pmos_well",
        "area of pMOS well region"
    )
    pcell.add_area_anchor_documentation(
        "nmos_implant",
        "area of nMOS implant region"
    )
    pcell.add_area_anchor_documentation(
        "pmos_implant",
        "area of pMOS implant region"
    )
end

function check(_P)
    -- check separation
    if not (_P.ignoreseparationchecks or _P.separationautocalc) then
        if (_P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace) > _P.separation then
            return false, string.format("can't fit all gate straps into the separation between nmos and pmos: %d > %d", _P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace, _P.separation)
        end
        if (_P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace) ~= _P.separation then
            return false, string.format("the separation between nmos and pmos must have the exact size to fit %d rows of gate contacts (%d vs. %d)", _P.innergatestraps, _P.separation, _P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace)
        end
    end
    -- check number of gate and source/drain contacts
    if #_P.pcontactpos ~= #_P.ncontactpos then
        return false, "the number of the source/drain contacts must be equal for nmos and pmos"
    end
    if (#_P.gatecontactpos + 1) ~= #_P.ncontactpos then
        return false, string.format("the number of the source/drain contacts must match the gate contacts + 1 (%d vs. %d)", #_P.ncontactpos, #_P.gatecontactpos + 1)
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

    -- inner separation
    local separation = _P.separation
    if _P.separationautocalc then
        separation = _P.innergatestraps * _P.gatestrapwidth + (_P.innergatestraps + 1) * _P.gatestrapspace
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
            extendoxidetypeleft = _P.extendoxidetypeleft,
            extendoxidetyperight = _P.extendoxidetyperight,
            extendvthtypeleft = _P.extendvthtypeleft,
            extendvthtyperight = _P.extendvthtyperight,
            extendimplantleft = _P.extendimplantleft,
            extendimplantright = _P.extendimplantright,
            extendwellleft = _P.extendwellleft,
            extendwellright = _P.extendwellright,
            extendlvsmarkerleft = _P.extendlvsmarkerleft,
            extendlvsmarkerright = _P.extendlvsmarkerright,
            extendrotationmarkerleft = _P.extendrotationmarkerleft,
            extendrotationmarkerright = _P.extendrotationmarkerright,
            extendanalogmarkerleft = _P.extendanalogmarkerleft,
            extendanalogmarkerright = _P.extendanalogmarkerright,
            excludestopgatesfromcutregions = _P.excludestopgatesfromcutregions,
        }

        -- pmos
        local popt = util.add_options(baseopt, {
            channeltype = "pmos",
            vthtype = _P.pvthtype,
            flippedwell = _P.pmosflippedwell,
            fingerwidth = _P.pwidth,
            gbotext = _P.overwriteinnergateextensions and _P.innerpgateext or separation / 2,
            gtopext = _P.pgateext,
            topgatecutspace = _P.ppowerspace + _P.powerwidth / 2 - _P.cutheight / 2,
            drawtopactivedummy = _P.drawactivedummy,
            topactivedummywidth = _P.activedummywidth,
            topactivedummyspace = _P.activedummyspace,
            botgatecutspace = separation / 2 - _P.cutheight / 2,
            extendoxidetypetop = _P.extendoxidetypetop,
            extendoxidetypebottom = separation / 2,
            extendvthtypetop = _P.extendvthtypetop,
            extendvthtypebottom = separation / 2,
            extendimplanttop = _P.extendimplanttop,
            extendimplantbottom = separation / 2,
            extendwelltop = _P.extendwelltop,
            extendwellbottom = separation / 2,
            extendlvsmarkertop = _P.extendlvsmarkertop,
            extendlvsmarkerbottom = separation / 2,
            extendrotationmarkertop = _P.extendrotationmarkertop,
            extendrotationmarkerbottom = separation / 2,
            extendanalogmarkertop = _P.extendanalogmarkertop,
            extendanalogmarkerbottom = separation / 2,
            connectsourceinlineoffset = _P.poutputinlineoffset,
            implantalignleftwithactive = _P.implantalignleftwithactive,
            implantalignrightwithactive = _P.implantalignrightwithactive,
            implantaligntopwithactive = _P.implantaligntopwithactive,
            implantalignbottomwithactive = true,
            wellalignleftwithactive = _P.wellalignleftwithactive,
            wellalignrightwithactive = _P.wellalignrightwithactive,
            wellaligntopwithactive = _P.wellaligntopwithactive,
            wellalignbottomwithactive = true,
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
            gtopext = _P.overwriteinnergateextensions and _P.innerngateext or separation / 2,
            gbotext = _P.ngateext,
            botgatecutspace = _P.npowerspace + _P.powerwidth / 2 - _P.cutheight / 2,
            drawbotgatecut = false,
            drawbottomactivedummy = _P.drawactivedummy,
            bottomactivedummywidth = _P.activedummywidth,
            bottomactivedummyspace = _P.activedummyspace,
            topgatecutspace = separation / 2 - _P.cutheight / 2,
            extendoxidetypetop = separation / 2,
            extendoxidetypebottom = _P.extendoxidetypebottom,
            extendvthtypetop = separation / 2,
            extendvthtypebottom = _P.extendvthtypebottom,
            extendimplanttop = separation / 2,
            extendimplantbottom = _P.extendimplantbottom,
            extendwelltop = separation / 2,
            extendwellbottom = _P.extendwellbottom,
            extendlvsmarkertop = separation / 2,
            extendlvsmarkerbottom = _P.extendlvsmarkerbottom,
            extendrotationmarkertop = separation / 2,
            extendrotationmarkerbottom = _P.extendrotationmarkerbottom,
            extendanalogmarkertop = separation / 2,
            extendanalogmarkerbottom = _P.extendanalogmarkerbottom,
            connectsourceinlineoffset = _P.noutputinlineoffset,
            implantalignleftwithactive = _P.implantalignleftwithactive,
            implantalignrightwithactive = _P.implantalignrightwithactive,
            implantaligntopwithactive = true,
            implantalignbottomwithactive = _P.implantalignbottomwithactive,
            wellalignleftwithactive = _P.wellalignleftwithactive,
            wellalignrightwithactive = _P.wellalignrightwithactive,
            wellaligntopwithactive = true,
            wellalignbottomwithactive = _P.wellalignbottomwithactive,
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
                    nopt_current.leftendgatelength = _P.leftendgatelength
                    nopt_current.leftendgatespace = _P.leftendgatespace
                    popt_current.drawleftstopgate = true
                    popt_current.drawstopgatetopgatecut = false
                    popt_current.drawstopgatebotgatecut = true
                    popt_current.leftendgatelength = _P.leftendgatelength
                    popt_current.leftendgatespace = _P.leftendgatespace
                end
                if _P.endleftwithgate then
                    nopt_current.endleftwithgate = true
                    nopt_current.leftendgatelength = _P.leftendgatelength
                    nopt_current.leftendgatespace = _P.leftendgatespace
                    popt_current.endleftwithgate = true
                    popt_current.leftendgatelength = _P.leftendgatelength
                    popt_current.leftendgatespace = _P.leftendgatespace
                end
            end
            if i == fingers then
                nopt_current.rightpolylines = _P.rightpolylines
                popt_current.rightpolylines = _P.rightpolylines
                if _P.drawrightstopgate then
                    nopt_current.drawrightstopgate = true
                    nopt_current.drawstopgatetopgatecut = true
                    nopt_current.drawstopgatebotgatecut = false
                    nopt_current.rightendgatelength = _P.rightendgatelength
                    nopt_current.rightendgatespace = _P.rightendgatespace
                    popt_current.drawrightstopgate = true
                    popt_current.drawstopgatetopgatecut = false
                    popt_current.drawstopgatebotgatecut = true
                    popt_current.rightendgatelength = _P.rightendgatelength
                    popt_current.rightendgatespace = _P.rightendgatespace
                end
                if _P.endrightwithgate then
                    nopt_current.endrightwithgate = true
                    nopt_current.rightendgatelength = _P.rightendgatelength
                    nopt_current.rightendgatespace = _P.rightendgatespace
                    popt_current.endrightwithgate = true
                    popt_current.rightendgatelength = _P.rightendgatelength
                    popt_current.rightendgatespace = _P.rightendgatespace
                end
            end
            -- gate contact positions
            local ngatey = (separation - _P.gatestrapwidth) / 2 + _P.shiftgatecontacts
            local pgatey = (separation - _P.gatestrapwidth) / 2 + _P.shiftgatecontacts
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
            elseif _P.gatecontactpos[i] == "split_nmosdummy" then
                -- FIXME: could add support for splitN
                nopt_current.drawbotgate = true
                nopt_current.botgatewidth = _P.dummycontheight
                popt_current.drawbotgate = true
                ngatey = _P.npowerspace
                pgatey = pgatey - 1 * (_P.gatestrapwidth + _P.gatestrapspace) + evenoddgatestrapshift
                nopt_current.drawtopgatecut = true
                --[[
                table.insert(gateanchors, {
                    pmos = {
                        source = "botgatestrap",
                        target = string.format("Gupper%d", i)
                    }
                })
                --]]
            elseif _P.gatecontactpos[i] == "split_pmosdummy" then
                -- FIXME: could add support for splitN
                nopt_current.drawtopgate = true
                popt_current.drawtopgate = true
                popt_current.topgatewidth = _P.dummycontheight
                ngatey = ngatey - 1 * (_P.gatestrapwidth + _P.gatestrapspace) + evenoddgatestrapshift
                pgatey = _P.ppowerspace
                nopt_current.drawtopgatecut = true
                --[[
                table.insert(gateanchors, {
                    nmos = {
                        source = "topgatestrap",
                        target = string.format("G%d", i)
                    },
                })
                --]]
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
            if _P.drawoutergatecut then -- only draw outer gate cut for inner active gates
                if _P.gatecontactpos[i] == "center" or
                   _P.gatecontactpos[i] == "split" or
                    string.match(_P.gatecontactpos[i], "upper") or
                    string.match(_P.gatecontactpos[i], "lower") then
                    nopt_current.drawbotgatecut = true
                    popt_current.drawtopgatecut = true
                end
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
                moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'\nmust be one of 'power', 'fullpower', 'outer', 'inner', 'dummyouterpower', 'dummyinner', 'full' or 'unused'", i, _P.ncontactpos[i]))
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
                    moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'\nmust be one of 'power', 'fullpower', 'outer', 'inner', 'dummyouterpower', 'dummyinner', 'full' or 'unused'", i + 1, _P.ncontactpos[i]))
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
                moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'\nmust be one of 'power', 'fullpower', 'outer', 'inner', 'dummyouterpower', 'dummyinner', 'full' or 'unused'", i, _P.pcontactpos[i]))
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
                    moderror(string.format("unknown source/drain contact position (p): [%d] = '%s'\nmust be one of 'power', 'fullpower', 'outer', 'inner', 'dummyouterpower', 'dummyinner', 'full' or 'unused'", i + 1, _P.pcontactpos[i]))
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
            pfet:translate(shift, separation)
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
            leftpdrainarea.tl:copy():translate(-_P.powerrailleftextension, _P.ppowerspace),
            rightpdrainarea.tr:copy():translate(_P.powerrailrightextension, _P.ppowerspace + _P.powerwidth)
        )
        cmos:add_area_anchor_bltr(
            "PRn",
            leftndrainarea.bl:copy():translate(-_P.powerrailleftextension, -_P.npowerspace - _P.powerwidth),
            rightndrainarea.br:copy():translate(_P.powerrailrightextension, -_P.npowerspace)
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
    local pmoswelltap_opt = {
        extendimplantleft = _P.pmoswelltapimplantleftextension,
        extendimplantright = _P.pmoswelltapimplantrightextension,
        extendimplanttop = _P.pmoswelltapimplanttopextension,
        extendimplantbottom = _P.pmoswelltapimplantbottomextension,
        extendsoiopenleft = _P.pmoswelltapsoiopenleftextension,
        extendsoiopenright = _P.pmoswelltapsoiopenrightextension,
        extendsoiopentop = _P.pmoswelltapsoiopentopextension,
        extendsoiopenbottom = _P.pmoswelltapsoiopenbottomextension,
        extendwellleft = _P.pmoswelltapwellleftextension,
        extendwellright = _P.pmoswelltapwellrightextension,
        extendwelltop = _P.pmoswelltapwelltopextension,
        extendwellbottom = _P.pmoswelltapwellbottomextension,
        ycontinuous = false,
    }
    local nmoswelltap_opt = {
        extendimplantleft = _P.nmoswelltapimplantleftextension,
        extendimplantright = _P.nmoswelltapimplantrightextension,
        extendimplanttop = _P.nmoswelltapimplanttopextension,
        extendimplantbottom = _P.nmoswelltapimplantbottomextension,
        extendsoiopenleft = _P.nmoswelltapsoiopenleftextension,
        extendsoiopenright = _P.nmoswelltapsoiopenrightextension,
        extendsoiopentop = _P.nmoswelltapsoiopentopextension,
        extendsoiopenbottom = _P.nmoswelltapsoiopenbottomextension,
        extendwellleft = _P.nmoswelltapwellleftextension,
        extendwellright = _P.nmoswelltapwellrightextension,
        extendwelltop = _P.nmoswelltapwelltopextension,
        extendwellbottom = _P.nmoswelltapwellbottomextension,
        ycontinuous = false,
    }
    if _P.drawpmosupperwelltap then
        local welltapwidth = rightpdrainarea.tr:getx() - leftpdrainarea.tl:getx()
        local welltap = pcell.create_layout("auxiliary/welltap", "welltap", util.add_options(pmoswelltap_opt, {
            contype = _P.pmosflippedwell and "p" or "n",
            width = welltapwidth + _P.pmoswelltapextension,
            height = _P.pmoswelltapwidth,
            xcontinuous = _P.welltapcontinuouscontact,
        }))
        welltap:move_point(welltap:get_area_anchor("boundary").bl, leftpdrainarea.tl)
        welltap:translate_x(-_P.pmoswelltapextension / 2)
        welltap:translate_y(_P.ppowerspace + _P.powerwidth + _P.pmoswelltapspace)
        cmos:merge_into(welltap)
        geometry.rectanglebltr(cmos, generics.well(_P.pmosflippedwell and "p" or "n"),
            point.create(
                math.max(
                    leftnmoswell.tl:getx(),
                    welltap:get_area_anchor("well").l
                ),
                leftnmoswell.tl:gety()
            ),
            point.create(
                math.max(
                    rightpmoswell.tr:getx(),
                    welltap:get_area_anchor("well").r
                ),
                welltap:get_area_anchor("well").t
            )
        )
        cmos:inherit_area_anchor_as(welltap, "boundary", "pmosupperwelltap_boundary")
        cmos:inherit_area_anchor_as(welltap, "well", "pmosupperwelltap_well")
        cmos:inherit_area_anchor_as(welltap, "implant", "pmosupperwelltap_implant")
        cmos:inherit_area_anchor_as(welltap, "soiopen", "pmosupperwelltap_soiopen")
    end
    if _P.drawpmosleftwelltap then
        local welltapwidth = leftpdrainarea.tl:gety() - leftpdrainarea.bl:gety()
        local welltap = pcell.create_layout("auxiliary/welltap", "welltap", util.add_options(pmoswelltap_opt, {
            contype = _P.pmosflippedwell and "p" or "n",
            width = _P.pmoswelltapwidth,
            height = welltapwidth + _P.pmoswelltapextension,
            xcontinuous = _P.welltapcontinuouscontact
        }))
        welltap:move_point(welltap:get_area_anchor("boundary").br, leftpdrainarea.bl)
        welltap:translate_x(-_P.pmoswelltapspace)
        cmos:merge_into(welltap)
        geometry.rectanglebltr(cmos, generics.well(_P.pmosflippedwell and "p" or "n"),
            point.create(
                welltap:get_area_anchor("well").l,
                leftpmoswell.bl:gety()
            ),
            leftpmoswell.tl
        )
        cmos:inherit_area_anchor_as(welltap, "boundary", "pmosleftwelltap_boundary")
        cmos:inherit_area_anchor_as(welltap, "well", "pmosleftwelltap_well")
        cmos:inherit_area_anchor_as(welltap, "implant", "pmosleftwelltap_implant")
        cmos:inherit_area_anchor_as(welltap, "soiopen", "pmosleftwelltap_soiopen")
    end
    if _P.drawpmosrightwelltap then
        local welltapwidth = rightpdrainarea.tr:gety() - rightpdrainarea.br:gety()
        local welltap = pcell.create_layout("auxiliary/welltap", "welltap", util.add_options(pmoswelltap_opt, {
            contype = _P.pmosflippedwell and "p" or "n",
            width = _P.pmoswelltapwidth,
            height = welltapwidth + _P.pmoswelltapextension,
            xcontinuous = _P.welltapcontinuouscontact
        }))
        welltap:move_point(welltap:get_area_anchor("boundary").bl, rightpdrainarea.br)
        welltap:translate_x(_P.pmoswelltapspace)
        cmos:merge_into(welltap)
        geometry.rectanglebltr(cmos, generics.well(_P.pmosflippedwell and "p" or "n"),
            rightpmoswell.br,
            point.create(
                welltap:get_area_anchor("well").r,
                rightpmoswell.tr:gety()
            )
        )
        cmos:inherit_area_anchor_as(welltap, "boundary", "pmosrightwelltap_boundary")
        cmos:inherit_area_anchor_as(welltap, "well", "pmosrightwelltap_well")
        cmos:inherit_area_anchor_as(welltap, "implant", "pmosrightwelltap_implant")
        cmos:inherit_area_anchor_as(welltap, "soiopen", "pmosrightwelltap_soiopen")
    end
    if _P.drawnmoslowerwelltap then
        local welltapwidth = rightndrainarea.br:getx() - leftpdrainarea.bl:getx()
        local welltap = pcell.create_layout("auxiliary/welltap", "welltap", util.add_options(nmoswelltap_opt, {
            contype = _P.nmosflippedwell and "n" or "p",
            width = welltapwidth + _P.nmoswelltapextension,
            height = _P.nmoswelltapwidth,
            xcontinuous = _P.welltapcontinuouscontact
        }))
        welltap:move_point(welltap:get_area_anchor("boundary").tl, leftndrainarea.bl)
        welltap:translate_x(-_P.nmoswelltapextension / 2)
        welltap:translate_y(-_P.npowerspace - _P.powerwidth - _P.nmoswelltapspace)
        cmos:merge_into(welltap)
        geometry.rectanglebltr(cmos, generics.well(_P.nmosflippedwell and "n" or "p"),
            point.create(
                math.min(
                    leftnmoswell.bl:getx(),
                    welltap:get_area_anchor("well").l
                ),
                welltap:get_area_anchor("well").b
            ),
            rightnmoswell.br
        )
        cmos:inherit_area_anchor_as(welltap, "boundary", "nmoslowerwelltap_boundary")
        cmos:inherit_area_anchor_as(welltap, "well", "nmoslowerwelltap_well")
        cmos:inherit_area_anchor_as(welltap, "implant", "nmoslowerwelltap_implant")
        cmos:inherit_area_anchor_as(welltap, "soiopen", "nmoslowerwelltap_soiopen")
    end
    if _P.drawnmosleftwelltap then
        local welltapwidth = leftndrainarea.tl:gety() - leftndrainarea.bl:gety()
        local welltap = pcell.create_layout("auxiliary/welltap", "welltap", util.add_options(nmoswelltap_opt, {
            contype = _P.nmosflippedwell and "p" or "n",
            width = _P.nmoswelltapwidth,
            height = welltapwidth + _P.nmoswelltapextension,
            xcontinuous = _P.welltapcontinuouscontact
        }))
        welltap:move_point(welltap:get_area_anchor("boundary").tr, leftndrainarea.tl)
        welltap:translate_x(-_P.nmoswelltapspace)
        cmos:merge_into(welltap)
        geometry.rectanglebltr(cmos, generics.well(_P.nmosflippedwell and "n" or "p"),
            point.create(
                welltap:get_area_anchor("well").l,
                leftnmoswell.bl:gety()
            ),
            leftnmoswell.tl
        )
        cmos:inherit_area_anchor_as(welltap, "boundary", "nmosleftwelltap_boundary")
        cmos:inherit_area_anchor_as(welltap, "well", "nmosleftwelltap_well")
        cmos:inherit_area_anchor_as(welltap, "implant", "nmosleftwelltap_implant")
        cmos:inherit_area_anchor_as(welltap, "soiopen", "nmosleftwelltap_soiopen")
    end
    if _P.drawnmosrightwelltap then
        local welltapwidth = rightndrainarea.tr:gety() - rightndrainarea.br:gety()
        local welltap = pcell.create_layout("auxiliary/welltap", "welltap", util.add_options(nmoswelltap_opt, {
            contype = _P.nmosflippedwell and "n" or "p",
            width = _P.nmoswelltapwidth,
            height = welltapwidth + _P.nmoswelltapextension,
            xcontinuous = _P.welltapcontinuouscontact
        }))
        welltap:move_point(welltap:get_area_anchor("boundary").tl, rightndrainarea.tr)
        welltap:translate_x(_P.nmoswelltapspace)
        cmos:merge_into(welltap)
        geometry.rectanglebltr(cmos, generics.well(_P.nmosflippedwell and "n" or "p"),
            rightnmoswell.br,
            point.create(
                welltap:get_area_anchor("well").r,
                rightnmoswell.tr:gety()
            )
        )
        cmos:inherit_area_anchor_as(welltap, "boundary", "nmosrightwelltap_boundary")
        cmos:inherit_area_anchor_as(welltap, "well", "nmosrightwelltap_well")
        cmos:inherit_area_anchor_as(welltap, "implant", "nmosrightwelltap_implant")
        cmos:inherit_area_anchor_as(welltap, "soiopen", "nmosrightwelltap_soiopen")
    end

    if _P.drawoutergatecut and _P.drawgatecuteverywhere then
        geometry.rectanglebltr(cmos, generics.feol("gatecut"),
            cmos:get_area_anchor("PRp").bl:translate(0, (_P.powerwidth - _P.cutheight) / 2),
            cmos:get_area_anchor("PRp").br:translate(0, (_P.powerwidth - _P.cutheight) / 2 + _P.cutheight)
        )
        geometry.rectanglebltr(cmos, generics.feol("gatecut"),
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
    local ybottom = -separation / 2 - _P.nwidth - _P.npowerspace - _P.powerwidth / 2
    local ytop =  separation / 2 + _P.pwidth + _P.ppowerspace + _P.powerwidth / 2
    if _P.drawpmosupperwelltap then
        ytop = ytop + _P.powerwidth / 2 + _P.pmoswelltapspace + _P.pmoswelltapwidth / 2
    end
    if _P.drawnmoslowerwelltap then
        ybottom = ybottom - _P.powerwidth / 2 - _P.nmoswelltapspace - _P.nmoswelltapwidth / 2
    end
    cmos:set_alignment_box(
        leftndrainarea.bl:copy():translate(0, -_P.npowerspace - _P.powerwidth),
        rightpdrainarea.tr:copy():translate(0, _P.ppowerspace + _P.powerwidth),
        leftndrainarea.br:copy():translate(0, -_P.npowerspace),
        rightpdrainarea.tl:copy():translate(0, _P.ppowerspace)
    )
end
