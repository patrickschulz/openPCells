--[[
This file is part of the openPCells project.

This module provides the pcell functionality:
    - functions for cell parameterization
    - parameter inheritance and binding (cell hierarchies)
    - layout generation
    - parameter summary

Implementation note:
    Every parameter stores a function return its value, which is only
    evaluated when it is needed: at the moment of shape creation.
    This more complex approach (compared to just storing the values)
    allows for easy binding and inheritance of parameters.
--]]

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

local function _prepare_cell_environment(cellname)
    return {
        pcell = {
            add_parameter                   = bind(add_parameter,                   1, cellname),
            add_parameters                  = bind(add_parameters,                  1, cellname),
            inherit_parameter               = bind(inherit_parameter,               1, cellname),
            bind_parameter                  = bind(bind_parameter,                  1, cellname),
            inherit_and_bind_parameter      = bind(inherit_and_bind_parameter,      1, cellname),
            inherit_and_bind_all_parameters = bind(inherit_and_bind_all_parameters, 1, cellname),
            create_layout = M.create_layout
        },
        geometry = geometry,
        graphics = graphics,
        shape = shape,
        generics = generics,
        point = point,
        util = util,
        aux = aux,
        math = math,
        enable = function(bool, val) return (bool and 1 or 0) * val end,
        string = string,
        table = table,
        print = print,
        ipairs = ipairs
    }
end

local function _load(cellname)
    local file = io.open(string.format("%s/cells/%s.lua", _get_opc_home(), cellname))
    if not file then
        return nil, string.format("unknown cell '%s'", cellname)
    end
    local content = file:read("*a")
    local env = _prepare_cell_environment(cellname)
    local chunkname = string.format("=cell '%s'", cellname)
    local chunk, msg = load(content, chunkname, "t", env)
    if not chunk then
        return nil, string.format("syntax error in cell '%s': %s", cellname, msg)
    end
    local status, msg = pcall(chunk)
    if not status then
        return nil, string.format("semantic error in cell '%s': %s", cellname, msg)
    end
    return env
end

local meta = {}
meta.__index = function(t, cellname)
    local funcs, msg = _load(cellname)
    if not funcs then
        print(msg)
        os.exit(exitcodes.syntaxerrorincell)
    end
    if not (funcs.parameters or funcs.layout) then
        print("every cell must define the public functions 'parameters' and 'layout'")
        os.exit(exitcodes.usererrorincell)
    end
    local cell = {
        funcs = funcs,
        parameters = {},
        indices = {},
        num = 0
    }
    t[cellname] = cell
    return cell
end
local loadedcells = setmetatable({}, meta)

local function _get_pname_dname(name)
    local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
    if not pname then pname = name end -- no display name
    return pname, dname
end

local function _add_parameter(cellname, name, value, argtype, posvals, overwrite)
    local argtype = argtype or type(value)
    local pname, dname = _get_pname_dname(name)
    local new = {
        display = dname,
        func    = funcobject.identity(value),
        argtype = argtype,
        posvals = posvals
    }
    if not loadedcells[cellname].parameters[ppname] or overwrite then
        loadedcells[cellname].parameters[pname] = new
        loadedcells[cellname].num = loadedcells[cellname].num + 1
        loadedcells[cellname].indices[pname] = loadedcells[cellname].num
    else
        return false
    end
    return true
end

local function _load_cell(cellname)
    local cell = loadedcells[cellname]
    cell.funcs.parameters()
    return cell
end

--------------------------------------------------------------------
function add_parameter(cellname, name, value, argtype)
    _add_parameter(cellname, name, value, argtype)
end

function add_parameters(cellname, ...)
    for _, parameter in ipairs({ ... }) do
        add_parameter(cellname, table.unpack(parameter))
    end
end

function inherit_parameter(cellname, othercell, name)
    local param = loadedcells[othercell].parameters[name]
    _add_parameter(cellname, name, param.func(), param.argtype, param.posvals)
end

function bind_parameter(cellname, name, othercell, othername)
    local otherparam = loadedcells[othercell].parameters[othername]
    local param = loadedcells[cellname].parameters[name]
    otherparam.func = param.func
end

function inherit_and_bind_parameter(cellname, othercell, name)
    inherit_parameter(cellname, othercell, name)
    bind_parameter(cellname, name, othercell, name)
end

function inherit_and_bind_all_parameters(cellname, othercell)
    local inherited = _load_cell(othercell)
    for name, param in pairs(inherited.parameters) do 
        inherit_and_bind_parameter(cellname, othercell, name)
    end
end
--------------------------------------------------------------------

function M.get_parameters(cellname, cellargs, evaluate)
    local cellparams = loadedcells[cellname].parameters
    local cellargs = cellargs or {}

    -- process input arguments
    local args = args or {}
    for name, value in pairs(cellargs) do
        local p = cellparams[name]
        if not p then
            print(string.format("argument '%s' has no matching parameter, maybe it was spelled wrong?", name))
            os.exit(1)
        end
        if evaluate then
            local eval = evaluators[p.argtype]
            value = eval(value)
        end
        -- important: use :replace(), don't create a new function object. 
        -- Otherwise parameter binding does not work, because bound parameters link to the original function object
        p.func:replace(function() return value end)
    end

    -- store parameters in user-readable table
    local P = {}
    for name, entry in pairs(cellparams) do
        P[name] = entry.func()
    end
    
    -- install meta method for non-existing parameters as safety check 
    -- this avoids arithmetic-with-nil-errors
    setmetatable(P, {
        __index = function(t, k)
            print(string.format("trying to access undefined parameter value '%s'", k))
            os.exit(exitcodes.parameternotfound)
        end
    })

    return P
end

function M.create_layout(name, args, evaluate)
    local cell = _load_cell(name)
    local obj = object.create()
    local parameters = M.get_parameters(name, args, evaluate)
    local status, msg = pcall(cell.funcs.layout, obj, parameters)
    if not status then
        print(string.format("could not create cell '%s': %s", name, msg))
        os.exit(exitcodes.syntaxerrorincell)
    end
    return obj
end

function M.parameters(name)
    local cellfuncs = _load_cell(name)
    for _, v in pcell.iter() do
        print(string.format("%s %s %s", tostring(v.name), tostring(v.value), tostring(v.argtype)))
    end
end

return M
