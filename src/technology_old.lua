local viastrategies = _load_module("technology.vias")

--[[
local function _prepare_ports(cell)
    for i, port in pairs(cell.ports) do
        if port.layer:is_type("metal") then
            if port.layer.value < 0 then
                port.layer.value = config.metals + port.layer.value + 1
            end
        end
    end
end

local function _translate_layers(cell, export)
    for i, S in cell:iterate_shapes(function(S) return not (S:is_lpp_type("mapped") or S:is_lpp_type("premapped")) end) do
        local layer = S:get_lpp():str()
        local mappings = layermap[layer]
        if not mappings then 
            if not envlib.get("ignoremissinglayers") then
                moderror(string.format("no layer information for '%s'\nif the layer is not provided, set it to {}", layer))
            end
        else
            for _, entry in ipairs(mappings) do
                if entry.action == "map" then
                    _do_map(cell, S, entry, export)
                elseif entry.action == "array" then
                    _do_array(cell, S, entry, export)
                end
            end
            cell:remove_shape(i)
        end
    end
end

local function _translate_ports(cell, export)
    local todelete = {}
    for i, port in pairs(cell.ports) do
        if port.layer:is_type("premapped") then
            local lpp = port.layer
            local newlpp = _get_lpp({ name = lpp:str(), lpp = lpp:get() }, export)
            if newlpp then
                port.layer = generics.mapped(lpp:str(), newlpp)
            else
                table.insert(todelete, i)
            end
        elseif not port.layer:is_type("mapped") then
            local layer = port.layer:str()
            local name = string.format("%sport", layer)
            local mappings = layermap[name]
            if not mappings then
                moderror(string.format("no layer information for '%s'\nif the layer is not provided, set it to {}", name))
            end
            -- FIXME: current implementation uses the first mapping, this should be improved
            local entry = mappings[1]
            entry = entry.func()
            local lpp = _get_lpp(entry, export)
            port.layer = generics.mapped(entry.name, lpp)
        end
    end
    table.sort(todelete, function(l, r) return l > r end)
    for _, i in ipairs(todelete) do table.remove(cell.ports, i) end
end

local function _fix_to_grid(cell)
    if config.grid then
        for _, S in cell:iterate_shapes() do
            for _, pt in pairs(S:get_points()) do
                pt:fix(config.grid)
            end
        end
    end
end
--]]
