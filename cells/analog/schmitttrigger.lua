function parameters()
    pcell.add_parameters(
        { "buffer_output",              true },
        { "gatelength",                 technology.get_dimension("Minimum Gate Length") },
        { "gatespace",                  technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space") },
        { "pmosfingerwidth",            technology.get_dimension("Minimum Gate Width") },
        { "nmosfingerwidth",            technology.get_dimension("Minimum Gate Width") },
        { "pmosvthtype",                1 },
        { "pmosoxidetype",              1 },
        { "pmosflippedwell",            false },
        { "nmosvthtype",                1 },
        { "nmosoxidetype",              1 },
        { "nmosflippedwell",            false },
        { "gatestrapwidth",             technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace",             technology.get_dimension("Minimum M1 Space") },
        { "invfingers",                 4 },
        { "crossfingers",               4 },
        { "outputmetal",                2 },
        { "sdwidth",                    technology.get_dimension("Minimum M1 Width") },
        { "powerwidth",                 technology.get_dimension("Minimum M1 Width") },
        { "powerspace",                 technology.get_dimension("Minimum M1 Space") },
        { "doublepowerrails",           false },
        { "gatecutheight",              technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace") },
        { "drawstopgates",              false },
        { "extendall",                  0 },
        { "extendalltop",               0, follow = "extendall" },
        { "extendallbottom",            0, follow = "extendall" },
        { "extendallleft",              0, follow = "extendall" },
        { "extendallright",             0, follow = "extendall" },
        { "extendoxidetypetop",         technology.get_dimension("Minimum Oxide Extension"), follow = "extendalltop" },
        { "extendoxidetypebottom",      technology.get_dimension("Minimum Oxide Extension"), follow = "extendallbottom" },
        { "extendoxidetypeleft",        technology.get_dimension("Minimum Oxide Extension"), follow = "extendallleft" },
        { "extendoxidetyperight",       technology.get_dimension("Minimum Oxide Extension"), follow = "extendallright" },
        { "extendvthtypetop",           technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendalltop" },
        { "extendvthtypebottom",        technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallbottom" },
        { "extendvthtypeleft",          technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallleft" },
        { "extendvthtyperight",         technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallright" },
        { "extendimplanttop",           technology.get_dimension("Minimum Implant Extension"), follow = "extendalltop" },
        { "extendimplantbottom",        technology.get_dimension("Minimum Implant Extension"), follow = "extendallbottom" },
        { "extendimplantleft",          technology.get_dimension("Minimum Implant Extension"), follow = "extendallleft" },
        { "extendimplantright",         technology.get_dimension("Minimum Implant Extension"), follow = "extendallright" },
        { "extendwelltop",              technology.get_dimension("Minimum Well Extension"), follow = "extendalltop" },
        { "extendwellbottom",           technology.get_dimension("Minimum Well Extension"), follow = "extendallbottom" },
        { "extendwellleft",             technology.get_dimension("Minimum Well Extension"), follow = "extendallleft" },
        { "extendwellright",            technology.get_dimension("Minimum Well Extension"), follow = "extendallright" }
    )
end

function layout(schmitttrigger, _P, env)
    local baseoptions = {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.gatestrapspace,
        sourcemetal = 1,
        sdwidth = _P.sdwidth,
        extratopstrapwidth = _P.powerwidth,
        extratopstrapspace = _P.powerspace,
        extrabotstrapwidth = _P.powerwidth,
        extrabotstrapspace = _P.powerspace,
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
        topgatecutleftext = _P.gatespace / 2,
        topgatecutrightext = _P.gatespace / 2,
        botgatecutleftext = _P.gatespace / 2,
        botgatecutrightext = _P.gatespace / 2,
    }
    local gatecontactpos = {}
    local contactpos = {}
    -- input inverter
    for i = 1, 2 * _P.invfingers do
        table.insert(gatecontactpos, "center")
    end
    for i = 1, 2 * _P.invfingers + 1 do
        if i % 4 == 1 then
            table.insert(contactpos, "fullpower")
        else
            table.insert(contactpos, "full")
        end
    end
    -- separator
    table.insert(gatecontactpos, "dummy")
    -- output cross-coupling
    for i = 1, _P.crossfingers do
        table.insert(gatecontactpos, "center")
    end
    for i = 1, _P.crossfingers + 1 do
        table.insert(contactpos, "full")
    end
    local cmos = pcell.create_layout("basic/cmos", "_cmos", util.add_options({}, {
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        innergatestraps = 1,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        pwidth = _P.pmosfingerwidth,
        nwidth = _P.nmosfingerwidth,
        sdwidth = _P.sdwidth,
        powerspace = _P.powerspace,
        powerwidth = _P.powerwidth,
        separationautocalc = true,
        drawleftstopgate = _P.drawstopgates,
        drawrightstopgate = _P.drawstopgates,
    }))
    schmitttrigger:merge_into(cmos)
    --[[
    local Pinv = pcell.create_layout("basic/mosfet", "Pinv", util.add_options(baseoptions, {
        fingers = 2 * _P.invfingers,
        fingerwidth = _P.pmosfingerwidth,
        channeltype = "pmos",
        vthtype = _P.pmosvthtype,
        oxidetype = _P.pmosoxidetype,
        flippedwell = _P.pmosflippedwell,
        drawbotgate = true,
        drawextratopstrap = true,
        gtopext = _P.powerwidth + _P.powerspace,
        implantalignbottomwithactive = true,
        oxidetypealignbottomwithactive = true,
        vthtypealignbottomwithactive = true,
        extendimplantbottom = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendvthtypebottom = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendoxidetypebottom = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        drawstopgatebotgatecut = true,
        drawleftstopgate = true,
        botgatecutheight = _P.gatecutheight,
        botgatecutspace = _P.gatestrapwidth / 2 + _P.gatestrapspace - _P.gatecutheight / 2,
    }))
    local Pseparator = pcell.create_layout("basic/mosfet", "Pseparator", util.add_options(baseoptions, {
        fingers = 1,
        fingerwidth = _P.pmosfingerwidth,
        channeltype = "pmos",
        vthtype = _P.pmosvthtype,
        oxidetype = _P.pmosoxidetype,
        flippedwell = _P.pmosflippedwell,
        drawtopgate = true,
        topgatewidth = _P.powerwidth,
        topgatespace = _P.powerspace,
        drawextratopstrap = true,
        extratopstraprightalign = 2,
        gtopext = _P.powerwidth + _P.powerspace,
        implantalignbottomwithactive = true,
        oxidetypealignbottomwithactive = true,
        vthtypealignbottomwithactive = true,
        extendimplantbottom = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendvthtypebottom = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendoxidetypebottom = _P.gatestrapwidth / 2 + _P.gatestrapspace,
    }))
    local Pcross = pcell.create_layout("basic/mosfet", "Pcross", util.add_options(baseoptions, {
        fingers = _P.crossfingers,
        fingerwidth = _P.pmosfingerwidth,
        channeltype = "pmos",
        vthtype = _P.pmosvthtype,
        oxidetype = _P.pmosoxidetype,
        flippedwell = _P.pmosflippedwell,
        drawbotgate = true,
        botgatemetal = _P.outputmetal,
        drawbotgatevia = true,
        drawextratopstrap = true,
        drainmetal = _P.doublepowerrails and 2 or 3,
        drawdrainvia = true,
        drainviasize = _P.pmosfingerwidth / 2,
        drainviaalign = _P.doublepowerrails and "top" or "bottom",
        sourcemetal = 2,
        drawsourcevia = true,
        sourceviasize = _P.pmosfingerwidth / 2,
        sourceviaalign = _P.doublepowerrails and "bottom" or "top",
        gtopext = _P.powerwidth + _P.powerspace,
        implantalignbottomwithactive = true,
        oxidetypealignbottomwithactive = true,
        vthtypealignbottomwithactive = true,
        extendimplantbottom = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendvthtypebottom = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendoxidetypebottom = _P.gatestrapwidth / 2 + _P.gatestrapspace,
    }))
    local Ninv = pcell.create_layout("basic/mosfet", "Ninv", util.add_options(baseoptions, {
        fingers = 2 * _P.invfingers,
        fingerwidth = _P.nmosfingerwidth,
        channeltype = "nmos",
        vthtype = _P.nmosvthtype,
        oxidetype = _P.nmosoxidetype,
        flippedwell = _P.nmosflippedwell,
        drawtopgate = true,
        drawextrabotstrap = true,
        gbotext = _P.powerwidth + _P.powerspace,
        implantaligntopwithactive = true,
        oxidetypealigntopwithactive = true,
        vthtypealigntopwithactive = true,
        drawstopgatetopgatecut = true,
        topgatecutheight = _P.gatecutheight,
        topgatecutspace = _P.gatestrapwidth / 2 + _P.gatestrapspace - _P.gatecutheight / 2,
        drawleftstopgate = true,
        extendimplanttop = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendvthtypetop = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendoxidetypetop = _P.gatestrapwidth / 2 + _P.gatestrapspace,
    }))
    local Nseparator = pcell.create_layout("basic/mosfet", "Nseparator", util.add_options(baseoptions, {
        fingers = 1,
        fingerwidth = _P.nmosfingerwidth,
        channeltype = "nmos",
        vthtype = _P.nmosvthtype,
        oxidetype = _P.nmosoxidetype,
        flippedwell = _P.nmosflippedwell,
        drawbotgate = true,
        botgatewidth = _P.powerwidth,
        botgatespace = _P.powerspace,
        drawextrabotstrap = true,
        extrabotstraprightalign = 2,
        gbotext = _P.powerwidth + _P.powerspace,
        implantaligntopwithactive = true,
        oxidetypealigntopwithactive = true,
        vthtypealigntopwithactive = true,
        extendimplanttop = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendvthtypetop = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendoxidetypetop = _P.gatestrapwidth / 2 + _P.gatestrapspace,
    }))
    local Ncross = pcell.create_layout("basic/mosfet", "Ncross", util.add_options(baseoptions, {
        fingers = _P.crossfingers,
        fingerwidth = _P.nmosfingerwidth,
        channeltype = "nmos",
        vthtype = _P.nmosvthtype,
        oxidetype = _P.nmosoxidetype,
        flippedwell = _P.nmosflippedwell,
        drawtopgate = true,
        topgatemetal = _P.outputmetal,
        drawtopgatevia = true,
        drawextrabotstrap = true,
        sourcemetal = _P.doublepowerrails and 2 or 3,
        drawsourcevia = true,
        sourceviasize = _P.nmosfingerwidth / 2,
        sourceviaalign = "top",
        drainmetal = 2,
        drawdrainvia = true,
        drainviasize = _P.nmosfingerwidth / 2,
        drainviaalign = "bottom",
        gbotext = _P.powerwidth + _P.powerspace,
        implantaligntopwithactive = true,
        oxidetypealigntopwithactive = true,
        vthtypealigntopwithactive = true,
        extendimplanttop = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendvthtypetop = _P.gatestrapwidth / 2 + _P.gatestrapspace,
        extendoxidetypetop = _P.gatestrapwidth / 2 + _P.gatestrapspace,
    }))
    local Pseparator_middle = Pseparator:copy()
    local Pseparator_right = Pseparator:copy()
    Pseparator_middle:align_bottom(Pinv)
    Pseparator_middle:abut_right(Pinv)
    Pcross:align_bottom(Pseparator_middle)
    Pcross:abut_right(Pseparator_middle)
    Pseparator_right:align_bottom(Pcross)
    Pseparator_right:abut_right(Pcross)
    Ninv:align_area_anchor("topgatestrap", Pinv, "botgatestrap")
    local Nseparator_middle = Nseparator:copy()
    local Nseparator_right = Nseparator:copy()
    Nseparator_middle:align_bottom(Ninv)
    Nseparator_middle:abut_right(Ninv)
    Ncross:align_bottom(Nseparator_middle)
    Ncross:abut_right(Nseparator_middle)
    Nseparator_right:align_bottom(Ncross)
    Nseparator_right:abut_right(Ncross)
    schmitttrigger:merge_into(Pinv)
    schmitttrigger:merge_into(Pseparator_middle)
    schmitttrigger:merge_into(Pcross)
    schmitttrigger:merge_into(Pseparator_right)
    schmitttrigger:merge_into(Ninv)
    schmitttrigger:merge_into(Nseparator_middle)
    schmitttrigger:merge_into(Ncross)
    schmitttrigger:merge_into(Nseparator_right)
    schmitttrigger:set_alignment_box(
        Ninv:get_area_anchor("extrabotstrap").bl,
        point.combine_12(
            Pseparator_right:get_area_anchor("sourcedrain-1").br,
            Pinv:get_area_anchor("extratopstrap").tl
        ),
        point.combine_12(
            Ninv:get_area_anchor("sourcedrain1").br,
            Ninv:get_area_anchor("extrabotstrap").tl
        ),
        point.combine_12(
            Pseparator_right:get_area_anchor("sourcedrain-1").bl,
            Pinv:get_area_anchor("extratopstrap").bl
        )
    )

    -- draw power rail connections
    for i = 1, 2 * _P.invfingers + 1, 4 do
        geometry.rectanglebltr(schmitttrigger, generics.metal(1),
            Pinv:get_area_anchor(string.format("sourcedrain%d", i)).tl,
            point.combine_12(
                Pinv:get_area_anchor(string.format("sourcedrain%d", i)).tr,
                Pinv:get_area_anchor("extratopstrap").bl
            )
        )
        geometry.rectanglebltr(schmitttrigger, generics.metal(1),
            point.combine_12(
                Ninv:get_area_anchor(string.format("sourcedrain%d", i)).tl,
                Ninv:get_area_anchor("extrabotstrap").tl
            ),
            Ninv:get_area_anchor(string.format("sourcedrain%d", i)).tr
        )
    end

    -- draw inverter output connections
    for i = 3, 2 * _P.invfingers + 1, 4 do
        geometry.viabltr(schmitttrigger, 1, _P.outputmetal,
            Pinv:get_area_anchor(string.format("sourcedrain%d", i)).bl,
            Pinv:get_area_anchor(string.format("sourcedrain%d", i)).br:translate_y(_P.pmosfingerwidth / 2)
        )
        geometry.viabltr(schmitttrigger, 1, _P.outputmetal,
            Ninv:get_area_anchor(string.format("sourcedrain%d", i)).tl:translate_y(-_P.nmosfingerwidth / 2),
            Ninv:get_area_anchor(string.format("sourcedrain%d", i)).tr
        )
        geometry.rectanglebltr(schmitttrigger, generics.metal(_P.outputmetal),
            Ninv:get_area_anchor(string.format("sourcedrain%d", i)).tl,
            Pinv:get_area_anchor(string.format("sourcedrain%d", i)).br
        )
    end
    geometry.rectanglebltr(schmitttrigger, generics.metal(_P.outputmetal),
        point.combine_12(
            Ninv:get_area_anchor(string.format("sourcedrain%d", 3)).tl,
            Ncross:get_area_anchor("topgatestrap").bl
        ),
        Ncross:get_area_anchor("topgatestrap").tl
    )

    -- draw inner node vias
    for i = 2, 2 * _P.invfingers + 1, 2 do
        geometry.viabltr(schmitttrigger, 1, 2,
            Pinv:get_area_anchor(string.format("sourcedrain%d", i)).tl:translate_y(-_P.pmosfingerwidth / 2),
            Pinv:get_area_anchor(string.format("sourcedrain%d", i)).tr
        )
        geometry.viabltr(schmitttrigger, 1, 2,
            Ninv:get_area_anchor(string.format("sourcedrain%d", i)).bl,
            Ninv:get_area_anchor(string.format("sourcedrain%d", i)).br:translate_y(_P.nmosfingerwidth / 2)
        )
    end


    -- draw inverse power connections
    if _P.doublepowerrails then
        local crossmetal = 2
        for i = 2, _P.crossfingers + 1, 2 do
            geometry.rectanglebltr(schmitttrigger, generics.metal(crossmetal),
                Pcross:get_area_anchor(string.format("sourcedrain%d", i)).tl,
                point.combine_12(
                    Pcross:get_area_anchor(string.format("sourcedrain%d", i)).br,
                    Pcross:get_area_anchor("extratopstrap").tl:translate_y(_P.powerspace + _P.powerwidth)
                )
            )
            geometry.rectanglebltr(schmitttrigger, generics.metal(crossmetal),
                point.combine_12(
                    Ncross:get_area_anchor(string.format("sourcedrain%d", i)).bl,
                    Ncross:get_area_anchor("extrabotstrap").bl:translate_y(-_P.powerspace - _P.powerwidth)
                ),
                Ncross:get_area_anchor(string.format("sourcedrain%d", i)).br
            )
        end
    else
        local crossmetal = 3
        for i = 2, _P.crossfingers + 1, 2 do
            geometry.rectanglebltr(schmitttrigger, generics.metal(crossmetal),
                point.combine_12(
                    Pcross:get_area_anchor(string.format("sourcedrain%d", i)).bl,
                    Ncross:get_area_anchor("extrabotstrap").br
                ),
                Pcross:get_area_anchor(string.format("sourcedrain%d", i)).br
            )
        end
        for i = 1, _P.crossfingers + 1, 2 do
            geometry.rectanglebltr(schmitttrigger, generics.metal(crossmetal),
                Ncross:get_area_anchor(string.format("sourcedrain%d", i)).tl,
                point.combine_12(
                    Ncross:get_area_anchor(string.format("sourcedrain%d", i)).tr,
                    Pcross:get_area_anchor("extratopstrap").tr
                )
            )
        end
    end

    -- connect internal nets
    if _P.doublepowerrails then
        geometry.rectanglebltr(schmitttrigger, generics.metal(2),
            Pinv:get_area_anchor("sourcedrain2").tl:translate_y(-_P.sdwidth),
            Pcross:get_area_anchor("sourcedrain1").tr
        )
        geometry.rectanglebltr(schmitttrigger, generics.metal(2),
            Ninv:get_area_anchor("sourcedrain2").bl,
            Ncross:get_area_anchor("sourcedrain1").br:translate_y(_P.sdwidth)
        )
        geometry.rectanglebltr(schmitttrigger, generics.metal(2),
            Pcross:get_area_anchor("sourcedrain1").bl,
            Pcross:get_area_anchor("sourcedrain1").tr
        )
        geometry.rectanglebltr(schmitttrigger, generics.metal(2),
            Ncross:get_area_anchor("sourcedrain1").bl,
            Ncross:get_area_anchor("sourcedrain1").tr
        )
        geometry.rectanglebltr(schmitttrigger, generics.metal(2),
            Pcross:get_area_anchor("sourcedrain1").bl,
            Pcross:get_area_anchor("sourcedrain-1").br:translate_y(_P.sdwidth)
        )
        geometry.rectanglebltr(schmitttrigger, generics.metal(2),
            Ncross:get_area_anchor("sourcedrain1").tl:translate_y(-_P.sdwidth),
            Ncross:get_area_anchor("sourcedrain-1").tr
        )
    else
        geometry.rectanglebltr(schmitttrigger, generics.metal(2),
            Pinv:get_area_anchor("sourcedrain2").tl:translate_y(-_P.sdwidth),
            Pcross:get_area_anchor("sourcedrain-1").tr
        )
        geometry.rectanglebltr(schmitttrigger, generics.metal(2),
            Ninv:get_area_anchor("sourcedrain2").bl,
            Ncross:get_area_anchor("sourcedrain-1").br:translate_y(_P.sdwidth)
        )
    end

    -- extra power rails / vias on power rails
    if _P.doublepowerrails then
        geometry.viabltr_xcontinuous(schmitttrigger, 1, 2,
            Pinv:get_area_anchor("extratopstrap").bl:translate_y(_P.powerspace + _P.powerwidth),
            Pseparator_right:get_area_anchor("extratopstrap").tr:translate_y(_P.powerspace + _P.powerwidth)
        )
        geometry.viabltr_xcontinuous(schmitttrigger, 1, 2,
            Ninv:get_area_anchor("extrabotstrap").bl:translate_y(-_P.powerspace - _P.powerwidth),
            Nseparator_right:get_area_anchor("extrabotstrap").tr:translate_y(-_P.powerspace - _P.powerwidth)
        )
    else
        geometry.viabltr_xcontinuous(schmitttrigger, 1, crossmetal,
            Pinv:get_area_anchor("extratopstrap").bl,
            Pseparator_right:get_area_anchor("extratopstrap").tr
        )
        geometry.viabltr_xcontinuous(schmitttrigger, 1, crossmetal,
            Ninv:get_area_anchor("extrabotstrap").bl,
            Nseparator_right:get_area_anchor("extrabotstrap").tr
        )
    end

    -- connect last separator to power
    geometry.rectanglebltr(schmitttrigger, generics.metal(1),
        Pseparator_right:get_area_anchor("sourcedrain-1").tl,
        point.combine_12(
            Pseparator_right:get_area_anchor("sourcedrain-1").tr,
            Pseparator_right:get_area_anchor("extratopstrap").br
        )
    )
    geometry.rectanglebltr(schmitttrigger, generics.metal(1),
        point.combine_12(
            Nseparator_right:get_area_anchor("sourcedrain-1").bl,
            Nseparator_right:get_area_anchor("extrabotstrap").tl
        ),
        Nseparator_right:get_area_anchor("sourcedrain-1").br
    )

    -- vss anchor
    schmitttrigger:add_area_anchor_bltr("vss",
        Ninv:get_area_anchor("extrabotstrap").bl,
        Nseparator_right:get_area_anchor("extrabotstrap").tr
    )

    -- vdd anchor
    schmitttrigger:add_area_anchor_bltr("vdd",
        Pinv:get_area_anchor("extratopstrap").bl,
        Pseparator_right:get_area_anchor("extratopstrap").tr
    )

    -- input anchor
    schmitttrigger:add_area_anchor_bltr("input",
        Ninv:get_area_anchor("topgatestrap").bl,
        Ninv:get_area_anchor("topgatestrap").tr
    )

    -- output anchor
    schmitttrigger:add_area_anchor_bltr("output",
        Ncross:get_area_anchor("topgatestrap").bl,
        Ncross:get_area_anchor("topgatestrap").tr
    )

    -- ports
    schmitttrigger:add_port("vout", generics.metalport(2),
        point.combine(
            schmitttrigger:get_area_anchor("output").br,
            schmitttrigger:get_area_anchor("output").tr
        )
    )
    schmitttrigger:add_port("vin", generics.metalport(1),
        point.combine(
            schmitttrigger:get_area_anchor("input").bl,
            schmitttrigger:get_area_anchor("input").tl
        )
    )
    schmitttrigger:add_port("vdd", generics.metalport(1),
        schmitttrigger:get_area_anchor("vdd").bl
    )
    schmitttrigger:add_port("vss", generics.metalport(1),
        schmitttrigger:get_area_anchor("vss").bl
    )
    --]]
end
