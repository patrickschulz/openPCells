local M = {}

M.__index = M

local proxymeta = {}
proxymeta.__index = function(self, key) return self.obj[key] end
proxymeta.__newindex = function(self, key, value) self.obj[key] = value end

local function _create(value)
    local obj = {
        value = value
    }
    setmetatable(obj, M)
    local self = { obj = obj }
    setmetatable(self, proxymeta)
    return self
end

function M.copy(self)
    local new = { obj = self.obj }
    setmetatable(new, proxymeta)
    return new
end

function M.get(self)
    if self.typ == "via" then
        return self.value.from, self.value.to
    elseif self.typ == "contact" then
        return self.value, self.special
    else
        return self.value
    end
end

function M.str(self)
    if self.typ == "metal" then
        return string.format("M%d", self:get())
    elseif self.typ == "via" then
        return string.format("viaM%dM%d", self:get())
    elseif self.typ == "contact" then
        return string.format("contact%s", self:get())
    elseif self.typ == "feol" then
        return "feol"
    elseif self.typ == "special" then
        return "special"
    elseif self.typ == "premapped" then
        return self.name
    elseif self.typ == "mapped" then
        return self.name
    elseif self.typ == "other" then
        return self.value
    else
        error(string.format("unknown generic: '%s'", self.typ))
    end
end

function M.set_port(self)
    self.isport = true
end

function M.metal(num)
    local self = _create(num)
    self.typ = "metal"
    return self
end

function M.via(from, to, bare)
    if not from or not to then
        error("generic.via with nil")
    end
    local self = _create({ from = from, to = to })
    self.typ = "via"
    self.bare = bare
    return self
end

function M.contact(region, special, bare)
    local self = _create(region)
    self.typ = "contact"
    self.special = special
    self.bare = bare
    return self
end

function M.feol(settings)
    local self = _create(settings)
    self.typ = "feol"
    return self
end

function M.other(layer)
    local self = _create(layer)
    self.typ = "other"
    return self
end

function M.special(layer)
    local self = _create(layer)
    self.typ = "special"
    return self
end

function M.premapped(name, layer)
    local self = _create(layer)
    self.typ = "premapped"
    self.name = name
    return self
end

function M.mapped(name, layer)
    local self = _create(layer)
    self.typ = "mapped"
    self.name = name
    return self
end

function M.is_type(self, ...)
    local comp = function(v) return self.typ == v end
    return aux.any_of(comp, { ... })
end

return M
