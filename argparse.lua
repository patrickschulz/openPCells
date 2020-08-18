local M = {}

function M.parse(args)
    local i = 1
    local res = {cellargs = {}}
    while i <= #args do
        local arg = args[i]
        if string.match(arg, "^-P") then
            res.params = true
        elseif string.match(arg, "^-T") then
            res.technology = args[i + 1]
            i = i + 1
        elseif string.match(arg, "^-I") then
            res.interface = args[i + 1]
            i = i + 1
        elseif string.match(arg, "^-C") then
            res.cell = args[i + 1]
            i = i + 1
        elseif string.match(arg, "^-f") then
            res.filename = args[i + 1]
            i = i + 1
        else
            table.insert(res.cellargs, arg)
        end
        i = i + 1
    end
    return res
end

return M
