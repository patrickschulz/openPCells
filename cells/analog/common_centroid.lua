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
        { "gatestrapleftext", 0 },
        { "gatestraprightext", 0 },
        { "gatelinewidth", 100 },
        { "gatelinespace", 100 },
        { "gatelineviawidth", 100 },
        { "gatelineviapitch", 200 },
        { "gateviawidth", 100 },
        { "interconnectlinewidth", 100 },
        { "interconnectlinespace", 100 },
        { "interconnectviawidth", 100 },
        { "interconnectviapitch", 200 },
        { "outputlinewidth", 100 },
        { "outputlinespace", 100 },
        { "outputviawidth", 200 },
        { "outputlinetopextend", 0 },
        { "outputlinebotextend", 0 },
        { "outputlinesonlyincenter", false },
        { "outputlinesovereverydevice", false },
        { "outputlinesonelineperdevice", false },
        { "gateconnwidth", 70 },
        { "sourcedrainstrapwidth", 100 },
        { "sourcedrainstrapspace", 100 },
        { "equalgatenets", false },
        { "shortgates", false, follow = "equalgatenets" },
        { "gatestrapsincenter", false, follow = "equalgatenets" },
        { "connectgatesonbothsides", false },
        { "diodeconnected", {} },
        { "innerdummies", 2 },
        { "outerdummies", 2 },
        { "outerdummygatelength", 500, follow = "gatelength" }, -- FIXME: basic/stacked_mosfet_array does not support this
        { "connectdummygatestoactive", false },
        { "connectdummies", true },
        { "connectdummysources", true },
        { "interoutputvias", "topdown", posvals = set("topdown", "leftright") },
        { "extendalltop", 0 },
        { "extendallbottom", 0 },
        { "extendallleft", 0 },
        { "extendallright", 0 }
    )
end

