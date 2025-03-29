function parameters()
    pcell.add_parameters(
        { "pattern", { { 1, 2, 1 }, { 2, 1, 2 } } },
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
        { "interconnectviapitch", 200 },
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
    local numrows = #_P.pattern
    local numdevicesperrow = #(_P.pattern[1])
    local numdevices = 0
    for _, rowpattern in ipairs(_P.pattern) do
        for _, device in ipairs(rowpattern) do
            if device > numdevices then
                numdevices = device
            end
        end
    end
    local numgatelines = _P.equalgatenets and 1 or numdevices
    local gateline_space_occupation = 2 * _P.gatestrapspace + 2 * _P.gatestrapwidth + (numgatelines + 1) * _P.gatelinespace + numgatelines * _P.gatelinewidth
    local interconnectline_space_occupation = 2 * _P.sourcedrainstrapspace + 2 * _P.sourcedrainstrapwidth + (numdevices + 1) * _P.interconnectlinespace + numdevices * _P.interconnectlinewidth
    local separation = math.max(interconnectline_space_occupation, gateline_space_occupation)
    local gateline_offset = (separation - gateline_space_occupation) / 2
    local interconnectline_offset = separation - interconnectline_space_occupation
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
    
    local namelookup = {}
    local function _get_device_name(devicenum)
        if not namelookup[devicenum] then
            namelookup[devicenum] = 0
        end
        namelookup[devicenum] = namelookup[devicenum] + 1
        return namelookup[devicenum]
    end
    -- generate all sub-devices
    local devicetable = {}
    for rownum, rowpattern in ipairs(_P.pattern) do
        for _, devicenum in ipairs(rowpattern) do
            local index = _get_device_name(devicenum)
            table.insert(devicetable, {
                device = devicenum,
                row = rownum,
                index = index,
            })
        end
    end

    local function _get_devices(cond)
        local result = {}
        for _, device in ipairs(devicetable) do
            if cond(device) then
                table.insert(result, device)
            end
        end
        return result
    end

    local function _make_row_devices(rownum, devicerow)
        local devices = {}
        table.insert(devices,
            util.add_options(dummyoptions, {
                name = string.format("outerleftdummy_%d", rownum),
                fingers = _P.outerdummies,
                drawtopgate = rownum % 2 == 0,
                drawbotgate = rownum % 2 == 1,
                shortlocation = (rownum % 2 == 0) and "top" or "bottom",
                shortdevicerightoffset = 1,
                topgaterightextension = -_P.gatelength,
            })
        )
        for deviceindex, device in ipairs(devicerow) do
            table.insert(devices,
                util.add_options(fetoptions, {
                    name = string.format("M_%d_%d_%d", device.device, device.row, device.index),
                    fingers = _P.fingers,
                    drawtopgate = rownum % 2 == 1,
                    drawbotgate = rownum % 2 == 0,
                    connectsourceinverse = (rownum % 2 == 1) and not flipsourcedrain or flipsourcedrain,
                    connectdraininverse = (rownum % 2 == 1) and not flipsourcedrain or flipsourcedrain,
                })
            )
            if deviceindex < #devicerow then
                table.insert(devices,
                    util.add_options(dummyoptions, {
                        name = string.format("innerdummy_%d_%d", rownum, deviceindex),
                        fingers = _P.innerdummies,
                        drawtopgate = rownum % 2 == 0,
                        drawbotgate = rownum % 2 == 1,
                        shortdevice = false
                    })
                )
            end
        end
        table.insert(devices,
            util.add_options(dummyoptions, {
                name = string.format("outerrightdummy_%d", rownum),
                fingers = _P.outerdummies,
                drawtopgate = rownum % 2 == 0,
                drawbotgate = rownum % 2 == 1,
                shortlocation = (rownum % 2 == 0) and "top" or "bottom",
                shortdevicerightoffset = 1,
                topgaterightextension = -_P.gatelength,
            })
        )
        return devices
    end

    local rows = {}
    for rownum = 1, numrows do
        local row = util.add_options(rowoptions, {})
        local devicerow = _get_devices(function(device) return device.row == rownum end)
        row.devices = _make_row_devices(rownum, devicerow)
        table.insert(rows, row)
    end

    local array = pcell.create_layout("basic/stacked_mosfet_array", "_array", {
        rows = rows,
        separation = separation,
        autoskip = true,
    })
    cell:merge_into(array)
    cell:inherit_all_anchors_with_prefix(array, "")

    -- connect outer and inner dummies
    for rownum = 1, numrows do
        local gate = (rownum % 2 == 0) and "top" or "bot"
        geometry.rectanglebltr(cell, generics.metal(1),
            cell:get_area_anchor_fmt("outerleftdummy_%d_%sgatestrap", rownum, gate).br,
            cell:get_area_anchor_fmt("outerrightdummy_%d_%sgatestrap", rownum, gate).tl
        )
    end

    -- create gate lines
    for rownum = 1, numrows // 2 do
        local leftdevice = string.format("outerleftdummy_%d", 2 * rownum - 1)
        local rightdevice = string.format("outerrightdummy_%d", 2 * rownum - 1)
        for line = 1, numgatelines do
            cell:add_area_anchor_bltr(string.format("gateline_%d_%d", rownum, line),
                point.create(
                    cell:get_area_anchor_fmt("%s_active", leftdevice).l,
                    cell:get_area_anchor_fmt("%s_active", leftdevice).t + gateline_offset + _P.gatestrapspace + _P.gatestrapwidth + _P.gatelinespace + (line - 1) * (_P.gatelinespace + _P.gatelinewidth)
                ),
                point.create(
                    cell:get_area_anchor_fmt("%s_active", rightdevice).r,
                    cell:get_area_anchor_fmt("%s_active", rightdevice).t + gateline_offset + _P.gatestrapspace + _P.gatestrapwidth + _P.gatelinespace + _P.gatelinewidth + (line - 1) * (_P.gatelinespace + _P.gatelinewidth)
                )
            )
            geometry.rectanglebltr(cell, generics.metal(_P.gatemetal),
                cell:get_area_anchor_fmt("gateline_%d_%d", rownum, line).bl,
                cell:get_area_anchor_fmt("gateline_%d_%d", rownum, line).tr
            )
        end
    end

    -- create interconnect lines
    for rownum = 1, numrows // 2 do
        local leftdevice = string.format("outerleftdummy_%d", 2 * rownum - 1)
        local rightdevice = string.format("outerrightdummy_%d", 2 * rownum - 1)
        for line = 1, numdevices do
            cell:add_area_anchor_bltr(string.format("interconnectline_%d_%d", rownum, line),
                point.create(
                    cell:get_area_anchor_fmt("%s_active", leftdevice).l,
                    cell:get_area_anchor_fmt("%s_active", leftdevice).t + interconnectline_offset + _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth + _P.interconnectlinespace + (line - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth)
                ),
                point.create(
                    cell:get_area_anchor_fmt("%s_active", rightdevice).r,
                    cell:get_area_anchor_fmt("%s_active", rightdevice).t + interconnectline_offset + _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth + _P.interconnectlinespace + _P.interconnectlinewidth + (line - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth)
                )
            )
            geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal),
                cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, line).bl,
                cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, line).tr
            )
        end
    end

    -- connect drains to interconnect lines
    for _, device in ipairs(devicetable) do
        local linerow = (device.row - 1) // 2 + 1
        geometry.viabltr(cell, _P.drainmetal, _P.interconnectmetal,
            point.create(
                0.5 * (
                    cell:get_area_anchor_fmt("M_%d_%d_%d_gate%d", device.device, device.row, device.index, 2).l +
                    cell:get_area_anchor_fmt("M_%d_%d_%d_gate%d", device.device, device.row, device.index, 2).r
                ) - _P.interconnectviawidth / 2 + (device.device - 1) * _P.interconnectviapitch,
                cell:get_area_anchor_fmt("interconnectline_%d_%d", linerow, device.device).b
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor_fmt("M_%d_%d_%d_gate%d", device.device, device.row, device.index, 2).l +
                    cell:get_area_anchor_fmt("M_%d_%d_%d_gate%d", device.device, device.row, device.index, 2).r
                ) + _P.interconnectviawidth / 2 + (device.device - 1) * _P.interconnectviapitch,
                cell:get_area_anchor_fmt("interconnectline_%d_%d", linerow, device.device).t
            )
        )
        geometry.rectanglepoints(cell, generics.metal(_P.drainmetal),
            point.create(
                0.5 * (
                    cell:get_area_anchor_fmt("M_%d_%d_%d_gate%d", device.device, device.row, device.index, 2).l +
                    cell:get_area_anchor_fmt("M_%d_%d_%d_gate%d", device.device, device.row, device.index, 2).r
                ) - _P.interconnectlinewidth / 2 + (device.device - 1) * _P.interconnectviapitch,
                cell:get_area_anchor_fmt("interconnectline_%d_%d", linerow, device.device).b
            ),
            point.create(
                0.5 * (
                    cell:get_area_anchor_fmt("M_%d_%d_%d_gate%d", device.device, device.row, device.index, 2).l +
                    cell:get_area_anchor_fmt("M_%d_%d_%d_gate%d", device.device, device.row, device.index, 2).r
                ) + _P.interconnectlinewidth / 2 + (device.device - 1) * _P.interconnectviapitch,
                cell:get_area_anchor_fmt("M_%d_%d_%d_drainstrap", device.device, device.row, device.index).t
            )
        )
    end

    -- create output lines
    --[[
    local outputline_ytop
    if _P.outputlinetopalign == "top" then
        local toprowdev = _get_devices(function(device) return device.row == numrows end)[1]
        outputline_ytop = cell:get_area_anchor_fmt("M_%d_%d_%d_active", toprowdev.device, toprowdev.row, toprowdev.index).t
    else -- _P.outputlinetopalign == "center"
        outputline_ytop = cell:get_area_anchor("M2l_active").b
    end
    local outputline_ybot
    if _P.outputlinebotalign == "bottom" then
        outputline_ybot = cell:get_area_anchor("M1l_active").b
    else -- _P.outputlinebotalign == "center"
        outputline_ybot = cell:get_area_anchor("M1l_active").t
    end
    --]]
    local botrowdevices = _get_devices(function(device) return device.row == 1 end)
    local toprowdevices = _get_devices(function(device) return device.row == numrows end)
    for line = 1, numdevicesperrow - 1 do
        local leftfet = botrowdevices[line]
        local rightfet = toprowdevices[line + 1]
        for i = 1, numdevices do
            cell:add_area_anchor_bltr(string.format("outputline_%d_%d", line, i),
                point.create(
                    0.5 * (
                        cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveright", leftfet.device, leftfet.row, leftfet.index).r +
                        cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveleft", rightfet.device, rightfet.row, rightfet.index).l
                    ) + (-numdevices + 1 + 2 * (i - 1)) * (_P.outputlinewidth + _P.outputlinespace) / 2 - _P.outputlinewidth / 2,
                    cell:get_area_anchor_fmt("M_%d_%d_%d_active", leftfet.device, leftfet.row, leftfet.index).b
                ),
                point.create(
                    0.5 * (
                        cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveright", leftfet.device, leftfet.row, leftfet.index).r +
                        cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveleft", rightfet.device, rightfet.row, rightfet.index).l
                    ) + (-numdevices + 1 + 2 * (i - 1)) * (_P.outputlinewidth + _P.outputlinespace) / 2 + _P.outputlinewidth / 2,
                    cell:get_area_anchor_fmt("M_%d_%d_%d_active", rightfet.device, rightfet.row, rightfet.index).t
                )
            )
            geometry.rectanglebltr(cell, generics.metal(_P.outputmetal),
                cell:get_area_anchor_fmt("outputline_%d_%d", line, i).bl,
                cell:get_area_anchor_fmt("outputline_%d_%d", line, i).tr
            )
        end
    end

    -- connect interconnect lines to output lines
    if _P.interoutputvias == "topdown" then
        for rownum = 1, numrows // 2 do
            for colnum = 1, numdevicesperrow - 1 do
                for device = 1, numdevices do
                    geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_%d", colnum, device).l,
                            cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, device).b
                        ),
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_%d", colnum, device).r,
                            cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, device).t
                        )
                    )
                end
            end
        end
    else -- _P.interoutputvias == "leftright
        --geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
        --    point.create(
        --        cell:get_area_anchor("outputline1").l - _P.outputviawidth,
        --        cell:get_area_anchor("interconnectline1").b
        --    ),
        --    point.create(
        --        cell:get_area_anchor("outputline1").l,
        --        cell:get_area_anchor("interconnectline1").t
        --    )
        --)
        --geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
        --    point.create(
        --        cell:get_area_anchor("outputline2").r,
        --        cell:get_area_anchor("interconnectline2").b
        --    ),
        --    point.create(
        --        cell:get_area_anchor("outputline2").r + _P.outputviawidth,
        --        cell:get_area_anchor("interconnectline2").t
        --    )
        --)
    end

    -- connect all sources (horizontal)
    for rownum = 1, numrows do
        local fets = _get_devices(function(entry) return entry.row == rownum end)
        local leftfet = fets[1]
        local rightfet = fets[numdevicesperrow]
        geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcestrap", leftfet.device, leftfet.row, leftfet.index).br,
            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcestrap", rightfet.device, rightfet.row, rightfet.index).tl
        )
        geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
            cell:get_area_anchor_fmt("M_%d_%d_%d_othersourcestrap", leftfet.device, leftfet.row, leftfet.index).br,
            cell:get_area_anchor_fmt("M_%d_%d_%d_othersourcestrap", rightfet.device, rightfet.row, rightfet.index).tl
        )
    end

    -- connect all sources (vertical)
    for i = 1, numdevicesperrow do
        local lowerfet = botrowdevices[i]
        local upperfet = toprowdevices[i]
        for finger = 2, _P.fingers, 2 do
            geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
                point.create(
                    cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactive%d", lowerfet.device, lowerfet.row, lowerfet.index, finger).l,
                    cell:get_area_anchor_fmt("M_%d_%d_%d_sourcestrap", lowerfet.device, lowerfet.row, lowerfet.index).b
                ),
                point.create(
                    cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactive%d", upperfet.device, upperfet.row, upperfet.index, finger).r,
                    cell:get_area_anchor_fmt("M_%d_%d_%d_sourcestrap", upperfet.device, upperfet.row, upperfet.index).t
                )
            )
        end
    end
end
