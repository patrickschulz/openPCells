function check_arg(arg, argtype, msg)
    if argtype or not arg then
        if type(arg) ~= argtype then
            moderror(msg)
        end
    else
        if not arg then
            moderror(msg)
        end
    end
end

function check_arg_or_nil(arg, argtype, msg)
    if arg and argtype then
        if type(arg) ~= argtype then
            moderror(msg)
        end
    end
end

local function _check_argument(arg, argtype, isoptional, extracheck)
    local info = debug.getinfo(2, "nS")
    if isoptional then
        if arg then
            if type(arg) ~= argtype then
                moderror(string.format("%s: %s expected, got %s", info.name, argtype, type(arg)))
            end
        end
    else
        if not arg or type(arg) ~= argtype then
            moderror(string.format("%s: %s expected, got %s", info.name, argtype, type(arg)))
        end
        if not extracheck(arg) then
            local res, msg = extracheck(arg)
            moderror(string.format("%s: %s", info.name, msg))
        end
    end
end

function check_number(arg)
    -- explicitely pass 'isoptional' as false (default) for NaN check (n != n)
    _check_argument(arg, "number", false, function(n) return n == n end)
end

function check_number_range(arg, bound)
    local NaNcheck = function(n) 
        if n ~= n then
            return false, string.format("number is NaN")
        end
        return true
    end
    local boundcheck = function(n)
        if (bound.lowerinclusive and (n < bound.lower) or (n <= bound.lower)) or
           (bound.upperinclusive and (n > bound.upper) or (n >= bound.upper)) then
           return false, string.format("number (%s) must be between %f (%s) and %f (%s)", n, 
                bound.lower, bound.lowerinclusive and "inclusive" or "exclusive",
                bound.upper, bound.upperinclusive and "inclusive" or "exclusive")
        end
        return true
    end
    -- explicitely pass 'isoptional' as false (default) for NaN and boundary checks
    _check_argument(arg, "number", false, function(n) 
        local ret, msg = NaNcheck(n)
        if not ret then
            return false, msg
        end
        ret, msg = boundcheck(n)
        if not ret then
            return false, msg
        end
        return true
    end)
end

function check_string(arg)
    _check_argument(arg, "string")
end

function check_table(arg)
    _check_argument(arg, "table")
end

function check_optional_table(arg)
    _check_argument(arg, "table", true)
end

function modinfo(msg)
    print(msg)
end

--function moderror(msg)
--    local traceback = envlib.get("debug")
--    error({ msg = msg, traceback = traceback }, 0)
--end
function moderror(msg)
    error(msg, 0)
end

function modwarning(msg)
    print(msg)
end

function modassert(predicate, msg)
    if not predicate then
        moderror(msg)
    end
end
