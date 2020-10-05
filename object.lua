--[[
This file is part of the openPCells project.

An 'object' is a collection of 'shapes', that is an object composed of several polygons on several layers.
--]]
local M = {}

local meta = {}
meta.__index = meta

function M.create()
    local self = { shapes = {}, anchors = {} }
    setmetatable(self, meta)
    return self
end

function meta.copy(self)
    local new = M.create()
    for i, shape in ipairs(self.shapes) do
        new.shapes[i] = shape:copy()
    end
    for name, pt in pairs(self.anchors) do
        new.anchors[name] = pt:copy()
    end
    return new
end

function M.make_from_shape(shape)
    local self = M.create()
    self:add_shape(shape)
    return self
end

function meta.merge_into(self, other)
    for _, shape in other:iter() do
        self:add_shape(shape)
    end
end

function meta.add_shape(self, shape)
    table.insert(self.shapes, shape:copy())
end

function meta.add_shapes(self, shapes)
    for _, s in ipairs(shapes) do
        self:add_shape(s)
    end
end

-- this function returns an iterator over all shapes in a cell
-- (possibly only selecting a subset)
-- First all shapes are collected in an auxiliary table, which enables 
-- modification of the self.shapes table within the iteration
-- Furthermore, the list is iterated from the end, which allows 
-- element removal in the loop
function meta.iter(self, comp)
    local shapes = {}
    local indices = {}
    local comp = comp or function() return true end
    for i, s in ipairs(self.shapes) do
        if comp(s) then
            table.insert(shapes, s)
            table.insert(indices, i)
        end
    end
    local idx = #shapes + 1 -- start at the end
    local iter = function()
        idx = idx - 1
        return indices[idx], shapes[idx]
    end
    return iter
end

function meta.find(self, comp)
    local shapes = {}
    local indices = {}
    local comp = comp or function() return true end
    for i, s in ipairs(self.shapes) do
        if comp(s) then
            table.insert(shapes, s)
            table.insert(indices, i)
        end
    end
    return indices, shapes
end

function meta.translate(self, dx, dy)
    for _, shape in ipairs(self.shapes) do
        shape:translate(dx, dy)
    end
    for _, anchor in pairs(self.anchors) do
        anchor:translate(dx, dy)
    end
    return self
end

function meta.rotate(self, angle)
    for _, shape in ipairs(self.shapes) do
        shape:rotate(angle)
    end
    for _, anchor in pairs(self.anchors) do
        anchor:rotate(angle)
    end
    return self
end

function meta.width_height(self)
    local minx =  math.huge
    local maxx = -math.huge
    local miny =  math.huge
    local maxy = -math.huge
    for _, shape in self:iter() do
        if shape.typ == "polygon" then
            for _, pt in ipairs(shape.points) do
                minx = math.min(minx, pt.x)
                maxx = math.max(maxx, pt.x)
                miny = math.min(miny, pt.y)
                maxy = math.max(maxy, pt.y)
            end
        elseif shape.typ == "rectangle" then
            minx = math.min(minx, shape.points.bl.x, shape.points.tr.x)
            maxx = math.max(maxx, shape.points.bl.x, shape.points.tr.x)
            miny = math.min(miny, shape.points.bl.y, shape.points.tr.y)
            maxy = math.max(maxy, shape.points.bl.y, shape.points.tr.y)
        end
    end
    return maxx - minx, maxy - miny
end

function meta.bounding_box(self)
    local minx =  math.huge
    local maxx = -math.huge
    local miny =  math.huge
    local maxy = -math.huge
    for _, shape in self:iter() do
        if shape.typ == "polygon" then
            for _, pt in ipairs(shape.points) do
                minx = math.min(minx, pt.x)
                maxx = math.max(maxx, pt.x)
                miny = math.min(miny, pt.y)
                maxy = math.max(maxy, pt.y)
            end
        elseif shape.typ == "rectangle" then
            minx = math.min(minx, shape.points.bl.x, shape.points.tr.x)
            maxx = math.max(maxx, shape.points.bl.x, shape.points.tr.x)
            miny = math.min(miny, shape.points.bl.y, shape.points.tr.y)
            maxy = math.max(maxy, shape.points.bl.y, shape.points.tr.y)
        end
    end
    return { bl = point.create(minx, miny), tr = point.create(maxx, maxy) }
end

function meta.add_anchor(self, name, where)
    local where = where or point.create(0, 0)
    self.anchors[name] = where
end

function meta.get_anchor(self, name)
    return self.anchors[name]
end

function meta.move_anchor(self, name, where)
    local where = where or point.create(0, 0)
    local pt = self.anchors[name]
    if not pt then
        print(string.format("anchor '%s' is unknown", name))
        os.exit(exitcodes.anchornotfound)
    end
    self:translate(where.x - pt.x, where.y - pt.y)
    return self
end

return M
