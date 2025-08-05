local M = {}

local meta = {}
meta.__index = meta

function M.create()
    local self = {
        bl = point.create(0, 0),
        tr = point.create(0, 0)
    }
    setmetatable(self, meta)
    return self
end

function meta.add(self, cell)
    local bl = cell:get_alignment_anchor("outerbl")
    local tr = cell:get_alignment_anchor("outertr")
    local blx = math.min(self.bl:getx(), bl:getx())
    local bly = math.min(self.bl:gety(), bl:gety())
    local trx = math.max(self.tr:getx(), tr:getx())
    local try = math.max(self.tr:gety(), tr:gety())
    self.bl = point.create(blx, bly)
    self.tr = point.create(trx, try)
end
M.add = meta.add

return M
