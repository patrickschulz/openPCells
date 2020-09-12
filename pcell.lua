local M = {}

local function identity(arg) return arg end
local function toboolean(arg) 
    return arg == "true" and true or false
end
local function tointeger(arg)
    return math.floor(tonumber(arg))
end
local function totable(arg)
    local t = {}
    for e in string.gmatch(arg, "[^;,]+") do
        table.insert(t, e)
    end
    return t
end

local evaluators = {
    number = tonumber,
    integer = tointeger,
    string = identity,
    boolean = toboolean,
    table = totable,
}

local paramdir = {}
local currentcell

local function _get_parameters(cellname)
    if not paramdir[cellname] then
        local _currentcell = currentcell -- save current cell name
        celllib.load_cell(cellname)
        currentcell = _currentcell -- restore current cell name
    end
    return paramdir[cellname]
end

local function _get_parameter(cellname, name, silent)
    local dir = _get_parameters(cellname)
    local p = dir.parameters[name]
    if not p and not silent then
        print(string.format("trying to access undefined parameter definition '%s' in cell '%s'", name, cellname))
        os.exit(exitcodes.undefinedparameter)
    end
    return p
end

local function _get_pname_dname(name)
    local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
    if not pname then pname = name end -- no display name
    return pname, dname
end

local function _add_parameter(cell, name, value, argtype, posvals, overwrite)
    local argtype = argtype or type(value)
    local pname, dname = _get_pname_dname(name)
    local new = {
        display = dname,
        func    = funcobject.identity(value),
        argtype = argtype,
        posvals = posvals
    }
    if not paramdir[cell].parameters[pname] or overwrite then
        paramdir[cell].parameters[pname] = new
        paramdir[cell].num = paramdir[cell].num + 1
        paramdir[cell].indices[pname] = paramdir[cell].num
    else
        return false
    end
    return true
end

local function _process(args, evaluate)
    local args = args or {}
    for name, value in pairs(args) do
        local p = _get_parameter(currentcell, name, true)
        if not p then
            print(string.format("argument '%s' has no matching parameter, maybe it was spelled wrong?", name))
            os.exit(1)
        end
        local v = value
        if evaluate then
            local eval = evaluators[p.argtype]
            v = eval(value) -- replace default value
        end
        -- important: use :replace(), don't create a new function object. 
        -- Otherwise parameter binding does not work, because bound parameters link to the original function object
        p.func:replace(function() return v end)
    end
end

local function _set_cell(cellname)
    paramdir[cellname] = {
        parameters = {},
        indices = {},
        num = 0
    }
    currentcell = cellname
end

-- public functions
function M.add_parameters(...)
    for _, param in ipairs({...}) do
        local name, default, argtype, posvals = table.unpack(param)
        _add_parameter(currentcell, name, default, argtype, posvals)
    end
end

function M.inherit_parameter(othercell, name)
    local param = _get_parameter(othercell, name)
    _add_parameter(currentcell, name, param.func(), param.argtype, param.posvals)
end

function M.bind_parameter(name, othercell, othername)
    local otherparam = _get_parameter(othercell, othername)
    local param = _get_parameter(currentcell, name)
    otherparam.func = param.func
end

function M.inherit_and_bind_parameter(othercell, name)
    M.inherit_parameter(othercell, name)
    M.bind_parameter(name, othercell, name)
end

function M.inherit_and_bind_all_parameters(othercell, overwrite)
    local inherited = _get_parameters(othercell)
    for name, param in pairs(inherited.parameters) do 
        M.inherit_and_bind_parameter(othercell, name)
    end
end

function M.load(paramfunc, cellname)
    _set_cell(cellname)
    aux.call_if_present(paramfunc)
end

function M.get_parameters(cellname, cellargs, evaluate)
    _process(cellargs, evaluate)
    local P = {}
    for name, entry in pairs(paramdir[cellname].parameters) do
        P[name] = entry.func()
    end
    local meta = {
        __index = function(t, k)
            print(string.format("trying to access undefined parameter value '%s'", k))
            os.exit(exitcodes.parameternotfound)
        end
    }
    setmetatable(P, meta)
    return P
end

function M.iter()
    local ret = {}
    local params = _get_parameters(currentcell)
    for k, v in pairs(params.parameters) do
        ret[params.indices[k]] = { name = k, value = v.func(), argtype = v.argtype }
    end
    return ipairs(ret)
end

--[[
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
--]]

return M
