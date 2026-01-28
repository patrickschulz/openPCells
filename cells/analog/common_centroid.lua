function info()
    local lines = {
        "This cell implements a common-centroid array of several MOSFET devices.",
        "The local nets (source/drain/gate) are distributed in rows via so-called gate/interconnect lines and the connected between rows by global/output lines.",
        "The device pattern is given with numeric indices starting at one, so a typical differential pair could be represented by { { 1, 2 }, { 2, 1 } }, where every inner table represents one row.",
        "The property of every device can then be controlled via cell parameters such as gatelength, fingerwidth etc.",
        "The inner nets can also be shorted together, when for instance one of the devices is in a diode-connected configuration, or when several sources are connected together. These connections are controlled via 'sourceconnections' and 'connectgatetosourcedrain'.",
        "A typical cell configuration could look like this:",
        "{",
        "    pattern = {",
        "        { 1, 1, 2, 2, },",
        "        { 2, 2, 1, 1, },",
        "    },",
        "    channeltype = \"nmos\",",
        "    oxidetype = 2,",
        "    gatelength = 200,",
        "    gatespace = 200,",
        "    fingerwidth = 1500,",
        "    fingers = 2, -- per device",
        "}",
        "",
        "The pattern can currently be anything (almost, it needs to have an even number of rows), no checks for actual common-centroid arrays are done.",
        "This might change in the future, but currently the user is responsible for proper placement.",
        "",
        "The rows spacing is typically given by the number of interconnect lines, in arrays with many devices the row spacing can get quite large.",
        "The parameter 'allow_unequal_rowshifts' can reduce this spacing.",
        "Per default it is 'false', although (with proper pattern specification) it should be safe to set to 'true' in most cases.",
    }
    return table.concat(lines, "\n")
end

function parameters()
    pcell.add_parameters(
        { "pattern", { { 1, 2, 1 }, { 2, 1, 2 } }, info = "pattern specification of the common centroid array. For every row a table should be specified, individual devices are indicated by a numeric index, starting at 1. These indices later also correspond to the net numbers (e.g. device 2 -> gate2/source2/drain2). The indices must be consecutive, for instance { { 1, 2, 4 } } is not allowed. Dummy/filler devices can be specified by '0', these devices are controlled via the '*dummy*' parameters." },
        { "minimum_row_shift", 0, info = "Minimum row shift between device rows (active-to-active spacing) where no other spacing constraints are present. In the default settings this does not happen, but with the 'gate' interconnect lines placement method for instance there are no metal lines between odd-even rows. This value is set to accomodate minimum spacing requirements between gates and active regions, but can be modified with this parameter." },
        { "channeltype", "nmos", posvals = set("nmos", "pmos"), info = "Channel type of the array devices ('nmos' or 'pmos')." },
        { "implantalignwithactive", false, info = "Change the reference points for the distance parameters for the implant type layer. See the parameter for basic/mosfet for more information." },
        { "vthtype", 1, info = "Threshold voltage type of the array devices." },
        { "vthtypealignwithactive", false, info = "Change the reference points for the distance parameters for the threshold voltage modification layer. See the parameter for basic/mosfet for more information." },
        { "oxidetype", 1, info = "Oxide type of the array devices." },
        { "oxidetypealignwithactive", false, info = "Change the reference points for the distance parameters for the oxide type layer. See the parameter for basic/mosfet for more information." },
        { "flippedwell", false, info = "Specifies whether devices are flipped-well devices." },
        { "wellalignwithactive", false, info = "Change the reference points for the distance parameters for the well layer. See the parameter for basic/mosfet for more information." },
        { "fingerwidth", technology.get_dimension("Minimum Gate Width"), info = "Specifies the fingerwidth of all devices." },
        { "sourcedrainsize", technology.get_dimension("Minimum Gate Width"), follow = "fingerwidth" },
        { "xseparation", 0, info = "Shift every devices by this amount in x-direction. Required for non-equal source net arrays, where source regions can not be shared." },
        { "gatelength", technology.get_dimension("Minimum Gate Length"), info = "Specifies the gate length of all devices." },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space"), info = "Specifies the gate space of all devices." },
        { "matchgateextensions", true, info = "Makes all gates have the same height. If this is 'false', some gate extensions can be longer, due to connections to gate straps. With 'true', all extensions are matched for symmetry. This increases the total area of the gate layer (not the gates itself, which are defined by the intersection of the active and gate regions)." },
        { "gatemetal",  1, info = "Metal of the gate straps." },
        { "gatelinemetal",  2, info = "Metal of the gate connections lines." },
        { "usesourcestraps", false },
        { "sourcestrapsinside", false },
        { "usedrainstraps", false },
        { "sourcedrainmetal", 1 },
        { "drainmetal", 1, follow = "sourcedrainmetal" },
        { "interconnectmetal", 2 },
        { "sourcemetal", 1, follow = "sourcedrainmetal" },
        { "equalsourcenets", true },
        { "equaldrainnets", false },
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
        { "gatepos", "doublerow", posvals = set("doublerow", "bottom", "top") },
        { "extendgatessymmetrically", false },
        { "allow_odd_rows", false },
        { "allow_unequal_rowshifts", false },
        { "usegateconnections", false },
        { "gateconnections", {}, info = "Connect gates of several devices. This allows finer control over the gate connections of arrays than 'equalgatenets'. The parameter value should be a table with several entries, where every entry is a table with numeric indices that correspond to devices that are connected. Every entry represents one connection, so devices should not be present in multiple entries. 'equalgatenets' can be mimicked by gateconnections = { { 1, 2, 3, ... } }, the standard non-equal-gate-nets configuration (one gate net per device) is represented by gateconnections = { { 1 }, { 2 }, { 3 }, ... }. A possible configuration that makes sense could be gateconnections = { { 1, 2 }, { 3, 4, 5 } }. Use this parameter together with 'usegateconnections = true', otherwise it is ignored." },
        { "usesourceconnections", false },
        { "sourceconnections", {} },
        { "usedrainconnections", false },
        { "drainconnections", {} },
        { "interconnectlinepos", "offside", posvals = set("offside", "gate", "inline"), info = "Set the position of the interconnect lines. 'offside' places them at the other side of the transistors (with respect to the gate lines), 'gate' puts both gate and interconnect lines between double-row devices, 'inline' places the lines on top of the transistors (which works only well for a few devices or large finger widths. 'offside' is usually the best option." },
        { "spreadinterconnectlines", true },
        { "interconnectlinewidth", technology.get_dimension("Minimum M2 Width") },
        { "interconnectlinespace", technology.get_dimension("Minimum M2 Space") },
        { "interconnectlineextension", 0, info = "extend interconnect lines beyond their minimum x-values. This is useful for allowing for more enclosure around placed vias at the edges of the array." },
        { "interconnectlineviawidth", technology.get_dimension("Minimum M1M2 Viawidth") },
        { "interconnectviapitch", technology.get_optional_dimension("Minimum M2 Pitch", 0) },
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
        { "globallines", {}, info = "Specifies the global lines order manually. If used, this table must at least contain an entry for every net (gate, drain and source). The syntax for every line specification is '{ pin = <pin>, net = <numeric index> }'. A possible specification could be: '{ { pin = \"gate\", net = 1 }, { pin = \"gate\", net = 2 }, { pin = \"source\", net = 2 }, { pin = \"drain\", net = 1 }, { pin = \"drain\", net = 2 }, { pin = \"source\", net = 2 } }. Global lines can also be specified more than once, for low-ohmic connections or spreading of global lines. This will change internal anchors (appends _1, _2, etc.), which might change how global lines can be connected automatically. This parameter must be used with 'usegloballines', otherwise it is ignored." },
        { "sourcenets", {} },
        { "drainnets", {} },
        { "connectgatetosourcedrain", {} },
        { "diodeconnected", {} },
        { "shortdummies", false, follow = "drawinnerguardrings" },
        { "outerdummies", 0 },
        { "outerdummyrows", 0 },
        { "outerdummiesfingerwidth", technology.get_dimension("Minimum Gate Width"), follow = "fingerwidth", info = "Specifies the fingerwidth of devices in outer dummy rows." },
        { "outerdummygatelength", technology.get_dimension("Minimum Gate Length") }, -- FIXME: basic/stacked_mosfet_array does not support this
        { "connectdummygatestoactive", false },
        { "connectdummies", true },
        { "connectdummysources", true },
        { "connectdummiestointernalnet", false },
        { "allow_single_device", false },
        { "extendall",                              0 },
        { "extendalltop",                           0, follow = "extendall" },
        { "extendallbottom",                        0, follow = "extendall" },
        { "extendallleft",                          0, follow = "extendall" },
        { "extendallright",                         0, follow = "extendall" },
        { "extendoxidetypetop",                     technology.get_dimension("Minimum Oxide Extension"), follow = "extendalltop" },
        { "extendoxidetypebottom",                  technology.get_dimension("Minimum Oxide Extension"), follow = "extendallbottom" },
        { "extendoxidetypeleft",                    technology.get_dimension("Minimum Oxide Extension"), follow = "extendallleft" },
        { "extendoxidetyperight",                   technology.get_dimension("Minimum Oxide Extension"), follow = "extendallright" },
        { "extendvthtypetop",                       technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendalltop" },
        { "extendvthtypebottom",                    technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallbottom" },
        { "extendvthtypeleft",                      technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallleft" },
        { "extendvthtyperight",                     technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallright" },
        { "extendimplanttop",                       technology.get_dimension("Minimum Implant Extension"), follow = "extendalltop" },
        { "extendimplantbottom",                    technology.get_dimension("Minimum Implant Extension"), follow = "extendallbottom" },
        { "extendimplantleft",                      technology.get_dimension("Minimum Implant Extension"), follow = "extendallleft" },
        { "extendimplantright",                     technology.get_dimension("Minimum Implant Extension"), follow = "extendallright" },
        { "extendwelltop",                          technology.get_dimension("Minimum Well Extension"), follow = "extendalltop" },
        { "extendwellbottom",                       technology.get_dimension("Minimum Well Extension"), follow = "extendallbottom" },
        { "extendwellleft",                         technology.get_dimension("Minimum Well Extension"), follow = "extendallleft" },
        { "extendwellright",                        technology.get_dimension("Minimum Well Extension"), follow = "extendallright" },
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
        { "guardringsoiopeninnerextension", technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "guardringsoiopenouterextension", technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "guardringoxidetypeinnerextension", technology.get_dimension("Minimum Oxide Extension") },
        { "guardringoxidetypeouterextension", technology.get_dimension("Minimum Oxide Extension") },
        { "insertglobalguardringlines", false },
        { "connectguardringtogloballines", false, follow = "insertglobalguardringlines" },
        { "guardringnet", "" },
        { "annotate_lines", true },
        { "annotate_gatelines", true, follow = "annotate_lines" },
        { "annotate_interconnectlines", true, follow = "annotate_lines" },
        { "annotate_globallines", true, follow = "annotate_lines" },
        { "lines_label_sizehint", technology.get_optional_dimension("Default Label Size", 0) },
        { "gatelines_label_sizehint", technology.get_optional_dimension("Default Label Size", 0), follow = "lines_label_sizehint" },
        { "interconnectlines_label_sizehint", technology.get_optional_dimension("Default Label Size", 0), follow = "lines_label_sizehint" },
        { "globallines_label_sizehint", technology.get_optional_dimension("Default Label Size", 0), follow = "lines_label_sizehint" },
        { "instancename", nil },
        { "instancelabelsizehint", technology.get_optional_dimension("Default Label Size", 0) }
    )
end

function process_parameters(_P)
    local t = {}
    -- calculate minimum row shift (needed if no interconnect lines are drawn between rows)
    t.minimum_row_shift = math.max(
        technology.get_optional_dimension("Minimum Active Space", 0),
        math.max(
            technology.get_optional_dimension("Minimum Gate Space", 0),
            technology.get_optional_dimension("Minimum Gate XSpace", 0)
        ) + 2 * technology.get_optional_dimension("Minimum Gate Extension", 0)
    )
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
    t.gateoutputlinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1))
    t.sourceoutputlinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1))
    t.drainoutputlinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1))
    t.guardringoutputlinewidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1))
    t.sourcedrainstrapwidth = technology.get_dimension(string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1))
    if _P.insertglobalguardringlines and _P.connectguardringtogloballines then
        t.guardringwidth = technology.get_dimension_max(
            string.format("Minimum M%d Width", _P.interconnectmetal + 1),
            string.format("Minimum M%dM%d Viawidth", _P.interconnectmetal, _P.interconnectmetal + 1)
        )
    end
    return t
