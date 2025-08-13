function parameters()
    pcell.add_parameters(
        { "invfingers", 2 },
        { "dummyfingers", 1 },
        { "bufferfingers", 8 },
        { "numrows", 2, posvals = even() },
        { "numdummyrows", 0 },
        { "inv_per_row", 5 },
        { "nand_row", 1 },
        { "gatelength", technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace") },
        { "buffergatelength", technology.get_dimension("Minimum Gate Length") },
        { "buffergatespace", technology.get_dimension("Minimum Gate XSpace") },
        { "usegatecut", false },
        { "pwidth", technology.get_dimension("Minimum MOSFET Fingerwidth", "Minimum Active Width") },
        { "nwidth", technology.get_dimension("Minimum MOSFET Fingerwidth", "Minimum Active Width") },
        { "drawstopgates", false },
        { "stopgatelength", technology.get_dimension("Minimum Gate Length"), follow = "gatelength" },
        { "bufferpwidth", technology.get_dimension("Minimum MOSFET Fingerwidth", "Minimum Active Width") },
        { "buffernwidth", technology.get_dimension("Minimum MOSFET Fingerwidth", "Minimum Active Width") },
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "buffergatemetal", 2 },
        { "bufferoutputmetal", 3 },
        { "bufferoutputwidth", technology.get_dimension("Minimum M3 Width") },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "buffersdwidth", technology.get_dimension("Minimum M3 Width") },
        { "buffershift", 0 },
        { "powerwidth", 2 * technology.get_dimension("Minimum M1 Width") },
        { "powerspace", 2 * technology.get_dimension("Minimum M1 Space") },
        { "powerlinemetal", 4 }
    )
end

