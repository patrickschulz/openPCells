--[[
This file is part of the openPCells project.

An 'object' is a collection of 'shapes', that is an object composed of several polygons on several layers.
--]]
local M = {}

local shapelib = require "shape"

local meta = {}
meta.__index = meta

meta.__tostring = function(self)
    local t = { "object:" }
    for shape in self:iter() do
        table.insert(t, tostring(shape))
    end
    return table.concat(t, "\n")
end

function M.create()
    local self = { shapes = {} }
    setmetatable(self, meta)
    return self
end

function meta.copy(self)
    local new = M.create()
    for i, shape in ipairs(self.shapes) do
        new.shapes[i] = shape:copy()
    end
    return new
end

function M.make_from_shape(shape)
    local self = M.create()
    self:add_shape(shape)
    return self
end

function meta.merge_into(self, other)
    --for _, shape in ipairs(other.shapes) do
    for shape in other:iter() do
        self:add_shape(shape)
    end
end

function meta.add_shape(self, shape)
    table.insert(self.shapes, shape)
end

function meta.add_shapes(self, shapes)
    for _, s in ipairs(shapes) do
        self:add_shape(s)
    end
end

function meta.iter(self)
    local idx = 1
    local iter = function()
        idx = idx + 1
        return self.shapes[idx - 1]
    end
    return iter
end

function meta.translate(self, dx, dy)
    for _, shape in ipairs(self.shapes) do
        shape:translate(dx, dy)
    end
    return self
end

return M
