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
    local t = { string.format("shape: %s, %s", self.layer, self.purpose), "--------------------------" }
    for i, pts in ipairs(self.pts) do
        table.insert(t, tostring(pts))
    end
    table.insert(t, "--------------------------")
    return table.concat(t, "\n")
end

function M.create(layer, purpose)
    local self = { pts = {}, layer = layer, purpose = purpose, current = nil }
    setmetatable(self, meta)
    return self
end

function meta.copy(self)
    local new = M.create(self.layer, self.purpose)
    for i, pts in ipairs(self.pts) do
        new.pts[i] = pts:copy()
    end
    return new
end

function meta.translate(self, dx, dy)
    for pts in self:iter() do
        pts:map(function(pt) pt:translate(dx, dy) end)
    end
    return self
end

function meta.add_pointarray(self, pts)
    table.insert(self.pts, pts)
end

function meta.add_point(self, pt)
    self.pts[self.current]:append(pt)
end

function meta.start(self)
    self.current = #self.pts + 1
    self.pts[self.current] = pointarray.create()
end

function meta.close(self)
    self.pts[self.current]:close()
    self.current = nil
end

function meta.iter(self)
    local idx = 1
    local iter = function()
        idx = idx + 1
        return self.pts[idx - 1]
    end
    return iter
end

return M
