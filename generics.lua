local M = {}

local function _create(value)
    return {
        value = value,
        isgeneric = true,
        get = function(self)
            if self.typ == "via" then
                return self.value.from, self.value.to
            else
                return self.value
            end
        end,
        str = function(self)
            if self.typ == "metal" then
                return string.format("M%d", self.value)
            else
                return self.value
            end
        end
    }
end

function M.metal(num)
    local self = _create(num)
    self.typ = "metal"
    return self
end

function M.via(from, to)
    local self = _create({ from = from, to = to })
    self.typ = "via"
    self.str = function(self) return string.format("viaM%dM%d", self:get()) end
    return self
end

function M.contact(region)
    local self = _create(region)
    self.typ = "contact"
    self.str = function(self) return string.format("contact%s", self:get()) end
    return self
end

function M.other(layer)
    local self = _create(layer)
    self.typ = "other"
    return self
end

function M.mapped(layer)
    local self = _create(layer)
    self.typ = "mapped"
    return self
end

return M
