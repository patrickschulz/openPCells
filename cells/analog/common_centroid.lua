function parameters()
    pcell.add_parameters(
        { "pattern", { { 1, 2, 1 }, { 2, 1, 2 } } },
        { "channeltype", "nmos" },
        { "vthtype", 1 },
        { "oxidetype", 1 },
        { "flippedwell", false },
        { "fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "sourcedrainsize", technology.get_dimension("Minimum Gate Width"), follow = "fingerwidth" },
        { "xseparation", 0 },
        { "gatelength",  technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space") },
        { "matchgateextensions", true },
        { "gatemetal",  1 },
        { "gatelinemetal",  2 },
        { "usesourcestraps", false },
        { "sourcestrapsinside", false },
        { "usedrainstraps", false },
        { "drainmetal",  1 },
        { "interconnectmetal", 2 },
        { "sourcemetal", 1 },
        { "equalsourcenets", true },
        { "multiplesourcelines", true },
        { "sdwidth", technology.get_dimension("Minimum Source/Drain Contact Region Size") },
        { "sdm1ext", 0 },
        { "fingers", 2, posvals = even() },
        { "gatestrapwidth", technology.get_dimension("Minimum Gate Contact Region Size") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "gatestrapleftext", 0 },
        { "gatestraprightext", 0 },
        { "gatefeedlinewidth", technology.get_dimension("Minimum M1 Width") },
        { "gatelinewidth", technology.get_dimension("Minimum M2 Width") },
        { "gatelinespace", technology.get_dimension("Minimum M2 Space") },
        { "gatelineviawidth", technology.get_dimension("Minimum M1M2 Viawidth") },
        { "gatelineviapitch", 0 },
        { "fullgatevia", false },
        { "extendgatessymmetrically", false },
        { "allow_unequal_rowshifts", false },
        { "usegateconnections", false },
        { "gateconnections", {} }, -- FIXME: this should be nil, but due to how parameters are handled internally, this is currently not supported
        { "usesourceconnections", false },
        { "sourceconnections", {} }, -- FIXME: this should be nil, but due to how parameters are handled internally, this is currently not supported
        { "interconnectlinepos", "offside", posvals = set("offside", "gate", "inline") },
        { "spreadinterconnectlines", true },
        { "interconnectlinewidth", technology.get_dimension("Minimum M2 Width") },
        { "interconnectlinespace", technology.get_dimension("Minimum M2 Space") },
        { "interconnectlineviawidth", technology.get_dimension("Minimum M1M2 Viawidth") },
        { "interconnectviapitch", technology.get_optional_dimension("Minimum M2 Pitch") },
        { "spreadoutputlines", true },
        { "outputlinewidth", technology.get_dimension("Minimum M3 Width") },
        { "outputlinespace", technology.get_dimension("Minimum M3 Space") },
        { "gateoutputlinewidth", technology.get_dimension("Minimum M3 Width"), follow = "outputlinewidth" },
        { "sourceoutputlinewidth", technology.get_dimension("Minimum M3 Width"), follow = "outputlinewidth" },
        { "drainoutputlinewidth", technology.get_dimension("Minimum M3 Width"), follow = "outputlinewidth" },
        { "guardringoutputlinewidth", technology.get_dimension("Minimum M3 Width"), follow = "outputlinewidth" },
        { "outputlinetopextend", 0 },
        { "outputlinebotextend", 0 },
        { "insertglobalgatelines", false },
        { "globalgatelinesincenter", true },
        { "connectsourcesonbothsides", false },
        { "sourcedrainstrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "sourcedrainstrapspace", technology.get_dimension("Minimum M1 Space") },
        { "equalgatenets", false },
        { "shortgates", false },
        { "gatestrapsincenter", false },
        { "connectgatesonbothsides", false },
        { "groupoutputlines", false },
        { "grouporder", "drain_inside", posvals = set("drain_inside", "source_inside") },
        { "usegloballines", false },
        { "globallines", {} },
        { "sourcenets", {} }, -- FIXME: this should be nil, but due to how parameters are handled internally, this is currently not supported
        { "drainnets", {} }, -- FIXME: this should be nil, but due to how parameters are handled internally, this is currently not supported
        { "connectgatetosourcedrain", {} }, -- FIXME: this should be nil, but due to how parameters are handled internally, this is currently not supported
        { "diodeconnected", {} },
        { "shortdummies", false, follow = "drawinnerguardrings" },
        { "outerdummies", 0 },
        { "outerdummygatelength", 500, follow = "gatelength" }, -- FIXME: basic/stacked_mosfet_array does not support this
        { "connectdummygatestoactive", false },
        { "connectdummies", true },
        { "connectdummysources", true },
        { "connectdummiestointernalnet", false },
        { "allow_single_device", false },
        { "extendalltop", 0 },
        { "extendallbottom", 0 },
        { "extendallleft", 0 },
        { "extendallright", 0 },
        { "drawinnerguardrings", false },
        { "drawouterguardring", false },
        { "guardringwidth", technology.get_dimension("Minimum Active Contact Region Size") },
        { "guardringminxsep", technology.get_dimension_max("Minimum Active Space", "Minimum M1 Space") },
        { "guardringminysep", technology.get_dimension_max("Minimum Active Space", "Minimum M1 Space") },
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
        { "guardringoxidetypeouterextension", technology.get_dimension("Minimum Oxide Extension") },
        { "insertglobalguardringlines", false },
        { "connectguardringtogloballines", false, follow = "insertglobalguardringlines" },
        { "guardringnet", "" },
        { "annotate_lines", false },
        { "annotate_gatelines", false, follow = "annotate_lines" },
        { "annotate_interconnectlines", false, follow = "annotate_lines" },
        { "annotate_globallines", false, follow = "annotate_lines" },
        { "lines_label_sizehint", technology.get_optional_dimension("Default Label Size") },
        { "gatelines_label_sizehint", technology.get_optional_dimension("Default Label Size"), follow = "lines_label_sizehint" },
        { "interconnectlines_label_sizehint", technology.get_optional_dimension("Default Label Size"), follow = "lines_label_sizehint" },
        { "globallines_label_sizehint", technology.get_optional_dimension("Default Label Size"), follow = "lines_label_sizehint" },
        { "instancename", nil },
        { "instancelabelsizehint", technology.get_optional_dimension("Default Label Size") }
    )
end

function process_parameters(_P)
    local t = {}
    t.gatefeedlinewidth = technology.get_dimension(string.format("Minimum M%d Width", _P.gatemetal))
    if _P.gatelinemetal > 1 then
        t.gatelinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.gatelinemetal - 1, _P.gatelinemetal))
    else
        t.gatelinewidth = technology.get_dimension("Minimum M1 Width")
    end
    if _P.gatelinemetal > 1 then
        t.gatelineviawidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.gatelinemetal - 1, _P.gatelinemetal))
    end
    if _P.interconnectmetal > 1 then
        t.interconnectlinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal - 1, _P.interconnectmetal))
    else
        t.interconnectlinewidth = technology.get_dimension("Minimum M1 Width")
    end
    t.outputlinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1))
    t.gateoutputlinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1))
    t.sourceoutputlinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1))
    t.drainoutputlinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1))
    t.guardringoutputlinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1))
    return t
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

    -- check whether devices are specified continuously
    local devices = {}
    for device = 1, numdevices do
        for _, row in ipairs(_P.pattern) do
            if util.any_of(device, row) then
                devices[device] = true
            end
        end
        if not devices[device] then
            return false, "devices must be specified continuously, starting at 1"
        end
    end

    if numdevices < 2 and not _P.allow_single_device then
        return false, "the array must contain more than one active device (unless 'allow_single_device' is true)"
    end

    if _P.equalgatenets and _P.usegateconnections then
        return false, "'equalgatenets' and 'usegateconnections' must not be true at the same time"
    end

    if _P.shortgates and not _P.equalgatenets then
        return false, "gates can not be shorted ('shortgates' == true) when gate nets are not equal ('equalgatenets' == false)"
    end

    if _P.equalsourcenets and _P.usesourceconnections then
        return false, "'equalsourcenets' and 'usesourceconnections' must not be true at the same time"
    end

    -- copied from layout(), there might be a better (but still convenient) way
    -- I don't want to pass all parameters, hence this should be a closure
    local function _map_device_index_to_source(device)
        if _P.equalsourcenets then
            return 1
        elseif _P.usesourceconnections then
            for i, entry in ipairs(_P.sourceconnections) do
                if util.any_of(device, entry) then
                    return i
                end
            end
        else
            return device
        end
        -- should not reach here
        -- FIXME: implement check in check()
        cellerror(string.format("common_centroid: source lookup with unknown device/configuration (device: %d, configuration: equalsourcenets = %s, usesourceconnections = %s)", device, _P.equalsourcenets and "true" or "false", _P.usesourceconnections and "true" or "false"))
    end

    local sourceconnections = {}
    if _P.equalsourcenets then
    elseif _P.usesourceconnections then
        for _, net in ipairs(util.uniq(util.foreach(util.range(1, numdevices), _map_device_index_to_source))) do
            table.insert(sourceconnections, i)
        end
    else -- regular source nets
        for i = 1, numdevices do
            table.insert(sourceconnections, i)
        end
    end

    -- gather nets for later checks
    local nets = {
        gate = {},
        drain = {},
        source = {},
    }
    -- insert source nets
    for _, net in ipairs(util.uniq(util.foreach(util.range(1, numdevices), _map_device_index_to_source))) do
        table.insert(nets.source, net)
    end
    -- insert drain nets
    for i = 1, numdevices do
        table.insert(nets.drain, i)
    end
    -- insert gate nets
    if _P.equalgatenets then
        table.insert(nets.gate, 1)
    else
        if _P.usegateconnections then
            for i = 1, #_P.gateconnections do
                table.insert(nets.gate, i)
            end
        else
            for i = 1, numdevices do
                table.insert(nets.gate, i)
            end
        end
    end

    -- check for unspecified gate connections
    if _P.usegateconnections then
        for i = 1, numdevices do
            local found = false
            for _, connections in ipairs(_P.gateconnections) do
                for _, entry in ipairs(connections) do
                    if i == entry then
                        found = true
                    end
                end
            end
            if not found then
                return false, string.format("when gate connections are used, every gate connection must be specified. Missing gate connection: %d", i)
            end
        end
    end

    -- check for unspecified source connections
    if _P.usesourceconnections then
        for i = 1, numdevices do
            local found = false
            for _, connections in ipairs(_P.sourceconnections) do
                for _, entry in ipairs(connections) do
                    if i == entry then
                        found = true
                    end
                end
            end
            if not found then
                return false, string.format("when source connections are used, every source connection must be specified. Missing source connection: %d", i)
            end
        end
    end

    -- common centroid makes no sense for only one device
    if numdevices < 2 then
        return false, "the pattern definition does not contain more than one device"
    end

    if _P.connectdummygatestoactive and not _P.equalgatenets then
        return false, "if gate straps are in the center, all gates have to be on the same net (equalgatenets == true)"
    end
    if _P.connectdummygatestoactive and not _P.equalgatenets then
        return false, "if dummy gates are connected to active gates, all gates have to be on the same net (equalgatenets == true)"
    end
    if not _P.connectdummygatestoactive and _P.connectgatesonbothsides and (_P.outerdummies > 0) then
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
    if _P.gatemetal == _P.interconnectmetal + 1 then
        return false, "the drain metal can not be on the same layer as the output line metal"
    end
    if _P.interconnectlinepos == "offside" and _P.drainmetal == _P.interconnectmetal then
        return false, "the drain metal can not be on the same layer as the interconncect line metal"
    end
    if _P.interconnectlinepos == "offside" and _P.sourcemetal == _P.interconnectmetal then
        return false, "the source metal can not be on the same layer as the interconncect line metal"
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
    -- rudimentary check that the table is formatted properly
    -- should catch errors like connectgatetosourcedrain = { gate = 1, target = "drain2" } (missing surrounding braces)
    for k, v in pairs(_P.connectgatetosourcedrain) do
        if type(k) == "string" then
            return false, "the 'connectgatetosourcedrain' table is not formatted properly, did you forget surrounding braces?"
        end
    end
    -- check that no shorted dummies are present if gates are shorted
    if _P.shortgates and _P.shortdummies and hasdummies then
        return false, "shorted dummies (with dummies present) are not allowed if gates are shorted"
    end

    -- connect interconnect lines (source) to output lines
    if _P.usesourcestraps then
        local numsources = #util.uniq(util.foreach(util.range(1, numdevices), _map_device_index_to_source))
        if numsources > 1 then
            return false, "when source straps with non-equal source nets are used, the sources can't reliably be connected by output lines. Use source interconnect lines"
        end
    end

    -- check that all nets are present in globallines
    if _P.usegloballines then
        for _, pin in ipairs({ "gate", "drain", "source" }) do
            local pinnettable = util.clone_array_predicate(_P.globallines, function(entry) return entry.pin == pin end)
            local pnets = util.foreach(pinnettable, function(e) return e.net end)
            for _, net in ipairs(nets[pin]) do
                if not util.any_of(net, pnets) then
                    if pin ~= "gate" or #_P.pattern > 2 then
                        return false, string.format("when global line nets are specified manually ('usegloballines'), all required nets must be present in 'globallines'. Missing net: '%s%d'", pin, net)
                    end
                end
            end
            for _, net in ipairs(pnets) do
                if not util.any_of(net, nets[pin]) then
                    return false, string.format("when global line nets are specified manually ('usegloballines'), only the required nets must be present in 'globallines'. Specified unknown net net: '%s%d'", pin, net)
                end
            end
        end
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
    local numdevicespersinglerow = {} -- total number of devices in a row (e.g. ABBBBA   -> 2
                                      --                                        CAABBC   -> 3
                                      --                                        CAABBC   -> 3
                                      --                                        ABBBBA   -> 2)
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
        numdevicespersinglerow[i] = count
    end
    local maxnumdevicespersinglerow = 0
    for rownum = 1, #numdevicespersinglerow do
        maxnumdevicespersinglerow = math.max(maxnumdevicespersinglerow, #util.uniq(activepattern[rownum]))
    end
    -- the maximum of different devices in a double row
    local numdevicesperdoublerow = {}
    for rownum = 1, #numdevicespersinglerow - 1, 2 do
        numdevicesperdoublerow[rownum] = #util.uniq(util.merge_tables(activepattern[rownum], activepattern[rownum + 1]))
    end

    local function _map_device_index_to_gate(device)
        if _P.equalgatenets then
            return 1
        elseif _P.usegateconnections then
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

    local function _map_device_index_to_source(device)
        if _P.equalsourcenets then
            return 1
        elseif _P.usesourceconnections then
            for i, entry in ipairs(_P.sourceconnections) do
                if util.any_of(device, entry) then
                    return i
                end
            end
        else
            return device
        end
        -- should not reach here
        -- FIXME: implement check in check()
        cellerror(string.format("common_centroid: source lookup with unknown device/configuration (device: %d, configuration: equalsourcenets = %s, usesourceconnections = %s)", device, _P.equalsourcenets and "true" or "false", _P.usesourceconnections and "true" or "false"))
    end

    -- calculate required minimum row space for every row
    -- every row gets their own source/drain lines, gate lines are shared between two rows ('doublerow')
    -- as gate lines are shared, they are referenced to the lower row, so all odd rows
    -- FIXME: this calculation has 'offside' placement of interconnect lines in mind, check/fix for other placement methods
    local rowshifts = {}
    rowshifts[1] = 0
    for row = 2, numrows do -- skip first row, no shift needed
        if row % 2 == 0 then -- gate line row shifts only apply to even rows
            local doublerowdevices = util.merge_tables(activepattern[row - 1], activepattern[row])
            local numgates = #util.uniq(util.foreach(doublerowdevices, _map_device_index_to_gate))
            local gateline_space_occupation =
                2 * _P.gatestrapspace + 2 * _P.gatestrapwidth
                + (numgates + 1) * _P.gatelinespace + numgates * _P.gatelinewidth
            if _P.usesourcestraps and _P.sourcestrapsinside then
                gateline_space_occupation = gateline_space_occupation + 2 * (_P.sourcedrainstrapwidth + _P.sourcedrainstrapspace)
            end
            rowshifts[row] = gateline_space_occupation
        else -- odd row
            local lowerrowdevices = activepattern[row - 1]
            local numlowersourcelines
            if _P.usesourcestraps then
                numlowersourcelines = 0
            else
                numlowersourcelines = #util.uniq(util.foreach(lowerrowdevices, _map_device_index_to_source))
            end
            local numlowerdrainlines = #util.uniq(lowerrowdevices)
            local numlowerlines = numlowersourcelines + numlowerdrainlines
            local upperrowdevices = activepattern[row]
            local numuppersourcelines
            if _P.usesourcestraps then
                numuppersourcelines = 0
            else
                numuppersourcelines = #util.uniq(util.foreach(upperrowdevices, _map_device_index_to_source))
            end
            local numupperdrainlines = #util.uniq(upperrowdevices)
            local numupperlines = numuppersourcelines + numupperdrainlines
            local interconnectline_space_occupation = - _P.interconnectlinespace -- correct for one additional space
                + (numlowerlines + 1) * _P.interconnectlinespace + numlowerlines * _P.interconnectlinewidth
                + (numupperlines + 1) * _P.interconnectlinespace + numupperlines * _P.interconnectlinewidth
            rowshifts[row] = interconnectline_space_occupation
        end
    end
    local maxrowshift = util.max(rowshifts)
    if not _P.allow_unequal_rowshifts then
        for row = 1, numrows do
            rowshifts[row] = maxrowshift
        end
    end

    -- outer row interconnectlines space occupation, needed for guardring separation calculation
    -- not needed for shifting rows (ignored by stacked_mosfet_array anyway), but for calculating guardring y hole extension
    local firstrowinterconnectline_space_occupation = 0
    local lastrowinterconnectline_space_occupation = 0
    do
        local firstrowdevices = activepattern[1]
        local numsourcelines
        if _P.usesourcestraps then
            numsourcelines = 0
        else
            numsourcelines = #util.uniq(util.foreach(firstrowdevices, _map_device_index_to_source))
        end
        local numdrainlines = #util.uniq(firstrowdevices)
        local numlines = numsourcelines + numdrainlines
        local interconnectline_space_occupation = 0 -- no space correction here (as opposed to other odd rows)
            + (numlines + 1) * _P.interconnectlinespace + numlines * _P.interconnectlinewidth
        firstrowinterconnectline_space_occupation = interconnectline_space_occupation
    end
    do
        local lastrowdevices = activepattern[numrows]
        local numsourcelines
        if _P.usesourcestraps then
            numsourcelines = 0
        else
            numsourcelines = #util.uniq(util.foreach(lastrowdevices, _map_device_index_to_source))
        end
        local numdrainlines = #util.uniq(lastrowdevices)
        local numlines = numsourcelines + numdrainlines
        local interconnectline_space_occupation = 0 -- no space correction here (as opposed to other odd rows)
            + (numlines + 1) * _P.interconnectlinespace + numlines * _P.interconnectlinewidth
        lastrowinterconnectline_space_occupation = interconnectline_space_occupation
    end

    -- active extension
    local activegateext
    local inactivegateext
    if _P.matchgateextensions then
        if _P.extendgatessymmetrically then
            if _P.gatestrapsincenter and not _P.drawinnerguardrings then
                activegateext = (yseparation + _P.gatestrapwidth) / 2
                inactivegateext = (yseparation + _P.gatestrapwidth) / 2
            else
                activegateext = _P.gatestrapspace + _P.gatestrapwidth
                inactivegateext = _P.gatestrapspace + _P.gatestrapwidth
            end
        else
            activegateext = _P.gatestrapspace + _P.gatestrapwidth
            inactivegateext = nil
        end
    else
        -- nil to get the default value
        activegateext = nil
        inactivegateext = nil
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
        sourcesize = _P.sourcedrainsize,
        drainsize = _P.sourcedrainsize,
        sourcealign = "center",
        drainalign = "center",
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
        checkshorts = false,
    })

    local dummyoptions = util.add_options(commonoptions, {
        shortwidth = _P.gatestrapwidth,
        shortspace = (_P.gatestrapsincenter and not _P.drawinnerguardrings) and (yseparation - _P.gatestrapwidth) / 2 or _P.gatestrapspace,
        connectsource = _P.usesourcestraps and _P.connectdummysources,
        connectsourceboth = _P.connectdummysources,
        connectdrain = _P.connectdummysources,
        connectdrainboth = _P.connectdummysources,
    })

    -- add outer dummies to pattern
    local pattern = {}
    for _, rowpattern in ipairs(_P.pattern) do
        local row = {}
        -- add outer dummies (left)
        for i = 1, _P.outerdummies do
            table.insert(row, 0)
        end
        -- add active devices
        for _, device in ipairs(rowpattern) do
            table.insert(row, device)
        end
        -- add outer dummies (right)
        for i = 1, _P.outerdummies do
            table.insert(row, 0)
        end
        table.insert(pattern, row)
    end

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
    for rownum, rowpattern in ipairs(pattern) do -- don't use activepattern here as dummies should be generated
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
        return devices
    end

    -- create mosfet array
    local rows = {}
    for rownum = 1, numrows do
        local rowshift = rowshifts[rownum]
        if _P.drawinnerguardrings then
            rowshift = 0
        end
        local row = util.add_options(rowoptions, {
            shift = rowshift,
            gtopext = rownum % 2 == 1 and activegateext or inactivegateext,
            gbotext = rownum % 2 == 0 and activegateext or inactivegateext,
        })
        local devicerow = _get_devices(function(device) return device.row == rownum end)
        row.devices = _make_row_devices(rownum, devicerow)
        table.insert(rows, row)
    end
    local guardringxsep = _P.guardringminxsep
    local innerguardringysep = _P.guardringminysep
    local array = pcell.create_layout("basic/stacked_mosfet_array", "_array", {
        rows = rows,
        drawimplant = not (_P.guardringfillimplant and (_P.drawinnerguardrings or _P.drawouterguardring)),
        drawwell = _P.flippedwell or not (_P.guardringfillwell and (_P.drawinnerguardrings or _P.drawouterguardring)),
        xseparation = _P.xseparation,
        yseparation = 0, -- yseparation is given manually with rowshifts
        autoskip = false,
        splitgates = not _P.shortgates,
        drawguardring = _P.drawinnerguardrings,
        guardringwidth = _P.guardringwidth,
        guardringrespectactivedummies = false,
        guardringrespectgatestraps = false,
        guardringrespectgateextensions = false,
        guardringleftsep = guardringxsep,
        guardringrightsep = guardringxsep,
        guardringtopsep = innerguardringysep,
        guardringbottomsep = innerguardringysep,
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

    -- get current alignment size for placement of global lines
    local obbbl = cell:get_alignment_anchor("outerbl")
    local obbtr = cell:get_alignment_anchor("outertr")
    local ibbbl = cell:get_alignment_anchor("innerbl")
    local ibbtr = cell:get_alignment_anchor("innertr")

    local _get_dev_anchor = function(device, where)
        return cell:get_area_anchor_fmt("M_%d_%d_%d_%s", device.device, device.row, device.index, where)
    end

    local function _get_uniq_row_devices_double(rownum)
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

    -- outer guardring
    local guardring -- needed later for connecting global lines
    if _P.drawouterguardring then
        local active = cell:get_area_anchor("active_all")
        local holewidth_active = point.xdistance_abs(active.bl, active.tr)
        local holeheight_active = point.ydistance_abs(active.bl, active.tr)
        local lowerrowdevices = _get_active_devices(function(device) return device.row == 1 end)
        local upperrowdevices = _get_active_devices(function(device) return device.row == numrows end)
        local lowergateboundingbox = _get_dev_anchor(lowerrowdevices[1], "gateboundingbox")
        local uppergateboundingbox = _get_dev_anchor(upperrowdevices[1], "gateboundingbox")
        local holewidth_gate = point.xdistance_abs(lowergateboundingbox.bl, lowergateboundingbox.tr)
        local holeheight_gate = point.ydistance_abs(lowergateboundingbox.bl, uppergateboundingbox.tr)
        local holewidth = math.max(holewidth_active, holewidth_gate)
        local holeheight = math.max(holeheight_active, holeheight_gate)
        -- FIXME: this works for symmetric arrays, but can be extended easily to support non-symmetric arrays
        local outerguardringysep
        local outerguardringyshift
        if _P.interconnectlinepos == "offside" then
            outerguardringysep = math.max(2 * _P.guardringminysep, firstrowinterconnectline_space_occupation + lastrowinterconnectline_space_occupation)
            outerguardringyshift = 0.5 * (lastrowinterconnectline_space_occupation - firstrowinterconnectline_space_occupation)
        else
            outerguardringysep = 2 * _P.guardringminysep
            outerguardringyshift = 0
        end
        guardring = pcell.create_layout("auxiliary/guardring", "guardring", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            ringwidth = _P.guardringwidth,
            holewidth = holewidth + 2 * guardringxsep,
            holeheight = holeheight + outerguardringysep,
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
        guardring:move_point_x(guardring:get_area_anchor("innerboundary").bl, active.bl)
        guardring:move_point_y(guardring:get_area_anchor("innerboundary").bl, 
            point.create(
                0, -- dont'care
                math.min(active.bl:gety(), lowergateboundingbox.bl:gety())
            )
        )
        guardring:translate(-guardringxsep, -0.5 * outerguardringysep + outerguardringyshift)
        cell:merge_into(guardring)
        cell:add_area_anchor_bltr("outerguardring",
            guardring:get_area_anchor("outerboundary").bl,
            guardring:get_area_anchor("outerboundary").tr
        )
        cell:add_area_anchor_bltr("innerguardring",
            guardring:get_area_anchor("innerboundary").bl,
            guardring:get_area_anchor("innerboundary").tr
        )
        cell:inherit_alignment_box(guardring)
    end

    -- calculate maximum/minimum x coordinates for gate/interconnect lines
    local interconnectlineminx
    local interconnectlinemaxx
    do
        local row1devices = _get_devices(function(device) return device.row == 1 end)
        local leftdevice = row1devices[1]
        local rightdevice = row1devices[#row1devices]
        local icvextension = math.max(_P.interconnectlineviawidth, _P.sdwidth)
        interconnectlineminx = _get_dev_anchor(leftdevice, "sourcedrainmetal1").l - (icvextension - _P.sdwidth) / 2
        interconnectlinemaxx = _get_dev_anchor(rightdevice, "sourcedrainmetal-1").r + (icvextension - _P.sdwidth) / 2
    end

    -- create gate lines
    local gatelines = {}
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
        local devindices = _get_uniq_row_devices_double(rownum)
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
                    interconnectlineminx,
                    _get_dev_anchor(leftlowerdevice, "active").t + gateline_center + yshift - _P.gatelinewidth / 2
                ),
                point.create(
                    interconnectlinemaxx,
                    _get_dev_anchor(rightlowerdevice, "active").t + gateline_center + yshift + _P.gatelinewidth / 2
                )
            )
            geometry.rectanglebltr(cell, generics.metal(_P.gatelinemetal),
                cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).bl,
                cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).tr
            )
            table.insert(gatelines, { rownum = rownum, index = index })
        end
    end

    -- connect gates to gate lines
    if not _P.gatestrapsincenter then
        for rownum = 1, math.floor((numrows + 1) / 2) do
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
                local spread = (lowerdevice and upperdevice) and _map_device_index_to_gate(lowerdevice.device) ~= _map_device_index_to_gate(upperdevice.device)
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
                                ) - _P.gatefeedlinewidth / 2 + shift,
                                cell:get_area_anchor_fmt("gateline_%d_%d", rownum, _map_device_index_to_gate(device.device)).b
                            ),
                            point.create(
                                0.5 * (
                                    _get_dev_anchor(device, string.format("%sgatestrap", gate)).l +
                                    _get_dev_anchor(device, string.format("%sgatestrap", gate)).r
                                ) + _P.gatefeedlinewidth / 2 + shift,
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
                                ),
                                string.format("gate strap via for gate line:\n    x parameters: gatelineviawidth (%d)\n    y parameters: gatestrapwidth (%d)", _P.gatelineviawidth, _P.gatestrapwidth)
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
                            ),
                            string.format("gate strap to gate line conncetion:\n    x parameters: gatelineviawidth (%d)\n    y parameters: gatelinewidth (%d)", _P.gatelineviawidth, _P.gatelinewidth)
                        )
                    end
                end
            end
        end
    end

    -- create interconnect lines
    local interconnectlines = {}
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
            -- add source lines
            if not _P.usesourcestraps then
                local sourcelines = util.uniq(util.foreach(devnums, _map_device_index_to_source))
                for _, num in ipairs(sourcelines) do
                    table.insert(lines, string.format("source%d", num))
                end
            end
            -- add drain lines
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
                table.insert(interconnectlines, { rownum = rownum, net = linelabel })
            end
        end
    elseif _P.interconnectlinepos == "gate" then
        for rownum = 1, math.floor((numrows + 1) / 2) do
            local devindices = _get_uniq_row_devices_double(rownum)
            local doublerowdevices = _get_active_devices(function(device) return device.row == 2 * rownum - 1 or device.row == 2 * rownum end)
            local leftdevice = doublerowdevices[1]
            local rightdevice = doublerowdevices[numinstancesperrow]
            for line, index in ipairs(devindices) do
                local net = string.format("drain%d", index)
                cell:add_area_anchor_bltr(string.format("interconnectline_%d_%s", rownum, net),
                    point.create(
                        interconnectlineminx,
                        _get_dev_anchor(leftdevice, "active").t + _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth + _P.interconnectlinespace + (line - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth)
                    ),
                    point.create(
                        interconnectlinemaxx,
                        _get_dev_anchor(rightdevice, "active").t + _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth + _P.interconnectlinespace + _P.interconnectlinewidth + (line - 1) * (_P.interconnectlinespace + _P.interconnectlinewidth)
                    )
                )
                geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal),
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, net).bl,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, net).tr
                )
                table.insert(interconnectlines, { rownum = rownum, net = net })
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
                -- add source lines
                if not _P.usesourcestraps then
                    local sourcelines = util.uniq(util.foreach(devindices, _map_device_index_to_source))
                    for _, num in ipairs(sourcelines) do
                        table.insert(lines, string.format("source%d", num))
                    end
                end
                -- add drain lines
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
                    table.insert(interconnectlines, { rownum = rownum, net = linelabel })
                end
            end
        end
    end

    -- connect sources to interconnect lines
    if not _P.usesourcestraps then
        if _P.interconnectlinepos == "inline" then
            for rownum = 1, numrows do
                local devices = _get_active_devices(function(device) return device.row == rownum end)
                for _, device in ipairs(devices) do
                    local sourceline = _map_device_index_to_source(device.device)
                    for finger = 1, _P.fingers + 1, 2 do
                        geometry.viabltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).bl,
                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).tr,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).bl,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).tr
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
                    local sourceline = _map_device_index_to_source(device.device)
                    for finger = 1, _P.fingers + 1, 2 do
                        if rownum % 2 == 1 then
                            geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).b
                                ),
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).b
                                )
                            )
                            geometry.viabltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).b
                                ),
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).b
                                ),
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).bl,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).tr
                            )
                        else
                            geometry.rectanglebltr(cell, generics.metal(_P.sourcemetal),
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).t
                                ),
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).t
                                )
                            )
                            geometry.viabltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).l,
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).t
                                ),
                                point.create(
                                    _get_dev_anchor(device, string.format("sourcedrain%d", finger)).r,
                                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).t
                                ),
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).bl,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).tr
                            )
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
                        geometry.viabltrov(cell, _P.drainmetal, _P.interconnectmetal,
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
                    local icvextension = math.max(_P.interconnectlineviawidth, _P.sdwidth)
                    local sdanchor = _get_dev_anchor(device, string.format("sourcedrain%d", finger))
                    local ytop
                    local ybottom
                    if rownum % 2 == 1 then
                        ybottom = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).b
                        ytop = sdanchor.b
                    else
                        ybottom = sdanchor.t
                        ytop = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).t
                    end
                    geometry.rectanglebltr(cell, generics.metal(_P.drainmetal),
                        point.create(sdanchor.l, ybottom),
                        point.create(sdanchor.r, ytop)
                    )
                    if _P.drainmetal ~= _P.interconnectmetal then
                        geometry.viabltrov(cell, _P.drainmetal, _P.interconnectmetal,
                            point.create(
                                0.5 * (sdanchor.l + sdanchor.r) - icvextension / 2,
                                ybottom
                            ),
                            point.create(
                                0.5 * (sdanchor.l + sdanchor.r) + icvextension / 2,
                                ytop
                            ),
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).bl,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).tr,
                            string.format("drain to interconnect line conncetion:\n    x parameters: max of interconnectlineviawidth/sdwidth (%d)\n    y parameters: interconnectlinewidth (%d)", icvextension, _P.interconnectlinewidth)
                        )
                    end
                end
            end
        end
    end

    -- calculate maximum/minimum y coordinates for global lines
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
    if _P.drawouterguardring and _P.insertglobalguardringlines then
        local guardringboundary = cell:get_area_anchor("outerguardring")
        local holeheight = point.ydistance_abs(guardringboundary.bl, guardringboundary.tr)
        local distance = holeheight - (outputlinemaxy - outputlineminy)
        if distance > 0 then
            outputlinemaxy = outputlinemaxy + distance / 2
            outputlineminy = outputlineminy - distance / 2
        end
    end

    -- gather output lines
    local outputlines = {}

    -- get the targetwidth from the alignmentboxes, so that the global line array is continuous
    local outertargetwidth = point.xdistance_abs(obbbl, obbtr)
    local innertargetwidth = point.xdistance_abs(ibbbl, ibbtr)
    local targetwidth = 0.5 * (outertargetwidth + innertargetwidth)

    -- fill output lines table
    if _P.usegloballines then
        -- build variant lookup table
        local variantnum = {}
        for _, entry in ipairs(_P.globallines) do
            local netname = string.format("%s%d", entry.pin, entry.net)
            if not variantnum[netname] then
                variantnum[netname] = 0
            else
                variantnum[netname] = variantnum[netname] + 1
            end
        end
        -- insert lines
        local variantlookup = {}
        for _, entry in ipairs(_P.globallines) do
            local netname = string.format("%s%d", entry.pin, entry.net)
            local variant
            if variantnum[netname] > 0 then
                if not variantlookup[netname] then
                    variantlookup[netname] = 1
                else
                    variantlookup[netname] = variantlookup[netname] + 1
                end
                variant = variantlookup[netname]
            end
            table.insert(outputlines, { base = entry.pin, device = entry.net, variant = variant })
        end
    else -- not _P.usegloballines
        local outputlinespre = {
            source = {},
            drain = {},
            gate = {}
        }
        -- source lines
        local numsourcelines = #util.uniq(util.foreach(util.range(1, numdevices), _map_device_index_to_source))
        for i = 1, numsourcelines do
            table.insert(outputlinespre.source, {
                base = "source",
                device = i,
            })
        end
        -- drain lines
        local numdrainlines = numdevices
        for i = 1, numdrainlines do
            table.insert(outputlinespre.drain, {
                base = "drain",
                device = i,
            })
        end
        -- insert gate lines
        if numrows > 2 or _P.insertglobalgatelines then
            local numgatelines = #util.uniq(util.foreach(util.range(1, numdevices), _map_device_index_to_gate))
            local currentnumlines = #outputlinespre
            for i = 1, numgatelines do
                table.insert(outputlinespre.gate, {
                    base = "gate",
                    device = i,
                })
            end
        end
        if _P.groupoutputlines then
            if _P.grouporder == "drain_inside" then
                local numsourcelines = #outputlinespre.source
                local numsourcelineshalf = numsourcelines // 2
                for i = 1, numsourcelineshalf do
                    table.insert(outputlines, outputlinespre.source[i])
                end
                for _, line in ipairs(outputlinespre.drain) do
                    table.insert(outputlines, line)
                end
                for i = numsourcelineshalf + 1, numsourcelines do
                    table.insert(outputlines, outputlinespre.source[i])
                end
            else -- _P.grouporder == "source_inside"
                local numdrainlines = #outputlinespre.drain
                local numdrainlineshalf = numdrainlines // 2
                for i = 1, numdrainlineshalf do
                    table.insert(outputlines, outputlinespre.drain[i])
                end
                for _, line in ipairs(outputlinespre.source) do
                    table.insert(outputlines, line)
                end
                for i = numdrainlineshalf + 1, numdrainlines do
                    table.insert(outputlines, outputlinespre.drain[i])
                end
            end
        else
            for _, line in ipairs(outputlinespre.source) do
                table.insert(outputlines, line)
            end
            for _, line in ipairs(outputlinespre.drain) do
                table.insert(outputlines, line)
            end
        end
        local currentnumlines = #outputlines
        for i, line in ipairs(outputlinespre.gate) do
            if _P.globalgatelinesincenter then
                table.insert(outputlines, currentnumlines // 2 + i, line)
            else
                table.insert(outputlines, 1, {
                    base = "gate",
                    device = line.device,
                    variant = 1,
                })
                table.insert(outputlines, {
                    base = "gate",
                    device = line.device,
                    variant = 2,
                })
            end
        end
    end
    if _P.insertglobalguardringlines then
        table.insert(outputlines, 1, {
            base = "guardring",
            device = 0,
            variant = 1,
        })
        table.insert(outputlines, {
            base = "guardring",
            device = 0,
            variant = 2,
        })
    end

    -- add output lines width
    util.foreach(
        outputlines,
        function(line)
            if line.base == "source" then
                line.width = _P.sourceoutputlinewidth
            elseif line.base == "drain" then
                line.width = _P.drainoutputlinewidth
            elseif line.base == "gate" then
                line.width = _P.gateoutputlinewidth
            else -- line.base == "guardring"
                line.width = _P.guardringoutputlinewidth
            end
        end
    )

    -- create output lines
    local numlines = #outputlines
    local all_lines_width = util.sum(util.foreach(outputlines, function(line) return line.width end))
    local space
    if _P.spreadoutputlines then
        space = util.fit_lines_fullwidth_grid(targetwidth, all_lines_width, numlines, technology.get_even_grid())
    else
        space = _P.outputlinespace
    end
    local outputline_start = 0.5 * outertargetwidth - (all_lines_width + (numlines - 1) * space) / 2
    --local outputline_start = obbbl:getx()
    -- create output lines and add anchors
    local shift = 0
    for lineindex, line in ipairs(outputlines) do
        local identifier
        local netname
        if line.variant then
            netname = string.format("%s%d_%d", line.base, line.device, line.variant)
        else
            netname = string.format("%s%d", line.base, line.device)
        end
        local identifier = string.format("outputconnectline_%s", netname)
        cell:add_area_anchor_bltr(identifier,
            point.create(
                obbbl:getx() + outputline_start + shift,
                outputlineminy - _P.outputlinebotextend
            ),
            point.create(
                obbbl:getx() + outputline_start + shift + line.width,
                outputlinemaxy + _P.outputlinetopextend
            )
        )
        shift = shift + line.width + space
        geometry.rectanglebltr(cell, generics.metal(_P.interconnectmetal + 1),
            cell:get_area_anchor(identifier).bl,
            cell:get_area_anchor(identifier).tr
        )
        cell:add_area_anchor_bltr(netname,
            cell:get_area_anchor(identifier).bl,
            cell:get_area_anchor(identifier).tr
        )
    end

    -- connect gate lines to output lines
    for rownum = 1, math.floor((numrows + 1) / 2) do
        local devindices = _get_uniq_row_devices_double(rownum)
        local lines = {}
        for _, di in ipairs(devindices) do
            local index = _map_device_index_to_gate(di)
            if not util.any_of(index, lines) then
                table.insert(lines, index)
            end
        end
        local numlines = #lines
        for line, index in ipairs(lines) do
            local gateoutputlines = util.clone_array_predicate(outputlines,
                function(e)
                    return e.base == "gate" and e.device == index
                end
            )
            for _, outputline in ipairs(gateoutputlines) do
                local netname
                if outputline.variant then
                    netname = string.format("gate%d_%d", index, outputline.variant)
                else
                    netname = string.format("gate%d", index)
                end
                geometry.viabltrov(cell, _P.gatelinemetal, _P.interconnectmetal + 1,
                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).bl,
                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).tr,
                    cell:get_area_anchor_fmt("outputconnectline_%s", netname).bl,
                    cell:get_area_anchor_fmt("outputconnectline_%s", netname).tr
                )
            end
        end
    end

    -- connect interconnect lines (source) to output lines
    local sourceoutputlines = util.clone_array_predicate(outputlines, function(e) return e.base == "source" end)
    if not _P.usesourcestraps then
        for rownum = 1, numrows do
            local devices = _get_active_devices(function(device) return device.row == rownum end)
            for _, device in ipairs(devices) do
                local sourceline = _map_device_index_to_source(device.device)
                geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).bl,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).tr,
                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("source%d", sourceline)).bl,
                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("source%d", sourceline)).tr
                )
            end
        end
    else -- _P.usesourcestraps
        if _P.equalsourcenets then
            for rownum = 1, numrows do
                local alldevices = _get_devices(function(device) return device.row == rownum end)
                local leftdevice = alldevices[1]
                local rightdevice = alldevices[numinstancesperrow]
                --[[ FIXME: this is old and not compatible with the new parameters
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
                --]]
            end
        else -- not _P.equalsourcenets
            -- this can not be reliable connected, hence it is caught in check()
        end
    end

    -- connect interconnect lines (drains) to output lines
    for rownum = 1, numrows do
        local devices = _get_active_devices(function(device) return device.row == rownum end)
        for _, device in ipairs(devices) do
            local lines = util.clone_array_predicate(outputlines, function(e) return e.base == "drain" and e.device == device.device end)
            if #lines > 1 then -- multiple output lines, use variant field
                for _, line in ipairs(lines) do
                    geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).bl,
                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).tr,
                        cell:get_area_anchor_fmt("outputconnectline_%s_%d", string.format("drain%d", device.device), line.variant).bl,
                        cell:get_area_anchor_fmt("outputconnectline_%s_%d", string.format("drain%d", device.device), line.variant).tr
                    )
                end
            else
                geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).bl,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", device.device)).tr,
                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("drain%d", device.device)).bl,
                    cell:get_area_anchor_fmt("outputconnectline_%s", string.format("drain%d", device.device)).tr
                )
            end
        end
    end

    -- connect gates lines to output lines
    for _, connection in ipairs(_P.connectgatetosourcedrain) do
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

    -- add source nets to output lines
    for _, line in ipairs(sourceoutputlines) do
        local netname = string.format("%s%d", line.base, line.device)
        local anchorname
        if line.variant then
            anchorname = string.format("%s_%d", netname, line.variant)
        else
            anchorname = netname
        end
        if _P.sourcenets[netname] then
            cell:add_net_shape(
                _P.sourcenets[netname],
                cell:get_area_anchor(anchorname).bl,
                cell:get_area_anchor(anchorname).tr,
                generics.metal(_P.interconnectmetal + 1)
            )
        end
    end

    -- add drain nets to output lines
    for i = 1, numdevices do
        if _P.drainnets[i] then
            cell:add_net_shape(_P.drainnets[i],
                cell:get_area_anchor_fmt("outputconnectline_drain%d", i).bl,
                cell:get_area_anchor_fmt("outputconnectline_drain%d", i).tr,
                generics.metal(_P.interconnectmetal + 1)
            )
        end
    end

    -- add guardring net to output lines
    if _P.insertglobalguardringlines and _P.guardringnet ~= "" then
        for i = 1, 2 do
            cell:add_net_shape(_P.guardringnet,
                cell:get_area_anchor_fmt("outputconnectline_%s_%d", "guardring0", i).bl,
                cell:get_area_anchor_fmt("outputconnectline_%s_%d", "guardring0", i).tr,
                generics.metal(_P.interconnectmetal + 1)
            )
        end
    end

    -- add net labels for visual inspection (interconnect lines and gate lines)
    if _P.annotate_interconnectlines then
        for _, line in ipairs(interconnectlines) do
            local anchor = string.format("interconnectline_%d_%s", line.rownum, line.net)
            cell:add_label(
                string.format("%s", line.net),
                generics.metal(_P.interconnectmetal),
                cell:get_area_anchor_fmt(anchor).br,
                _P.interconnectlines_label_sizehint
            )
            cell:add_label(
                string.format("%s", line.net),
                generics.metal(_P.interconnectmetal),
                cell:get_area_anchor_fmt(anchor).bl,
                _P.interconnectlines_label_sizehint
            )
        end
        for _, line in ipairs(gatelines) do
            local anchor = string.format("gateline_%d_%d", line.rownum, line.index)
            cell:add_label(
                string.format("gate%d", line.index),
                generics.metal(_P.gatelinemetal),
                cell:get_area_anchor_fmt(anchor).br,
                _P.gatelines_label_sizehint
            )
            cell:add_label(
                string.format("gate%d", line.index),
                generics.metal(_P.gatelinemetal),
                cell:get_area_anchor_fmt(anchor).bl,
                _P.gatelines_label_sizehint
            )
        end
    end

    -- add net labels for visual inspection (global lines)
    if _P.annotate_globallines then
        for _, line in ipairs(outputlines) do
            local anchor
            if line.variant then
                anchor = string.format("outputconnectline_%s%d_%d", line.base, line.device, line.variant)
            else
                anchor = string.format("outputconnectline_%s%d", line.base, line.device)
            end
            cell:add_label(
                string.format("%s%d", line.base, line.device),
                generics.metal(_P.interconnectmetal + 1),
                cell:get_area_anchor_fmt(anchor).tl,
                _P.globallines_label_sizehint
            )
            cell:add_label(
                string.format("%s%d", line.base, line.device),
                generics.metal(_P.interconnectmetal + 1),
                cell:get_area_anchor_fmt(anchor).bl,
                _P.globallines_label_sizehint
            )
        end
    end

    if _P.drawouterguardring and _P.insertglobalguardringlines and _P.connectguardringtogloballines then
        for _, segment in ipairs({ "top", "bottom" }) do
            for i = 1, 2 do
                geometry.viabltr(cell, 1, _P.interconnectmetal + 1,
                    point.create(
                        cell:get_area_anchor_fmt("outputconnectline_%s_%d", "guardring0", i).l,
                        guardring:get_area_anchor_fmt("%ssegment", segment).b
                    ),
                    point.create(
                        cell:get_area_anchor_fmt("outputconnectline_%s_%d", "guardring0", i).r,
                        guardring:get_area_anchor_fmt("%ssegment", segment).t
                    )
                )
            end
        end
    end

    -- instance name
    if rawget(_P, "instancename") then
        cell:add_label(
            _P.instancename,
            generics.other("text"),
            cell:get_alignment_anchor("outerbl"),
            _P.instancelabelsizehint
        )
    end
end
