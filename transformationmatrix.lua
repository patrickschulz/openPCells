local M = {}

local meta = {}
meta.__index = meta
meta.__tostring = function(self) return string.format("%d %d\n%d %d\ndx: %d, dy: %d", self[1], self[2], self[3], self[4], self.dx, self.dy) end

function M.identity()
    local self = {
        1, 0,
        0, 1,
        dx = 0, dy = 0,
        scalefactor = 1,
    }
    setmetatable(self, meta)
    return self
end

function meta.copy(self)
    local new = M.identity()
    new[1] = self[1]
    new[2] = self[2]
    new[3] = self[3]
    new[4] = self[4]
    new.dx = self.dx
    new.dy = self.dy
    new.scalefactor = self.scalefactor
    return new
end

function meta.translate(self, dx, dy)
    self.dx = self.dx + dx
    self.dy = self.dy + dy
end

function meta.scale(self, factor)
    self.scalefactor = factor
end

function meta.flipx(self)
    self[1] = -self[1]
    self[2] = -self[2]
end

function meta.flipy(self)
    self[3] = -self[3]
    self[4] = -self[4]
end

function meta.rotate_90_right(self)
    self[1], self[3] = self[3], -self[1]
    self[2], self[4] = self[4], -self[2]
end

function meta.rotate_90_left(self)
    self[1], self[3] = -self[3], self[1]
    self[2], self[4] = -self[4], self[2]
end

function meta.apply_translation(self, pt)
    local x, y = pt:unwrap()
    point._update(pt, x + self.dx, y + self.dy)
end

function meta.apply_transformation_translation_first(self, pt)
    local x, y = pt:unwrap()
    point._update(pt, 
        self.scalefactor * (self[1] * (x + self.dx) + self[2] * (y + self.dy)),
        self.scalefactor * (self[3] * (x + self.dx) + self[4] * (y + self.dy))
    )
end

function meta.apply_transformation(self, pt)
    local x, y = pt:unwrap()
    point._update(pt, 
        self.scalefactor * (self[1] * x + self[2] * y) + self.dx, 
        self.scalefactor * (self[3] * x + self[4] * y) + self.dy
    )
end

function meta.apply_inverse_transformation(self, pt)
    local x, y = pt:unwrap()
    local det = self[1] * self[4] - self[2] * self[3]
    point._update(pt, 
        ((x - self.dx) / self.scalefactor * self[4] - (y - self.dy) / self.scalefactor * self[2]) / det, 
        ((y - self.dy) / self.scalefactor * self[1] - (x - self.dx) / self.scalefactor * self[3]) / det
    )
end

function meta.orientation_string(self)
    if self[1] >= 0 and self[4] >= 0 then
        return "R0"
    elseif self[1] < 0 and self[4] >= 0 then
        return "fx"
    elseif self[1] >= 0 and self[4] < 0 then
        return "fy"
    elseif self[1] < 0 and self[4] < 0 then
        return "R180"
    end
end

return M
