local M = {}

local function _connections_match(c1, c2, connections)
    for _, c in ipairs(connections) do
        if c1[c] ~= c2[c] then
            return false
        end
    end
    return true
end

local function _parameters_match(p1, p2, ignore)
    for k, v in pairs(p1) do
        if v ~= p2[k] and not util.any_of(k, ignore) then
            return false
        end
    end
    return true
end

local function _can_merge_mosfet(m1, m2)
    -- device model has to be equal
    if not m1.model == m2.model then
    end
    -- all connections have to be the same
    local c1 = m1.connections
    local c2 = m2.connections
    if not _connections_match(m1.connections, m2.connections, { "gate", "drain", "source", "bulk" }) then
        return false
    end
    if not _parameters_match(m1.parameters, m2.parameters, { "fingers", "fingerwidth" }) then
        return false
    end
    -- FIXME: check parameters
    return true
end

local function _can_merge(device1, device2)
    -- device type has to be equal
    if not device1.type == device2.type then
        return false
    end
    -- currently only mosfets can be merged
    if device1.type == "mosfet" then
        return _can_merge_mosfet(device1, device2)
    end
    return false
end

local function _do_merge(device1, device2)
    if device1.type == "mosfet" then
        device1.parameters["fingers"] = device1.parameters["fingers"] + device2.parameters["fingers"]
        --device1.parameters["w"] = device1.parameters["w"] + device2.parameters["w"]
    end
end

function M.map_netlist_devices(netlist, devicemap, verbose)
    local devices = {}
    -- map devices to opc cells, parse parameters
    for _, subcircuit in ipairs(netlist) do
        for _, instance in ipairs(subcircuit) do
            local class = devicemap[instance.type]
            if not class then
                error(string.format("device map does not contain a class for '%s'", instance.type))
            end
            local entry = class[instance.model]
            if not entry then
                error(string.format("device map class for '%s' does not contain an entry of model '%s'", instance.type, instance.model))
            end
            local t = {}
            local parameters = entry.parameters
            for k, v in pairs(parameters) do
                t[k] = v
            end
            local mapped_parameters = entry.map_netlist_parameters(instance.parameters)
            for k, v in pairs(mapped_parameters) do
                t[k] = v
            end
            table.insert(devices, {
                cell = entry.cell,
                --name = string.format("%s_%s", subcircuit.name, instance.identifier),
                name = string.format("%s", instance.identifier),
                parameters = t,
                model = instance.model,
                type = instance.type,
                connections = instance.connections,
            })
        end
    end
    for idx1 = 1, #devices do
        local idx2 = idx1 + 1
        while true do
            if idx2 > #devices then
                break
            end
            local merge = _can_merge(devices[idx1], devices[idx2])
            if merge then
                if verbose then
                    print(string.format("merge devices %s and %s", devices[idx1].name, devices[idx2].name))
                end
                _do_merge(devices[idx1], devices[idx2])
                table.remove(devices, idx2)
            else
                -- only increment if device was not merged.
                -- Otherwise, the device is removed and the index stays here
                idx2 = idx2 + 1
            end
        end
    end
    return devices
end

function M.check(devices, placement)
    local searchfunc = function(pentry, name)
        return pentry.object == name
    end
    for _, device in ipairs(devices) do
        if not util.find_predicate(placement, searchfunc, device.name) then
            error(string.format("import.check: placement plan is not complete. No entry for device '%s'.", device.name))
        end
    end
end

-- default device mappings (factories)
M.maps = {}

local _map_mosfet_parameters = function(parameters)
    local result = {}
    local l = import.parse_string_float(parameters.l)
    local w = import.parse_string_float(parameters.w)
    local nf = import.parse_string_integer(parameters.nf)
    result.gatelength = l / 1e-9
    result.fingerwidth = w / nf / 1e-9
    result.fingers = nf
    return result
end

M.maps.mosfet = function(t)
    return {
        cell = "basic/mosfet",
        parameters = {
            channeltype = t.channeltype,
            vthtype = t.vthtype,
            oxidetype = t.oxidetype,
            flippedwell = t.flippedwell,
            connectsource = true,
            connectdrain = true,
            drawtopgate = true,
        },
        map_netlist_parameters = _map_mosfet_parameters,
    }
end

return M
