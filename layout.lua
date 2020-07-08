local M = {}

local point      = require "point"
local graphics   = require "graphics"
local pointarray = require "pointarray"
local shape      = require "shape"
local object     = require "object"

-- private helper functions
local function _rectangle(center, width, height)
    local pts = pointarray.create()
    -- polygon
    pts:append(point.create(center.x - 0.5 * width, center.y - 0.5 * height))
    pts:append(point.create(center.x + 0.5 * width, center.y - 0.5 * height))
    pts:append(point.create(center.x + 0.5 * width, center.y + 0.5 * height))
    pts:append(point.create(center.x - 0.5 * width, center.y + 0.5 * height))
    return pts
end

local function _get_layer_via_lists(startlayer, endlayer)
    local layers = {}
    local vias = {}
    if startlayer == "active" or startlayer == "gate" then
        table.insert(layers, startlayer)
        table.insert(vias, startlayer == "active" and "wellcont" or "gatecont")
    end
    local startindex = string.match(startlayer, "M(%d)") or 1
    local endindex = string.match(endlayer, "M(%d)") or 1
    for i = startindex, endindex do
        table.insert(layers, string.format("M%d", i))
    end
    return layers, vias
end

-- public interface
function M.rectangle(layer, purpose, center, width, height, options)
    local options = options or {}
    local xrep = options.xrep or 1.0
    local yrep = options.yrep or 1.0
    local xpitch = options.xpitch or 0.0
    local ypitch = options.ypitch or 0.0
    local xoffset = options.xoffset or 0.0
    local yoffset = options.yoffset or 0.0
    local obj = shape.create(layer, purpose)
    for x = 1, xrep do
        for y = 1, yrep do
            local c = point.create(
                center.x + xoffset + (x - 1) * xpitch - 0.5 * (xrep - 1) * xpitch, 
                center.y + yoffset + (y - 1) * ypitch - 0.5 * (yrep - 1) * ypitch
            )
            local pts = _rectangle(c, width, height)
            obj:add_pointarray(pts)
        end
    end
    return obj
end

function M.via(spec, width, height)
    local startlayer, endlayer = string.match(spec, "(%w+)%-%>(%w+)")
    local shapes = {}
    local layers, vias = _get_layer_via_lists(startlayer, endlayer)
    for _, layer in ipairs(layers) do
        local s = M.rectangle(layer, "drawing", point.create(0, 0), width, height)
        table.insert(shapes, s)
        --print(layer)
    end
    for _, via in ipairs(vias) do
        --print(via)
    end
    return shapes
end

return M
