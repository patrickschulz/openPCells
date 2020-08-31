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

return M
