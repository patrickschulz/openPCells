function parameters()
    pcell.add_parameters(
        { "pattern", { { 1, 2, 1 }, { 2, 1, 2 } } },
        { "channeltype", "pmos" },
        { "vthtype", 1 },
        { "oxidetype", 1 },
        { "flippedwell", false },
        { "fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "xseparation", 0 },
        { "gatelength",  technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space") },
        { "gatemetal",  1 },
        { "gatelinemetal",  2 },
        { "usesourcestraps", false },
        { "sourcestrapsinside", false },
        { "usedrainstraps", false },
        { "drainmetal",  2 },
        { "interconnectmetal", 3 },
        { "sourcemetal", 2 },
        { "equalsourcenets", true },
        { "multiplesourcelines", true },
        { "sdwidth", technology.get_dimension("Minimum Source/Drain Contact Region Size") },
        { "sdm1ext", 0 },
        { "fingers", 2, posvals = even() },
        { "gatestrapwidth", technology.get_dimension("Minimum Gate Contact Region Size") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapleftext", 0 },
        { "gatestraprightext", 0 },
        { "gatelinewidth", technology.get_dimension("Minimum M2 Width") },
        { "gatelinespace", technology.get_dimension("Minimum M2 Space") },
        { "gatelineviawidth", technology.get_dimension("Minimum M2 Width") },
        { "gatelineviapitch", 0 },
        { "gateviawidth", technology.get_dimension("Minimum M2 Width") },
        { "fullgatevia", false },
        { "extendgatessymmetrically", false },
        { "usegateconnections", false },
        { "gateconnections", {} }, -- FIXME: this should be nil, but due to how parameters are handled internally, this is currently not supported
        { "interconnectlinepos", "inline", posvals = set("inline", "gate", "offside") },
        { "spreadinterconnectlines", true },
        { "interconnectlinewidth", technology.get_dimension("Minimum M3 Width") },
        { "interconnectlinespace", technology.get_dimension("Minimum M3 Space") },
        { "interconnectviapitch", technology.get_optional_dimension("Minimum M3 Pitch") },
        { "outputlinemode", "local", posvals = set("local", "global") },
        { "groupoutputlines", false },
        { "grouporder", "drain_inside", posvals = set("drain_inside", "source_inside") },
        { "drainordermanual", false },
        { "drainorder", {} },
        { "spreadoutputlines", true },
        { "outputlinewidth", technology.get_dimension("Minimum M4 Width") },
        { "outputlinespace", technology.get_dimension("Minimum M4 Space") },
        { "outputviawidth", technology.get_dimension("Minimum M4 Width") },
        { "outputlinetopextend", 0 },
        { "outputlinebotextend", 0 },
        { "insertglobalgateline", false },
        { "globalgatelinesincenter", true },
        { "connectsourcesonbothsides", false },
        { "sourcedrainstrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "sourcedrainstrapspace", technology.get_dimension("Minimum M1 Space") },
        { "equalgatenets", false },
        { "shortgates", false, follow = "equalgatenets" },
        { "gatestrapsincenter", false },
        { "connectgatesonbothsides", false },
        { "sourcenets", {} }, -- FIXME: this should be nil, but due to how parameters are handled internally, this is currently not supported
        { "drainnets", {} }, -- FIXME: this should be nil, but due to how parameters are handled internally, this is currently not supported
        { "connectgatetosourcedrain", {} }, -- FIXME: this should be nil, but due to how parameters are handled internally, this is currently not supported
        { "diodeconnected", {} },
        { "shortdummies", false, follow = "drawinnerguardrings" },
        { "innerdummies", 2 },
        { "outerdummies", 2 },
        { "outerdummygatelength", 500, follow = "gatelength" }, -- FIXME: basic/stacked_mosfet_array does not support this
        { "connectdummygatestoactive", false },
        { "connectdummies", true },
        { "connectdummysources", true },
        { "connectdummiestointernalnet", false },
        { "innerdummiesasdiode", false },
        { "outerdummiesasdiode", false },
        { "extendalltop", 0 },
        { "extendallbottom", 0 },
        { "extendallleft", 0 },
        { "extendallright", 0 },
        { "drawinnerguardrings", false },
        { "drawouterguardring", false },
        { "guardringwidth", technology.get_dimension("Minimum Active Contact Region Size") },
        { "guardringminxsep", 0 },
        { "guardringminysep", 0 },
        { "guardringfillimplant", true },
        { "guardringfillwell", true },
        { "guardringdrawoxidetype", true },
        { "guardringfilloxidetype", true },
        { "guardringoxidetype", 1, follow = "oxidetype" },
        { "guardringwellinnerextension", technology.get_dimension("Minimum Well Extension") },
        { "guardringwellouterextension", technology.get_dimension("Minimum Well Extension") },
        { "guardringimplantinnerextension", technology.get_dimension("Minimum Implant Extension") },
        { "guardringimplantouterextension", technology.get_dimension("Minimum Implant Extension") },
        { "guardringsoiopeninnerextension", technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "guardringsoiopenouterextension", technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "guardringoxidetypeinnerextension", technology.get_dimension("Minimum Oxide Extension") },
        { "guardringoxidetypeouterextension", technology.get_dimension("Minimum Oxide Extension") }
    )
end

function check(_P)
    if #_P.pattern % 2 == 1 then
        return false, "the pattern contains an odd number of rows. There might be a use case for this, but the current implementation does not support this"
    end
    for i = 2, #_P.pattern do
        if #_P.pattern[i] ~= #_P.pattern[1] then
            return false, string.format("row pattern lengths are not equal (row %d has %d entries, the other rows have %d entries)", i, #_P.pattern[i], #_P.pattern[1])
        end
    end
    local numdevices = 0
    local hasdummies = false
    for _, rowpattern in ipairs(_P.pattern) do
        for _, device in ipairs(rowpattern) do
            if device ~= 0 then
                if device > numdevices then
                    numdevices = device
                end
            else
                hasdummies = true
            end
        end
    end
    if numdevices < 2 then
        return false, "the pattern definition does not contain more than one device"
    end
    if _P.groupoutputlines and numdevices % 2 ~= 0 then
        return false, string.format("an odd number of devices is not allowed for grouped output lines (number of devices: %d)", numdevices)
    end
    if _P.connectdummygatestoactive and not _P.equalgatenets then
        return false, "if gate straps are in the center, all gates have to be on the same net (equalgatenets == true)"
    end
    if _P.connectdummygatestoactive and not _P.equalgatenets then
        return false, "if dummy gates are connected to active gates, all gates have to be on the same net (equalgatenets == true)"
    end
    if not _P.connectdummygatestoactive and _P.connectgatesonbothsides and (_P.innerdummies > 0 or _P.outerdummies > 0) then
        return false, "if gates are connected on both sides, dummy gates must be connected to the active gates"
    end
    if not _P.equalgatenets and _P.gatemetal == _P.gatelinemetal then
        return false, "if gates are on different nets, gate lines can not be on the same metal as gate connection lines (gatemetal and gatelinemetal)"
    end
    if _P.drawinnerguardrings and _P.gatemetal == 1 then
        return false, "if guard rings are present, gate connection lines can not be on metal 1 (gatemetal)"
    end
    if _P.drawinnerguardrings and _P.gatelinemetal == 1 then
        return false, "if guard rings are present, gate lines can not be on metal 1 (gatelinemetal)"
    end
    if _P.interconnectlinepos == "offside" and _P.usesourcestraps and not _P.sourcestrapsinside and _P.sourcemetal == _P.drainmetal then
        return false, "if interconnectlines are positioned 'offside' and source straps are used, the drain and source connections can not be on the same metal"
    end
    if not _P.equalsourcenets and not ((_P.xseparation > 0) or _P.drawinnerguardrings) then
        return false, "if source nets are not equal, the xseparation between devices can not be 0 or inner guard rings must be present"
    end
    if #_P.connectgatetosourcedrain ~= 0 then
        if _P.equalgatenets and #_P.connectgatetosourcedrain ~= 1 then
            return false, string.format("if gates are connected to source/drain nets, not more than one net shall be specified when equalgatenets == true (given nets: '%s')", table.concat(_P.connectgatetosourcedrain, ", "))
        end
        -- FIXME: check if connected nets exist
    end
    if _P.drainordermanual then
        for i = 1, numdevices do
            if not util.any_of(i, _P.drainorder) then
                return false, string.format("when the drain order is specified manually, all drain nets must be specified. Missing specification for device net %d", i)
            end
        end
    end
    -- check that no shorted dummies are present if gates are shorted
    if _P.shortgates and _P.shortdummies and hasdummies then
        return false, "shorted dummies (with dummies present) are not allowed if gates are shorted"
    end

    -- connect interconnect lines (source) to output lines
    if _P.usesourcestraps and not _P.equalsourcenets and _P.outputlinemode ~= "local" then
        return false, "when source straps with non-equal source nets are used, the sources can't reliably be connected by global output lines. Use local output lines or source interconnect lines"
    end
    return true
end

function layout(cell, _P)
    local flipsourcedrain = _P.channeltype == "nmos"
    local gatepitch = _P.gatelength + _P.gatespace
    -- create pattern only containing active devices
    local activepattern = {}
    for _, rowpattern in ipairs(_P.pattern) do
        local row = {}
        for _, device in ipairs(rowpattern) do
            if device ~= 0 then
                table.insert(row, device)
            end
        end
        table.insert(activepattern, row)
    end
    local numrows = #activepattern
    local numinstancesperrow = #(_P.pattern[1]) -- total number of *instances* in a row (e.g. 0ABBAABBA0 -> 10, includes dummies)
    local numdevicesperrow = {} -- total number of devices in a row (e.g. ABBBBA   -> 2
                               --                                         CAABBC   -> 3
                               --                                         CAABBC   -> 3
                               --                                         ABBBBA   -> 2)
    -- in the pattern, a '0' denotes a dummy, this does *not* count as a device
    local numdevices = 0 -- total number of devices (e.g. 0ABBA0
                         --                               0CCDD0
                         --                                    -> 4)
    for i, rowpattern in ipairs(activepattern) do
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
    local maxnumdevicespersinglerow = 0
    for rownum = 1, #numdevicesperrow do
        maxnumdevicespersinglerow = math.max(maxnumdevicespersinglerow, #util.uniq(activepattern[rownum]))
    end
    -- the maximum of different devices in a double row
    local maxnumdevicesperdoublerow = 0
    for rownum = 1, #numdevicesperrow - 1, 2 do
        maxnumdevicesperdoublerow = math.max(maxnumdevicesperdoublerow, #util.uniq(util.merge_tables(activepattern[rownum], activepattern[rownum + 1])))
    end
    local maxnumgatelines
    if _P.equalgatenets then
        maxnumgatelines = 1
    else
        if _P.usegateconnections then
            -- FIXME: this is too pessimistic, this should iterate over the pattern and use _map_device_index_to_gate to find the right number of gate lines
            maxnumgatelines = #_P.gateconnections
        else
            maxnumgatelines = maxnumdevicesperdoublerow
        end
    end
    local gateline_space_occupation = 2 * _P.gatestrapspace + 2 * _P.gatestrapwidth + (maxnumgatelines + 1) * _P.gatelinespace + maxnumgatelines * _P.gatelinewidth
    if _P.usesourcestraps and _P.sourcestrapsinside then
        gateline_space_occupation = gateline_space_occupation + 2 * (_P.sourcedrainstrapwidth + _P.sourcedrainstrapspace)
    end
    local interconnectline_space_occupation
    if _P.interconnectlinepos == "inline" then
        interconnectline_space_occupation = 0
    elseif _P.interconnectlinepos == "gate" then
        interconnectline_space_occupation = 2 * _P.sourcedrainstrapspace + 2 * _P.sourcedrainstrapwidth + (maxnumdevicesperdoublerow + 1) * _P.interconnectlinespace + maxnumdevicesperdoublerow * _P.interconnectlinewidth
    else -- "offside"
        if numrows == 2 then -- 'offside' lines are outside of the array, no spacing requirements here
            interconnectline_space_occupation = 0
        else
            if _P.equalsourcenets then
                local numlines = 2 * maxnumdevicespersinglerow
                if not _P.usesourcestraps then
                    numlines = numlines + 2
                end
                interconnectline_space_occupation = (numlines + 1) * _P.interconnectlinespace + numlines * _P.interconnectlinewidth
            else
                local numlines = 0
                for rownum = 2, numrows - 1, 2 do
                    local l = 2 * (numdevicesperrow[rownum] + numdevicesperrow[rownum + 1])
                    numlines = math.max(numlines, l)
                end
                interconnectline_space_occupation = (numlines + 1) * _P.interconnectlinespace + numlines * _P.interconnectlinewidth
            end
        end
    end
    local yseparation_needed = math.max(interconnectline_space_occupation, gateline_space_occupation)
    if _P.drawinnerguardrings then
        yseparation = 0
    else
        yseparation = yseparation_needed
    end
    local interconnectline_offset = yseparation - interconnectline_space_occupation
    local guardringxsep = _P.guardringminxsep
    local guardringysep = math.max(_P.guardringminysep, (yseparation_needed - _P.guardringwidth) / 2)

    local gateext
    if _P.extendgatessymmetrically then
        if _P.gatestrapsincenter and not _P.drawinnerguardrings then
            gateext = (yseparation + _P.gatestrapwidth) / 2
        else
            gateext = _P.gatestrapspace + _P.gatestrapwidth
        end
    else
        -- keep nil to get the default value
    end

    local rowoptions = {
        channeltype = _P.channeltype,
        oxidetype = _P.oxidetype,
        vthtype = _P.vthtype,
        flippedwell = _P.flippedwell,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        width = _P.fingerwidth,
        sdwidth = _P.sdwidth,
        gtopext = gateext,
        gbotext = gateext,
        topgateleftextension = _P.gatestrapleftext,
        botgateleftextension = _P.gatestrapleftext,
        topgaterightextension = _P.gatestraprightext,
        botgaterightextension = _P.gatestraprightext,
        extendalltop = _P.extendalltop,
        extendallbottom = _P.extendallbottom,
        extendallleft = _P.extendallleft,
        extendallright = _P.extendallright,
    }

    local gatespace
    if _P.gatestrapsincenter then
        -- FIXME: this should rather be checked in check()
        if not _P.drawinnerguardrings then
            gatespace = (yseparation - _P.gatestrapwidth) / 2
        end
    else
        gatespace = _P.gatestrapspace
        if _P.usesourcestraps and _P.sourcestrapsinside then
            gatespace = gatespace + _P.sourcedrainstrapwidth + _P.sourcedrainstrapspace
        end
    end
    local commonoptions = {
        topgatewidth = _P.gatestrapwidth,
        topgatespace = gatespace,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = gatespace,
        drawsourcevia = true,
        drawdrainvia = true,
        connectsourcewidth = _P.sourcedrainstrapwidth,
        connectsourcespace = _P.sourcedrainstrapspace,
        connectdrainwidth = _P.sourcedrainstrapwidth,
        connectdrainspace = _P.sourcedrainstrapspace,
    }

    local fetoptions = util.add_options(commonoptions, {
        fingers = _P.fingers,
        drainmetal = _P.drainmetal,
        sourcemetal = _P.sourcemetal,
        connectsource = _P.usesourcestraps,
        connectsourceboth = _P.connectsourcesonbothsides,
        connectdrain = _P.usedrainstraps,
    })

    local dummyoptions = util.add_options(commonoptions, {
        shortwidth = _P.gatestrapwidth,
        shortspace = (_P.gatestrapsincenter and not _P.drawinnerguardrings) and (yseparation - _P.gatestrapwidth) / 2 or _P.gatestrapspace,
        connectsource = _P.usesourcestraps and _P.connectdummysources,
        connectsourceboth = _P.connectdummysources,
        connectdrain = _P.connectdummysources,
        connectdrainboth = _P.connectdummysources,
    })

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
    for rownum, rowpattern in ipairs(_P.pattern) do -- don't use activepattern here as dummies should be generated
        for column, devicenum in ipairs(rowpattern) do
            local index = _get_device_name(devicenum)
            table.insert(devicetable, {
                device = devicenum, -- the 'device' refers to the group of mosfets with equal connectivity, an entry in the pattern (e.g. '1')
                row = rownum,
                column = column,
                index = index, -- the 'index' is counted for each 'device', so every instance has its unique combination of 'index' and 'device' (e.g. '1-1', '1-2', '1-3', ...)
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
    local function _get_active_devices(cond)
        local result = {}
        for _, device in ipairs(devicetable) do
            if device.device ~= 0 then
                if cond(device) then
                    table.insert(result, device)
                end
            end
        end
        return result
    end

    local function _get_active_device(cond)
        local result = {}
        for _, device in ipairs(devicetable) do
            if device.device ~= 0 then
                if cond(device) then
                    table.insert(result, device)
                end
            end
        end
        if #result > 1 then
            error("ambigious device query")
        end
        if #result == 0 then
            return nil
        end
        return result[1]
    end

    -- prepare mosfet rows
    local function _make_row_devices(rownum, devicerow)
        local devices = {}
        table.insert(devices,
            util.add_options(dummyoptions, {
                name = string.format("outerleftdummy_%d", rownum),
                fingers = _P.outerdummies,
                gatelength = _P.outerdummygatelength,
                drawtopgate = _P.connectgatesonbothsides or (rownum % 2 == 0),
                drawbotgate = _P.connectgatesonbothsides or (rownum % 2 == 1),
                shortdevice = _P.connectdummiestointernalnet or (not _P.connectdummysources and (_P.outerdummies > 1)),
                shortsourcegate = _P.outerdummies == 1,
                shortlocation = (rownum % 2 == 0) and "top" or "bottom",
                shortdevicerightoffset = _P.connectdummiestointernalnet and 0 or 1,
                topgaterightextension = -_P.gatelength,
                drainmetal = _P.outerdummiesasdiode and 1 or _P.sourcemetal,
                sourcemetal = _P.outerdummiesasdiode and 1 or _P.sourcemetal,
            })
        )
        local connectsourceinverse
        if _P.sourcestrapsinside then
            connectsourceinverse = ((_P.channeltype == "pmos") and (rownum % 2 == 0)) or ((_P.channeltype == "nmos") and (rownum % 2 == 1))
        else
            connectsourceinverse = ((_P.channeltype == "pmos") and (rownum % 2 == 1)) or ((_P.channeltype == "nmos") and (rownum % 2 == 0))
        end
        for deviceindex, device in ipairs(devicerow) do
            if device.device ~= 0 then
                table.insert(devices,
                    util.add_options(fetoptions, {
                        name = string.format("M_%d_%d_%d", device.device, device.row, device.index),
                        fingers = _P.fingers,
                        drawtopgate = _P.connectgatesonbothsides or (rownum % 2 == 1),
                        drawbotgate = _P.connectgatesonbothsides or (rownum % 2 == 0),
                        sdm1botext = (rownum % 2 == 1) and _P.sdm1ext or 0,
                        sdm1topext = (rownum % 2 == 0) and _P.sdm1ext or 0,
                        connectsourceinverse = connectsourceinverse,
                        connectdraininverse = ((_P.channeltype == "pmos") and (rownum % 2 == 1)) or ((_P.channeltype == "nmos") and (rownum % 2 == 0)),
                        diodeconnected = util.any_of(device.device, _P.diodeconnected),
                        connectdrainleftext = (_P.fingers == 2) and (_P.interconnectviapitch + _P.interconnectlinewidth - _P.sdwidth) / 2 or 0,
                        connectdrainrightext = (_P.fingers == 2) and (_P.interconnectviapitch + _P.interconnectlinewidth - _P.sdwidth) / 2 or 0,
                    })
                )
            else
                table.insert(devices,
                    util.add_options(fetoptions, {
                        shortdevice = _P.shortdummies,
                        diodeconnected = _P.shortdummies,
                        name = string.format("M_%d_%d_%d", device.device, device.row, device.index),
                        fingers = _P.fingers,
                        drawtopgate = _P.connectgatesonbothsides or (rownum % 2 == 1),
                        drawbotgate = _P.connectgatesonbothsides or (rownum % 2 == 0),
                        sdm1botext = (rownum % 2 == 1) and _P.sdm1ext or 0,
                        sdm1topext = (rownum % 2 == 0) and _P.sdm1ext or 0,
                        connectsourceinverse = connectsourceinverse,
                        connectdraininverse = ((_P.channeltype == "pmos") and (rownum % 2 == 1)) or ((_P.channeltype == "nmos") and (rownum % 2 == 0)),
                        connectdrainleftext = (_P.fingers == 2) and (_P.interconnectviapitch + _P.interconnectlinewidth - _P.sdwidth) / 2 or 0,
                        connectdrainrightext = (_P.fingers == 2) and (_P.interconnectviapitch + _P.interconnectlinewidth - _P.sdwidth) / 2 or 0,
                        drainmetal = 1,
                        sourcemetal = 1,
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
                shortdevice = _P.connectdummiestointernalnet or (not _P.connectdummysources and (_P.outerdummies > 1)),
                shortdraingate = _P.outerdummies == 1,
                shortlocation = (rownum % 2 == 0) and "top" or "bottom",
                shortdeviceleftoffset = _P.connectdummiestointernalnet and 0 or 1,
                topgateleftextension = -_P.gatelength,
                drainmetal = _P.outerdummiesasdiode and 1 or _P.sourcemetal,
                sourcemetal = _P.outerdummiesasdiode and 1 or _P.sourcemetal,
            })
        )
        return devices
    end

    -- create mosfet array
    local rows = {}
    for rownum = 1, numrows do
        local row = util.add_options(rowoptions, {})
        local devicerow = _get_devices(function(device) return device.row == rownum end)
        row.devices = _make_row_devices(rownum, devicerow)
        table.insert(rows, row)
    end
    local array = pcell.create_layout("basic/stacked_mosfet_array", "_array", {
        rows = rows,
        drawimplant = not (_P.guardringfillimplant and (_P.drawinnerguardrings or _P.drawouterguardring)),
        xseparation = _P.xseparation,
        yseparation = yseparation,
        autoskip = true,
        splitgates = not _P.shortgates,
        drawguardring = _P.drawinnerguardrings,
        guardringwidth = _P.guardringwidth,
        guardringrespectactivedummy = false,
        guardringrespectgatestraps = false,
        guardringrespectgateextensions = false,
        guardringleftsep = guardringxsep,
        guardringrightsep = guardringxsep,
        guardringtopsep = guardringysep,
        guardringbottomsep = guardringysep,
        guardringfillimplant = _P.guardringfillimplant,
        guardringfillwell = _P.guardringfillwell,
        guardringdrawoxidetype = _P.guardringdrawoxidetype,
        guardringfilloxidetype = _P.guardringfilloxidetype,
        guardringoxidetype = _P.guardringoxidetype,
        guardringwellinnerextension = _P.guardringwellinnerextension,
        guardringwellouterextension = _P.guardringwellouterextension,
        guardringimplantinnerextension = _P.guardringimplantinnerextension,
        guardringimplantouterextension = _P.guardringimplantouterextension,
        guardringsoiopeninnerextension = _P.guardringsoiopeninnerextension,
        guardringsoiopenouterextension = _P.guardringsoiopenouterextension,
    })
    cell:merge_into(array)
    cell:inherit_all_anchors_with_prefix(array, "")
    cell:inherit_alignment_box(array)

    local _get_dev_anchor = function(device, where)
        return cell:get_area_anchor_fmt("M_%d_%d_%d_%s", device.device, device.row, device.index, where)
    end

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
        local doublerowdevices = _get_active_devices(function(device) return device.row == 2 * rownum - 1 or device.row == 2 * rownum end)
        local indices = util.uniq(util.foreach(doublerowdevices, function(entry) return entry.device end))
        table.sort(indices)
        return indices
    end

    local function _get_uniq_row_devices_single(rownum)
        local singlerowdevices = _get_active_devices(function(device) return device.row == rownum end)
        local indices = util.uniq(util.foreach(singlerowdevices, function(entry) return entry.device end))
        table.sort(indices)
        return indices
    end

    local function _map_device_index_to_gate(device)
        if _P.usegateconnections then
            for i, entry in ipairs(_P.gateconnections) do
                if util.any_of(device, entry) then
                    return i
                end
            end
        else
            return device
        end
        -- should not reach here
        -- FIXME: implement check in check()
    end

    -- find maximum/minimum x coordinates for gate lines
    local gatelineminx
    local gatelinemaxx
    do
        local row1devices = _get_devices(function(device) return device.row == 1 end)
        local leftdevice = row1devices[1]
        local rightdevice = row1devices[#row1devices]
        gatelineminx = _get_dev_anchor(leftdevice, "active").l
        gatelinemaxx = _get_dev_anchor(rightdevice, "active").r
    end

    -- create gate lines
    for rownum = 1, math.floor((numrows + 1) / 2) do
        -- gate lines cover all devices, not only active devices
        local lowerdevices = _get_devices(function(device) return device.row == 2 * rownum - 1 end)
        local upperdevices = _get_devices(function(device) return device.row == 2 * rownum end)
        local leftlowerdevice = lowerdevices[1]
        local rightlowerdevice = lowerdevices[numinstancesperrow]
        local leftupperdevice = upperdevices[1]
        local rightupperdevice = upperdevices[numinstancesperrow]
        local gateline_center = 0.5 * point.ydistance_abs(
            _get_dev_anchor(leftupperdevice, "active").bl,
            _get_dev_anchor(leftlowerdevice, "active").tl
        )
        if _P.equalgatenets then
            cell:add_area_anchor_bltr(string.format("gateline_%d", rownum),
                point.create(
                    _get_dev_anchor(leftlowerdevice, "active").l,
                    gatelineminx,
                    _get_dev_anchor(leftlowerdevice, "active").t + gateline_center - _P.gatelinewidth / 2
                ),
                point.create(
                    gatelinemaxx,
                    _get_dev_anchor(rightlowerdevice, "active").t + gateline_center + _P.gatelinewidth / 2
                )
            )
            geometry.rectanglebltr(cell, generics.metal(_P.gatelinemetal),
                cell:get_area_anchor_fmt("gateline_%d", rownum).bl,
                cell:get_area_anchor_fmt("gateline_%d", rownum).tr
            )
        else -- not _P.equalgatenets
            local devindices = _get_uniq_row_devices(rownum)
            local lines = {}
            for _, di in ipairs(devindices) do
                local index = _map_device_index_to_gate(di)
                if not util.any_of(index, lines) then
                    table.insert(lines, index)
                end
            end
            local numlines = #lines
            for line, index in ipairs(lines) do
                local yshift = -(numlines - 1) / 2 * (_P.gatelinespace + _P.gatelinewidth) + (line - 1) * (_P.gatelinespace + _P.gatelinewidth)
                cell:add_area_anchor_bltr(string.format("gateline_%d_%d", rownum, index),
                    point.create(
                        gatelineminx,
                        _get_dev_anchor(leftlowerdevice, "active").t + gateline_center + yshift - _P.gatelinewidth / 2
                    ),
                    point.create(
                        gatelinemaxx,
                        _get_dev_anchor(rightlowerdevice, "active").t + gateline_center + yshift + _P.gatelinewidth / 2
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.gatelinemetal),
                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).bl,
                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).tr
                )
            end
        end
    end

    -- connect gates to gate lines
    if not _P.gatestrapsincenter then
        for rownum = 1, math.floor((numrows + 1) / 2) do
            if _P.equalgatenets then
                local anchortarget = { "b", "t" }
                for colnum = 1, numinstancesperrow do
                    local lowerdevice = _get_active_device(function(device) return (device.row == 2 * rownum - 1) and (device.column == colnum) end)
                    local upperdevice = _get_active_device(function(device) return (device.row == 2 * rownum)     and (device.column == colnum) end)
                    local devices = {}
                    if lowerdevice then
                        devices[1] = lowerdevice
                    end
                    if upperdevice then
                        devices[2] = upperdevice
                    end
                    for i = 1, 2 do
                        local device = devices[i]
                        if device then
                            local gate = (i % 2 == 1) and "top" or "bot"
                            local anchor = _get_dev_anchor(device, string.format("%sgatestrap", gate))
                            local target1 = (i % 2 == 1) and "b" or "t"
                            local target2 = (i % 2 == 1) and "t" or "b"
                            geometry.viabltr(cell, _P.gatemetal, _P.gatelinemetal,
                                point.create(
                                    0.5 * (anchor.l + anchor.r) - _P.gatelineviawidth / 2,
                                    cell:get_area_anchor_fmt("gateline_%d", rownum).b
                                ),
                                point.create(
                                    0.5 * (anchor.l + anchor.r) + _P.gatelineviawidth / 2,
                                    cell:get_area_anchor_fmt("gateline_%d", rownum).t
                                )
                            )
                            geometry.rectanglepoints(cell, generics.metal(_P.gatemetal),
                                point.create(
                                    0.5 * (anchor.l + anchor.r) - _P.gatelinewidth / 2,
                                    anchor[target1]
                                ),
                                point.create(
                                    0.5 * (anchor.l + anchor.r) + _P.gatelinewidth / 2,
                                    cell:get_area_anchor_fmt("gateline_%d", rownum)[target2]
                                )
                            )
                            -- connect to gate
                            if _P.fullgatevia then
                                geometry.viabltr(cell, 1, _P.gatemetal, anchor.bl, anchor.tr)
                            else
                                geometry.viabltr(cell, 1, _P.gatemetal,
                                    point.create(
                                        0.5 * (anchor.l + anchor.r) - _P.gatelineviawidth / 2,
                                        anchor.b
                                    ),
                                    point.create(
                                        0.5 * (anchor.l + anchor.r) + _P.gatelineviawidth / 2,
                                        anchor.t
                                    )
                                )
                            end
                        end
                    end
                end
            else
                for colnum = 1, numinstancesperrow do
                    local lowerdevice = _get_active_device(function(device) return (device.row == 2 * rownum - 1) and (device.column == colnum) end)
                    local upperdevice = _get_active_device(function(device) return (device.row == 2 * rownum)     and (device.column == colnum) end)
                    local devices = {}
                    if lowerdevice then
                        devices[1] = lowerdevice
                    end
                    if upperdevice then
                        devices[2] = upperdevice
                    end
                    local spread = (lowerdevice and upperdevice) and lowerdevice.device ~= upperdevice.device
                    for i = 1, 2 do
                        local device = devices[i]
                        if device then
                            local gate = (i % 2 == 1) and "top" or "bot"
                            local shiftamount
                            if _P.gatelineviapitch > 0 then
                                shiftamount = _P.gatelineviapitch
                            else
                                shiftamount = _P.gatelength + _P.gatespace
                            end
                            local shift = spread and (i - 1.5) * shiftamount or 0
                            -- draw connection line
                            geometry.rectanglepoints(cell, generics.metal(_P.gatemetal),
                                point.create(
                                    0.5 * (
                                        _get_dev_anchor(device, string.format("%sgatestrap", gate)).l +
                                        _get_dev_anchor(device, string.format("%sgatestrap", gate)).r
                                    ) - _P.gatelinewidth / 2 + shift,
                                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, _map_device_index_to_gate(device.device)).b
                                ),
                                point.create(
                                    0.5 * (
                                        _get_dev_anchor(device, string.format("%sgatestrap", gate)).l +
                                        _get_dev_anchor(device, string.format("%sgatestrap", gate)).r
                                    ) + _P.gatelinewidth / 2 + shift,
                                    _get_dev_anchor(device, string.format("%sgatestrap", gate)).t
                                )
                            )
                            -- connect to gate
                            if not spread and _P.fullgatevia then
                                geometry.viabltr(cell, 1, _P.gatemetal,
                                    _get_dev_anchor(device, string.format("%sgatestrap", gate)).bl,
                                    _get_dev_anchor(device, string.format("%sgatestrap", gate)).tr
                                )
                            else
                                geometry.viabltr(cell, 1, _P.gatemetal,
                                    point.create(
                                        0.5 * (
                                            _get_dev_anchor(device, string.format("%sgatestrap", gate)).l +
                                            _get_dev_anchor(device, string.format("%sgatestrap", gate)).r
                                        ) - _P.gatelineviawidth / 2 + shift,
                                        _get_dev_anchor(device, string.format("%sgatestrap", gate)).b
                                    ),
                                    point.create(
                                        0.5 * (
                                            _get_dev_anchor(device, string.format("%sgatestrap", gate)).l +
                                            _get_dev_anchor(device, string.format("%sgatestrap", gate)).r
                                        ) + _P.gatelineviawidth / 2 + shift,
                                        _get_dev_anchor(device, string.format("%sgatestrap", gate)).t
                                    )
                                )
                            end
                            -- connect to gate line
                            geometry.viabltr(cell, _P.gatemetal, _P.gatelinemetal,
                                point.create(
                                    0.5 * (
                                        _get_dev_anchor(device, string.format("%sgatestrap", gate)).l +
                                        _get_dev_anchor(device, string.format("%sgatestrap", gate)).r
                                    ) - _P.gatelineviawidth / 2 + shift,
                                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, _map_device_index_to_gate(device.device)).b
                                ),
                                point.create(
                                    0.5 * (
                                        _get_dev_anchor(device, string.format("%sgatestrap", gate)).l +
                                        _get_dev_anchor(device, string.format("%sgatestrap", gate)).r
                                    ) + _P.gatelineviawidth / 2 + shift,
                                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, _map_device_index_to_gate(device.device)).t
                                )
                            )
                        end
                    end
                end
            end
        end
    end

    -- find maximum/minimum x coordinates for interconnect lines
    local interconnectlineminx
    local interconnectlinemaxx
    do
        local row1devices = _get_devices(function(device) return device.row == 1 end)
        local leftdevice = row1devices[1]
        local rightdevice = row1devices[#row1devices]
        interconnectlineminx = _get_dev_anchor(leftdevice, "active").l
        interconnectlinemaxx = _get_dev_anchor(rightdevice, "active").r
    end

    -- create interconnect lines
    if _P.interconnectlinepos == "inline" then
        for rownum = 1, numrows do
            local anchor
            local sign
            if rownum % 2 == 1 then
                anchor = "t"
                sign = -1
            else
                anchor = "b"
                sign = 1
            end
            local devnums = _get_uniq_row_devices_single(rownum)
            local devices = _get_active_devices(function(device) return device.row == rownum end)
            local leftdevice = devices[1]
            local rightdevice = devices[numinstancesperrow]
            local interconnectline_center = 0.5 * _P.fingerwidth
            local lines = {}
            if _P.equalsourcenets then
                -- create common source line
                if not _P.usesourcestraps then
                    table.insert(lines, "source0")
                end
            else
                -- add individual source lines
                for line, num in ipairs(devnums) do
                    table.insert(lines, string.format("source%d", num))
                end
            end
            -- add individual drain lines
            for line, num in ipairs(devnums) do
                table.insert(lines, string.format("drain%d", num))
            end
            local numlines = #lines
            local space
            if _P.spreadinterconnectlines then
                space = divevendown(_P.fingerwidth - numlines * _P.interconnectlinewidth, numlines)
            else
                space = _P.interconnectlinespace
            end
            for line, linelabel in ipairs(lines) do
                cell:add_area_anchor_points(string.format("interconnectline_%d_%s", rownum, linelabel),
                    point.create(
                        cell:get_area_anchor_fmt("outeralignmentbox_%d_%d", rownum, 1).l,
                        _get_dev_anchor(leftdevice, "active")[anchor] + sign * (interconnectline_center - (numlines * _P.interconnectlinewidth + (numlines - 1) * space) / 2 + (line - 1) * (space + _P.interconnectlinewidth))
                    ),
                    point.create(
                        cell:get_area_anchor_fmt("outeralignmentbox_%d_%d", rownum, numinstancesperrow).r,
                        _get_dev_anchor(leftdevice, "active")[anchor] + sign * (interconnectline_center - (numlines * _P.interconnectlinewidth + (numlines - 1) * space) / 2 + _P.interconnectlinewidth + (line - 1) * (space + _P.interconnectlinewidth))
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal),
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, linelabel).bl,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, linelabel).tr
                )
            end
        end
    elseif _P.interconnectlinepos == "gate" then
        for rownum = 1, math.floor((numrows + 1) / 2) do
            local devindices = _get_uniq_row_devices(rownum)
            local doublerowdevices = _get_active_devices(function(device) return device.row == 2 * rownum - 1 or device.row == 2 * rownum end)
            local leftdevice = doublerowdevices[1]
            local rightdevice = doublerowdevices[numinstancesperrow]
            for line, index in ipairs(devindices) do
                cell:add_area_anchor_bltr(string.format("interconnectline_%d_%s", rownum, string.format("drain%d", index)),
                    point.create(
                        interconnectlineminx,
                        _get_dev_anchor(leftdevice, "active").t + interconnectline_offset + _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth + _P.interconnectlinespace + (line - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth)
                    ),
                    point.create(
                        interconnectlinemaxx,
                        _get_dev_anchor(rightdevice, "active").t + interconnectline_offset + _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth + _P.interconnectlinespace + _P.interconnectlinewidth + (line - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth)
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal),
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", index)).bl,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", index)).tr
                )
            end
        end
    else -- "offside"
        for rownum = 1, numrows do
            local anchor
            local sign
            if rownum % 2 == 1 then
                anchor = "b"
                sign = -1
            else
                anchor = "t"
                sign = 1
            end
            local devindices = _get_uniq_row_devices_single(rownum)
            local singlerowdevices = _get_active_devices(function(device) return device.row == rownum end)
            if #devindices > 0 then -- check for dummy-only rows
                local leftdevice = singlerowdevices[1]
                local rightdevice = singlerowdevices[#singlerowdevices]
                local skipstrap = (_P.usesourcestraps and not _P.sourcestrapsinside) and _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth or 0
                local lines = {}
                if not _P.usesourcestraps then
                    if _P.equalsourcenets then
                        -- create common source line
                        table.insert(lines, "source0")
                    else
                        -- add individual source lines
                        for line, num in ipairs(devindices) do
                            table.insert(lines, string.format("source%d", num))
                        end
                    end
                end
                -- add individual drain lines
                for line, num in ipairs(devindices) do
                    table.insert(lines, string.format("drain%d", num))
                end
                for line, linelabel in ipairs(lines) do
                    cell:add_area_anchor_points(string.format("interconnectline_%d_%s", rownum, linelabel),
                        point.create(
                            interconnectlineminx,
                            _get_dev_anchor(rightdevice, "active")[anchor] + sign * (skipstrap + _P.interconnectlinespace + _P.interconnectlinewidth + (line - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth))
                        ),
                        point.create(
                            interconnectlinemaxx,
                            _get_dev_anchor(leftdevice, "active")[anchor] + sign * (skipstrap + _P.interconnectlinespace + (line - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth))
                        )
                    )
                    geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal),
                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, linelabel).bl,
                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, linelabel).tr
                    )
                end
            end
        end
    end

    -- connect sources to interconnect lines
    if not _P.usesourcestraps then
        if _P.equalsourcenets then
            if _P.interconnectlinepos == "inline" then
                if _P.sourcemetal ~= _P.interconnectmetal then
                    for rownum = 1, numrows do
                        local devices = _get_active_devices(function(device) return device.row == rownum end)
                        for _, device in ipairs(devices) do
                            for finger = 1, _P.fingers + 1, 2 do
                                geometry.viabarebltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).bl,
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).tr,
                                    cell:get_area_anchor_fmt("interconnectline_%d_source0", rownum).bl,
                                    cell:get_area_anchor_fmt("interconnectline_%d_source0", rownum).tr
                                )
                            end
                        end
                    end
                end
            elseif _P.interconnectlinepos == "gate" then
            else -- "offside"
                for rownum = 1, numrows do
                    local anchor
                    if rownum % 2 == 1 then
                        anchor = "b"
                    else
                        anchor = "t"
                    end
                    local devices = _get_active_devices(function(device) return device.row == rownum end)
                    for _, device in ipairs(devices) do
                        for finger = 1, _P.fingers + 1, 2 do
                            if rownum % 2 == 1 then
                                geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").b
                                    ),
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).b
                                    )
                                )
                                if _P.sourcemetal ~= _P.interconnectmetal then
                                    geometry.viabarebltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                                        point.create(
                                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").b
                                        ),
                                        point.create(
                                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).b
                                        ),
                                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").bl,
                                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").tr
                                    )
                                end
                            else
                                geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).t
                                    ),
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").t
                                    )
                                )
                                if _P.sourcemetal ~= _P.interconnectmetal then
                                    geometry.viabarebltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                                        point.create(
                                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).t
                                        ),
                                        point.create(
                                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").t
                                        ),
                                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").bl,
                                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").tr
                                    )
                                end
                            end
                        end
                    end
                end
            end
        else -- not _P.equalsourcenets
            if _P.interconnectlinepos == "inline" then
                for rownum = 1, numrows do
                    local devices = _get_active_devices(function(device) return device.row == rownum end)
                    for _, device in ipairs(devices) do
                        for finger = 1, _P.fingers + 1, 2 do
                            geometry.viabarebltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                                _get_dev_anchor(device, string.format("sourcedrain%d", finger)).bl,
                                _get_dev_anchor(device, string.format("sourcedrain%d", finger)).tr,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).bl,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).tr
                            )
                        end
                    end
                end
            elseif _P.interconnectlinepos == "gate" then
            else -- "offside"
                for rownum = 1, numrows do
                    local anchor
                    if rownum % 2 == 1 then
                        anchor = "b"
                    else
                        anchor = "t"
                    end
                    local devices = _get_active_devices(function(device) return device.row == rownum end)
                    for _, device in ipairs(devices) do
                        for finger = 1, _P.fingers + 1, 2 do
                            if rownum % 2 == 1 then
                                geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).b
                                    ),
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).b
                                    )
                                )
                                geometry.viabarebltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).b
                                    ),
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).b
                                    ),
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).bl,
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).tr
                                )
                            else
                                geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).t
                                    ),
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).t
                                    )
                                )
                                geometry.viabarebltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).t
                                    ),
                                    point.create(
                                        _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).t
                                    ),
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).bl,
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).tr
                                )
                            end
                        end
                    end
                end
            end
        end
    end

    -- connect drains to interconnect lines
    if _P.interconnectlinepos == "inline" then
        if _P.drainmetal ~= _P.interconnectmetal then
            for rownum = 1, numrows do
                local devices = _get_active_devices(function(device) return device.row == rownum end)
                for _, device in ipairs(devices) do
                    for finger = 2, _P.fingers + 1, 2 do
                        geometry.viabarebltrov(cell, _P.drainmetal, _P.interconnectmetal,
                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).bl,
                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).tr,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).bl,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).tr
                        )
                    end
                end
            end
        end
    elseif _P.interconnectlinepos == "gate" then
    else -- "offside"
        for rownum = 1, numrows do
            local anchor
            if rownum % 2 == 1 then
                anchor = "b"
            else
                anchor = "t"
            end
            local devices = _get_active_devices(function(device) return device.row == rownum end)
            for _, device in ipairs(devices) do
                for finger = 2, _P.fingers + 1, 2 do
                    if rownum % 2 == 1 then
                        geometry.rectanglebltr(cell, generics.metal(_P.drainmetal),
                            point.create(
                                _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).b
                            ),
                            point.create(
                                _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                _get_dev_anchor(device, string.format("sourcedrain%d", finger)).b
                            )
                        )
                        if _P.drainmetal ~= _P.interconnectmetal then
                            geometry.viabarebltrov(cell, _P.drainmetal, _P.interconnectmetal,
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).b
                                ),
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).b
                                ),
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).bl,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).tr
                            )
                        end
                    else
                        geometry.rectanglebltr(cell, generics.metal(_P.drainmetal),
                            point.create(
                                _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                _get_dev_anchor(device, string.format("sourcedrain%d", finger)).t
                            ),
                            point.create(
                                _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).t
                            )
                        )
                        if _P.drainmetal ~= _P.interconnectmetal then
                            geometry.viabarebltrov(cell, _P.drainmetal, _P.interconnectmetal,
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).t
                                ),
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).t
                                ),
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).bl,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).tr
                            )
                        end
                    end
                end
            end
        end
    end

    -- find maximum/minimum y coordinates for global lines
    local outputlineminy
    local outputlinemaxy
    if _P.interconnectlinepos == "inline" then
        local lowerrowdevices = _get_devices(function(device) return device.row == 1 end)
        local lowerdevice = lowerrowdevices[1]
        local upperrowdevices = _get_devices(function(device) return device.row == numrows end)
        local upperdevice = upperrowdevices[1]
        outputlineminy = _get_dev_anchor(lowerdevice, "active").b
        outputlinemaxy = _get_dev_anchor(upperdevice, "active").t
    elseif _P.interconnectlinepos == "gate" then
        local lowerrowdevices = _get_devices(function(device) return device.row == 1 end)
        local lowerdevice = lowerrowdevices[1]
        local upperrowdevices = _get_devices(function(device) return device.row == numrows end)
        local upperdevice = upperrowdevices[1]
        outputlineminy = _get_dev_anchor(lowerdevice, "active").b
        outputlinemaxy = _get_dev_anchor(upperdevice, "active").t
    else -- "offside"
        local lowerdevindices = _get_uniq_row_devices_single(1)
        local lowerdevices = _get_devices(function(device) return device.row == 1 end)
        local lowerdevice = lowerdevices[1]
        local skipstrap = _P.usesourcestraps and _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth or 0
        local numlowerlines = #lowerdevindices
        if not _P.usesourcestraps then
            if _P.equalsourcenets then
                numlowerlines = numlowerlines + 1
            else
                numlowerlines = numlowerlines + numlowerlines
            end
        end
        outputlineminy = _get_dev_anchor(lowerdevice, "active").b - (skipstrap + _P.interconnectlinespace + _P.interconnectlinewidth + (numlowerlines - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth))
        local upperdevindices = _get_uniq_row_devices_single(numrows)
        local upperdevices = _get_devices(function(device) return device.row == numrows end)
        local upperdevice = upperdevices[1]
        local numupperlines = #upperdevindices
        if not _P.usesourcestraps then
            if _P.equalsourcenets then
                numupperlines = numupperlines + 1
            else
                numupperlines = numupperlines + numupperlines
            end
        end
        local skipstrap = _P.usesourcestraps and _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth or 0
        outputlinemaxy = _get_dev_anchor(upperdevice, "active").t + (skipstrap + _P.interconnectlinespace + _P.interconnectlinewidth + (numupperlines - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth))
    end

    -- create output lines
    if _P.outputlinemode == "global" then
        -- get the targetwidth from the alignmentboxes, so that the global line array is continuous
        local outertargetwidth = point.xdistance_abs(
            cell:get_alignment_anchor("outerbl"),
            cell:get_alignment_anchor("outertr")
        )
        local innertargetwidth = point.xdistance_abs(
            cell:get_alignment_anchor("innerbl"),
            cell:get_alignment_anchor("innertr")
        )
        local targetwidth = 0.5 * (outertargetwidth + innertargetwidth)
        local outputline_center = 0.5 * outertargetwidth
        local lines = {}
        if _P.groupoutputlines then
            --local numhalflines = (numdevices % 2 == 1) and ((numdevices + 1) / 2) or (numdevices / 2)
            local numhalflines = numdevices / 2
            if _P.grouporder == "drain_inside" then
                -- insert source lines
                if _P.equalsourcenets then
                    if _P.multiplesourcelines then
                        for i = 1, numhalflines do
                            table.insert(lines, {
                                device = "source0",
                                variant = i,
                            })
                        end
                    else
                        table.insert(lines, {
                            device = "source0",
                        })
                    end
                else
                    for i = 1, numhalflines do
                        table.insert(lines, {
                            device = string.format("source%d", i),
                        })
                    end
                end
                for i = 1, numhalflines do
                end
                if _P.drainordermanual then
                    for _, entry in ipairs(_P.drainorder) do
                        -- insert drain lines
                        table.insert(lines, {
                            device = string.format("drain%d", entry),
                        })
                    end
                else
                    for entry = 1, numdevices do
                        -- insert drain lines
                        table.insert(lines, {
                            device = string.format("drain%d", entry),
                        })
                    end
                end
                -- insert source lines
                if _P.equalsourcenets then
                    if _P.multiplesourcelines then
                        for i = 1, numhalflines do
                            table.insert(lines, {
                                device = "source0",
                                variant = numhalflines + i,
                            })
                        end
                    else
                        table.insert(lines, {
                            device = "source0",
                        })
                    end
                else
                    for i = 1, numhalflines do
                        table.insert(lines, {
                            device = string.format("source%d", numhalflines + i),
                        })
                    end
                end
            else -- "source_inside"
                for i = 1, numhalflines do
                    -- insert drain lines
                    table.insert(lines, {
                        device = string.format("drain%d", i),
                    })
                end
                -- insert source lines
                if _P.equalsourcenets then
                    if _P.multiplesourcelines then
                        for i = 1, numdevices do
                            table.insert(lines, {
                                device = "source0",
                                variant = i,
                            })
                        end
                    else
                        table.insert(lines, {
                            device = "source0",
                        })
                    end
                else
                    for i = 1, numhalflines do
                        table.insert(lines, {
                            device = string.format("source%d", i),
                        })
                    end
                end
                for i = 1, numhalflines do
                    -- insert drain lines
                    table.insert(lines, {
                        device = string.format("drain%d", numhalflines + i),
                    })
                end
            end
        else
            for i = 1, numdevices do
                -- insert drain lines
                table.insert(lines, {
                    device = string.format("drain%d", i),
                })
                -- insert source lines
                if _P.equalsourcenets then
                    table.insert(lines, {
                        device = "source0",
                        variant = i,
                    })
                else
                    table.insert(lines, {
                        device = string.format("source%d", i),
                    })
                end
            end
        end
        -- insert gate lines
        if numrows > 2 or _P.insertglobalgateline then
            if _P.equalgatenets then
                if _P.globalgatelinesincenter then
                    table.insert(lines, #lines // 2 + 1, {
                        device = "gate0",
                    })
                else
                    table.insert(lines, 1, {
                        device = "gate0left",
                    })
                    table.insert(lines, {
                        device = "gate0right",
                    })
                end
            else
                local numgatelines
                if _P.usegateconnections then
                    numgatelines = #_P.gateconnections
                else
                    numgatelines = numdevices
                end
                local currentnumlines = #lines
                for i = 1, numgatelines do
                    if _P.globalgatelinesincenter then
                        table.insert(lines, currentnumlines // 2 + i, {
                            device = string.format("gate%d", i),
                        })
                    else
                        table.insert(lines, 1, {
                            device = string.format("gate%dleft", i),
                        })
                        table.insert(lines, {
                            device = string.format("gate%dright", i),
                        })
                    end
                end
            end
        end
        local numlines = #lines
        local space = util.fit_lines_width_grid(targetwidth, _P.outputlinewidth, numlines, technology.get_grid())
        for lineindex, line in ipairs(lines) do
            local identifier
            local netname
            if line.variant then
                netname = string.format("%s_%d", line.device, line.variant)
            else
                netname = string.format("%s", line.device)
            end
            local identifier = string.format("outputconnectline_%s", netname)
            cell:add_area_anchor_bltr(identifier,
                point.create(
                    cell:get_alignment_anchor("outerbl"):getx() + outputline_center - (numlines * _P.outputlinewidth + (numlines - 1) * space) / 2 + (lineindex - 1) * (space + _P.outputlinewidth),
                    outputlineminy - _P.outputlinebotextend
                ),
                point.create(
                    cell:get_alignment_anchor("outerbl"):getx() + outputline_center - (numlines * _P.outputlinewidth + (numlines - 1) * space) / 2 + _P.outputlinewidth + (lineindex - 1) * (space + _P.outputlinewidth),
                    outputlinemaxy + _P.outputlinetopextend
                )
            )
            geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal + 1),
                cell:get_area_anchor(identifier).bl,
                cell:get_area_anchor(identifier).tr
            )
            cell:add_area_anchor_bltr(netname,
                cell:get_area_anchor(identifier).bl,
                cell:get_area_anchor(identifier).tr
            )
        end
    else -- "local"
        for rownum = 1, numrows do
            local devices = _get_active_devices(function(device) return device.row == rownum end)
            for column, device in ipairs(devices) do
                -- get the targetwidth from the alignmentboxes, so that the global line array is continuous
                local outertargetwidth = point.xdistance_abs(
                    cell:get_area_anchor_fmt("outeralignmentbox_%d_%d", rownum, column).bl,
                    cell:get_area_anchor_fmt("outeralignmentbox_%d_%d", rownum, column).tr
                )
                local innertargetwidth = point.xdistance_abs(
                    cell:get_area_anchor_fmt("inneralignmentbox_%d_%d", rownum, column).bl,
                    cell:get_area_anchor_fmt("inneralignmentbox_%d_%d", rownum, column).tr
                )
                local targetwidth = 0.5 * (outertargetwidth + innertargetwidth)
                local outputline_center = 0.5 * outertargetwidth
                local lines = {}
                -- insert drain lines
                for i = 1, numdevices do
                    table.insert(lines, string.format("drain%d", i))
                end
                -- insert source lines
                if _P.equalsourcenets then
                    table.insert(lines, "source0")
                else
                    for i = 1, numdevices do
                        table.insert(lines, string.format("drain%d", i))
                    end
                end
                local numlines = #lines
                local space
                if _P.spreadoutputlines then
                    space = divevendown(targetwidth - numlines * _P.outputlinewidth, numlines)
                else
                    space = _P.outputlinespace
                end
                for lineindex, linelabel in ipairs(lines) do
                    cell:add_area_anchor_bltr(string.format("outputconnectline_%d_%d_%s", rownum, column, linelabel),
                        point.create(
                            cell:get_area_anchor_fmt("outeralignmentbox_%d_%d", rownum, column).l + outputline_center - (numlines * _P.outputlinewidth + (numlines - 1) * space) / 2 + (lineindex - 1) * (space + _P.outputlinewidth),
                            cell:get_area_anchor_fmt("outeralignmentbox_%d_%d", rownum, column).b
                        ),
                        point.create(
                            cell:get_area_anchor_fmt("outeralignmentbox_%d_%d", rownum, column).l + outputline_center - (numlines * _P.outputlinewidth + (numlines - 1) * space) / 2 + _P.outputlinewidth + (lineindex - 1) * (space + _P.outputlinewidth),
                            cell:get_area_anchor_fmt("outeralignmentbox_%d_%d", rownum, column).t
                        )
                    )
                    geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal + 1),
                        cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, column, linelabel).bl,
                        cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, column, linelabel).tr
                    )
                    -- FIXME: net anchor
                end
            end
        end
    end

    -- connect gate lines (on the same net) to output lines
    if _P.gatelinemetal ~= _P.interconnectmetal + 1 then
        if numrows > 2 or _P.insertglobalgateline then
            if _P.outputlinemode == "global" then
                if _P.equalgatenets then
                    for rownum = 1, math.floor((numrows + 1) / 2) do
                        if _P.globalgatelinesincenter then
                            geometry.viabarebltrov(cell, _P.gatelinemetal, _P.interconnectmetal + 1,
                                cell:get_area_anchor_fmt("gateline_%d", rownum).bl,
                                cell:get_area_anchor_fmt("gateline_%d", rownum).tr,
                                cell:get_area_anchor_fmt("outputconnectline_%s", "gate0").bl,
                                cell:get_area_anchor_fmt("outputconnectline_%s", "gate0").tr
                            )
                        else
                            geometry.viabarebltrov(cell, _P.gatelinemetal, _P.interconnectmetal + 1,
                                cell:get_area_anchor_fmt("gateline_%d", rownum).bl,
                                cell:get_area_anchor_fmt("gateline_%d", rownum).tr,
                                cell:get_area_anchor_fmt("outputconnectline_%s", "gate0left").bl,
                                cell:get_area_anchor_fmt("outputconnectline_%s", "gate0left").tr
                            )
                            geometry.viabarebltrov(cell, _P.gatelinemetal, _P.interconnectmetal + 1,
                                cell:get_area_anchor_fmt("gateline_%d", rownum).bl,
                                cell:get_area_anchor_fmt("gateline_%d", rownum).tr,
                                cell:get_area_anchor_fmt("outputconnectline_%s", "gate0right").bl,
                                cell:get_area_anchor_fmt("outputconnectline_%s", "gate0right").tr
                            )
                        end
                    end
                else
                    --[[
                    local numgatelines
                    if _P.usegateconnections then
                        numgatelines = #_P.gateconnections
                    else
                        numgatelines = numdevices
                    end
                    --]]
                    for rownum = 1, math.floor((numrows + 1) / 2) do
                        local devindices = _get_uniq_row_devices(rownum)
                        local lines = {}
                        for _, di in ipairs(devindices) do
                            local index = _map_device_index_to_gate(di)
                            if not util.any_of(index, lines) then
                                table.insert(lines, index)
                            end
                        end
                        local numlines = #lines
                        for line, index in ipairs(lines) do
                            if _P.globalgatelinesincenter then
                                geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).bl,
                                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).tr,
                                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("gate%d", index)).bl,
                                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("gate%d", index)).tr
                                )
                            else
                                geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).bl,
                                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).tr,
                                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("gate%dleft", index)).bl,
                                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("gate%dleft", index)).tr
                                )
                                geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).bl,
                                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).tr,
                                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("gate%dright", index)).bl,
                                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("gate%dright", index)).tr
                                )
                            end
                        end
                    end
                end
            else -- "local"
                --[[
                for rownum = 1, numrows do
                    local devices = _get_active_devices(function(device) return device.row == rownum end)
                    for _, device in ipairs(devices) do
                        geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).bl,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).tr,
                            cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, device.column, string.format("drain%d", device.device)).bl,
                            cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, device.column, string.format("drain%d", device.device)).tr
                        )
                    end
                end
                --]]
            end
        end
    end

    -- connect interconnect lines (source) to output lines
    if not _P.usesourcestraps then
        if _P.equalsourcenets then
            if _P.outputlinemode == "global" then
                for rownum = 1, numrows do
                    local devices = _get_active_devices(function(device) return device.row == rownum end)
                    -- FIXME: if #devices > 0 or _P.connectdummiestosource0line
                    if #devices > 0 then -- ignore dummy-only rows
                        if _P.multiplesourcelines then
                            for i = 1, numdevices do -- iterate over variants
                                geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").bl,
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").tr,
                                    cell:get_area_anchor_fmt("outputconnectline_%s_%d", "source0", i).bl,
                                    cell:get_area_anchor_fmt("outputconnectline_%s_%d", "source0", i).tr
                                )
                            end
                        else
                            geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").bl,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").tr,
                                cell:get_area_anchor_fmt("outputconnectline_%s", "source0").bl,
                                cell:get_area_anchor_fmt("outputconnectline_%s", "source0").tr
                            )
                        end
                    end
                end
            else -- _P.outputlinemode == "local"
                for rownum = 1, numrows do
                    local devices = _get_active_devices(function(device) return device.row == rownum end)
                    for _, device in ipairs(devices) do
                        geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").bl,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, "source0").tr,
                            cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, device.column, "source0").bl,
                            cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, device.column, "source0").tr
                        )
                    end
                end
            end
        else -- not _P.equalsourcenets
            if _P.outputlinemode == "global" then
                for rownum = 1, numrows do
                    local devices = _get_active_devices(function(device) return device.row == rownum end)
                    for _, device in ipairs(devices) do
                        geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).bl,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).tr,
                            cell:get_area_anchor_fmt("outputconnectline_%s", string.format("source%d", device.device)).bl,
                            cell:get_area_anchor_fmt("outputconnectline_%s", string.format("source%d", device.device)).tr
                        )
                    end
                end
            else -- "local"
                for rownum = 1, numrows do
                    local devices = _get_active_devices(function(device) return device.row == rownum end)
                    for _, device in ipairs(devices) do
                        geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).bl,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", device.device)).tr,
                            cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, device.column, string.format("source%d", device.device)).bl,
                            cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, device.column, string.format("source%d", device.device)).tr
                        )
                    end
                end
            end
        end
    else -- _P.usesourcestraps
        if _P.equalsourcenets then
            for rownum = 1, numrows do
                local alldevices = _get_devices(function(device) return device.row == rownum end)
                local leftdevice = alldevices[1]
                local rightdevice = alldevices[numinstancesperrow]
                if not _P.groupoutputlines and _P.multiplesourcelines then
                    for i = 1, numdevices do -- iterate over variants
                        geometry.viabltr(cell, _P.sourcemetal, _P.interconnectmetal + 1,
                            point.create(
                                cell:get_area_anchor_fmt("outputconnectline_%s_%d", "source0", i).l,
                                _get_dev_anchor(leftdevice, "sourcestrap").b
                            ),
                            point.create(
                                cell:get_area_anchor_fmt("outputconnectline_%s_%d", "source0", i).r,
                                _get_dev_anchor(rightdevice, "sourcestrap").t
                            )
                        )
                    end
                else
                    geometry.viabltr(cell, _P.sourcemetal, _P.interconnectmetal + 1,
                        point.create(
                            cell:get_area_anchor_fmt("outputconnectline_%s", "source0").l,
                            _get_dev_anchor(leftdevice, "sourcestrap").b
                        ),
                        point.create(
                            cell:get_area_anchor_fmt("outputconnectline_%s", "source0").r,
                            _get_dev_anchor(rightdevice, "sourcestrap").t
                        )
                    )
                end
            end
        else -- not _P.equalsourcenets
            if _P.outputlinemode == "local" then
                -- FIXME: implement
            else
                -- this can not be reliable connected, hence it is caught in check()
            end
        end
    end

    -- connect interconnect lines (drains) to output lines
    if _P.outputlinemode == "global" then
        for rownum = 1, numrows do
            local devices = _get_active_devices(function(device) return device.row == rownum end)
            for _, device in ipairs(devices) do
                geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).bl,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).tr,
                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("drain%d", device.device)).bl,
                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("drain%d", device.device)).tr
                )
            end
        end
    else -- "local"
        for rownum = 1, numrows do
            local devices = _get_active_devices(function(device) return device.row == rownum end)
            for _, device in ipairs(devices) do
                geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).bl,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).tr,
                    cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, device.column, string.format("drain%d", device.device)).bl,
                    cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, device.column, string.format("drain%d", device.device)).tr
                )
            end
        end
    end

    -- optionally connect gates lines to output lines
    if _P.gatelinemetal ~= _P.interconnectmetal + 1 then
        for _, connection in ipairs(_P.connectgatetosourcedrain) do
            if _P.outputlinemode == "global" then
                if _P.equalgatenets then
                    for rownum = 1, math.floor((numrows + 1) / 2) do
                        geometry.viabarebltrov(cell, _P.gatelinemetal, _P.interconnectmetal + 1,
                            cell:get_area_anchor_fmt("gateline_%d", rownum).bl,
                            cell:get_area_anchor_fmt("gateline_%d", rownum).tr,
                            cell:get_area_anchor_fmt("outputconnectline_%s", connection.target).bl,
                            cell:get_area_anchor_fmt("outputconnectline_%s", connection.target).tr
                        )
                    end
                else
                    for rownum = 1, math.floor((numrows + 1) / 2) do
                        local devices = _get_active_devices(function(device) return device.row == rownum end)
                        for _, device in ipairs(devices) do
                            geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                                cell:get_area_anchor_fmt("gateline_%d_%d", rownum, connection.gate).bl,
                                cell:get_area_anchor_fmt("gateline_%d_%d", rownum, connection.gate).tr,
                                cell:get_area_anchor_fmt("outputconnectline_%s", connection.target).bl,
                                cell:get_area_anchor_fmt("outputconnectline_%s", connection.target).tr
                            )
                        end
                    end
                end
            else -- "local"
                --[[
                for rownum = 1, numrows do
                    local devices = _get_active_devices(function(device) return device.row == rownum end)
                    for _, device in ipairs(devices) do
                        geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).bl,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).tr,
                            cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, device.column, string.format("drain%d", device.device)).bl,
                            cell:get_area_anchor_fmt("outputconnectline_%d_%d_%s", rownum, device.column, string.format("drain%d", device.device)).tr
                        )
                    end
                end
                --]]
            end
        end
    end

    -- add source nets to output lines
    if _P.equalsourcenets then
        if _P.outputlinemode == "global" then
            for i = 1, numdevices do
                if _P.sourcenets[1] then
                    cell:add_net_shape(_P.sourcenets[1],
                        cell:get_area_anchor_fmt("outputconnectline_source0_%d", i).bl,
                        cell:get_area_anchor_fmt("outputconnectline_source0_%d", i).tr
                    )
                end
            end
        else -- "local"
            -- FIXME
        end
    else
        if _P.outputlinemode == "global" then
            for i = 1, numdevices do
                if _P.sourcenets[i] then
                    cell:add_net_shape(_P.sourcenets[i],
                        cell:get_area_anchor_fmt("outputconnectline_source%d", i).bl,
                        cell:get_area_anchor_fmt("outputconnectline_source%d", i).tr
                    )
                end
            end
        else -- "local"
            -- FIXME
        end
    end

    -- add drain nets to output lines
    if _P.outputlinemode == "global" then
        for i = 1, numdevices do
            if _P.drainnets[i] then
                cell:add_net_shape(_P.drainnets[i],
                    cell:get_area_anchor_fmt("outputconnectline_drain%d", i).bl,
                    cell:get_area_anchor_fmt("outputconnectline_drain%d", i).tr
                )
            end
        end
    else -- "local"
        -- FIXME
    end

    -- outer guardring
    if _P.drawouterguardring then
        local active = cell:get_area_anchor("active_all")
        local holewidth = point.xdistance_abs(active.bl, active.tr)
        local holeheight = point.ydistance_abs(active.bl, active.tr)
        local guardring = pcell.create_layout("auxiliary/guardring", "guardring", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            ringwidth = _P.guardringwidth,
            holewidth = holewidth + guardringxsep + guardringxsep,
            holeheight = holeheight + guardringysep + guardringysep,
            fillwell = _P.guardringfillwell,
            fillinnerimplant = _P.guardringfillimplant,
            innerimplantpolarity = _P.channeltype == "nmos" and "n" or "p",
            drawoxidetype = _P.guardringdrawoxidetype,
            filloxidetype = _P.guardringfilloxidetype,
            oxidetype = _P.guardringoxidetype,
            wellinnerextension = _P.guardringwellinnerextension,
            wellouterextension = _P.guardringwellouterextension,
            implantinnerextension = _P.guardringimplantinnerextension,
            implantouterextension = _P.guardringimplantouterextension,
            soiopeninnerextension = _P.guardringsoiopeninnerextension,
            soiopenouterextension = _P.guardringsoiopenouterextension,
        })
        guardring:move_point(guardring:get_area_anchor("innerboundary").bl, active.bl)
        guardring:translate(-guardringxsep, -guardringysep)
        cell:merge_into(guardring)
        cell:add_area_anchor_bltr("outerguardring",
            guardring:get_area_anchor("outerboundary").bl,
            guardring:get_area_anchor("outerboundary").tr
        )
        cell:add_area_anchor_bltr("innerguardring",
            guardring:get_area_anchor("innerboundary").bl,
            guardring:get_area_anchor("innerboundary").tr
        )
    end
end
