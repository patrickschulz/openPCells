-- point meta functions (methods)
local meta = point._getmetatable()
point._getmetatable = nil -- remove metatable access

function meta.__eq(lhs, rhs)
    local x1, y1 = lhs:unwrap()
    local x2, y2 = rhs:unwrap()
    return (x1 == x2) and (y1 == y2)
end

function meta.__add(lhs, rhs)
    local x1, y1 = lhs:unwrap()
    local x2, y2 = rhs:unwrap()
    return point.create(x1 + x2, y1 + y2)
end

function meta.__sub(lhs, rhs)
    local x1, y1 = lhs:unwrap()
    local x2, y2 = rhs:unwrap()
    return point.create(x1 - x2, y1 - y2)
end

function meta.unwrap(self)
    return point._unwrap(self)
end

function meta.getx(self)
    local x = self:unwrap()
    return x
end

function meta.gety(self)
    local _, y = self:unwrap()
    return y
end

function meta.translate(self, dx, dy)
    local x, y = self:unwrap()
    point._update(self, x + dx, y + dy)
    return self
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

function meta.copy(self)
    local x1, y1 = self:unwrap()
    return point.create(x1, y1)
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

function point.relative_array(startpt, increments, skipfirst)
    local collection = {}
    local x, y = startpt:unwrap()
    if not skipfirst then
        table.insert(collection, startpt:copy())
    end
    for _, pt in ipairs(increments) do
        x = x + pt[1]
        y = y + pt[2]
        table.insert(collection, point.create(x, y))
    end
    return collection
end

function is_lpoint(obj)
    if not obj then
        error("is_lpoint expects expects one argument")
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
