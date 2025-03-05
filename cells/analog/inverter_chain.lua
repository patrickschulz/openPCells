function parameters()
    pcell.add_parameters(
        { "fingers",                                    { 2, 4 } },
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
        { "drawoutergatecut",                           false },
        { "gatecutheight",                              0 },
        { "gatemetal",                                  1 },
        { "sdwidth(Source/Drain Metal Width)",          technology.get_dimension("Minimum M1 Width"), posvals = even() },
        { "gatestrapwidth(Gate Metal Width)",           technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace(Gate Metal Space)",           technology.get_dimension("Minimum M1 Width") },
        { "gatestrapleftextension",                     0 },
        { "gatestraprightextension",                     0 },
        { "powerwidth(Power Rail Metal Width)",         technology.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",               technology.get_dimension("Minimum M1 Space") },
        { "pgateext",                                   0 },
        { "ngateext",                                   0 },
        { "numleftdummies",                             2 },
        { "numrightdummies",                            2 },
        { "numinnerdummies",                            2 },
        { "alternatedummycontacts",                     false },
        { "drawalternatedummycontactspowerbarvia",      false, follow = "alternatedummycontacts" },
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
        { "leftpolylines",                              {} },
        { "rightpolylines",                             {} },
        { "drawanalogmarker",                           false },
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
        { "extendwellright",                            0 },
        { "flat",                                       true }
    )
end

function layout(chain, _P)
    local inverters = {}
    for i, fingers in ipairs(_P.fingers) do
        local inv = pcell.create_layout("analog/inverter", string.format("inv_%d", i), {
            fingers = fingers,
            pwidth = _P.pwidth,
            nwidth = _P.nwidth,
            oxidetype = _P.oxidetype,
            gatemarker = _P.gatemarker,
            pvthtype = _P.pvthtype,
            nvthtype = _P.nvthtype,
            pmosflippedwell = _P.pmosflippedwell,
            nmosflippedwell = _P.nmosflippedwell,
            gatelength = _P.gatelength,
            gatespace = _P.gatespace,
            drawoutergatecut = _P.drawoutergatecut,
            gatecutheight = _P.gatecutheight,
            gatemetal = _P.gatemetal,
            sdwidth = _P.sdwidth,
            gatestrapwidth = _P.gatestrapwidth,
            gatestrapspace = _P.gatestrapspace,
            gatestrapleftextension = _P.gatestrapleftextension,
            gatestraprightextension = _P.gatestraprightextension,
            powerwidth = _P.powerwidth,
            powerspace = _P.powerspace,
            pgateext = _P.pgateext,
            ngateext = _P.ngateext,
            numleftdummies = i == 1 and _P.numleftdummies or _P.numinnerdummies / 2,
            numrightdummies = i == #_P.fingers and _P.numrightdummies or _P.numinnerdummies / 2,
            alternatedummycontacts = _P.alternatedummycontacts,
            drawalternatedummycontactspowerbarvia = false,
            outputmetal = _P.outputmetal,
            outputwidth = _P.outputwidth,
            outputxshift = _P.outputxshift,
            outputyshift = _P.outputyshift,
            extendoutputmetal = _P.extendoutputmetal,
            dummycontheight = _P.dummycontheight,
            dummycontshift = _P.dummycontshift,
            psddummyouterheight = _P.psddummyouterheight,
            nsddummyouterheight = _P.nsddummyouterheight,
            outputisinside = _P.outputisinside,
            drawleftstopgate = (i == 1) and _P.drawleftstopgate or false,
            drawrightstopgate = (i == #_P.fingers) and _P.drawrightstopgate or false,
            leftpolylines = i == 1 and _P.leftpolylines or nil,
            rightpolylines = i == #_P.fingers and _P.rightpolylines or nil,
            drawanalogmarker = _P.drawanalogmarker,
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
        })
        if _P.flat then
            table.insert(inverters, inv)
            if i > 1 then
                inv:abut_right(inverters[i - 1])
            end
            chain:merge_into(inv)
            chain:inherit_alignment_box(inv)
        else
            local invinst = chain:add_child(inv, string.format("inv_%d", i))
            table.insert(inverters, invinst)
            if i > 1 then
                invinst:abut_right(inverters[i - 1])
            end
            chain:inherit_alignment_box(invinst)
        end
    end

    for i = 1, #inverters - 1 do
        if _P.numinnerdummies > 0 then
            geometry.viabltr(chain, 1, _P.outputmetal,
                point.create(
                    inverters[i + 1]:get_area_anchor("input").l - (_P.numinnerdummies - 0) * (_P.gatelength + _P.gatespace),
                    inverters[i + 1]:get_area_anchor("input").b
                ),
                point.create(
                    inverters[i + 1]:get_area_anchor("input").l - _P.gatespace,
                    inverters[i + 1]:get_area_anchor("input").t
                )
            )
            geometry.rectanglebltr(chain, generics.metal(1),
                point.create(
                    inverters[i + 1]:get_area_anchor("input").l - _P.gatespace,
                    inverters[i + 1]:get_area_anchor("input").b
                ),
                point.create(
                    inverters[i + 1]:get_area_anchor("input").l,
                    inverters[i + 1]:get_area_anchor("input").t
                )
            )
        else
            moderror("inverter_chain: connections between inverters are currently not implemented for numinnerdummies == 0")
        end
    end

    -- inherit anchors
    chain:add_area_anchor_bltr("vddbar",
        inverters[1]:get_area_anchor("vddbar").bl,
        inverters[#inverters]:get_area_anchor("vddbar").tr
    )
    chain:add_area_anchor_bltr("vssbar",
        inverters[1]:get_area_anchor("vssbar").bl,
        inverters[#inverters]:get_area_anchor("vssbar").tr
    )
    chain:inherit_area_anchor(inverters[1], "input")
    chain:inherit_area_anchor(inverters[#inverters], "output")
    chain:add_area_anchor_bltr("nmos_implant",
        inverters[1]:get_area_anchor("nmos_implant").bl,
        inverters[#inverters]:get_area_anchor("nmos_implant").tr
    )
    chain:add_area_anchor_bltr("pmos_implant",
        inverters[1]:get_area_anchor("pmos_implant").bl,
        inverters[#inverters]:get_area_anchor("pmos_implant").tr
    )
    chain:add_area_anchor_bltr("nmos_well",
        inverters[1]:get_area_anchor("nmos_well").bl,
        inverters[#inverters]:get_area_anchor("nmos_well").tr
    )
    chain:add_area_anchor_bltr("pmos_well",
        inverters[1]:get_area_anchor("pmos_well").bl,
        inverters[#inverters]:get_area_anchor("pmos_well").tr
    )
    chain:add_area_anchor_bltr("nmos_active",
        inverters[1]:get_area_anchor("nmos_active").bl,
        inverters[#inverters]:get_area_anchor("nmos_active").tr
    )
    chain:add_area_anchor_bltr("pmos_active",
        inverters[1]:get_area_anchor("pmos_active").bl,
        inverters[#inverters]:get_area_anchor("pmos_active").tr
    )

    -- draw vias on power bars (handling this in the individual cells can lead to DRC errors)
    if _P.alternatedummycontacts and _P.drawalternatedummycontactspowerbarvia then
        geometry.viabltr(chain, 1, 2,
            chain:get_area_anchor("vddbar").bl,
            chain:get_area_anchor("vddbar").tr
        )
        geometry.viabltr(chain, 1, 2,
            chain:get_area_anchor("vssbar").bl,
            chain:get_area_anchor("vssbar").tr
        )
    end
end
