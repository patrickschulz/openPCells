local M = {}

local options = {}

function M.set(str)
    if str then
        for module in string.gmatch(str, "[^;]+") do
            options[module] = true
        end
    end
end

function M.print(module, msg)
    if options[module] then
        print(string.format("%s: %s", module, msg))
    end
end

return M