function layout(toplevel, _P)
    local xpitch = _P.gatelength + _P.gatespace
    local powerlinewidth = util.ratio_split_even(util.ratio_split_even(xpitch, 1), 1) -- 50 % density

    local nand_inv_size_ratio = 2
    local gatecutheight = 100

    local mingateext = 40

    local numleftdummies = 0
    local numrightdummies = 0

    local row_conn_xshift = 0.5 * _P.gatespace + 2 * xpitch
    local row_conn_extraxshift = xpitch

    local baseoptions = {
        pvthtype = 2,
        nvthtype = 3,
        pmosflippedwell = true,
        nmosflippedwell = false,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        powerwidth = _P.powerwidth,
        extendalltop = _P.powerspace + _P.powerwidth / 2,
        extendallbottom = _P.powerspace + _P.powerwidth / 2,
        extendallleft = _P.powerspace + _P.powerwidth / 2,
        extendallright = _P.powerspace + _P.powerwidth / 2,
    }

    local oscoptions = util.add_options(baseoptions, {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        actext = 10,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        sdwidth = _P.sdwidth,
        pgateext = _P.usegatecut and (_P.powerwidth + _P.powerspace) or mingateext,
        ngateext = _P.usegatecut and (_P.powerwidth + _P.powerspace) or mingateext,
    })

    local inverter = pcell.create_layout("analog/inverter", "inverter", util.add_options(oscoptions, {
        fingers = _P.invfingers,
        gatestrapspace = _P.gatestrapspace + 0.5 * (_P.gatestrapwidth + _P.gatestrapspace), -- compensate for extra gate strap in nand
        gatecutheight = gatecutheight,
        outputmetal = 2,
        outputwidth = 70,
        outputxshift = -_P.gatespace - _P.gatelength / 2,
        powerspace = _P.powerspace,
        numleftdummies = 0,
        numrightdummies = 0,
        drawgatecuteverywhere = _P.usegatecut,
        drawoutergatecut = _P.usegatecut,
        gatecutheight = gatecutheight,
    }))
    geometry.viabltr(inverter, 1, 2,
        inverter:get_area_anchor("input").bl,
        inverter:get_area_anchor("input").tl:translate_x(_P.gatelength)
    )

    -- vss
    for i = 1, _P.invfingers do
        inverter:add_area_anchor_bltr(string.format("vssline_%d", i),
            point.create(
                0.5 * (
                    inverter:get_area_anchor(string.format("G%d", i)).l +
                    inverter:get_area_anchor(string.format("G%d", i)).r
                ) - 0.5 * powerlinewidth,
                inverter:get_area_anchor("vssbar").b
            ),
            point.create(
                0.5 * (
                    inverter:get_area_anchor(string.format("G%d", i)).l +
                    inverter:get_area_anchor(string.format("G%d", i)).r
                ) + 0.5 * powerlinewidth,
                inverter:get_area_anchor("vddbar").t
            )
        )
        geometry.rectanglebltr(inverter, generics.metal(_P.powerlinemetal),
            inverter:get_area_anchor(string.format("vssline_%d", i)).bl,
            inverter:get_area_anchor(string.format("vssline_%d", i)).tr
        )
        geometry.viabltr(inverter, 1, _P.powerlinemetal,
            point.create(
                inverter:get_area_anchor(string.format("vssline_%d", i)).l,
                inverter:get_area_anchor("vssbar").b
            ),
            point.create(
                inverter:get_area_anchor(string.format("vssline_%d", i)).r,
                inverter:get_area_anchor("vssbar").t
            )
        )
    end

    -- inv vdd
    for i = 1, _P.invfingers do
        inverter:add_area_anchor_bltr(string.format("leftvddline_%d", i),
            point.create(
                0.5 * (
                    inverter:get_area_anchor(string.format("G%d", i)).l +
                    inverter:get_area_anchor(string.format("G%d", i)).r
                ) - 0.5 * powerlinewidth - 0.5 * xpitch,
                inverter:get_area_anchor("vssbar").b
            ),
            point.create(
                0.5 * (
                    inverter:get_area_anchor(string.format("G%d", i)).l +
                    inverter:get_area_anchor(string.format("G%d", i)).r
                ) + 0.5 * powerlinewidth - 0.5 * xpitch,
                inverter:get_area_anchor("vddbar").t
            )
        )
        inverter:add_area_anchor_bltr(string.format("rightvddline_%d", i),
            point.create(
                0.5 * (
                    inverter:get_area_anchor(string.format("G%d", i)).l +
                    inverter:get_area_anchor(string.format("G%d", i)).r
                ) - 0.5 * powerlinewidth + 0.5 * xpitch,
                inverter:get_area_anchor("vssbar").b
            ),
            point.create(
                0.5 * (
                    inverter:get_area_anchor(string.format("G%d", i)).l +
                    inverter:get_area_anchor(string.format("G%d", i)).r
                ) + 0.5 * powerlinewidth + 0.5 * xpitch,
                inverter:get_area_anchor("vddbar").t
            )
        )
        geometry.rectanglebltr(inverter, generics.metal(_P.powerlinemetal),
            inverter:get_area_anchor(string.format("leftvddline_%d", i)).bl,
            inverter:get_area_anchor(string.format("leftvddline_%d", i)).tr
        )
        geometry.rectanglebltr(inverter, generics.metal(_P.powerlinemetal),
            inverter:get_area_anchor(string.format("rightvddline_%d", i)).bl,
            inverter:get_area_anchor(string.format("rightvddline_%d", i)).tr
        )
        geometry.viabltr(inverter, 1, _P.powerlinemetal,
            point.create(
                inverter:get_area_anchor(string.format("leftvddline_%d", i)).l,
                inverter:get_area_anchor("vddbar").b
            ),
            point.create(
                inverter:get_area_anchor(string.format("leftvddline_%d", i)).r,
                inverter:get_area_anchor("vddbar").t
            )
        )
        geometry.viabltr(inverter, 1, _P.powerlinemetal,
            point.create(
                inverter:get_area_anchor(string.format("rightvddline_%d", i)).l,
                inverter:get_area_anchor("vddbar").b
            ),
            point.create(
                inverter:get_area_anchor(string.format("rightvddline_%d", i)).r,
                inverter:get_area_anchor("vddbar").t
            )
        )
    end

    local nandoptions = util.add_options(oscoptions, {
        outputmetal = 2,
        outputwidth = 70,
        outputyshift = 0,
        innerconnectmetal = 3,
        innerconnectwidth = 70,
        innerconnectspace = 70,
        innerconnectyshift = 0,
    })

    local nand = object.create("nand")

    local nand_gatecontactpos = util.fill_predicate_with(2 * _P.invfingers, "upper1", function(i) return i % 4 > 1 end, "lower1")
    local nand_pcontactpos = util.fill_odd_with(2 * _P.invfingers + 1, "fullpower", "full")
    local nand_ncontactpos = util.fill_predicate_with(2 * _P.invfingers + 1, "fullpower", function(i) return i % 4 == 1 end, "full")

    local cmos = pcell.create_layout("basic/cmos", "cmos", util.add_options(oscoptions, {
        gatecontactpos = nand_gatecontactpos,
        pcontactpos = nand_pcontactpos,
        ncontactpos = nand_ncontactpos,
        npowerspace = _P.powerspace,
        ppowerspace = _P.powerspace,
        innergatestraps = 2,
        separation = 2 * oscoptions.gatestrapwidth + 3 * oscoptions.gatestrapspace,
        drawoutergatecut = _P.usegatecut,
        drawgatecuteverywhere = _P.usegatecut,
        cutheight = gatecutheight,
    }))
    nand:merge_into(cmos)
    nand:inherit_alignment_box(cmos)
    nand:inherit_all_anchors_with_prefix(cmos, "")

    -- connect gate straps
    if _P.invfingers > 1 then
        geometry.rectanglebltr(nand, generics.metal(1),
            nand:get_area_anchor(string.format("G%d", numleftdummies + 2)).bl,
            nand:get_area_anchor(string.format("G%d", numleftdummies + 2 * _P.invfingers - 1)).tr
        )
        geometry.rectanglebltr(nand, generics.metal(1),
            nand:get_area_anchor(string.format("G%d", numleftdummies + 1)).bl,
            nand:get_area_anchor(string.format("G%d", numleftdummies + 2 * _P.invfingers)).tr
        )
    end

    -- place inner-connection vias
    if _P.invfingers > 1 then
        for i = 1, _P.invfingers / 2 do
            geometry.viabltr(nand, 1, nandoptions.innerconnectmetal,
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 2 + (i - 1) * 4)).bl,
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 2 + (i - 1) * 4)).tr
            )
            geometry.viabltr(nand, 1, nandoptions.innerconnectmetal,
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 4 + (i - 1) * 4)).bl,
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 4 + (i - 1) * 4)).tr
            )
        end
    end

    -- connect inner nets
    if _P.invfingers > 1 then
        geometry.rectanglebltr(nand, generics.metal(nandoptions.innerconnectmetal),
            point.create(
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 2)).l,
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 2)).t
                    + nandoptions.innerconnectspace
            ),
            point.create(
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 2 * _P.invfingers)).r,
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 2)).t
                    + nandoptions.innerconnectspace + nandoptions.innerconnectwidth
            )
        )
        for i = 1, _P.invfingers do
            geometry.rectanglebltr(nand, generics.metal(nandoptions.innerconnectmetal),
                point.create(
                    nand:get_area_anchor(string.format("nSD%d", numleftdummies + i * 2)).l,
                    nand:get_area_anchor(string.format("nSD%d", numleftdummies + i * 2)).t
                ),
                point.create(
                    nand:get_area_anchor(string.format("nSD%d", numleftdummies + i * 2)).r,
                    nand:get_area_anchor(string.format("nSD%d", numleftdummies + i * 2)).t
                        + nandoptions.innerconnectspace
                )
            )
        end
    end

    -- place output vias
    for i = 1, _P.invfingers do
        geometry.viabltr(nand, 1, nandoptions.outputmetal,
            nand:get_area_anchor(string.format("pSD%d", numleftdummies + 2 * i)).bl,
            nand:get_area_anchor(string.format("pSD%d", numleftdummies + 2 * i)).tr
        )
        geometry.rectanglebltr(nand, generics.metal(nandoptions.outputmetal),
            point.create(
                nand:get_area_anchor(string.format("pSD%d", numleftdummies + 2 * i)).l,
                0.5 * (
                    nand:get_area_anchor(string.format("nSD%d", numleftdummies + 1)).t +
                    nand:get_area_anchor(string.format("pSD%d", numleftdummies + 1)).b
                ) + nandoptions.outputwidth / 2
            ),
            nand:get_area_anchor(string.format("pSD%d", numleftdummies + 2 * i)).br
        )
    end
    for i = 1, _P.invfingers / 2 do
        geometry.viabltr(nand, 1, nandoptions.outputmetal,
            nand:get_area_anchor(string.format("nSD%d", numleftdummies + 3 + (i - 1) * 4)).bl,
            nand:get_area_anchor(string.format("nSD%d", numleftdummies + 3 + (i - 1) * 4)).tr
        )
        geometry.rectanglebltr(nand, generics.metal(nandoptions.outputmetal),
            nand:get_area_anchor(string.format("nSD%d", numleftdummies + 3 + (i - 1) * 4)).tl,
            point.create(
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 3 + (i - 1) * 4)).r,
                0.5 * (
                    nand:get_area_anchor(string.format("nSD%d", numleftdummies + 1)).t +
                    nand:get_area_anchor(string.format("pSD%d", numleftdummies + 1)).b
                ) - nandoptions.outputwidth / 2
            )
        )
    end

    -- connect output
    geometry.rectanglebltr(nand, generics.metal(nandoptions.outputmetal),
        point.create(
            nand:get_area_anchor(string.format("pSD%d", numleftdummies + 2)).l,
            0.5 * (
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 1)).t +
                nand:get_area_anchor(string.format("pSD%d", numleftdummies + 1)).b
            ) - nandoptions.outputwidth / 2
        ),
        point.create(
            nand:get_area_anchor(string.format("pSD%d", numleftdummies + 2 * _P.invfingers)).r,
            0.5 * (
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 1)).t +
                nand:get_area_anchor(string.format("pSD%d", numleftdummies + 1)).b
            ) + nandoptions.outputwidth / 2
        )
    )

    -- nand input
    nand:add_area_anchor_bltr("input",
        point.create(
            nand:get_area_anchor(string.format("G%d", numleftdummies + 1)).l,
            nand:get_area_anchor(string.format("G%d", numleftdummies + 2)).b
        ),
        point.create(
            nand:get_area_anchor(string.format("G%d", numleftdummies + 1)).r,
            nand:get_area_anchor(string.format("G%d", numleftdummies + 2)).t
        )
    )
    geometry.viabltr(nand, 1, 2,
        nand:get_area_anchor("input").bl,
        nand:get_area_anchor("input").tr
    )
    geometry.rectanglebltr(nand, generics.metal(1),
        nand:get_area_anchor("input").bl,
        nand:get_area_anchor("input").tr:translate_x(nandoptions.gatespace)
    )

    -- nand output
    nand:add_area_anchor_bltr("output",
        point.create(
            nand:get_area_anchor(string.format("pSD%d", numleftdummies + 2)).l,
            0.5 * (
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 1)).t +
                nand:get_area_anchor(string.format("pSD%d", numleftdummies + 1)).b
            ) - nandoptions.outputwidth / 2
        ),
        point.create(
            nand:get_area_anchor(string.format("pSD%d", numleftdummies + 2 * _P.invfingers)).r,
            0.5 * (
                nand:get_area_anchor(string.format("nSD%d", numleftdummies + 1)).t +
                nand:get_area_anchor(string.format("pSD%d", numleftdummies + 1)).b
            ) + nandoptions.outputwidth / 2
        )
    )

    -- nand vss
    nand:add_area_anchor_bltr("vssbar",
        nand:get_area_anchor("PRn").bl,
        nand:get_area_anchor("PRn").tr
    )
    nand:add_area_anchor_bltr("vddbar",
        nand:get_area_anchor("PRp").bl,
        nand:get_area_anchor("PRp").tr
    )
    for i = 1, 2 * _P.invfingers do
        nand:add_area_anchor_bltr(string.format("vssline_%d", i),
            point.create(
                0.5 * (
                    nand:get_area_anchor(string.format("G%d", i)).l +
                    nand:get_area_anchor(string.format("G%d", i)).r
                ) - 0.5 * powerlinewidth,
                nand:get_area_anchor("PRn").b
            ),
            point.create(
                0.5 * (
                    nand:get_area_anchor(string.format("G%d", i)).l +
                    nand:get_area_anchor(string.format("G%d", i)).r
                ) + 0.5 * powerlinewidth,
                nand:get_area_anchor("PRp").t
            )
        )
        geometry.rectanglebltr(nand, generics.metal(_P.powerlinemetal),
            nand:get_area_anchor(string.format("vssline_%d", i)).bl,
            nand:get_area_anchor(string.format("vssline_%d", i)).tr
        )
        geometry.viabltr(nand, 1, _P.powerlinemetal,
            point.create(
                nand:get_area_anchor(string.format("vssline_%d", i)).l,
                nand:get_area_anchor("PRn").b
            ),
            point.create(
                nand:get_area_anchor(string.format("vssline_%d", i)).r,
                nand:get_area_anchor("PRn").t
            )
        )
    end

    -- nand vdd
    for i = 1, 2 * _P.invfingers do
        nand:add_area_anchor_bltr(string.format("leftvddline_%d", i),
            point.create(
                0.5 * (
                    nand:get_area_anchor(string.format("G%d", i)).l +
                    nand:get_area_anchor(string.format("G%d", i)).r
                ) - 0.5 * powerlinewidth - 0.5 * xpitch,
                nand:get_area_anchor("PRn").b
            ),
            point.create(
                0.5 * (
                    nand:get_area_anchor(string.format("G%d", i)).l +
                    nand:get_area_anchor(string.format("G%d", i)).r
                ) + 0.5 * powerlinewidth - 0.5 * xpitch,
                nand:get_area_anchor("PRp").t
            )
        )
        nand:add_area_anchor_bltr(string.format("rightvddline_%d", i),
            point.create(
                0.5 * (
                    nand:get_area_anchor(string.format("G%d", i)).l +
                    nand:get_area_anchor(string.format("G%d", i)).r
                ) - 0.5 * powerlinewidth + 0.5 * xpitch,
                nand:get_area_anchor("PRn").b
            ),
            point.create(
                0.5 * (
                    nand:get_area_anchor(string.format("G%d", i)).l +
                    nand:get_area_anchor(string.format("G%d", i)).r
                ) + 0.5 * powerlinewidth + 0.5 * xpitch,
                nand:get_area_anchor("PRp").t
            )
        )
        geometry.rectanglebltr(nand, generics.metal(_P.powerlinemetal),
            nand:get_area_anchor(string.format("leftvddline_%d", i)).bl,
            nand:get_area_anchor(string.format("leftvddline_%d", i)).tr
        )
        geometry.rectanglebltr(nand, generics.metal(_P.powerlinemetal),
            nand:get_area_anchor(string.format("rightvddline_%d", i)).bl,
            nand:get_area_anchor(string.format("rightvddline_%d", i)).tr
        )
        geometry.viabltr(nand, 1, _P.powerlinemetal,
            point.create(
                nand:get_area_anchor(string.format("leftvddline_%d", i)).l,
                nand:get_area_anchor("PRp").b
            ),
            point.create(
                nand:get_area_anchor(string.format("leftvddline_%d", i)).r,
                nand:get_area_anchor("PRp").t
            )
        )
        geometry.viabltr(nand, 1, _P.powerlinemetal,
            point.create(
                nand:get_area_anchor(string.format("rightvddline_%d", i)).l,
                nand:get_area_anchor("PRp").b
            ),
            point.create(
                nand:get_area_anchor(string.format("rightvddline_%d", i)).r,
                nand:get_area_anchor("PRp").t
            )
        )
    end

    local dummy = pcell.create_layout("basic/cmos", "dummy", util.add_options(oscoptions, {
        gatecontactpos = util.fill_all_with(_P.dummyfingers, "dummy"),
        pcontactpos = util.fill_all_with(_P.dummyfingers + 1, "fullpower"),
        ncontactpos = util.fill_all_with(_P.dummyfingers + 1, "fullpower"),
        dummycontheight = _P.powerwidth,
        npowerspace = _P.powerspace,
        ppowerspace = _P.powerspace,
        innergatestraps = 2,
        separation = 2 * oscoptions.gatestrapwidth + 3 * oscoptions.gatestrapspace,
        drawdummygatecut = false,
        overwriteinnergateextensions = true,
        innerpgateext = 0.5 * (2 * oscoptions.gatestrapwidth + 3 * oscoptions.gatestrapspace) - 0.5 * 160,
        innerngateext = 0.5 * (2 * oscoptions.gatestrapwidth + 3 * oscoptions.gatestrapspace) - 0.5 * 160,
        drawleftstopgate = _P.drawstopgates,
        leftendgatelength = _P.stopgatelength,
    }))
    -- dummy vss
    dummy:add_area_anchor_bltr("vssbar",
        dummy:get_area_anchor("PRn").bl,
        dummy:get_area_anchor("PRn").tr
    )
    dummy:add_area_anchor_bltr("vddbar",
        dummy:get_area_anchor("PRp").bl,
        dummy:get_area_anchor("PRp").tr
    )
    for i = 1, _P.dummyfingers do
        dummy:add_area_anchor_bltr(string.format("vssline_%d", i),
            point.create(
                0.5 * (
                    dummy:get_area_anchor(string.format("G%d", i)).l +
                    dummy:get_area_anchor(string.format("G%d", i)).r
                ) - 0.5 * powerlinewidth,
                dummy:get_area_anchor("PRn").b
            ),
            point.create(
                0.5 * (
                    dummy:get_area_anchor(string.format("G%d", i)).l +
                    dummy:get_area_anchor(string.format("G%d", i)).r
                ) + 0.5 * powerlinewidth,
                dummy:get_area_anchor("PRp").t
            )
        )
        geometry.rectanglebltr(dummy, generics.metal(_P.powerlinemetal),
            dummy:get_area_anchor(string.format("vssline_%d", i)).bl,
            dummy:get_area_anchor(string.format("vssline_%d", i)).tr
        )
        geometry.viabltr(dummy, 1, _P.powerlinemetal,
            point.create(
                dummy:get_area_anchor(string.format("vssline_%d", i)).l,
                dummy:get_area_anchor("PRn").b
            ),
            point.create(
                dummy:get_area_anchor(string.format("vssline_%d", i)).r,
                dummy:get_area_anchor("PRn").t
            )
        )
    end

    -- dummy vdd
    for i = 1, _P.dummyfingers do
        dummy:add_area_anchor_bltr(string.format("leftvddline_%d", i),
            point.create(
                0.5 * (
                    dummy:get_area_anchor(string.format("G%d", i)).l +
                    dummy:get_area_anchor(string.format("G%d", i)).r
                ) - 0.5 * powerlinewidth - 0.5 * xpitch,
                dummy:get_area_anchor("PRn").b
            ),
            point.create(
                0.5 * (
                    dummy:get_area_anchor(string.format("G%d", i)).l +
                    dummy:get_area_anchor(string.format("G%d", i)).r
                ) + 0.5 * powerlinewidth - 0.5 * xpitch,
                dummy:get_area_anchor("PRp").t
            )
        )
        dummy:add_area_anchor_bltr(string.format("rightvddline_%d", i),
            point.create(
                0.5 * (
                    dummy:get_area_anchor(string.format("G%d", i)).l +
                    dummy:get_area_anchor(string.format("G%d", i)).r
                ) - 0.5 * powerlinewidth + 0.5 * xpitch,
                dummy:get_area_anchor("PRn").b
            ),
            point.create(
                0.5 * (
                    dummy:get_area_anchor(string.format("G%d", i)).l +
                    dummy:get_area_anchor(string.format("G%d", i)).r
                ) + 0.5 * powerlinewidth + 0.5 * xpitch,
                dummy:get_area_anchor("PRp").t
            )
        )
        geometry.rectanglebltr(dummy, generics.metal(_P.powerlinemetal),
            dummy:get_area_anchor(string.format("leftvddline_%d", i)).bl,
            dummy:get_area_anchor(string.format("leftvddline_%d", i)).tr
        )
        geometry.rectanglebltr(dummy, generics.metal(_P.powerlinemetal),
            dummy:get_area_anchor(string.format("rightvddline_%d", i)).bl,
            dummy:get_area_anchor(string.format("rightvddline_%d", i)).tr
        )
        geometry.viabltr(dummy, 1, _P.powerlinemetal,
            point.create(
                dummy:get_area_anchor(string.format("leftvddline_%d", i)).l,
                dummy:get_area_anchor("PRp").b
            ),
            point.create(
                dummy:get_area_anchor(string.format("leftvddline_%d", i)).r,
                dummy:get_area_anchor("PRp").t
            )
        )
        geometry.viabltr(dummy, 1, _P.powerlinemetal,
            point.create(
                dummy:get_area_anchor(string.format("rightvddline_%d", i)).l,
                dummy:get_area_anchor("PRp").b
            ),
            point.create(
                dummy:get_area_anchor(string.format("rightvddline_%d", i)).r,
                dummy:get_area_anchor("PRp").t
            )
        )
    end

    local celldef = {}

    local function _insert_nand_row(celldef, rownum)
        local entry = {}
        table.insert(entry, { reference = dummy, instance = string.format("leftdummy%d", rownum) })
        table.insert(entry, { reference = nand, instance = "nand" })
        for i = 1, _P.inv_per_row - nand_inv_size_ratio do
            table.insert(entry, { reference = inverter, instance = string.format("inv_%d_%d", rownum, i) })
        end
        table.insert(entry, { reference = dummy, instance = string.format("rightdummy%d", rownum), flipx = true })
        table.insert(celldef, entry)
    end

    local function _insert_inv_row(celldef, rownum)
        local entry = {}
        local flipx = rownum % 2 == 0
        table.insert(entry, { reference = dummy, instance = string.format("leftdummy%d", rownum), })
        for i = 1, _P.inv_per_row do
            table.insert(entry, { reference = inverter, instance = string.format("inv_%d_%d", rownum, i), flipx = flipx })
        end
        table.insert(entry, { reference = dummy, instance = string.format("rightdummy%d", rownum), flipx = true })
        table.insert(celldef, entry)
    end

    for row = 1, _P.numrows do
        if row == 1 then
            _insert_nand_row(celldef, row)
        else
            _insert_inv_row(celldef, row)
        end
    end

    local cells = placement.rowwise(toplevel, celldef, true)

    -- inter-row connections
    local function _connect_rows(toplevel, cells, row1, row2, index1, index2, shift)
        local outputedge = (index1 == 2) and "r" or "l"
        local inputedge = (index2 == 2) and "l" or "r"
        geometry.path_cshape(toplevel, generics.metal(2),
            point.create(
                cells[row1][index1]:get_area_anchor("output")[outputedge],
                0.5 * (
                    cells[row1][index1]:get_area_anchor("output").b +
                    cells[row1][index1]:get_area_anchor("output").t
                )
            ),
            point.create(
                cells[row2][index2]:get_area_anchor("input")[inputedge],
                0.5 * (
                    cells[row2][index2]:get_area_anchor("input").b +
                    cells[row2][index2]:get_area_anchor("input").t
                )
            ),
            point.create(
                cells[row2][index2]:get_area_anchor("input")[inputedge] + shift,
                0 -- don't care
            ),
            70
        )
    end

    -- start/end rows
    _connect_rows(toplevel, cells, 1, 2, 1 + _P.inv_per_row - 1, 1 + _P.inv_per_row, row_conn_xshift)
    _connect_rows(toplevel, cells, _P.numrows, 1, 2, 2, -row_conn_xshift - row_conn_extraxshift)

    -- regular rows
    for row = _P.nand_row + 1, _P.numrows - 1 do
        local index = (row % 2 == 0) and 1 or _P.inv_per_row
        local shift = (row % 2 == 0) and -row_conn_xshift or row_conn_xshift
        _connect_rows(toplevel, cells, row, row + 1, 1 + index, 1 + index, shift)
    end

    local function _connect_inverters(toplevel, cells, row, inst)
        local index = (row % 2 == 0) and _P.inv_per_row + 2 - inst or inst + 1
        local incr = (row % 2 == 0) and -1 or 1
        local outputedge = (row % 2 == 0) and "l" or "r"
        local inputedge = (row % 2 == 0) and "r" or "l"
        geometry.path(toplevel, generics.metal(2), {
            point.create(
                cells[row][index]:get_area_anchor("output")[outputedge],
                0.5 * (
                    cells[row][index]:get_area_anchor("output").b +
                    cells[row][index]:get_area_anchor("output").t
                )
            ),
            point.create(
                cells[row][index + incr]:get_area_anchor("input")[inputedge],
                0.5 * (
                    cells[row][index + incr]:get_area_anchor("input").b +
                    cells[row][index + incr]:get_area_anchor("input").t
                )
            ),
        }, 70)
    end

    -- inner-row connections
    for row = _P.nand_row + 1, _P.numrows do
        for inst = 1, _P.inv_per_row - 1 do
            _connect_inverters(toplevel, cells, row, inst)
        end
    end
    for inst = 1, _P.inv_per_row - nand_inv_size_ratio - 1 + 1 do
        _connect_inverters(toplevel, cells, _P.nand_row, inst) -- skip nand
    end

    -- output buffer
    local bufferref = pcell.create_layout("analog/inverter", "buffer", util.add_options(baseoptions, {
        fingers = _P.bufferfingers,
        pwidth = _P.bufferpwidth,
        nwidth = _P.buffernwidth,
        sdwidth = _P.buffersdwidth,
        gatelength = _P.buffergatelength,
        gatespace = _P.buffergatespace,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        gatestrapleftextension = 50,
        gatestraprightextension = 50,
        gatecutheight = gatecutheight,
        pgateext = _P.powerspace + _P.powerwidth,
        ngateext = _P.powerspace + _P.powerwidth,
        drawleftstopgate = true,
        drawrightstopgate = true,
        leftpolylines = { { length = 32, space = 90 } },
        rightpolylines = { { length = 32, space = 90 } },
        gatemetal = _P.buffergatemetal,
        outputmetal = _P.bufferoutputmetal,
        outputwidth = _P.bufferoutputwidth,
        outputxshift = 0,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        numleftdummies = 2,
        numrightdummies = 2,
    }))
    local buffer = toplevel:add_child(bufferref, "buffer")
    local bufferplacementtarget
    if (_P.numrows + _P.numdummyrows) % 2 == 0 then
        local row = (_P.numrows + _P.numdummyrows) / 2
        local power
        if row % 2 == 0 then
            power = "vss"
        else
            power = "vdd"
        end
        local middlebar = cells[string.format("inv_%d_1", row)]:get_area_anchor_fmt("%sbar", power)
        bufferplacementtarget = point.create(
            cells["rightdummy1"]:get_area_anchor("nmos_active").r,
            0.5 * (middlebar.b + middlebar.t)
        )
    else
        local row = (_P.numrows + _P.numdummyrows + 1) / 2
        local gate = cells[string.format("inv_%d_1", row)]:get_area_anchor("input")
        bufferplacementtarget = point.create(
            cells["rightdummy1"]:get_area_anchor("nmos_active").r,
            0.5 * (gate.b + gate.t)
        )
    end
    buffer:move_point(
        point.create(
            buffer:get_area_anchor("input").l,
            0.5 * (
                buffer:get_area_anchor("input").b +
                buffer:get_area_anchor("input").t
            )
        ),
        bufferplacementtarget
    )
    buffer:translate_x(_P.buffershift)

    -- connect oscillator to buffer
    geometry.path_3x(toplevel, generics.metal(2),
        point.create(
            cells[1][1 + _P.inv_per_row - 1]:get_area_anchor("output").r,
            0.5 * (
                cells[1][1 + _P.inv_per_row - 1]:get_area_anchor("output").b +
                cells[1][1 + _P.inv_per_row - 1]:get_area_anchor("output").t
            )
        ),
        point.create(
            buffer:get_area_anchor("input").l,
            0.5 * (
                buffer:get_area_anchor("input").b +
                buffer:get_area_anchor("input").t
            )
        ),
        70,
        0.85
    )

    -- pwell guard ring
    layouthelpers.place_guardring(
        toplevel,
        cells[1][1]:get_area_anchor("vssbar").bl,
        point.create(
            buffer:get_area_anchor("vddbar").r,
            cells[_P.numrows + _P.numdummyrows][_P.inv_per_row + 2]:get_area_anchor_fmt("%sbar",
                ((_P.numrows + _P.numdummyrows) % 2 == 0) and "vss" or "vdd").t
                -- + 2 for dummies
        ),
        500, 400,
        "pwellguardring_",
        {
            contype = "p",
            ringwidth = 400,
            soiopenouterextension = 200,
            wellouterextension = 200,
            implantouterextension = 200,
        }
    )

    -- nwell guard ring
    layouthelpers.place_guardring(
        toplevel,
        toplevel:get_area_anchor("pwellguardring_outerboundary").bl,
        toplevel:get_area_anchor("pwellguardring_outerboundary").tr,
        400, 400,
        "nwellguardring_",
        {
            contype = "n",
            ringwidth = 400,
            fillwell = false,
            drawdeepwell = true,
            deepwelloffset = 150,
            fillinnerimplant = false,
            soiopeninnerextension = 200,
            wellinnerextension = 200,
            implantinnerextension = 200,
            wellouterextension = 200,
            implantouterextension = 200,
        }
    )
end
