local M = {}

local funcnamestack = {}

function M.set_next_function_name(funcname)
    funcnamestack[#funcnamestack + 1] = funcname
end

function M.reset_function_name(funcname)
    funcnamestack[#funcnamestack] = nil
end

function M.arg(index, argname, typename, arg)
    if not arg then
        error(string.format("%s expected a %s as argument #%d ('%s'), got nil", funcnamestack[#funcnamestack], typename, index, argname))
    end
    if type(arg) ~= typename then
        error(string.format("%s expected a %s as argument #%d ('%s'), got %s", funcnamestack[#funcnamestack], typename, index, argname, type(arg)))
    end
end

function M.arg_optional(index, argname, typename, arg)
    if arg and type(arg) ~= typename then
        error(string.format("%s expected a (optional) %s as argument #%d ('%s'), got %s", funcnamestack[#funcnamestack], typename, index, argname, type(arg)))
    end
end

function M.arg_func(index, argname, typename, arg, func)
    if not arg then
        error(string.format("%s expected a %s as argument #%d ('%s'), got nil", funcnamestack[#funcnamestack], typename, index, argname))
    end
    if not func(arg) then
        error(string.format("%s expected a %s as argument #%d ('%s'), got %s", funcnamestack[#funcnamestack], typename, index, argname, type(arg)))
    end
end

return M
