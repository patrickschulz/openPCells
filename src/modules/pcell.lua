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

-- submodules

-- start of evaluator module
local function _eval_identity(arg) return arg end

local function _eval_toboolean(arg)
    assert(
        string.match(arg, "true") or string.match(arg, "false"), 
        string.format("_eval_toboolean: argument must be 'true' or 'false' (is '%s')", arg)
    )
    return arg == "true" and true or false
end

local function _eval_tointeger(arg)
    return math.floor(tonumber(arg))
end

local function _eval_tonumtable(arg)
    local t = {}
    for e in string.gmatch(arg, "[^;,]+") do
        table.insert(t, tonumber(e))
    end
    return t
end

local function _eval_tostrtable(arg)
    local t = {}
    for e in string.gmatch(arg, "[^;,]+") do
        table.insert(t, tostring(e))
    end
    return t
end

local function evaluator(arg, argtype)
    local evaluators = {
        number   = tonumber,
        integer  = _eval_tointeger,
        string   = _eval_identity,
        boolean  = _eval_toboolean,
        numtable = _eval_tonumtable,
        strtable = _eval_tostrtable,
    }
    local eval = evaluators[argtype]
    return eval(arg)
end
-- end of evaluator module

-- start of parameter module
local paramlib = {}

local parammeta = {}
parammeta.__index = parammeta

-- start of funcobject module
local funcobject = {}

local funcobjectmeta = {}
funcobjectmeta.__call = function(self, ...) return self.func(...) end
funcobjectmeta.__index = funcobjectmeta

function funcobject.create(func)
    local self = { func = func }
    setmetatable(self, funcobjectmeta)
    return self
end

function funcobject.identity(value)
    return funcobject.create(function()
        return value
    end)
end

function funcobjectmeta.replace(self, func)
    self.func = func
end

function funcobjectmeta.get(self)
    return self.func
end
-- end of funcobject module

function paramlib.create_directory()
    local self = {
        names = {},
        values = {},
        overwrite = false
    }
    setmetatable(self, parammeta)
    return self
end

function paramlib.check_constraints(parameter, value)
    local posvals = parameter.posvals
    local name = parameter.name
    if posvals then
        if posvals.type == "set" then
            local found = aux.find(posvals.values, function(v) return v == value end)
            if not found then
                moderror(string.format("parameter '%s' (%s) can only be %s", name, value, table.concat(posvals.values, " or ")))
            end
        elseif posvals.type == "interval" then
            if value < posvals.values.lower or value > posvals.values.upper then
                moderror(string.format("parameter '%s' (%s) out of range from %s to %s", name, value, posvals.values.lower, posvals.values.upper))
            end
        elseif posvals.type == "even" then
            if value % 2 ~= 0 then
                moderror(string.format("parameter '%s' (%s) must be even", name, value))
            end
        elseif posvals.type == "odd" then
            if value % 2 ~= 1 then
                moderror(string.format("parameter '%s' (%s) must be odd", name, value))
            end
        elseif posvals.type == "positive" then
            if value <= 0 then
                moderror(string.format("parameter '%s' (%s) must be positive (exluding zero)", name, value))
            end
        else
        end
    end
end

function paramlib.check_readonly(parameter)
    if parameter.readonly then
        moderror(string.format("parameter '%s' is read-only", parameter.name))
    end
end

function parammeta.set_overwrite(self, overwrite)
    self.overwrite = overwrite
end

function parammeta.set_follow(self, follow)
    self.follow = follow
end

function parammeta.add(self, name, value, argtype, posvals, readonly)
    local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
    if not pname then pname = name end -- no display name
    local new = {
        name      = pname,
        display   = dname,
        func      = funcobject.identity(value),
        argtype   = argtype,
        posvals   = posvals,
        followers = {},
        readonly  = not not readonly,
    }
    if not self.values[pname] or self.overwrite then
        self.values[pname] = new
        table.insert(self.names, pname)
        if self.follow then
            self.values[self.follow].followers[pname] = true
        end
        return true
    else
        return false
    end
end

function parammeta.get(self, name)
    return self.values[name]
end

function parammeta.get_values(self)
    return self.values
