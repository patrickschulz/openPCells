local M = {}

local function _create(value)
    return {
        value = value,
        isgeneric = true
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
    return self
end

function M.other(layer)
    local self = _create(layer)
    self.typ = "other"
    return self
end

return M
