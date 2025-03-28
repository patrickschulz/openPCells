function parameters()
    pcell.add_parameters(
        { "channeltype", "pmos" },
        { "vthtype", 1 },
        { "oxidetype", 1 },
        { "flippedwell", false },
        { "fingerwidth", 2500 },
        { "gatelength",  500 },
        { "gatespace",  160 },
        { "gatemetal",  2 },
        { "drainmetal",  3 },
        { "interconnectmetal", 4 },
        { "outputmetal", 3 },
        { "sourcemetal", 5 },
        { "sdwidth", 70 },
        { "fingers", 4 },
        { "viaoffset", 1000 },
        { "gatestrapwidth", 70 },
        { "gatestrapspace", 70 },
        { "gatelinewidth", 100 },
        { "gatelinespace", 100 },
        { "gateviawidth", 100 },
        { "interconnectlinewidth", 100 },
        { "interconnectlinespace", 100 },
        { "interconnectviawidth", 100 },
        { "outputlinewidth", 100 },
        { "outputlinespace", 100 },
        { "outputviawidth", 200 },
        { "outputlinetopalign", "top" },
        { "outputlinebotalign", "bottom" },
        { "outputlinetopextend", 0 },
        { "outputlinebotextend", 0 },
        { "gateconnwidth", 70 },
        { "sourcedrainstrapwidth", 100 },
        { "sourcedrainstrapspace", 100 },
        { "equalgatenets", false },
        { "innerdummies", 2 },
        { "outerdummies", 2 },
        { "interoutputvias", "topdown", posvals = set("topdown", "leftright") },
        { "extendallleft", 0 },
        { "extendallright", 0 }
    )
end

