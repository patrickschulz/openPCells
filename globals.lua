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
    if argtype or not arg then
        if type(arg) ~= argtype then
            moderror(msg)
        end
    end
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
