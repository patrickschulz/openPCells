local M = {}

local pretty = require "pl.pretty"

function M.get_extension()
    return "debug"
end

local function _serialize_table(t, indent)
    local indent = indent or 4
    local indentstr = string.rep(" ", indent)
    local res = {}
    table.insert(res, "{")
    for k, v in pairs(t) do
        local str = string.format("%s%s = ", indentstr, k)
        if type(v) == "table" then
            str = str .. _serialize_table(v, indent + 4)
        elseif type(v) == "function" then
            str = str .. string.format("%s,", v)
        else
            str = str .. string.format("%s,", v)
        end
        table.insert(res, str)
    end
    table.insert(res, string.format("%s}", string.rep(" ", indent - 4)))
    return table.concat(res, "\n")
end

function M.print_object(file, obj)
    for shape in obj:iter() do
        file:write(string.format("%s\n", ">>>>> Start Shape >>>>>"))
        local str = _serialize_table(shape)
        file:write(string.format("%s\n", str))
        file:write(string.format("%s\n", "<<<<<  End Shape  <<<<<"))
    end
end

return M
