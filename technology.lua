local M = {}

local layermap
local viarules
local config

function M.translate_metals(cell)
    -- make relative metal (negative indices) absolute
    for s in cell:iter() do
        if s.lpp.typ == "metal" then
            if s.lpp.value < 0 then
                s.lpp.value = config.metals + s.lpp.value + 1
            end
        elseif s.lpp.typ == "via" then
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
    end
end

local function _map_layer(layer)
    local t = layermap[layer]
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

function M.map_layers(cell)
    for shape in cell:iter() do
        if shape.lpp.typ ~= "mapped" then
            shape.lpp = _map_layer(shape.lpp:str())
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
    return viarules[layer]
end

local function _place_metals(cell, lpp, pts)
    if lpp.typ == "via" then
        local m1, m2 = lpp:get()
        local s1 = shape.create(generics.metal(m1))
        s1.points = pts
        local s2 = shape.create(generics.metal(m2))
        s2.points = pts
        cell:add_shape(s1)
        cell:add_shape(s2)
    elseif lpp.typ == "contact" then
        local semi = lpp:get()
        local ssemi = shape.create(generics.other(semi))
        ssemi.points = pts
        local smetal = shape.create(generics.metal(1))
        smetal.points = pts
        cell:add_shape(ssemi)
        cell:add_shape(smetal)
    end
end

local function _place_vias(cell, lpp, pts)
    local layer = lpp:str()
    local viaspec = _get_viaspec(layer)
    local width = math.abs(pts[3].x - pts[1].x)
    local height = math.abs(pts[3].y - pts[1].y)
    local x = 0.5 * (pts[1].x + pts[3].x)
    local y = 0.5 * (pts[1].y + pts[3].y)
    local xrep = math.max(1, math.floor((width + viaspec.xspace - 2 * viaspec.xencl) / (viaspec.width + viaspec.xspace)))
    local yrep = math.max(1, math.floor((height + viaspec.yspace - 2 * viaspec.yencl) / (viaspec.height + viaspec.yspace)))
    local xpitch = viaspec.width + viaspec.xspace
    local ypitch = viaspec.height + viaspec.yspace
    for _, lay in ipairs(viaspec.layers) do
        local enlarge = lay.enlarge or 0.0
        local o = layout.multiple(
            layout.rectangle(generics.mapped(lay.lpp), viaspec.width + enlarge, viaspec.height + enlarge),
            xrep, yrep, xpitch, ypitch
        )
        cell:merge_into(o:translate(x, y))
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

function M.create_via_geometries(cell)
    local numshapes = #cell.shapes
    local toremove = {}
    for i = 1, numshapes do
        local s = cell.shapes[i]
        if s.lpp.typ == "via" or s.lpp.typ == "contact" then
            table.insert(toremove, i)
            _place_metals(cell, s.lpp, s.points)
            _place_vias(cell, s.lpp, s.points)
        end
    end
    -- remove dummy via entries
    for i, idx in ipairs(toremove) do
        -- table.remove shifts the element, so we have to shift the index by the number of deleted entries
        table.remove(cell.shapes, idx - i + 1)
    end
end

local function _fix_pt_to_grid(pt)
    pt.x = config.grid * math.floor(pt.x / config.grid)
    pt.y = config.grid * math.floor(pt.y / config.grid)
end

function M.fix_to_grid(cell)
    for s in cell:iter() do
        for pt in s.points:iter_forward() do
            _fix_pt_to_grid(pt)
        end
    end
end

local function _load_technology_file(name, what)
    local status, ret = pcall(require, string.format("tech.%s.%s", name, what))
    if not status then
        print(string.format("no %s for technology '%s' found", what, name))
        os.exit(1)
    end
    return ret
end

function M.load(name)
    layermap = _load_technology_file(name, "layermap")
    viarules = _load_technology_file(name, "viarules")
    config   = _load_technology_file(name, "config")
end

return M
