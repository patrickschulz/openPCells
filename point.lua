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

function meta.getx(self)
    return self.x
end

function meta.gety(self)
    return self.y
end

function meta.fix(self, grid)
    self.x = grid * aux.round(self.x / grid);
    self.y = grid * aux.round(self.y / grid);
end

local function _format_number(num, baseunit)
    local fmt
    if baseunit == 1 then
        fmt = "%d"
    else
        fmt = string.format("%%d.%%0%dd", math.log(baseunit, 10))
    end
    local int = num // baseunit
    local frac = num - baseunit * int
    return string.format(fmt, int, frac)
end

function meta.format(self, baseunit, sep)
    local x, y = self:unwrap()
    local xs = _format_number(x, baseunit)
    local ys = _format_number(y, baseunit)
    return string.format("%s%s%s", xs, sep, ys)
end

return M
