local M = {}

local meta = {}
meta.__index = meta

function M.identity()
    local self = {
        1, 0,
        0, 1,
        dx = 0, dy = 0
    }
    setmetatable(self, meta)
    return self
end

function meta.translate(self, dx, dy)
    self.dx = self.dx + dx
    self.dy = self.dy + dy
end

--[[
function meta.scale(self, factor)
    self[1] = factor * self[1]
    self[2] = factor * self[2]
    self[3] = factor * self[3]
    self[4] = factor * self[4]
end
--]]

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

function meta.apply_transformation(self, pt)
    local x, y = pt:unwrap()
    point._update(pt, self[1] * x + self[2] * y + self.dx, self[3] * x + self[4] * y + self.dy)
end

function meta.apply_inverse_transformation(self, pt)
    local x, y = pt:unwrap()
    local det = self[1] * self[4] - self[2] * self[3]
    point._update(pt, (x - self.dx) * self[4] / det - (y - self.dy) * self[2] /det, -(x - self.dx) * self[3] / det + (y - self.dy) * self[1] / det)
end

return M
