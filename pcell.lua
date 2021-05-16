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

-- submodules
local evaluators = _load_module("pcell.evaluators")
local paramlib = _load_module("pcell.parameter")

local function _get_cell_filename(state, cellname)
    for _, path in ipairs(state.cellpaths) do
        local filename = string.format("%s/%s.lua", path, cellname)
        if dir.exists(filename) then
            -- first found matching cell is used
            return filename
        end
    end
end

local function _load_cell(state, cellname, env)
    local filename = _get_cell_filename(state, cellname)
    if envlib.get("verbose") then
        print(string.format("pcell: loading cell definition in %s", filename))
    end
    if not filename then
        local str = {
            string.format("could not find cell '%s' in:", cellname),
        }
        for _, path in ipairs(state.cellpaths) do
            table.insert(str, string.format("  %s", path))
        end
        error(table.concat(str, "\n"))
    end

    local reader = _get_reader(filename)
    if not reader then
        error(string.format("could not open cell file '%s'", filename))
    end
    local chunkname = string.format("@cell '%s'", cellname)
    _generic_load(
        reader, chunkname,
        string.format("syntax error in cell '%s'", cellname),
        string.format("semantic error in cell '%s'", cellname),
        env
    )
    return env
end

local _cellenv
local function _override_cell_environment(what, t)
    if what then
        if not _cellenv then
            _cellenv = {}
        end
        _cellenv[what] = t
    else
        _cellenv = nil
    end
end

local function _get_cell(state, cellname, nocallparams)
    if not state.loadedcells[cellname] then
        if state.debug then print(string.format("loading cell '%s'", cellname)) end
        local env = state:create_cellenv(cellname, _cellenv)
        local funcs = _load_cell(state, cellname, env)
        if not (funcs.parameters or funcs.layout) then
            error(string.format("cell '%s' must define at least the public function 'parameters' or 'layout'", cellname))
        end
        local cell = {
            funcs       = funcs,
            parameters  = paramlib.create_directory(),
            properties  = {},
            references  = {
                [cellname] = true -- a cell can always refer to its own parameters
            },
        }
        rawset(state.loadedcells, cellname, cell)
        if not nocallparams then
            local status, msg = pcall(funcs.parameters)
            if not status then
                error(string.format("could not create parameters of cell '%s': %s", cellname, msg))
            end
        end
        if funcs.config then
            funcs.config()
        end
    end
    return rawget(state.loadedcells, cellname)
end

local function _add_parameter(state, cellname, name, value, argtype, posvals, follow, overwrite, readonly)
    argtype = argtype or type(value)
    local cell = _get_cell(state, cellname)
    cell.parameters:set_overwrite(overwrite)
    cell.parameters:set_follow(follow)
    return cell.parameters:add(name, value, argtype, posvals, readonly)
end

local function _set_parameter_function(state, cellname, name, value, backup, evaluate, overwrite)
    local cell = _get_cell(state, cellname)
    local p = cell.parameters:get(name)
    if not p then
        error(string.format("argument '%s' has no matching parameter in cell '%s', maybe it was spelled wrong?", name, cellname))
    end
    if overwrite then
        p.overwritten = true
    end
    local value = value
    if evaluate then
        local eval = evaluators[p.argtype]
        value = eval(value)
    end
    paramlib.check_constraints(p, value)
    paramlib.check_readonly(p)
    -- store old function for restoration
    backup[name] = p.func:get()
    -- important: use :replace(), don't create a new function object.
    -- Otherwise parameter binding does not work, because bound parameters link to the original function object
    p.func:replace(function() return value end)
end

local function _split_input_arguments(cellargs)
    local t = {}
    for name, value in pairs(cellargs) do
        local parent, arg = string.match(name, "^([^.]+)%.(.+)$")
        if not parent then
            arg = name
        end
        table.insert(t, { parent = parent, name = arg, value = value })
    end
    return t
end

local function _process_input_parameters(state, cellname, cellargs, evaluate, overwrite)
    local backup = {}
    if cellargs then
        local args = _split_input_arguments(cellargs)
        for _, arg in ipairs(args) do
            if arg.parent then
                _set_parameter_function(state, arg.parent, arg.name, arg.value, {}, evaluate, overwrite)
            else
                _set_parameter_function(state, cellname, arg.name, arg.value, backup, evaluate, overwrite)
            end
        end
    end
    return backup
