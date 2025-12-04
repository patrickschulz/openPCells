function parameters()
    pcell.add_parameters(
        { "fingers(Number of Fingers)",                 2 },
        { "pwidth",                                     2 * technology.get_dimension("Minimum Gate Width") },
        { "nwidth",                                     2 * technology.get_dimension("Minimum Gate Width") },
        { "oxidetype(Oxide Type)",                      1 },
        { "gatemarker(Gate Marker Index)",              1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",     1 },
        { "nvthtype(NMOS Threshold Voltage Type)",      1 },
        { "pmosflippedwell(PMOS Flipped Well) ",        false },
        { "nmosflippedwell(NMOS Flipped Well)",         false },
        { "gatelength(Gate Length)",                    technology.get_dimension("Minimum Gate Length") },
        { "gatespace(Gate Spacing)",                    technology.get_dimension("Minimum Gate XSpace") },
        { "allgatesequalheight",                        true },
        { "actext",                                     technology.get_optional_dimension("Minimum Device Minimum Active Extension") },
        { "drawoutergatecut",                           false },
        { "drawgatecuteverywhere",                      false },
        { "gatecutheight",                              0 },
        { "outergatecutyshift",                         0 },
        { "gatemetal",                                  1 },
        { "sdwidth(Source/Drain Metal Width)",          technology.get_dimension_max("Minimum Source/Drain Contact Region Size", "Minimum M1 Width"), posvals = even() },
        { "gatestrapwidth(Gate Metal Width)",           technology.get_dimension_max("Minimum Gate Contact Region Size", "Minimum M1 Width") },
        { "gatestrapspace(Gate Metal Space)",           technology.get_dimension("Minimum M1 Width") },
        { "gatestrapleftextension",                     0 },
        { "gatestraprightextension",                    0 },
        { "powerwidth(Power Rail Metal Width)",         technology.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",               technology.get_dimension("Minimum M1 Space") },
        { "powerrailleftrightextension",                0 },
        { "powerrailleftextension",                     0, follow = "powerrailleftrightextension" },
        { "powerrailrightextension",                    0, follow = "powerrailleftrightextension" },
        { "pgateext",                                   technology.get_dimension("Minimum Gate Extension") },
        { "ngateext",                                   technology.get_dimension("Minimum Gate Extension") },
        { "numleftdummies",                             0 },
        { "numrightdummies",                            0 },
        { "alternatedummycontacts",                     false },
        { "drawalternatedummycontactspowerbarvia",      false, follow = "alternatedummycontacts" },
        { "splitdrainvias",                             false },
        { "outputmetal",                                2, posvals = interval(2, inf) },
        { "outputwidth",                                technology.get_dimension("Minimum M1 Width") },
        { "outputxshift",                               0 },
        { "outputyshift",                               0 },
        { "extendoutputmetal",                          0 },
        { "dummycontheight",                            technology.get_dimension("Minimum M1 Width"), follow = "powerwidth" },
        { "dummycontshift",                             0 },
        { "psddummyouterheight",                        2 * technology.get_dimension("Minimum Gate Width"), follow = "pwidth" },
        { "nsddummyouterheight",                        2 * technology.get_dimension("Minimum Gate Width"), follow = "nwidth" },
        { "outputisinside",                             false },
        { "drawleftstopgate",                           false },
        { "drawrightstopgate",                          false },
        { "excludestopgatesfromcutregions",             true },
        { "leftpolylines",                              {} },
        { "rightpolylines",                             {} },
        { "drawanalogmarker",                           false, },
        { "implantalignwithactive",                     false },
        { "implantalignleftwithactive",                 false, follow = "implantalignwithactive" },
        { "implantalignrightwithactive",                false, follow = "implantalignwithactive" },
        { "implantaligntopwithactive",                  false, follow = "implantalignwithactive" },
        { "implantalignbottomwithactive",               false, follow = "implantalignwithactive" },
        { "wellalignwithactive",                        false },
        { "wellalignleftwithactive",                    false, follow = "wellalignwithactive" },
        { "wellalignrightwithactive",                   false, follow = "wellalignwithactive" },
        { "wellaligntopwithactive",                     false, follow = "wellalignwithactive" },
        { "wellalignbottomwithactive",                  false, follow = "wellalignwithactive" },
        { "oxidetypealignwithactive",                   false },
        { "oxidetypealignleftwithactive",               false, follow = "oxidetypealignwithactive" },
        { "oxidetypealignrightwithactive",              false, follow = "oxidetypealignwithactive" },
        { "oxidetypealigntopwithactive",                false, follow = "oxidetypealignwithactive" },
        { "oxidetypealignbottomwithactive",             false, follow = "oxidetypealignwithactive" },
        { "vthtypealignwithactive",                     false },
        { "vthtypealignleftwithactive",                 false, follow = "vthtypealignwithactive" },
        { "vthtypealignrightwithactive",                false, follow = "vthtypealignwithactive" },
        { "vthtypealigntopwithactive",                  false, follow = "vthtypealignwithactive" },
        { "vthtypealignbottomwithactive",               false, follow = "vthtypealignwithactive" },
        { "extendall",                                  0 },
        { "extendalltop",                               0, follow = "extendall" },
        { "extendallbottom",                            0, follow = "extendall" },
        { "extendallleft",                              0, follow = "extendall" },
        { "extendallright",                             0, follow = "extendall" },
        { "extendoxidetypetop",                         0, follow = "extendalltop" },
        { "extendoxidetypebottom",                      0, follow = "extendallbottom" },
        { "extendoxidetypeleft",                        0, follow = "extendallleft" },
        { "extendoxidetyperight",                       0, follow = "extendallright" },
        { "extendvthtypetop",                           0, follow = "extendalltop" },
        { "extendvthtypebottom",                        0, follow = "extendallbottom" },
        { "extendvthtypeleft",                          0, follow = "extendallleft" },
        { "extendvthtyperight",                         0, follow = "extendallright" },
        { "extendimplanttop",                           0, follow = "extendalltop" },
        { "extendimplantbottom",                        0, follow = "extendallbottom" },
        { "extendimplantleft",                          0, follow = "extendallleft" },
        { "extendimplantright",                         0, follow = "extendallright" },
        { "extendwelltop",                              0, follow = "extendalltop" },
        { "extendwellbottom",                           0, follow = "extendallbottom" },
        { "extendwellleft",                             0, follow = "extendallleft" },
        { "extendwellright",                            0, follow = "extendallright" },
        { "extendlvsmarkertop",                         0, follow = "extendalltop" },
        { "extendlvsmarkerbottom",                      0, follow = "extendallbottom" },
        { "extendlvsmarkerleft",                        0, follow = "extendallleft" },
        { "extendlvsmarkerright",                       0, follow = "extendallright" },
        { "extendrotationmarkertop",                    0, follow = "extendalltop" },
        { "extendrotationmarkerbottom",                 0, follow = "extendallbottom" },
        { "extendrotationmarkerleft",                   0, follow = "extendallleft" },
        { "extendrotationmarkerright",                  0, follow = "extendallright" },
        { "extendanalogmarkertop",                      0, follow = "extendalltop" },
        { "extendanalogmarkerbottom",                   0, follow = "extendallbottom" },
        { "extendanalogmarkerleft",                     0, follow = "extendallleft" },
        { "extendanalogmarkerright",                    0, follow = "extendallright" },
        { "drawnmoslowerwelltap",                       false },
        { "drawnmosleftrightwelltap",                   false },
        { "drawnmosleftwelltap",                        false, follow = "drawnmosleftrightwelltap" },
        { "drawnmosrightwelltap",                       false, follow = "drawnmosleftrightwelltap" },
        { "connectnmoswelltap",                         false },
        { "nmoswelltapwidth",                           200 },
        { "nmoswelltapextension",                       0 },
        { "nmoswelltapspace",                           500 },
        { "nmoswelltapimplantleftextension",            technology.get_dimension("Minimum Implant Extension") },
        { "nmoswelltapimplantrightextension",           technology.get_dimension("Minimum Implant Extension") },
        { "nmoswelltapimplanttopextension",             technology.get_dimension("Minimum Implant Extension") },
        { "nmoswelltapimplantbottomextension",          technology.get_dimension("Minimum Implant Extension") },
        { "nmoswelltapsoiopenleftextension",            technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "nmoswelltapsoiopenrightextension",           technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "nmoswelltapsoiopentopextension",             technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "nmoswelltapsoiopenbottomextension",          technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "nmoswelltapwellleftextension",               technology.get_dimension("Minimum Well Extension") },
        { "nmoswelltapwellrightextension",              technology.get_dimension("Minimum Well Extension") },
        { "nmoswelltapwelltopextension",                technology.get_dimension("Minimum Well Extension") },
        { "nmoswelltapwellbottomextension",             technology.get_dimension("Minimum Well Extension") },
        { "drawpmosupperwelltap",                       false },
        { "drawpmosleftrightwelltap",                   false },
        { "drawpmosleftwelltap",                        false, follow = "drawpmosleftrightwelltap" },
        { "drawpmosrightwelltap",                       false, follow = "drawpmosleftrightwelltap" },
        { "connectpmoswelltap",                         false },
        { "pmoswelltapwidth",                           200 },
        { "pmoswelltapextension",                       0 },
        { "pmoswelltapspace",                           500 },
        { "pmoswelltapimplantleftextension",            technology.get_dimension("Minimum Implant Extension") },
        { "pmoswelltapimplantrightextension",           technology.get_dimension("Minimum Implant Extension") },
        { "pmoswelltapimplanttopextension",             technology.get_dimension("Minimum Implant Extension") },
        { "pmoswelltapimplantbottomextension",          technology.get_dimension("Minimum Implant Extension") },
        { "pmoswelltapsoiopenleftextension",            technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "pmoswelltapsoiopenrightextension",           technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "pmoswelltapsoiopentopextension",             technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "pmoswelltapsoiopenbottomextension",          technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "pmoswelltapwellleftextension",               technology.get_dimension("Minimum Well Extension") },
        { "pmoswelltapwellrightextension",              technology.get_dimension("Minimum Well Extension") },
        { "pmoswelltapwelltopextension",                technology.get_dimension("Minimum Well Extension") },
        { "pmoswelltapwellbottomextension",             technology.get_dimension("Minimum Well Extension") },
        { "drawguardring",                              false },
        { "guardringwidth",                             technology.get_dimension("Minimum Active Contact Region Size") },
        { "guardringspace",                             technology.get_dimension("Minimum Active Space") },
        { "guardringdeepwelloffset",                    0 }
    )
end

function layout(inverter, _P)
    local xpitch = _P.gatespace + _P.gatelength

    local gatecontactpos = util.fill_all_with(_P.fingers, "center")
    local contactpos = util.fill_odd_with(_P.fingers + 1, "fullpower", "full")
    for i = 1, _P.numleftdummies do
        table.insert(gatecontactpos, 1, "dummy")
        --table.insert(contactpos, 1, "dummyouterpower")
        table.insert(contactpos, 1, "dummyouter")
    end
    for i = 1, _P.numrightdummies do
        table.insert(gatecontactpos, "dummy")
        --table.insert(contactpos, "dummyouterpower")
        table.insert(contactpos, "dummyouter")
    end
    local hasdummies = (_P.numleftdummies > 0) and (_P.numrightdummies > 0)

    local cmos = pcell.create_layout("basic/cmos", "cmos", {
        nvthtype = _P.nvthtype,
        pvthtype = _P.pvthtype,
        pmosflippedwell = _P.pmosflippedwell,
        nmosflippedwell = _P.nmosflippedwell,
        oxidetype = _P.oxidetype,
        gatemarker = _P.gatemarker,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        actext = _P.actext,
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
        psplitoutputvias = _P.splitdrainvias,
        nsplitoutputvias = _P.splitdrainvias,
        outputwidth = _P.outputwidth,
        noutputinlineoffset = _P.nwidth - _P.outputyshift - _P.outputwidth,
        poutputinlineoffset = _P.pwidth - _P.outputyshift - _P.outputwidth,
        powerwidth = _P.powerwidth,
        npowerspace = _P.powerspace,
        ppowerspace = _P.powerspace,
        powerrailleftextension = _P.powerrailleftextension,
        powerrailrightextension = _P.powerrailrightextension,
        pgateext = ((_P.allgatesequalheight and hasdummies) and (_P.powerspace + _P.powerwidth) or 0) + _P.pgateext,
        ngateext = ((_P.allgatesequalheight and hasdummies) and (_P.powerspace + _P.powerwidth) or 0) + _P.ngateext,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        outputmetal = _P.outputmetal,
        isoutputcontact = util.range(_P.numleftdummies + 2, _P.numleftdummies + _P.fingers, 2),
        innergatestraps = 1,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        sdwidth = _P.sdwidth,
        separation = _P.gatestrapwidth + 2 * _P.gatestrapspace,
        dummycontheight = _P.dummycontheight,
        dummycontshift = _P.dummycontshift,
        drawleftstopgate = _P.drawleftstopgate,
        drawrightstopgate = _P.drawrightstopgate,
        excludestopgatesfromcutregions = _P.excludestopgatesfromcutregions,
        leftpolylines = _P.leftpolylines,
        rightpolylines = _P.rightpolylines,
        drawanalogmarker = _P.drawanalogmarker,
        cutwidth = _P.gatelength + _P.gatespace,
        drawgatecuteverywhere = _P.drawgatecuteverywhere,
        drawoutergatecut = _P.drawoutergatecut,
        cutheight = _P.gatecutheight,
        poutercutyshift = _P.outergatecutyshift,
        noutercutyshift = _P.outergatecutyshift,
        implantalignleftwithactive = _P.implantalignleftwithactive,
        implantalignrightwithactive = _P.implantalignrightwithactive,
        implantaligntopwithactive = _P.implantaligntopwithactive,
        implantalignbottomwithactive = _P.implantalignbottomwithactive,
        wellalignleftwithactive = _P.wellalignleftwithactive,
        wellalignrightwithactive = _P.wellalignrightwithactive,
        wellaligntopwithactive = _P.wellaligntopwithactive,
        wellalignbottomwithactive = _P.wellalignbottomwithactive,
        oxidetypealignleftwithactive = _P.oxidetypealignleftwithactive,
        oxidetypealignrightwithactive = _P.oxidetypealignrightwithactive,
        oxidetypealigntopwithactive = _P.oxidetypealigntopwithactive,
        oxidetypealignbottomwithactive = _P.oxidetypealignbottomwithactive,
        vthtypealignleftwithactive = _P.vthtypealignleftwithactive,
        vthtypealignrightwithactive = _P.vthtypealignrightwithactive,
        vthtypealigntopwithactive = _P.vthtypealigntopwithactive,
        vthtypealignbottomwithactive = _P.vthtypealignbottomwithactive,
        extendimplanttop = _P.extendimplanttop,
        extendimplantbottom = _P.extendimplantbottom,
        extendimplantleft = _P.extendimplantleft,
        extendimplantright = _P.extendimplantright,
        extendoxidetypetop = _P.extendoxidetypetop,
        extendoxidetypebottom = _P.extendoxidetypebottom,
        extendoxidetypeleft = _P.extendoxidetypeleft,
        extendoxidetyperight = _P.extendoxidetyperight,
        extendvthtypetop = _P.extendvthtypetop,
        extendvthtypebottom = _P.extendvthtypebottom,
        extendvthtypeleft = _P.extendvthtypeleft,
        extendvthtyperight = _P.extendvthtyperight,
        extendwelltop = _P.extendwelltop,
        extendwellbottom = _P.extendwellbottom,
        extendwellleft = _P.extendwellleft,
        extendwellright = _P.extendwellright,
        extendlvsmarkertop = _P.extendlvsmarkertop,
        extendlvsmarkerbottom = _P.extendlvsmarkerbottom,
        extendlvsmarkerleft = _P.extendlvsmarkerleft,
        extendlvsmarkerright = _P.extendlvsmarkerright,
        extendrotationmarkertop = _P.extendrotationmarkertop,
        extendrotationmarkerbottom = _P.extendrotationmarkerbottom,
        extendrotationmarkerleft = _P.extendrotationmarkerleft,
        extendrotationmarkerright = _P.extendrotationmarkerright,
        extendanalogmarkertop = _P.extendanalogmarkertop,
        extendanalogmarkerbottom = _P.extendanalogmarkerbottom,
        extendanalogmarkerleft = _P.extendanalogmarkerleft,
        extendanalogmarkerright = _P.extendanalogmarkerright,
        psddummyouterheight = _P.psddummyouterheight,
        nsddummyouterheight = _P.nsddummyouterheight,
        drawnmoslowerwelltap = _P.drawnmoslowerwelltap,
        drawnmosleftwelltap = _P.drawnmosleftwelltap,
        drawnmosrightwelltap = _P.drawnmosrightwelltap,
        nmoswelltapwidth = _P.nmoswelltapwidth,
        nmoswelltapspace = _P.nmoswelltapspace,
        nmoswelltapextension = _P.nmoswelltapextension,
        nmoswelltapimplantleftextension = _P.nmoswelltapimplantleftextension,
        nmoswelltapimplantrightextension = _P.nmoswelltapimplantrightextension,
        nmoswelltapimplanttopextension = _P.nmoswelltapimplanttopextension,
        nmoswelltapimplantbottomextension = _P.nmoswelltapimplantbottomextension,
        nmoswelltapsoiopenleftextension = _P.nmoswelltapsoiopenleftextension,
        nmoswelltapsoiopenrightextension = _P.nmoswelltapsoiopenrightextension,
        nmoswelltapsoiopentopextension = _P.nmoswelltapsoiopentopextension,
        nmoswelltapsoiopenbottomextension = _P.nmoswelltapsoiopenbottomextension,
        nmoswelltapwellleftextension = _P.nmoswelltapwellleftextension,
        nmoswelltapwellrightextension = _P.nmoswelltapwellrightextension,
        nmoswelltapwelltopextension = _P.nmoswelltapwelltopextension,
        nmoswelltapwellbottomextension = _P.nmoswelltapwellbottomextension,
        drawpmosupperwelltap = _P.drawpmosupperwelltap,
        drawpmosleftwelltap = _P.drawpmosleftwelltap,
        drawpmosrightwelltap = _P.drawpmosrightwelltap,
        pmoswelltapwidth = _P.pmoswelltapwidth,
        pmoswelltapspace = _P.pmoswelltapspace,
        pmoswelltapextension = _P.pmoswelltapextension,
        pmoswelltapimplantleftextension = _P.pmoswelltapimplantleftextension,
        pmoswelltapimplantrightextension = _P.pmoswelltapimplantrightextension,
        pmoswelltapimplanttopextension = _P.pmoswelltapimplanttopextension,
        pmoswelltapimplantbottomextension = _P.pmoswelltapimplantbottomextension,
        pmoswelltapsoiopenleftextension = _P.pmoswelltapsoiopenleftextension,
        pmoswelltapsoiopenrightextension = _P.pmoswelltapsoiopenrightextension,
        pmoswelltapsoiopentopextension = _P.pmoswelltapsoiopentopextension,
        pmoswelltapsoiopenbottomextension = _P.pmoswelltapsoiopenbottomextension,
        pmoswelltapwellleftextension = _P.pmoswelltapwellleftextension,
        pmoswelltapwellrightextension = _P.pmoswelltapwellrightextension,
        pmoswelltapwelltopextension = _P.pmoswelltapwelltopextension,
        pmoswelltapwellbottomextension = _P.pmoswelltapwellbottomextension,
    })
    inverter:merge_into(cmos)

    inverter:inherit_alignment_box(cmos)

    -- gate strap
    if _P.fingers > 1 then
        if _P.gatemetal > 1 then
            geometry.viabltr(
                inverter, 1, _P.gatemetal,
                cmos:get_area_anchor(string.format("G%d", 1 + _P.numleftdummies)).bl:translate_x(-_P.gatestrapleftextension),
                cmos:get_area_anchor(string.format("G%d", _P.fingers + _P.numleftdummies)).tr:translate_x(_P.gatestraprightextension)
            )
        else
            geometry.rectanglebltr(
                inverter, generics.metal(1),
                cmos:get_area_anchor(string.format("G%d", 1 + _P.numleftdummies)).bl:translate_x(-_P.gatestrapleftextension),
                cmos:get_area_anchor(string.format("G%d", _P.fingers + _P.numleftdummies)).tr:translate_x(_P.gatestraprightextension)
            )
        end
    end

    -- signal transistors drain connections
    if _P.outputisinside then
        for i = 2, _P.fingers + 1, 2 do
            geometry.rectanglebltr(inverter, generics.metal(_P.outputmetal),
                cmos:get_area_anchor(string.format("nSD%d", i + _P.numleftdummies)).tl,
                cmos:get_area_anchor(string.format("pSD%d", i + _P.numleftdummies)).br
            )
        end
        inverter:add_area_anchor_bltr("output",
            point.combine(
                cmos:get_area_anchor(string.format("nSD%d", 2 + _P.numleftdummies)).tl,
                cmos:get_area_anchor(string.format("pSD%d", 2 + _P.numleftdummies)).bl
            ):translate_y(-_P.outputwidth / 2),
            point.combine(
                cmos:get_area_anchor(string.format("nSD%d", _P.fingers + _P.numleftdummies)).tr,
                cmos:get_area_anchor(string.format("pSD%d", _P.fingers + _P.numleftdummies)).br
            ):translate_y(_P.outputwidth / 2)
        )
        geometry.rectanglebltr(inverter, generics.metal(_P.outputmetal),
            inverter:get_area_anchor("output").bl,
            inverter:get_area_anchor("output").tr
        )
    else
        geometry.path_cshape(inverter, generics.metal(_P.outputmetal),
            cmos:get_area_anchor(string.format("pSD%d", 2 + _P.numleftdummies)).br:translate(0,  _P.outputyshift + _P.outputwidth / 2),
            cmos:get_area_anchor(string.format("nSD%d", 2 + _P.numleftdummies)).tr:translate(0, -_P.outputyshift - _P.outputwidth / 2),
            cmos:get_area_anchor(string.format("G%d", _P.fingers + _P.numleftdummies)).bl:translate(xpitch + _P.outputxshift, 0),
            _P.outputwidth
        )
        inverter:add_area_anchor_bltr("upperoutput",
            point.create(
                cmos:get_area_anchor(string.format("pSD%d", 2 + _P.numleftdummies)).r,
                cmos:get_area_anchor(string.format("pSD%d", 2 + _P.numleftdummies)).b + _P.outputyshift
            ),
            point.create(
                cmos:get_area_anchor(string.format("G%d", _P.fingers + _P.numleftdummies)).l + xpitch + _P.outputxshift,
                cmos:get_area_anchor(string.format("pSD%d", 2 + _P.numleftdummies)).b + _P.outputyshift + _P.outputwidth
            )
        )
        inverter:add_area_anchor_bltr("loweroutput",
            point.create(
                cmos:get_area_anchor(string.format("nSD%d", 2 + _P.numleftdummies)).r,
                cmos:get_area_anchor(string.format("nSD%d", 2 + _P.numleftdummies)).t - _P.outputyshift - _P.outputwidth
            ),
            point.create(
                cmos:get_area_anchor(string.format("G%d", _P.fingers + _P.numleftdummies)).l + xpitch + _P.outputxshift,
                cmos:get_area_anchor(string.format("nSD%d", 2 + _P.numleftdummies)).t - _P.outputyshift
            )
        )
        inverter:add_area_anchor_bltr("output",
            point.create(
                cmos:get_area_anchor(string.format("G%d", _P.fingers + _P.numleftdummies)).l + xpitch + _P.outputxshift - _P.outputwidth / 2,
                cmos:get_area_anchor(string.format("nSD%d", 2 + _P.numleftdummies)).t - _P.outputwidth / 2
            ),
            point.create(
                cmos:get_area_anchor(string.format("G%d", _P.fingers + _P.numleftdummies)).l + xpitch + _P.outputxshift + _P.outputwidth / 2,
                cmos:get_area_anchor(string.format("pSD%d", 2 + _P.numleftdummies)).b + _P.outputwidth / 2
            )
        )
    end

    -- inherit anchors
    inverter:inherit_area_anchor_as(cmos, "PRp", "vddbar")
    inverter:inherit_area_anchor_as(cmos, "PRn", "vssbar")
    inverter:inherit_area_anchor(cmos, "nmos_implant")
    inverter:inherit_area_anchor(cmos, "pmos_implant")
    inverter:inherit_area_anchor(cmos, "nmos_well")
    inverter:inherit_area_anchor(cmos, "pmos_well")
    inverter:inherit_area_anchor(cmos, "nmos_active")
    inverter:inherit_area_anchor(cmos, "pmos_active")
    if _P.drawpmosupperwelltap then
        inverter:inherit_area_anchor(cmos, "pmosupperwelltap_boundary")
        inverter:inherit_area_anchor(cmos, "pmosupperwelltap_well")
        inverter:inherit_area_anchor(cmos, "pmosupperwelltap_implant")
        inverter:inherit_area_anchor(cmos, "pmosupperwelltap_soiopen")
    end
    if _P.drawpmosleftwelltap then
        inverter:inherit_area_anchor(cmos, "pmosleftwelltap_boundary")
        inverter:inherit_area_anchor(cmos, "pmosleftwelltap_well")
        inverter:inherit_area_anchor(cmos, "pmosleftwelltap_implant")
        inverter:inherit_area_anchor(cmos, "pmosleftwelltap_soiopen")
    end
    if _P.drawpmosrightwelltap then
        inverter:inherit_area_anchor(cmos, "pmosrightwelltap_boundary")
        inverter:inherit_area_anchor(cmos, "pmosrightwelltap_well")
        inverter:inherit_area_anchor(cmos, "pmosrightwelltap_implant")
        inverter:inherit_area_anchor(cmos, "pmosrightwelltap_soiopen")
    end
    if _P.drawnmoslowerwelltap then
        inverter:inherit_area_anchor(cmos, "nmoslowerwelltap_boundary")
        inverter:inherit_area_anchor(cmos, "nmoslowerwelltap_well")
        inverter:inherit_area_anchor(cmos, "nmoslowerwelltap_implant")
        inverter:inherit_area_anchor(cmos, "nmoslowerwelltap_soiopen")
    end
    if _P.drawnmosleftwelltap then
        inverter:inherit_area_anchor(cmos, "nmosleftwelltap_boundary")
        inverter:inherit_area_anchor(cmos, "nmosleftwelltap_well")
        inverter:inherit_area_anchor(cmos, "nmosleftwelltap_implant")
        inverter:inherit_area_anchor(cmos, "nmosleftwelltap_soiopen")
    end
    if _P.drawnmosrightwelltap then
        inverter:inherit_area_anchor(cmos, "nmosrightwelltap_boundary")
        inverter:inherit_area_anchor(cmos, "nmosrightwelltap_well")
        inverter:inherit_area_anchor(cmos, "nmosrightwelltap_implant")
        inverter:inherit_area_anchor(cmos, "nmosrightwelltap_soiopen")
    end
    for i = 1, _P.numleftdummies + _P.numrightdummies + _P.fingers do
        inverter:inherit_area_anchor(cmos, string.format("G%d", i))
    end

    -- connect dummies
    if _P.alternatedummycontacts then
        if _P.drawalternatedummycontactspowerbarvia then
            geometry.viabltr_xcontinuous(inverter, 1, 2,
                inverter:get_area_anchor("vddbar").bl,
                inverter:get_area_anchor("vddbar").tr
            )
            geometry.viabltr_xcontinuous(inverter, 1, 2,
                inverter:get_area_anchor("vssbar").bl,
                inverter:get_area_anchor("vssbar").tr
            )
        end
        for i = 1, _P.numleftdummies do
            if i % 2 == 1 then
                geometry.rectanglebltr(inverter, generics.metal(1),
                    cmos:get_area_anchor(string.format("pSD%d", i)).tl,
                    point.create(
                        cmos:get_area_anchor(string.format("pSD%d", i)).r,
                        cmos:get_area_anchor("PRp").b
                    )
                )
                geometry.rectanglebltr(inverter, generics.metal(1),
                    point.create(
                        cmos:get_area_anchor(string.format("nSD%d", i)).l,
                        cmos:get_area_anchor("PRn").t
                    ),
                    cmos:get_area_anchor(string.format("nSD%d", i)).br
                )
            else
                geometry.rectanglebltr(inverter, generics.metal(2),
                    cmos:get_area_anchor(string.format("pSD%d", i)).tl,
                    point.create(
                        cmos:get_area_anchor(string.format("pSD%d", i)).r,
                        cmos:get_area_anchor("PRp").b
                    )
                )
                geometry.rectanglebltr(inverter, generics.metal(2),
                    point.create(
                        cmos:get_area_anchor(string.format("nSD%d", i)).l,
                        cmos:get_area_anchor("PRn").t
                    ),
                    cmos:get_area_anchor(string.format("nSD%d", i)).br
                )
                geometry.viabltr(inverter, 1, 2,
                    cmos:get_area_anchor(string.format("pSD%d", i)).bl,
                    cmos:get_area_anchor(string.format("pSD%d", i)).tr
                )
                geometry.viabltr(inverter, 1, 2,
                    cmos:get_area_anchor(string.format("nSD%d", i)).bl,
                    cmos:get_area_anchor(string.format("nSD%d", i)).tr
                )
            end
        end
        for i = 1, _P.numrightdummies do
            if i % 2 == 0 then
                geometry.rectanglebltr(inverter, generics.metal(1),
                    cmos:get_area_anchor(string.format("pSD%d", i + _P.fingers + _P.numleftdummies + 1)).tl,
                    point.create(
                        cmos:get_area_anchor(string.format("pSD%d", i + _P.fingers + _P.numleftdummies + 1)).r,
                        cmos:get_area_anchor("PRp").b
                    )
                )
                geometry.rectanglebltr(inverter, generics.metal(1),
                    point.create(
                        cmos:get_area_anchor(string.format("nSD%d", i + _P.fingers + _P.numleftdummies + 1)).l,
                        cmos:get_area_anchor("PRn").t
                    ),
                    cmos:get_area_anchor(string.format("nSD%d", i + _P.fingers + _P.numleftdummies + 1)).br
                )
            else
                geometry.rectanglebltr(inverter, generics.metal(2),
                    cmos:get_area_anchor(string.format("pSD%d", i + _P.fingers + _P.numleftdummies + 1)).tl,
                    point.create(
                        cmos:get_area_anchor(string.format("pSD%d", i + _P.fingers + _P.numleftdummies + 1)).r,
                        cmos:get_area_anchor("PRp").b
                    )
                )
                geometry.rectanglebltr(inverter, generics.metal(2),
                    point.create(
                        cmos:get_area_anchor(string.format("nSD%d", i + _P.fingers + _P.numleftdummies + 1)).l,
                        cmos:get_area_anchor("PRn").t
                    ),
                    cmos:get_area_anchor(string.format("nSD%d", i + _P.fingers + _P.numleftdummies + 1)).br
                )
                geometry.viabltr(inverter, 1, 2,
                    cmos:get_area_anchor(string.format("pSD%d", i + _P.fingers + _P.numleftdummies + 1)).bl,
                    cmos:get_area_anchor(string.format("pSD%d", i + _P.fingers + _P.numleftdummies + 1)).tr
                )
                geometry.viabltr(inverter, 1, 2,
                    cmos:get_area_anchor(string.format("nSD%d", i + _P.fingers + _P.numleftdummies + 1)).bl,
                    cmos:get_area_anchor(string.format("nSD%d", i + _P.fingers + _P.numleftdummies + 1)).tr
                )
            end
        end
    else
        for i = 1, _P.numleftdummies do
            geometry.rectanglebltr(inverter, generics.metal(1),
                cmos:get_area_anchor(string.format("pSD%d", i)).tl,
                point.create(
                    cmos:get_area_anchor(string.format("pSD%d", i)).r,
                    cmos:get_area_anchor("PRp").b
                )
            )
            geometry.rectanglebltr(inverter, generics.metal(1),
                point.create(
                    cmos:get_area_anchor(string.format("nSD%d", i)).l,
                    cmos:get_area_anchor("PRn").t
                ),
                cmos:get_area_anchor(string.format("nSD%d", i)).br
            )
        end
        for i = 1, _P.numrightdummies do
            geometry.rectanglebltr(inverter, generics.metal(1),
                cmos:get_area_anchor(string.format("pSD%d", i + _P.fingers + _P.numleftdummies + 1)).tl,
                point.create(
                    cmos:get_area_anchor(string.format("pSD%d", i + _P.fingers + _P.numleftdummies + 1)).r,
                    cmos:get_area_anchor("PRp").b
                )
            )
            geometry.rectanglebltr(inverter, generics.metal(1),
                point.create(
                    cmos:get_area_anchor(string.format("nSD%d", i + _P.fingers + _P.numleftdummies + 1)).l,
                    cmos:get_area_anchor("PRn").t
                ),
                cmos:get_area_anchor(string.format("nSD%d", i + _P.fingers + _P.numleftdummies + 1)).br
            )
        end
    end

    -- guardring
    if _P.drawguardring then
        local guardringw1, guardringw2
        if _P.drawpmosleftwelltap then
            guardringw1 = cmos:get_area_anchor("pmosleftwelltap_boundary").l
        else
            guardringw1 = cmos:get_area_anchor("pmos_active").l
        end
        if _P.drawpmosrightwelltap then
            guardringw2 = cmos:get_area_anchor("pmosrightwelltap_boundary").r
        else
            guardringw2 = cmos:get_area_anchor("pmos_active").r
        end
        local guardringh1, guardringh2
        if _P.drawnmoslowerwelltap then
            guardringh1 = cmos:get_area_anchor("nmoslowerwelltap_boundary").b
        else
            guardringh1 = cmos:get_area_anchor("PRn").b
        end
        if _P.drawpmosupperwelltap then
            guardringh2 = cmos:get_area_anchor("pmosupperwelltap_boundary").t
        else
            guardringh2 = cmos:get_area_anchor("PRp").t
        end
        local guardringwidth = guardringw2 - guardringw1
        local guardringheight = guardringh2 - guardringh1
        local firstguardring = pcell.create_layout("auxiliary/guardring", "_firstguardring", {
            contype = "n",
            ringwidth = _P.guardringwidth,
            holewidth = guardringwidth + 2 * _P.guardringspace,
            holeheight = guardringheight + 2 * _P.guardringspace,
            fillwell = false,
            drawdeepwell = true,
            deepwelloffset = _P.guardringdeepwelloffset,
        })
        firstguardring:move_point(
            firstguardring:get_area_anchor("innerboundary").bl,
            point.create(
                guardringw1,
                guardringh1
            )
        )
        firstguardring:translate(-_P.guardringspace, -_P.guardringspace)
        inverter:merge_into(firstguardring)
        geometry.rectanglebltr(inverter, generics.well("n"),
            firstguardring:get_area_anchor("outerwell").bl,
            point.create(
                firstguardring:get_area_anchor("outerwell").r,
                inverter:get_area_anchor("nmos_well").t
            )
        )
    end

    inverter:add_area_anchor_bltr("input",
        point.create(
            cmos:get_area_anchor(string.format("G%d", 1 + _P.numleftdummies)).l - _P.gatestrapleftextension,
            cmos:get_area_anchor(string.format("G%d", 1 + _P.numleftdummies)).b
        ),
        cmos:get_area_anchor(string.format("G%d", _P.fingers + _P.numleftdummies)).tr
    )

end
