local M = {}

local pretty = require "pl.pretty"

function M.get_extension()
    return "debug"
end

function M.print_object(file, obj)
    for shape in obj:iter() do
        file:write(string.format("%s\n", ">>>>> Start Shape >>>>>"))
        local str = pretty.write(shape.lpp)
        file:write(string.format("    %s\n", str))
        file:write(string.format("%s\n", "<<<<<  End Shape  <<<<<"))
    end
end

return M
