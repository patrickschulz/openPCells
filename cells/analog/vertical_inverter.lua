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
        { "extendimplanttop",                           0 },
        { "extendimplantbottom",                        0 },
        { "extendimplantleft",                          0 },
        { "extendimplantright",                         0 },
        { "extendoxidetypetop",                         0 },
        { "extendoxidetypebottom",                      0 },
        { "extendoxidetypeleft",                        0 },
        { "extendoxidetyperight",                       0 },
        { "extendvthtypetop",                           0 },
        { "extendvthtypebottom",                        0 },
        { "extendvthtypeleft",                          0 },
        { "extendvthtyperight",                         0 },
        { "extendwelltop",                              0 },
        { "extendwellbottom",                           0 },
        { "extendwellleft",                             0 },
        { "extendwellright",                            0 }
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
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
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
        extendallleft = _P.gatelength + _P.gatespace,
        extendallright = _P.gatelength + _P.gatespace,
        vthtypealignwithactive = true,
        extendvthtypetop = 100,
        extendvthtypebottom = 100,
        extendvthtypeleft = 208 + 50,
        extendvthtyperight = 208 + 50,
        sourcealign = "top",
        drainalign = "bottom",
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
        -- guard ring
        --drawguardring = _P.nmosflippedwell == _P.pmosflippedwell, -- only place local guardrings if not connected to the same well
        --guardringrespectactivedummy = true,
        --guardringwidth = 100,
        --guardringleftsep = 3 * (_P.gatelength + _P.gatespace),
        --guardringrightsep = 3 * (_P.gatelength + _P.gatespace),
        --guardringtopsep = _P.guardring.innerysep,
        --guardringwellextension = _P.guardring.wellextension,
        --guardringimplantextension = _P.guardring.implantextension,
        --guardringfillimplant = true,
        --guardringsoiopenextension = _P.guardring.soiopenextension,
        -- stop gates
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
        --guardringbottomsep = _P.guardring.innerysep + math.max(_P.nwidth - _P.pwidth, 0),
    }))
    if _P.nmosflippedwell == _P.pmosflippedwell then
        pmos:align_top(nmos)
        pmos:abut_right(nmos)
        pmos:translate_x(2 * (_P.gatelength + _P.gatespace))
        --pmos:translate_x(_P.guardring.innerwidth + 2 * _P.guardring.wellextension)
    else
        pmos:align_area_anchor("leftpolyline3", nmos, "rightpolyline3")
        pmos:align_top(nmos)
    end
    inverter:merge_into(nmos)
    inverter:merge_into(pmos)

    if _P.nmosflippedwell == _P.pmosflippedwell then
        inverter:inherit_alignment_box(nmos)
        inverter:inherit_alignment_box(pmos)
    else
        inverter:set_alignment_box(
            nmos:get_area_anchor("leftpolyline3").bl,
            pmos:get_area_anchor("rightpolyline3").tr,
            nmos:get_area_anchor("leftpolyline3").br,
            pmos:get_area_anchor("rightpolyline3").tl
        )
    end

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
