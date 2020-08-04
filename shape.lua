--[[
This file is part of the openPCells project.

A 'shape' in this context is a collection of polygons in one layer-purpose-pair.
For overlapping shapes this could also be handled by a single polygon, but we also 
consider a collection of non-overlapping shapes a 'shape'.

TODO:
 * implement reduction of overlapping polygons
--]]
local M = {}

local pointarray = require "pointarray"

local meta = {}
meta.__index = meta

meta.__tostring = function(self)
    local t = { string.format("shape: %s", self.lpp), "--------------------------" }
    table.insert(t, tostring(self.points))
    table.insert(t, "--------------------------")
    return table.concat(t, "\n")
end

function M.create(lpp, typ)
    local typ = typ or "polygon"
    local self = { points = pointarray.create(), lpp = lpp, unmapped = true, typ = typ }
    setmetatable(self, meta)
    return self
end

function meta.copy(self)
    local new = M.create(self.lpp)
    new.points = self.points:copy()
    return new
end

function meta.translate(self, dx, dy)
    self.points:map(function(pt) pt:translate(dx, dy) end)
    return self
end

function meta.add_point(self, pt)
    self.points:append(pt)
end

return M
