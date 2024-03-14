function parameters()
    pcell.add_parameters(
        { "nmosfingers(Number of Fingers for nMOS)",    2 },
        { "pmosfingers(Number of Fingers for pMOS)",    2 },
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
        { "gateleftextension",                          0 },
        { "gaterightextension",                         0 },
        { "drawinnergatecut",                           false },
        { "drawoutergatecut",                           false },
        { "gatecutheight",                              0 },
        { "gatemetal",                                  1 },
        { "drawtopgate",                                true },
        { "drawbotgate",                                false },
        { "sdwidth(Source/Drain Metal Width)",          technology.get_dimension("Minimum M1 Width"), posvals = even() },
        { "gatestrapwidth(Gate Metal Width)",           technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace(Gate Metal Space)",           technology.get_dimension("Minimum M1 Width") },
        { "gatestrapleftextension",                     0 },
        { "gatestraprightextension",                    0 },
        { "powermetal",                                 1 },
        { "powerwidth(Power Rail Metal Width)",         technology.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",               technology.get_dimension("Minimum M1 Space") },
        { "vddwidth",                                   technology.get_dimension("Minimum M1 Width"), follow = "powerwidth" },
        { "vddspace",                                   technology.get_dimension("Minimum M1 Space"), follow = "powerspace" },
        { "vsswidth",                                   technology.get_dimension("Minimum M1 Width"), follow = "powerwidth" },
        { "vssspace",                                   technology.get_dimension("Minimum M1 Space"), follow = "powerspace" },
        { "pgateext",                                   0 },
        { "ngateext",                                   0 },
        { "numleftdummies",                             0 },
        { "numrightdummies",                            0 },
        { "alternatedummycontacts",                     false },
        { "outputmetal",                                2, posvals = interval(2, inf) },
        { "outputwidth",                                technology.get_dimension("Minimum M1 Width") },
        { "outputspace",                                technology.get_dimension("Minimum M1 Space") },
        { "extendoutputmetal",                          0 },
        { "dummycontheight",                            technology.get_dimension("Minimum M1 Width"), follow = "powerwidth" },
        { "dummycontshift",                             0 },
        { "psddummyouterheight",                        2 * technology.get_dimension("Minimum Gate Width"), follow = "pwidth" },
        { "nsddummyouterheight",                        2 * technology.get_dimension("Minimum Gate Width"), follow = "nwidth" },
        { "outputisinside",                             false },
        { "drawleftstopgate",                           false },
        { "drawrightstopgate",                          false },
        { "leftpolylines",                              {} },
        { "rightpolylines",                             {} },
        { "drawleftrightactivedummies",                 false },
        { "drawtopbottomactivedummies",                 false },
        { "implantalignwithactive",                     false },
        { "oxidetypealignwithactive",                   false },
        { "vthtypealignwithactive",                     false },
        { "extendalltop",                               0 },
        { "extendallbottom",                            0 },
        { "extendallleft",                              0 },
        { "extendallright",                             0 },
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
        { "extendwellright",                            0, follow = "extendallright" }
    )
end

function layout(inverter, _P)
    local baseoptions = {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        sdwidth = _P.sdwidth,
        connectdrain = true,
        connectdrainwidth = _P.outputwidth,
        connectdrainspace = _P.outputspace,
        drainmetal = _P.outputmetal,
        connectsource = true,
        sourcemetal = _P.powermetal,
        drawtopgate = _P.drawtopgate,
        topgatemetal = _P.gatemetal,
        gtopextadd = 10,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        topgateleftextension = _P.gateleftextension,
        topgaterightextension = _P.gaterightextension,
        drawbotgate = _P.drawbotgate,
        botgatemetal = _P.gatemetal,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.gatestrapspace,
        botgateleftextension = _P.gateleftextension,
        botgaterightextension = _P.gaterightextension,
        oxidetype = _P.oxidetype,
        implantalignwithactive = true,
        vthtypealignwithactive = true,
        oxidetypealignwithactive = true,
        extendvthtypetop = _P.extendvthtypetop,
        extendvthtypebottom = _P.extendvthtypebottom,
        extendvthtypeleft = _P.extendvthtypeleft,
        extendvthtyperight = _P.extendvthtyperight,
        extendoxidetypetop = _P.extendoxidetypetop,
        extendoxidetypebottom = _P.extendoxidetypebottom,
        extendoxidetypeleft = _P.extendoxidetypeleft,
        extendoxidetyperight = _P.extendoxidetyperight,
        extendimplanttop = _P.extendimplanttop,
        extendimplantbottom = _P.extendimplantbottom,
        extendimplantleft = _P.extendimplantleft,
        extendimplantright = _P.extendimplantright,
        drawleftactivedummy = _P.drawleftrightactivedummies,
        leftactivedummywidth = _P.gatelength + _P.gatespace,
        leftactivedummyspace = _P.gatelength + _P.gatespace,
        drawrightactivedummy = _P.drawleftrightactivedummies,
        rightactivedummywidth = _P.gatelength + _P.gatespace,
        rightactivedummyspace = _P.gatelength + _P.gatespace,
        drawtopactivedummy = _P.drawtopbottomactivedummies,
        topactivedummywidth = 100,
        topactivedummyspace = 300,
        drawbottomactivedummy = _P.drawtopbottomactivedummies,
        bottomactivedummywidth = 100,
        bottomactivedummyspace = 300,
        drawrightstopgate = true,
        drawleftstopgate = true,
        rightpolylines = _P.rightpolylines,
        leftpolylines = _P.leftpolylines,
    }

    local nmos = pcell.create_layout("basic/mosfet", "_nmos", util.add_options(baseoptions, {
        fingers = _P.nmosfingers,
        flippedwell = _P.nmosflippedwell,
        fingerwidth = _P.nwidth,
        channeltype = "nmos",
        gbotextadd = (_P.nwidth == not _P.pmosflippedwell) and math.max(_P.pwidth - _P.nwidth, 10) or 10,
        vthtype = _P.nvthtype,
        connectsourcewidth = _P.vsswidth,
        connectsourcespace = _P.vssspace,
        --guardringbottomsep = _P.guardring.innerysep + math.max(_P.pwidth - _P.nwidth, 0),
        --guardringfillwell = true,
    }))
    local pmos = pcell.create_layout("basic/mosfet", "_pmos", util.add_options(baseoptions, {
        fingers = _P.pmosfingers,
        flippedwell = _P.pmosflippedwell,
        fingerwidth = _P.pwidth,
        vthtype = _P.pvthtype,
        channeltype = "pmos",
        gbotextadd = (_P.nwidth == not _P.pmosflippedwell) and math.max(_P.nwidth - _P.pwidth, 10) or 10,
        connectdraininverse = true,
        connectsourceinverse = true,
        connectsourcewidth = _P.vddwidth,
        connectsourcespace = _P.vddspace,
        --guardringbottomsep = _P.guardring.innerysep + math.max(_P.nwidth - _P.pwidth, 0),
    }))
    pmos:align_top(nmos)
    pmos:abut_right(nmos)
    pmos:translate_x(2 * (_P.gatelength + _P.gatespace))
    inverter:merge_into(nmos)
    inverter:merge_into(pmos)

    inverter:inherit_alignment_box(nmos)
    inverter:inherit_alignment_box(pmos)

    -- gate connections
    if _P.drawtopgate then
        inverter:add_area_anchor_bltr("topinput",
            nmos:get_area_anchor("topgatestrap").bl,
            pmos:get_area_anchor("topgatestrap").tr
        )
        geometry.rectanglebltr(inverter, generics.metal(_P.gatemetal),
            inverter:get_area_anchor("topinput").bl,
            inverter:get_area_anchor("topinput").tr
        )
    end
    if _P.drawbotgate then
        inverter:add_area_anchor_bltr("botinput",
            nmos:get_area_anchor("botgatestrap").bl,
            pmos:get_area_anchor("botgatestrap").tr
        )
        geometry.rectanglebltr(inverter, generics.metal(_P.gatemetal),
            inverter:get_area_anchor("botinput").bl,
            inverter:get_area_anchor("botinput").tr
        )
    end

    -- output connections
    inverter:add_area_anchor_bltr("output",
        nmos:get_area_anchor("drainstrap").bl,
        pmos:get_area_anchor("drainstrap").tr
    )
    geometry.rectanglebltr(inverter, generics.metal(_P.outputmetal),
        inverter:get_area_anchor("output").bl,
        inverter:get_area_anchor("output").tr
    )

    -- power bar anchors
    inverter:add_area_anchor_bltr("vssbar",
        nmos:get_area_anchor("sourcestrap").bl,
        nmos:get_area_anchor("sourcestrap").tr
    )
    inverter:add_area_anchor_bltr("vddbar",
        pmos:get_area_anchor("sourcestrap").bl,
        pmos:get_area_anchor("sourcestrap").tr
    )
end
