local M = {}

local layermap
local viarules
local config

function M.translate_metals(cell)
    debug.print("technology", "translate_metals()")
    debug.down()
    -- make relative metal (negative indices) absolute
    for s in cell:iter() do
        debug.print("technology", string.format("translating '%s'", s.lpp.typ))
        debug.down()
        if s.lpp.typ == "metal" then
            if s.lpp.value < 0 then
                s.lpp.value = config.metals + s.lpp.value + 1
            end
        elseif s.lpp.typ == "via" then
            debug.print("technology", string.format("via(%s, %s)", s.lpp.value.from, s.lpp.value.to))
            if s.lpp.value.from < 0 then
                s.lpp.value.from = config.metals + s.lpp.value.from + 1
            end
            if s.lpp.value.to < 0 then
                s.lpp.value.to = config.metals + s.lpp.value.to + 1
            end
            -- reorder
            if s.lpp.value.from > s.lpp.value.to then
                s.lpp.value.from, s.lpp.value.to = s.lpp.value.to, s.lpp.value.from
            end
        end
        debug.up()
    end
    debug.up()
end

local function _map_layer(layer, interface)
    local t = layermap[layer][interface]
    if not t then
        print(string.format("no layer information for '%s'\nif the layer is not provided, set it to 'UNUSED'", layer))
        os.exit(1)
    end
    if t == "UNUSED" then
        return nil
    else
        return generics.mapped(t)
    end
end

local function _remove_unused_shapes(cell)
    local i = 1
    while true do
        local s = cell.shapes[i]
        if not s then break end
        if not s.lpp then
            table.remove(cell.shapes, i)
        else
            i = i + 1
        end
    end
end

function M.map_layers(cell, interface)
    for shape in cell:iter() do
        if shape.lpp.typ ~= "mapped" then
            shape.lpp = _map_layer(shape.lpp:str(), interface)
        end
    end
    _remove_unused_shapes(cell)
end

local function _get_viaspec(layer)
    local t = viarules[layer]
    if not t then
        print(string.format("no via geometry specification for '%s'", layer))
        os.exit(1)
    end
    return t
end

local function _place_metals(cell, s)
    if s.lpp.typ == "via" then
        local m1, m2 = s.lpp:get()
        local s1 = s:copy()
        s1.lpp = generics.metal(m1)
        local s2 = s:copy()
        s2.lpp = generics.metal(m2)
        cell:add_shape(s1)
        cell:add_shape(s2)
    elseif s.lpp.typ == "contact" then
        local semi = s.lpp:get()
        local ssemi = s:copy()
        ssemi.lpp = generics.other(semi)
        local smetal = s:copy()
        smetal.lpp = generics.metal(1)
        cell:add_shape(ssemi)
        cell:add_shape(smetal)
    end
end

local function _place_vias(cell, s, interface)
    local layer = s.lpp:str()
    local viaspec = _get_viaspec(layer)
    local width = s:width()
    local height = s:height()
    local c = s:center()
    local xrep = math.max(1, math.floor((width + viaspec.xspace - 2 * viaspec.xencl) / (viaspec.width + viaspec.xspace)))
    local yrep = math.max(1, math.floor((height + viaspec.yspace - 2 * viaspec.yencl) / (viaspec.height + viaspec.yspace)))
    local xpitch = viaspec.width + viaspec.xspace
    local ypitch = viaspec.height + viaspec.yspace
    for _, lay in ipairs(viaspec.layers) do
        local enlarge = lay.enlarge or 0.0
        local o = geometry.multiple(
            geometry.rectangle(generics.mapped(lay.lpp[interface]), viaspec.width + enlarge, viaspec.height + enlarge),
            xrep, yrep, xpitch, ypitch
        )
        cell:merge_into(o:translate(c.x, c.y))
    end
end

function M.split_vias(cell)
    local numshapes = #cell.shapes
    local toremove = {}
    for i = 1, numshapes do
        local s = cell.shapes[i]
        if s.lpp.typ == "via" then
            table.insert(toremove, i)
            local from, to = s.lpp:get()
            for i = from, to - 1 do
                local sc = s:copy()
                sc.lpp = generics.via(i, i + 1)
                cell:add_shape(sc)
            end
            -- if start == end we still want to get the metal
            if from == to then
                local sc = s:copy()
                sc.lpp = generics.metal(from)
                cell:add_shape(sc)
            end
        end
    end
    -- remove dummy via entries
    for i, idx in ipairs(toremove) do
        -- table.remove shifts the element, so we have to shift the index by the number of deleted entries
        table.remove(cell.shapes, idx - i + 1)
    end
end

function M.create_via_geometries(cell, interface)
    local numshapes = #cell.shapes
    local toremove = {}
    for i = 1, numshapes do
        local s = cell.shapes[i]
        if s.lpp.typ == "via" or s.lpp.typ == "contact" then
            table.insert(toremove, i)
            _place_metals(cell, s)
            _place_vias(cell, s, interface)
        end
    end
    -- remove dummy via entries
    for i, idx in ipairs(toremove) do
        -- table.remove shifts the element, so we have to shift the index by the number of deleted entries
        table.remove(cell.shapes, idx - i + 1)
    end
end

local function _fix_pt_to_grid(pt)
    local round = function(num)
        return num >= 0 and math.floor(num + 0.5) or math.ceil(num - 0.5)
    end
    pt.x = config.grid * round(pt.x / config.grid)
    pt.y = config.grid * round(pt.y / config.grid)
end

function M.fix_to_grid(cell)
    for s in cell:iter() do
        if s.typ == "polygon" then
            for _, pt in ipairs(s.points) do
                _fix_pt_to_grid(pt)
            end
        elseif s.typ == "rectangle" then
            _fix_pt_to_grid(s.points.bl)
            _fix_pt_to_grid(s.points.tr)
        end
    end
end

local function _load_technology_file(name, what)
    local status, ret = pcall(dofile, string.format("%s/tech/%s/%s.lua", _get_opc_home(), name, what))
    if not status then
        print(ret)
        print(string.format("no %s for technology '%s' found", what, name))
        os.exit(exitcodes.technotfound)
    end
    return ret
end

function M.load(name)
    layermap = _load_technology_file(name, "layermap")
    viarules = _load_technology_file(name, "viarules")
    config   = _load_technology_file(name, "config")
end

return M
