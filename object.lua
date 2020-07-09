--[[
This file is part of the openPCells project.

An 'object' is a collection of 'shapes', that is an object composed of several polygons on several layers.
--]]
local M = {}

local shapelib = require "shape"

local meta = {}
meta.__index = meta

function M.create()
    local self = { shapes = {} }
    setmetatable(self, meta)
    return self
end

function meta.add_shape(self, shape)
    table.insert(self.shapes, shape)
end

function meta.iter(self)
    local idx = 1
    local iter = function()
        idx = idx + 1
        return self.shapes[idx - 1]
    end
    return iter
end

return M
