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
        { "drawoutergatecut",                           false },
        { "gatecutheight",                              0 },
        { "outergatecutyshift",                         0 },
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
        { "numleftdummies",                             0 },
        { "numrightdummies",                            0 },
        { "alternatedummycontacts",                     false },
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
        { "leftpolylines",                              {} },
        { "rightpolylines",                             {} },
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
        { "drawleftnmoswelltap",                        false },
        { "drawrightnmoswelltap",                       false },
        { "connectnmoswelltap",                         false },
        { "nmoswelltapwidth",                           200 },
        { "nmoswelltapshrink",                          0 },
        { "nmoswelltapshift",                           500 },
        { "nmoswelltapwellextension",                   0 },
        { "nmoswelltapsoiopenextension",                0 },
        { "drawleftpmoswelltap",                        false },
        { "drawrightpmoswelltap",                       false },
        { "connectpmoswelltap",                         false },
        { "pmoswelltapwidth",                           200 },
        { "pmoswelltapshrink",                          0 },
        { "pmoswelltapshift",                           500 },
        { "pmoswelltapwellextension",                   0 },
        { "pmoswelltapsoiopenextension",                0 }
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

    local cmos = pcell.create_layout("basic/cmos", "cmos", {
        nvthtype = _P.nvthtype,
        pvthtype = _P.pvthtype,
        pmosflippedwell = _P.pmosflippedwell,
        nmosflippedwell = _P.nmosflippedwell,
        oxidetype = _P.oxidetype,
        gatemarker = _P.gatemarker,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
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
        pgateext = _P.pgateext,
        ngateext = _P.ngateext,
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
        leftpolylines = _P.leftpolylines,
        rightpolylines = _P.rightpolylines,
        cutwidth = _P.gatelength + _P.gatespace,
        drawoutergatecut = _P.drawoutergatecut,
        cutheight = _P.gatecutheight,
        poutercutyshift = _P.outergatecutyshift,
        noutercutyshift = _P.outergatecutyshift,
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
        psddummyouterheight = _P.psddummyouterheight,
        nsddummyouterheight = _P.nsddummyouterheight,
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

    -- connect dummies
    if _P.alternatedummycontacts then
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

    -- inherit anchors
    inverter:inherit_area_anchor_as(cmos, "PRp", "vddbar")
    inverter:inherit_area_anchor_as(cmos, "PRn", "vssbar")
    inverter:inherit_area_anchor(cmos, "nmos_implant")
    inverter:inherit_area_anchor(cmos, "pmos_implant")
    inverter:inherit_area_anchor(cmos, "nmos_well")
    inverter:inherit_area_anchor(cmos, "pmos_well")
    inverter:inherit_area_anchor(cmos, "nmos_active")
    inverter:inherit_area_anchor(cmos, "pmos_active")

    -- place welltaps
    if _P.drawleftnmoswelltap then
        layouthelpers.place_welltap(
            inverter,
            inverter:get_area_anchor("nmos_active").bl:translate(-_P.nmoswelltapshift - _P.nmoswelltapwidth, _P.nmoswelltapshrink),
            inverter:get_area_anchor("nmos_active").tl:translate(-_P.nmoswelltapshift, -_P.nmoswelltapshrink),
            "left_nmos_welltap_",
            {
                contype = "n",
                wellleftextension = _P.nmoswelltapwellextension,
                soiopenleftextension = _P.nmoswelltapsoiopenextension,
                soiopenrightextension = _P.nmoswelltapsoiopenextension,
                soiopentopextension = _P.nmoswelltapsoiopenextension,
                soiopenbottomextension = _P.nmoswelltapsoiopenextension,
            }
        )
        geometry.rectanglebltr(inverter, generics.other("nwell"),
            point.create(
                inverter:get_area_anchor("left_nmos_welltap_well").l,
                inverter:get_area_anchor("nmos_well").b
            ),
            point.create(
                inverter:get_area_anchor("nmos_well").l,
                inverter:get_area_anchor("nmos_well").t
            )
        )
    end
    if _P.drawleftpmoswelltap then
        layouthelpers.place_welltap(
            inverter,
            inverter:get_area_anchor("pmos_implant").bl:translate(-_P.pmoswelltapshift - _P.pmoswelltapwidth, _P.pmoswelltapshrink),
            inverter:get_area_anchor("pmos_implant").tl:translate(-_P.pmoswelltapshift, -_P.pmoswelltapshrink),
            "left_pmos_welltap_",
            {
                contype = "p",
                wellleftextension = _P.pmoswelltapwellextension,
                soiopenleftextension = _P.pmoswelltapsoiopenextension,
                soiopenrightextension = _P.pmoswelltapsoiopenextension,
                soiopentopextension = _P.pmoswelltapsoiopenextension,
                soiopenbottomextension = _P.pmoswelltapsoiopenextension,
            }
        )
        geometry.rectanglebltr(inverter, generics.other("pwell"),
            point.create(
                inverter:get_area_anchor("left_pmos_welltap_well").l,
                inverter:get_area_anchor("pmos_well").b
            ),
            point.create(
                inverter:get_area_anchor("pmos_well").l,
                inverter:get_area_anchor("pmos_well").t
            )
        )
        geometry.rectanglebltr(inverter, generics.other("pimplant"),
            point.create(
                inverter:get_area_anchor("left_pmos_welltap_implant").l,
                inverter:get_area_anchor("pmos_implant").b
            ),
            point.create(
                inverter:get_area_anchor("pmos_implant").l,
                inverter:get_area_anchor("pmos_implant").t
            )
        )
        if _P.connectpmoswelltap then
            -- FIXME: currently only support for flipped-well
            if _P.pmosflippedwell then
                geometry.polygon(inverter, generics.metal(1), {
                    point.create(
                        inverter:get_area_anchor("left_pmos_welltap_boundary").l,
                        inverter:get_area_anchor("left_pmos_welltap_boundary").b
                    ),
                    point.create(
                        inverter:get_area_anchor("left_pmos_welltap_boundary").l,
                        inverter:get_area_anchor("vssbar").b
                    ),
                    point.create(
                        inverter:get_area_anchor("vssbar").l,
                        inverter:get_area_anchor("vssbar").b
                    ),
                    point.create(
                        inverter:get_area_anchor("vssbar").l,
                        inverter:get_area_anchor("vssbar").t
                    ),
                    point.create(
                        inverter:get_area_anchor("left_pmos_welltap_boundary").r,
                        inverter:get_area_anchor("vssbar").t
                    ),
                    point.create(
                        inverter:get_area_anchor("left_pmos_welltap_boundary").r,
                        inverter:get_area_anchor("left_pmos_welltap_boundary").b
                    ),
                })
            end
        end
    end
    if _P.drawrightnmoswelltap then
        layouthelpers.place_welltap(
            inverter,
            inverter:get_area_anchor("nmos_well").br:translate(_P.nmoswelltapshift, _P.nmoswelltapshrink),
            inverter:get_area_anchor("nmos_well").tr:translate(_P.nmoswelltapshift + _P.nmoswelltapwidth, -_P.nmoswelltapshrink),
            "right_nmos_welltap_",
            {
                contype = "n",
                wellrightextension = _P.nmoswelltapwellextension,
                soiopenleftextension = _P.nmoswelltapsoiopenextension,
                soiopenrightextension = _P.nmoswelltapsoiopenextension,
                soiopentopextension = _P.nmoswelltapsoiopenextension,
                soiopenbottomextension = _P.nmoswelltapsoiopenextension,
            }
        )
        geometry.rectanglebltr(inverter, generics.other("nwell"),
            point.create(
                inverter:get_area_anchor("nmos_well").l,
                inverter:get_area_anchor("nmos_well").b
            ),
            point.create(
                inverter:get_area_anchor("right_nmos_welltap_well").l,
                inverter:get_area_anchor("right_nmos_welltap_well").t
            )
        )
    end
    if _P.drawrightpmoswelltap then
        layouthelpers.place_welltap(
            inverter,
            inverter:get_area_anchor("pmos_well").br:translate(_P.pmoswelltapshift, _P.pmoswelltapshrink),
            inverter:get_area_anchor("pmos_well").tr:translate(_P.pmoswelltapshift + _P.pmoswelltapwidth, -_P.pmoswelltapshrink),
            "right_pmos_welltap_",
            {
                contype = "p",
                wellrightextension = _P.pmoswelltapwellextension,
                soiopenleftextension = _P.pmoswelltapsoiopenextension,
                soiopenrightextension = _P.pmoswelltapsoiopenextension,
                soiopentopextension = _P.pmoswelltapsoiopenextension,
                soiopenbottomextension = _P.pmoswelltapsoiopenextension,
            }
        )
        geometry.rectanglebltr(inverter, generics.other("pwell"),
            point.create(
                inverter:get_area_anchor("pmos_well").r,
                inverter:get_area_anchor("pmos_well").b
            ),
            point.create(
                inverter:get_area_anchor("right_pmos_welltap_well").l,
                inverter:get_area_anchor("right_pmos_welltap_well").t
            )
        )
        geometry.rectanglebltr(inverter, generics.other("pimplant"),
            point.create(
                inverter:get_area_anchor("pmos_implant").r,
                inverter:get_area_anchor("pmos_implant").b
            ),
            point.create(
                inverter:get_area_anchor("right_pmos_welltap_implant").r,
                inverter:get_area_anchor("pmos_implant").t
            )
        )
        if _P.connectpmoswelltap then
            -- FIXME: currently only support for flipped-well
            if _P.pmosflippedwell then
                geometry.polygon(inverter, generics.metal(1), {
                    point.create(
                        inverter:get_area_anchor("right_pmos_welltap_boundary").r,
                        inverter:get_area_anchor("right_pmos_welltap_boundary").b
                    ),
                    point.create(
                        inverter:get_area_anchor("right_pmos_welltap_boundary").r,
                        inverter:get_area_anchor("vssbar").b
                    ),
                    point.create(
                        inverter:get_area_anchor("vssbar").r,
                        inverter:get_area_anchor("vssbar").b
                    ),
                    point.create(
                        inverter:get_area_anchor("vssbar").r,
                        inverter:get_area_anchor("vssbar").t
                    ),
                    point.create(
                        inverter:get_area_anchor("right_pmos_welltap_boundary").l,
                        inverter:get_area_anchor("vssbar").t
                    ),
                    point.create(
                        inverter:get_area_anchor("right_pmos_welltap_boundary").l,
                        inverter:get_area_anchor("right_pmos_welltap_boundary").b
                    ),
                })
            end
        end
    end

    inverter:add_area_anchor_bltr("input",
        cmos:get_area_anchor(string.format("G%d", 1 + _P.numleftdummies)).bl,
        cmos:get_area_anchor(string.format("G%d", _P.fingers + _P.numleftdummies)).tr
    )
end
