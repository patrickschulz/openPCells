local M = {}

local interface

function M.load(name)
    interface = require(string.format("interface.%s", name))
end

function M.write_cell(filename, cell)
    local extension = interface.get_extension()
    local file = io.open(string.format("%s.%s", filename, extension), "w")
    interface.print_object(file, cell)
    file:close()
end

return M