end

function parammeta.get_names(self)
    return self.names
end
--]]
-- end of parameter module

local function _load_cell(state, cellname, env)
    if not cellname then
        error("pcell: load_cell expects a cellname")
    end
    local filename = pcell.get_cell_filename(cellname)
    local reader = _get_reader(filename)
    if not reader then
        error(string.format("could not open cell file '%s'", filename))
    end
    local chunkname = string.format("@cell '%s'", cellname)
    --if verbose then
    --    print(string.format("pcell: loading cell definition in %s", filename))
    --end
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
    if funcs.parameters and not nocallparams then
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

local function _set_parameter_function(state, cellname, name, value, backup, overwrite)
    local cell = _get_cell(state, cellname)
    local p = cell.parameters:get(name)
    if not p then
        error(string.format("argument '%s' has no matching parameter in cell '%s', maybe it was spelled wrong?", name, cellname))
    end
    if overwrite then
        p.overwritten = true
    end
    paramlib.check_constraints(p, value)
    paramlib.check_readonly(p)
    -- store old function for restoration
    backup[name] = p.func:get()
    -- important: use :replace(), don't create a new function object.
    -- Otherwise parameter binding does not work, because bound parameters link to the original function object
    -- FIXME: parameter binding is deprecated/does not exist any more. Is this comment/method still needed?
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

local function _process_input_parameters(state, cellname, cellargs, overwrite)
    local backup = {}
    if cellargs then
        local args = _split_input_arguments(cellargs)
        for _, arg in ipairs(args) do
            if arg.parent then
                _set_parameter_function(state, arg.parent, arg.name, arg.value, {}, overwrite)
            else
                if cellname then -- can be called without a cellname to update only parent parameters
                    _set_parameter_function(state, cellname, arg.name, arg.value, backup, overwrite)
                end
            end
        end
    end
    return backup
end

local function _check_parameter_expressions(state, cellname, parameters)
    local failures = {}
    if state.expressions[cellname] then
        for _, expr in ipairs(state.expressions[cellname]) do
            local chunk, msg = load("return " .. expr.expression, "parameterexpression", "t", parameters)
            if not chunk then
                print(msg)
                return
            end
            local check = chunk()
            if not check then
                if expr.message then
                    table.insert(failures, expr.message)
                else
                    table.insert(failures, expr.expression)
                end
            end
        end
    end
    return failures
end

local function _get_parameters(state, cellname, othercellname, cellargs)
    local othercell = _get_cell(state, othercellname)
    local cellparams = othercell.parameters:get_values()
    cellargs = cellargs or {}

    local backup
    if cellname then -- is nil when called from a cellscript; perform no reference check in this case
        local cell = _get_cell(state, cellname)
        if not cell.references[othercellname] then
            error(string.format("trying to access parameters of unreferenced cell (%s from %s)", othercellname, cellname))
        end
        backup = _process_input_parameters(state, cellname, cellargs)
    end

    -- store parameters in user-readable table
    -- FIXME: this is somewhat confusing, this should be easier
    -- What the following loop does, is to copy all processed parameter values to a new table
    -- This also handles follower parameters, which makes stuff ugly, since we need to check that user-provided 
    -- parameters are not overwritten. Should not be this hard
    local P = {}
    local handled = {}
    for name, entry in pairs(cellparams) do
        if not handled[name] then
            P[name] = entry.func()
        end
        if rawget(cellargs, name) ~= nil then
            P[name] = entry.func()
            handled[name] = true
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

    local failures = _check_parameter_expressions(state, othercellname, P)
    if #failures > 0 then
        for _, failure in ipairs(failures) do
            print(failure)
        end
        error(string.format("could not satisfy parameter expression for cell '%s'", cellname), 0)
    end

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
    local backup = _process_input_parameters(state, othercell, cellargs, true) -- true: overwrite
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

local function check_expression(state, cellname, expression, message)
    if not state.expressions[cellname] then
        state.expressions[cellname] = {}
    end
    table.insert(state.expressions[cellname], { expression = expression, message = message })
end

