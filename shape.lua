function shape.get_points(self)
    return self.points
end

function shape.get_lpp(self)
    return self.lpp
end

function shape.set_lpp(self, lpp)
    self.lpp = lpp
end

function shape.convert_to_polygon(self)
    if self.typ == "rectangle" then
        local blx, bly = self.points.bl:unwrap()
        local trx, try = self.points.tr:unwrap()
        local new = shape.create_polygon(self.lpp)
        table.insert(new.points, point.create(blx, bly))
        table.insert(new.points, point.create(trx, bly))
        table.insert(new.points, point.create(trx, try))
        table.insert(new.points, point.create(blx, try))
        table.insert(new.points, point.create(blx, bly)) -- close polygon
        return new
    elseif self.typ == "polygon" then
        return self:copy()
    end
end

function shape.copy(self)
    local new
    if self.typ == "polygon" then
        new = shape.create_polygon(self.lpp:copy())
        for i, pt in ipairs(self.points) do
            new.points[i] = pt:copy()
        end
        return new
    elseif self.typ == "rectangle" then
        new = shape.create_rectangle(self.lpp:copy(), 0, 0) -- dummy width and length
        new.points.bl = self.points.bl:copy()
        new.points.tr = self.points.tr:copy()
    end
    return new
end

function shape.apply_transformation(self, matrix)
    if self.typ == "polygon" then
        for _, pt in ipairs(self.points) do
            matrix:apply_transformation(pt)
        end
    elseif self.typ == "rectangle" then
        matrix:apply_transformation(self.points.bl)
        matrix:apply_transformation(self.points.tr)
    end
    return self
end

function shape.apply_inverse_transformation(self, matrix)
    if self.typ == "polygon" then
        for _, pt in ipairs(self.points) do
            matrix:apply_inverse_transformation(pt)
        end
    elseif self.typ == "rectangle" then
        matrix:apply_inverse_transformation(self.points.bl)
        matrix:apply_inverse_transformation(self.points.tr)
    end
    return self
end

function shape.resize(self, xsize, ysize)
    shape.resize_lrtb(self, xsize / 2, xsize / 2, ysize / 2, ysize/ 2)
end

function shape.resize_lrtb(self, left, right, top, bottom)
    if self.typ == "polygon" then
        error("sorry, resizing is currently only implemented for rectangles")
    elseif self.typ == "rectangle" then
        self.points.bl:translate(-left, -bottom)
        self.points.tr:translate(right, top)
    end
end

function shape.width(self)
    if self.typ == "polygon" then
        local minx =  math.huge
        local maxx = -math.huge
        for _, pt in ipairs(self.points) do
            local x = pt:getx()
            minx = math.min(minx, x)
            maxx = math.max(maxx, x)
        end
        return maxx - minx
    elseif self.typ == "rectangle" then
        local x1 = self.points.bl:getx()
        local x2 = self.points.tr:getx()
        return x2 - x1
    end
end

function shape.height(self)
    if self.typ == "polygon" then
        local miny =  math.huge
        local maxy = -math.huge
        for _, pt in ipairs(self.points) do
            local y = pt:gety()
            miny = math.min(miny, y)
            maxy = math.max(maxy, y)
        end
        return maxy - miny
    elseif self.typ == "rectangle" then
        local y1 = self.points.bl:gety()
        local y2 = self.points.tr:gety()
        return y2 - y1
    end
end

-- FIXME: this is only needed for via arrayzation. Find a better approach (see technology.lua, _do_array)
function shape.center(self)
    if self.typ == "polygon" then
        error("no implementation for center() for polygons")
    elseif self.typ == "rectangle" then
        local x1, y1 = self.points.bl:unwrap()
        local x2, y2 = self.points.tr:unwrap()
        -- NOTE: odd lengths are chopped off (integer division)
        local x = (x1 + x2) // 2
        local y = (y1 + y2) // 2
        return point.create(x, y)
    end
end

function shape.concat_points(self, func)
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

function shape.is_type(self, typ)
    return self.typ == typ
end

function shape.is_lpp_type(self, typ)
    return self.lpp.typ == typ
end

return shape
