local M = {}

local options = {}
local indent = 0

function M.set(str)
    if str then
        for module in string.gmatch(str, "[^;,]+") do
            options[module] = true
        end
    end
end

function M.print(module, msg)
    if options[module] then
        local indentstr = string.rep(" ", 2 * indent)
        print(string.format("%s%s: %s", indentstr, module, msg))
    end
end

function M.down()
    indent = indent + 1
end

function M.up()
    indent = indent - 1
end

function M.serialize(t, indent)
    local indent = indent or 4
    local indentstr = string.rep(" ", indent)
    local res = {}
    table.insert(res, "{")
    for k, v in pairs(t) do
        local str = string.format("%s%s = ", indentstr, k)
        if type(v) == "table" then
            str = str .. M.serialize(v, indent + 4)
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

return M
