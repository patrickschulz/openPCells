-- point meta functions (methods)
local meta = point._getmetatable()
point._getmetatable = nil -- remove metatable access

function meta.__tostring(self)
    local x, y = self:unwrap()
    return string.format("point: (%d, %d)", x, y)
end

function meta.__add(lhs, rhs)
    local x1, y1 = lhs:unwrap()
    local x2, y2 = rhs:unwrap()
    return point.create((x1 + x2) / 2, (y1 + y2) / 2)
end

function meta.__sub(lhs, rhs)
    local x1, y1 = lhs:unwrap()
    local x2, y2 = rhs:unwrap()
    return point.create(x1 - x2, y1 - y2)
end

function meta.__unm(lhs)
    local x, y = lhs:unwrap()
    return point.create(-x, -y)
end

function meta.__concat(lhs, rhs)
    local x1 = lhs:getx()
    local y2 = rhs:gety()
    return point.create(x1, y2)
end

function meta.scale(self, factor)
    local x, y = self:unwrap()
    point._update(self, x * factor, y * factor)
    return self
end

function meta.rotate(self, angle)
    local x, y = self:unwrap()
    local nx = x * math.cos(angle) - y * math.sin(angle)
    local ny = x * math.sin(angle) + y * math.cos(angle)
    point._update(self, math.floor(nx), math.floor(ny))
    return self
end

function meta.fix(self, grid)
    local x, y = self:unwrap()
    point._update(self, grid * (x // grid), grid * (y // grid))
    return self
end

local function intlog10(num)
    if num == 0 then return 0 end
    if num == 1 then return 0 end
    local ret = 0
    while num > 1 do
        num = num / 10
        ret = ret + 1
    end
    return ret
end

local function _format_number(num, baseunit)
    local fmt = string.format("%%s%%u.%%0%uu", intlog10(baseunit))
    local sign = "";
    if num < 0 then
        sign = "-"
        num = -num
    end
    local ipart = num // baseunit;
    local fpart = num - baseunit * ipart;
    return string.format(fmt, sign, ipart, fpart)
end

function meta.format(self, baseunit, sep)
    local x, y = self:unwrap()
    local sx = _format_number(x, baseunit)
    local sy = _format_number(y, baseunit)
    return string.format("%s%s%s", sx, sep, sy)
end

-- point module functions
function point.combine_12(lhs, rhs)
    return point.create(lhs:getx(), rhs:gety())
end

function point.combine_21(lhs, rhs)
    return point.create(rhs:getx(), lhs:gety())
end

function point.combine(lhs, rhs)
    local x1, y1 = lhs:unwrap()
    local x2, y2 = rhs:unwrap()
    return point.create((x1 + x2) / 2, (y1 + y2) / 2)
end

function point.xdistance(lhs, rhs)
    return lhs:getx() - rhs:getx()
end

function point.ydistance(lhs, rhs)
    return lhs:gety() - rhs:gety()
end

function is_point(obj)
    if not obj then
        error("is_point expects expects one argument")
    end
    if type(obj) ~= "userdata" then
        return false
    end
    local meta = getmetatable(obj)
    if not meta then
        return false
    end
    if meta.__name and meta.__name == "lpoint" then
        return true
    end
    return false -- explicitly return false because we always want one result
end
