local M = {}

local meta = {}
meta.__index = meta

local function _create(lpp, typ)
    assert(typ, "creating a shape without a type")
    local typ = typ
    local self = { lpp = lpp, unmapped = true, typ = typ }
    setmetatable(self, meta)
    return self
end

function M.create_rectangle(lpp, width, height)
    local self = _create(lpp, "rectangle")
    self.points = {
        bl = point.create(-0.5 * width, -0.5 * height),
        tr = point.create( 0.5 * width,  0.5 * height)
    }
    return self
end

function M.create_polygon(lpp)
    local self = _create(lpp, "polygon")
    self.points = {}
    return self
end

function meta.convert_to_polygon(self)
    if self.typ == "rectangle" then
        local new = M.create_polygon(self.lpp)
        table.insert(new.points, point.create(self.points.bl.x, self.points.bl.y))
        table.insert(new.points, point.create(self.points.tr.x, self.points.bl.y))
        table.insert(new.points, point.create(self.points.tr.x, self.points.tr.y))
        table.insert(new.points, point.create(self.points.bl.x, self.points.tr.y))
        table.insert(new.points, point.create(self.points.bl.x, self.points.bl.y)) -- close polygon
        return new
    elseif self.typ == "polygon" then
        return self:copy()
    end
end

function meta.copy(self)
    local new
    if self.typ == "polygon" then
        new = M.create_polygon(self.lpp)
        for i, pt in ipairs(self.points) do
            new.points[i] = pt:copy()
        end
        return new
    elseif self.typ == "rectangle" then
        new = M.create_rectangle(self.lpp, 0, 0) -- dummy width and length
        new.points.bl = self.points.bl:copy()
        new.points.tr = self.points.tr:copy()
    end
    return new
end

function meta.width(self)
    if self.typ == "polygon" then
        local minx =  math.huge
        local maxx = -math.huge
        for _, pt in ipairs(self.points) do
            minx = math.min(minx, pt.x)
            maxx = math.max(maxx, pt.x)
        end
        return maxx - minx
    elseif self.typ == "rectangle" then
        return self.points.tr.x - self.points.bl.x
    end
end

function meta.height(self)
    if self.typ == "polygon" then
        local miny =  math.huge
        local maxy = -math.huge
        for _, pt in ipairs(self.points) do
            miny = math.min(miny, pt.y)
            maxy = math.max(maxy, pt.y)
        end
        return maxy - miny
    elseif self.typ == "rectangle" then
        return self.points.tr.y - self.points.bl.y
    end
end

function meta.center(self)
    if self.typ == "polygon" then
        error("no implementation for center() for polygons")
    elseif self.typ == "rectangle" then
        local x = 0.5 * (self.points.bl.x + self.points.tr.x)
        local y = 0.5 * (self.points.bl.y + self.points.tr.y)
        return point.create(x, y)
    end
end

function meta.concat_points(self, func)
    local st = {}
    if self.typ == "polygon" then
        for _, pt in ipairs(self.points) do
            table.insert(st, func(pt))
        end
    elseif self.typ == "rectangle" then
        table.insert(st, func(self.points.bl))
        table.insert(st, func(self.points.tr))
    end
    return st
end

function meta.translate(self, dx, dy)
    if self.typ == "polygon" then
        for _, pt in ipairs(self.points) do
            pt:translate(dx, dy)
        end
    elseif self.typ == "rectangle" then
        self.points.bl:translate(dx, dy)
        self.points.tr:translate(dx, dy)
    end
    return self
end

function meta.rotate(self, angle)
    if self.typ == "polygon" then
        for _, pt in ipairs(self.points) do
            pt:rotate(angle)
        end
    elseif self.typ == "rectangle" then
        self.points.bl:rotate(angle)
        self.points.tr:rotate(angle)
    end
    return self
end

function meta.scale(self, factor)
    if self.typ == "polygon" then
        for _, pt in ipairs(self.points) do
            pt:scale(factor)
        end
    elseif self.typ == "rectangle" then
        self.points.bl:scale(factor)
        self.points.tr:scale(factor)
    end
    return self
end

return M
