--[[
TODO:
    * [ ] add support for varying grid line widths/spacings
    * [ ] extend gate/source/drain straps to fit the interconnect lines
    * [ ] put drain access line in the middle, as the drain strap is potentially of the smallest width
    * [ ] check that all devices in one group share the same bulk net
    * [ ] check group grid positions
--]]
function parameters()
    pcell.add_parameters(
        { "devicebases",                            {} },
        { "devices",                                {} },
        { "devicegroups",                           {} },
        { "auto_assign_groups",                     true },
        { "auto_assign_welltypes",                  true },
        { "minimum_device_xspace",                  0 },
        { "minimum_device_yspace",                  0 },
        { "default_gate_strap_width",               technology.get_dimension_max("Minimum M1 Width", "Minimum M1M2 Viawidth") },
        { "default_source_strap_width",             technology.get_dimension_max("Minimum M1 Width", "Minimum M1M2 Viawidth") },
        { "default_drain_strap_width",              technology.get_dimension_max("Minimum M1 Width", "Minimum M1M2 Viawidth") },
        { "access_grid",                            1, posvals = greaterzero() },
        { "guardringwidth",                         technology.get_dimension("Minimum Active Contact Region Size"), posvals = positive() },
        { "guardring_minimum_separation",           technology.get_dimension_max("Minimum M1 Space", "Minimum Active Space"), posvals = positive() },
        { "hlines",                                 {} },
        { "vlines",                                 {} },
        { "add_pin_lines",                          false },
        { "auto_assign_xylines",                    true },
        { "interconnectlinewidth",                  technology.get_dimension_max("Minimum M2 Width", "Minimum M1M2 Viawidth", "Minimum M2M3 Viawidth") },
        { "interconnectlinespace",                  technology.get_dimension_max("Minimum M2 Space", "Minimum M3 Space") },
        { "allow_grid_holes",                       false },
        { "allow_failed_grid_connections",          false },
        { "check_grid_connections",                 true },
        { "netlabel_size",                          technology.get_optional_dimension("Default Label Size", 0) },
        { "annotate_missing_device_connections",    true },
        { "annotate_device_bounding_boxes",         false },
        { "annotate_grid_cells",                    false }
    )
end

function check_pre(_P)
    -- check device names (present and unique)
    local devicenames = {} -- for uniqueness check
    for i, device in ipairs(_P.devices) do
        if not device.name then
            return false, string.format("device #%d does not specify 'name'", i)
        end
        if devicenames[device.name] then
            return false, string.format("device #%d uses an already-taken name '%s' (name previously assigned to device #%d)", i, device.name, devicenames[device.name])
        end
        devicenames[device.name] = i
    end

    -- check group names (present and unique)
    local groupnames = {} -- for uniqueness check
    for i, group in ipairs(_P.devicegroups) do
        if not group.name then
            return false, string.format("group #%d does not specify 'name'", i)
        end
        if groupnames[group.name] then
            return false, string.format("group #%d uses an already-taken name '%s' (name previously assigned to group #%d)", i, group.name, groupnames[group.name])
        end
        groupnames[group.name] = i
    end

    -- check that every group has a grid placement
    for i, group in ipairs(_P.devicegroups) do
        if not group.x then
            return false, string.format("group #%d does not specify an x-coordinate", i)
        end
        if not group.y then
            return false, string.format("group #%d does not specify a y-coordinate", i)
        end
    end

    -- check that every group has a welltype
    if not _P.auto_assign_welltypes then
        for i, group in ipairs(_P.devicegroups) do
            if not group.welltype then
                return false, string.format("group #%d does not specify 'welltype'", i)
            end
            if not ((group.welltype == "n") or (group.welltype == "p")) then
                return false, string.format("group #%d specifies an illegal welltype: '%s' (must be 'n' or 'p')", i, group.welltype)
            end
        end
    end

    -- check device bases
    for i, device in ipairs(_P.devices) do
        if device.base then
            if not _P.devicebases[device.base] then
                return false, string.format("device #%d ('%s') references a non-existing device base '%s'", i, device.name, device.base)
            end
        end
    end

    -- check that every device is in one and only one group
    for i, device in pairs(_P.devices) do
        if not device.dontplace then
            local counter = 0
            for _, group in ipairs(_P.devicegroups) do
                if util.any_of(device.name, group.devices) then
                    counter = counter + 1
                end
            end
            if (counter == 0) and not _P.auto_assign_groups then
                return false, string.format("device #%d ('%s') is not part of any group. Singular devices also must be put into a group.", i, device.name)
            end
            if counter > 1 then
                return false, string.format("device #%d ('%s') is part of more than one group. Every device must be in one and only one group.", i, device.name)
            end
        end
    end

    -- check that every device has a placement entry
    for i, device in pairs(_P.devices) do
        if not (device.x and device.y) then
            return false, string.format("device #%d ('%s') has no in-group placement specification (missing 'x' or 'y')", i, device.name)
        end
    end

    -- check that only allowed keys are set (devices)
    local allowed_keys = {
        "name",
        "base",
        "parameters",
        "nets",
        "x",
        "y",
        "dontplace",
    }
    for i, device in ipairs(_P.devices) do
        for k in pairs(device) do
            if not util.any_of(k, allowed_keys) then
                return false,
                    string.format(
                        "device #%d ('%s') sets the non-legal key '%s'. The only legal keys are %s.",
                        i, device.name,
                        k,
                        table.concat(allowed_keys, ", ")
                    )
            end
        end
    end

    -- check that all lines have an assigned net
    for i, line in ipairs(_P.hlines) do
        if not line.net or type(line.net) ~= "string" then
            return false, string.format("horizontal line #%d does not specify a net", i)
        end
    end
    for i, line in ipairs(_P.vlines) do
        if not line.net or type(line.net) ~= "string" then
            return false, string.format("vertical line #%d does not specify a net", i)
        end
    end

    -- check that only allowed keys are set (vlines)
    local allowed_keys = {
        "net",
        "group",
        "xgrid",
        "xline",
        "ygridstart",
        "ygridend",
        "ylinestart",
        "ylineend",
        "dontplace",
    }
    for i, line in ipairs(_P.vlines) do
        for k in pairs(line) do
            if not util.any_of(k, allowed_keys) then
                return false,
                    string.format(
                        "vertical line #%d (net '%s') sets the non-legal key '%s'. The only legal keys are %s.",
                        i, line.net,
                        k,
                        table.concat(allowed_keys, ", ")
                    )
            end
        end
    end

    -- check that only allowed keys are set (hlines)
    local allowed_keys = {
        "net",
        "group",
        "ygrid",
        "yline",
        "xgridstart",
        "xgridend",
        "xlinestart",
        "xlineend",
        "dontplace",
    }
    for i, line in ipairs(_P.hlines) do
        for k in pairs(line) do
            if not util.any_of(k, allowed_keys) then
                return false,
                    string.format(
                        "horizontal line #%d (net '%s') sets the non-legal key '%s'. The only legal keys are %s.",
                        i, line.net,
                        k,
                        table.concat(allowed_keys, ", ")
                    )
            end
        end
    end

    -- gather group names for line checks
    local groupnames = util.select_key(_P.devicegroups, "name")

    -- check that lines only reference existing groups (hlines)
    for i, line in ipairs(_P.hlines) do
        if line.group and not util.any_of(line.group, groupnames) then
            return false, string.format("horizontal line #%d (net '%s') references a non-existing group '%s'", i, line.net, line.group)
        end
    end

    -- check that lines only reference existing groups (vlines)
    for i, line in ipairs(_P.vlines) do
        if line.group and not util.any_of(line.group, groupnames) then
            return false, string.format("vertical line #%d (net '%s') references a non-existing group '%s'", i, line.net, line.group)
        end
    end

    return true
