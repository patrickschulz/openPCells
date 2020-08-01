local M = {}

-- public interface
function M.create(name, args)
    local func = require(string.format("cells.%s", name))
    if not func then 
        return nil, string.format("unknown cell '%s'", name)
    end
    return func(args)
end

return M