function layout(cell, _P)
    local flipsourcedrain = _P.channeltype == "nmos"
    local gatepitch = _P.gatelength + _P.gatespace
    local separation = 2 * _P.gatestrapspace + 2 * _P.gatestrapwidth + 3 * _P.gatelinespace + 2 * _P.gatelinewidth
    local rowoptions = {
        channeltype = _P.channeltype,
        oxidetype = _P.oxidetype,
        vthtype = _P.vthtype,
        flippedwell = _P.flippedwell,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        width = _P.fingerwidth,
        sdwidth = _P.sdwidth,
        gtopext = _P.gatestrapspace + _P.gatestrapwidth,
        gbotext = _P.gatestrapspace + _P.gatestrapwidth,
        extendalltop = separation / 2,
        extendallbottom = separation / 2,
        extendallleft = _P.extendallleft,
        extendallright = _P.extendallright,
    }

    local fetoptions = {
        fingers = _P.fingers,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.gatestrapspace,
        drainmetal = _P.drainmetal,
        sourcemetal = _P.sourcemetal,
        connectsource = true,
        connectsourceboth = true,
        connectsourcewidth = _P.sourcedrainstrapwidth,
        connectsourcespace = _P.sourcedrainstrapspace,
        connectdrain = true,
        connectdrainwidth = _P.sourcedrainstrapwidth,
        connectdrainspace = _P.sourcedrainstrapspace,
    }

    local dummyoptions = {
        shortdevice = true,
        shortwidth = _P.gatestrapwidth,
        shortspace = _P.gatestrapspace,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.gatestrapspace,
    }

    local row1 = util.add_options(rowoptions, {
        devices = {
            util.add_options(dummyoptions, {
                name = "outerleftdummy1",
                fingers = _P.outerdummies,
                drawbotgate = true,
                shortlocation = "bottom",
                shortdevicerightoffset = 1,
                botgaterightextension = -_P.gatelength,
            }),
            util.add_options(fetoptions, {
                name = "M1l",
                fingers = _P.fingers,
                drawtopgate = true,
                connectsourceinverse = not flipsourcedrain,
                connectdraininverse = not flipsourcedrain
            }),
            util.add_options(dummyoptions, {
                name = "innerdummy1l",
                fingers = _P.innerdummies,
                drawbotgate = true,
                shortdevice = false,
            }),
            util.add_options(fetoptions, {
                name = "M2c",
                fingers = _P.fingers,
                drawtopgate = true,
                connectsourceinverse = not flipsourcedrain,
                connectdraininverse = not flipsourcedrain
            }),
            util.add_options(dummyoptions, {
                name = "innerdummy1r",
                fingers = _P.innerdummies,
                drawbotgate = true,
                shortdevice = false,
            }),
            util.add_options(fetoptions, {
                name = "M1r",
                fingers = _P.fingers,
                drawtopgate = true,
                connectsourceinverse = not flipsourcedrain,
                connectdraininverse = not flipsourcedrain
            }),
            util.add_options(dummyoptions, {
                name = "outerrightdummy1",
                fingers = _P.outerdummies,
                drawbotgate = true,
                shortlocation = "bottom",
                shortdeviceleftoffset = 1,
                botgateleftextensions = -_P.gatelength,
            }),
        }
    })

    local row2 = util.add_options(rowoptions, {
        devices = {
            util.add_options(dummyoptions, {
                name = "outerleftdummy2",
                fingers = _P.outerdummies,
                drawtopgate = true,
                shortlocation = "top",
                shortdevicerightoffset = 1,
                topgaterightextension = -_P.gatelength,
            }),
            util.add_options(fetoptions, {
                name = "M2l",
                fingers = _P.fingers,
                drawbotgate = true,
                connectsourceinverse = flipsourcedrain,
                connectdraininverse = flipsourcedrain
            }),
            util.add_options(dummyoptions, {
                name = "innerdummy2l",
                fingers = _P.innerdummies,
                drawtopgate = true,
                shortdevice = false
            }),
            util.add_options(fetoptions, {
                name = "M1c",
                fingers = _P.fingers,
                drawbotgate = true,
                connectsourceinverse = flipsourcedrain,
                connectdraininverse = flipsourcedrain
            }),
            util.add_options(dummyoptions, {
                name = "innerdummy2r",
                fingers = _P.innerdummies,
                drawtopgate = true,
                shortdevice = false
            }),
            util.add_options(fetoptions, {
                name = "M2r",
                fingers = _P.fingers,
                drawbotgate = true,
                connectsourceinverse = flipsourcedrain,
                connectdraininverse = flipsourcedrain
            }),
            util.add_options(dummyoptions, {
                name = "outerrightdummy2",
                fingers = _P.outerdummies,
                drawtopgate = true,
                shortlocation = "top",
                shortdeviceleftoffset = 1,
                topgateleftextension = -_P.gatelength,
            }),
        }
    })

    local rows = {
        row1,
        row2
    }
    local array = pcell.create_layout("basic/stacked_mosfet_array", "_array", {
        rows = rows,
        separation = separation,
        autoskip = true,
    })
    cell:merge_into(array)
    cell:inherit_all_anchors_with_prefix(array, "")

    -- center cell
    cell:move_point_x(
        cell:get_area_anchor_fmt("M1c_sourcedrainactive%d", _P.fingers // 2 + 1).bl,
        point.create(0, 0)
    )
    cell:translate_x(-_P.sdwidth / 2)

    -- connect outer and inner dummies
    geometry.rectanglebltr(cell, generics.metal(1),
        cell:get_area_anchor("outerleftdummy1_botgatestrap").br,
        cell:get_area_anchor("outerrightdummy1_botgatestrap").tl
    )
    geometry.rectanglebltr(cell, generics.metal(1),
        cell:get_area_anchor("outerleftdummy2_topgatestrap").br,
        cell:get_area_anchor("outerrightdummy2_topgatestrap").tl
    )

    -- gate lines for split gate nets
    if not _P.equalgatenets then
        dprint(1 + nil)
        -- FIXME: this part is copied unmodified from common_centroid_2x2
        -- create gate lines
        cell:add_area_anchor_bltr("gateline1",
            cell:get_area_anchor("M1l_topgatestrap").tl:translate_y(_P.gatelinespace),
            cell:get_area_anchor("M2r_topgatestrap").tr:translate_y(_P.gatelinespace + _P.gatelinewidth)
        )
        cell:add_area_anchor_bltr("gateline2",
            cell:get_area_anchor("M1l_topgatestrap").tl:translate_y(2 * _P.gatelinespace + _P.gatelinewidth),
            cell:get_area_anchor("M2r_topgatestrap").tr:translate_y(2 * _P.gatelinespace + 2 * _P.gatelinewidth)
        )
        geometry.rectanglebltr(cell, generics.metal(_P.gatemetal),
            cell:get_area_anchor("gateline1").bl,
            cell:get_area_anchor("gateline1").tr
        )
        geometry.rectanglebltr(cell, generics.metal(_P.gatemetal),
            cell:get_area_anchor("gateline2").bl,
            cell:get_area_anchor("gateline2").tr
        )
        -- connect gates to gate lines
        for _, entry in ipairs({
            { fet = "1l", gate = "top", line = 1, factor = -1 },
            { fet = "2r", gate = "top", line = 2, factor =  1 },
            { fet = "1r", gate = "bot", line = 1, factor = -1 },
            { fet = "2l", gate = "bot", line = 2, factor =  1 },
        }) do
            geometry.viabltr(cell, 1, _P.gatemetal,
                point.create(
                    cell:get_area_anchor_fmt("M%s_%sgatestrap", entry.fet, entry.gate).l + _P.viaoffset + entry.factor * gatepitch,
                    cell:get_area_anchor_fmt("gateline%d", entry.line).b
                ),
                point.create(
                    cell:get_area_anchor_fmt("M%s_%sgatestrap", entry.fet, entry.gate).r - _P.viaoffset + entry.factor * gatepitch,
                    cell:get_area_anchor_fmt("gateline%d", entry.line).t
                )
            )
            geometry.rectanglepoints(cell, generics.metal(1),
                point.create(
                    0.5 * (
                        cell:get_area_anchor_fmt("M%s_%sgatestrap", entry.fet, entry.gate).l +
                        cell:get_area_anchor_fmt("M%s_%sgatestrap", entry.fet, entry.gate).r
                    ) + entry.factor * gatepitch - _P.gateconnwidth / 2,
                    cell:get_area_anchor_fmt("M%s_%sgatestrap", entry.fet, entry.gate).t
                ),
                point.create(
                    0.5 * (
                        cell:get_area_anchor_fmt("M%s_%sgatestrap", entry.fet, entry.gate).l +
                        cell:get_area_anchor_fmt("M%s_%sgatestrap", entry.fet, entry.gate).r
                    ) + entry.factor * gatepitch + _P.gateconnwidth / 2,
                    cell:get_area_anchor_fmt("gateline%d", entry.line).t
                )
            )
        end
    else
        -- create gate lines
        cell:add_area_anchor_bltr("gateline",
            point.create(
                cell:get_area_anchor("M1l_topgatestrap").l,
                cell:get_area_anchor("M1l_active").t + separation / 2 - _P.gatelinewidth / 2
            ),
            point.create(
                cell:get_area_anchor("M1r_topgatestrap").r,
                cell:get_area_anchor("M1r_active").t + separation / 2 + _P.gatelinewidth / 2
            )
        )
        geometry.rectanglebltr(cell, generics.metal(_P.gatemetal),
            cell:get_area_anchor("gateline").bl,
            cell:get_area_anchor("gateline").tr
        )
        geometry.viabltr(cell, 1, _P.gatemetal,
            point.create(
                0.5 * (
                    cell:get_area_anchor("M1l_topgatestrap").l +
                    cell:get_area_anchor("M1l_topgatestrap").r
                ) - _P.gateviawidth / 2,
                cell:get_area_anchor("gateline").b
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor("M1l_topgatestrap").l +
                    cell:get_area_anchor("M1l_topgatestrap").r
                ) + _P.gateviawidth / 2,
                cell:get_area_anchor("gateline").t
            )
        )
        geometry.viabltr(cell, 1, _P.gatemetal,
            point.create(
                0.5 * (
                    cell:get_area_anchor("M2c_topgatestrap").l +
                    cell:get_area_anchor("M2c_topgatestrap").r
                ) - _P.gateviawidth / 2,
                cell:get_area_anchor("gateline").b
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor("M2c_topgatestrap").l +
                    cell:get_area_anchor("M2c_topgatestrap").r
                ) + _P.gateviawidth / 2,
                cell:get_area_anchor("gateline").t
            )
        )
        geometry.viabltr(cell, 1, _P.gatemetal,
            point.create(
                0.5 * (
                    cell:get_area_anchor("M1l_topgatestrap").l +
                    cell:get_area_anchor("M1l_topgatestrap").r
                ) - _P.gateviawidth / 2,
                cell:get_area_anchor("gateline").b
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor("M1l_topgatestrap").l +
                    cell:get_area_anchor("M1l_topgatestrap").r
                ) + _P.gateviawidth / 2,
                cell:get_area_anchor("gateline").t
            )
        )
        geometry.viabltr(cell, 1, _P.gatemetal,
            point.create(
                0.5 * (
                    cell:get_area_anchor("M1r_topgatestrap").l +
                    cell:get_area_anchor("M1r_topgatestrap").r
                ) - _P.gateviawidth / 2,
                cell:get_area_anchor("gateline").b
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor("M1r_topgatestrap").l +
                    cell:get_area_anchor("M1r_topgatestrap").r
                ) + _P.gateviawidth / 2,
                cell:get_area_anchor("gateline").t
            )
        )
        geometry.rectanglebltr(cell, generics.metal(1),
            point.create(
                0.5 * (
                    cell:get_area_anchor("M1l_topgatestrap").l +
                    cell:get_area_anchor("M1l_topgatestrap").r
                ) - _P.gateconnwidth / 2,
                cell:get_area_anchor("M1l_topgatestrap").t
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor("M2l_botgatestrap").l +
                    cell:get_area_anchor("M2l_botgatestrap").r
                ) + _P.gateconnwidth / 2,
                cell:get_area_anchor("M2l_botgatestrap").t
            )
        )
        geometry.rectanglebltr(cell, generics.metal(1),
            point.create(
                0.5 * (
                    cell:get_area_anchor("M2c_topgatestrap").l +
                    cell:get_area_anchor("M2c_topgatestrap").r
                ) - _P.gateconnwidth / 2,
                cell:get_area_anchor("M2c_topgatestrap").t
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor("M1c_botgatestrap").l +
                    cell:get_area_anchor("M1c_botgatestrap").r
                ) + _P.gateconnwidth / 2,
                cell:get_area_anchor("M1c_botgatestrap").t
            )
        )
        geometry.rectanglebltr(cell, generics.metal(1),
            point.create(
                0.5 * (
                    cell:get_area_anchor("M1r_topgatestrap").l +
                    cell:get_area_anchor("M1r_topgatestrap").r
                ) - _P.gateconnwidth / 2,
                cell:get_area_anchor("M1r_topgatestrap").t
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor("M2r_botgatestrap").l +
                    cell:get_area_anchor("M2r_botgatestrap").r
                ) + _P.gateconnwidth / 2,
                cell:get_area_anchor("M2r_botgatestrap").t
            )
        )
    end

    --[[
    -- create interconnect lines
    cell:add_area_anchor_bltr("interconnectline1",
        cell:get_area_anchor("M1l_topgatestrap").tl:translate_y(_P.interconnectlinespace),
        cell:get_area_anchor("M2r_topgatestrap").tr:translate_y(_P.interconnectlinespace + _P.interconnectlinewidth)
    )
    cell:add_area_anchor_bltr("interconnectline2",
        cell:get_area_anchor("M1l_topgatestrap").tl:translate_y(2 * _P.interconnectlinespace + _P.interconnectlinewidth),
        cell:get_area_anchor("M2r_topgatestrap").tr:translate_y(2 * _P.interconnectlinespace + 2 * _P.interconnectlinewidth)
    )
    geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal),
        cell:get_area_anchor("interconnectline1").bl,
        cell:get_area_anchor("interconnectline1").tr
    )
    geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal),
        cell:get_area_anchor("interconnectline2").bl,
        cell:get_area_anchor("interconnectline2").tr
    )

    -- connect drains to interconnect lines
    for _, entry in ipairs({
        { fet = "1l", gate = 2, line = 1, factor = -1 },
        { fet = "2r", gate = -2, line = 2, factor =  1 },
        { fet = "1r", gate = 2, line = 1, factor = -1 },
        { fet = "2l", gate = -2, line = 2, factor =  1 },
    }) do
        geometry.viabltr(cell, _P.drainmetal, _P.interconnectmetal,
            point.create(
                0.5 * (
                    cell:get_area_anchor_fmt("M%s_gate%d", entry.fet, entry.gate).l +
                    cell:get_area_anchor_fmt("M%s_gate%d", entry.fet, entry.gate).r
                ) - _P.interconnectviawidth / 2,
                cell:get_area_anchor_fmt("interconnectline%d", entry.line).b
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor_fmt("M%s_gate%d", entry.fet, entry.gate).l +
                    cell:get_area_anchor_fmt("M%s_gate%d", entry.fet, entry.gate).r
                ) + _P.interconnectviawidth / 2,
                cell:get_area_anchor_fmt("interconnectline%d", entry.line).t
            )
        )
        geometry.rectanglepoints(cell, generics.metal(_P.drainmetal),
            point.create(
                0.5 * (
                    cell:get_area_anchor_fmt("M%s_gate%d", entry.fet, entry.gate).l +
                    cell:get_area_anchor_fmt("M%s_gate%d", entry.fet, entry.gate).r
                ) - _P.sdwidth / 2,
                cell:get_area_anchor_fmt("M%s_drainstrap", entry.fet).t
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor_fmt("M%s_gate%d", entry.fet, entry.gate).l +
                    cell:get_area_anchor_fmt("M%s_gate%d", entry.fet, entry.gate).r
                ) + _P.sdwidth / 2,
                cell:get_area_anchor_fmt("interconnectline%d", entry.line).t
            )
        )
    end

    -- create output lines
    local outputline_ytop
    if _P.outputlinetopalign == "top" then
        outputline_ytop = cell:get_area_anchor("M2l_active").t
    else -- _P.outputlinetopalign == "center"
        outputline_ytop = cell:get_area_anchor("M2l_active").b
    end
    local outputline_ybot
    if _P.outputlinebotalign == "bottom" then
        outputline_ybot = cell:get_area_anchor("M1l_active").b
    else -- _P.outputlinebotalign == "center"
        outputline_ybot = cell:get_area_anchor("M1l_active").t
    end
    cell:add_area_anchor_bltr("outputline1",
        point.create(
            0.5 * (
                cell:get_area_anchor("M1l_sourcedrainactiveright").r +
                cell:get_area_anchor("M1r_sourcedrainactiveleft").l
            ) - _P.outputlinespace / 2 - _P.outputlinewidth,
            outputline_ybot - _P.outputlinebotextend
        ),
        point.create(
            0.5 * (
                cell:get_area_anchor("M1l_sourcedrainactiveright").r +
                cell:get_area_anchor("M1r_sourcedrainactiveleft").l
            ) - _P.outputlinespace / 2,
            outputline_ytop + _P.outputlinetopextend
        )
    )
    cell:add_area_anchor_bltr("outputline2",
        point.create(
            0.5 * (
                cell:get_area_anchor("M1l_sourcedrainactiveright").r +
                cell:get_area_anchor("M1r_sourcedrainactiveleft").l
            ) + _P.outputlinespace / 2,
            outputline_ybot - _P.outputlinebotextend
        ),
        point.create(
            0.5 * (
                cell:get_area_anchor("M1l_sourcedrainactiveright").r +
                cell:get_area_anchor("M1r_sourcedrainactiveleft").l
            ) + _P.outputlinespace / 2 + _P.outputlinewidth,
            outputline_ytop + _P.outputlinetopextend
        )
    )
    geometry.rectanglebltr(cell, generics.metal(_P.outputmetal),
        cell:get_area_anchor("outputline1").bl,
        cell:get_area_anchor("outputline1").tr
    )
    geometry.rectanglebltr(cell, generics.metal(_P.outputmetal),
        cell:get_area_anchor("outputline2").bl,
        cell:get_area_anchor("outputline2").tr
    )

    -- connect interconnect lines to output lines
    if _P.interoutputvias == "topdown" then
        geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
            point.create(
                cell:get_area_anchor("outputline1").l,
                cell:get_area_anchor("interconnectline1").b - _P.outputviawidth
            ),
            point.create(
                cell:get_area_anchor("outputline1").r,
                cell:get_area_anchor("interconnectline1").b
            )
        )
        geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
            point.create(
                cell:get_area_anchor("outputline2").l,
                cell:get_area_anchor("interconnectline2").t
            ),
            point.create(
                cell:get_area_anchor("outputline2").r,
                cell:get_area_anchor("interconnectline2").t + _P.outputviawidth
            )
        )
    else -- _P.interoutputvias == "leftright
        geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
            point.create(
                cell:get_area_anchor("outputline1").l - _P.outputviawidth,
                cell:get_area_anchor("interconnectline1").b
            ),
            point.create(
                cell:get_area_anchor("outputline1").l,
                cell:get_area_anchor("interconnectline1").t
            )
        )
        geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
            point.create(
                cell:get_area_anchor("outputline2").r,
                cell:get_area_anchor("interconnectline2").b
            ),
            point.create(
                cell:get_area_anchor("outputline2").r + _P.outputviawidth,
                cell:get_area_anchor("interconnectline2").t
            )
        )
    end

    -- connect all sources
    for i = 2, _P.fingers, 2 do
        geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
            point.create(
                cell:get_area_anchor_fmt("M%s_sourcedrainactive%d", "1l", i).l,
                cell:get_area_anchor_fmt("M%s_sourcestrap", "1l").b
            ),
            point.create(
                cell:get_area_anchor_fmt("M%s_sourcedrainactive%d", "1l", i).r,
                cell:get_area_anchor_fmt("M%s_sourcestrap", "2l").t
            )
        )
        geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
            point.create(
                cell:get_area_anchor_fmt("M%s_sourcedrainactive%d", "2r", i).l,
                cell:get_area_anchor_fmt("M%s_sourcestrap", "2r").b
            ),
            point.create(
                cell:get_area_anchor_fmt("M%s_sourcedrainactive%d", "2r", i).r,
                cell:get_area_anchor_fmt("M%s_sourcestrap", "1r").t
            )
        )
    end
    --]]
end