end

function prepare(_P)
    local state = {}

    -- net mapping functions
    state._map_device_index_to_gate = function(device)
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
        cellerror(string.format("common_centroid: gate lookup with unknown device/configuration (device: %d, configuration: equalgatenets = %s, usegateconnections = %s)", device, _P.equalgatenets and "true" or "false", _P.usegateconnections and "true" or "false"))
    end
    state._map_device_index_to_source = function(device)
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
        cellerror(string.format("common_centroid: source lookup with unknown device/configuration (device: %d, configuration: equalsourcenets = %s, usesourceconnections = %s)", device, _P.equalsourcenets and "true" or "false", _P.usesourceconnections and "true" or "false"))
    end
    state._map_device_index_to_drain = function(device)
        if _P.equaldrainnets then
            return 1
        elseif _P.usedrainconnections then
            for i, entry in ipairs(_P.drainconnections) do
                if util.any_of(device, entry) then
                    return i
                end
            end
        else
            return device
        end
        cellerror(string.format("common_centroid: drain lookup with unknown device/configuration (device: %d, configuration: equaldrainnets = %s, usedrainconnections = %s)", device, _P.equaldrainnets and "true" or "false", _P.usedrainconnections and "true" or "false"))
    end

    state.numinstancesperrow = #(_P.pattern[1]) + 2 * _P.outerdummies -- total number of *instances* in a row (e.g. 0ABBAABBA0 -> 10, includes dummies, excluding 'outerdummies')

    -- add outer dummies to pattern
    state.pattern = {}
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
        table.insert(state.pattern, row)
    end
    for i = 1, _P.outerdummyrows do
        local lowerrow = {}
        local upperrow = {}
        for j = 1, state.numinstancesperrow do
            table.insert(lowerrow, 0)
            table.insert(upperrow, 0)
        end
        table.insert(state.pattern, 1, lowerrow)
        table.insert(state.pattern, upperrow)
    end

    -- create pattern only containing active devices
    state.activepattern = {}
    for _, rowpattern in ipairs(state.pattern) do
        local row = {}
        for _, device in ipairs(rowpattern) do
            if device ~= 0 then
                table.insert(row, device)
            end
        end
        table.insert(state.activepattern, row)
    end

    state.numrows = #state.activepattern
    -- in the pattern, a '0' denotes a dummy, this does *not* count as a device
    state.numdevices = 0 -- total number of active devices (e.g. 0ABBA0
                         --                                      0CCDD0
                         --                                 -> 4)
    state.hasdummies = false
    for _, rowpattern in ipairs(state.pattern) do
        for _, device in ipairs(rowpattern) do
            if device ~= 0 then
                if device > state.numdevices then
                    state.numdevices = device
                end
            else
                state.hasdummies = true
            end
        end
    end

    -- device table
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
    for rownum, rowpattern in ipairs(state.pattern) do -- don't use activepattern here as dummies should be generated
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

    -- device access functions
    state._get_devices = function(cond)
        local result = {}
        for _, device in ipairs(devicetable) do
            if cond(device) then
                table.insert(result, device)
            end
        end
        return result
    end
    state._get_active_devices = function(cond)
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
    state._get_active_device = function(cond)
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
    state._get_uniq_row_devices_double = function(rownum)
        local doublerowdevices = state._get_active_devices(function(device) return device.row == 2 * rownum - 1 or device.row == 2 * rownum end)
        local indices = util.uniq(util.foreach(doublerowdevices, function(entry) return entry.device end))
        table.sort(indices)
        return indices
    end
    state._get_uniq_row_devices_single = function(rownum)
        local singlerowdevices = state._get_active_devices(function(device) return device.row == rownum end)
        local indices = util.uniq(util.foreach(singlerowdevices, function(entry) return entry.device end))
        table.sort(indices)
        return indices
    end

    -- end of prepare() function
    return state
end

