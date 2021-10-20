local M = {}

local variables = {}

function M.set(name, value)
    variables[name] = value
end

function M.get(name)
    return variables[name]
end

return M
