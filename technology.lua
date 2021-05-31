local M = {}

local layermap
local constraintsmeta = {}
constraintsmeta.__index = function() return 1 end -- fake get_dimension
local constraints = setmetatable({}, constraintsmeta)
local config

local techpaths = {}

-- make relative metal (negative indices) absolute
local function _translate_metals(cell)
    for _, S in cell:iterate_shapes(function(S) return S:get_lpp():is_type("metal") end) do
        if S:get_lpp().value < 0 then
            S:get_lpp().value = config.metals + S:get_lpp().value + 1
        end
    end
    for _, S in cell:iterate_shapes(function(S) return S:get_lpp():is_type("via") end) do
        local value = S:get_lpp().value
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

local function _place_via_conductors(cell)
    for _, S in cell:iterate_shapes() do
        if S:get_lpp():is_type("via") and not S:get_lpp().bare then
            local m1, m2 = S:get_lpp():get()
            local s1 = S:copy()
            s1:set_lpp(generics.metal(m1))
            local s2 = S:copy()
            s2:set_lpp(generics.metal(m2))
            cell:add_raw_shape(s1)
            cell:add_raw_shape(s2)
        elseif S:get_lpp():is_type("contact") and not S:get_lpp().bare then
            -- FIXME: can't place active contact surrounding as this needs more data than available here
            local smetal = S:copy()
            smetal:set_lpp(generics.metal(1))
            cell:add_raw_shape(smetal)
        end
    end
end

local function _split_vias(cell)
    for i, S in cell:iterate_shapes(function(S) return S:is_lpp_type("via") end) do
        local from, to = S:get_lpp():get()
        for j = from, to - 1 do
            local sc = S:copy()
            sc:set_lpp(generics.via(j, j + 1, S:get_lpp().bare))
            cell:add_raw_shape(sc)
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
    entry = entry.func(S:get_lpp():get())
    if entry.lpp then
        local new = S:copy()
        new:set_lpp(generics.mapped(entry.name, _get_lpp(entry.lpp, export)))
        if entry.left   > 0 or
           entry.right  > 0 or
           entry.top    > 0 or
           entry.bottom > 0
        then -- this check ensures that not-resized polygons work
            new:resize_lrtb(entry.left, entry.right, entry.top, entry.bottom)
        end
        cell:add_raw_shape(new)
    end
end

local function _do_array(cell, S, entry, export)
    entry = entry.func(S:get_lpp():get())
    local lpp = entry.lpp
    local width = S:width()
    local height = S:height()
    local c = S:center()
    local xrep = math.max(1, math.floor((width + entry.xspace - 2 * entry.xencl) / (entry.width + entry.xspace)))
    local yrep = math.max(1, math.floor((height + entry.yspace - 2 * entry.yencl) / (entry.height + entry.yspace)))
    local xpitch = entry.width + entry.xspace
    local ypitch = entry.height + entry.yspace
    local enlarge = 0
    local cut = geometry.multiple_xy(
        geometry.rectangle(generics.mapped(entry.name, _get_lpp(lpp, export)), entry.width + enlarge, entry.height + enlarge),
        xrep, yrep, xpitch, ypitch
    )
    cut:translate(entry.xshift or 0, entry.yshift or 0)

    cut:translate(c:unwrap())
    for _, S in cut:iterate_shapes() do
        local new = cell:add_raw_shape(S)
        new:apply_transformation(cut.trans, cut.trans.apply_transformation)
    end
end

local function _translate_layers(cell, export)
    for i, S in cell:iterate_shapes() do
        local layer = S:get_lpp():str()
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
end

local function _translate_ports(cell, export)
    for portname, port in pairs(cell.ports) do
        local layer = port.layer:str()
        local name = string.format("%sport", layer)
        local mappings = layermap[name]
        if not mappings then
            error(string.format("no layer information for '%s'\nif the layer is not provided, set it to {}", name))
        end
        -- FIXME: current implementation uses the first mapping, this should be improved
        local entry = mappings[1]
        entry = entry.func()
        port.layer = generics.mapped(entry.name, _get_lpp(entry.lpp, export))
    end
end

local function _fix_to_grid(cell)
    for _, S in cell:iterate_shapes() do
        for _, pt in pairs(S:get_points()) do
            pt:fix(config.grid)
        end
    end
end

local function _translate(cell, export)
    -- translate cell itself
    _translate_metals(cell)
    _split_vias(cell)
    _place_via_conductors(cell, export)
    _translate_layers(cell, export)
    _fix_to_grid(cell)
    -- translate children
    for _, child in cell:iterate_children() do
        _translate(child, export)
    end
end

function M.translate(cell, export)
    _translate(cell, export)
    _translate_ports(cell, export) -- ports are only translated on the toplevel
end

function M.get_dimension(dimension)
    local value = constraints[dimension]
    if not value then
        error(string.format("no dimension '%s' found", dimension))
    end
    return value
end

local function _get_tech_filename(name, what)
    for _, path in ipairs(techpaths) do
        local filename = string.format("%s/%s/%s.lua", path, name, what)
        if dir.exists(filename) then
            -- first found matching techfile is used
            return filename
        end
    end
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
                            name = entry.name,
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
                            name = entry.name,
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
    local filename = _get_tech_filename(name, "layermap")
    if not filename then
        error(string.format("no techfile for technology '%s' found", name))
    end
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
    local filename = _get_tech_filename(name, "constraints")
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
    local filename = _get_tech_filename(name, "config")
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

function M.add_techpath(path)
    table.insert(techpaths, path)
end

function M.list_techpaths()
    for _, path in ipairs(techpaths) do
        print(path)
    end
end

return M
