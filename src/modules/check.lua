local M = {}

local funcnamestack = {}

-- all check functions are used in API functions,
-- hence the report level for error() is 3;
--   * level 0: error()
--   * level 1: check_xxx()
--   * level 2: API function calling check_xxx()
--   * level 3: actual use of API function

local calllevel = 3

function M.set_next_function_name(funcname)
    funcnamestack[#funcnamestack + 1] = funcname
end

function M.reset_function_name(funcname)
    funcnamestack[#funcnamestack] = nil
end

function M.arg(index, argname, typename, arg)
    if not arg then
        error(string.format("%s expected a %s as argument #%d ('%s'), got nil", funcnamestack[#funcnamestack], typename, index, argname), calllevel)
    end
    if type(arg) ~= typename then
        error(string.format("%s expected a %s as argument #%d ('%s'), got %s", funcnamestack[#funcnamestack], typename, index, argname, type(arg)), calllevel)
    end
end

function M.arg_optional(index, argname, typename, arg)
    if arg and type(arg) ~= typename then
        error(string.format("%s expected a (optional) %s as argument #%d ('%s'), got %s", funcnamestack[#funcnamestack], typename, index, argname, type(arg)), calllevel)
    end
end

function M.arg_func(index, argname, typename, arg, func)
    if not arg then
        error(string.format("%s expected a %s as argument #%d ('%s'), got nil", funcnamestack[#funcnamestack], typename, index, argname), calllevel)
    end
    if not func(arg) then
        error(string.format("%s expected a %s as argument #%d ('%s'), got %s", funcnamestack[#funcnamestack], typename, index, argname, type(arg)), calllevel)
    end
end

function M.arg_options_table(options, keys)
    for k in pairs(options) do
        if not util.any_of(k, keys) then
            error(string.format("options table must contain only allowed keys (one of { %s }), illegal key: '%s'", util.tconcatfmt(keys, ", ", "'%s'"), k), calllevel)
        end
    end
end

return M
