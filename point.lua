local M = {}

local tostringfun = function (self) return string.format("{ x = %7.3f, y = %7.3f }", self.x, self.y) end

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

function meta.copy(self)
    local new = M.create(self.x, self.y)
    return new
end

function M.set_tostring_method(fun)
    tostringfun = fun
end

function meta.translate(self, dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
    return self
end

function meta.rotate(self, angle)
    local x, y = self:unwrap()
    self.x = x * math.cos(angle) - y * math.sin(angle)
    self.y = x * math.sin(angle) + y * math.cos(angle)
    return self
end

function meta.scale(self, factor)
    self.x = self.x * factor
    self.y = self.y * factor
    return self
end

function meta.unwrap(self, mul)
    local mul = mul or 1
    return mul * self.x, mul * self.y
end

return M
