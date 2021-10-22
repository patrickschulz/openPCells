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
    -- check if only allowed values are defined
    for funcname in pairs(env) do 
        if not aux.any_of(function(v) return v == funcname end, { "config", "parameters", "layout" }) then
            moderror(string.format("pcell: all defined toplevel values must be one of 'parameters', 'layout' or 'config'. Illegal name: '%s'", funcname))
        end
    end
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

local function _add_cell(state, cellname, funcs, nocallparams)
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

local function _get_cell(state, cellname, nocallparams)
    if not state.loadedcells[cellname] then
        if state.debug then print(string.format("loading cell '%s'", cellname)) end
        local env = state:create_cellenv(cellname, _cellenv)
        local funcs = _load_cell(state, cellname, env)
        _add_cell(state, cellname, funcs)
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
    -- TODO: parameter binding is deprecated/does not exist any more. Is this comment/method still needed?
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
                if cellname then -- can be called without a cellname to update only parent parameters
                    _set_parameter_function(state, cellname, arg.name, arg.value, backup, evaluate, overwrite)
                end
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
    if cellname then -- is nil when called from a cellscript; perform no reference check in this case
        assert(type(cellname) == "string", "push_overwrites: cellname must be a string")
        local cell = _get_cell(state, cellname)
        if not cell.references[othercell] then
            error(string.format("trying to access parameters of unreferenced cell (%s from %s)", othercell, cellname))
        end
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

local function check_expression(state, cellname, expression)
    if not state.expressions[cellname] then
        state.expressions[cellname] = {}
    end
    table.insert(state.expressions[cellname], expression)
end

-- main state storing various data
-- only the public functions use this state as upvalue to conceal it from the user
-- all local implementing functions get state as first parameter
local state = {
    cellpaths = {},
    loadedcells = {},
    backupstacks = {},
    cellrefs = {},
    expressions = {},
    debug = false,
}

function state.create_cellenv(state, cellname, ovrenv)
    local bindstatecell = function(func)
        return function(...)
            return func(state, cellname, ...)
        end
    end
    local bindcell = function(func)
        return function(...)
            return func(cellname, ...)
        end
    end
    local bindstate = function(func)
        return function(...)
            return func(state, ...)
        end
    end
    local env = {}
    local envmeta = {
        -- "global" functions for posvals entries:
        set = function(...) return { type = "set", values = { ... } } end,
        interval = function(lower, upper) return { type= "interval", values = { lower = lower, upper = upper }} end,
        even = function() return { type= "even" } end,
        odd = function() return { type= "odd" } end,
        multiple = function(val) return { type = "multiple", value = val } end,
        inf = math.huge,
        pcell = {
            set_property                    = bindstatecell(set_property),
            add_parameter                   = bindstatecell(add_parameter),
            add_parameters                  = bindstatecell(add_parameters),
            reference_cell                  = bindstatecell(reference_cell),
            inherit_parameter               = bindstatecell(inherit_parameter),
            inherit_parameter_as            = bindstatecell(inherit_parameter_as),
            inherit_all_parameters          = bindstatecell(inherit_all_parameters),
            get_parameters                  = bindstatecell(_get_parameters),
            push_overwrites                 = bindstatecell(push_overwrites),
            pop_overwrites                  = bindstatecell(pop_overwrites),
            check_expression                = bindstatecell(check_expression),
            -- the following functions don't not need cell binding as they are called for other cells
            clone_parameters                = bindstate(clone_parameters),
            clone_matching_parameters       = bindstate(clone_matching_parameters),
            add_cell_reference              = M.add_cell_reference,
            create_layout                   = M.create_layout
        },
        tech = {
            get_dimension = technology.get_dimension
        },
        placement = placement,
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
        thisorthat = function(val, comp, this, that) return bool and this or that end,
        string = string,
        table = table,
        marker = marker,
        transformationmatrix = transformationmatrix,
        dprint = function(...) if state.debug then print(...) end end,
        tonumber = tonumber,
        type = type,
        ipairs = ipairs,
        pairs = pairs,
        cellerror = moderror,
        io = { open = function(filename) return io.open(filename, "r") end }
    }
    envmeta.__index = envmeta
    if ovrenv then
        for k, v in pairs(ovrenv) do
            envmeta[k] = v
        end
    end
    setmetatable(env, envmeta)
    return env
end

local function _check_parameter_expressions(state, cellname, parameters)
    local failures = {}
    if state.expressions[cellname] then
        for _, expr in ipairs(state.expressions[cellname]) do
            local chunk, msg = load("return " .. expr, "parameterexpression", "t", parameters)
            if not chunk then
                print(msg)
                return
            end
            local check = chunk()
            if not check then
                table.insert(failures, expr)
            end
        end
    end
    return failures
end

-- Public functions
function M.add_cell(cellname, funcs)
    _add_cell(state, cellname, funcs)
end

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
            return { source = d.source, line = d.currentline }
        end
        level = level + 1
    end
