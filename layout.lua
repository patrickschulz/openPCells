local M = {}

local point = require "point"
local graphics = require "graphics"
local pointarray = require "pointarray"
local shape = require "shape"
local object = require "object"

-- private helper functions
local function _rectangle(center, width, height)
    local pts = pointarray.create()
    -- polygon
    pts:append(point.create(center.x - 0.5 * width, center.y - 0.5 * height))
    pts:append(point.create(center.x + 0.5 * width, center.y - 0.5 * height))
    pts:append(point.create(center.x + 0.5 * width, center.y + 0.5 * height))
    pts:append(point.create(center.x - 0.5 * width, center.y + 0.5 * height))
    -- rectangle points (lower left and upper right)
    --pts:append(point.create(center.x - 0.5 * width, center.y - 0.5 * height))
    --pts:append(point.create(center.x + 0.5 * width, center.y + 0.5 * height))
    return pts
end

-- public interface
function M.rectangle(layer, purpose, center, width, height)
    local obj = shape.create(layer, purpose)
    obj:add_pointarray(_rectangle(center, width, height))
    return obj
end

function M.rectangle_array(layer, purpose, center, width, height, options)
    local xrep = options.xrep or 1
    local yrep = options.yrep or 1
    local xpitch = options.xpitch or 0
    local ypitch = options.ypitch or 0
    local xoffset = options.xoffset or 0
    local yoffset = options.yoffset or 0
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

return M