function check(_P)
    for i = 2, #_P.pattern do
        if #_P.pattern[i] ~= #_P.pattern[1] then
            return false, string.format("row pattern lengths are not equal (row %d has %d entries, the other rows have %d entries)", i, #_P.pattern[i], #_P.pattern[1])
        end
    end
    local numdevices = 0
    for _, rowpattern in ipairs(_P.pattern) do
        for _, device in ipairs(rowpattern) do
            if device > numdevices then
                numdevices = device
            end
        end
    end
    if numdevices < 2 then
        return false, "the pattern definition does not contain more than one device"
    end
    if _P.connectdummygatestoactive and not _P.equalgatenets then
        return false, "if gate straps are in the center, all gates have to be on the same net (equalnets == true)"
    end
    if _P.connectdummygatestoactive and not _P.equalgatenets then
        return false, "if dummy gates are connected to active gates, all gates have to be on the same net (equalnets == true)"
    end
    if not _P.connectdummygatestoactive and _P.connectgatesonbothsides then
        return false, "if gates are connected on both sides, dummy gates must be connected to the active gates"
    end
    return true
end

function layout(cell, _P)
    local flipsourcedrain = _P.channeltype == "nmos"
    local gatepitch = _P.gatelength + _P.gatespace
    local numrows = #_P.pattern
    local numinstancesperrow = #(_P.pattern[1]) -- total number of *instances* in a row (e.g. ABBAABBA -> 8)
    local numdevicesperrow = {} -- total number of devices in a row (e.g. ABBBBA   -> 2
                               --                                         CAABBC   -> 3
                               --                                         CAABBC   -> 3
                               --                                         ABBBBA   -> 2)
    local numdevices = 0 -- total number of devices (e.g. ABBA -> 2)
    for i, rowpattern in ipairs(_P.pattern) do
        local rowdevices = {}
        for _, device in ipairs(rowpattern) do
            rowdevices[device] = true
            if device > numdevices then
                numdevices = device
            end
        end
        local count = 0
        for i in pairs(rowdevices) do
            count = count + 1
        end
        numdevicesperrow[i] = count
    end
    local maxnumdevicesperdoublerow = 0
    for rownum = 1, #numdevicesperrow - 1, 2 do
        maxnumdevicesperdoublerow = math.max(maxnumdevicesperdoublerow, #util.uniq(util.merge_tables(_P.pattern[rownum], _P.pattern[rownum + 1])))
    end
    local maxnumgatelines = _P.equalgatenets and 1 or maxnumdevicesperdoublerow
    local gateline_space_occupation = 2 * _P.gatestrapspace + 2 * _P.gatestrapwidth + (maxnumgatelines + 1) * _P.gatelinespace + maxnumgatelines * _P.gatelinewidth
    local interconnectline_space_occupation = 2 * _P.sourcedrainstrapspace + 2 * _P.sourcedrainstrapwidth + (maxnumdevicesperdoublerow + 1) * _P.interconnectlinespace + maxnumdevicesperdoublerow * _P.interconnectlinewidth
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
        gtopext = _P.gatestrapsincenter and (separation + _P.gatestrapwidth) / 2 or _P.gatestrapspace + _P.gatestrapwidth,
        gbotext = _P.gatestrapsincenter and (separation + _P.gatestrapwidth) / 2 or _P.gatestrapspace + _P.gatestrapwidth,
        topgateleftextension = _P.gatestrapleftext,
        botgateleftextension = _P.gatestrapleftext,
        topgaterightextension = _P.gatestraprightext,
        botgaterightextension = _P.gatestraprightext,
        extendalltop = _P.extendalltop,
        extendallbottom = _P.extendallbottom,
        extendallleft = _P.extendallleft,
        extendallright = _P.extendallright,
    }

    local fetoptions = {
        fingers = _P.fingers,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapsincenter and (separation - _P.gatestrapwidth) / 2 or _P.gatestrapspace,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.gatestrapsincenter and (separation - _P.gatestrapwidth) / 2 or _P.gatestrapspace,
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
        shortwidth = _P.gatestrapwidth,
        shortspace = _P.gatestrapsincenter and (separation - _P.gatestrapwidth) / 2 or _P.gatestrapspace,
        connectsource = _P.connectdummysources,
        connectsourceboth = _P.connectdummysources,
        connectsourcewidth = _P.sourcedrainstrapwidth,
        connectsourcespace = _P.sourcedrainstrapspace,
        sourcemetal = _P.sourcemetal,
        connectdrain = _P.connectdummysources,
        connectdrainboth = _P.connectdummysources,
        connectdrainwidth = _P.sourcedrainstrapwidth,
        connectdrainspace = _P.sourcedrainstrapspace,
        drainmetal = _P.sourcemetal,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapsincenter and (separation - _P.gatestrapwidth) / 2 or _P.gatestrapspace,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.gatestrapsincenter and (separation - _P.gatestrapwidth) / 2 or _P.gatestrapspace,
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
        for column, devicenum in ipairs(rowpattern) do
            local index = _get_device_name(devicenum)
            table.insert(devicetable, {
                device = devicenum,
                row = rownum,
                column = column,
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
                gatelength = _P.outerdummygatelength,
                drawtopgate = _P.connectgatesonbothsides or (rownum % 2 == 0),
                drawbotgate = _P.connectgatesonbothsides or (rownum % 2 == 1),
                shortdevice = not _P.connectdummysources and (_P.outerdummies > 1),
                shortsourcegate = _P.outerdummies == 1,
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
                    drawtopgate = _P.connectgatesonbothsides or (rownum % 2 == 1),
                    drawbotgate = _P.connectgatesonbothsides or (rownum % 2 == 0),
                    connectdraininverse = ((_P.channeltype == "pmos") and (rownum % 2 == 1)) or ((_P.channeltype == "nmos") and (rownum % 2 == 0)),
                    diodeconnected = _P.diodeconnected[device.device],
                    connectdrainleftext = (_P.fingers == 2) and (_P.interconnectviapitch + _P.interconnectlinewidth - _P.sdwidth) / 2 or 0,
                    connectdrainrightext = (_P.fingers == 2) and (_P.interconnectviapitch + _P.interconnectlinewidth - _P.sdwidth) / 2 or 0,
                })
            )
            if deviceindex < #devicerow then
                table.insert(devices,
                    util.add_options(dummyoptions, {
                        name = string.format("innerdummy_%d_%d", rownum, deviceindex),
                        fingers = _P.innerdummies,
                        drawtopgate = _P.connectgatesonbothsides or (rownum % 2 == 0),
                        drawbotgate = _P.connectgatesonbothsides or (rownum % 2 == 1),
                        shortdevice = _P.innerdummies > 2,
                        shortlocation = (rownum % 2 == 0) and "top" or "bottom",
                        shortdeviceleftoffset = 1,
                        shortdevicerightoffset = 1,
                    })
                )
            end
        end
        table.insert(devices,
            util.add_options(dummyoptions, {
                name = string.format("outerrightdummy_%d", rownum),
                fingers = _P.outerdummies,
                gatelength = _P.outerdummygatelength,
                drawtopgate = _P.connectgatesonbothsides or (rownum % 2 == 0),
                drawbotgate = _P.connectgatesonbothsides or (rownum % 2 == 1),
                shortdevice = not _P.connectdummysources and (_P.outerdummies > 1),
                shortdraingate = _P.outerdummies == 1,
                shortlocation = (rownum % 2 == 0) and "top" or "bottom",
                shortdeviceleftoffset = 1,
                topgateleftextension = -_P.gatelength,
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
        splitgates = not _P.shortgates
    })
    cell:merge_into(array)
    cell:inherit_all_anchors_with_prefix(array, "")

    -- connect outer and inner dummies
    if not _P.connectdummygatestoactive then
        if _P.outerdummies > 0 then
            for rownum = 1, numrows do
                local gate = (rownum % 2 == 0) and "top" or "bot"
                geometry.rectanglebltr(cell, generics.metal(1),
                    cell:get_area_anchor_fmt("outerleftdummy_%d_%sgatestrap", rownum, gate).br,
                    cell:get_area_anchor_fmt("outerrightdummy_%d_%sgatestrap", rownum, gate).tl
                )
            end
        elseif _P.innerdummies > 0 then
            for rownum = 1, numrows do
                local gate = (rownum % 2 == 0) and "top" or "bot"
                geometry.rectanglebltr(cell, generics.metal(1),
                    cell:get_area_anchor_fmt("innerdummy_%d_%d_%sgatestrap", rownum, 1, gate).br,
                    cell:get_area_anchor_fmt("innerdummy_%d_%d_%sgatestrap", rownum, numinstancesperrow - 1, gate).tl
                )
            end
        end
    end

    local function _get_uniq_row_devices(rownum)
        local doublerowdevices = _get_devices(function(device) return device.row == 2 * rownum - 1 or device.row == 2 * rownum end)
        local indices = util.uniq(util.foreach(doublerowdevices, function(entry) return entry.device end))
        table.sort(indices)
        return indices
    end

    -- create gate lines
    if _P.connectdummygatestoactive then -- all gates are on the same net
        if _P.outerdummies > 0 then
            for rownum = 1, numrows do
                local gate  = (rownum % 2 == 0) and "top" or "bot"
                local igate = (rownum % 2 == 0) and "bot" or "top"
                cell:add_area_anchor_bltr(string.format("gateline_%d", rownum),
                    point.create(
                        cell:get_area_anchor_fmt("outerleftdummy_%d_%sgatestrap", rownum, gate).l,
                        0.5 * (
                            cell:get_area_anchor_fmt("outerleftdummy_%d_%sgatestrap", rownum, gate).b +
                            cell:get_area_anchor_fmt("outerleftdummy_%d_%sgatestrap", rownum, gate).t
                        ) - _P.gatelinewidth / 2
                    ),
                    point.create(
                        cell:get_area_anchor_fmt("outerrightdummy_%d_%sgatestrap", rownum, gate).r,
                        0.5 * (
                            cell:get_area_anchor_fmt("outerrightdummy_%d_%sgatestrap", rownum, gate).b +
                            cell:get_area_anchor_fmt("outerrightdummy_%d_%sgatestrap", rownum, gate).t
                        ) + _P.gatelinewidth / 2
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.gatemetal),
                    cell:get_area_anchor_fmt("gateline_%d", rownum).bl,
                    cell:get_area_anchor_fmt("gateline_%d", rownum).tr
                )
                cell:add_area_anchor_bltr(string.format("gatelineupper_%d", rownum), -- FIXME: use this gate line
                    point.create(
                        cell:get_area_anchor_fmt("outerleftdummy_%d_%sgatestrap", rownum, igate).l,
                        0.5 * (
                            cell:get_area_anchor_fmt("outerleftdummy_%d_%sgatestrap", rownum, igate).b +
                            cell:get_area_anchor_fmt("outerleftdummy_%d_%sgatestrap", rownum, igate).t
                        ) - _P.gatelinewidth / 2
                    ),
                    point.create(
                        cell:get_area_anchor_fmt("outerrightdummy_%d_%sgatestrap", rownum, igate).r,
                        0.5 * (
                            cell:get_area_anchor_fmt("outerrightdummy_%d_%sgatestrap", rownum, igate).b +
                            cell:get_area_anchor_fmt("outerrightdummy_%d_%sgatestrap", rownum, igate).t
                        ) + _P.gatelinewidth / 2
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.gatemetal),
                    cell:get_area_anchor_fmt("gatelineupper_%d", rownum).bl,
                    cell:get_area_anchor_fmt("gatelineupper_%d", rownum).tr
                )
            end
        end
    else
        for rownum = 1, math.floor((numrows + 1) / 2) do
            local doublerowdevices = _get_devices(function(device) return device.row == 2 * rownum - 1 or device.row == 2 * rownum end)
            local leftdevice = doublerowdevices[1]
            local rightdevice = doublerowdevices[numinstancesperrow]
            if _P.equalgatenets then
                cell:add_area_anchor_bltr(string.format("gateline_%d", rownum),
                    point.create(
                        cell:get_area_anchor_fmt("M_%d_%d_%d_active", leftdevice.device, leftdevice.row, leftdevice.index).l,
                        cell:get_area_anchor_fmt("M_%d_%d_%d_active", leftdevice.device, leftdevice.row, leftdevice.index).t + gateline_offset + _P.gatestrapspace + _P.gatestrapwidth + _P.gatelinespace
                    ),
                    point.create(
                        cell:get_area_anchor_fmt("M_%d_%d_%d_active", rightdevice.device, rightdevice.row, rightdevice.index).r,
                        cell:get_area_anchor_fmt("M_%d_%d_%d_active", rightdevice.device, rightdevice.row, rightdevice.index).t + gateline_offset + _P.gatestrapspace + _P.gatestrapwidth + _P.gatelinespace + _P.gatelinewidth
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.gatemetal),
                    cell:get_area_anchor_fmt("gateline_%d", rownum).bl,
                    cell:get_area_anchor_fmt("gateline_%d", rownum).tr
                )
            else
                local devindices = _get_uniq_row_devices(rownum)
                for line, index in ipairs(devindices) do
                    cell:add_area_anchor_bltr(string.format("gateline_%d_%d", rownum, index),
                        point.create(
                            cell:get_area_anchor_fmt("M_%d_%d_%d_active", leftdevice.device, leftdevice.row, leftdevice.index).l,
                            cell:get_area_anchor_fmt("M_%d_%d_%d_active", leftdevice.device, leftdevice.row, leftdevice.index).t + gateline_offset + _P.gatestrapspace + _P.gatestrapwidth + _P.gatelinespace + (line - 1) * (_P.gatelinespace + _P.gatelinewidth)
                        ),
                        point.create(
                            cell:get_area_anchor_fmt("M_%d_%d_%d_active", rightdevice.device, rightdevice.row, rightdevice.index).r,
                            cell:get_area_anchor_fmt("M_%d_%d_%d_active", rightdevice.device, rightdevice.row, rightdevice.index).t + gateline_offset + _P.gatestrapspace + _P.gatestrapwidth + _P.gatelinespace + _P.gatelinewidth + (line - 1) * (_P.gatelinespace + _P.gatelinewidth)
                        )
                    )
                    geometry.rectanglebltr(cell, generics.metal(_P.gatemetal),
                        cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).bl,
                        cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).tr
                    )
                end
            end
        end
    end

    -- connect gates to gate lines
    -- FIXME: this is partly broken due to the way gate line anchors are created when dummy gates are connected to active gates on both sides
    if not _P.gatestrapsincenter then
        for rownum = 1, math.floor((numrows + 1) / 2) do
            if _P.equalgatenets then
                for colnum = 1, numinstancesperrow do
                    local doublerowdevices = _get_devices(function(device) return (device.row == 2 * rownum - 1 or device.row == 2 * rownum) and (device.column == colnum) end)
                    for i, device in ipairs(doublerowdevices) do
                        local gate = (i % 2 == 1) and "top" or "bot"
                        geometry.viabltr(cell, 1, _P.gatemetal,
                            point.create(
                                0.5 * (
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).l +
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).r
                                ) - _P.gatelineviawidth / 2,
                                cell:get_area_anchor_fmt("gateline_%d", rownum).b
                            ),
                            point.create(
                                0.5 * (
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).l +
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).r
                                ) + _P.gatelineviawidth / 2,
                                cell:get_area_anchor_fmt("gateline_%d", rownum).t
                            )
                        )
                        geometry.rectanglepoints(cell, generics.metal(1),
                            point.create(
                                0.5 * (
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).l +
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).r
                                ) - _P.gatelinewidth / 2,
                                cell:get_area_anchor_fmt("gateline_%d", rownum).b
                            ),
                            point.create(
                                0.5 * (
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).l +
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).r
                                ) + _P.gatelinewidth / 2,
                                cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).t
                            )
                        )
                    end
                end
            else
                for colnum = 1, numinstancesperrow do
                    local doublerowdevices = _get_devices(function(device) return (device.row == 2 * rownum - 1 or device.row == 2 * rownum) and (device.column == colnum) end)
                    local spread = doublerowdevices[1].device ~= doublerowdevices[2].device
                    for i, device in ipairs(doublerowdevices) do
                        local gate = (i % 2 == 1) and "top" or "bot"
                        local shift = spread and (i - 1.5) * _P.gatelineviapitch or 0
                        geometry.viabltr(cell, 1, _P.gatemetal,
                            point.create(
                                0.5 * (
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).l +
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).r
                                ) - _P.gatelineviawidth / 2 + shift,
                                cell:get_area_anchor_fmt("gateline_%d_%d", rownum, device.device).b
                            ),
                            point.create(
                                0.5 * (
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).l +
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).r
                                ) + _P.gatelineviawidth / 2 + shift,
                                cell:get_area_anchor_fmt("gateline_%d_%d", rownum, device.device).t
                            )
                        )
                        geometry.rectanglepoints(cell, generics.metal(1),
                            point.create(
                                0.5 * (
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).l +
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).r
                                ) - _P.gatelinewidth / 2 + shift,
                                cell:get_area_anchor_fmt("gateline_%d_%d", rownum, device.device).b
                            ),
                            point.create(
                                0.5 * (
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).l +
                                    cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).r
                                ) + _P.gatelinewidth / 2 + shift,
                                cell:get_area_anchor_fmt("M_%d_%d_%d_%sgatestrap", device.device, device.row, device.index, gate).t
                            )
                        )
                    end
                end
            end
        end
    end

    -- create interconnect lines
    for rownum = 1, math.floor((numrows + 1) / 2) do
        local devindices = _get_uniq_row_devices(rownum)
        local doublerowdevices = _get_devices(function(device) return device.row == 2 * rownum - 1 or device.row == 2 * rownum end)
        local leftdevice = doublerowdevices[1]
        local rightdevice = doublerowdevices[numinstancesperrow]
        for line, index in ipairs(devindices) do
            cell:add_area_anchor_bltr(string.format("interconnectline_%d_%d", rownum, index),
                point.create(
                    cell:get_area_anchor_fmt("M_%d_%d_%d_active", leftdevice.device, leftdevice.row, leftdevice.index).l,
                    cell:get_area_anchor_fmt("M_%d_%d_%d_active", leftdevice.device, leftdevice.row, leftdevice.index).t + interconnectline_offset + _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth + _P.interconnectlinespace + (line - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth)
                ),
                point.create(
                    cell:get_area_anchor_fmt("M_%d_%d_%d_active", rightdevice.device, rightdevice.row, rightdevice.index).r,
                    cell:get_area_anchor_fmt("M_%d_%d_%d_active", rightdevice.device, rightdevice.row, rightdevice.index).t + interconnectline_offset + _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth + _P.interconnectlinespace + _P.interconnectlinewidth + (line - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth)
                )
            )
            geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal),
                cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, index).bl,
                cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, index).tr
            )
        end
    end

    -- connect drains to interconnect lines
    for rownum = 1, math.floor((numrows + 1) / 2) do
        for colnum = 1, numinstancesperrow do
            local doublerowdevices = _get_devices(function(device) return (device.row == 2 * rownum - 1 or device.row == 2 * rownum) and (device.column == colnum) end)
            local spread
            if not doublerowdevices[2] then -- only when odd number of rows
                spread = 0
            else
                spread = doublerowdevices[1].device ~= doublerowdevices[2].device
            end
            for i, device in ipairs(doublerowdevices) do
                local shift = spread and (i - 1.5) * _P.interconnectviapitch or 0
                geometry.viabltr(cell, _P.drainmetal, _P.interconnectmetal,
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_drainstrap", device.device, device.row, device.index).l +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_drainstrap", device.device, device.row, device.index).r
                        ) - _P.interconnectviawidth / 2 + shift,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, device.device).b
                    ),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_drainstrap", device.device, device.row, device.index).l +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_drainstrap", device.device, device.row, device.index).r
                        ) + _P.interconnectviawidth / 2 + shift,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, device.device).t
                    )
                )
                geometry.rectanglepoints(cell, generics.metal(_P.drainmetal),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_drainstrap", device.device, device.row, device.index).l +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_drainstrap", device.device, device.row, device.index).r
                        ) - _P.interconnectlinewidth / 2 + shift,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, device.device).b
                    ),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_drainstrap", device.device, device.row, device.index).l +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_drainstrap", device.device, device.row, device.index).r
                        ) + _P.interconnectlinewidth / 2 + shift,
                        cell:get_area_anchor_fmt("M_%d_%d_%d_drainstrap", device.device, device.row, device.index).t
                    )
                )
            end
        end
    end

    -- create output lines
    local botrowdevices = _get_devices(function(device) return device.row == 1 end)
    local toprowdevices = _get_devices(function(device) return device.row == numrows end)
    local botrowdevindices = _get_uniq_row_devices(1)
    local toprowdevindices = _get_uniq_row_devices(math.floor((numrows + 1) / 2))
    local botrowminindex = util.min(botrowdevindices)
    local toprowmaxindex = util.max(toprowdevindices)
    if _P.outputlinesonlyincenter then
        for line = 1, 1 do
            local devicelineindex
            if numinstancesperrow % 2 == 1 then
                devicelineindex = (numinstancesperrow + 1) / 2
            else
                devicelineindex = numinstancesperrow / 2
            end
            local leftfet = botrowdevices[devicelineindex]
            local rightfet = toprowdevices[devicelineindex]
            for i = 1, numdevices do
                cell:add_area_anchor_bltr(string.format("outputline_%d_%d", line, i),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveright", leftfet.device, leftfet.row, leftfet.index).r +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveleft", rightfet.device, rightfet.row, rightfet.index).l
                        ) + (-numdevices + 1 + 2 * (i - 1)) * (_P.outputlinewidth + _P.outputlinespace) / 2 - _P.outputlinewidth / 2,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", 1, botrowminindex).b - _P.outputlinebotextend
                    ),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveright", leftfet.device, leftfet.row, leftfet.index).r +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveleft", rightfet.device, rightfet.row, rightfet.index).l
                        ) + (-numdevices + 1 + 2 * (i - 1)) * (_P.outputlinewidth + _P.outputlinespace) / 2 + _P.outputlinewidth / 2,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", math.floor((numrows + 1) / 2), toprowmaxindex).t + _P.outputlinetopextend
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.outputmetal),
                    cell:get_area_anchor_fmt("outputline_%d_%d", line, i).bl,
                    cell:get_area_anchor_fmt("outputline_%d_%d", line, i).tr
                )
            end
        end
    elseif _P.outputlinesonelineperdevice then
        for line = 1, numinstancesperrow do
            local devicelineindex = line
            local fet = botrowdevices[devicelineindex]
            local numoutputlines = 1
            for i = 1, numoutputlines do
                dprint(string.format("outputline_%d_%d", line, i))
                cell:add_area_anchor_bltr(string.format("outputline_%d_%d", line, i),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveright", fet.device, fet.row, fet.index).r +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveleft", fet.device, fet.row, fet.index).l
                        ) + (-numoutputlines + 1 + 2 * (i - 1)) * (_P.outputlinewidth + _P.outputlinespace) / 2 - _P.outputlinewidth / 2,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", 1, botrowminindex).b - _P.outputlinebotextend
                    ),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveright", fet.device, fet.row, fet.index).r +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveleft", fet.device, fet.row, fet.index).l
                        ) + (-numoutputlines + 1 + 2 * (i - 1)) * (_P.outputlinewidth + _P.outputlinespace) / 2 + _P.outputlinewidth / 2,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", math.floor((numrows + 1) / 2), toprowmaxindex).t + _P.outputlinetopextend
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.outputmetal),
                    cell:get_area_anchor_fmt("outputline_%d_%d", line, i).bl,
                    cell:get_area_anchor_fmt("outputline_%d_%d", line, i).tr
                )
            end
        end
    elseif _P.outputlinesovereverydevice then
        for line = 1, numinstancesperrow do
            local devicelineindex = line
            local fet = botrowdevices[devicelineindex]
            for i = 1, numdevices do
                cell:add_area_anchor_bltr(string.format("outputline_%d_%d", line, i),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveright", fet.device, fet.row, fet.index).r +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveleft", fet.device, fet.row, fet.index).l
                        ) + (-numdevices + 1 + 2 * (i - 1)) * (_P.outputlinewidth + _P.outputlinespace) / 2 - _P.outputlinewidth / 2,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", 1, botrowminindex).b - _P.outputlinebotextend
                    ),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveright", fet.device, fet.row, fet.index).r +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveleft", fet.device, fet.row, fet.index).l
                        ) + (-numdevices + 1 + 2 * (i - 1)) * (_P.outputlinewidth + _P.outputlinespace) / 2 + _P.outputlinewidth / 2,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", math.floor((numrows + 1) / 2), toprowmaxindex).t + _P.outputlinetopextend
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.outputmetal),
                    cell:get_area_anchor_fmt("outputline_%d_%d", line, i).bl,
                    cell:get_area_anchor_fmt("outputline_%d_%d", line, i).tr
                )
            end
        end
    else
        for line = 1, numinstancesperrow - 1 do
            local devicelineindex = line
            local leftfet = botrowdevices[devicelineindex]
            local rightfet = toprowdevices[devicelineindex + 1]
            for i = 1, numdevices do
                cell:add_area_anchor_bltr(string.format("outputline_%d_%d", line, i),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveright", leftfet.device, leftfet.row, leftfet.index).r +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveleft", rightfet.device, rightfet.row, rightfet.index).l
                        ) + (-numdevices + 1 + 2 * (i - 1)) * (_P.outputlinewidth + _P.outputlinespace) / 2 - _P.outputlinewidth / 2,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", 1, botrowminindex).b - _P.outputlinebotextend
                    ),
                    point.create(
                        0.5 * (
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveright", leftfet.device, leftfet.row, leftfet.index).r +
                            cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactiveleft", rightfet.device, rightfet.row, rightfet.index).l
                        ) + (-numdevices + 1 + 2 * (i - 1)) * (_P.outputlinewidth + _P.outputlinespace) / 2 + _P.outputlinewidth / 2,
                        cell:get_area_anchor_fmt("interconnectline_%d_%d", math.floor((numrows + 1) / 2), toprowmaxindex).t + _P.outputlinetopextend
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.outputmetal),
                    cell:get_area_anchor_fmt("outputline_%d_%d", line, i).bl,
                    cell:get_area_anchor_fmt("outputline_%d_%d", line, i).tr
                )
            end
        end
    end

    -- connect interconnect lines to output lines
    if numdevices > 2 then
        if _P.outputlinesonelineperdevice then
            for rownum = 1, math.floor((numrows + 1) / 2) do
                local devindices = _get_uniq_row_devices(rownum)
                for _, device in ipairs(devindices) do
                    geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_%d", device, 1).l - _P.outputviawidth / 2,
                            cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, device).b
                        ),
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_%d", device, 1).r + _P.outputviawidth / 2,
                            cell:get_area_anchor_fmt("interconnectline_%d_%d", rownum, device).t
                        )
                    )
                end
            end
        else
            for rownum = 1, math.floor((numrows + 1) / 2) do
                for colnum = 1, numinstancesperrow - 1 do
                    local devindices = _get_uniq_row_devices(rownum)
                    for _, device in ipairs(devindices) do
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
        end
    else -- optimized vias for two devices
        for rownum = 1, math.floor((numrows + 1) / 2) do
            for colnum = 1, numinstancesperrow - 1 do
                if _P.interoutputvias == "topdown" then
                    geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_1", colnum).l,
                            cell:get_area_anchor_fmt("interconnectline_%d_1", rownum).b - _P.outputviawidth
                        ),
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_1", colnum).r,
                            cell:get_area_anchor_fmt("interconnectline_%d_1", rownum).b
                        )
                    )
                    geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_2", colnum).l,
                            cell:get_area_anchor_fmt("interconnectline_%d_2", rownum).t
                        ),
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_2", colnum).r,
                            cell:get_area_anchor_fmt("interconnectline_%d_2", rownum).t + _P.outputviawidth
                        )
                    )
                else -- _P.interoutputvias == "leftright
                    geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_1", colnum).l - _P.outputviawidth,
                            cell:get_area_anchor_fmt("interconnectline_%d_1", rownum).b
                        ),
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_1", colnum).l,
                            cell:get_area_anchor_fmt("interconnectline_%d_1", rownum).t
                        )
                    )
                    geometry.viabltr(cell, _P.interconnectmetal, _P.outputmetal,
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_2", colnum).r,
                            cell:get_area_anchor_fmt("interconnectline_%d_2", rownum).b
                        ),
                        point.create(
                            cell:get_area_anchor_fmt("outputline_%d_2", colnum).r + _P.outputviawidth,
                            cell:get_area_anchor_fmt("interconnectline_%d_2", rownum).t
                        )
                    )
                end
            end
        end
    end

    -- connect all sources (horizontal)
    if _P.innerdummies > 0 then -- source straps touch if no dummies are present
        for rownum = 1, numrows do
            local fets = _get_devices(function(entry) return entry.row == rownum end)
            local leftfet = fets[1]
            local rightfet = fets[numinstancesperrow]
            geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
                cell:get_area_anchor_fmt("M_%d_%d_%d_sourcestrap", leftfet.device, leftfet.row, leftfet.index).bl,
                cell:get_area_anchor_fmt("M_%d_%d_%d_sourcestrap", rightfet.device, rightfet.row, rightfet.index).tl
            )
            geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
                cell:get_area_anchor_fmt("M_%d_%d_%d_othersourcestrap", leftfet.device, leftfet.row, leftfet.index).br,
                cell:get_area_anchor_fmt("M_%d_%d_%d_othersourcestrap", rightfet.device, rightfet.row, rightfet.index).tl
            )
        end
    end

    -- connect all sources (vertical)
    for i = 1, numinstancesperrow do
        local lowerfet = botrowdevices[i]
        local upperfet = toprowdevices[i]
        for finger = 2, _P.fingers, 2 do
            geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
                point.create(
                    cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactive%d", lowerfet.device, lowerfet.row, lowerfet.index, finger).l,
                    cell:get_area_anchor_fmt("M_%d_%d_%d_lowersourcestrap", lowerfet.device, lowerfet.row, lowerfet.index).b
                ),
                point.create(
                    cell:get_area_anchor_fmt("M_%d_%d_%d_sourcedrainactive%d", upperfet.device, upperfet.row, upperfet.index, finger).r,
                    cell:get_area_anchor_fmt("M_%d_%d_%d_uppersourcestrap", upperfet.device, upperfet.row, upperfet.index).t
                )
            )
        end
    end

    -- connect all dummies (vertical)
    if not _P.connectdummysources then
        if _P.outerdummies > 0 then
            geometry.rectanglebltr(cell, generics.metal(1),
                cell:get_area_anchor_fmt("outerleftdummy_%d_sourcedrain1", 1).tl,
                cell:get_area_anchor_fmt("outerleftdummy_%d_sourcedrain1", numrows).br
            )
            geometry.rectanglebltr(cell, generics.metal(1),
                cell:get_area_anchor_fmt("outerrightdummy_%d_sourcedrain-1", 1).tl,
                cell:get_area_anchor_fmt("outerrightdummy_%d_sourcedrain-1", numrows).br
            )
        end
    end

    -- anchors
    cell:add_area_anchor_bltr("well",
        cell:get_area_anchor("well_all").bl,
        cell:get_area_anchor("well_all").tr
    )
end