function check(_P, state)
    if not _P.allow_odd_rows and (#state.pattern % 2 == 1) then
        return false, "the pattern contains an odd number of rows. There is currently only limited support for this. Most things will probably work, but it is not tested extensively. Use 'allow_odd_rows == true' if you need a pattern with an odd number of rows."
    end
    for i = 2, #state.pattern do
        if #state.pattern[i] ~= #state.pattern[1] then
            return false, string.format("row pattern lengths are not equal (row %d has %d entries, the other rows have %d entries)", i, #state.pattern[i], #state.pattern[1])
        end
    end

    -- check gate position for an odd number of rows
    if #state.pattern % 2 == 1 then
        if _P.gatepos == "doublerow" then
            return false, "if the pattern contains an odd number of rows, the gate position must be 'top' or 'bottom'."
        end
    end

    -- check whether devices are specified continuously
    local devices = {}
    for device = 1, state.numdevices do
        for _, row in ipairs(state.pattern) do
            if util.any_of(device, row) then
                devices[device] = true
            end
        end
        if not devices[device] then
            return false, string.format("devices must be specified continuously, starting at 1. Missing device: %d", device)
        end
    end

    -- common centroid does not make sense with only one device (but allow with specific switch)
    if state.numdevices < 2 and not _P.allow_single_device then
        return false, "the array must contain more than one active device (unless 'allow_single_device' is true)"
    end

    -- gate connection mode
    if _P.equalgatenets and _P.usegateconnections then
        return false, "'equalgatenets' and 'usegateconnections' must not be true at the same time"
    end

    -- source connection mode
    if _P.equalsourcenets and _P.usesourceconnections then
        return false, "'equalsourcenets' and 'usesourceconnections' must not be true at the same time"
    end

    -- drain connection mode
    if _P.equaldrainnets and _P.usedrainconnections then
        return false, "'equaldrainnets' and 'usedrainconnections' must not be true at the same time"
    end

    -- check that (when 'usesourceconnections' is used):
    -- * all devices are present
    -- * no device is present more than once
    if _P.usesourceconnections then
        local connected_devices = {}
        for _, entry in ipairs(_P.sourceconnections) do
            for _, index in ipairs(entry) do
                if connected_devices[index] then
                    return false, string.format("when source connections are used, no device must be present more than once. Spurious device: %d", index)
                end
                connected_devices[index] = true
            end
        end
        for index = 1, state.numdevices do
            if not connected_devices[index] then
                return false, string.format("when source connections are used, all devices must be present. Missing device: %d", index)
            end
        end
    end

    -- check that (when 'usedrainconnections' is used):
    -- * all devices are present
    -- * no device is present more than once
    if _P.usedrainconnections then
        local connected_devices = {}
        for _, entry in ipairs(_P.drainconnections) do
            for _, index in ipairs(entry) do
                if connected_devices[index] then
                    return false, string.format("when drain connections are used, no device must be present more than once. Spurious device: %d", index)
                end
                connected_devices[index] = true
            end
        end
        for index = 1, state.numdevices do
            if not connected_devices[index] then
                return false, string.format("when drain connections are used, all devices must be present. Missing device: %d", index)
            end
        end
    end

    -- gather nets for later checks
    local nets = {
        gate = {},
        drain = {},
        source = {},
    }
    -- insert gate nets
    for _, net in ipairs(util.uniq(util.foreach(util.range(1, state.numdevices), state._map_device_index_to_gate))) do
        table.insert(nets.gate, net)
    end
    -- insert source nets
    for _, net in ipairs(util.uniq(util.foreach(util.range(1, state.numdevices), state._map_device_index_to_source))) do
        table.insert(nets.source, net)
    end
    -- insert drain nets
    for _, net in ipairs(util.uniq(util.foreach(util.range(1, state.numdevices), state._map_device_index_to_drain))) do
        table.insert(nets.drain, net)
    end

    -- check shorted gates (not possible with multiple gate nets)
    if _P.shortgates and #nets.gate > 1 then
        return false, "gates can not be shorted ('shortgates' == true) when not all gate nets equal"
    end

    -- check for unspecified gate connections
    if _P.usegateconnections then
        for i = 1, state.numdevices do
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
        for i = 1, state.numdevices do
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

    -- check for unspecified drain connections
    if _P.usedrainconnections then
        for i = 1, state.numdevices do
            local found = false
            for _, connections in ipairs(_P.drainconnections) do
                for _, entry in ipairs(connections) do
                    if i == entry then
                        found = true
                    end
                end
            end
            if not found then
                return false, string.format("when drain connections are used, every drain connection must be specified. Missing drain connection: %d", i)
            end
        end
    end

    -- common centroid makes no sense for only one device
    if state.numdevices < 2 then
        return false, "the pattern definition does not contain more than one device"
    end

    -- check dummy gates configuration
    if _P.connectdummygatestoactive and not _P.equalgatenets then
        return false, "if dummy gates are connected to active gates, all gates have to be on the same net (equalgatenets == true)"
    end
    if not _P.connectdummygatestoactive and _P.connectgatesonbothsides and (_P.outerdummies > 0) then
        return false, "if gates are connected on both sides, dummy gates must be connected to the active gates"
    end

    -- check number of gate nets when gate straps are in center
    if _P.gatestrapsincenter and #nets.gate > 1 then
        return false, "gate straps can not be placed in the center when there is more than one gate net"
    end

    -- check gate position when gate straps are in center
    if _P.gatestrapsincenter and _P.gatepos ~= "doublerow" then
        return false, "gate straps can not be placed in the center when the gate placement is not 'doublerow'."
    end

    -- check shorts between gates and inner guardrings
    if _P.gatestrapsincenter and _P.drawinnerguardrings then
        return false, "gate straps can not be placed in the center when inner guard rings are present"
    end

    -- check for gate line shorts
    if not _P.equalgatenets and _P.gatemetal == _P.gatelinemetal then
        return false, "if gates are on different nets, gate lines can not be on the same metal as gate connection lines (gatemetal and gatelinemetal)"
    end

    -- check shorts between inner guardrings and gates
    if _P.drawinnerguardrings and _P.gatemetal == 1 then
        return false, "if guard rings are present, gate connection lines can not be on metal 1 (gatemetal)"
    end

    -- check shorts between inner guardrings and gate lines
    if _P.drawinnerguardrings and _P.gatelinemetal == 1 then
        return false, "if guard rings are present, gate lines can not be on metal 1 (gatelinemetal)"
    end

    -- check shorts between inner guardrings and source connections
    if _P.drawinnerguardrings and _P.sourcemetal == 1 then
        return false, "if guard rings are present, the source connections can not be on metal 1 (sourcemetal)"
    end

    -- check shorts between inner guardrings and drain connections
    if _P.drawinnerguardrings and _P.drainmetal == 1 then
        return false, "if guard rings are present, the drain connections can not be on metal 1 (drainmetal)"
    end

    -- check shorts between inner guardrings and interconnectlines
    if _P.drawinnerguardrings and _P.interconnectmetal == 1 then
        return false, "if guard rings are present, interconnection lines can not be on metal 1 (interconnectmetal)"
    end

    -- check for presence of inner/outer guardring when global guardring lines are used
    if _P.insertglobalguardringlines and not (_P.drawinnerguardrings or _P.drawouterguardring) then
        return false, "global guardring lines can only be inserted when an outer guardring is present"
    end

    -- check for shorts between source and drain
    if _P.interconnectlinepos == "offside" and _P.usesourcestraps and not _P.sourcestrapsinside and _P.sourcemetal == _P.drainmetal then
        return false, "if interconnectlines are positioned 'offside' and source straps are used, the drain and source connections can not be on the same metal"
    end

    -- check for shorts between gate and source
    if _P.interconnectlinepos == "gate" and _P.sourcemetal == _P.gatemetal then
        return false, "if interconnectlines are positioned 'gate', the source metal can not be equal to the gate metal"
    end

    -- check for shorts between gate and drain
    if _P.interconnectlinepos == "gate" and _P.drainmetal == _P.gatemetal then
        return false, "if interconnectlines are positioned 'gate', the drain metal can not be equal to the gate metal"
    end

    -- check for shorts between gate and output lines
    if _P.gatemetal == _P.interconnectmetal + 1 then
        return false, "the drain metal can not be on the same layer as the output line metal"
    end

    -- check for shorts between source and interconnect lines
    if _P.interconnectlinepos == "offside" and _P.sourcemetal == _P.interconnectmetal then
        return false, "the source metal can not be on the same layer as the interconncect line metal"
    end

    -- check for shorts between drain and interconnect lines
    if _P.interconnectlinepos == "offside" and _P.drainmetal == _P.interconnectmetal then
        return false, "the drain metal can not be on the same layer as the interconncect line metal"
    end

    -- check for shorts between unequal source nets
    if #nets.source > 1 and not ((_P.xseparation > 0) or _P.drawinnerguardrings) then
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
    if _P.shortgates and _P.shortdummies and state.hasdummies then
        return false, "shorted dummies (with dummies present) are not allowed if gates are shorted"
    end

    -- connect interconnect lines (source) to output lines
    if _P.usesourcestraps then
        local numsources = #util.uniq(util.foreach(util.range(1, state.numdevices), state._map_device_index_to_source))
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
                    if pin ~= "gate" or #state.pattern > 2 then
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

    -- check that there is enough room for "inline" interconnect lines
    if _P.interconnectlinepos == "inline" then
        for rownum = 1, state.numrows do
            local devnums = state._get_uniq_row_devices_single(rownum)
            local lines = {}
            -- add source lines
            if not _P.usesourcestraps then
                local sourcelines = util.uniq(util.foreach(devnums, state._map_device_index_to_source))
                for _, num in ipairs(sourcelines) do
                    table.insert(lines, string.format("source%d", num))
                end
            end
            -- add drain lines
            local drainlines = util.uniq(util.foreach(devnums, state._map_device_index_to_drain))
            for _, num in ipairs(drainlines) do
                table.insert(lines, string.format("drain%d", num))
            end
            local numlines = #lines
            local space = divevendown(_P.fingerwidth - numlines * _P.interconnectlinewidth, numlines)
            if space < _P.interconnectlinespace then
                return false, string.format("there is not enough room to place all the interconnect lines with the 'inline' position method. A higher fingerwidth or lower number of devices in one row can mitigate this. Failure in row: %d", rownum)
            end
        end
    end

    -- end of check() function
    return true
end

function layout(cell, _P, _env, state)
    local activepattern = state.activepattern

    -- calculate required minimum row space for every row
    -- every row gets their own source/drain lines, gate lines are shared between two rows ('doublerow')
    -- as gate lines are shared, they are referenced to the lower row, so all odd rows
    local rowshifts = {}
    rowshifts[1] = 0
    for row = 2, state.numrows do -- skip first row, no shift needed
        local evenrow = row % 2 == 0

        -- interconnect lines occupation
        local interconnectline_space_occupation = 0
        if _P.gatepos == "doublerow" then
            if (evenrow and (_P.interconnectlinepos == "gate")) or
               (not evenrow and (_P.interconnectlinepos == "offside")) then
                local lowerrowdevices = activepattern[row - 1]
                local numlowersourcelines
                if _P.usesourcestraps then
                    numlowersourcelines = 0
                else
                    numlowersourcelines = #util.uniq(util.foreach(lowerrowdevices, state._map_device_index_to_source))
                end
                local numlowerdrainlines = #util.uniq(util.foreach(lowerrowdevices, state._map_device_index_to_drain))
                local numlowerlines = numlowersourcelines + numlowerdrainlines
                local upperrowdevices = activepattern[row]
                local numuppersourcelines
                if _P.usesourcestraps then
                    numuppersourcelines = 0
                else
                    numuppersourcelines = #util.uniq(util.foreach(upperrowdevices, state._map_device_index_to_source))
                end
                local numupperdrainlines = #util.uniq(util.foreach(upperrowdevices, state._map_device_index_to_drain))
                local numupperlines = numuppersourcelines + numupperdrainlines
                interconnectline_space_occupation = - 2 * _P.interconnectlinespace
                    + numlowerlines * (_P.interconnectlinespace + _P.interconnectlinewidth)
                    + numupperlines * (_P.interconnectlinespace + _P.interconnectlinewidth)
            elseif not evenrow and (_P.interconnectlinepos ~= "offside") then
                --if _P.usesourcestraps and not _P.sourcestrapsinside then
                --    local numsourcenets = #util.uniq(util.foreach(util.range(1, state.numdevices), state._map_device_index_to_source))
                --    -- FIXME: this checks across all rows, only check specific involved rows
                --    if numsourcenets > 1 then
                --        interconnectline_space_occupation = 2 * _P.sourcedrainstrapwidth + 3 * _P.sourcedrainstrapspace
                --    else
                --        interconnectline_space_occupation = _P.sourcedrainstrapwidth + 2 * _P.sourcedrainstrapspace
                --    end
                --end
            end
        else --_P.gatepos ~= "doublerow"
            local rowdevices = activepattern[row]
            local numsourcelines
            if _P.usesourcestraps then
                numsourcelines = 0
            else
                numsourcelines = #util.uniq(util.foreach(rowdevices, state._map_device_index_to_source))
            end
            local numdrainlines = #util.uniq(util.foreach(rowdevices, state._map_device_index_to_drain))
            local numlines = numsourcelines + numdrainlines
            interconnectline_space_occupation = (numlines - 1) * _P.interconnectlinespace + numlines * _P.interconnectlinewidth
        end

        -- gate strap occupation
        local gatestrap_space_occupation = 0
        if _P.gatepos == "doublerow" then
            if evenrow and _P.interconnectlinepos ~= "gate" then -- gate line row shifts only apply to even rows
                if _P.gatestrapsincenter then
                    gatestrap_space_occupation = 2 * _P.gatestrapspace + _P.gatestrapwidth
                else
                    gatestrap_space_occupation = 2 * _P.gatestrapspace + 2 * _P.gatestrapwidth
                end
            end
        else -- _P.gatepos ~= "doublerow"
            gatestrap_space_occupation = _P.gatestrapspace + _P.gatestrapwidth
        end

        -- source strap occupation
        local sourcestrap_space_occupation = 0
        if _P.usesourcestraps then
            if _P.gatepos == "doublerow" then
                if (not evenrow and not _P.sourcestrapsinside) or
                   (evenrow and _P.sourcestrapsinside) then
                    sourcestrap_space_occupation = _P.sourcedrainstrapwidth + 2 * _P.sourcedrainstrapspace
                end
            end
        end

        -- gate lines occupation
        local gateline_space_occupation = 0
        if _P.gatepos == "doublerow" then
            if evenrow then -- gate line row shifts only apply to even rows
                local doublerowdevices = util.merge_tables(activepattern[row - 1], activepattern[row])
                local numgates = #util.uniq(util.foreach(doublerowdevices, state._map_device_index_to_gate))
                gateline_space_occupation = numgates * _P.gatelinewidth + (numgates - 1) * _P.gatelinespace
            end
        else -- _P.gatepos ~= "doublerow"
            local numgates = #util.uniq(util.foreach(activepattern[row], state._map_device_index_to_gate))
            gateline_space_occupation = numgates * (_P.gatelinespace + _P.gatelinewidth)
            if _P.gatestrapsincenter then
                if gatestrap_space_occupation > gateline_space_occupation then
                    gateline_space_occupation = 0
                else
                    gatestrap_space_occupation = 0
                end
            end
        end

        -- add spacing between different lines
        local extraspace = 0
        if interconnectline_space_occupation > 0 then
            extraspace = 2 * _P.interconnectlinespace
            if _P.gatepos == "doublerow" then
                if gateline_space_occupation > 0 then
                    extraspace = extraspace + 2 * _P.interconnectlinespace
                else
                    extraspace = extraspace + _P.interconnectlinespace
                end
            end
        end
        if (gatestrap_space_occupation > 0) and (gateline_space_occupation > 0) then
            extraspace = 2 * _P.gatelinespace
        end

        -- gate straps and gate lines can overlap
        -- this removes unneeded spacing overhead
        if _P.gatestrapsincenter then
            if gatestrap_space_occupation > gateline_space_occupation + extraspace then
                gateline_space_occupation = 0
            else
                gatestrap_space_occupation = 0
            end
        end

        rowshifts[row] =
            sourcestrap_space_occupation +
            gatestrap_space_occupation +
            gateline_space_occupation +
            interconnectline_space_occupation +
            extraspace
    end
    -- fix zero-shift rows
    for row = 1, state.numrows do
        if rowshifts[row] == 0 then
            rowshifts[row] = _P.minimum_row_shift
        end
    end
    -- apply maximum row shift to all rows (unless 'allow_unequal_rowshifts' is true)
    local maxrowshift = util.max(rowshifts)
    if not _P.allow_unequal_rowshifts then
        for row = 1, state.numrows do
            rowshifts[row] = maxrowshift
        end
    end

    local rowoptions = {
        channeltype = _P.channeltype,
        implantalignwithactive = _P.implantalignwithactive,
        oxidetype = _P.oxidetype,
        oxidetypealignwithactive = _P.oxidetypealignwithactive,
        vthtype = _P.vthtype,
        vthtypealignwithactive = _P.vthtypealignwithactive,
        flippedwell = _P.flippedwell,
        wellalignwithactive = _P.wellalignwithactive,
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
    }

    -- gatespace is a table as it has to be given for individual rows
    -- if gate straps are placed in center and unequal row shifts are present
    local gatespace = {}
    if _P.gatestrapsincenter then
        for rownum = 2, state.numrows, 2 do
            gatespace[rownum - 1] = (rowshifts[rownum] - _P.gatestrapwidth) / 2
            gatespace[rownum] = (rowshifts[rownum] - _P.gatestrapwidth) / 2
        end
    else
        local value = _P.gatestrapspace
        if _P.usesourcestraps and _P.sourcestrapsinside then
            value = value + _P.sourcedrainstrapwidth + _P.sourcedrainstrapspace
        end
        gatespace = util.rep(state.numrows, value)
    end
    local commonoptions = {
        topgatewidth = _P.gatestrapwidth,
        botgatewidth = _P.gatestrapwidth,
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

    --[[
    local dummyoptions = util.add_options(commonoptions, {
        shortwidth = _P.gatestrapwidth,
        shortspace = (_P.gatestrapsincenter and not _P.drawinnerguardrings) and (yseparation - _P.gatestrapwidth) / 2 or _P.gatestrapspace,
        connectsource = _P.usesourcestraps and _P.connectdummysources,
        connectsourceboth = _P.connectdummysources,
        connectdrain = _P.connectdummysources,
        connectdrainboth = _P.connectdummysources,
    })
    --]]

    -- prepare mosfet rows
    local function _make_row_devices(rownum, devicerow)
        local devices = {}
        local connectsourceinverse
        if _P.sourcestrapsinside then
            connectsourceinverse = ((_P.channeltype == "pmos") and (rownum % 2 == 0)) or ((_P.channeltype == "nmos") and (rownum % 2 == 1))
        else
            connectsourceinverse = ((_P.channeltype == "pmos") and (rownum % 2 == 1)) or ((_P.channeltype == "nmos") and (rownum % 2 == 0))
        end
        local drawtopgate
        local drawbotgate
        if _P.gatepos == "doublerow" then
            drawtopgate = _P.connectgatesonbothsides or (rownum % 2 == 1)
            drawbotgate = _P.connectgatesonbothsides or (rownum % 2 == 0)
        else
            drawtopgate = _P.gatepos == "top"
            drawbotgate = _P.gatepos == "bottom"
        end
        for deviceindex, device in ipairs(devicerow) do
            local devopts = util.add_options(fetoptions, {
                name = string.format("M_%d_%d_%d", device.device, device.row, device.index),
                fingers = _P.fingers,
                drawtopgate = drawtopgate,
                drawbotgate = drawbotgate,
                topgatespace = gatespace[rownum],
                botgatespace = gatespace[rownum],
                sdm1botext = (rownum % 2 == 1) and _P.sdm1ext or 0,
                sdm1topext = (rownum % 2 == 0) and _P.sdm1ext or 0,
                connectsourceinverse = connectsourceinverse,
                connectdraininverse = ((_P.channeltype == "pmos") and (rownum % 2 == 1)) or ((_P.channeltype == "nmos") and (rownum % 2 == 0)),
                connectdrainleftext = (_P.fingers == 2) and (_P.interconnectviapitch + _P.interconnectlinewidth - _P.sdwidth) / 2 or 0,
                connectdrainrightext = (_P.fingers == 2) and (_P.interconnectviapitch + _P.interconnectlinewidth - _P.sdwidth) / 2 or 0,
            })
            if device.device ~= 0 then
                devopts.diodeconnected = util.any_of(device.device, _P.diodeconnected)
            else
                devopts.shortdevice = _P.shortdummies
                devopts.diodeconnected = _P.shortdummies
                devopts.drainmetal = 1
                devopts.sourcemetal = 1
            end
            table.insert(devices, devopts)
        end
        return devices
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

    -- create mosfet array
    local rows = {}
    for rownum = 1, state.numrows do
        local rowshift = rowshifts[rownum]
        if _P.drawinnerguardrings then
            rowshift = 0
        end
        local gtopext
        local gbotext
        if _P.gatepos == "doublerow" then
            gtopext = rownum % 2 == 1 and activegateext or inactivegateext
            gbotext = rownum % 2 == 0 and activegateext or inactivegateext
        else
            gtopext = (_P.gatepos == "top") and activegateext or inactivegateext
            gbotext = (_P.gatepos == "bottom") and activegateext or inactivegateext
        end
        local row = util.add_options(rowoptions, {
            shift = rowshift,
            gtopext = gtopext,
            gbotext = gbotext,
        })
        local devicerow = state._get_devices(function(device) return device.row == rownum end)
        row.devices = _make_row_devices(rownum, devicerow)
        local isdummyrow = true
        for deviceindex, device in ipairs(devicerow) do
            if device.device ~= 0 then
                isdummyrow = false
                break
            end
        end
        if isdummyrow then
            row.width = _P.outerdummiesfingerwidth
        end
        table.insert(rows, row)
    end
    local guardringxsep = _P.guardringminxsep
    local innerguardringysep = (util.max(rowshifts) - _P.guardringwidth) / 2
    if innerguardringysep < _P.guardringminysep then
        innerguardringysep = _P.guardringminysep
    end
    local array = pcell.create_layout("basic/stacked_mosfet_array", "_array", {
        rows = rows,
        drawimplant = not (_P.guardringfillimplant and (_P.drawinnerguardrings or _P.drawouterguardring)),
        drawoxidetype = not (_P.guardringfilloxidetype and (_P.drawinnerguardrings or _P.drawouterguardring)),
        drawwell = _P.flippedwell or not (_P.guardringfillwell and (_P.drawinnerguardrings or _P.drawouterguardring)),
        xseparation = _P.xseparation,
        yseparation = 0, -- yseparation is given manually with rowshifts
        autoskip = false,
        splitgates = not _P.shortgates,
        drawguardring = _P.drawinnerguardrings,
        guardringwidth = _P.guardringwidth,
        guardringrespectactivedummies = true,
        guardringrespectgatestraps = true,
        guardringrespectgateextensions = false, -- line spacing calculations assume active/metal regions, not gates
        guardringrespectsourcestraps = true,
        guardringrespectdrainstraps = true,
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
        guardringoxidetypeinnerextension = _P.guardringoxidetypeinnerextension,
        guardringoxidetypeouterextension = _P.guardringoxidetypeouterextension,
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
            numsourcelines = #util.uniq(util.foreach(firstrowdevices, state._map_device_index_to_source))
        end
        local numdrainlines = #util.uniq(util.foreach(firstrowdevices, state._map_device_index_to_drain))
        local numlines = numsourcelines + numdrainlines
        local interconnectline_space_occupation = 0 -- no space correction here (as opposed to other odd rows)
            + (numlines + 1) * _P.interconnectlinespace + numlines * _P.interconnectlinewidth
        firstrowinterconnectline_space_occupation = interconnectline_space_occupation
    end
    do
        local lastrowdevices = activepattern[state.numrows]
        local numsourcelines
        if _P.usesourcestraps then
            numsourcelines = 0
        else
            numsourcelines = #util.uniq(util.foreach(lastrowdevices, state._map_device_index_to_source))
        end
        local numdrainlines = #util.uniq(util.foreach(lastrowdevices, state._map_device_index_to_drain))
        local numlines = numsourcelines + numdrainlines
        local interconnectline_space_occupation = 0 -- no space correction here (as opposed to other odd rows)
            + (numlines + 1) * _P.interconnectlinespace + numlines * _P.interconnectlinewidth
        lastrowinterconnectline_space_occupation = interconnectline_space_occupation
    end

    -- outer guardring
    local guardring -- needed later for connecting global lines
    if _P.drawouterguardring then
        local active = cell:get_area_anchor("active_all")
        local holewidth_active = point.xdistance_abs(active.bl, active.tr)
        local holeheight_active = point.ydistance_abs(active.bl, active.tr)
        local lowerrowdevices = state._get_active_devices(function(device) return device.row == 1 end)
        local upperrowdevices = state._get_active_devices(function(device) return device.row == state.numrows end)
        local lowergateboundingbox = _get_dev_anchor(lowerrowdevices[1], "gateboundingbox")
        local uppergateboundingbox = _get_dev_anchor(upperrowdevices[1], "gateboundingbox")
        local holewidth_gate = point.xdistance_abs(lowergateboundingbox.bl, lowergateboundingbox.tr)
        local holeheight_gate = point.ydistance_abs(lowergateboundingbox.bl, uppergateboundingbox.tr)
        local holewidth = math.max(holewidth_active, holewidth_gate)
        local holeheight = math.max(holeheight_active, holeheight_gate)
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
            oxidetypeinnerextension = _P.guardringoxidetypeinnerextension,
            oxidetypeouterextension = _P.guardringoxidetypeouterextension,
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
        if _P.drawinnerguardrings then
            local row1devices = state._get_devices(function(device) return device.row == 1 end)
            local leftdevice = row1devices[1]
            local rightdevice = row1devices[#row1devices]
            interconnectlineminx = _get_dev_anchor(leftdevice, "outerguardring").l
            interconnectlinemaxx = _get_dev_anchor(rightdevice, "outerguardring").r
        else
            local row1devices = state._get_devices(function(device) return device.row == 1 end)
            local leftdevice = row1devices[1]
            local rightdevice = row1devices[#row1devices]
            local icvextension = math.max(_P.interconnectlineextension, _P.interconnectlineviawidth, _P.sdwidth)
            interconnectlineminx = _get_dev_anchor(leftdevice, "sourcedrainmetal1").l - (icvextension - _P.sdwidth) / 2
            interconnectlinemaxx = _get_dev_anchor(rightdevice, "sourcedrainmetal-1").r + (icvextension - _P.sdwidth) / 2
        end
    end

    -- create gate lines
    local gatelines = {}
    if _P.gatepos == "doublerow" then -- "doublerow" needs special treatment to avoid overlaps
        for rownum = 1, math.floor((state.numrows + 1) / 2) do
            -- gate lines cover all devices, not only active devices (use _get_device, not _get_active_device)
            local lowerdevices = state._get_devices(function(device) return device.row == 2 * rownum - 1 end)
            local upperdevices = state._get_devices(function(device) return device.row == 2 * rownum end)
            local leftlowerdevice = lowerdevices[1]
            local rightlowerdevice = lowerdevices[state.numinstancesperrow]
            local leftupperdevice = upperdevices[1]
            local rightupperdevice = upperdevices[state.numinstancesperrow]
            local devindices = state._get_uniq_row_devices_double(rownum)
            local lines = {}
            for _, di in ipairs(devindices) do
                local index = state._map_device_index_to_gate(di)
                if not util.any_of(index, lines) then
                    table.insert(lines, index)
                end
            end
            local numlines = #lines
            local yshiftbase = -(numlines - 1) / 2 * (_P.gatelinespace + _P.gatelinewidth)
            local gateline_center = 0.5 * point.ydistance_abs(
                _get_dev_anchor(leftupperdevice, "active").bl,
                _get_dev_anchor(leftlowerdevice, "active").tl
            ) + yshiftbase
            for line, index in ipairs(lines) do
                local yshift = (line - 1) * (_P.gatelinespace + _P.gatelinewidth)
                for _, r in ipairs({ 2 * rownum - 1, 2 * rownum }) do
                    cell:add_area_anchor_bltr(string.format("gateline_%d_%d", r, index),
                        point.create(
                            interconnectlineminx,
                            _get_dev_anchor(leftlowerdevice, "active").t + gateline_center + yshift - _P.gatelinewidth / 2
                        ),
                        point.create(
                            interconnectlinemaxx,
                            _get_dev_anchor(rightlowerdevice, "active").t + gateline_center + yshift + _P.gatelinewidth / 2
                        )
                    )
                end
                geometry.rectanglebltr(cell, generics.metal(_P.gatelinemetal),
                    cell:get_area_anchor_fmt("gateline_%d_%d", 2 * rownum - 1, index).bl,
                    cell:get_area_anchor_fmt("gateline_%d_%d", 2 * rownum - 1, index).tr
                )
                table.insert(gatelines, { rownum = 2 * rownum - 1, index = index })
            end
        end
    else
        for rownum = 1, state.numrows do
            local anchor = (_P.gatepos == "top") and "t" or "b"
            local sign = (_P.gatepos == "top") and 1 or -1
            local devindices = state._get_uniq_row_devices_single(rownum)
            local singlerowdevices = state._get_active_devices(function(device) return device.row == rownum end)
            if #devindices > 0 then -- check for dummy-only rows
                local leftdevice = singlerowdevices[1]
                local rightdevice = singlerowdevices[#singlerowdevices]
                local lines = util.uniq(util.foreach(devindices, state._map_device_index_to_gate))
                local yshift
                if _P.gatestrapsincenter then
                    yshift = _P.gatelinespace
                else -- not _P.gatestrapsincenter
                    if _P.interconnectlinepos == "gate" then
                        local yshift_gatestrap = _P.gatestrapspace + _P.gatestrapwidth + _P.gatelinespace
                        local numsourcelines = #util.uniq(util.foreach(devindices, state._map_device_index_to_source))
                        if _P.usesourcestraps then
                            numsourcelines = 0
                        end
                        local numdrainlines = #util.uniq(util.foreach(devindices, state._map_device_index_to_drain))
                        local yshift_sourcedrainline = 
                            (numsourcelines + numdrainlines) * _P.interconnectlinewidth +
                            (numsourcelines + numdrainlines + 1) * _P.interconnectlinespace
                        yshift = math.max(yshift_gatestrap, yshift_sourcedrainline)
                    else
                        yshift = _P.gatestrapspace + _P.gatestrapwidth + _P.gatelinespace
                    end
                end
                for line, lineindex in ipairs(lines) do
                    cell:add_area_anchor_points(string.format("gateline_%d_%d", rownum, lineindex),
                        point.create(
                            interconnectlineminx,
                            _get_dev_anchor(rightdevice, "active")[anchor] + sign * (yshift + (line - 1) * (_P.gatelinespace + _P.gatelinewidth) + _P.gatelinewidth)
                        ),
                        point.create(
                            interconnectlinemaxx,
                            _get_dev_anchor(leftdevice, "active")[anchor] + sign * (yshift + (line - 1) * (_P.gatelinespace + _P.gatelinewidth))
                        )
                    )
                    geometry.rectanglebltr(cell, generics.metal(_P.gatelinemetal),
                        cell:get_area_anchor_fmt("gateline_%d_%d", rownum, lineindex).bl,
                        cell:get_area_anchor_fmt("gateline_%d_%d", rownum, lineindex).tr
                    )
                    table.insert(gatelines, { rownum = rownum, index = lineindex })
                end
            end
        end
    end

    -- connect gates to gate lines
    if not _P.gatestrapsincenter then
        for rownum = 1, state.numrows do
            for colnum = 1, state.numinstancesperrow do
                local device = state._get_active_device(function(device) return (device.row == rownum) and (device.column == colnum) end)
                if device then -- not a dummy?
                    local spread = false
                    if _P.gatepos == "doublerow" then
                        -- FIXME: caution with odd-row patterns
                        local offset = (rownum % 2 == 0) and -1 or 1
                        local otherdevice = state._get_active_device(function(device) return (device.row == rownum + offset) and (device.column == colnum) end)
                        if otherdevice then
                            local gatenet1 = state._map_device_index_to_gate(device.device)
                            local gatenet2 = state._map_device_index_to_gate(otherdevice.device)
                            spread = gatenet1 ~= gatenet2
                        end
                    end
                    local gate
                    if _P.gatepos == "doublerow" then
                        gate = (rownum % 2 == 1) and "top" or "bot"
                    else
                        gate = (_P.gatepos == "top") and "top" or "bot"
                    end
                    local shiftamount
                    if _P.gatelineviapitch > 0 then
                        shiftamount = _P.gatelineviapitch
                    else
                        shiftamount = _P.gatelength + _P.gatespace
                    end
                    local shift = spread and (((rownum % 2) - 0.5) * shiftamount) or 0
                    local lineanchor
                    local gateanchor
                    if _P.gatepos == "doublerow" then
                        gateanchor = (rownum % 2 == 1) and "t" or "b"
                        lineanchor = (rownum % 2 == 1) and "b" or "t"
                    elseif _P.gatepos == "top" then
                        gateanchor = "t"
                        lineanchor = "b"
                    else -- _P.gatepos == "bottom"
                        gateanchor = "b"
                        lineanchor = "t"
                    end
                    -- draw connection line
                    geometry.rectanglepoints(cell, generics.metal(_P.gatemetal),
                        point.create(
                            0.5 * (
                                _get_dev_anchor(device, string.format("%sgatestrap", gate)).l +
                                _get_dev_anchor(device, string.format("%sgatestrap", gate)).r
                            ) - _P.gatefeedlinewidth / 2 + shift,
                            cell:get_area_anchor_fmt("gateline_%d_%d", rownum, state._map_device_index_to_gate(device.device))[lineanchor]
                        ),
                        point.create(
                            0.5 * (
                                _get_dev_anchor(device, string.format("%sgatestrap", gate)).l +
                                _get_dev_anchor(device, string.format("%sgatestrap", gate)).r
                            ) + _P.gatefeedlinewidth / 2 + shift,
                            _get_dev_anchor(device, string.format("%sgatestrap", gate))[gateanchor]
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
                            cell:get_area_anchor_fmt("gateline_%d_%d", rownum, state._map_device_index_to_gate(device.device)).b
                        ),
                        point.create(
                            0.5 * (
                                _get_dev_anchor(device, string.format("%sgatestrap", gate)).l +
                                _get_dev_anchor(device, string.format("%sgatestrap", gate)).r
                            ) + _P.gatelineviawidth / 2 + shift,
                            cell:get_area_anchor_fmt("gateline_%d_%d", rownum, state._map_device_index_to_gate(device.device)).t
                        ),
                        string.format("gate strap to gate line conncetion:\n    x parameters: gatelineviawidth (%d)\n    y parameters: gatelinewidth (%d)", _P.gatelineviawidth, _P.gatelinewidth)
                    )
                end
            end
        end
    end

    -- create interconnect lines
    local interconnectlines = {}
    if _P.interconnectlinepos == "inline" then
        for rownum = 1, state.numrows do
            local anchor
            local sign
            if rownum % 2 == 1 then
                anchor = "t"
                sign = -1
            else
                anchor = "b"
                sign = 1
            end
            local devnums = state._get_uniq_row_devices_single(rownum)
            local devices = state._get_active_devices(function(device) return device.row == rownum end)
            local leftdevice = devices[1]
            local rightdevice = devices[state.numinstancesperrow]
            local interconnectline_center = 0.5 * _P.fingerwidth
            local lines = {}
            -- add source lines
            if not _P.usesourcestraps then
                local sourcelines = util.uniq(util.foreach(devnums, state._map_device_index_to_source))
                for _, num in ipairs(sourcelines) do
                    table.insert(lines, string.format("source%d", num))
                end
            end
            -- add drain lines
            local drainlines = util.uniq(util.foreach(devnums, state._map_device_index_to_drain))
            for _, num in ipairs(drainlines) do
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
                        interconnectlineminx,
                        _get_dev_anchor(leftdevice, "active")[anchor] + sign * (interconnectline_center - (numlines * _P.interconnectlinewidth + (numlines - 1) * space) / 2 + (line - 1) * (space + _P.interconnectlinewidth))
                    ),
                    point.create(
                        interconnectlinemaxx,
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
    else -- "gate" or "offside"
        for rownum = 1, state.numrows do
            local anchor
            local sign
            if _P.interconnectlinepos == "gate" then
                if _P.gatepos == "doublerow" then
                    anchor = (rownum % 2 == 1) and "t" or "b"
                    sign = (rownum % 2 == 1) and 1 or -1
                else
                    anchor = (_P.gatepos == "top") and "t" or "b"
                    sign = (_P.gatepos == "top") and 1 or -1
                end
            else -- _P.interconnectlinepos == "offside"
                if _P.gatepos == "doublerow" then
                    anchor = (rownum % 2 == 1) and "b" or "t"
                    sign = (rownum % 2 == 1) and -1 or 1
                else
                    anchor = (_P.gatepos == "top") and "b" or "t"
                    sign = (_P.gatepos == "top") and -1 or 1
                end
            end
            local devindices = state._get_uniq_row_devices_single(rownum)
            local singlerowdevices = state._get_active_devices(function(device) return device.row == rownum end)
            if #devindices > 0 then -- check for dummy-only rows
                local leftdevice = singlerowdevices[1]
                local rightdevice = singlerowdevices[#singlerowdevices]
                local skipstrap = 0
                if _P.usesourcestraps then
                    if _P.interconnectlinepos == "offside" and not _P.sourcestrapsinside then
                        skipstrap = _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth
                    elseif _P.interconnectlinepos == "gate" and _P.sourcestrapsinside then
                        skipstrap = _P.sourcedrainstrapspace + _P.sourcedrainstrapwidth
                    end
                end
                local lines = {}
                -- add source lines
                if not _P.usesourcestraps then
                    local sourcelines = util.uniq(util.foreach(devindices, state._map_device_index_to_source))
                    for _, num in ipairs(sourcelines) do
                        table.insert(lines, string.format("source%d", num))
                    end
                end
                -- add drain lines
                local drainlines = util.uniq(util.foreach(devindices, state._map_device_index_to_drain))
                for _, num in ipairs(drainlines) do
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
            for rownum = 1, state.numrows do
                local devices = state._get_active_devices(function(device) return device.row == rownum end)
                for _, device in ipairs(devices) do
                    local sourceline = state._map_device_index_to_source(device.device)
                    for finger = 1, _P.fingers + 1, 2 do
                        local anchor = _get_dev_anchor(device, string.format("sourcedrain%d", finger))
                        local lineanchor = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline))
                        geometry.viabltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                            anchor.bl, anchor.tr,
                            lineanchor.bl, lineanchor.tr
                        )
                    end
                end
            end
        else -- "gate" or "offside"
            for rownum = 1, state.numrows do
                local devices = state._get_active_devices(function(device) return device.row == rownum end)
                for _, device in ipairs(devices) do
                    local sourceline = state._map_device_index_to_source(device.device)
                    for finger = 1, _P.fingers + 1, 2 do
                        local icvextension = math.max(_P.interconnectlineviawidth, _P.sdwidth)
                        local sdanchor = _get_dev_anchor(device, string.format("sourcedrain%d", finger))
                        local ytop
                        local ybottom
                        if _P.gatepos == "doublerow" then
                            if _P.interconnectlinepos == "gate" then
                                if rownum % 2 == 1 then
                                    ybottom = sdanchor.t
                                    ytop = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).t
                                else
                                    ybottom = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).b
                                    ytop = sdanchor.b
                                end
                            else
                                if rownum % 2 == 1 then
                                    ybottom = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).b
                                    ytop = sdanchor.b
                                else
                                    ybottom = sdanchor.t
                                    ytop = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).t
                                end
                            end
                        elseif _P.gatepos == "top" then
                            ybottom = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).b
                            ytop = sdanchor.b
                        else --_P.gatepos == "bottom"
                            ybottom = sdanchor.t
                            ytop = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).t
                        end
                        geometry.rectanglepoints(cell, generics.metal(_P.sourcemetal),
                            point.create(sdanchor.l, ybottom),
                            point.create(sdanchor.r, ytop)
                        )
                        if _P.sourcemetal ~= _P.interconnectmetal then
                            geometry.viabltrov(cell, _P.sourcemetal, _P.interconnectmetal,
                                point.create(
                                    0.5 * (sdanchor.l + sdanchor.r) - icvextension / 2,
                                    ybottom
                                ),
                                point.create(
                                    0.5 * (sdanchor.l + sdanchor.r) + icvextension / 2,
                                    ytop
                                ),
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).bl,
                                cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("source%d", sourceline)).tr,
                                string.format("source to interconnect line conncetion:\n    x parameters: max of interconnectlineviawidth/sdwidth (%d)\n    y parameters: interconnectlinewidth (%d)", icvextension, _P.interconnectlinewidth)
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
            for rownum = 1, state.numrows do
                local devices = state._get_active_devices(function(device) return device.row == rownum end)
                for _, device in ipairs(devices) do
                    local drainline = state._map_device_index_to_drain(device.device)
                    for finger = 2, _P.fingers + 1, 2 do
                        geometry.viabltrov(cell, _P.drainmetal, _P.interconnectmetal,
                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).bl,
                            _get_dev_anchor(device, string.format("sourcedrain%d", finger)).tr,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", drainline)).bl,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", drainline)).tr
                        )
                    end
                end
            end
        end
    else -- "gate" or "offside"
        for rownum = 1, state.numrows do
            local anchor
            if _P.interconnectlinepos == "gate" then
                if rownum % 2 == 1 then
                    anchor = "t"
                else
                    anchor = "b"
                end
            else
                if rownum % 2 == 1 then
                    anchor = "b"
                else
                    anchor = "t"
                end
            end
            local devices = state._get_active_devices(function(device) return device.row == rownum end)
            for _, device in ipairs(devices) do
                local drainline = state._map_device_index_to_drain(device.device)
                for finger = 2, _P.fingers + 1, 2 do
                    local icvextension = math.max(_P.interconnectlineviawidth, _P.sdwidth)
                    local sdanchor = _get_dev_anchor(device, string.format("sourcedrain%d", finger))
                    local ytop
                    local ybottom
                    if _P.gatepos == "doublerow" then
                        if _P.interconnectlinepos == "gate" then
                            if rownum % 2 == 1 then
                                ybottom = sdanchor.t
                                ytop = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", drainline)).t
                            else
                                ybottom = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", drainline)).b
                                ytop = sdanchor.b
                            end
                        else
                            if rownum % 2 == 1 then
                                ybottom = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", drainline)).b
                                ytop = sdanchor.b
                            else
                                ybottom = sdanchor.t
                                ytop = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", drainline)).t
                            end
                        end
                    elseif _P.gatepos == "top" then
                        ybottom = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", drainline)).b
                        ytop = sdanchor.b
                    else --_P.gatepos == "bottom"
                        ybottom = sdanchor.t
                        ytop = cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", drainline)).t
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
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", drainline)).bl,
                            cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, string.format("drain%d", drainline)).tr,
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
        local lowerrowdevices = state._get_devices(function(device) return device.row == 1 end)
        local lowerdevice = lowerrowdevices[1]
        local upperrowdevices = state._get_devices(function(device) return device.row == state.numrows end)
        local upperdevice = upperrowdevices[1]
        outputlineminy = _get_dev_anchor(lowerdevice, "active").b
        outputlinemaxy = _get_dev_anchor(upperdevice, "active").t
    elseif _P.interconnectlinepos == "gate" then
        local lowerrowdevices = state._get_devices(function(device) return device.row == 1 end)
        local lowerdevice = lowerrowdevices[1]
        local upperrowdevices = state._get_devices(function(device) return device.row == state.numrows end)
        local upperdevice = upperrowdevices[1]
        outputlineminy = _get_dev_anchor(lowerdevice, "active").b
        outputlinemaxy = _get_dev_anchor(upperdevice, "active").t
    else -- "offside"
        local lowerdevindices = state._get_uniq_row_devices_single(1)
        local lowerdevices = state._get_devices(function(device) return device.row == 1 end)
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
        local upperdevindices = state._get_uniq_row_devices_single(state.numrows)
        local upperdevices = state._get_devices(function(device) return device.row == state.numrows end)
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
    if _P.insertglobalguardringlines then
        if _P.drawouterguardring then
            local guardringboundary = cell:get_area_anchor("outerguardring")
            outputlinemaxy = math.max(outputlinemaxy, guardringboundary.tr:gety())
            outputlineminy = math.min(outputlineminy, guardringboundary.bl:gety())
        end
        if _P.drawinnerguardrings then
            local lowerdevices = state._get_devices(function(device) return device.row == 1 end)
            local upperdevices = state._get_devices(function(device) return device.row == state.numrows end)
            outputlineminy = _get_dev_anchor(lowerdevices[1], "outerguardring").b
            outputlinemaxy = _get_dev_anchor(upperdevices[1], "outerguardring").t
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
        local numsourcelines = #util.uniq(util.foreach(util.range(1, state.numdevices), state._map_device_index_to_source))
        for i = 1, numsourcelines do
            table.insert(outputlinespre.source, {
                base = "source",
                device = i,
            })
        end
        -- drain lines
        local numdrainlines = #util.uniq(util.foreach(util.range(1, state.numdevices), state._map_device_index_to_drain))
        for i = 1, numdrainlines do
            table.insert(outputlinespre.drain, {
                base = "drain",
                device = i,
            })
        end
        -- insert gate lines
        if state.numrows > 2 or _P.insertglobalgatelines then
            local numgatelines = #util.uniq(util.foreach(util.range(1, state.numdevices), state._map_device_index_to_gate))
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
    for rownum = 1, state.numrows do
        local devindices = state._get_uniq_row_devices_single(rownum)
        local lines = {}
        for _, di in ipairs(devindices) do
            local index = state._map_device_index_to_gate(di)
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
                local viafun = (_P.gatelinemetal == _P.interconnectmetal) and geometry.viabarebltrov or geometry.viabltrov
                viafun(cell, _P.gatelinemetal, _P.interconnectmetal + 1,
                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).bl,
                    cell:get_area_anchor_fmt("gateline_%d_%d", rownum, index).tr,
                    cell:get_area_anchor_fmt("outputconnectline_%s", netname).bl,
                    cell:get_area_anchor_fmt("outputconnectline_%s", netname).tr
                )
            end
        end
    end

    -- connect interconnect lines (source) to output lines
    if not _P.usesourcestraps then
        for rownum = 1, state.numrows do
            local devindices = state._get_uniq_row_devices_single(rownum)
            local lines = util.uniq(util.foreach(devindices, state._map_device_index_to_source))
            for line, index in ipairs(lines) do
                local sourceoutputlines = util.clone_array_predicate(outputlines,
                    function(e)
                        return e.base == "source" and e.device == index
                    end
                )
                for _, outputline in ipairs(sourceoutputlines) do
                    local netname = string.format("source%d", index)
                    local identifier
                    if outputline.variant then
                        identifier = string.format("%s_%d", netname, outputline.variant)
                    else
                        identifier = netname
                    end
                    geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, netname).bl,
                        cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, netname).tr,
                        cell:get_area_anchor_fmt("outputconnectline_%s", identifier).bl,
                        cell:get_area_anchor_fmt("outputconnectline_%s", identifier).tr
                    )
                end
            end
        end
    else -- _P.usesourcestraps
        local numsourcenets = #util.uniq(util.foreach(util.range(1, state.numdevices), state._map_device_index_to_source))
        if numsourcenets == 1 then
            local sourceoutputlines = util.clone_array_predicate(outputlines,
                function(e)
                    return e.base == "source" and e.device == 1
                end
            )
            for rownum = 1, state.numrows do
                local alldevices = state._get_devices(function(device) return device.row == rownum end)
                local leftdevice = alldevices[1]
                local rightdevice = alldevices[state.numinstancesperrow]
                for _, outputline in ipairs(sourceoutputlines) do
                    local netname = string.format("source%d", 1)
                    local identifier
                    if outputline.variant then
                        identifier = string.format("%s_%d", netname, outputline.variant)
                    else
                        identifier = netname
                    end
                    local viafun = (_P.sourcemetal == _P.interconnectmetal + 1) and geometry.viabarebltrov or geometry.viabltrov
                    viafun(cell, _P.sourcemetal, _P.interconnectmetal + 1,
                        _get_dev_anchor(leftdevice, "sourcestrap").bl,
                        _get_dev_anchor(rightdevice, "sourcestrap").tr,
                        cell:get_area_anchor_fmt("outputconnectline_%s", identifier).bl,
                        cell:get_area_anchor_fmt("outputconnectline_%s", identifier).tr
                    )
                end
            end
        else -- numsourcenets > 1
            -- this can not be reliable connected, hence it is caught in check()
        end
    end

    -- connect interconnect lines (drains) to output lines
    for rownum = 1, state.numrows do
        local devindices = state._get_uniq_row_devices_single(rownum)
        local lines = util.uniq(util.foreach(devindices, state._map_device_index_to_drain))
        for line, index in ipairs(lines) do
            local drainoutputlines = util.clone_array_predicate(outputlines,
                function(e)
                    return e.base == "drain" and e.device == index
                end
            )
            for _, outputline in ipairs(drainoutputlines) do
                local netname = string.format("drain%d", index)
                local identifier
                if outputline.variant then
                    identifier = string.format("%s_%d", netname, outputline.variant)
                else
                    identifier = netname
                end
                geometry.viabarebltrov(cell, _P.interconnectmetal, _P.interconnectmetal + 1,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, netname).bl,
                    cell:get_area_anchor_fmt("interconnectline_%d_%s", rownum, netname).tr,
                    cell:get_area_anchor_fmt("outputconnectline_%s", identifier).bl,
                    cell:get_area_anchor_fmt("outputconnectline_%s", identifier).tr
                )
            end
        end
    end

    -- connect gates lines to drain output lines
    for _, connection in ipairs(_P.connectgatetosourcedrain) do
        for rownum = 1, state.numrows do
            local devices = state._get_active_devices(function(device) return device.row == rownum end)
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
    do
        local sourceoutputlines = util.clone_array_predicate(outputlines, function(e) return e.base == "source" end)
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
    end

    -- add drain nets to output lines
    for i = 1, state.numdevices do
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

    -- add net labels for visual inspection (gate lines)
    if _P.annotate_gatelines then
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

    -- add net labels for visual inspection (interconnect lines)
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

    -- connect global guardring lines to guardrings
    if _P.insertglobalguardringlines and _P.connectguardringtogloballines then
        if _P.drawouterguardring then
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
        if _P.drawinnerguardrings then
            local lowerdevices = state._get_devices(function(device) return device.row == 1 end)
            local upperdevices = state._get_devices(function(device) return device.row == state.numrows end)
            for i = 1, 2 do
                geometry.viabltrov(cell, 1, _P.interconnectmetal + 1,
                    point.create(
                        _get_dev_anchor(lowerdevices[1], "outerguardring").l,
                        _get_dev_anchor(lowerdevices[1], "outerguardring").b
                    ),
                    point.create(
                        _get_dev_anchor(lowerdevices[state.numinstancesperrow], "outerguardring").r,
                        _get_dev_anchor(lowerdevices[state.numinstancesperrow], "innerguardring").b
                    ),
                    cell:get_area_anchor_fmt("outputconnectline_%s_%d", "guardring0", i).bl,
                    cell:get_area_anchor_fmt("outputconnectline_%s_%d", "guardring0", i).tr
                )
                geometry.viabltrov(cell, 1, _P.interconnectmetal + 1,
                    point.create(
                        _get_dev_anchor(upperdevices[1], "outerguardring").l,
                        _get_dev_anchor(upperdevices[1], "innerguardring").t
                    ),
                    point.create(
                        _get_dev_anchor(upperdevices[state.numinstancesperrow], "outerguardring").r,
                        _get_dev_anchor(upperdevices[state.numinstancesperrow], "outerguardring").t
                    ),
                    cell:get_area_anchor_fmt("outputconnectline_%s_%d", "guardring0", i).bl,
                    cell:get_area_anchor_fmt("outputconnectline_%s_%d", "guardring0", i).tr
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
