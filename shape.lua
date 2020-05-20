local M = {}

local pointarray = require "pointarray"

local meta = {}
meta.__index = meta

function M.create(layer, purpose)
    local self = { pts = pointarray.create(), layer = layer, purpose = purpose }
    setmetatable(self, meta)
    return self
end

function M.add_point(self, pt)
    self.pts:append(pt)
end

function M.close(self)
    self.pts:close()
end

return M
