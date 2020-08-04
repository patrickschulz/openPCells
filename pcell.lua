local M = {}

local function identity(arg) return arg end
local function toboolean(arg) 
    return arg == "true" and true or false
end
local function tointeger(arg)
    return math.floor(tonumber(arg))
end

local evaluators = {
    number = tonumber,
    integer = tointeger,
    string = identity,
    boolean = toboolean,
    table = nil -- not yet implemented
}

local used
local args

function M.process_args(name, default, argtype, posvals)
    local argtype = argtype or type(default)
    local eval = evaluators[argtype]
    local res
    if args[name] then
        used[name] = true
        res = eval(args[name])
    else
        res = default
    end
    if posvals then

    end
    return res
end

function M.setup(a)
    used = {}
    args = a
end

function M.check_args()
    for k in pairs(args) do
        if not used[k] then
            print(string.format("argument '%s' was not used, maybe it was spelled wrong?", k))
            os.exit(1)
        end
    end
end

return M