end

function prepare(_P)
    local state = {}

    state.device_pin_order = {
        bulk    = { order = 1, line = -2 },
        source  = { order = 2, line = -1 },
        gate    = { order = 3, line =  1 },
        drain   = { order = 4, line =  2 },
    }

    -- device storage and access functions
    state.devices = {}
    function state._get_devices(predicate, ...)
        local result = {}
        for _, device in ipairs(state.devices) do
            if predicate(device, ...) then
                table.insert(result, device)
            end
        end
        return result
    end
    local function _get_device(x, y)
        for _, device in ipairs(state.devices) do
            if device.x == x and device.y == y then
                return device
            end
        end
        cellerror(string.format("trying to look up device at (%d, %d), but it does not exist", x, y))
    end
    function state._get_device_anchor(x, y, anchor)
        local device = _get_device(x, y)
        return device.cell:get_area_anchor(anchor)
    end

    -- search helper function for in-group devices
    state.groupsearch = function(device, group)
        return util.any_of(device.name, group.devices)
    end

    -- grid helper function
    state.calculate_grid = function(value, grid)
        local factor = math.ceil(value / grid)
        if factor % 2 == 0 then
            factor = factor + 1
        end
        return factor * grid
    end

    -- copy device groups into state-owned array, in order to add new groups
    -- filter out unplaced groups
    state.devicegroups = {}
    for i, group in ipairs(_P.devicegroups) do
        if not group.dontplace then
            state.devicegroups[i] = group
        end
    end

    -- store resolved devices (combination of direct parameters and base templates)
    -- this table is later modified in layout() to also store the actual layout object for the device
    for _, device in ipairs(_P.devices) do
        if not device.dontplace then
            local d = {
                name = device.name,
                x = device.x,
                y = device.y,
                parameters = {},
                nets = {
                    gate = device.nets.gate,
                    source = device.nets.source,
                    drain = device.nets.drain,
                    bulk = device.nets.bulk,
                },
                -- filled later and used for connection verification
                connected = {
                    gate = false,
                    source = false,
                    drain = false,
                    --bulk = false,
                },
            }
            -- copy base parameters
            if device.base then
                for k, v in pairs(_P.devicebases[device.base]) do
                    d.parameters[k] = v
                end
            end
            -- copy potentially-existing overwriting instance parameters
            -- (order matters, instance parameters take priority over base parameters)
            if device.parameters then
                for k, v in pairs(device.parameters) do
                    d.parameters[k] = v
                end
            end
            -- find well type of device (for group assignment)
            local welltype
            if d.parameters.flippedwell then
                if d.parameters.channeltype == "nmos" then
                    welltype = "n"
                else
                    welltype = "p"
                end
            else
                if d.parameters.channeltype == "nmos" then
                    welltype = "p"
                else
                    welltype = "n"
                end
            end
            -- add group index to device
            -- (potentially a new group)
            local groupindex
            for gi, group in ipairs(state.devicegroups) do
                if util.any_of(device.name, group.devices) then
                    groupindex = gi
                    break
                end
            end
            if not groupindex then -- device not in a group, create a new one
                local group = { 
                    name = string.format("%s_group", d.name),
                    devices = { d.name },
                    -- inherit placement from device
                    x = d.x,
                    y = d.y,
                }
                table.insert(state.devicegroups, group)
                groupindex = #state.devicegroups
                -- if this device is in its own group, remove the placement information (set it to 1, 1)
                d.x = 1
                d.y = 1
            end
            -- assign group well type from device
            -- for groups with multiple devices this happens more than once
            -- however, equal well types are enforved for all devices
            -- within one group via parameter checks
            if _P.auto_assign_welltypes then
                state.devicegroups[groupindex].welltype = welltype
            end
            state.devicegroups[groupindex].net = d.nets.bulk
            d.group = groupindex
            table.insert(state.devices, d)
        end -- not device.dontplace
    end

    -- pre-fill ylines array for auto-assignment of unspecified grid lines
    local ylines = {}
    for _, line in ipairs(_P.hlines) do
        if line.yline then
            if not ylines[line.ygrid] then
                ylines[line.ygrid] = {}
            end
            table.insert(ylines[line.ygrid], line.yline)
        end
    end

    -- copy horizontal gridlines to state-owned array,
    -- auto-assign x line start/end to grid lines
    -- auto-assign y lines to grid lines
    state.hlines = {}
    for _, line in ipairs(_P.hlines) do
        if not line.dontplace then
            local xlinestart = line.xlinestart
            local xlineend = line.xlineend
            -- FIXME: simplify, merge, put in functions, etc.
            if not xlinestart then
                local ydevices = state._get_devices(function(device) return device.x == line.xgridstart and device.y == line.ygrid end)
                local targets = {}
                for _, device in ipairs(ydevices) do
                    for pin, entry in pairs(state.device_pin_order) do
                        if line.net == device.nets[pin] then
                            table.insert(targets, entry.line)
                        end
                    end
                end
                if #targets > 0 then
                    if line.xgridstart <= line.xgridend then
                        xlinestart = util.min(targets)
                    else
                        xlinestart = util.max(targets)
                    end
                end
            end
            if not xlineend then
                local ydevices = state._get_devices(function(device) return device.x == line.xgridend and device.y == line.ygrid end)
                local targets = {}
                for _, device in ipairs(ydevices) do
                    for pin, entry in pairs(state.device_pin_order) do
                        if line.net == device.nets[pin] then
                            table.insert(targets, entry.line)
                        end
                    end
                end
                if #targets > 0 then
                    if line.xgridend >= line.xgridstart then
                        xlineend = util.max(targets)
                    else
                        xlineend = util.min(targets)
                    end
                end
            end
            local yline = line.yline
            if not yline and _P.auto_assign_xylines then
                if not ylines[line.ygrid] then
                    ylines[line.ygrid] = {}
                end
                repeat
                    if not yline then
                        yline = 1
                    elseif yline > 0 then
                        yline = -yline
                    else
                        yline = -yline + 1
                    end
                until not util.any_of(yline, ylines[line.ygrid])
                table.insert(ylines[line.ygrid], yline)
            end
            table.insert(state.hlines, {
                group       = line.group,
                net         = line.net,
                xgridstart  = line.xgridstart,
                xgridend    = line.xgridend,
                xlinestart  = xlinestart,
                xlineend    = xlineend,
                ygrid       = line.ygrid,
                yline       = yline,
            })
        end
    end

    -- copy vertical gridlines to state-owned array,
    -- auto-assign y lines to grid lines
    -- the vertical grid lines follow the horizontal ones,
    -- when both are auto-assigned
    state.vlines = {}
    for _, line in ipairs(_P.vlines) do
        if not line.dontplace then
            local ylinestart = line.ylinestart
            local ylineend = line.ylineend
            -- if y lines are not specified, search for a matching horizontal grid line
            if not ylinestart then
                for _, hline in ipairs(state.hlines) do
                    if (line.ygridstart == hline.ygrid) and (line.net == hline.net) then
                        ylinestart = hline.yline
                        break
                    end
                end
                -- if no line was found keep the nil, which will
                -- raise an error in the parameter checks
            end
            if not ylineend then
                for _, hline in ipairs(state.hlines) do
                    if (line.ygridend == hline.ygrid) and (line.net == hline.net) then
                        ylineend = hline.yline
                        break
                    end
                end
                -- if no line was found keep the nil, which will
                -- raise an error in the parameter checks
            end
            table.insert(state.vlines, {
                group       = line.group,
                net         = line.net,
                xgrid       = line.xgrid,
                xline       = line.xline,
                ygridstart  = line.ygridstart,
                ygridend    = line.ygridend,
                ylinestart  = ylinestart,
                ylineend    = ylineend,
            })
        end
    end

    -- find minimum/maximum grid indices (device groups)
    state.minx = math.huge
    state.miny = math.huge
    state.maxx = -math.huge
    state.maxy = -math.huge
    for _, group in pairs(state.devicegroups) do
        state.minx = math.min(state.minx, group.x)
        state.miny = math.min(state.miny, group.y)
        state.maxx = math.max(state.maxx, group.x)
        state.maxy = math.max(state.maxy, group.y)
    end

    -- find minimum/maximum grid indices (pre-group devices)
    state.groupgridvalues = {}
    for index, group in ipairs(state.devicegroups) do
        local gdevices = state._get_devices(state.groupsearch, group)
        local minx = math.huge
        local miny = math.huge
        local maxx = -math.huge
        local maxy = -math.huge
        for _, device in pairs(gdevices) do
            minx = math.min(minx, device.x)
            miny = math.min(miny, device.y)
            maxx = math.max(maxx, device.x)
            maxy = math.max(maxy, device.y)
        end
        state.groupgridvalues[index] = {
            minx = minx,
            miny = miny,
            maxx = maxx,
            maxy = maxy,
        }
    end

    return state
