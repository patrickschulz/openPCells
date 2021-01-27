local M = {}

local meta = {}
meta.__index = meta

function M.create_directory()
    local self = {
        names = {},
        values = {},
        overwrite = false
    }
    setmetatable(self, meta)
    return self
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
        display   = dname,
        func      = funcobject.identity(value),
        argtype   = argtype,
        posvals   = posvals,
        followers = {},
        ptype     = "R"
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
