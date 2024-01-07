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
        { "numleftdummies",                             0 },
        { "numrightdummies",                            0 },
        { "outputmetal",                                2, posvals = interval(2, inf) },
        { "outputwidth",                                technology.get_dimension("Minimum M1 Width") },
        { "outputshift",                                0 },
        { "dummycontheight",                            technology.get_dimension("Minimum M1 Width"), follow = "powerwidth" },
        { "dummycontshift",                             0 },
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
        { "extendvthtyperight",                         0 }
    )
end

function layout(inverter, _P)
    local xpitch = _P.gatespace + _P.gatelength

    local gatecontactpos = util.fill_all_with(_P.fingers, "center")
    local contactpos = util.fill_odd_with(_P.fingers + 1, "fullpower", "full")
    for i = 1, _P.numleftdummies do
        table.insert(gatecontactpos, 1, "dummy")
        table.insert(contactpos, 1, "dummyouterpower")
    end
    for i = 1, _P.numrightdummies do
        table.insert(gatecontactpos, "dummy")
        table.insert(contactpos, "dummyouterpower")
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
        powerwidth = _P.powerwidth,
        npowerspace = _P.powerspace,
        ppowerspace = _P.powerspace,
        pgateext = _P.pgateext,
        ngateext = _P.ngateext,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
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
        cutheight = _P.gatecutheight,
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
        psddummyouterheight = 200,
        nsddummyouterheight = 200,
    })
    inverter:merge_into(cmos)

    inverter:inherit_alignment_box(cmos)

    -- gate strap
    local dummyoffset = _P.numleftdummies
    if _P.fingers > 1 then
        if _P.gatemetal > 1 then
            geometry.viabltr(
                inverter, 1, _P.gatemetal,
                cmos:get_area_anchor(string.format("G%d", 1 + dummyoffset)).bl:translate_x(-_P.gatestrapleftextension),
                cmos:get_area_anchor(string.format("G%d", _P.fingers + dummyoffset)).tr:translate_x(_P.gatestraprightextension)
            )
        else
            geometry.rectanglebltr(
                inverter, generics.metal(1),
                cmos:get_area_anchor(string.format("G%d", 1 + dummyoffset)).bl:translate_x(-_P.gatestrapleftextension),
                cmos:get_area_anchor(string.format("G%d", _P.fingers + dummyoffset)).tr:translate_x(_P.gatestraprightextension)
            )
        end
    end

    -- signal transistors drain connections
    if _P.outputisinside then
        for i = 2, _P.fingers + 1, 2 do
            geometry.rectanglebltr(inverter, generics.metal(_P.outputmetal),
                cmos:get_area_anchor(string.format("nSD%d", i + dummyoffset)).tl,
                cmos:get_area_anchor(string.format("pSD%d", i + dummyoffset)).br
            )
        end
        inverter:add_area_anchor_bltr("output",
            point.combine(
                cmos:get_area_anchor(string.format("nSD%d", 2 + dummyoffset)).tl,
                cmos:get_area_anchor(string.format("pSD%d", 2 + dummyoffset)).bl
            ):translate_y(-_P.outputwidth / 2),
            point.combine(
                cmos:get_area_anchor(string.format("nSD%d", _P.fingers + dummyoffset)).tr,
                cmos:get_area_anchor(string.format("pSD%d", _P.fingers + dummyoffset)).br
            ):translate_y(_P.outputwidth / 2)
        )
        geometry.rectanglebltr(inverter, generics.metal(_P.outputmetal),
            inverter:get_area_anchor("output").bl,
            inverter:get_area_anchor("output").tr
        )
    else
        geometry.path_cshape(inverter, generics.metal(_P.outputmetal),
            cmos:get_area_anchor(string.format("pSD%d", 2 + dummyoffset)).br:translate(0, _P.outputwidth / 2),
            cmos:get_area_anchor(string.format("nSD%d", 2 + dummyoffset)).tr:translate(0, -_P.outputwidth / 2),
            cmos:get_area_anchor(string.format("G%d", _P.fingers + dummyoffset)).bl:translate(xpitch + _P.outputshift, 0),
            _P.outputwidth
        )
        inverter:add_area_anchor_bltr("output",
            point.create(
                cmos:get_area_anchor(string.format("G%d", _P.fingers + dummyoffset)).l + xpitch + _P.outputshift - _P.outputwidth / 2,
                cmos:get_area_anchor(string.format("nSD%d", 2 + dummyoffset)).t - _P.outputwidth / 2
            ),
            point.create(
                cmos:get_area_anchor(string.format("G%d", _P.fingers + dummyoffset)).l + xpitch + _P.outputshift + _P.outputwidth / 2,
                cmos:get_area_anchor(string.format("pSD%d", 2 + dummyoffset)).b + _P.outputwidth / 2
            )
        )
    end

    for i = 2, _P.fingers + 1, 2 do
        geometry.viabltr(inverter, 1, _P.outputmetal,
            cmos:get_area_anchor(string.format("pSD%d", i + dummyoffset)).bl,
            cmos:get_area_anchor(string.format("pSD%d", i + dummyoffset)).tr
        )
        geometry.viabltr(inverter, 1, _P.outputmetal,
            cmos:get_area_anchor(string.format("nSD%d", i + dummyoffset)).bl,
            cmos:get_area_anchor(string.format("nSD%d", i + dummyoffset)).tr
        )
    end

    inverter:inherit_area_anchor(cmos, "PRp")
    inverter:inherit_area_anchor(cmos, "PRn")

    inverter:add_area_anchor_bltr("input",
        cmos:get_area_anchor(string.format("G%d", 1 + dummyoffset)).bl,
        cmos:get_area_anchor(string.format("G%d", _P.fingers + dummyoffset)).tr
    )
end
