local M = {}

local pointarray = require "pointarray"

local meta = {}
meta.__index = meta

meta.__tostring = function(self)
    local t = {}
    for i, pts in ipairs(self.pts) do
        table.insert(t, tostring(pts))
    end
    return table.concat(t, "\n")
end

function M.create(layer, purpose)
    local self = { pts = {}, layer = layer, purpose = purpose, current = nil }
    setmetatable(self, meta)
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
