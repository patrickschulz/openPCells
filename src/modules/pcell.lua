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

function paramlib.create_directory()
    local self = {
        names = {},
        values = {},
        followers = {},
    }
    setmetatable(self, parammeta)
    return self
end

function paramlib.check_constraints(parameter, value)
    local posvals = parameter.posvals
    local name = parameter.name
    if posvals then
        if posvals.type == "set" then
            local found = aux.find_predicate(posvals.values, function(v) return v == value end)
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
        elseif posvals.type == "negative" then
            if value >= 0 then
                moderror(string.format("parameter '%s' (%s) must be negative (exluding zero)", name, value))
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

function parammeta.add(self, name, value, argtype, posvals, follow, readonly)
    local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
    if not pname then pname = name end -- no display name
    local new = {
        name      = pname,
        display   = dname,
        value     = value,
        argtype   = argtype,
        posvals   = posvals,
        readonly  = not not readonly,
    }
    self.values[pname] = new
    table.insert(self.names, pname)
    if follow then
        self.followers[pname] = follow
    end
end

function parammeta.get(self, name)
    return self.values[name]
end

function parammeta.get_values(self)
    return self.values
end

function parammeta.get_followers(self)
    return aux.clone_shallow(self.followers)
end

function parammeta.get_names(self)
    return self.names
end
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
        name        = cellname,
        overwrites  = {},
        expressions = {},
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

local function _add_parameter(state, cell, name, value, argtype, posvals, follow, readonly)
    argtype = argtype or type(value)
    cell.parameters:add(name, value, argtype, posvals, follow, readonly)
end

local function _check_parameter_expressions(cell, parameters)
    local failures = {}
    for _, expr in ipairs(cell.expressions) do
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
    return failures
end

local function _get_parameters(state, cellname, cellargs)
    local cell = _get_cell(state, cellname)
    local cellparams = cell.parameters:get_values()

    -- assemble arguments for the cell layout function
    -- order of processing is:
    --  (1) default values
    --  (2) overwrites
    --  (3) cell arguments
    --  (4) handle followers
    --  (5) run parameter checks
    --  (6) check cell expressions
    -- this ensures that values explicitly-given parameter values have priority,
    -- while overwrites (from push_overwrites) only overwrite default values
    -- follower parameters are updated AFTER explicit cell arguments, but must check
    -- that given arguments are not overwritten
    local P = {}

    -- (1) fill with default values
    for name, entry in pairs(cellparams) do
        P[name] = entry.value
    end

    -- (2) process overwrites
    for _, overwrites in pairs(cell.overwrites) do
        for name, value in pairs(overwrites) do
            P[name] = value
        end
    end

    -- (3) process input parameters
    local explicit = {}
    if cellargs then
        for name, value in pairs(cellargs) do
            assert(P[name] ~= nil,
                string.format("argument '%s' has no matching parameter in cell '%s', maybe it was spelled wrong?", name, cellname))
            P[name] = value
            explicit[name] = true
        end
    end

    -- (4) handle followers
    local followers = cell.parameters:get_followers()
    local ordered = {}
    repeat
        for name, target in pairs(followers) do
            if not followers[target] then
                table.insert(ordered, { name = name, target = target })
                followers[name] = nil
            end
        end
    until not next(followers)
    for _, entry in ipairs(ordered) do
        if not explicit[entry.name] then -- don't overwrite explicitly-given parameters
            P[entry.name] = P[entry.target]
        end
    end

    -- (5) run parameter checks
    for name, entry in pairs(cellparams) do
        paramlib.check_constraints(entry, P[name])
    end

    -- (6) check cell expressions
    local failures = _check_parameter_expressions(cell, P)
    if #failures > 0 then
        for _, failure in ipairs(failures) do
            print(failure)
        end
        error(string.format("could not satisfy parameter expression for cell '%s'", cellname), 0)
    end

    -- install meta method for non-existing parameters as safety check
    -- this avoids arithmetic-with-nil-errors and raises an error instead
    setmetatable(P, {
        __index = function(_, k)
            error(string.format("trying to access undefined parameter value '%s'", k))
        end,
    })

    return P
end

local function set_property(state, cellname, property, value)
    local cell = _get_cell(state, cellname)
    cell.properties[property] = value
end

local function add_parameter(state, cellname, name, value, opt)
    opt = opt or {}
    local cell = _get_cell(state, cellname)
    _add_parameter(state, cell, name, value, opt.argtype, opt.posvals, opt.follow, opt.readonly)
end