end

function M.update_other_cell_parameters(cellargs, evaluate)
    local overwrite = false -- ?? TODO
    for name, arg in pairs(cellargs) do
        -- call with cellname == nil, only update parent parameters
        _process_input_parameters(state, nil, cellargs, evaluate, false)
    end
end

function M.update_cell_parameters(cellname, cellargs, evaluate)
    local cell = _get_cell(state, cellname) -- load cell if not loaded
    local parameters, backup = _get_parameters(state, cellname, cellname, cellargs, evaluate) -- cellname needs to be passed twice
    _restore_parameters(state, cellname, backup)
end

function M.push_overwrites(othercell, cellargs)
    push_overwrites(state, nil, othercell, cellargs)
end

function M.pop_overwrites(othercell)
    pop_overwrites(state, nil, othercell)
end

function M.create_layout(cellname, cellargs, evaluate)
    if state.debug then 
        local status = _find_cell_traceback()
        if not status then -- main call to create_layout 
            print(string.format("creating layout of cell '%s' (main call)", cellname))
        else
            print(string.format("creating layout of cell '%s' in %s:%d", cellname, status.source, status.line))
        end
    end
    local cell = _get_cell(state, cellname)
    if not cell.funcs.layout then
        error(string.format("cell '%s' has no layout definition", cellname))
    end
    local parameters, backup = _get_parameters(state, cellname, cellname, cellargs, evaluate) -- cellname needs to be passed twice
    _restore_parameters(state, cellname, backup)
    local failures = _check_parameter_expressions(state, cellname, parameters)
    if #failures > 0 then
        for _, failure in ipairs(failures) do
            print(failure)
        end
        error(string.format("could not satisfy parameter expression for cell '%s'", cellname), 0)
    end
    local obj = object.create(cellname)
    local status, msg = xpcall(cell.funcs.layout, function(err) return { msg = err, where = _find_cell_traceback() } end, obj, parameters)
    if not status then
        error(string.format("could not create cell '%s'. Error in line %d\n  -> %s", cellname, msg.where.line, msg.msg), 0)
    end
    return obj
end

function M.add_cell_reference(cell, name)
    local identifier = aux.make_unique_name(name)
    if not state.cellrefs[identifier] then
        state.cellrefs[identifier] = cell
    end
    return identifier
end

function M.get_cell_reference(identifier)
    local reference = state.cellrefs[identifier]
    if not reference then
        moderror(string.format("trying to access an unknown child reference (%s). Make sure to use the name generated by add_child_reference()", identifier))
    end
    return reference
end

function M.iterate_cell_references()
    return pairs(state.cellrefs)
end

function M.foreach_cell_references(func, ...)
    for _, reference in pcell.iterate_cell_references() do
        func(reference, ...)
    end
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

local function _traverse_tree(tree)
    if tree.children then
        local elements = {}
        for _, child in ipairs(tree.children) do
            local t = _traverse_tree(child)
            for _, tt in ipairs(t) do
                local elem = { tree.name }
                for _, e in ipairs(tt) do
                    table.insert(elem, e)
                end
                table.insert(elements, elem)
            end
        end
        return elements
    else
        return { { tree.name } }
    end
end
function M.list_tree(listhidden)
    local dir = {}
    for _, path in ipairs(state.cellpaths) do
        local baseinfo = {}
        local tree = support.dirtree(path)
        for _, base in ipairs(tree.children) do
            local cellinfo = {}
            for _, info in ipairs(_traverse_tree(base)) do
                table.remove(info, 1) -- remove base
                table.insert(cellinfo, table.concat(info, "/"))
            end
            table.sort(cellinfo)
            table.insert(baseinfo, { name = base.name, cellinfo = cellinfo })
        end
        table.sort(baseinfo, function(l, r) return l.name < r.name end)
        table.insert(dir, { name = path, baseinfo = baseinfo })
    end
    table.sort(dir, function(l, r) return l.name < r.name end)
    return dir
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

local function _collect_parameters(cell, ptype, parent, str)
    for _, name in ipairs(cell.parameters:get_names()) do
        local v = cell.parameters:get(name)
        local val = v.func()
        if type(val) == "table" then
            val = table.concat(val, ",")
            if val == "" then val = " " end
        else
            val = tostring(val)
        end
        local ptype = ptype
        table.insert(str, { 
            parent = parent, 
            name = name, 
            display = v.display, 
            value = val, 
            ptype = ptype, 
            argtype = tostring(v.argtype), 
            readonly = v.readonly,
            posvals = v.posvals 
        })
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
    --_restore_parameters(state, cellname, backup) -- FIXME?
    _collect_parameters(cell, "N", cellname, str)

    -- display referenced parameters
    for othercellname in pairs(cell.references) do
        if othercellname ~= cellname then
            local othercell = _get_cell(state, othercellname)
            _collect_parameters(othercell, "R", othercellname, str) -- 'referenced' parameter
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