local function _resolve_cellname(state, cellname)
    local libpart, cellpart = string.match(cellname, "([^/]+)/(.+)")
    if libpart == "." then -- implicit library
        libpart = state.libnamestacks:top()
    end
    return string.format("%s/%s", libpart, cellpart)
end

-- main state storing various data
-- only the public functions use this state as upvalue to conceal it from the user
-- all local implementing functions get state as first parameter
local state = {
    libnamestacks = stack.create(),
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
        interval = function(lower, upper) return { type = "interval", values = { lower = lower, upper = upper }} end,
        even = function() return { type = "even" } end,
        odd = function() return { type = "odd" } end,
        positive = function() return { type = "positive" } end,
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
            add_cell_reference              = pcell.add_cell_reference,
            create_layout                   = pcell.create_layout
        },
        tech = {
            get_dimension = technology.get_dimension,
            has_layer = technology.has_layer,
        },
        placement = placement,
        routing = routing,
        geometry = geometry,
        curve = curve,
        layout = layout,
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
        evenodddiv = function(num, div) if num % 2 == 0 then return num / div, num / div else return num // div, num // div + 1 end end,
        evenodddiv2 = function(num) if num % 2 == 0 then return num / 2, num / 2 else return num // 2, num // 2 + 1 end end,
        string = string,
        table = table,
        marker = marker,
        transformationmatrix = transformationmatrix,
        dprint = function(...) if state.enabledprint then print(...) end end,
        moderror = moderror,
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

-- Public functions
function pcell.get_parameters(othercell, cellargs)
    return _get_parameters(state, nil, othercell, cellargs)
end

function pcell.add_cell(cellname, funcs)
    _add_cell(state, cellname, funcs)
end

function pcell.enable_debug(d)
    state.debug = d
end

function pcell.enable_dprint(d)
    state.enabledprint = d
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

function pcell.update_other_cell_parameters(cellargs)
    for name, arg in pairs(cellargs) do
        -- call with cellname == nil, only update parent parameters
        _process_input_parameters(state, nil, cellargs, false) -- false: overwrite
    end
end

function pcell.push_overwrites(othercell, cellargs)
    push_overwrites(state, nil, othercell, cellargs)
end

function pcell.pop_overwrites(othercell)
    pop_overwrites(state, nil, othercell)
end

function pcell.evaluate_parameters(cellname, cellargs)
    local parameters = {}
    local args = _split_input_arguments(cellargs)
    for _, arg in ipairs(args) do
        local cell = _get_cell(state, arg.parent or cellname)
        local p = cell.parameters:get(arg.name)
        if not p then
            error(string.format("argument '%s' has no matching parameter in cell '%s', maybe it was spelled wrong?", name, arg.parent or cellname))
        end
        local index = arg.name
        if arg.parent then
            index = string.format("%s.%s", arg.parent, arg.name)
        end
        parameters[index] = evaluator(arg.value, p.argtype)
    end
    return parameters
end


function pcell.create_layout(cellname, cellargs, env)
    if not cellname then
        error("pcell.create_layout: no cellname given")
    end
    if state.debug then 
        local status = _find_cell_traceback()
        if not status then -- main call to create_layout 
            print(string.format("creating layout of cell '%s' (main call)", cellname))
        else
            print(string.format("creating layout of cell '%s' in %s:%d", cellname, status.source, status.line))
        end
    end
    local libpart, cellpart = string.match(cellname, "([^/]+)/(.+)")
    local explicitlib = false
    if libpart ~= "." then -- explicit library
        explicitlib = true
        state.libnamestacks:push(libpart)
    end
    cellname = _resolve_cellname(state, cellname)
    local cell = _get_cell(state, cellname)
    if not cell.funcs.layout then
        error(string.format("cell '%s' has no layout definition", cellname))
    end
    local parameters, backup = _get_parameters(state, cellname, cellname, cellargs) -- cellname needs to be passed twice
    _restore_parameters(state, cellname, backup)
    local obj = object.create(cellname)
    cell.funcs.layout(obj, parameters, env)
    if explicitlib then
        state.libnamestacks:pop()
    end
    return obj
end

