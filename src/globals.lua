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
        if not arg or type(arg) ~= argtype or not extracheck(arg) then
            moderror(string.format("%s: %s expected, got %s", info.name, argtype, type(arg)))
        end
    end
end

function check_number(arg)
    -- explicitely pass 'isoptional' as false (default) for NaN check (n != n)
    _check_argument(arg, "number", false, function(n) return n == n end)
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
