local M = {}

local viastrategies = _load_module("technology.vias")

local layermap
local constraintsmeta = {}
constraintsmeta.__index = function() return 1 end -- fake get_dimension
local constraints = setmetatable({}, constraintsmeta)
local config

local techpaths = {}

-- make relative metal (negative indices) absolute
local function _translate_metals(cell)
    for _, S in cell:iterate_shapes(function(S) return S:is_lpp_type("metal") end) do
        if S:get_lpp().value < 0 then
            S:get_lpp().value = config.metals + S:get_lpp().value + 1
        end
    end
    for _, S in cell:iterate_shapes(function(S) return S:is_lpp_type("via") end) do
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

local function _prepare_ports(cell)
    for i, port in pairs(cell.ports) do
        if port.layer:is_type("metal") then
            if port.layer.value < 0 then
                port.layer.value = config.metals + port.layer.value + 1
            end
        end
    end
end

local function _place_via_conductors(cell)
    for _, S in cell:iterate_shapes() do
        if S:is_lpp_type("via") and not S:get_lpp().bare then
            local m1, m2 = S:get_lpp():get()
            if not S:get_lpp().firstbare then
                local s1 = S:copy()
                s1:set_lpp(generics.metal(m1))
                cell:add_raw_shape(s1)
            end
            if not S:get_lpp().lastbare then
                local s2 = S:copy()
                s2:set_lpp(generics.metal(m2))
                cell:add_raw_shape(s2)
            end
        elseif S:is_lpp_type("contact") and not S:get_lpp().bare then
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
            -- FIXME: implement a proper copy() for generics
            sc:set_lpp(generics.via(j, j + 1, { 
                bare = S:get_lpp().bare,
                firstbare = S:get_lpp().firstbare,
                lastbare = S:get_lpp().lastbare,
                xcontinuous = S:get_lpp().xcontinuous,
                ycontinuous = S:get_lpp().ycontinuous,
            }))
            cell:add_raw_shape(sc)
        end
        cell:remove_shape(i)
    end
end

local function _get_lpp(entry, export)
    local lpp = entry.lpp
    if type(lpp) == "function" then
        lpp = lpp()
    end
    if not lpp[export] and not envlib.get("ignoremissingexport") then
        if entry.name then
            moderror(string.format("no layer information for layer '%s' for export type '%s'", entry.name, export))
        else
            moderror(string.format("no layer information for a requested layer was found (export type '%s'). This usually happens when an imported cell (e.g. from gds) gets exported to a different export type (e.g. SKILL). Check your cell definitions for 'premapped' layers", export))
        end
    end
    return lpp[export]
end

local function _do_map(cell, S, entry, export)
    entry = entry.func(S:get_lpp():get())
    if entry.lpp then
        local new = S:copy()
        local lpp = _get_lpp(entry, export)
        if lpp then
            new:set_lpp(generics.mapped(entry.name, lpp))
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
end

local function _get_via_arrayzation(width, height, entry, xcont, ycont)
    -- via strategy
    local xstrat = viastrategies[xcont and "continuous" or "fit"]
    local ystrat = viastrategies[ycont and "continuous" or "fit"]

    local _make_table = function(arg) if(type(arg) == "table") then return arg else return { arg } end end
    entry.width = _make_table(entry.width)
    entry.height = _make_table(entry.height)
    entry.xspace = _make_table(entry.xspace)
    entry.yspace = _make_table(entry.yspace)
    entry.xencl = _make_table(entry.xencl)
    entry.yencl = _make_table(entry.yencl)
    entry.conductivity = _make_table(entry.conductivity)
    entry.noneedtofit = _make_table(entry.noneedtofit)
    local via = {
        xrep = 0,
        yrep = 0,
        conductivity = 0
    }
    for i = 1, #entry.width do
        local xrep, xspace = xstrat(width, entry.width[i], entry.xspace[i], entry.xencl[i])
        local yrep, yspace = ystrat(height, entry.height[i], entry.yspace[i], entry.yencl[i])
        if entry.noneedtofit[i] then
            xrep = math.max(1, xrep)
            yrep = math.max(1, yrep)
        end
        local conductivity = entry.conductivity[i] or 1
        if xrep * yrep * conductivity > via.xrep * via.yrep * via.conductivity then
            via.width = entry.width[i]
            via.height = entry.height[i]
            via.xpitch = entry.width[i] + xspace
            via.ypitch = entry.height[i] + yspace
            via.xrep = xrep
            via.yrep = yrep
            via.conductivity = conductivity
        end
    end
    if not via.width then return nil end
    return via
