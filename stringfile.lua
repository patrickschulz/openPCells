local M = {}

local meta = {}
meta.__index = meta

function M.open(filename)
    local self = {
        filename = filename,
        content = stringbuffer.create()
    }
    setmetatable(self, meta)
    return self
end

function meta.truewrite(self)
    local file = io.open(self.filename, "w")
    file:write(tostring(self.content))
    file:close()
end

function meta.write(self, str)
    self.content:append(str)
end

function meta.write_hexstr(self, data)
    for _, datum in ipairs(data) do
        self.content:append(string.format("%02x", datum))
    end
end

function meta.write_binary(self, data)
    for _, datum in ipairs(data) do
        self.content:append(string.char(datum))
    end
end

return M
