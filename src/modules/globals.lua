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

local function _check_type(arg, argtype)
    if type(arg) == argtype then
        return true
    elseif type(arg) == "userdata" then
        local meta = getmetatable(arg)
        if not meta then
            return false
        end
        if meta.__name and meta.__name == argtype then
            return true
        end
        return false
    end
    return false
end

local function _check_argument(arg, argtype, msg, isoptional, extracheck)
    local info = debug.getinfo(3, "nS")
    msg = msg or string.format("%s: %s expected", info.name, argtype)
    if isoptional then
        if arg then
            if not _check_type(arg, argtype) then
                moderror(string.format("%s (got %s)", msg, type(arg)))
            end
        end
    else
        if not arg or not _check_type(arg, argtype) then
            moderror(string.format("%s (got %s)", msg, type(arg)))
        end
        if extracheck and not extracheck(arg) then
            local res, msg = extracheck(arg)
            moderror(string.format("%s (got %s)", msg, type(arg)))
        end
    end
end

function check_number(arg, msg)
    -- explicitely pass 'isoptional' as false (default) for NaN check (n != n)
    _check_argument(arg, "number", msg, false, function(n) return n == n end)
end

function check_number_range(arg, bound, msg)
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
    _check_argument(arg, "number", msg, false, function(n) 
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

function check_string(arg, msg)
    _check_argument(arg, "string", msg)
end

function check_table(arg, msg)
    _check_argument(arg, "table", msg)
end

function check_optional_table(arg, msg)
    _check_argument(arg, "table", msg, true)
end

function check_point(arg, msg)
    _check_argument(arg, "lpoint", msg)
end

function check_object(arg, msg)
    _check_argument(arg, "object", msg)
end

function evenodddiv2(num)
    if num % 2 == 0 then
        return num / 2, num / 2
    else
        return num // 2, num // 2 + 1
    end
end

function divevendown(num, div)
    while (num / div % 2) ~= 0 do
        num = num - 1
    end
    return num / div
end

function divevenup(num, div)
    while (num / div % 2) ~= 0 do
        num = num + 1
    end
    return num / div
end

function modinfo(msg)
    print(msg)
end

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
