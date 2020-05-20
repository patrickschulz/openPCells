local M = {}

local shapelib = require "shape"

local meta = {}
meta.__index = meta

function M.create()
    local self = { shapes = {} }
    setmetatable(self, meta)
    return self
end

function M.add_shape(self, shape)
    table.insert(shapes, shape)
end

return M
