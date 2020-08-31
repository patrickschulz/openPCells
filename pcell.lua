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

local paramdir = {}
local currentcell
local overrides = {}

local function _unpack_param(param)
    return param[1], param[2], param[3], param[4]
end

local function _max_index(params)
    local index = 0
    for _, v in pairs(params) do
        index = math.max(index, v.index)
    end
    return index
end

local function _process(args, evaluate)
    local args = args or {}
    for name, value in pairs(args) do
        if not currentparams[name] then
            print(string.format("argument '%s' was not used, maybe it was spelled wrong?", name))
            os.exit(1)
        end
        local param = currentparams[name]
        if evaluate then
            local eval = evaluators[param.argtype]
            param.value = eval(value) -- replace default value
        else
            param.value = value
        end
    end
end

local function _set_overrides(cellname)
    if overrides[cellname] then
        for name, value in pairs(overrides[cellname]) do
            if value.func then
                currentparams[name].value = M.get_parameter(value.func.cell, value.func.name)
            else
                currentparams[name].value = value.value
            end
        end
    end
end

local function _get_pname_dname(name)
    local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
    if not pname then pname = name end -- no display name
    return pname, dname
end

local function _add_parameter(param, index, start)
    debug.print("pcell", string.format("_add_parameter(%s)", param[1]))
    local name, default, argtype, posvals = _unpack_param(param)
    local pname, dname = _get_pname_dname(name)
    currentparams[pname] = { 
        display = dname,
        value   = default,
        argtype = argtype or type(default),
        posvals = posvals,
        index = index + start
    }
end

local function _set_cell(cellname)
    debug.print("pcell", string.format("_set_cell() with '%s'", cellname))
    paramdir[cellname] = {}
    currentcell = cellname
    currentparams = paramdir[cellname]
end

-- public functions
function M.add_parameters(...)
    debug.print("pcell", string.format("add_parameters() for '%s'", currentcell))
    local start = _max_index(currentparams)
    for i, param in ipairs({...}) do
        _add_parameter(param, i, start)
    end
end

function M.add_bind_parameter(name, othercell, othername)
    debug.print("pcell", string.format("add_bind_parameter(%s, %s, %s) (currentcell = %s)", name, othercell, othername, currentcell))
    if not overrides[othercell] then overrides[othercell] = {} end
    local ov = overrides[othercell]
    --ov[othername] = { func = function() return M.get_parameter(currentcell, name) end }
    ov[othername] = { func = { cell = currentcell, name = name } }
end

function M.inherit_parameter(othercell, name)
    debug.print("pcell", "inherit_parameters()")
    local prev = params -- store current parameters

    celllib.load_cell(othercell)
    local inherited = params -- save loaded parameters

    local start = _max_index()
    if not inherited[name] then
        print(string.format("trying to inherit unknown parameter '%s'", k))
        os.exit(exitcodes.unknownparameter)
    end
    currentparams[name] = inherited[name]
    currentparams[name].index = start + 1 -- fix index
end

function M.override_defaults(othercell, ...)
    if not overrides[othercell] then overrides[othercell] = {} end
    local ov = overrides[othercell]
    for _, p in ipairs({...}) do
        local name = p[1]
        local value = p[2]
        ov[name] = { value = value }
    end
end

function M.process(paramfunc, cellname, cellargs, evaluate)
    _set_cell(cellname)
    aux.call_if_present(paramfunc)
    _process(cellargs, evaluate)
    _set_overrides(cellname)
end

function M.get_parameter(cellname, parameter)
    debug.print("pcell", string.format("get_parameter(%s, %s)", cellname, parameter))
    return paramdir[cellname][parameter].value
end

function M.get_parameters(cellname)
    debug.print("pcell", string.format("get_parameters() with '%s'", cellname))
    local P = {}
    for k, v in pairs(paramdir[cellname]) do
        P[k] = v.value
    end
    return P
end

function M.iter()
    local t = {}
    for name, entry in pairs(currentparams) do
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
