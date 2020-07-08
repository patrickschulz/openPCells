local M = {}

local celllist = {
    "transistor",
    "momcap"
}

local cellcode = {}
for _, cell in ipairs(celllist) do
    cellcode[cell] = require(string.format("cells.%s", cell))
end

function M.create(name, args)
    print(table.unpack(args))
    local func = cellcode[name]
    if not func then return nil end
    return func(table.unpack(args))
end

return M
