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
local function tonumtable(arg)
    local t = {}
    for e in string.gmatch(arg, "[^;,]+") do
        table.insert(t, tonumber(e))
    end
    return t
end
local function tostrable(arg)
    local t = {}
    for e in string.gmatch(arg, "[^;,]+") do
        table.insert(t, tostring(e))
    end
    return t
end
local evaluators = {
    number   = tonumber,
    integer  = tointeger,
    string   = identity,
    boolean  = toboolean,
    numtable = tonumtable,
    strtable = tostrtable,
}

local function _prepare_cell_environment(cellname)
    local bindcell = function(func)
        return bind(func, 1, cellname)
    end
    return {
        pcell = {
            add_parameter                   = bindcell(add_parameter),
            add_parameters                  = bindcell(add_parameters),
            inherit_parameter               = bindcell(inherit_parameter),
            inherit_parameter_as            = bindcell(inherit_parameter_as),
            bind_parameter                  = bindcell(bind_parameter),
            inherit_all_parameters          = bindcell(inherit_all_parameters),
            inherit_and_bind_parameter      = bindcell(inherit_and_bind_parameter),
            inherit_and_bind_parameter_as   = bindcell(inherit_and_bind_parameter_as),
            inherit_and_bind_all_parameters = bindcell(inherit_and_bind_all_parameters),
            -- the following functions don't not need cell binding as they are called for other cells
            clone_parameters                = clone_parameters,
            clone_matching_parameters       = clone_matching_parameters,
            push_overwrites                 = push_overwrites,
            pop_overwrites                  = pop_overwrites,
            create_layout = M.create_layout
        },
        -- fake modules, the shapes are really created later
        -- this enables some tricks for example regarding even/odd metals 
        -- to build metal grids with unknown number of metals
        geometry = abstract.geometry,
        graphics = abstract.graphics,
        shape = shape,
        object = object,
        generics = generics,
        point = point,
        util = util,
        aux = aux,
        math = math,
        enable = function(bool, val) return (bool and 1 or 0) * val end,
        string = string,
        table = table,
        print = print,
        type = type,
        ipairs = ipairs,
        pairs = pairs,
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
        error(msg, 0)
    end
    if not (funcs.parameters or funcs.layout) then
        error("every cell must define at least the public functions 'parameters' or 'layout'", 0)
    end
    local cell = {
        funcs = funcs,
        parameters = {},
        indices = {},
        num = 0
    }
    rawset(t, cellname, cell)
    funcs.parameters()
    return cell
end
local loadedcells = setmetatable({}, meta)

local function _get_pname_dname(name)
    local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
    if not pname then pname = name end -- no display name
    return pname, dname
end

local function _add_parameter(cellname, name, value, argtype, posvals, follow, overwrite)
    local argtype = argtype or type(value)
    local pname, dname = _get_pname_dname(name)
    local new = {
        display = dname,
        func    = funcobject.identity(value),
        argtype = argtype,
        posvals = posvals,
        followers = {}
    }
    if not loadedcells[cellname].parameters[pname] or overwrite then
        loadedcells[cellname].parameters[pname] = new
        loadedcells[cellname].num = loadedcells[cellname].num + 1
        loadedcells[cellname].indices[pname] = loadedcells[cellname].num
        if follow then
            loadedcells[cellname].parameters[follow].followers[pname] = true
        end
    else
        return false
    end
    return true
end

local function _process_input_parameters(cellname, cellargs, evaluate, overwrite)
    local cellparams = loadedcells[cellname].parameters
    local cellargs = cellargs or {}

    local backup = {}

    -- process input arguments
    local args = args or {}
    for name, value in pairs(cellargs) do
        local p = cellparams[name]
        if not p then
            error(string.format("argument '%s' has no matching parameter, maybe it was spelled wrong?", name), 0)
        end
        if overwrite then
            p.overwritten = true
        end
        if evaluate then
            local eval = evaluators[p.argtype]
            value = eval(value)
        end
        -- store old function for restoration
        backup[name] = p.func:get()
        -- important: use :replace(), don't create a new function object. 
        -- Otherwise parameter binding does not work, because bound parameters link to the original function object
        p.func:replace(function() return value end)
    end

    return backup
end

local function _get_parameters(cellname, cellargs, evaluate)
    local cellparams = loadedcells[cellname].parameters
    local cellargs = cellargs or {}

    local backup = _process_input_parameters(cellname, cellargs, evaluate)

    -- store parameters in user-readable table
    local P = {}
    local handled = {}
    for name, entry in pairs(cellparams) do
        if not handled[name] or cellargs[name] then
            P[name] = entry.func()
            if cellargs[name] then
                handled[name] = true
            end
        end
        for follower in pairs(entry.followers) do
            if not (handled[follower] or cellparams[follower].overwritten) then
                P[follower] = entry.func()
                handled[follower] = true
            end
        end
    end

    -- install meta method for non-existing parameters as safety check 
    -- this avoids arithmetic-with-nil-errors
    setmetatable(P, {
        __index = function(t, k)
            error(string.format("trying to access undefined parameter value '%s'", k), 0)
        end,
    })

    return P, backup
end

local function _restore_parameters(cellname, backup)
    local cellparams = loadedcells[cellname].parameters
    -- restore old functions
    for name, func in pairs(backup) do
        cellparams[name].func:replace(func)
        cellparams[name].overwritten = nil
    end
end

--------------------------------------------------------------------
function add_parameter(cellname, name, value, opt)
    _add_parameter(cellname, name, value, opt.argtype, opt.posvals, opt.follow)
end

function add_parameters(cellname, ...)
    for _, parameter in ipairs({ ... }) do
        local name, value = parameter[1], parameter[2]
        _add_parameter(
            cellname, 
            name, value, 
            parameter.argtype, parameter.posvals, parameter.follow
        )
    end
end

function inherit_parameter(cellname, othercell, name)
    local param = loadedcells[othercell].parameters[name]
    _add_parameter(cellname, name, param.func(), param.argtype, param.posvals)
end

function inherit_parameter_as(cellname, name, othercell, othername)
    local param = loadedcells[othercell].parameters[othername]
    _add_parameter(cellname, name, param.func(), param.argtype, param.posvals)
end

function bind_parameter(cellname, name, othercell, othername)
    local param = loadedcells[cellname].parameters[name]
    if not param then 
        error(string.format("trying to bind '%s.%s' to '%s.%s', which is unknown", othercell, othername, cellname, name), 0)
    end
    local otherparam = loadedcells[othercell].parameters[othername]
    otherparam.func = param.func
end

function inherit_all_parameters(cellname, othercell)
    local inherited = loadedcells[othercell]
    for name, param in pairs(inherited.parameters) do 
        inherit_parameter(cellname, othercell, name)
    end
end

function inherit_and_bind_parameter(cellname, othercell, name)
    inherit_parameter(cellname, othercell, name)
    bind_parameter(cellname, name, othercell, name)
end

function inherit_and_bind_parameter_as(cellname, name, othercell, othername)
    inherit_parameter_as(cellname, name, othercell, othername)
    bind_parameter(cellname, name, othercell, othername)
end

function inherit_and_bind_all_parameters(cellname, othercell)
    local inherited = loadedcells[othercell]
    for name, param in pairs(inherited.parameters) do 
        inherit_and_bind_parameter(cellname, othercell, name)
    end
end

local backupstacks = {}
function push_overwrites(cellname, cellargs)
    local cellparams = loadedcells[cellname].parameters
    local backup = _process_input_parameters(cellname, cellargs, false, true)
    if not backupstacks[cellname] then
        backupstacks[cellname] = stack.create()
    end
    backupstacks[cellname]:push(backup)
end

function pop_overwrites(cellname)
    if (not backupstacks[cellname]) or (not backupstacks[cellname]:peek()) then
        error(string.format("trying to restore default parameters for '%s', but there where no previous overwrites", cellname), 0)
    end
    _restore_parameters(cellname, backupstacks[cellname]:top())
    backupstacks[cellname]:pop()
end

function empty_overwrite_stack(cellname)
    -- restore all cell defaults
    if backupstacks[cellname] then
        while backupstacks[cellname]:peek() do
            _restore_parameters(cellname, backupstacks[cellname]:top())
            backupstacks[cellname]:pop()
        end
    end
end

function clone_parameters(P)
    local new = {}
    for k, v in pairs(P) do
        new[k] = v
    end
    return new
end

function clone_matching_parameters(cellname, P)
    local cell = loadedcells[cellname]
    local new = {}
    for k, v in pairs(P) do
        if cell.parameters[k] then
            new[k] = v
        end
    end
    return new
end
--------------------------------------------------------------------

function M.create_layout(cellname, args, evaluate)
    local cell = loadedcells[cellname]
    if not cell.funcs.layout then
        error(string.format("cell '%s' has no layout definition", cellname), 0)
    end
    local obj = object.create()
    local parameters, backup = _get_parameters(cellname, args, evaluate)
    _restore_parameters(cellname, backup)
    local status, msg = pcall(cell.funcs.layout, obj, parameters)
    if not status then
        error(string.format("could not create cell '%s': %s", cellname, msg), 0)
    end
    return obj
end

function M.parameters(name)
    local cell = loadedcells[name]
    local str = {}
    for k, v in pairs(cell.parameters) do
        local val = v.func()
        if type(val) == "table" then
            val = table.concat(val, ",")
        else
            val = tostring(val)
        end
        str[cell.indices[k]] = string.format("%s:%s:%s:%s", k, v.display, val, tostring(v.argtype))
    end
    return str
end

return M
