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

local params 

local function _unpack_param(param)
    return param[1], param[2], param[3], param[4]
end

function M.add_parameters(...)
    for i, param in ipairs({...}) do
        local name, default, argtype, posvals = _unpack_param(param)
        local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
        if not pname then pname = name end
        params[pname] = { 
            display = dname,
            value   = default,
            argtype = argtype or type(default),
            posvals = posvals,
            index = i
        }
    end
end

function M.setup()
    -- reset parameters
    params = {}
end

function M.process(args, evaluate)
    for name, value in pairs(args) do
        if not params[name] then
            print(string.format("argument '%s' was not used, maybe it was spelled wrong?", name))
            os.exit(1)
        end
        local param = params[name]
        if evaluate then
            local eval = evaluators[param.argtype]
            param.value = eval(value) -- replace default value
        else
            param.value = value
        end
    end
end

function M.get_params()
    local P = {}
    for k, v in pairs(params) do
        P[k] = v.value
    end
    return P
end

function M.iter()
    local t = {}
    for name, entry in pairs(params) do
        t[entry.index] = {
            name = name,
            display = entry.display,
            default = entry.value,
            argtype = entry.argtype,
            posvals = entry.posvals,
        }
    end
    return ipairs(t)
end

return M