end

local function _get_parameters(state, cellname, othercell, cellargs, evaluate)
    local cell = _get_cell(state, cellname)
    if not cell.references[othercell] then
        error(string.format("trying to access parameters of unreferenced cell (%s from %s)", othercell, cellname))
    end
    local othercell = _get_cell(state, othercell)
    local cellparams = othercell.parameters:get_values()
    cellargs = cellargs or {}

    local backup = _process_input_parameters(state, cellname, cellargs, evaluate)

    -- store parameters in user-readable table
    local P = {}
    local handled = {}
    for name, entry in pairs(cellparams) do
        if not handled[name] or rawget(cellargs, name) then
            P[name] = entry.func()
            if rawget(cellargs, name) then
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
        __index = function(_, k)
            error(string.format("trying to access undefined parameter value '%s'", k))
        end,
    })

    return P, backup
end

local function _restore_parameters(state, cellname, backup)
    local cell = _get_cell(state, cellname)
    local cellparams = cell.parameters:get_values()
    -- restore old functions
    for name, func in pairs(backup) do
        cellparams[name].func:replace(func)
        cellparams[name].overwritten = nil
    end
end

local function set_property(state, cellname, property, value)
    local cell = _get_cell(state, cellname)
    cell.properties[property] = value
end

local function add_parameter(state, cellname, name, value, opt)
    opt = opt or {}
    _add_parameter(state, cellname, name, value, opt.argtype, opt.posvals, opt.follow, opt.readonly)
end

local function add_parameters(state, cellname, ...)
    for _, parameter in ipairs({ ... }) do
        local name, value = parameter[1], parameter[2]
        _add_parameter(
            state,
            cellname,
            name, value,
            parameter.argtype, parameter.posvals, parameter.follow, nil, parameter.readonly
        )
    end
end

local function reference_cell(state, cellname, othercell)
    local cell = _get_cell(state, cellname)
    cell.references[othercell] = true
    -- load the referenced cell, needed for 'constraints'
    _get_cell(state, othercell)
end

local function inherit_parameter_as(state, cellname, name, othercell, othername)
    local othercell = _get_cell(state, othercell)
    local param = othercell.parameters:get(othername)
    if param.display then
        name = string.format("%s(%s)", othername, param.display)
    end
    --_add_parameter(state, cellname, name, param.func(), param.argtype, param.posvals)
end

local function inherit_parameter(state, cellname, othercell, othername)
    inherit_parameter_as(state, cellname, othername, othercell, othername)
end

local function inherit_all_parameters(state, cellname, othercell)
    local inherited = _get_cell(state, othercell)
    local parameters = {}
    for _, name in ipairs(inherited.parameters:get_names()) do
        inherit_parameter(state, cellname, othercell, name)
    end
end

local function push_overwrites(state, cellname, othercell, cellargs)
    assert(type(cellname) == "string", "push_overwrites: cellname must be a string")
    local cell = _get_cell(state, cellname)
    if not cell.references[othercell] then
        error(string.format("trying to access parameters of unreferenced cell (%s from %s)", othercell, cellname))
    end
    local backup = _process_input_parameters(state, othercell, cellargs, false, true)
    if not state.backupstacks[othercell] then
        state.backupstacks[othercell] = stack.create()
    end
    state.backupstacks[othercell]:push(backup)
end

local function pop_overwrites(state, cellname, othercell)
    if (not state.backupstacks[othercell]) or (not state.backupstacks[othercell]:peek()) then
        error(string.format("trying to restore default parameters for '%s', but there where no previous overwrites", othercell))
    end
    _restore_parameters(state, othercell, state.backupstacks[othercell]:top())
    state.backupstacks[othercell]:pop()
end

local function clone_parameters(state, P, predicate)
    assert(P, "pcell.clone_parameters: no parameters given")
    return aux.clone_shallow(P, predicate)
end

local function clone_matching_parameters(state, cellname, P)
    assert(cellname, "pcell.clone_matching_parameters: no cellname given")
    local cell = _get_cell(state, cellname)
    local predicate = function(k, v)
        return not not cell.parameters:get(k)
    end
    return clone_parameters(state, P, predicate)
