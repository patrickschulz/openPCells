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

function meta.fix(self, grid)
    local x, y = self:unwrap()
    point._update(self, grid * (x // grid), grid * (y // grid))
    return self
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

function point.xdistance_abs(lhs, rhs)
    return math.abs(lhs:getx() - rhs:getx())
end

function point.ydistance_abs(lhs, rhs)
    return math.abs(lhs:gety() - rhs:gety())
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
