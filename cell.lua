local M = {}

local celllist = {
    "transistor",
    "momcap"
}

local cellcode = {}
for _, cell in ipairs(celllist) do
    cellcode[cell] = dofile(string.format("cells/%s.lua", cell))
end

function M.create(name, options)
    local func = cellcode[name]
    if not func then return nil end
    return func()
end

return M
