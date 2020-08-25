local M = {}

function M.call_if_present(func, ...)
    if func then
        return func(...)
    end
end

function M.map(t, func)
    local res = {}
    for k, v in pairs(t) do
        res[k] = func(v)
    end
    return res
end

function M.concat(data, sep, pre, post, newline)
    local pre = pre or ""
    local post = post or ""
    local sep = sep or ", "
    if newline then
        sep = sep .. "\n"
    end
    local fun = function(str)
        return string.format("%s%s%s", pre, str, post)
    end
    local processed = M.map(data, fun)
    local tabstr = table.concat(processed, sep)
    return tabstr
end

return M