function pcell.create_layout_from_script(scriptpath, cellargs)
    if cellargs then
        pcell.update_other_cell_parameters(cellargs)
    end
    local reader = _get_reader(scriptpath)
    if reader then
        local env = _ENV
        local path, name = aux.split_path(scriptpath)
        env._CURRENT_SCRIPT_PATH = path
        env._CURRENT_SCRIPT_NAME = name
        local cell = _dofile(reader, string.format("@%s", scriptpath), nil, env)
        if not cell then
            error(string.format("cellscript '%s' did not return an object", scriptpath))
        end
        return cell
    else
        error(string.format("cellscript '%s' could not be opened", scriptpath))
    end
end

function pcell.constraints(cellname)
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
        if type(val) == "table" and not val.isgenerictechparameter then
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

function pcell.parameters(cellname, cellargs, generictech)
    if generictech then
        local meta = {}
        meta.__add = function(lhs, rhs)
            return setmetatable({ 
                str = string.format("%s + %s", tostring(lhs), tostring(rhs)),
                isgenerictechparameter = true, 
            }, meta)
        end
        meta.__sub = function(lhs, rhs)
            return setmetatable({ 
                str = string.format("%s - %s", tostring(lhs), tostring(rhs)),
                isgenerictechparameter = true, 
            }, meta)
        end
        meta.__mul = function(lhs, rhs)
            return setmetatable({ 
                str = string.format("%s * %s", tostring(lhs), tostring(rhs)),
                isgenerictechparameter = true, 
            }, meta)
        end
        meta.__div = function(lhs, rhs)
            return setmetatable({ 
                str = string.format("%s / %s", tostring(lhs), tostring(rhs)),
                isgenerictechparameter = true, 
            }, meta)
        end
        meta.__tostring = function(self)
            return self.str
        end
        local t = {
            get_dimension = function(name) return setmetatable({ 
                str = string.format('tech.get_dimension("%s")', name),
                isgenerictechparameter = true, 
            }, meta) end,
        }
        _override_cell_environment("tech", t)
    end

    local cell = _get_cell(state, cellname)
    local parameters, backup = _get_parameters(state, cellname, cellname, cellargs, true) -- cellname needs to be passed twice
    --_restore_parameters(state, cellname, backup) -- FIXME?
    local str = {}
    _collect_parameters(cell, "N", cellname, str)

    -- FIXME: implement parameter collection from layout functions
    -- execute the 'layout' function without creating any layouts to collect all used parameters
    -- this is required in order to get the actual transparent parameters of subcells
    -- (that is, parameters that are not overwritten on higher levels)
        --local t = {
        --    get_dimension = function(name) return 4 end, -- FIXME: find a suitable return value
        --}
        --_override_cell_environment("tech", t)
        --local status, msg = pcall(pcell.create_layout, cellname)
        --if not status then
        --    print(string.format("cell '%s' is not instantiable. Error: %s", cellname, msg))
        --    return
        --end

    --[[
    -- display referenced parameters
    for othercellname in pairs(cell.references) do
        if othercellname ~= cellname then
            local othercell = _get_cell(state, othercellname)
            _collect_parameters(othercell, "R", othercellname, str) -- 'referenced' parameter
        end
    end
    --]]
    _override_cell_environment(nil)
    return str
end

local function _perform_cell_check(cellname, name, values)
    for _, pval in ipairs(values) do
        local status, msg = pcall(pcell.create_layout, cellname, { [name] = pval })
        io.write(string.format("checking parameter '%s' with '%s':", name, pval))
        if not status then
            print(msg)
            print(" failure")
        else
            print(" success")
        end
    end
end

function pcell.check(cellname)
    -- collect parameter names
    local t = {
        get_dimension = function(name) return string.format('tech.get_dimension("%s")', name) end,
    }
    _override_cell_environment("tech", t)
    local cell = _get_cell(state, cellname)
    _override_cell_environment(nil)

    -- all loaded cells are in an unusable state after collecting the parameters. Reset and start again
    state.loadedcells = {}

    -- check if cell is instantiable
    local t = {
        get_dimension = function(name) return 4 end, -- FIXME: find a suitable return value
    }
    _override_cell_environment("tech", t)
    local status, msg = pcall(pcell.create_layout, cellname)
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

