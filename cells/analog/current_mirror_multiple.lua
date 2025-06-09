function parameters()
    pcell.add_parameters(
        { "channeltype", "nmos" },
        { "oxidetype", 1 },
        { "vthtype", 1 },
        { "flippedwell", false },
        { "fingerwidth", 0 },
        { "gatelength", 0 },
        { "gatespace", 0 },
        { "numgates", 2 },
        { "rowdef", { "output1", "output2 "} },
        { "dummyfingerwidth", 0 },
        { "drainmetal", 2 },
        { "gatemetal", 2 },
        { "powerwidth", 0 },
        { "powerspace", 0 },
        { "gatelinewidth", 0 },
        { "sdwidth", 0 },
        { "add_dummy_rows", true },
        { "connectdummiestomain", false },
        { "dummygates", 3 },
        { "gatecutheight", 0 },
        { "botgatecutspace", 250 },
        { "drawleftrightstopgates", false },
        { "endgatelength", 0 },
        { "extendall",                                                                                  0 },
        { "extendalltop",                                                                               0, follow = "extendall" },
        { "extendallbottom",                                                                            0, follow = "extendall" },
        { "extendallleft",                                                                              0, follow = "extendall" },
        { "extendallright",                                                                             0, follow = "extendall" },
        { "extendoxidetypetop",                                                                         0, follow = "extendalltop" },
        { "extendoxidetypebottom",                                                                      0, follow = "extendallbottom" },
        { "extendoxidetypeleft",                                                                        0, follow = "extendallleft" },
        { "extendoxidetyperight",                                                                       0, follow = "extendallright" },
        { "extendvthtypetop",                                                                           0, follow = "extendalltop" },
        { "extendvthtypebottom",                                                                        0, follow = "extendallbottom" },
        { "extendvthtypeleft",                                                                          0, follow = "extendallleft" },
        { "extendvthtyperight",                                                                         0, follow = "extendallright" },
        { "extendimplanttop",                                                                           0, follow = "extendalltop" },
        { "extendimplantbottom",                                                                        0, follow = "extendallbottom" },
        { "extendimplantleft",                                                                          0, follow = "extendallleft" },
        { "extendimplantright",                                                                         0, follow = "extendallright" },
        { "extendwelltop",                                                                              0, follow = "extendalltop" },
        { "extendwellbottom",                                                                           0, follow = "extendallbottom" },
        { "extendwellleft",                                                                             0, follow = "extendallleft" },
        { "extendwellright",                                                                            0, follow = "extendallright" },
        { "extendlvsmarkertop",                                                                         0, follow = "extendalltop" },
        { "extendlvsmarkerbottom",                                                                      0, follow = "extendallbottom" },
        { "extendlvsmarkerleft",                                                                        0, follow = "extendallleft" },
        { "extendlvsmarkerright",                                                                       0, follow = "extendallright" },
        { "extendrotationmarkertop",                                                                    0, follow = "extendalltop" },
        { "extendrotationmarkerbottom",                                                                 0, follow = "extendallbottom" },
        { "extendrotationmarkerleft",                                                                   0, follow = "extendallleft" },
        { "extendrotationmarkerright",                                                                  0, follow = "extendallright" },
        { "extendanalogmarkertop",                                                                      0, follow = "extendalltop" },
        { "extendanalogmarkerbottom",                                                                   0, follow = "extendallbottom" },
        { "extendanalogmarkerleft",                                                                     0, follow = "extendallleft" },
        { "extendanalogmarkerright",                                                                    0, follow = "extendallright" }
    )
end

