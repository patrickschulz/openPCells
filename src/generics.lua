generics = {}
generics.__index = generics

local proxymeta = {}
proxymeta.__index = function(self, key) return self.obj[key] end
proxymeta.__newindex = function(self, key, value) self.obj[key] = value end

local function _create(value)
    local obj = {
        value = value
    }
    setmetatable(obj, generics)
    local self = { obj = obj }
    setmetatable(self, proxymeta)
    return self
end

--[[
local function _create(value)
    local obj = {
        value = value,
    }
    setmetatable(obj, generics)
    local d = debug.getinfo(2, "Slnt")
    local self = { obj = obj, debug = { source = d.source, line = d.linenumber } }
    setmetatable(self, proxymeta)
    return self
end
--]]

--[[
function generics.copy(self)
    local new = { obj = self.obj }
    setmetatable(new, proxymeta)
    return new
end
--]]

function generics.get(self)
    if self.typ == "via" then
        return self.value.from, self.value.to
    elseif self.typ == "contact" then
        return self.value, self.special
    else
        return self.value
    end
end

function generics.str(self)
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

function generics.set_port(self)
    self.isport = true
end

function generics.metal(num)
    return { type = "metal", metal = num }
end

function generics.via(from, to, opt)
    check_number(from)
    check_number(to)
    check_optional_table(opt)
    local self = _create({ from = from, to = to })
    self.typ = "via"
    self.bare = opt and opt.bare
    self.firstbare = opt and opt.firstbare
    self.lastbare = opt and opt.lastbare
    self.xcontinuous = opt and opt.xcontinuous
    self.ycontinuous = opt and opt.ycontinuous
    return self
end

function generics.contact(region, special, bare)
    local self = _create(region)
    self.typ = "contact"
    self.special = special
    self.bare = bare
    return self
end

function generics.feol(settings)
    local self = _create(settings)
    self.typ = "feol"
    return self
end

function generics.other(layer)
    local self = _create(layer)
    self.typ = "other"
    return self
end

function generics.special(layer)
    local self = _create(layer)
    self.typ = "special"
    return self
end

function generics.premapped(name, layer)
    check_arg_or_nil(name, "string", "generics.premapped: first argument expects a name")
    check_arg(layer, "table", "generics.premapped: second argument expects a table")
    local self = _create(layer)
    self.typ = "premapped"
    self.name = name
    return self
end

function generics.mapped(name, layer)
    check_arg_or_nil(name, "string", "generics.mapped: first argument expects a name")
    check_arg(layer, "table", "generics.mapped: second argument expects a table")
    local self = _create(layer)
    self.typ = "mapped"
    self.name = name
    return self
end

function generics.is_type(self, ...)
    local comp = function(v) return self.typ == v end
    return aux.any_of(comp, { ... })
end
