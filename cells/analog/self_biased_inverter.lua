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
        { "gatemetal",                                  1 },
        { "sdwidth(Source/Drain Metal Width)",          technology.get_dimension("Minimum M1 Width"), posvals = even() },
        { "gatestrapwidth(Gate Metal Width)",           technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace(Gate Metal Space)",           technology.get_dimension("Minimum M1 Width") },
        { "powerwidth(Power Rail Metal Width)",         technology.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",               technology.get_dimension("Minimum M1 Space") },
        { "drawleftdummy",                              false },
        { "drawrightdummy",                             false },
        { "outputmetal",                                2, posvals = interval(2, inf) },
        { "outputwidth",                                technology.get_dimension("Minimum M1 Width") },
        { "dummycontheight",                            technology.get_dimension("Minimum M1 Width"), follow = "powerwidth" },
        { "shiftoutput",                                0 },
        { "dummycontshift",                             0 },
        { "outputisinside",                             false }
    )
end

function layout(inverter, _P)
    local xpitch = _P.gatespace + _P.gatelength

    local gatecontactpos = util.fill_all_with(_P.fingers, "center")
    local contactpos = util.fill_odd_with(_P.fingers + 1, "fullpower", "full")
    if _P.drawleftdummy then
        table.insert(gatecontactpos, 1, "dummy")
        table.insert(contactpos, 1, "fullpower")
    end
    if _P.drawrightdummy then
        table.insert(gatecontactpos, "dummy")
        table.insert(contactpos, "fullpower")
    end

    local cmos = pcell.create_layout("basic/cmos", "_cmos", {
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
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        innergatestraps = 1,
        gstwidth = _P.gatestrapwidth,
        gstspace = _P.gatestrapspace,
        sdwidth = _P.sdwidth,
        separation = _P.gatestrapwidth + 2 * _P.gatestrapspace,
        dummycontheight = _P.dummycontheight,
        dummycontshift = _P.dummycontshift,
    })
    inverter:merge_into(cmos)

    inverter:inherit_alignment_box(cmos)

    -- resistor
    local resistor = pcell.create_layout("basic/polyresistor", "_resistor", {
        width = 400,
        length = 200,
        extension = 100,
        contactheight = 100,
    })
    local resistor_upper = resistor:copy()
    local resistor_lower = resistor:copy()
    resistor_lower:mirror_at_xaxis()
    resistor_upper:move_point(resistor_upper:get_area_anchor("plus").tl, cmos:get_area_anchor("pSD-1").tr)
    resistor_upper:translate_x(500)
    resistor_lower:move_point(resistor_lower:get_area_anchor("plus").bl, cmos:get_area_anchor("nSD-1").br)
    resistor_lower:translate_x(500)
    inverter:merge_into(resistor_upper)
    inverter:merge_into(resistor_lower)

    -- gate strap
    local dummyoffset = _P.drawleftdummy and 1 or 0
    if _P.fingers > 1 then
        if _P.gatemetal > 1 then
            geometry.viabltr(
                inverter, 1, _P.gatemetal,
                cmos:get_area_anchor(string.format("G%d", 1 + dummyoffset)).bl,
                cmos:get_area_anchor(string.format("G%d", _P.fingers + dummyoffset)).tr
            )
        else
            geometry.rectanglebltr(
                inverter, generics.metal(1),
                cmos:get_area_anchor(string.format("G%d", 1 + dummyoffset)).bl,
                cmos:get_area_anchor(string.format("G%d", _P.fingers + dummyoffset)).tr
            )
        end
    end

    -- signal transistors drain connections
    if _P.outputisinside then
        for i = 2, _P.fingers + 1, 2 do
            geometry.rectanglebltr(inverter, generics.metal(_P.outputmetal),
                cmos:get_area_anchor(string.format("nSD%d", i)).tl,
                cmos:get_area_anchor(string.format("pSD%d", i)).br
            )
        end
        geometry.rectanglebltr(inverter, generics.metal(_P.outputmetal),
            point.combine(
                cmos:get_area_anchor(string.format("nSD%d", 2)).tl,
                cmos:get_area_anchor(string.format("pSD%d", 2)).bl
            ):translate_y(-_P.outputwidth),
            point.combine(
                cmos:get_area_anchor(string.format("nSD%d", _P.fingers)).tr,
                cmos:get_area_anchor(string.format("pSD%d", _P.fingers)).br
            ):translate_y(_P.outputwidth)
        )
    else
        geometry.path_cshape(inverter, generics.metal(_P.outputmetal),
            cmos:get_area_anchor(string.format("pSD%d", 2 + dummyoffset)).br:translate(0, _P.sdwidth / 2),
            cmos:get_area_anchor(string.format("nSD%d", 2 + dummyoffset)).tr:translate(0, -_P.sdwidth / 2),
            cmos:get_area_anchor(string.format("G%d", _P.fingers + dummyoffset)).bl:translate(xpitch + _P.shiftoutput, 0),
            _P.outputwidth
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

    inverter:add_area_anchor_bltr("input",
        cmos:get_area_anchor(string.format("G%d", 1)).bl,
        cmos:get_area_anchor(string.format("G%d", _P.fingers)).tr
    )
end