end

-- main state storing various data
-- only the public functions use this state as upvalue to conceal it from the user
-- all local implementing functions get state as first parameter
local state = {
    cellpaths = {},
    loadedcells = {},
    backupstacks = {},
    debug = false,
}

function state.create_cellenv(state, cellname, ovrenv)
    local bindcell = function(func)
        return function(...)
            return func(state, cellname, ...)
        end
    end
    local bindstate = function(func)
        return function(...)
            return func(state, ...)
        end
    end
    local env = {
        -- "global" functions for posvals entries:
        set = function(...) return { type = "set", values = { ... } } end,
        interval = function(lower, upper) return { type= "interval", values = { lower = lower, upper = upper }} end,
        even = function() return { type= "even" } end,
        odd = function() return { type= "odd" } end,
        multiple = function(val) return { type = "multiple", value = val } end,
        inf = math.huge,
        pcell = {
            set_property                    = bindcell(set_property),
            add_parameter                   = bindcell(add_parameter),
            add_parameters                  = bindcell(add_parameters),
            reference_cell                  = bindcell(reference_cell),
            inherit_parameter               = bindcell(inherit_parameter),
            inherit_parameter_as            = bindcell(inherit_parameter_as),
            inherit_all_parameters          = bindcell(inherit_all_parameters),
            get_parameters                  = bindcell(_get_parameters),
            push_overwrites                 = bindcell(push_overwrites),
            pop_overwrites                  = bindcell(pop_overwrites),
            -- the following functions don't not need cell binding as they are called for other cells
            clone_parameters                = bindstate(clone_parameters),
            clone_matching_parameters       = bindstate(clone_matching_parameters),
            create_layout                   = M.create_layout
        },
        tech = {
            get_dimension = technology.get_dimension
        },
        geometry = geometry,
        graphics = graphics,
        shape = shape,
        object = object,
        generics = generics,
        point = point,
        util = util,
        aux = aux,
        math = math,
        enable = function(bool, val) return (bool and 1 or 0) * (val or 1) end,
        string = string,
        table = table,
        dprint = function(...) if state.debug then print(...) end end,
        type = type,
        ipairs = ipairs,
        pairs = pairs,
        error = error,
    }
    if ovrenv then
        for k, v in pairs(ovrenv) do
            env[k] = v
        end
    end
    return env
end

-- Public functions
function M.enable_debug(d)
    state.debug = d
end

function M.append_cellpath(path)
    table.insert(state.cellpaths, path)
end

function M.prepend_cellpath(path)
    table.insert(state.cellpaths, 1, path)
end

function M.list_cellpaths()
    for _, path in ipairs(state.cellpaths) do
        print(path)
    end
end

local function _find_cell_traceback()
    local level = 2
    while true do
        local d = debug.getinfo(level, "Slnt")
        if not d then break end
        if string.match(d.source, "^@cell") then
            return d.currentline
        end
        level = level + 1
    end
end

function M.create_layout(cellname, cellargs, evaluate)
    local cell = _get_cell(state, cellname)
    if not cell.funcs.layout then
        error(string.format("cell '%s' has no layout definition", cellname))
    end
    local parameters, backup = _get_parameters(state, cellname, cellname, cellargs, evaluate) -- cellname needs to be passed twice
    _restore_parameters(state, cellname, backup)
    local obj = object.create(cellname)
    local status, msg = xpcall(cell.funcs.layout, function(err) return { msg = err, where = _find_cell_traceback() } end, obj, parameters)
    if not status then
        error(string.format("could not create cell '%s'. Error in line %d\n  -> %s", cellname, msg.where, msg.msg), 0)
    end
    return obj
end

function M.list(listhidden)
    local cells = {}
    for i, path in ipairs(state.cellpaths) do
        cells[i] = { path = path, cells = {} }
        for _, cellname in ipairs(support.listcells(path)) do
            local cell = _get_cell(state, cellname, true) -- don't call funcs.params()
            if not cell.properties.hidden or listhidden then
                table.insert(cells[i].cells, cellname)
            end
        end
    end

    -- pcell.list() renders the loaded cells unusable, as the cell environment is modified for data collection
    -- perhaps there is a better way, but the current fix for this is to reset ALL cells
    -- FIXME: unsure if this is true anymore after some important changes to the cell environment system.
    state.loadedcells = {}

    return cells
