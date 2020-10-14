local M = {}

local meta = {}
meta.__index = meta

function M.create()
    local self = {}
    setmetatable(self, meta)
    return self
end

function meta.push(self, value)
    table.insert(self, value)
end

function meta.top(self)
    return self[#self]
end

function meta.pop(self)
    table.remove(self)
end

function meta.peek(self)
    return #self > 0
end

return M
