function parameters()
    pcell.add_parameters(
        { "fingers",                                    { 2, 4 } },
        { "pwidth",                                     2 * technology.get_dimension("Minimum Gate Width") },
        { "nwidth",                                     2 * technology.get_dimension("Minimum Gate Width") },
        { "oxidetype(Oxide Type)",                      1 },
        { "gatemarker(Gate Marker Index)",              1 },
        { "mosfetmarker(MOSFET Marking Layer Index)",   1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",     1 },
        { "nvthtype(NMOS Threshold Voltage Type)",      1 },
        { "pmosflippedwell(PMOS Flipped Well) ",        false },
        { "nmosflippedwell(NMOS Flipped Well)",         false },
        { "gatelength(Gate Length)",                    technology.get_dimension("Minimum Gate Length") },
        { "gatespace(Gate Spacing)",                    technology.get_dimension("Minimum Gate XSpace") },
        { "drawoutergatecut",                           false },
        { "gatecutheight",                              technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace", "Minimum Gate Space") },
        { "gatemetal",                                  1 },
        { "sdwidth(Source/Drain Metal Width)",          technology.get_dimension("Minimum M1 Width"), posvals = even() },
        { "gatestrapwidth(Gate Metal Width)",           technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace(Gate Metal Space)",           technology.get_dimension("Minimum M1 Width") },
        { "gatestrapleftextension",                     0 },
        { "gatestraprightextension",                     0 },
        { "powerwidth(Power Rail Metal Width)",         technology.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",               technology.get_dimension("Minimum M1 Space") },
        { "powerrailleftrightextension",                0 },
        { "powerrailleftextension",                     0 },
        { "powerrailrightextension",                    0 },
        { "pgateext",                                   technology.get_dimension("Minimum Gate Extension") },
        { "ngateext",                                   technology.get_dimension("Minimum Gate Extension") },
        { "numinnerdummies",                            0 },
        { "numleftdummies",                             0 },
        { "numrightdummies",                            0 },
        { "numinnerfloatingdummies",                    0 },
        { "numleftfloatingdummies",                     0 },
        { "numrightfloatingdummies",                    0 },
        { "inv_xshift",                                 0 },
        { "alternatedummycontacts",                     false },
        { "drawalternatedummycontactspowerbarvia",      false, follow = "alternatedummycontacts" },
        { "splitdrainvias",                             false },
        { "inneroutputmetal",                           1, posvals = interval(1, inf) },
        { "inneroutputwidth",                           technology.get_dimension("Minimum M1 Width"), follow = "sdwidth" },
        { "inneroutputxshift",                          0 },
        { "inneroutputyshift",                          0 },
        { "extendinneroutputmetal",                     0 },
        { "outputmetal",                                2, posvals = interval(1, inf) },
        { "outputwidth",                                technology.get_dimension("Minimum M1 Width") },
        { "outputxshift",                               0 },
        { "outputyshift",                               0 },
        { "extendoutputmetal",                          0 },
        { "dummycontheight",                            technology.get_dimension("Minimum M1 Width"), follow = "powerwidth" },
        { "dummycontshift",                             0 },
        { "psddummyouterheight",                        2 * technology.get_dimension("Minimum Gate Width"), follow = "pwidth" },
        { "nsddummyouterheight",                        2 * technology.get_dimension("Minimum Gate Width"), follow = "nwidth" },
        { "inneroutputmode",                            "around", posvals = set("overlay", "inside", "around") },
        { "outputmode",                                 "overlay", posvals = set("overlay", "inside", "around") },
        { "drawleftstopgate",                           false },
        { "drawrightstopgate",                          false },
        { "leftpolylines",                              {} },
        { "rightpolylines",                             {} },
        { "drawanalogmarker",                           false },
        { "extendall",                                  0 },
        { "extendalltop",                               0, follow = "extendall" },
        { "extendallbottom",                            0, follow = "extendall" },
        { "extendallleft",                              0, follow = "extendall" },
        { "extendallright",                             0, follow = "extendall" },
        { "extendoxidetypetop",                         technology.get_dimension("Minimum Oxide Extension"), follow = "extendalltop" },
        { "extendoxidetypebottom",                      technology.get_dimension("Minimum Oxide Extension"), follow = "extendallbottom" },
        { "extendoxidetypeleft",                        technology.get_dimension("Minimum Oxide Extension"), follow = "extendallleft" },
        { "extendoxidetyperight",                       technology.get_dimension("Minimum Oxide Extension"), follow = "extendallright" },
        { "extendvthtypetop",                           technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendalltop" },
        { "extendvthtypebottom",                        technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallbottom" },
        { "extendvthtypeleft",                          technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallleft" },
        { "extendvthtyperight",                         technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallright" },
        { "extendimplanttop",                           technology.get_dimension("Minimum Implant Extension"), follow = "extendalltop" },
        { "extendimplantbottom",                        technology.get_dimension("Minimum Implant Extension"), follow = "extendallbottom" },
        { "extendimplantleft",                          technology.get_dimension("Minimum Implant Extension"), follow = "extendallleft" },
        { "extendimplantright",                         technology.get_dimension("Minimum Implant Extension"), follow = "extendallright" },
        { "extendwelltop",                              technology.get_dimension("Minimum Well Extension"), follow = "extendalltop" },
        { "extendwellbottom",                           technology.get_dimension("Minimum Well Extension"), follow = "extendallbottom" },
        { "extendwellleft",                             technology.get_dimension("Minimum Well Extension"), follow = "extendallleft" },
        { "extendwellright",                            technology.get_dimension("Minimum Well Extension"), follow = "extendallright" },
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
        { "nmoswelltapwidth",                           technology.get_dimension_max("Minimum Active Width", "Minimum Active Contact Region Size", "Minimum M1 Width") },
        { "nmoswelltapextension",                       0 },
        { "nmoswelltapspace",                           technology.get_dimension("Minimum M1 Space") },
        { "nmoswelltapnet",                             "" },
        { "nmoswelltapimplantleftextension",            technology.get_dimension("Minimum Implant Extension") },
        { "nmoswelltapimplantrightextension",           technology.get_dimension("Minimum Implant Extension") },
        { "nmoswelltapimplanttopextension",             technology.get_dimension("Minimum Implant Extension") },
        { "nmoswelltapimplantbottomextension",          technology.get_dimension("Minimum Implant Extension") },
        { "nmoswelltapsoiopenleftextension",            technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "nmoswelltapsoiopenrightextension",           technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "nmoswelltapsoiopentopextension",             technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "nmoswelltapsoiopenbottomextension",          technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "nmoswelltapwellleftextension",               technology.get_dimension("Minimum Well Extension") },
        { "nmoswelltapwellrightextension",              technology.get_dimension("Minimum Well Extension") },
        { "nmoswelltapwelltopextension",                technology.get_dimension("Minimum Well Extension") },
        { "nmoswelltapwellbottomextension",             technology.get_dimension("Minimum Well Extension") },
        { "drawpmosupperwelltap",                       false },
        { "drawpmosleftrightwelltap",                   false },
        { "drawpmosleftwelltap",                        false, follow = "drawpmosleftrightwelltap" },
        { "drawpmosrightwelltap",                       false, follow = "drawpmosleftrightwelltap" },
        { "connectpmoswelltap",                         false },
        { "pmoswelltapwidth",                           technology.get_dimension_max("Minimum Active Width", "Minimum Active Contact Region Size", "Minimum M1 Width") },
        { "pmoswelltapextension",                       0 },
        { "pmoswelltapspace",                           technology.get_dimension("Minimum M1 Space") },
        { "pmoswelltapnet",                             "" },
        { "pmoswelltapimplantleftextension",            technology.get_dimension("Minimum Implant Extension") },
        { "pmoswelltapimplantrightextension",           technology.get_dimension("Minimum Implant Extension") },
        { "pmoswelltapimplanttopextension",             technology.get_dimension("Minimum Implant Extension") },
        { "pmoswelltapimplantbottomextension",          technology.get_dimension("Minimum Implant Extension") },
        { "pmoswelltapsoiopenleftextension",            technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "pmoswelltapsoiopenrightextension",           technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "pmoswelltapsoiopentopextension",             technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "pmoswelltapsoiopenbottomextension",          technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "pmoswelltapwellleftextension",               technology.get_dimension("Minimum Well Extension") },
        { "pmoswelltapwellrightextension",              technology.get_dimension("Minimum Well Extension") },
        { "pmoswelltapwelltopextension",                technology.get_dimension("Minimum Well Extension") },
        { "pmoswelltapwellbottomextension",             technology.get_dimension("Minimum Well Extension") },
        { "drawguardring",                              false },
        { "guardringcontype",                           "n" },
        { "guardringwidth",                             technology.get_dimension("Minimum Active Contact Region Size") },
        { "guardringxspace",                            technology.get_dimension("Minimum Active Space") },
        { "guardringyspace",                            technology.get_dimension("Minimum Active Space") },
        { "guardringdeepwelloffset",                    technology.get_optional_dimension("Deep Well Offset", 0) },
        { "guardringwellinnerextension",                technology.get_dimension("Minimum Well Extension") },
        { "guardringwellouterextension",                technology.get_dimension("Minimum Well Extension") },
        { "guardringsoiopeninnerextension",             technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "guardringsoiopenouterextension",             technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "guardringimplantinnerextension",             technology.get_dimension("Minimum Implant Extension") },
        { "guardringimplantouterextension",             technology.get_dimension("Minimum Implant Extension") },
        { "guardringoxidetypeinnerextension",           technology.get_dimension("Minimum Oxide Extension") },
        { "guardringoxidetypeouterextension",           technology.get_dimension("Minimum Oxide Extension") },
        { "vddnet",                                     "" },
        { "vssnet",                                     "" },
        { "guardringnet",                               "" },
        { "flat",                                       true }
    )
end

function process_parameters(_P)
    if _P.numinnerdummies == 0 then
        local metalshift =
            _P.sdwidth +
            technology.get_dimension("Minimum M1 Space") +
            technology.get_dimension("Minimum M1M2 Viawidth")
        local activeshift = _P.sdwidth + technology.get_dimension("Minimum Active Space")
        _P.inv_xshift = math.max(metalshift, activeshift)
    end
end

function layout(chain, _P)
    local inverters = {}
    -- explicitly set the pmos/nmos separation as it can be different due to the output mode
    local separation
    if _P.inneroutputmode == "around" or _P.outputmode == "around" then
        separation = _P.gatestrapwidth + 4 * _P.gatestrapspace + 2 * math.max(_P.inneroutputwidth, _P.outputwidth)
    else
        separation = _P.gatestrapwidth + 2 * _P.gatestrapspace
    end
    for i, fingers in ipairs(_P.fingers) do
        local leftext = nil
        local rightext = nil
        if _P.inv_xshift > 0 then
            if i < #_P.fingers then
                rightext = _P.inv_xshift / 2
            end
            if i > 1 then
                leftext = _P.inv_xshift / 2
            end
        end
        local inv = pcell.create_layout("analog/inverter", string.format("inv_%d", i), {
            fingers = fingers,
            pwidth = _P.pwidth,
            nwidth = _P.nwidth,
            oxidetype = _P.oxidetype,
            gatemarker = _P.gatemarker,
            mosfetmarker = _P.mosfetmarker,
            pvthtype = _P.pvthtype,
            nvthtype = _P.nvthtype,
            pmosflippedwell = _P.pmosflippedwell,
            nmosflippedwell = _P.nmosflippedwell,
            manual_separation = separation,
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
            powerrailleftextension = (i == 1) and _P.powerrailleftextension or 0,
            powerrailrightextension = (i == #_P.fingers) and _P.powerrailrightextension or 0,
            pgateext = _P.pgateext,
            ngateext = _P.ngateext,
            numleftdummies = i == 1 and _P.numleftdummies or _P.numinnerdummies / 2,
            numrightdummies = i == #_P.fingers and _P.numrightdummies or _P.numinnerdummies / 2,
            numleftfloatingdummies = (i == 1) and _P.numleftfloatingdummies or _P.numinnerfloatingdummies / 2,
            numrightfloatingdummies = (i == #_P.fingers) and _P.numrightfloatingdummies or _P.numinnerfloatingdummies / 2,
            alternatedummycontacts = _P.alternatedummycontacts,
            drawalternatedummycontactspowerbarvia = false,
            splitdrainvias = _P.splitdrainvias,
            outputmode = ((i == #_P.fingers) and _P.outputmode) or _P.inneroutputmode,
            outputmetal = ((i == #_P.fingers) and _P.outputmetal) or _P.inneroutputmetal,
            outputwidth = ((i == #_P.fingers) and _P.outputwidth) or _P.inneroutputwidth,
            outputxshift = ((i == #_P.fingers) and _P.outputxshift) or _P.inneroutputxshift,
            outputyshift = ((i == #_P.fingers) and _P.outputyshift) or _P.inneroutputyshift,
            extendoutputmetal = ((i == #_P.fingers) and _P.extendoutputmetal) or _P.extendinneroutputmetal,
            dummycontheight = _P.dummycontheight,
            dummycontshift = _P.dummycontshift,
            psddummyouterheight = _P.psddummyouterheight,
            nsddummyouterheight = _P.nsddummyouterheight,
            drawleftstopgate = _P.drawleftstopgate and ((_P.inv_xshift ~= 0) or (i == 1)),
            drawrightstopgate = _P.drawrightstopgate and ((_P.inv_xshift ~= 0) or (i == #_P.fingers)),
            leftpolylines = i == 1 and _P.leftpolylines or nil,
            rightpolylines = i == #_P.fingers and _P.rightpolylines or nil,
            drawanalogmarker = _P.drawanalogmarker,
            extendimplanttop = _P.extendimplanttop,
            extendimplantbottom = _P.extendimplantbottom,
            extendimplantleft = leftext or _P.extendimplantleft,
            extendimplantright = rightext or _P.extendimplantright,
            extendoxidetypetop = _P.extendoxidetypetop,
            extendoxidetypebottom = _P.extendoxidetypebottom,
            extendoxidetypeleft = leftext or _P.extendoxidetypeleft,
            extendoxidetyperight = rightext or _P.extendoxidetyperight,
            extendvthtypetop = _P.extendvthtypetop,
            extendvthtypebottom = _P.extendvthtypebottom,
            extendvthtypeleft = leftext or _P.extendvthtypeleft,
            extendvthtyperight = rightext or _P.extendvthtyperight,
            extendwelltop = _P.extendwelltop,
            extendwellbottom = _P.extendwellbottom,
            extendwellleft = leftext or _P.extendwellleft,
            extendwellright = rightext or _P.extendwellright,
            drawnmosleftwelltap = _P.drawnmosleftwelltap and (i == 1),
            drawnmosrightwelltap = _P.drawnmosrightwelltap and (i == #_P.fingers),
            drawnmoslowerwelltap = _P.drawnmoslowerwelltap,
            connectnmoswelltap = _P.connectnmoswelltap,
            nmoswelltapwidth = _P.nmoswelltapwidth,
            nmoswelltapextension = _P.nmoswelltapextension,
            nmoswelltapspace = _P.nmoswelltapspace,
            nmoswelltapnet = _P.nmoswelltapnet,
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
            drawpmosleftwelltap = _P.drawpmosleftwelltap and (i == 1),
            drawpmosrightwelltap = _P.drawpmosrightwelltap and (i == #_P.fingers),
            drawpmosupperwelltap = _P.drawpmosupperwelltap,
            connectpmoswelltap = _P.connectpmoswelltap,
            pmoswelltapwidth = _P.pmoswelltapwidth,
            pmoswelltapextension = _P.pmoswelltapextension,
            pmoswelltapspace = _P.pmoswelltapspace,
            pmoswelltapnet = _P.pmoswelltapnet,
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
            vddnet = _P.vddnet,
            vssnet = _P.vssnet,
        })
        local invinst
        if _P.flat then
            invinst = inv
        else
            local invinst = chain:add_child(inv, string.format("inv_%d", i))
        end
        table.insert(inverters, invinst)
        if i > 1 then
            invinst:abut_right(inverters[i - 1])
            invinst:translate_x(_P.inv_xshift)
        end
        if _P.flat then
            chain:merge_into(invinst)
        end
        chain:inherit_alignment_box(invinst)
        chain:inherit_net_shapes(invinst)
    end

    for i = 1, #inverters - 1 do
        --if _P.numinnerdummies > 0 then
        if _P.inneroutputmode == "overlay" then
            geometry.viabltr(chain, _P.gatemetal, _P.inneroutputmetal,
                point.create(
                    inverters[i]:get_area_anchor("output").r + _P.inneroutputxshift,
                    inverters[i + 1]:get_area_anchor("input").b
                ),
                point.create(
                    inverters[i + 1]:get_area_anchor("input").l - _P.gatespace,
                    inverters[i + 1]:get_area_anchor("input").t
                )
            )
            geometry.rectanglebltr(chain, generics.metal(_P.inneroutputmetal),
                point.create(
                    inverters[i]:get_area_anchor("output").r,
                    inverters[i + 1]:get_area_anchor("input").b
                ),
                point.create(
                    inverters[i]:get_area_anchor("output").l + _P.inneroutputxshift,
                    inverters[i + 1]:get_area_anchor("input").t
                )
            )
            geometry.rectanglebltr(chain, generics.metal(_P.gatemetal),
                point.create(
                    inverters[i + 1]:get_area_anchor("input").l - _P.gatespace,
                    inverters[i + 1]:get_area_anchor("input").b
                ),
                point.create(
                    inverters[i + 1]:get_area_anchor("input").l,
                    inverters[i + 1]:get_area_anchor("input").t
                )
            )
        elseif _P.inneroutputmode == "overlay" then
            -- FIXME
            --geometry.viabltr(chain, _P.gatemetal, _P.outputmetal,
            --    point.create(
            --        --inverters[i + 1]:get_area_anchor("input").l - (_P.numinnerdummies - 0) * (_P.gatelength + _P.gatespace),
            --        inverters[i]:get_area_anchor("output").r,
            --        inverters[i + 1]:get_area_anchor("input").b
            --    ),
            --    point.create(
            --        inverters[i + 1]:get_area_anchor("input").l - _P.gatespace,
            --        inverters[i + 1]:get_area_anchor("input").t
            --    )
            --)
            --geometry.rectanglebltr(chain, generics.metal(_P.gatemetal),
            --    point.create(
            --        inverters[i + 1]:get_area_anchor("input").l - _P.gatespace,
            --        inverters[i + 1]:get_area_anchor("input").b
            --    ),
            --    point.create(
            --        inverters[i + 1]:get_area_anchor("input").l,
            --        inverters[i + 1]:get_area_anchor("input").t
            --    )
            --)
        else -- "around"
            geometry.viabltr(chain, _P.gatemetal, _P.inneroutputmetal,
                point.create(
                    inverters[i]:get_area_anchor("output").r,
                    inverters[i + 1]:get_area_anchor("input").b
                ),
                point.create(
                    inverters[i + 1]:get_area_anchor("input").l,
                    inverters[i + 1]:get_area_anchor("input").t
                )
            )
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
    chain:add_area_anchor_bltr("oxide",
        inverters[1]:get_area_anchor("oxide").bl,
        inverters[#inverters]:get_area_anchor("oxide").tr
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

    -- connect power bars
    geometry.rectangleareaanchor(chain, generics.metal(1), "vddbar")
    geometry.rectangleareaanchor(chain, generics.metal(1), "vssbar")

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

    -- fill up FEOL layers
    geometry.rectangleareaanchor(chain, generics.implant("p"), "pmos_implant")
    geometry.rectangleareaanchor(chain, generics.implant("n"), "nmos_implant")
    geometry.rectangleareaanchor(chain, generics.oxide(_P.oxidetype), "oxide")
    geometry.rectangleareaanchor(chain, generics.well(_P.pmosflippedwell and "p" or "n"), "pmos_well")
    geometry.rectangleareaanchor(chain, generics.well(_P.nmosflippedwell and "n" or "p"), "nmos_well")

    -- guardring
    if _P.drawguardring then
        local guardringw1, guardringw2
        if _P.drawpmosleftwelltap then
            guardringw1 = inverters[1]:get_area_anchor("pmosleftwelltap_boundary").l
        else
            guardringw1 = inverters[1]:get_area_anchor("pmos_active").l
        end
        if _P.drawpmosrightwelltap then
            guardringw2 = inverters[#inverters]:get_area_anchor("pmosrightwelltap_boundary").r
        else
            guardringw2 = inverters[#inverters]:get_area_anchor("pmos_active").r
        end
        local guardringh1, guardringh2
        if _P.drawnmoslowerwelltap then
            guardringh1 = inverters[1]:get_area_anchor("nmoslowerwelltap_boundary").b
        else
            guardringh1 = inverters[1]:get_area_anchor("vssbar").b
        end
        if _P.drawpmosupperwelltap then
            guardringh2 = inverters[#inverters]:get_area_anchor("pmosupperwelltap_boundary").t
        else
            guardringh2 = inverters[#inverters]:get_area_anchor("vddbar").t
        end
        local guardringwidth = guardringw2 - guardringw1
        local guardringheight = guardringh2 - guardringh1
        local firstguardring = pcell.create_layout("auxiliary/guardring", "_firstguardring", {
            contype = _P.guardringcontype,
            ringwidth = _P.guardringwidth,
            holewidth = guardringwidth + 2 * _P.guardringxspace,
            holeheight = guardringheight + 2 * _P.guardringyspace,
            fillwell = (not not _P.pmosflippedwell) == (not _P.nmosflippedwell),
            drawdeepwell = true,
            deepwelloffset = _P.guardringdeepwelloffset,
            oxidetype = _P.oxidetype,
            wellinnerextension = _P.guardringwellinnerextension,
            wellouterextension = _P.guardringwellouterextension,
            implantinnerextension = _P.guardringimplantinnerextension,
            implantouterextension = _P.guardringimplantouterextension,
            soiopeninnerextension = _P.guardringsoiopeninnerextension,
            soiopenouterextension = _P.guardringsoiopenouterextension,
            oxidetypeinnerextension = _P.guardringoxidetypeinnerextension,
            oxidetypeouterextension = _P.guardringoxidetypeouterextension,
            net = _P.guardringnet,
            addtopnet = true,
            addbottomnet = true,
        })
        firstguardring:move_point(
            firstguardring:get_area_anchor("innerboundary").bl,
            point.create(
                guardringw1,
                guardringh1
            )
        )
        firstguardring:translate(-_P.guardringxspace, -_P.guardringyspace)
        chain:merge_into(firstguardring)
        chain:inherit_net_shapes(firstguardring)
        geometry.rectanglebltr(chain, generics.well("n"),
            firstguardring:get_area_anchor("outerwell").bl,
            point.create(
                firstguardring:get_area_anchor("outerwell").r,
                chain:get_area_anchor("nmos_well").t
            )
        )
        -- fill implant
        geometry.unequal_ring_pts(chain, generics.implant(_P.guardringcontype),
            firstguardring:get_area_anchor("innerimplant").bl,
            firstguardring:get_area_anchor("innerimplant").tr,
            chain:get_area_anchor("nmos_implant").bl,
            chain:get_area_anchor("pmos_implant").tr
        )
    end
end
