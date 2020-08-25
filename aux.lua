local M = {}

function M.call_if_present(func, ...)
    if func then
        return func(...)
    end
end

return M
