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
local overrides = {}

local function _unpack_param(param)
    return param[1], param[2], param[3], param[4]
end

local function _get_parameters(cellname)
    if not paramdir[cellname] then
        local _currentcell = currentcell -- save current cell name
        celllib.load_cell(cellname)
        currentcell = _currentcell -- restore current cell name
    end
    return paramdir[cellname]
end

local function _get_parameter(cellname, name)
    local dir = _get_parameters(cellname)
    local _, p = aux.find(dir, function(v) return v.name == name end)
    if not p then
        print(string.format("trying to access undefined parameter '%s' in cell '%s'", name, cellname))
        os.exit(exitcodes.undefinedparameter)
    end
    return p
end

local function _process(args, evaluate)
    local args = args or {}
    for name, value in pairs(args) do
        local p = _get_parameter(currentcell, name)
        if not p then
            print(string.format("argument '%s' was not used, maybe it was spelled wrong?", name))
            os.exit(1)
        end
        if evaluate then
            local eval = evaluators[p.argtype]
            p.value = eval(value) -- replace default value
        else
            p.value = value
        end
    end
end

-- FIXME: clean up code (maybe add _set_parameter_value?)
local function _set_overrides(cellname)
    if overrides[cellname] then
        for name, value in pairs(overrides[cellname]) do
            local p = _get_parameter(currentcell, name)
            if value.func then
                p.value = _get_parameter(value.func.cell, value.func.name).value
            else
                p.value = value.value
            end
        end
    end
end

local function _get_pname_dname(name)
    local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
    if not pname then pname = name end -- no display name
    return pname, dname
end

local function _add_parameter(name, dname, value, argtype, posvals, overwrite)
    local argtype = argtype or type(value)
    debug.print("pcell", string.format('_add_parameter("%s", "%s", %s, "%s")', name, dname, value, argtype))
    local new = {
        name    = name,
        display = dname,
        value   = value,
        argtype = argtype,
        posvals = posvals
    }
    local idx, old = aux.find(_get_parameters(currentcell), function(v) return v.name == name end)
    if old then
        if overwrite then
            _get_parameters(currentcell)[idx] = new
        else
            return false
        end
    else
        table.insert(_get_parameters(currentcell), new)
    end
    return true
end

local function _set_cell(cellname)
    debug.print("pcell", string.format("_set_cell() with '%s'", cellname))
    paramdir[cellname] = {}
    currentcell = cellname
end

-- public functions
function M.add_parameters(...)
    debug.print("pcell", string.format("add_parameters() for '%s'", currentcell))
    for i, param in ipairs({...}) do
        local name, default, argtype, posvals = _unpack_param(param)
        local pname, dname = _get_pname_dname(name)
        _add_parameter(pname, dname, default, argtype, posvals)
    end
end

function M.bind_parameter(name, othercell, othername)
    debug.print("pcell", string.format("bind_parameter(%s, %s, %s) (currentcell = %s)", name, othercell, othername, currentcell))
    if not overrides[othercell] then overrides[othercell] = {} end
    overrides[othercell][othername] = { func = { cell = currentcell, name = name } }
end

function M.unbind(othercell, othername)
    overrides[othercell][othername] = nil
end

--[[
function M.inherit_parameter(othercell, name)
    debug.print("pcell", string.format("inherit_parameter(%s, %s)", othercell, name))

    local _currentcell = currentcell -- save current cell name
    celllib.load_cell(othercell)
    local inherited = paramdir[othercell]
    currentcell = _currentcell -- restor current cell name

    local start = _max_index(paramdir[currentcell])
    if not inherited[name] then
        print(string.format("trying to inherit unknown parameter '%s'", k))
        os.exit(exitcodes.unknownparameter)
    end
    paramdir[currentcell][name] = inherited[name]
    paramdir[currentcell][name].index = start + 1 -- fix index
end
--]]

--[[
function M.inherit_and_bind_parameter(othercell, name)
    debug.print("pcell", string.format("inherit_and_bind_parameter(%s, %s)", othercell, name))
    debug.down()
    M.inherit_parameter(othercell, name)
    M.bind_parameter(name, othercell, name)
    debug.up()
end
--]]

function M.inherit_and_bind_all_parameters(othercell, overwrite)
    debug.print("pcell", string.format('inherit_and_bind_all_parameter("%s")', othercell))
    local inherited = _get_parameters(othercell)

    for _, inh in ipairs(inherited) do
        local added = _add_parameter(inh.name, inh.display, inh.value, inh.argtype, inh.posvals)
        if added then
            M.bind_parameter(inh.name, othercell, inh.name)
        end
    end
end

--[[
function M.override_defaults(othercell, ...)
    if not overrides[othercell] then overrides[othercell] = {} end
    local ov = overrides[othercell]
    for _, p in ipairs({...}) do
        local name = p[1]
        local value = p[2]
        ov[name] = { value = value }
    end
end
--]]

function M.load(paramfunc, cellname)
    _set_cell(cellname)
    aux.call_if_present(paramfunc)
end

function M.process(cellname, cellargs, evaluate)
    _set_overrides(cellname)
    _process(cellargs, evaluate)
end

function M.get_parameters(cellname)
    debug.print("pcell", string.format("get_parameters() with '%s'", cellname))
    local P = {}
    for _, v in ipairs(_get_parameters(cellname)) do
        P[v.name] = v.value
    end
    local meta = {
        __index = function(t, k)
            print(string.format("could not find parameter '%s', maybe it was spelled wrong?", k))
            os.exit(exitcodes.parameternotfound)
        end
    }
    setmetatable(P, meta)
    return P
end

function M.iter()
    return ipairs(_get_parameters(currentcell))
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
