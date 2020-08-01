local M = {}

local point = require "point"

local meta = {}
meta.__index = meta

meta.__tostring = function(self)
    local t = {}
    for pt in self:iter_forward() do
        table.insert(t, tostring(pt))
    end
    return table.concat(t, "\n")
end

function M.create()
    local self = {}
    setmetatable(self, meta)
    return self
end

function meta.concat(self, func, delim)
    local st = {}
    local delim = delim or " "
    for _, pt in ipairs(self) do
        table.insert(st, func(pt))
    end
    return table.concat(st, delim)
end

function meta.copy(self)
    local new = M.create()
    for i, pt in ipairs(self) do
        new[i] = pt:copy()
    end
    return new
end

function meta.insert(self, idx, pt)
    table.insert(self, idx, pt)
end

function meta.prepend(self, pt)
    table.insert(self, pt, 1)
end

function meta.append(self, pt)
    table.insert(self, pt)
end

function meta.move(self, dx, dy)
    local dx = dx or 0
    local dy = dx or 0
    for i in ipairs(self) do
        self[i].x = self[i].x + dx
        self[i].y = self[i].y + dy
    end
end

function meta.prepend(self, pt)
    table.insert(self, 1, pt)
end

function meta.merge_append(self, pts)
    for _, pt in ipairs(pts) do
        self:append(pt)
    end
end

function meta.close(self)
    self:append(self[1])
end

function meta.reverse(self)
    local new = M.create()
    for pt in self:iter_backward() do
        new:append(pt)
    end
    return new
end

function meta.reverse_inline(self)
    local i = 1
    local j = #self
    while i < j do
        self[i], self[j] = self[j], self[i]
        i = i + 1
        j = j - 1
    end
end

function meta.filter_forward(self, fun)
    local filtered = M.create()
    for pt in self:iter_forward(self) do
        if fun(pt) then
            filtered:append(pt)
        end
    end
    return filtered
end

function meta.filter_backward(self, fun)
    local filtered = M.create()
    for pt in self:iter_backward(self) do
        if fun(pt) then
            filtered:append(pt)
        end
    end
    return filtered
end

function meta.iter_forward(self) 
    local idx = 1
    local iter = function()
        idx = idx + 1
        return self[idx - 1]
    end
    return iter
end

function meta.iter_backward(self) 
    local idx = #self
    local iter = function()
        idx = idx - 1
        return self[idx + 1]
    end
    return iter
end

function meta.map(self, func, ...)
    for _, pt in ipairs(self) do
        func(pt, ...)
    end
end

function meta.xmirror(self, xcenter)
    local mirrored = M.create()
    local xcenter = xcenter or 0
    for pt in self:iter_forward() do
        mirrored:append(point.create(2 * xcenter - pt.x, pt.y))
    end
    return mirrored
end

return M
