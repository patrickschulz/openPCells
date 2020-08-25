local M = {}

local meta = {}
meta.__index = meta

function M.open(filename)
    local self = {
        filename = filename,
        content = {}
    }
    setmetatable(self, meta)
    return self
end

function meta.truewrite(self)
    local file = io.open(self.filename, "w")
    file:write(table.concat(self.content))
    file:close()
end

function meta.write(self, str)
    table.insert(self.content, str)
end

return M
