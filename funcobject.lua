local M = {}

local meta = {}
meta.__call = function(self, ...) return self.func(...) end
meta.__index = meta

function M.create(func)
    local self = { func = func }
    setmetatable(self, meta)
    return self
end

function M.identity(value)
    return M.create(function()
        return value
    end)
end

function meta.replace(self, func)
    self.func = func
end

function meta.get(self)
    return self.func
end

return M
