local M = {}

local layermap
local config

-- make relative metal (negative indices) absolute
function M.translate_metals(cell)
    for _, S in cell:iter(function(S) return S.lpp:is_type("metal") end) do
        if S.lpp.value < 0 then
            S.lpp.value = config.metals + S.lpp.value + 1
        end
    end
    for _, S in cell:iter(function(S) return S.lpp:is_type("via") end) do
        local value = S.lpp.value
        if value.from < 0 then
            value.from = config.metals + value.from + 1
        end
        if value.to < 0 then
            value.to = config.metals + value.to + 1
        end
        -- reorder
        if value.from > value.to then
            value.from, value.to = value.to, value.from
        end
    end
end

function M.place_via_conductors(cell)
    for _, S in cell:iter() do
        if S.lpp:is_type("via") then
            local m1, m2 = S.lpp:get()
            local s1 = S:copy()
            s1.lpp = generics.metal(m1)
            local s2 = S:copy()
            s2.lpp = generics.metal(m2)
            cell:add_shape(s1)
            cell:add_shape(s2)
        elseif S.lpp:is_type("contact") then
            -- FIXME: can't place active contact surrounding as this needs more data than available here
            local smetal = S:copy()
            smetal.lpp = generics.metal(1)
            cell:add_shape(smetal)
        end
    end
end

function M.split_vias(cell)
    for i, S in cell:iter(function(S) return S:is_lpp_type("via") end) do
        local from, to = S.lpp:get()
        for j = from, to - 1 do
            local sc = S:copy()
            sc.lpp = generics.via(j, j + 1)
            cell:add_shape(sc)
        end
        cell:remove_shape(i)
    end
end

local function _get_lpp(lpp, export)
    if type(lpp) == "function" then
        lpp = lpp()
    end
    if not lpp[export] then
        error(string.format("no layer information for export type '%s'", export))
    end
    return lpp[export]
end

local function _do_map(cell, S, entry, export)
    entry = entry.func(S.lpp:get())
    if entry.lpp then
        local new = S:copy()
        new.lpp = generics.mapped(_get_lpp(entry.lpp, export))
        if entry.left   > 0 or
           entry.right  > 0 or
           entry.top    > 0 or
           entry.bottom > 0
        then -- this check ensures that not-resized polygons work
            new:resize_lrtb(entry.left, entry.right, entry.top, entry.bottom)
        end
        cell:add_shape(new)
    end
end

local function _do_array(cell, S, entry, export)
    entry = entry.func(S.lpp:get())
    local lpp = entry.lpp
    local width = S:width()
    local height = S:height()
    local c = S:center()
    local xrep = math.max(1, math.floor((width + entry.xspace - 2 * entry.xencl) / (entry.width + entry.xspace)))
    local yrep = math.max(1, math.floor((height + entry.yspace - 2 * entry.yencl) / (entry.height + entry.yspace)))
    local xpitch = entry.width + entry.xspace
    local ypitch = entry.height + entry.yspace
    local enlarge = 0
    local cut = geometry.multiple(
        geometry.rectangle(generics.mapped(_get_lpp(lpp, export)), entry.width + enlarge, entry.height + enlarge),
        xrep, yrep, xpitch, ypitch
    )
    cut:translate(entry.xshift or 0, entry.yshift or 0)
    cell:merge_into(cut:translate(c:unwrap()))
end

function M.translate(cell, export)
    for i, S in cell:iter() do
        local layer = S.lpp:str()
        local mappings = layermap[layer]
        if not mappings then
            error(string.format("no layer information for '%s'\nif the layer is not provided, set it to {}", layer))
        end
        for _, entry in ipairs(mappings) do
            if entry.action == "map" then
                _do_map(cell, S, entry, export)
            elseif entry.action == "array" then
                _do_array(cell, S, entry, export)
            end
        end
        cell:remove_shape(i)
    end
    --[[
    for _, port in pairs(cell.ports) do
        local layer = port.layer:str()
    end
    --]]
end

function M.fix_to_grid(cell)
    for _, s in cell:iter() do
        for _, pt in pairs(s.points) do
            pt:fix(config.grid)
        end
    end
end

function M.get_dimension(dimension)
    local value = constraints[dimension]
    if not value then
        error(string.format("no dimension '%s' found", dimension))
    end
    return value
end

local function _load_layermap(name)
    local env = {
        map = function(entry)
            if type(entry) == "function" then
                return {
                    action = "map",
                    func = entry,
                }
            else -- table
                return {
                    action = "map",
                    func = function()
                        return {
                            lpp = entry.lpp,
                            left = entry.left or 0,
                            right = entry.right or 0,
                            top = entry.top or 0,
                            bottom = entry.bottom or 0,
                        }
                    end,
                }
            end
        end,
        array = function(entry)
            if type(entry) == "function" then
                return {
                    action = "array",
                    func = entry
                }
            else
                return {
                    action = "array",
                    func = function()
                        return {
                            lpp = entry.lpp,
                            width = entry.width,
                            height = entry.height,
                            xspace = entry.xspace,
                            yspace = entry.yspace,
                            xencl = entry.xencl,
                            yencl = entry.yencl,
                        }
                    end,
                }
            end
        end,
        refer = function(reference)
            return function()
                return layermap[reference]
            end
        end,
    }
    local filename = string.format("%s/tech/%s/layermap.lua", _get_opc_home(), name)
    local chunkname = "@techfile"

    local reader = _get_reader(filename)
    if not reader then
        error(string.format("no techfile for technology '%s' found", name))
    end
    return _generic_load(
        reader, chunkname,
        string.format("syntax error while loading layermap for technology '%s'", name),
        string.format("semantic error while loading layermap for technology '%s'", name),
        env
    )
end

local function _load_constraints(name)
    local filename = string.format("%s/tech/%s/constraints.lua", _get_opc_home(), name)
    local chunkname = "@techconstraints"

    local reader = _get_reader(filename)
    if not reader then
        error(string.format("no constraints for technology '%s' found", name))
    end
    return _generic_load(
        reader, chunkname,
        string.format("syntax error while loading constraints for technology '%s'", name),
        string.format("semantic error while loading constraints for technology '%s'", name)
    )
end

local function _load_config(name)
    local filename = string.format("%s/tech/%s/config.lua", _get_opc_home(), name)
    local chunkname = "@techconfig"

    local reader = _get_reader(filename)
    if not reader then
        error(string.format("no config for technology '%s' found", name))
    end
    return _generic_load(
        reader, chunkname,
        string.format("syntax error while loading config for technology '%s'", name),
        string.format("semantic error while loading config for technology '%s'", name)
    )
end

function M.load(name)
    layermap    = _load_layermap(name)
    constraints = _load_constraints(name)
    config      = _load_config(name)
end

return M
