local M = {}

local meta = {}
meta.__index = meta

function M.create()
    local self = { sub = {}, current = 0 }
    setmetatable(self, meta)
    return self
end

function M.start(self)
    self.current = self.current + 1
    self.sub[self.current] = pointarray.create()
end

function M.stop(self)
    self.sub[self.current]:close()
end

function M.add_point(self, pt)
    self.sub[self.current]:append(pt)
end

return M