end

function check(_P, state)
    -- check group grid targets (only one group per cell)
    local gridtargets = {}
    for i, group in pairs(state.devicegroups) do
        local index = util.find_predicate(
            gridtargets,
            function(cell, group)
                return cell.x == group.x and cell.y == group.y
            end,
            group
        )
        if index then
            return false, string.format("group #%d ('%s') is placed in an already-occupied grid cell (%d, %d)", i, group.name, group.x, group.y)
        end
        -- insert device grid target
        table.insert(gridtargets, { x = group.x, y = group.y })
    end

    -- check that no group is empty
    for i, group in ipairs(state.devicegroups) do
        local gdevices = state._get_devices(state.groupsearch, group)
        if (#gdevices == 0) and not group.dontplace then
            return false, string.format("group #%d ('%s') is empty", i, group.name)
        end
    end

    -- check welltype sanity of every group
    for i, group in ipairs(state.devicegroups) do
        local gdevices = state._get_devices(state.groupsearch, group)
        local num_nwell = 0
        local num_pwell = 0
        for _, device in ipairs(gdevices) do
            if device.parameters.flippedwell then
                if device.parameters.channeltype == "nmos" then
                    num_nwell = num_nwell + 1
                else
                    num_pwell = num_pwell + 1
                end
            else
                if device.parameters.channeltype == "nmos" then
                    num_pwell = num_pwell + 1
                else
                    num_nwell = num_nwell + 1
                end
            end
        end
        if (num_nwell > 0) and (num_pwell > 0) then
            return false, string.format("group #%d ('%s') contains devices with different well types", i, group.name)
        end
    end

    -- check in-group device grid targets (only one device per cell)
    for index, group in ipairs(state.devicegroups) do
        local gdevices = state._get_devices(state.groupsearch, group)
        local gridtargets = {}
        for _, device in ipairs(gdevices) do
            local index = util.find_predicate(
                gridtargets,
                function(cell, device)
                    return cell.x == device.x and cell.y == device.y
                end,
                device
            )
            if index then
                return false, string.format("placement entry for device '%s' is placed in an already-occupied grid cell (%d, %d) (group '%s')", device.name, device.x, device.y, group.name)
            end
            -- insert device grid target
            table.insert(gridtargets, { x = device.x, y = device.y })
        end
    end

    -- check that no group grid has holes
    if not _P.allow_grid_holes then
        for index, group in ipairs(state.devicegroups) do
            local gdevices = state._get_devices(state.groupsearch, group)
            local minx = state.groupgridvalues[index].minx
            local maxx = state.groupgridvalues[index].maxx
            for x = minx, maxx do
                local found = false
                for _, device in ipairs(gdevices) do
                    if x == device.x then
                        found = true
                        break
                    end
                end
                if not found then
                    return false, string.format("group #%d contains device x-placements with grid holes (minx: %d, maxx: %d)", index, minx, maxx)
                end
            end
            local miny = state.groupgridvalues[index].miny
            local maxy = state.groupgridvalues[index].maxy
            for y = miny, maxy do
                local found = false
                for _, device in ipairs(gdevices) do
                    if y == device.y then
                        found = true
                        break
                    end
                end
                if not found then
                    return false, string.format("group #%d contains device y-placements with grid holes (miny: %d, maxy: %d)", index, miny, maxy)
                end
            end
        end
    end

    -- check that the global grid does not contain any holes
    if not _P.allow_grid_holes then
        for x = state.minx, state.maxx do
            local found = false
            for _, group in ipairs(state.devicegroups) do
                if x == group.x then
                    found = true
                    break
                end
            end
            if not found then
                return false, string.format("the global grid contains group x-placements with grid holes (minx: %d, maxx: %d)", state.minx, state.maxx)
            end
        end
        for y = state.miny, state.maxy do
            local found = false
            for _, group in ipairs(state.devicegroups) do
                if y == group.y then
                    found = true
                    break
                end
            end
            if not found then
                return false, string.format("the global grid contains group y-placements with grid holes (miny: %d, maxy: %d)", state.miny, state.maxy)
            end
        end
    end

    -- check for existance of must-have parameters
    local paramlist = {
        "channeltype",
        "fingers",
        "fingerwidth",
        "gatelength",
    }
    for i, device in ipairs(state.devices) do
        for _, p in ipairs(paramlist) do
            if not device.parameters[p] then
                return false, string.format("device #%d does not specify '%s'", i, p)
            end
        end
    end

    -- check device nets presence
    for i, device in ipairs(state.devices) do
        if not device.nets then
            return false, string.format("device #%d does not specify any nets ('nets' property)", i)
        end
        if not device.nets.gate then
            return false, string.format("device #%d does not specify any gate nets ('gate' property in 'nets' table)", i)
        end
        if not device.nets.source then
            return false, string.format("device #%d does not specify any source nets ('source' property in 'nets' table)", i)
        end
        if not device.nets.drain then
            return false, string.format("device #%d does not specify any drain nets ('drain' property in 'nets' table)", i)
        end
        if not device.nets.bulk then
            return false, string.format("device #%d does not specify any bulk nets ('bulk' property in 'nets' table)", i)
        end
    end

    -- build device nets for net checks
    local devicenets = {}
    for i, device in ipairs(_P.devices) do
        for _, net in pairs(device.nets) do
            if not util.any_of(net, devicenets) then
                table.insert(devicenets, net)
            end
        end
    end
    -- build grid nets for net checks
    local gridnets = {}
    for _, line in ipairs(state.vlines) do
        if not util.any_of(line.net, gridnets) then
            table.insert(gridnets, line.net)
        end
    end
    for _, line in ipairs(state.hlines) do
        if not util.any_of(line.net, gridnets) then
            table.insert(gridnets, line.net)
        end
    end
    -- check nets
    if _P.check_grid_connections then
        for _, net in ipairs(devicenets) do
            if not util.any_of(net, gridnets) then
                return false, string.format("device net '%s' is not present in the grid line nets", net)
            end
        end
        for _, net in ipairs(gridnets) do
            if not util.any_of(net, devicenets) then
                return false, string.format("grid line net '%s' is not present in the device nets", net)
            end
        end
    end

    -- gather global and group grid coordinates
    local gridcoordinates = {
        global = {
            x = {},
            y = {}
        },
        groups = {},
    }
    for _, group in ipairs(state.devicegroups) do
        -- global (group) position
        gridcoordinates.global.x[group.x] = true
        gridcoordinates.global.y[group.y] = true
        -- local (in-group) device positions
        gridcoordinates.groups[group.name] = {
            x = {},
            y = {},
        }
        local gdevices = state._get_devices(state.groupsearch, group)
        for _, device in ipairs(gdevices) do
            gridcoordinates.groups[group.name].x[device.x] = true
            gridcoordinates.groups[group.name].y[device.y] = true
        end
    end

    -- check vertical lines
    for i, line in ipairs(state.vlines) do
        if not line.ygridstart then
            return false, string.format("vertical line #%d (net '%s') does not specify 'ygridstart'", i, line.net)
        end
        if not line.ygridend then
            return false, string.format("vertical line #%d (net '%s') does not specify 'ygridend'", i, line.net)
        end
        if not line.xgrid then
            return false, string.format("vertical line #%d (net '%s') does not specify 'xgrid'", i, line.net)
        end
        if not line.ylinestart then
            return false, string.format("vertical line #%d (net '%s') does not specify 'ylinestart'", i, line.net)
        end
        if not line.ylineend then
            return false, string.format("vertical line #%d (net '%s') does not specify 'ylineend'", i, line.net)
        end
        if not line.xline then
            return false, string.format("vertical line #%d (net '%s') does not specify 'xline'", i, line.net)
        end
        if line.group then
            if not gridcoordinates.groups[line.group].x[line.xgrid] then
                return false, string.format("vertical line #%d (net '%s') references a device on x-grid %d, which does not exist ('xgrid')", i, line.net, line.xgrid)
            end
            if not gridcoordinates.groups[line.group].y[line.ygridstart] then
                return false, string.format("vertical line #%d (net '%s') references a device on y-grid %d, which does not exist ('ygridstart')", i, line.net, line.ygridstart)
            end
            if not gridcoordinates.groups[line.group].y[line.ygridend] then
                return false, string.format("vertical line #%d (net '%s') references a device on y-grid %d, which does not exist ('ygridend')", i, line.net, line.ygridend)
            end
        else
            if not gridcoordinates.global.x[line.xgrid] then
                return false, string.format("vertical line #%d (net '%s') references a group on x-grid %d, which does not exist ('xgrid')", i, line.net, line.xgrid)
            end
            if not gridcoordinates.global.y[line.ygridstart] then
                return false, string.format("vertical line #%d (net '%s') references a group on y-grid %d, which does not exist ('ygridstart')", i, line.net, line.ygridstart)
            end
            if not gridcoordinates.global.y[line.ygridend] then
                return false, string.format("vertical line #%d (net '%s') references a group on y-grid %d, which does not exist ('ygridend')", i, line.net, line.ygridend)
            end
        end
    end

    -- check horizontal lines
    for i, line in ipairs(state.hlines) do
        if not line.xgridstart then
            return false, string.format("horizontal line #%d (net '%s') does not specify 'xgridstart'", i, line.net)
        end
        if not line.xgridend then
            return false, string.format("horizontal line #%d (net '%s') does not specify 'xgridend'", i, line.net)
        end
        if not line.ygrid then
            return false, string.format("horizontal line #%d (net '%s') does not specify 'ygrid'", i, line.net)
        end
        if not line.xlinestart then
            return false, string.format("horizontal line #%d (net '%s') does not specify 'xlinestart'", i, line.net)
        end
        if not line.xlineend then
            return false, string.format("horizontal line #%d (net '%s') does not specify 'xlineend'", i, line.net)
        end
        if not line.yline then
            return false, string.format("horizontal line #%d (net '%s') does not specify 'yline'", i, line.net)
        end
        if line.group then
            if not gridcoordinates.groups[line.group].y[line.ygrid] then
                return false, string.format("horizontal line #%d (net '%s') references a device on y-grid %d, which does not exist ('ygrid')", i, line.net, line.ygrid)
            end
            if not gridcoordinates.groups[line.group].x[line.xgridstart] then
                return false, string.format("horizontal line #%d (net '%s') references a device on x-grid %d, which does not exist ('xgridstart')", i, line.net, line.xgridstart)
            end
            if not gridcoordinates.groups[line.group].x[line.xgridend] then
                return false, string.format("horizontal line #%d (net '%s') references a device on x-grid %d, which does not exist ('xgridend')", i, line.net, line.xgridend)
            end
        else
            if not gridcoordinates.global.y[line.ygrid] then
                return false, string.format("horizontal line #%d (net '%s') references a group on y-grid %d, which does not exist ('ygrid')", i, line.net, line.ygrid)
            end
            if not gridcoordinates.global.x[line.xgridstart] then
                return false, string.format("horizontal line #%d (net '%s') references a group on x-grid %d, which does not exist ('xgridstart')", i, line.net, line.xgridstart)
            end
            if not gridcoordinates.global.x[line.xgridend] then
                return false, string.format("horizontal line #%d (net '%s') references a group on x-grid %d, which does not exist ('xgridend')", i, line.net, line.xgridend)
            end
        end
    end

    -- check non-overlap of routes
    local yoccupations = {}
    for i, line in ipairs(state.hlines) do
        local gridstart   = math.min(line.xgridstart, line.xgridend)
        local gridend     = math.max(line.xgridstart, line.xgridend)
        local linestart   = math.min(line.xlinestart, line.xlineend)
        local lineend     = math.max(line.xlinestart, line.xlineend)
        for _, oline in ipairs(yoccupations) do
            -- these conditions look like they're from hell, this is partly true.
            -- it's more innocuous than it looks, it just checking if the lines touch,
            -- first for the xgrid values, then for the xline values
            if line.group == oline.group then
                if (line.ygrid == oline.ygrid) and (line.yline == oline.yline) then
                    if (gridend >= oline.gridstart and gridend <= oline.gridend) or
                       (gridstart <= oline.gridend and gridstart >= oline.gridstart) or
                       (gridstart <= oline.gridstart and gridend >= oline.gridend) then
                        if (lineend >= oline.linestart and lineend <= oline.lineend) or
                           (linestart <= oline.lineend and linestart >= oline.linestart) or
                           (linestart <= oline.linestart and lineend >= oline.lineend) then
                            if line.net ~= oline.net then
                            end
                        end
                    end
                end
            end
        end
        table.insert(yoccupations, {
            index = i,
            gridstart   = gridstart,
            gridend     = gridend,
            linestart   = linestart,
            lineend     = lineend,
            ygrid       = line.ygrid,
            yline       = line.yline,
            net         = line.net,
            group       = line.group,
        })
    end

    return true
end

function layout(circuit, _P, _env, state)
    local gridpitch = _P.interconnectlinewidth + _P.interconnectlinespace
    local vmetal = 2
    local hmetal = 3

    -- grid settings (interconnect lines)
    local interconnectlinegrid = _P.interconnectlinewidth + _P.interconnectlinespace

    -- create objects to store the actual layout objects
    for index, group in ipairs(state.devicegroups) do
        group.object = object.create(string.format("device_group_%d", index))
    end

    -- create the layout in two passes:
    -- first, for every group create the devices and place them relatively to each other
    -- merge all these devices into their respective layout group
    -- then place a guardring around that layout group
    -- now there are several unplaced layout groups, these are now placed similar to the device internally

    -- create devices and store
    local commonopts = {
        drawwell = false,
        drawtopgate = true,
        topgatewidth = _P.default_gate_strap_width,
        topgateadjustforsdstraps = true,
        topgateminwidth = 3 * _P.interconnectlinewidth + 2 * _P.interconnectlinespace,
        connectsource = true,
        connectsourcewidth = _P.default_source_strap_width,
        connectsourcefullwidth = true,
        connectsourceminwidth = 3 * _P.interconnectlinewidth + 2 * _P.interconnectlinespace,
        sourcemetal = 1,
        connectdrain = true,
        connectdrainwidth = _P.default_drain_strap_width,
        connectdrainfullwidth = true,
        connectdrainminwidth = 3 * _P.interconnectlinewidth + 2 * _P.interconnectlinespace,
        drainmetal = 1,
        drawinstancebox = true,
        grid = _P.access_grid,
        --shapegrid = 2, -- FIXME: is this needed, could this help with placement?
    }
    local exclude_parameters = { -- parameters from basic/mosfet than can not be used in base/device specifications
        "instancename", "drawguardring", "shapegrid", "drawinstancebox",
        "drainmetal", "connectdrain", "sourcemetal", "connectsource",
        "drawwell", "drawtopgate", "topgateadjustforsdstraps",
    }
    for _, device in ipairs(state.devices) do
        local options = util.add_options(commonopts, {
            instancename = device.name,
            drawguardring = false, -- guard rings are drawn around device groups
        })
        for k, v in pairs(device.parameters) do
            if not util.any_of(k, exclude_parameters) then
                options[k] = v
            end
        end
        -- create layout of the device and store
        device.cell = pcell.create_layout("basic/mosfet", "_mosfet", options)
    end

    -- place devices within a group
    for index, group in ipairs(state.devicegroups) do
        -- in here, operate only on the devices that belong to this group
        local gdevices = state._get_devices(state.groupsearch, group)

        -- sort devices grid-wise (column first, then row)
        -- FIXME: why again?
        local sortfun = function(dev1, dev2)
            if dev1.y < dev2.y then
                return true
            elseif dev2.y < dev1.y then
                return false
            else
                return dev1.x < dev2.x
            end
        end
        table.sort(gdevices, sortfun)

        -- get all devices sizes within this group
        local gridsizes = {
            x = {},
            y = {},
        }
        for _, device in ipairs(gdevices) do
            gridsizes.x[device.x] = gridsizes.x[device.x] or 0
            gridsizes.y[device.y] = gridsizes.y[device.y] or 0
            local boundary = device.cell:get_bounding_box()
            local width = boundary.tr:getx() - boundary.bl:getx()
            local height = boundary.tr:gety() - boundary.bl:gety()
            local qwidth = state.calculate_grid(width, interconnectlinegrid)
            local qheight = state.calculate_grid(height, interconnectlinegrid)
            while qwidth - width < _P.minimum_device_xspace do
                qwidth = qwidth + interconnectlinegrid
            end
            while qheight - height < _P.minimum_device_yspace do
                qheight = qheight + interconnectlinegrid
            end
            gridsizes.x[device.x] = math.max(gridsizes.x[device.x], qwidth)
            gridsizes.y[device.y] = math.max(gridsizes.y[device.y], qheight)
        end
        if _P.allow_grid_holes then -- fill grid holes with 0
            for x = state.groupgridvalues[index].minx, state.groupgridvalues[index].maxx do
                if not gridsizes[x].x then
                    gridsizes[x].x = 0
                end
            end
            for y = state.groupgridvalues[index].miny, state.groupgridvalues[index].maxy do
                if not gridsizes[y].y then
                    gridsizes[y].y = 0
                end
            end
        end

        --[[
        -- calculate grid positions for placement
        local gridpositions = {
            -- only the gaps between devices are calculated,
            -- hence there is one less calculation than devices
            -- for easier placement later on, fill the first entry with 0, 0
            x = { 0 },
            y = { 0 },
        }
        for x = 1, state.maxx do
            for y = 1, state.maxy do
                gridpositions.x[x] = 1000
                gridpositions.y[y] = 0
            end
        end
        --]]

        -- place devices on-grid, but overlapping
        -- later, the placement is legalized with only on-grid movements
        for _, device in ipairs(gdevices) do
            local boundary = device.cell:get_bounding_box()
            local xcenter = evenodddiv2(boundary.bl:getx() + boundary.tr:getx())
            local ycenter = evenodddiv2(boundary.bl:gety() + boundary.tr:gety())
            device.cell:translate(-xcenter, -ycenter)
        end

        -- legalize placement (only with positive on-grid movements)
        for deviceindex, device in ipairs(gdevices) do
            local xshift = 0
            for x = state.groupgridvalues[index].minx, device.x do
                xshift = xshift + gridsizes.x[x]
            end
            local yshift = 0
            for y = state.groupgridvalues[index].miny, device.y do
                yshift = yshift + gridsizes.y[y]
            end
            local boundary = device.cell:get_bounding_box()
            local bblx = boundary.bl:getx()
            local bbly = boundary.bl:gety()
            local btrx = boundary.tr:getx()
            local btry = boundary.tr:gety()
            local width = btrx - bblx
            local height = btry - bbly
            local xcentershift = math.ceil((gridsizes.x[device.x] - width) / 2)
            local ycentershift = math.ceil((gridsizes.y[device.y] - height) / 2)
            local xmove = xshift + bblx - xcentershift
            local ymove = yshift + bbly - ycentershift
            device.cell:translate(xmove, ymove)
        end

        -- merge devices in the groups and store their bounding boxes for later
        for _, device in ipairs(gdevices) do
            group.object:merge_into(device.cell)
            group.object:inherit_all_anchors_with_prefix(device.cell, string.format("%s_", device.name))
            local bb = device.cell:get_bounding_box()
            group.object:add_area_anchor_bltr(
                string.format("%s_boundingbox", device.name),
                bb.bl, bb.tr
            )
        end

        -- add anchor for grid cell
        for _, device in ipairs(gdevices) do
            local boundary = group.object:get_area_anchor_fmt("%s_boundingbox", device.name)
            local x0 = evenodddiv2(boundary.tr:getx() + boundary.bl:getx())
            local y0 = evenodddiv2(boundary.tr:gety() + boundary.bl:gety())
            local width = gridsizes.x[device.x]
            local height = gridsizes.y[device.y]
            group.object:add_area_anchor_bltr(
                string.format("%s_gridcell", device.name),
                point.create(x0 - evenodddiv2(width), y0 - evenodddiv2(height)),
                point.create(x0 + evenodddiv2(width), y0 + evenodddiv2(height))
            )
            if _P.annotate_grid_cells then
                geometry.rectangleareaanchor(group.object, generics.special(), string.format("%s_gridcell", device.name))
            end
        end
    end

    -- fill FEOL layers in grid cells to avoid DRC issues
    for _, device in ipairs(state.devices) do
        local dgroup = state.devicegroups[device.group]
        local boundary = dgroup.object:get_area_anchor_fmt("%s_gridcell", device.name)
        -- oxide type
        geometry.rectanglebltr(dgroup.object, generics.oxide(device.parameters.oxidetype or 1), boundary.bl, boundary.tr)
        -- implant
        geometry.rectanglebltr(dgroup.object, generics.implant(device.parameters.channeltype or "nmos"), boundary.bl, boundary.tr)
        -- vtytype
        geometry.rectanglebltr(dgroup.object, generics.vthtype(device.parameters.channeltype or "nmos", device.parameters.vthtype or 1), boundary.bl, boundary.tr)
    end

    -- add guard rings around device groups
    for i, group in ipairs(state.devicegroups) do
        local searchfun = function(device)
            return util.any_of(device.name, group.devices)
        end
        local gdevices = state._get_devices(searchfun)
        local blx
        local bly
        local trx
        local try
        for _, device in ipairs(gdevices) do
            local boundary = group.object:get_area_anchor(string.format("%s_gridcell", device.name))
            blx = not blx and boundary.l or math.min(blx, boundary.l)
            bly = not bly and boundary.b or math.min(bly, boundary.b)
            trx = not trx and boundary.r or math.max(trx, boundary.r)
            try = not try and boundary.t or math.max(try, boundary.t)
        end
        -- the guardring width must be chosen so that N grid lines (and N - 1 grid spaces) fit perfectly
        local isxodd = (state.groupgridvalues[i].maxx - state.groupgridvalues[i].minx + 1) % 2 == 1
        local isyodd = (state.groupgridvalues[i].maxy - state.groupgridvalues[i].miny + 1) % 2 == 1
        local gminwidth = trx - blx
        local gminheight = try - bly
        local xspace = _P.guardring_minimum_separation
        local yspace = _P.guardring_minimum_separation
        local Nx = math.ceil((gminwidth + xspace) / (_P.interconnectlinewidth + _P.interconnectlinespace))
        local Ny = math.ceil((gminheight + yspace) / (_P.interconnectlinewidth + _P.interconnectlinespace))
        if Ny % 2 == 0 then
            Ny = Ny + 1
        end
        local holewidth = Nx * (_P.interconnectlinewidth + _P.interconnectlinespace)
        if not isxodd then
            holewidth = holewidth + interconnectlinegrid
        end
        local holeheight = Ny * (_P.interconnectlinewidth + _P.interconnectlinespace)
        if not isyodd then
            holeheight = holeheight + interconnectlinegrid
        end
        local guardring = pcell.create_layout(
            "auxiliary/guardring",
            "_guardring",
            {
                contype = group.welltype,
                ringwidth = group.guardringwidth or _P.guardringwidth,
                holewidth = holewidth,
                holeheight = holeheight,
                net = group.net,
                addtopnet = true,
                addbottomnet = true,
            }
        )
        guardring:move_point(guardring:get_area_anchor("innerboundary").bl, point.create(blx, bly))
        local xshift = evenodddiv2(holewidth - gminwidth)
        if not isxodd then
            xshift = xshift - interconnectlinegrid / 2
        end
        local yshift = evenodddiv2(holeheight - gminheight)
        if not isyodd then
            yshift = yshift - interconnectlinegrid / 2
        end
        guardring:translate(-xshift, -yshift)
        group.object:merge_into(guardring)
        group.object:inherit_net_shapes(guardring)
    end

    -- * now place the groups, similar to the placement of the devices *
    -- get all devices sizes within this group
    local gridsizes = {
        x = {},
        y = {},
    }
    for _, group in ipairs(state.devicegroups) do
        local boundary = group.object:get_bounding_box()
        gridsizes.x[group.x] = gridsizes.x[group.x] or 0
        gridsizes.y[group.y] = gridsizes.y[group.y] or 0
        local width = boundary.tr:getx() - boundary.bl:getx()
        local height = boundary.tr:gety() - boundary.bl:gety()
        local qwidth = state.calculate_grid(width, interconnectlinegrid)
        local qheight = state.calculate_grid(height, interconnectlinegrid)
        while qwidth - width < _P.minimum_device_xspace do
            qwidth = qwidth + interconnectlinegrid
        end
        while qheight - height < _P.minimum_device_yspace do
            qheight = qheight + interconnectlinegrid
        end
        gridsizes.x[group.x] = math.max(gridsizes.x[group.x], qwidth)
        gridsizes.y[group.y] = math.max(gridsizes.y[group.y], qheight)
    end
    if _P.allow_grid_holes then
        for x = state.minx, state.maxx do
            if not gridsizes[x].x then
                gridsizes[x].x = 0
            end
        end
        for y = state.miny, state.maxy do
            if not gridsizes[y].y then
                gridsizes[y].y = 0
            end
        end
    end

    --[[
    -- calculate grid positions for placement
    local gridpositions = {
        -- only the gaps between devices are calculated,
        -- hence there is one less calculation than devices
        -- for easier placement later on, fill the first entry with 0, 0
        x = { 0 },
        y = { 0 },
    }
    for x = 1, state.maxx do
        for y = 1, state.maxy do
            gridpositions.x[x] = 1000
            gridpositions.y[y] = 0
        end
    end
    --]]

    -- place devices on-grid, but overlapping
    -- later, the placement is legalized with only on-grid movements
    for _, group in ipairs(state.devicegroups) do
        local boundary = group.object:get_bounding_box()
        local xcenter = evenodddiv2(boundary.bl:getx() + boundary.tr:getx())
        local ycenter = evenodddiv2(boundary.bl:gety() + boundary.tr:gety())
        group.object:translate(-xcenter, -ycenter)
    end

    -- legalize placement (only with positive on-grid movements)
    for _, group in ipairs(state.devicegroups) do
        local xshift = 0
        for x = 1, group.x do
            xshift = xshift + gridsizes.x[x]
        end
        local yshift = 0
        for y = 1, group.y do
            yshift = yshift + gridsizes.y[y]
        end
        local boundary = group.object:get_bounding_box()
        local bblx = boundary.bl:getx()
        local bbly = boundary.bl:gety()
        local btrx = boundary.tr:getx()
        local btry = boundary.tr:gety()
        local width = btrx - bblx
        local height = btry - bbly
        local xcentershift = math.ceil((gridsizes.x[group.x] - width) / 2)
        local ycentershift = math.ceil((gridsizes.y[group.y] - height) / 2)
        local xmove = xshift + bblx - xcentershift
        local ymove = yshift + bbly - ycentershift
        group.object:translate(xmove, ymove)
    end

    -- merge the layout groups into the main object
    for _, group in ipairs(state.devicegroups) do
        circuit:merge_into(group.object)
        circuit:inherit_net_shapes(group.object)
    end

    -- add pin lines
    if _P.add_pin_lines then
        for _, device in ipairs(state.devices) do
            local dgroup = state.devicegroups[device.group]
            -- add interconnectlines
            local bb = dgroup.object:get_area_anchor(string.format("%s_boundingbox", device.name))
            local interconnectlinebot = bb.b
            local interconnectlinetop = bb.t
            local lines = {}
            -- FIXME: derive this from state.device_pin_order
            --table.insert(lines, {
            --    net = "bulk",
            --    --variant = 1,
            --    width = _P.interconnectlinewidth,
            --})
            table.insert(lines, {
                net = "source",
                width = _P.interconnectlinewidth,
            })
            table.insert(lines, {
                net = "gate",
                width = _P.interconnectlinewidth,
            })
            table.insert(lines, {
                net = "drain",
                width = _P.interconnectlinewidth,
            })
            --table.insert(lines, {
            --    net = "bulk",
            --    variant = 2,
            --    width = _P.interconnectlinewidth,
            --})
            local numlines = #lines
            local fullwidth = util.reduce(lines, function(value, line) return value + line.width end, 0)
            local activeanchor = dgroup.object:get_area_anchor(string.format("%s_active", device.name))
            local activewidth = point.xdistance_abs(activeanchor.bl, activeanchor.tr)
            local start = activeanchor.l
            local shift = (activewidth - (fullwidth + (numlines - 1) * _P.interconnectlinespace)) / 2
            for lineindex, line in ipairs(lines) do
                -- draw line
                local anchorname
                if line.variant then
                    anchorname = string.format("%s_%s_%d", device.name, line.net, line.variant)
                else
                    anchorname = string.format("%s_%s", device.name, line.net)
                end
                -- add numeric anchor
                circuit:add_area_anchor_bltr(
                    string.format("%s_line%d", device.name, lineindex),
                    point.create(start + shift, interconnectlinebot),
                    point.create(start + shift + line.width, interconnectlinetop)
                )
                -- add net-based anchor
                circuit:add_area_anchor_bltr(
                    anchorname,
                    point.create(start + shift, interconnectlinebot),
                    point.create(start + shift + line.width, interconnectlinetop)
                )
                circuit:add_label(device.nets[line.net], generics.metal(vmetal), circuit:get_area_anchor(anchorname).bl, _P.netlabel_size)
                circuit:add_label(device.nets[line.net], generics.metal(vmetal), circuit:get_area_anchor(anchorname).tl, _P.netlabel_size)
                geometry.rectangleareaanchor(circuit, generics.metal(vmetal), anchorname)
                -- connect to respective region
                local viaanchors = {}
                if line.net == "gate" then
                    table.insert(viaanchors, {
                        b = dgroup.object:get_area_anchor(string.format("%s_topgatestrap", device.name)).b,
                        t = dgroup.object:get_area_anchor(string.format("%s_topgatestrap", device.name)).t,
                    })
                elseif line.net == "source" then
                    table.insert(viaanchors, {
                        b = dgroup.object:get_area_anchor(string.format("%s_sourcestrap", device.name)).b,
                        t = dgroup.object:get_area_anchor(string.format("%s_sourcestrap", device.name)).t,
                    })
                elseif line.net == "drain" then
                    table.insert(viaanchors, {
                        b = dgroup.object:get_area_anchor(string.format("%s_drainstrap", device.name)).b,
                        t = dgroup.object:get_area_anchor(string.format("%s_drainstrap", device.name)).t,
                    })
                elseif line.net == "bulk" then
                    table.insert(viaanchors, {
                        b = dgroup.object:get_area_anchor(string.format("%s_outerguardring", device.name)).b,
                        t = dgroup.object:get_area_anchor(string.format("%s_innerguardring", device.name)).b,
                    })
                    table.insert(viaanchors, {
                        b = dgroup.object:get_area_anchor(string.format("%s_innerguardring", device.name)).t,
                        t = dgroup.object:get_area_anchor(string.format("%s_outerguardring", device.name)).t,
                    })
                else
                    cellerror(string.format("interconnect line on unknown net '%s'", line.net))
                end
                for _, anchor in ipairs(viaanchors) do
                    geometry.viabarebltr(circuit,
                        1, 2,
                        point.create(start + shift, anchor.b),
                        point.create(start + shift + line.width, anchor.t)
                    )
                end
                -- connect interconnect lines to gate/source/drain straps
                local pinstrapmap = {
                    drain = "drainstrap",
                    source = "sourcestrap",
                    gate = "topgatestrap",
                    bulk = nil, -- don't map bulk, guardring will always fit (FIXME: will it?)
                }
                local strapname = pinstrapmap[line.net]
                if strapname then
                    local strap = dgroup.object:get_area_anchor(string.format("%s_%s", device.name, strapname))
                    local line = circuit:get_area_anchor(anchorname)
                    local leftc = strap.l
                    local rightc = strap.r
                    if strap.l > line.l then
                        leftc = line.l
                    end
                    if strap.r < line.r then
                        rightc = line.r
                    end
                    geometry.rectanglebltr(circuit, generics.metal(1),
                        point.create(leftc, strap.b),
                        point.create(rightc, strap.t)
                    )
                end
                -- advance line array
                shift = shift + line.width + _P.interconnectlinespace
            end
        end
    else
        for _, device in ipairs(state.devices) do
            local dgroup = state.devicegroups[device.group]
            -- add anchors for gate/source/drain straps
            local pinstrapmap = {
                drain = "drainstrap",
                source = "sourcestrap",
                gate = "topgatestrap",
            }
            for pin, target in pairs(pinstrapmap) do
                local strap = dgroup.object:get_area_anchor_fmt("%s_%s", device.name, target)
                local anchorname = string.format("%s_%s", device.name, pin)
                circuit:add_area_anchor_bltr(anchorname, strap.bl, strap.tr)
                circuit:add_label(device.nets[pin], generics.metal(1), circuit:get_area_anchor(anchorname).bl, _P.netlabel_size)
                circuit:add_label(device.nets[pin], generics.metal(1), circuit:get_area_anchor(anchorname).br, _P.netlabel_size)
            end
        end
    end

    -- assemble grid positions for grid lines
    local globalgrid = {
        x = {},
        y = {}
    }
    local groupgrids = {}
    for index, group in ipairs(state.devicegroups) do
        local gdevices = state._get_devices(state.groupsearch, group)
        groupgrids[group.name] = {
            x = {},
            y = {}
        }
        -- in-group grid
        for _, device in ipairs(gdevices) do
            local bb = group.object:get_area_anchor_fmt("%s_boundingbox", device.name)
            groupgrids[group.name].x[device.x] = evenodddiv2(bb.bl:getx() + bb.tr:getx())
            groupgrids[group.name].y[device.y] = evenodddiv2(bb.bl:gety() + bb.tr:gety())
        end
        -- global grid
        local bb = group.object:get_bounding_box()
        globalgrid.x[group.x] = evenodddiv2(bb.bl:getx() + bb.tr:getx())
        globalgrid.y[group.y] = evenodddiv2(bb.bl:gety() + bb.tr:gety())
    end

    local function _get_grid_x(groupname, xgrid, xline)
        local grid
        if groupname then
            grid = groupgrids[groupname]
        else
            grid = globalgrid
        end
        return grid.x[xgrid] - _P.interconnectlinewidth / 2 + xline * (_P.interconnectlinewidth + _P.interconnectlinespace)
    end

    local function _get_grid_y(groupname, ygrid, yline)
        local grid
        if groupname then
            grid = groupgrids[groupname]
        else
            grid = globalgrid
        end
        return grid.y[ygrid] - _P.interconnectlinewidth / 2 + yline * (_P.interconnectlinewidth + _P.interconnectlinespace)
    end

    -- place vertical grid lines
    for gridlineindex, gridline in ipairs(state.vlines) do
        local anchorname = string.format("vgridline%d", gridlineindex)
        local xstart = _get_grid_x(gridline.group, gridline.xgrid, gridline.xline)
        local xend = xstart + _P.interconnectlinewidth
        local ystart = _get_grid_y(gridline.group, gridline.ygridstart, gridline.ylinestart)
        local yend = _get_grid_y(gridline.group, gridline.ygridend, gridline.ylineend)
        if gridline.ygridstart > gridline.ygridend then
            ystart = ystart + _P.interconnectlinewidth
        else
            yend = yend + _P.interconnectlinewidth
        end
        circuit:add_area_anchor_points(anchorname,
            point.create(xstart, ystart),
            point.create(xend, yend)
        )
        local lineanchor = circuit:get_area_anchor(anchorname)
        geometry.rectanglebltr(circuit, generics.metal(vmetal), lineanchor.bl, lineanchor.tr)
        circuit:add_net_shape(gridline.net, lineanchor.bl, lineanchor.tr, generics.metal(vmetal))
        local labely = ystart
        while labely <= yend do
            circuit:add_label(gridline.net, generics.metal(vmetal), point.create(xstart, labely), _P.netlabel_size)
            labely = labely + 4 * gridpitch
        end
    end

    -- place horizontal grid lines
    for gridlineindex, gridline in ipairs(state.hlines) do
        local anchorname = string.format("hgridline%d", gridlineindex)
        local x1 = _get_grid_x(gridline.group, gridline.xgridstart, gridline.xlinestart)
        local x2 = _get_grid_x(gridline.group, gridline.xgridend, gridline.xlineend)
        local xstart
        local xend
        if x1 > x2 then
            xstart = x2
            xend = x1 + _P.interconnectlinewidth
        else
            xstart = x1
            xend = x2 + _P.interconnectlinewidth
        end
        local ystart = _get_grid_y(gridline.group, gridline.ygrid, gridline.yline)
        local yend = ystart + _P.interconnectlinewidth
        circuit:add_area_anchor_points(anchorname,
            point.create(xstart, ystart),
            point.create(xend, yend)
        )
        local lineanchor = circuit:get_area_anchor(anchorname)
        geometry.rectanglebltr(circuit, generics.metal(hmetal), lineanchor.bl, lineanchor.tr)
        circuit:add_net_shape(gridline.net, lineanchor.bl, lineanchor.tr, generics.metal(hmetal))
        local labelx = xstart
        while labelx <= xend do
            circuit:add_label(gridline.net, generics.metal(hmetal), point.create(labelx, ystart), _P.netlabel_size)
            labelx = labelx + 4 * gridpitch
        end
    end

    -- connect grid lines to devices
    if _P.add_pin_lines then
        for gridlineindex, gridline in ipairs(state.hlines) do
            for _, device in ipairs(state.devices) do
                for _, pin in ipairs({ "gate", "source", "drain" }) do
                    local net = device.nets[pin]
                    if net == gridline.net then
                        -- FIXME: 'anchorname' needs better automatic handling of line variants,
                        -- but this also requires improvements in the adding of the lines
                        local anchorname = string.format("%s_%s", device.name, pin)
                        local cancreate = true
                        if _P.allow_failed_grid_connections then
                            cancreate = geometry.check_viabltrov(
                                2, 3,
                                circuit:get_area_anchor_fmt("hgridline%d", gridlineindex).bl,
                                circuit:get_area_anchor_fmt("hgridline%d", gridlineindex).tr,
                                circuit:get_area_anchor(anchorname).bl,
                                circuit:get_area_anchor(anchorname).tr
                            )
                        end
                        if cancreate then
                            geometry.viabltrov(circuit, 2, 3,
                                circuit:get_area_anchor_fmt("hgridline%d", gridlineindex).bl,
                                circuit:get_area_anchor_fmt("hgridline%d", gridlineindex).tr,
                                circuit:get_area_anchor(anchorname).bl,
                                circuit:get_area_anchor(anchorname).tr
                            )
                            device.connected[pin] = true
                        end
                    end
                end
            end
        end
    else -- not _P.add_pin_lines
        for gridlineindex, gridline in ipairs(state.vlines) do
            for _, device in ipairs(state.devices) do
                for _, pin in ipairs({ "gate", "source", "drain" }) do
                    local net = device.nets[pin]
                    if net == gridline.net then
                        -- FIXME: 'anchorname' needs better automatic handling of line variants,
                        -- but this also requires improvements in the adding of the lines
                        local anchorname = string.format("%s_%s", device.name, pin)
                        local cancreate = true
                        if _P.allow_failed_grid_connections then
                            cancreate = geometry.check_viabltrov(
                                1, 2,
                                circuit:get_area_anchor_fmt("vgridline%d", gridlineindex).bl,
                                circuit:get_area_anchor_fmt("vgridline%d", gridlineindex).tr,
                                circuit:get_area_anchor(anchorname).bl,
                                circuit:get_area_anchor(anchorname).tr
                            )
                        end
                        if cancreate then
                            geometry.viabltrov(circuit, 1, 2,
                                circuit:get_area_anchor_fmt("vgridline%d", gridlineindex).bl,
                                circuit:get_area_anchor_fmt("vgridline%d", gridlineindex).tr,
                                circuit:get_area_anchor(anchorname).bl,
                                circuit:get_area_anchor(anchorname).tr
                            )
                            device.connected[pin] = true
                        end
                    end
                end
            end
        end
    end

    -- connect vertical and horizontal grid lines
    for hgridlineindex, hgridline in ipairs(state.hlines) do
        for vgridlineindex, vgridline in ipairs(state.vlines) do
            if hgridline.net == vgridline.net then
                local cancreate = true
                if _P.allow_failed_grid_connections then
                    cancreate = geometry.check_viabltrov(
                        2, 3,
                        circuit:get_area_anchor_fmt("hgridline%d", hgridlineindex).bl,
                        circuit:get_area_anchor_fmt("hgridline%d", hgridlineindex).tr,
                        circuit:get_area_anchor_fmt("vgridline%d", vgridlineindex).bl,
                        circuit:get_area_anchor_fmt("vgridline%d", vgridlineindex).tr
                    )
                end
                if cancreate then
                    geometry.viabltrov(circuit, 2, 3,
                        circuit:get_area_anchor_fmt("hgridline%d", hgridlineindex).bl,
                        circuit:get_area_anchor_fmt("hgridline%d", hgridlineindex).tr,
                        circuit:get_area_anchor_fmt("vgridline%d", vgridlineindex).bl,
                        circuit:get_area_anchor_fmt("vgridline%d", vgridlineindex).tr
                    )
                end
            end
        end
    end

    -- annotate partially or fully unconnected devices
    if _P.annotate_missing_device_connections then
        for _, device in ipairs(state.devices) do
            local not_connected = {}
            for pin, c in pairs(device.connected) do
                if not c then
                    table.insert(not_connected, pin)
                end
            end
            if #not_connected > 0 then
                local dgroup = state.devicegroups[device.group]
                local boundary = dgroup.object:get_area_anchor_fmt("%s_boundingbox", device.name)
                geometry.rectanglebltr(circuit, generics.error(), boundary.bl, boundary.tr)
                for _, pin in ipairs(not_connected) do
                    local anchorname = string.format("%s_%s", device.name, pin)
                    geometry.rectanglebltr(circuit, generics.error(),
                        circuit:get_area_anchor(anchorname).bl,
                        circuit:get_area_anchor(anchorname).tr
                    )
                end
            end
        end
    end

    -- annotate bounding boxes
    if _P.annotate_device_bounding_boxes then
        for i, group in ipairs(state.devicegroups) do
            local searchfun = function(device)
                return util.any_of(device.name, group.devices)
            end
            local gdevices = state._get_devices(searchfun)
            local blx
            local bly
            local trx
            local try
            for _, device in ipairs(gdevices) do
                local boundary = group.object:get_area_anchor(string.format("%s_boundingbox", device.name))
                geometry.rectanglebltr(circuit, generics.special(), boundary.bl, boundary.tr)
            end
        end
    end

    -- fill up empty space with horizontal lines
    --[[
    for i = 1, 8 do
        local x1 = _get_grid_x(nil, 1, 1)
        local x2 = _get_grid_x(nil, 1, -1)
        local xstart
        local xend
        if x1 > x2 then
            xstart = x2
            xend = x1 + _P.interconnectlinewidth
        else
            xstart = x1
            xend = x2 + _P.interconnectlinewidth
        end
        local ystart = _get_grid_y(nil, 1, i)
        local yend = ystart + _P.interconnectlinewidth
        geometry.rectanglebltr(circuit, generics.metal(hmetal),
            point.create(xstart, ystart),
            point.create(xend, yend)
        )
    end
    --]]
end