local function add_parameters(state, cellname, ...)
    local cell = _get_cell(state, cellname)
    for _, parameter in ipairs({ ... }) do
        local name, value = parameter[1], parameter[2]
        _add_parameter(
            state,
            cell,
            name, value,
            parameter.argtype, parameter.posvals, parameter.follow, parameter.readonly
        )
    end
end

local function _push_overwrites(state, cellname, cellargs)
    assert(type(cellname) == "string", "push_overwrites: cellname must be a string")
    assert(type(cellargs) == "table", string.format("pcell.push_overwrites: 'cellargs' must be a table (got: %s)", type(cellargs)))
    local cell = _get_cell(state, cellname)
    table.insert(cell.overwrites, cellargs)
end

local function _pop_overwrites(state, cellname)
    local cell = _get_cell(state, cellname)
    if #cell.overwrites == 0 then
        error(string.format("trying to restore default parameters for '%s', but there where no previous overwrites", cellname))
    end
    table.remove(cell.overwrites)
end

local function check_expression(state, cellname, expression, message)
    local cell = _get_cell(state, cellname)
    table.insert(cell.expressions, { expression = expression, message = message })
end

local function _resolve_cellname(state, cellname)
    local libpart, cellpart = string.match(cellname, "([^/]+)/(.+)")
    if libpart == "." then -- relative library
        if not state.libnamestacks:peek() then
            error("top-level cell can't have a relative library")
        end
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
    cellrefs = {},
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
        negative = function() return { type = "negative" } end,
        inf = math.huge,
        pcell = {
            set_property                    = bindstatecell(set_property),
            add_parameter                   = bindstatecell(add_parameter),
            add_parameters                  = bindstatecell(add_parameters),
            check_expression                = bindstatecell(check_expression),
            -- the following functions don't not need cell binding as they are called for other cells
            get_parameters                  = bindstate(_get_parameters),
            push_overwrites                 = bindstate(_push_overwrites),
            pop_overwrites                  = bindstate(_pop_overwrites),
            create_layout                   = pcell.create_layout
        },
        tech = {
            get_dimension = technology.get_dimension,
            has_layer = technology.has_layer,
            resolve_metal = technology.resolve_metal
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
    return _get_parameters(state, othercell, cellargs)
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

function pcell.push_overwrites(cellname, cellargs)
    _push_overwrites(state, cellname, cellargs)
end

function pcell.pop_overwrites(cellname)
    _pop_overwrites(state, cellname)
end

function pcell.evaluate_parameters(cellname, cellargs)
    local parameters = {}
    for name, value in pairs(cellargs) do
        -- split name if in  'parent/parameter'
        local parent, arg = string.match(name, "^([^.]+)%.(.+)$")
        if parent then
            name = arg
        end

        local cell = _get_cell(state, parent or cellname)
        local p = cell.parameters:get(name)
        if not p then
            error(string.format("argument '%s' has no matching parameter in cell '%s', maybe it was spelled wrong?", name, parent or cellname))
        end
        local index = name
        if parent then
            index = string.format("%s.%s", parent, name)
        end
        parameters[index] = evaluator(value, p.argtype)
    end
    return parameters
end

local function _create_layout_internal(cellname, name, cellargs, env)
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
    local parameters = _get_parameters(state, cellname, cellargs) -- cellname needs to be passed twice
    local obj = object.create(name)
    cell.funcs.layout(obj, parameters, env)
    if explicitlib then
        state.libnamestacks:pop()
    end
    return obj
end

local _globalenv
function pcell.create_layout(cellname, name, cellargs, ...)
    if not cellname then
        error("pcell.create_layout: expected cellname as first argument")
    end
    if not name then
        error("pcell.create_layout: expected object name as second argument")
    end
    if select("#", ...) > 0 then
        error("pcell.create_layout was called with more three two arguments. If you wanted to pass an environment, use pcell.create_layout_env")
    end
    return _create_layout_internal(cellname, name, cellargs, _globalenv)
end

function pcell.create_layout_env(cellname, name, cellargs, env)
    if not cellname then
        error("pcell.create_layout_env: expected cellname as first argument")
    end
    if not cellname then
        error("pcell.create_layout_env: expetect object name as second argument")
    end
    -- cellargs can be nil
    if not env then
        error("pcell.create_layout_env: expected environment as fourth argument")
    end
    _globalenv = env
    local obj = _create_layout_internal(cellname, name, cellargs, _globalenv)
    _globalenv = nil
    return obj
end

function pcell.create_layout_from_script(scriptpath)
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
        local val = v.value
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
    local parameters = _get_parameters(state, cellname, cellargs, true) -- cellname needs to be passed twice
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

