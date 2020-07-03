local M = {}

local tostringfun = function (self) return string.format("{ x = %6.3f, y = %6.3f }", self.x, self.y) end

local meta = {}
meta.__index = meta
meta.__tostring = tostringfun

function M.create(x, y)
    local self = {
        x = x,
        y = y
    }
    setmetatable(self, meta)
    return self
end

function M.set_tostring_method(fun)
    tostringfun = fun
end

function meta.unwrap(self)
    return self.x, self.y
end

return M
