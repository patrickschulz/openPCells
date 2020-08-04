local M = {}

local layout = require "layout"

local layermap
local viarules
local config

local function map_shape(shape)
    local t = layermap[shape.layer]
    if not t then
        print(string.format("no layer information for '%s'\nif the layer is not provided, set it to 'UNUSED'", shape.layer))
        os.exit(1)
    end
    if t == "UNUSED" then
        shape.layer = nil
        shape.purpose = nil
    else
        shape.layer = t.layer
        shape.purpose = t.purpose
    end
end

function M.map_layer(obj, layermap)
    for shape in obj:iter() do
        map_shape(shape, layermap)
    end
end

local function _get_viaspec(layer)
    local t = viarules[layer]
    if not t then
        print(string.format("no via geometry specification for '%s'", layer))
        os.exit(1)
    end
    return viarules[layer]
end

local function _place_vias(cell, layer, pts)
    local viaspec = _get_viaspec(layer)
    local width = math.abs(pts[3].x - pts[1].x)
    local height = math.abs(pts[3].y - pts[1].y)
    local x = 0.5 * (pts[1].x + pts[3].x)
    local y = 0.5 * (pts[1].y + pts[3].y)
    local xrep = math.max(1, math.floor((width + viaspec.xspace - 2 * viaspec.xencl) / (viaspec.width + viaspec.xspace)))
    local yrep = math.max(1, math.floor((height + viaspec.yspace - 2 * viaspec.yencl) / (viaspec.height + viaspec.yspace)))
    local xpitch = viaspec.width + viaspec.xspace
    local ypitch = viaspec.height + viaspec.yspace
    local o = layout.multiple(
        layout.rectangle(layer, "drawing", viaspec.width, viaspec.height),
        xrep, yrep, xpitch, ypitch
    )
    cell:merge_into(o:translate(x, y))
end

function M.translate_vias(cell)
    local numshapes = #cell.shapes
    local toremove = {}
    for i = 1, numshapes do
        local s = cell.shapes[i]
        if string.match(s.layer, "^via") then
            table.insert(toremove, i)
            local layer = string.match(s.layer, "^via(.+)$")
            for pts in s:iter() do
                _place_vias(cell, layer, pts)
            end
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

function M.fix_to_grid(obj)
    for s in obj:iter() do
        for pts in s:iter() do
            for pt in pts:iter_forward() do
                _fix_pt_to_grid(pt)
            end
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
    config = _load_technology_file(name, "config")
end

return M