function layout(cell, _P)
    local separation = _P.powerwidth + 2 * _P.powerspace
    local mainoptions = {
        connectsource = true,
        topgatemetal = _P.gatemetal,
        botgatemetal = _P.gatemetal,
        drainmetal = _P.drainmetal,
        topgatewidth = _P.powerwidth,
        topgatespace = _P.powerspace,
        topgateleftextension = _P.connectdummiestomain and _P.gatespace / 2 or 0,
        topgaterightextension = _P.connectdummiestomain and _P.gatespace / 2 or 0,
        topgatecontinuousvia = true,
        botgatewidth = _P.powerwidth,
        botgatespace = _P.powerspace,
        botgateleftextension = _P.connectdummiestomain and _P.gatespace / 2 or 0,
        botgaterightextension = _P.connectdummiestomain and _P.gatespace / 2 or 0,
        botgatecontinuousvia = true,
        topgatecutheight = _P.gatecutheight,
        topgatecutspace = (separation - _P.gatecutheight) / 2,
        topgatecutleftext = _P.gatespace / 2,
        topgatecutrightext = _P.gatespace / 2,
        botgatecutheight = _P.gatecutheight,
        botgatecutspace = (separation - _P.gatecutheight) / 2,
        botgatecutleftext = _P.gatespace / 2,
        botgatecutrightext = _P.gatespace / 2,
    }
    local dummyoptions = util.add_options(mainoptions, {
        connectdrain = true,
        connectsource = true,
        drainmetal = 1,
        connectdrainleftext = _P.gatelength + _P.gatespace,
        topgatemetal = 1,
        botgatemetal = 1,
    })

    local row_base_options = {
        channeltype = _P.channeltype,
        oxidetype = _P.oxidetype,
        vthtype = _P.vthtype,
        flippedwell = _P.flippedwell,
        width = _P.fingerwidth,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
        sdwidth = _P.sdwidth,
        leftendgatelength = _P.endgatelength,
        rightendgatelength = _P.endgatelength,
        extendoxidetypetop = _P.extendoxidetypetop,
        extendoxidetypebottom = _P.extendoxidetypebottom,
        extendoxidetypeleft = _P.extendoxidetypeleft,
        extendoxidetyperight = _P.extendoxidetyperight,
        extendvthtypetop = _P.extendvthtypetop,
        extendvthtypebottom = _P.extendvthtypebottom,
        extendvthtypeleft = _P.extendvthtypeleft,
        extendvthtyperight = _P.extendvthtyperight,
        extendimplanttop = _P.extendimplanttop,
        extendimplantbottom = _P.extendimplantbottom,
        extendimplantleft = _P.extendimplantleft,
        extendimplantright = _P.extendimplantright,
        extendwelltop = _P.extendwelltop,
        extendwellbottom = _P.extendwellbottom,
        extendwellleft = _P.extendwellleft,
        extendwellright = _P.extendwellright,
        extendlvsmarkertop = _P.extendlvsmarkertop,
        extendlvsmarkerbottom = _P.extendlvsmarkerbottom,
        extendlvsmarkerleft = _P.extendlvsmarkerleft,
        extendlvsmarkerright = _P.extendlvsmarkerright,
        extendrotationmarkertop = _P.extendrotationmarkertop,
        extendrotationmarkerbottom = _P.extendrotationmarkerbottom,
        extendrotationmarkerleft = _P.extendrotationmarkerleft,
        extendrotationmarkerright = _P.extendrotationmarkerright,
        extendanalogmarkertop = _P.extendanalogmarkertop,
        extendanalogmarkerbottom = _P.extendanalogmarkerbottom,
        extendanalogmarkerleft = _P.extendanalogmarkerleft,
        extendanalogmarkerright = _P.extendanalogmarkerright,
    }

    function _create_row(name, numrows, row)
        local isoddrow = row % 2 == 1
        return util.add_options(row_base_options, {
            devices = {
                util.add_options(dummyoptions, {
                    name = string.format("%s_leftdummy", name),
                    fingers = _P.dummygates,
                    drawtopgate = isoddrow,
                    drawbotgate = not isoddrow,
                    drawleftstopgate = _P.drawleftrightstopgates,
                    connectsourceinverse = isoddrow,
                    connectdraininverse = not isoddrow,
                    drawstopgatetopgatecut = isoddrow,
                    drawstopgatebotgatecut = not isoddrow,
                }),
                util.add_options(mainoptions, {
                    name = string.format("%s_output", name),
                    fingers = _P.numgates,
                    drawtopgate = isoddrow,
                    drawbotgate = not isoddrow,
                    connectsourceinverse = isoddrow,
                }),
                util.add_options(dummyoptions, {
                    name = string.format("%s_rightdummy", name),
                    fingers = _P.dummygates,
                    drawtopgate = isoddrow,
                    drawbotgate = not isoddrow,
                    drawrightstopgate = _P.drawleftrightstopgates,
                    connectsourceinverse = isoddrow,
                    connectdraininverse = not isoddrow,
                    drawstopgatetopgatecut = isoddrow,
                    drawstopgatebotgatecut = not isoddrow,
                }),
            },
        })
    end

    local numrows = #_P.rowdef
    local rows = {}
    for i = 1, #_P.rowdef do
        table.insert(rows, _create_row(_P.rowdef[i], numrows, i))
    end

    if _P.add_dummy_rows then
        table.insert(rows, 1, util.add_options(row_base_options, {
            width = _P.dummyfingerwidth,
            connectdraininverse = true,
            connectsourceinverse = false,
            devices = {
                util.add_options(dummyoptions, {
                    name = "bottomdummyrow",
                    fingers = _P.numgates + 2 * _P.dummygates,
                    drawbotgate = true,
                    drawleftstopgate = _P.drawleftrightstopgates,
                    drawrightstopgate = _P.drawleftrightstopgates,
                    drawstopgatebotgatecut = false,
                    topgatemetal = 1,
                    botgatemetal = 1,
                }),
            },
        }))
        table.insert(rows, util.add_options(row_base_options, {
            width = _P.dummyfingerwidth,
            connectsourceboth = not isoddrow,
            connectdraininverse = isoddrow,
            devices = {
                util.add_options(dummyoptions, {
                    name = "topdummyrow",
                    drawtopgate = true,
                    fingers = _P.numgates + 2 * _P.dummygates,
                    drawleftstopgate = _P.drawleftrightstopgates,
                    drawrightstopgate = _P.drawleftrightstopgates,
                    drawstopgatetopgatecut = false,
                    topgatemetal = 1,
                    botgatemetal = 1,
                }),
            },
        }))
    end

    local mosfets = pcell.create_layout("basic/stacked_mosfet_array", "mosfets", {
        separation = separation,
        splitgates = true,
        splitoxidetype = false,
        splitvthtype = false,
        splitwell = false,
        splitimplant = false,
        rows = rows,
    })
    cell:merge_into(mosfets)
end
