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
        { "pgateext",                                   0 },
        { "ngateext",                                   0 },
        { "gatelength(Gate Length)",                    technology.get_dimension("Minimum Gate Length") },
        { "gatespace(Gate Spacing)",                    technology.get_dimension("Minimum Gate XSpace") },
        { "gatemetal",                                  1 },
        { "sdwidth(Source/Drain Metal Width)",          technology.get_dimension("Minimum M1 Width"), posvals = even() },
        { "gatestrapwidth(Gate Metal Width)",           technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace(Gate Metal Space)",           technology.get_dimension("Minimum M1 Width") },
        { "drawoutergatecut",                           false },
        { "gatecutheight",                              0 },
        { "outergatecutyshift",                         0 },
        { "gatestrapleftextension",                     0 },
        { "gatestraprightextension",                    0 },
        { "powerwidth(Power Rail Metal Width)",         technology.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",               technology.get_dimension("Minimum M1 Space") },
        { "numleftdummies",                             2 },
        { "numrightdummies",                            2 },
        { "alternatedummycontacts",                 false },
        { "outputmetal",                                2, posvals = interval(2, inf) },
        { "outputwidth",                                technology.get_dimension("Minimum M1 Width") },
        { "outputxshift",                               0 },
        { "outputyshift",                               0 },
        { "dummycontshift",                             0 },
        { "extendoutputmetal",                          0 },
        { "dummycontheight",                            technology.get_dimension("Minimum M1 Width"), follow = "powerwidth" },
        { "dummycontshift",                             0 },
        { "psddummyouterheight",                        2 * technology.get_dimension("Minimum Gate Width"), follow = "pwidth" },
        { "nsddummyouterheight",                        2 * technology.get_dimension("Minimum Gate Width"), follow = "nwidth" },
        { "drawleftstopgate",                           false },
        { "drawrightstopgate",                          false },
        { "leftpolylines",                              {} },
        { "rightpolylines",                             {} },
        { "extendalltop",                               0 },
        { "extendallbottom",                            0 },
        { "extendallleft",                              0 },
        { "extendallright",                             0 },
        { "extendimplanttop",                           0, follow = "extendalltop" },
        { "extendimplantbottom",                        0, follow = "extendallbottom" },
        { "extendimplantleft",                          0, follow = "extendallleft" },
        { "extendimplantright",                         0, follow = "extendallright" },
        { "extendoxidetypetop",                         0, follow = "extendalltop" },
        { "extendoxidetypebottom",                      0, follow = "extendallbottom" },
        { "extendoxidetypeleft",                        0, follow = "extendallleft" },
        { "extendoxidetyperight",                       0, follow = "extendallright" },
        { "extendvthtypetop",                           0, follow = "extendalltop" },
        { "extendvthtypebottom",                        0, follow = "extendallbottom" },
        { "extendvthtypeleft",                          0, follow = "extendallleft" },
        { "extendvthtyperight",                         0, follow = "extendallright" },
        { "extendwelltop",                              0, follow = "extendalltop" },
        { "extendwellbottom",                           0, follow = "extendallbottom" },
        { "extendwellleft",                             0, follow = "extendallleft" },
        { "extendwellright",                            0, follow = "extendallright" },
        { "resistorplacement",                          "right", posvals = set("left", "right", "both") },
        { "resistorwidth",                              400 },
        { "resistorlength",                             200 },
        { "resistorextension",                          100 },
        { "resistorcontactheight",                      100 },
        { "resistorxshift",                             500 },
        { "connectinverse",                             false },
        { "drawleftnmoswelltap",                        false },
        { "drawrightnmoswelltap",                       false },
        { "connectnmoswelltap",                         false },
        { "nmoswelltapwidth",                           200 },
        { "nmoswelltapshrink",                          0 },
        { "nmoswelltapshift",                           500 },
        { "nmoswelltapwellextension",                   0 },
        { "drawleftpmoswelltap",                        false },
        { "drawrightpmoswelltap",                       false },
        { "connectpmoswelltap",                         false },
        { "pmoswelltapwidth",                           200 },
        { "pmoswelltapshrink",                          0 },
        { "pmoswelltapshift",                           500 },
        { "pmoswelltapwellextension",                   0 }
    )
end

function layout(sbinv, _P)
    local xpitch = _P.gatespace + _P.gatelength

    local inverter = pcell.create_layout("analog/inverter", "_inverter", {
        fingers = _P.fingers,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        oxidetype = _P.oxidetype,
        gatemarker = _P.gatemarker,
        pvthtype = _P.pvthtype,
        nvthtype = _P.nvthtype,
        pmosflippedwell = _P.pmosflippedwell,
        nmosflippedwell = _P.nmosflippedwell,
        pgateext = _P.pgateext,
        ngateext = _P.ngateext,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        gatemetal = _P.gatemetal,
        sdwidth = _P.sdwidth,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        drawoutergatecut = _P.drawoutergatecut,
        gatecutheight = _P.gatecutheight,
        outergatecutyshift = _P.outergatecutyshift,
        gatestrapleftextension = _P.gatestrapleftextension,
        gatestraprightextension = _P.gatestraprightextension,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        numleftdummies = _P.numleftdummies,
        numrightdummies = _P.numrightdummies,
        alternatedummycontacts = _P.alternatedummycontacts,
        outputmetal = _P.outputmetal,
        outputwidth = _P.outputwidth,
        outputxshift = _P.outputxshift,
        outputyshift = _P.outputyshift,
        dummycontshift = _P.dummycontshift,
        outputisinside = false,
        extendoutputmetal = _P.extendoutputmetal,
        dummycontheight = _P.dummycontheight,
        dummycontshift = _P.dummycontshift,
        psddummyouterheight = _P.psddummyouterheight,
        nsddummyouterheight = _P.nsddummyouterheight,
        drawleftstopgate = _P.drawleftstopgate,
        drawrightstopgate = _P.drawrightstopgate,
        leftpolylines = _P.leftpolylines,
        rightpolylines = _P.rightpolylines,
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
        drawleftnmoswelltap = _P.drawleftnmoswelltap,
        drawrightnmoswelltap = _P.drawrightnmoswelltap,
        connectnmoswelltap = _P.connectnmoswelltap,
        nmoswelltapwidth = _P.nmoswelltapwidth,
        nmoswelltapshrink = _P.nmoswelltapshrink,
        nmoswelltapshift = _P.nmoswelltapshift,
        nmoswelltapwellextension = _P.nmoswelltapwellextension,
        drawleftpmoswelltap = _P.drawleftpmoswelltap,
        drawrightpmoswelltap = _P.drawrightpmoswelltap,
        connectpmoswelltap = _P.connectpmoswelltap,
        pmoswelltapwidth = _P.pmoswelltapwidth,
        pmoswelltapshrink = _P.pmoswelltapshrink,
        pmoswelltapshift = _P.pmoswelltapshift,
        pmoswelltapwellextension = _P.pmoswelltapwellextension,
    })
    sbinv:merge_into(inverter)

    -- resistor
    local resistor = pcell.create_layout("basic/polyresistor", "_resistor", {
        width = _P.resistorwidth,
        length = _P.resistorlength,
        extension = _P.resistorextension,
        contactheight = _P.resistorcontactheight,
    })
    local resistor_upper = resistor:copy()
    local resistor_lower = resistor:copy()
    if _P.resistorplacement == "right" then
        resistor_upper:mirror_at_xaxis()
        resistor_lower:move_point(resistor_lower:get_area_anchor("plus").tl, inverter:get_area_anchor("nmos_active").tr)
        resistor_lower:translate_x(_P.resistorxshift)
        resistor_upper:move_point(resistor_upper:get_area_anchor("plus").bl, inverter:get_area_anchor("pmos_active").br)
        resistor_upper:translate_x(_P.resistorxshift)
    elseif _P.resistorplacement == "left" then
        resistor_upper:mirror_at_xaxis()
        resistor_lower:move_point(resistor_lower:get_area_anchor("plus").tr, inverter:get_area_anchor("nmos_active").tl)
        resistor_lower:translate_x(-_P.resistorxshift)
        resistor_upper:move_point(resistor_upper:get_area_anchor("plus").br, inverter:get_area_anchor("pmos_active").bl)
        resistor_upper:translate_x(-_P.resistorxshift)
    else -- _P.resistorplacement == "both"
    end
    sbinv:merge_into(resistor_upper)
    sbinv:merge_into(resistor_lower)

    -- alignment boxes
    sbinv:inherit_alignment_box(inverter)
    sbinv:inherit_alignment_box(resistor_upper)
    sbinv:inherit_alignment_box(resistor_lower)

    -- connect resistors
    if _P.resistorplacement == "right" then
        if _P.connectinverse then
            geometry.rectanglebltr(sbinv, generics.metal(_P.gatemetal),
                resistor_lower:get_area_anchor("plus").tl,
                resistor_upper:get_area_anchor("plus").br
            )
            geometry.rectanglebltr(sbinv, generics.metal(_P.gatemetal),
                point.create(
                    inverter:get_area_anchor("input").r,
                    inverter:get_area_anchor("input").b
                ),
                point.create(
                    resistor_lower:get_area_anchor("plus").r,
                    inverter:get_area_anchor("input").t
                )
            )
            geometry.viabltr(sbinv, 1, _P.gatemetal,
                resistor_upper:get_area_anchor("plus").bl,
                point.create(
                    resistor_upper:get_area_anchor("plus").r,
                    resistor_upper:get_area_anchor("plus").b + _P.gatestrapwidth
                )
            )
            geometry.viabltr(sbinv, 1, _P.gatemetal,
                point.create(
                    resistor_lower:get_area_anchor("plus").l,
                    resistor_lower:get_area_anchor("plus").t - _P.gatestrapwidth
                ),
                resistor_lower:get_area_anchor("plus").tr
            )
            geometry.polygon(sbinv, generics.metal(_P.outputmetal), {
                inverter:get_area_anchor("upperoutput").br,
                point.create(
                    inverter:get_area_anchor("upperoutput").r + _P.resistorxshift / 2,
                    inverter:get_area_anchor("upperoutput").b
                ),
                point.create(
                    inverter:get_area_anchor("upperoutput").r + _P.resistorxshift / 2,
                    resistor_upper:get_area_anchor("minus").b
                ),
                point.create(
                    resistor_upper:get_area_anchor("minus").l,
                    resistor_upper:get_area_anchor("minus").b
                ),
                point.create(
                    resistor_upper:get_area_anchor("minus").l,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                ),
                point.create(
                    inverter:get_area_anchor("upperoutput").r + _P.resistorxshift / 2 - _P.outputwidth,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                ),
                point.create(
                    inverter:get_area_anchor("upperoutput").r + _P.resistorxshift / 2 - _P.outputwidth,
                    inverter:get_area_anchor("upperoutput").t
                ),
                inverter:get_area_anchor("upperoutput").tr,
            })
            geometry.polygon(sbinv, generics.metal(_P.outputmetal), {
                inverter:get_area_anchor("loweroutput").br,
                point.create(
                    inverter:get_area_anchor("loweroutput").r + _P.resistorxshift / 2 - _P.outputwidth,
                    inverter:get_area_anchor("loweroutput").b
                ),
                point.create(
                    inverter:get_area_anchor("loweroutput").r + _P.resistorxshift / 2 - _P.outputwidth,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                point.create(
                    resistor_lower:get_area_anchor("minus").l,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                point.create(
                    resistor_lower:get_area_anchor("minus").l,
                    resistor_lower:get_area_anchor("minus").t
                ),
                point.create(
                    inverter:get_area_anchor("loweroutput").r + _P.resistorxshift / 2,
                    resistor_lower:get_area_anchor("minus").t
                ),
                point.create(
                    inverter:get_area_anchor("loweroutput").r + _P.resistorxshift / 2,
                    inverter:get_area_anchor("loweroutput").t
                ),
                inverter:get_area_anchor("loweroutput").tr,
            })
            geometry.viabltr(sbinv, 1, _P.outputmetal,
                resistor_upper:get_area_anchor("minus").bl,
                point.create(
                    resistor_upper:get_area_anchor("minus").r,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                )
            )
            geometry.viabltr(sbinv, 1, _P.outputmetal,
                point.create(
                    resistor_lower:get_area_anchor("minus").l,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                resistor_lower:get_area_anchor("minus").tr
            )
        else
            geometry.rectanglebltr(sbinv, generics.metal(_P.outputmetal),
                resistor_lower:get_area_anchor("plus").tl,
                resistor_upper:get_area_anchor("plus").br
            )
            geometry.rectanglebltr(sbinv, generics.metal(_P.outputmetal),
                point.create(
                    inverter:get_area_anchor("output").r,
                    (inverter:get_area_anchor("output").b + inverter:get_area_anchor("output").t) / 2 - _P.outputwidth / 2
                ),
                point.create(
                    resistor_lower:get_area_anchor("plus").r,
                    (inverter:get_area_anchor("output").b + inverter:get_area_anchor("output").t) / 2 + _P.outputwidth / 2
                )
            )
            geometry.viabltr(sbinv, 1, _P.outputmetal,
                resistor_upper:get_area_anchor("plus").bl,
                point.create(
                    resistor_upper:get_area_anchor("plus").r,
                    resistor_upper:get_area_anchor("plus").b + _P.gatestrapwidth
                )
            )
            geometry.viabltr(sbinv, 1, _P.outputmetal,
                point.create(
                    resistor_lower:get_area_anchor("plus").l,
                    resistor_lower:get_area_anchor("plus").t - _P.gatestrapwidth
                ),
                resistor_lower:get_area_anchor("plus").tr
            )
            geometry.polygon(sbinv, generics.metal(_P.gatemetal), {
                inverter:get_area_anchor("input").br,
                point.create(
                    inverter:get_area_anchor("input").r + _P.resistorxshift / 2,
                    inverter:get_area_anchor("input").b
                ),
                point.create(
                    inverter:get_area_anchor("input").r + _P.resistorxshift / 2,
                    resistor_upper:get_area_anchor("minus").b
                ),
                point.create(
                    resistor_upper:get_area_anchor("minus").l,
                    resistor_upper:get_area_anchor("minus").b
                ),
                point.create(
                    resistor_upper:get_area_anchor("minus").l,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                ),
                point.create(
                    inverter:get_area_anchor("input").r + _P.resistorxshift / 2 - _P.outputwidth,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                ),
                point.create(
                    inverter:get_area_anchor("input").r + _P.resistorxshift / 2 - _P.outputwidth,
                    inverter:get_area_anchor("input").t
                ),
                inverter:get_area_anchor("input").tr,
            })
            geometry.polygon(sbinv, generics.metal(_P.gatemetal), {
                inverter:get_area_anchor("input").br,
                point.create(
                    inverter:get_area_anchor("input").r + _P.resistorxshift / 2 - _P.outputwidth,
                    inverter:get_area_anchor("input").b
                ),
                point.create(
                    inverter:get_area_anchor("input").r + _P.resistorxshift / 2 - _P.outputwidth,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                point.create(
                    resistor_lower:get_area_anchor("minus").l,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                point.create(
                    resistor_lower:get_area_anchor("minus").l,
                    resistor_lower:get_area_anchor("minus").t
                ),
                point.create(
                    inverter:get_area_anchor("input").r + _P.resistorxshift / 2,
                    resistor_lower:get_area_anchor("minus").t
                ),
                point.create(
                    inverter:get_area_anchor("input").r + _P.resistorxshift / 2,
                    inverter:get_area_anchor("input").t
                ),
                inverter:get_area_anchor("input").tr,
            })
            geometry.viabltr(sbinv, 1, _P.gatemetal,
                resistor_upper:get_area_anchor("minus").bl,
                point.create(
                    resistor_upper:get_area_anchor("minus").r,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                )
            )
            geometry.viabltr(sbinv, 1, _P.gatemetal,
                point.create(
                    resistor_lower:get_area_anchor("minus").l,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                resistor_lower:get_area_anchor("minus").tr
            )
        end
    elseif _P.resistorplacement == "left" then
        if _P.connectinverse then
            geometry.rectanglebltr(sbinv, generics.metal(_P.gatemetal),
                resistor_lower:get_area_anchor("plus").tl,
                resistor_upper:get_area_anchor("plus").br
            )
            geometry.rectanglebltr(sbinv, generics.metal(_P.gatemetal),
                point.create(
                    inverter:get_area_anchor("input").r,
                    inverter:get_area_anchor("input").b
                ),
                point.create(
                    resistor_lower:get_area_anchor("plus").r,
                    inverter:get_area_anchor("input").t
                )
            )
            geometry.viabltr(sbinv, 1, _P.gatemetal,
                resistor_upper:get_area_anchor("plus").bl,
                point.create(
                    resistor_upper:get_area_anchor("plus").r,
                    resistor_upper:get_area_anchor("plus").b + _P.gatestrapwidth
                )
            )
            geometry.viabltr(sbinv, 1, _P.gatemetal,
                point.create(
                    resistor_lower:get_area_anchor("plus").l,
                    resistor_lower:get_area_anchor("plus").t - _P.gatestrapwidth
                ),
                resistor_lower:get_area_anchor("plus").tr
            )
            geometry.polygon(sbinv, generics.metal(_P.outputmetal), {
                inverter:get_area_anchor("upperoutput").br,
                point.create(
                    inverter:get_area_anchor("upperoutput").r + _P.resistorxshift / 2,
                    inverter:get_area_anchor("upperoutput").b
                ),
                point.create(
                    inverter:get_area_anchor("upperoutput").r + _P.resistorxshift / 2,
                    resistor_upper:get_area_anchor("minus").b
                ),
                point.create(
                    resistor_upper:get_area_anchor("minus").l,
                    resistor_upper:get_area_anchor("minus").b
                ),
                point.create(
                    resistor_upper:get_area_anchor("minus").l,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                ),
                point.create(
                    inverter:get_area_anchor("upperoutput").r + _P.resistorxshift / 2 - _P.outputwidth,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                ),
                point.create(
                    inverter:get_area_anchor("upperoutput").r + _P.resistorxshift / 2 - _P.outputwidth,
                    inverter:get_area_anchor("upperoutput").t
                ),
                inverter:get_area_anchor("upperoutput").tr,
            })
            geometry.polygon(sbinv, generics.metal(_P.outputmetal), {
                inverter:get_area_anchor("loweroutput").br,
                point.create(
                    inverter:get_area_anchor("loweroutput").r + _P.resistorxshift / 2 - _P.outputwidth,
                    inverter:get_area_anchor("loweroutput").b
                ),
                point.create(
                    inverter:get_area_anchor("loweroutput").r + _P.resistorxshift / 2 - _P.outputwidth,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                point.create(
                    resistor_lower:get_area_anchor("minus").l,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                point.create(
                    resistor_lower:get_area_anchor("minus").l,
                    resistor_lower:get_area_anchor("minus").t
                ),
                point.create(
                    inverter:get_area_anchor("loweroutput").r + _P.resistorxshift / 2,
                    resistor_lower:get_area_anchor("minus").t
                ),
                point.create(
                    inverter:get_area_anchor("loweroutput").r + _P.resistorxshift / 2,
                    inverter:get_area_anchor("loweroutput").t
                ),
                inverter:get_area_anchor("loweroutput").tr,
            })
            geometry.viabltr(sbinv, 1, _P.outputmetal,
                resistor_upper:get_area_anchor("minus").bl,
                point.create(
                    resistor_upper:get_area_anchor("minus").r,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                )
            )
            geometry.viabltr(sbinv, 1, _P.outputmetal,
                point.create(
                    resistor_lower:get_area_anchor("minus").l,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                resistor_lower:get_area_anchor("minus").tr
            )
        else
            geometry.rectanglebltr(sbinv, generics.metal(_P.outputmetal),
                resistor_lower:get_area_anchor("plus").tl,
                resistor_upper:get_area_anchor("plus").br
            )
            geometry.rectanglebltr(sbinv, generics.metal(_P.outputmetal),
                point.create(
                    resistor_lower:get_area_anchor("plus").r,
                    (inverter:get_area_anchor("output").b + inverter:get_area_anchor("output").t) / 2 - _P.outputwidth / 2
                ),
                point.create(
                    inverter:get_area_anchor("output").r,
                    (inverter:get_area_anchor("output").b + inverter:get_area_anchor("output").t) / 2 + _P.outputwidth / 2
                )
            )
            geometry.viabltr(sbinv, 1, _P.outputmetal,
                resistor_upper:get_area_anchor("plus").bl,
                point.create(
                    resistor_upper:get_area_anchor("plus").r,
                    resistor_upper:get_area_anchor("plus").b + _P.gatestrapwidth
                )
            )
            geometry.viabltr(sbinv, 1, _P.outputmetal,
                point.create(
                    resistor_lower:get_area_anchor("plus").l,
                    resistor_lower:get_area_anchor("plus").t - _P.gatestrapwidth
                ),
                resistor_lower:get_area_anchor("plus").tr
            )
            geometry.polygon(sbinv, generics.metal(_P.gatemetal), {
                inverter:get_area_anchor("input").bl,
                point.create(
                    inverter:get_area_anchor("input").l - _P.resistorxshift / 2,
                    inverter:get_area_anchor("input").b
                ),
                point.create(
                    inverter:get_area_anchor("input").l - _P.resistorxshift / 2,
                    resistor_upper:get_area_anchor("minus").b
                ),
                point.create(
                    resistor_upper:get_area_anchor("minus").r,
                    resistor_upper:get_area_anchor("minus").b
                ),
                point.create(
                    resistor_upper:get_area_anchor("minus").r,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                ),
                point.create(
                    inverter:get_area_anchor("input").l - _P.resistorxshift / 2 + _P.outputwidth,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                ),
                point.create(
                    inverter:get_area_anchor("input").l - _P.resistorxshift / 2 + _P.outputwidth,
                    inverter:get_area_anchor("input").t
                ),
                inverter:get_area_anchor("input").tl,
            })
            geometry.polygon(sbinv, generics.metal(_P.gatemetal), {
                inverter:get_area_anchor("input").bl,
                point.create(
                    inverter:get_area_anchor("input").l - _P.resistorxshift / 2 + _P.outputwidth,
                    inverter:get_area_anchor("input").b
                ),
                point.create(
                    inverter:get_area_anchor("input").l - _P.resistorxshift / 2 + _P.outputwidth,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                point.create(
                    resistor_lower:get_area_anchor("minus").r,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                point.create(
                    resistor_lower:get_area_anchor("minus").r,
                    resistor_lower:get_area_anchor("minus").t
                ),
                point.create(
                    inverter:get_area_anchor("input").l - _P.resistorxshift / 2,
                    resistor_lower:get_area_anchor("minus").t
                ),
                point.create(
                    inverter:get_area_anchor("input").l - _P.resistorxshift / 2,
                    inverter:get_area_anchor("input").t
                ),
                inverter:get_area_anchor("input").tl,
            })
            geometry.viabltr(sbinv, 1, _P.gatemetal,
                resistor_upper:get_area_anchor("minus").bl,
                point.create(
                    resistor_upper:get_area_anchor("minus").r,
                    resistor_upper:get_area_anchor("minus").b + _P.outputwidth
                )
            )
            geometry.viabltr(sbinv, 1, _P.gatemetal,
                point.create(
                    resistor_lower:get_area_anchor("minus").l,
                    resistor_lower:get_area_anchor("minus").t - _P.outputwidth
                ),
                resistor_lower:get_area_anchor("minus").tr
            )
        end
    end

    -- inherit anchors
    sbinv:inherit_area_anchor(inverter, "input")
    sbinv:add_area_anchor_points("output",
        resistor_lower:get_area_anchor("plus").tl,
        resistor_upper:get_area_anchor("plus").br
    )
    sbinv:inherit_area_anchor(inverter, "output")
    sbinv:inherit_area_anchor(inverter, "vddbar")
    sbinv:inherit_area_anchor(inverter, "vssbar")
    sbinv:inherit_area_anchor(inverter, "nmos_implant")
    sbinv:inherit_area_anchor(inverter, "pmos_implant")
    sbinv:inherit_area_anchor(inverter, "nmos_well")
    sbinv:inherit_area_anchor(inverter, "pmos_well")
    sbinv:inherit_area_anchor(inverter, "nmos_active")
    sbinv:inherit_area_anchor(inverter, "pmos_active")
    if _P.drawleftnmoswelltap then
        sbinv:inherit_area_anchor(inverter, "left_nmos_welltap_well")
        sbinv:inherit_area_anchor(inverter, "left_nmos_welltap_implant")
    end
    if _P.drawrightnmoswelltap then
        sbinv:inherit_area_anchor(inverter, "right_nmos_welltap_well")
        sbinv:inherit_area_anchor(inverter, "right_nmos_welltap_implant")
    end
    if _P.drawleftpmoswelltap then
        sbinv:inherit_area_anchor(inverter, "left_pmos_welltap_well")
        sbinv:inherit_area_anchor(inverter, "left_pmos_welltap_implant")
    end
    if _P.drawrightpmoswelltap then
        sbinv:inherit_area_anchor(inverter, "right_pmos_welltap_well")
        sbinv:inherit_area_anchor(inverter, "right_pmos_welltap_implant")
    end
end