end

local function _do_array(cell, S, entry, export)
    local xcont = S:get_lpp().xcontinuous
    local ycont = S:get_lpp().ycontinuous
    entry = entry.func(S:get_lpp():get())
    local width = S:get_width()
    local height = S:get_height()
    local c = S:get_center()
    local via = _get_via_arrayzation(width, height, entry, xcont, ycont)
    local isbare = S:get_lpp().bare
    if not via and entry.fallback and S:get_lpp().bare then
        via = { 
            width = entry.fallback.width, 
            height = entry.fallback.height,
            xrep = 1,
            yrep = 1,
            xpitch = 0,
            ypitch = 0
        }
    end
    if via then
        local enlarge = 0
        local lpp = _get_lpp(entry, export)
        local blx = -(via.width + enlarge) // 2
        local trx =  (via.width + enlarge) // 2
        local bly = -(via.height + enlarge) // 2
        local try =  (via.height + enlarge) // 2
        if (via.width + enlarge) % 2 ~= 0 then -- FIXME: make more flexible
            trx = trx + 1
            try = try + 1
        end
        local cut = geometry.multiple_xy(
            geometry.rectanglebltr(generics.mapped(entry.name, lpp), 
                point.create(blx, bly), point.create(trx, try)
            ),
            via.xrep, via.yrep, via.xpitch, via.ypitch
        )
        cut:translate(entry.xshift or 0, entry.yshift or 0)

        cut:translate(c:unwrap())
        for _, S in cut:iterate_shapes() do
            local new = cell:add_raw_shape(S)
            new:apply_transformation(cut.trans, cut.trans.apply_transformation)
        end
    else
        modwarning("could not fit via, the shape was ignored. The generated layout won't be electrically correct.")
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

local function _select_premapped_layers(cell, export)
    for i, S in cell:iterate_shapes(function(S) return S:is_lpp_type("premapped") end) do
        local lpp = S:get_lpp()
        local newlpp = _get_lpp({ name = lpp:str(), lpp = lpp:get() }, export)
        if newlpp then
            S:set_lpp(generics.mapped(lpp:str(), newlpp))
        else
            cell:remove_shape(i)
        end
    end
end

local function _translate(cell, export)
    _translate_layers(cell, export)
    _fix_to_grid(cell)
    _select_premapped_layers(cell, export)
    _translate_ports(cell, export)
end

local function _prepare(cell)
    _translate_metals(cell)
    _prepare_ports(cell)
    _split_vias(cell)
    _place_via_conductors(cell)
end

local function _foreach_cells(cell, func, ...)
    -- prepare cell itself
    func(cell, ...)
    -- prepare cell references
    for _, ref in pcell.iterate_cell_references() do
        func(ref, ...)
    end
end

function M.prepare(cell)
    _foreach_cells(cell, _prepare)
end

function M.translate(cell, export)
    _foreach_cells(cell, _translate, export)
end

function M.get_dimension(dimension)
    local value = constraints[dimension]
    if not value then
        moderror(string.format("no dimension '%s' found", dimension))
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
                        local t = {
                            name = entry.name,
                            lpp = entry.lpp,
                            width = entry.width,
                            height = entry.height,
                            xspace = entry.xspace,
                            yspace = entry.yspace,
                            xencl = entry.xencl,
                            yencl = entry.yencl,
                            conductivity = entry.conductivity or 1,
                            noneedtofit = entry.noneedtofit,
                            fallback = entry.fallback
                        }
                        return t
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
        moderror(string.format("no techfile for technology '%s' found", name))
    end
    local chunkname = "@techfile"

    local reader = _get_reader(filename)
    if not reader then
        moderror(string.format("no techfile for technology '%s' found", name))
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
    if not filename then
        moderror(string.format("no constraints for technology '%s' found", name))
    end
    local chunkname = "@techconstraints"

    local reader, msg = _get_reader(filename)
    if not reader then
        moderror(string.format("could not open constraints file for technology '%s' (reason: %d)", name, msg))
    end
    return _generic_load(
        reader, chunkname,
        string.format("syntax error while loading constraints for technology '%s'", name),
        string.format("semantic error while loading constraints for technology '%s'", name)
    )
end

local function _load_config(name)
    local filename = _get_tech_filename(name, "config")
    if not filename then
        moderror(string.format("no constraints for technology '%s' found", name))
    end
    local chunkname = "@techconfig"

    local reader, msg = _get_reader(filename)
    if not reader then
        moderror(string.format("could not open config file for technology '%s' (reason: %d)", name, msg))
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
