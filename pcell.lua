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
local overrides = {}

local function _unpack_param(param)
    return param[1], param[2], param[3], param[4]
end

local function _max_index()
    local index = 0
    for _, v in pairs(params) do
        index = math.max(index, v.index)
    end
    return index
end

local function _add_parameter()
end

function M.add_parameters(...)
    debug.print("pcell", "add_parameters()")
    local start = _max_index()
    for i, param in ipairs({...}) do
        local name, default, argtype, posvals = _unpack_param(param)
        local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
        if not pname then pname = name end
        params[pname] = { 
            display = dname,
            value   = default,
            argtype = argtype or type(default),
            posvals = posvals,
            index = i + start
        }
    end
end

function M.inherit_parameters(name, ...)
    debug.print("pcell", "inherit_parameters()")
    local prev = params -- store current parameters

    celllib.load_cell(name)
    local inherited = params -- save loaded parameters

    M.setup(prev) -- reset state
    local start = _max_index()
    for i, k in ipairs({...}) do
        if not inherited[k] then
            print(string.format("trying to inherit unknown parameter '%s'", k))
            os.exit(exitcodes.unknownparameter)
        end
        params[k] = inherited[k]
        params[k].index = i + start -- fix index
    end
end

function M.setup(p)
    debug.print("pcell", string.format("resetting parameters (%s)", tostring(p)))
    params = p or {}
end

function M.process(args, evaluate)
    local args = args or {}
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

function M.override_defaults(cell, ...)
    if not overrides[cell] then overrides[cell] = {} end
    local ov = overrides[cell]
    for _, p in ipairs({...}) do
        local name = p[1]
        local value = p[2]
        ov[name] = value
    end
end

function M.set_overrides(cell)
    if overrides[cell] then
        for name, value in pairs(overrides[cell]) do
            params[name].value = value
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

local meta = {
    overwrite = function(self, mod)
        for k, v in pairs(mod) do
            self[k] = v
        end
    end,
    modify = function(self, mod)
        local new = M.make_options({})
        new:overwrite(self) -- copy self
        new:overwrite(mod)  -- overwrite options
        return new
    end,
}
meta.__index = meta
function M.make_options(opt)
    local opt = opt or {}
    setmetatable(opt, meta)
    return opt
end

return M