end

function M.constraints(cellname)
    -- replace tech module in environment
    local constraints = {}
    local t = {
        get_dimension = function(name) constraints[name] = true end
    }
    _override_cell_environment("tech", t)

    -- load cell, this fills the 'constraints' table
    _get_cell(state, cellname)
    local str = {}
    for constraint in pairs(constraints) do
        table.insert(str, constraint)
    end
    _override_cell_environment(nil)
    return str
end

local function _collect_parameters(cell, ptype, prefix, str)
    prefix = prefix or ""
    for _, name in ipairs(cell.parameters:get_names()) do
        local v = cell.parameters:get(name)
        local val = v.func()
        if type(val) == "table" then
            val = table.concat(val, ",")
        else
            val = tostring(val)
        end
        local ptype = ptype or v.ptype
        if envlib.get("humannotmachine") then
            table.insert(str, string.format("%s %s", v.display or name, val))
        else
            table.insert(str, string.format("%s:%s:%s:%s:%s", ptype, prefix .. name, v.display or "_NONE_", val, tostring(v.argtype)))
        end
    end
end

function M.parameters(cellname, cellargs, generictech)
    local str = {}

    if generictech then
        local t = {
            get_dimension = function(name) return string.format('tech.get_dimension("%s")', name) end,
        }
        _override_cell_environment("tech", t)
    end

    local cell = _get_cell(state, cellname)
    local parameters, backup = _get_parameters(state, cellname, cellname, cellargs, true) -- cellname needs to be passed twice
    --_restore_parameters(state, cellname, backup)
    _collect_parameters(cell, nil, nil, str) -- use ptype of parameter, no prefix

    -- display referenced parameters
    for othercellname in pairs(cell.references) do
        if othercellname ~= cellname then
            local othercell = _get_cell(state, othercellname)
            _collect_parameters(othercell, string.format("R(%s)", othercellname), othercellname .. ".", str) -- 'referenced' parameter
        end
    end
    _override_cell_environment(nil)
    return str
end

local function _perform_cell_check(cellname, name, values)
    for _, pval in ipairs(values) do
        local status, msg = pcall(M.create_layout, cellname, { [name] = pval })
        io.write(string.format("checking parameter '%s' with '%s':", name, pval))
        if not status then
            print(msg)
            print(" failure")
        else
            print(" success")
        end
    end
end

function M.check(cellname)
    -- collect parameter names
    local t = {
        get_dimension = function(name) return string.format('tech.get_dimension("%s")', name) end,
    }
    _override_cell_environment("tech", t)
    local cell = _get_cell(state, cellname)
    _override_cell_environment(nil)

    -- all loaded cells are in a unusable state after collecting the parameters. Reset and start again
    state.loadedcells = {}

    -- check if cell is instantiable
    local t = {
        get_dimension = function(name) return 4 end, -- FIXME: find a suitable return value
    }
    _override_cell_environment("tech", t)
    local status, msg = pcall(M.create_layout, cellname)
    if not status then
        print(string.format("cell '%s' is not instantiable. Error: %s", cellname, msg))
        return
    end

    -- check cell parameters
    for _, name in ipairs(cell.parameters:get_names()) do
        local parameter = cell.parameters:get(name)
        if parameter.argtype == "number" or parameter.argtype == "integer" then
            if not parameter.posvals then
                _perform_cell_check(cellname, name, { 1, 2 })
            elseif parameter.posvals.type == "even" then
                _perform_cell_check(cellname, name, { 2 })
            elseif parameter.posvals.type == "odd" then
                _perform_cell_check(cellname, name, { 1 })
            elseif parameter.posvals.type == "set" then
                _perform_cell_check(cellname, name, parameter.posvals.values)
            elseif parameter.posvals.type == "interval" then
                local values = { parameter.posvals.values.lower, parameter.posvals.values.upper }
                if parameter.posvals.values.upper == math.huge then
                    values[2] = 1000
                end
                _perform_cell_check(cellname, name, values)
            end
        end
    end
end

return M
