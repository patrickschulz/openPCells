local M = {}

local meta = {}
meta.__index = meta

local funcobject = _load_module("pcell.funcobject")

function M.create_directory()
    local self = {
        names = {},
        values = {},
        overwrite = false
    }
    setmetatable(self, meta)
    return self
end

function M.check_constraints(parameter, value)
    local posvals = parameter.posvals
    local name = parameter.name
    if posvals then
        if posvals.type == "set" then
            local found = aux.find(posvals.values, function(v) return v == value end)
            if not found then
                error(string.format("parameter '%s' (%s) can only be %s", name, value, table.concat(posvals.values, " or ")))
            end
        elseif posvals.type == "interval" then
            if value < posvals.values.lower or value > posvals.values.upper then
                error(string.format("parameter '%s' (%s) out of range from %s to %s", name, value, posvals.values.lower, posvals.values.upper))
            end
        elseif posvals.type == "even" then
            if value % 2 ~= 0 then
                error(string.format("parameter '%s' (%s) must be even", name, value))
            end
        elseif posvals.type == "odd" then
            if value % 2 ~= 1 then
                error(string.format("parameter '%s' (%s) must be odd", name, value))
            end
        else
        end
    end
end

function meta.set_overwrite(self, overwrite)
    self.overwrite = overwrite
end

function meta.set_follow(self, follow)
    self.follow = follow
end

function meta.add(self, name, value, argtype, posvals)
    local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
    if not pname then pname = name end -- no display name
    local new = {
        name      = pname,
        display   = dname,
        func      = funcobject.identity(value),
        argtype   = argtype,
        posvals   = posvals,
        followers = {},
        ptype     = "N" -- 'normal' parameter
    }
    if not self.values[pname] or self.overwrite then
        self.values[pname] = new
        table.insert(self.names, pname)
        if self.follow then
            self.values[self.follow].followers[pname] = true
        end
        return true
    else
        return false
    end
end

function meta.get(self, name)
    return self.values[name]
end

function meta.get_values(self)
    return self.values
end

function meta.get_names(self)
    return self.names
end

return M
