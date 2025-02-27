-- submodules

-- start of parameter module
local paramlib = {}

local parammeta = {}
parammeta.__index = parammeta

function paramlib.create_directory()
    local self = {
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

function parammeta.add(self, name, value, argtype, posvals, info, follow, readonly)
    local pname, dname = string.match(name, "^([^(]+)%(([^)]+)%)")
    if not pname then pname = name end -- no display name
    local new = {
        name      = pname,
        display   = dname,
        value     = value,
        argtype   = argtype,
        posvals   = posvals,
        info      = info,
        readonly  = not not readonly,
    }
    table.insert(self.values, new)
    if follow then
        -- FIXME: add cycle check
        self.followers[pname] = follow
    end
end

function parammeta.get(self, name)
    for _, entry in ipairs(self.values) do
        if entry.name == name then
            return entry
        end
    end
end

function parammeta.get_followers(self)
    return aux.clone_shallow(self.followers)
end
-- end of parameter module

local function _load_cell(state, cellname, env)
    if not cellname then
        error("pcell: load_cell expects a cellname")
    end
    local filename = state.internal_state.get_cell_filename(state.internal_state, cellname)
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
        if not util.any_of(function(v) return v == funcname end, { "config", "parameters", "layout", "check" }) then
            moderror(string.format("pcell: all defined toplevel values must be one of 'parameters', 'layout', 'check' or 'config'. Illegal name: '%s'", funcname))
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

local function _add_parameter_internal(cell, name, value, argtype, posvals, info, follow, readonly)
    argtype = argtype or type(value)
    cell.parameters:add(name, value, argtype, posvals, info, follow, readonly)
end

local function _get_parameters(state, cellname, cellargs)
    local cell = _get_cell(state, cellname)
    local cellparams = cell.parameters.values

    -- assemble arguments for the cell layout function
    local P = {}

    -- (1) fill with default values
    for _, entry in ipairs(cellparams) do
        P[entry.name] = entry.value
    end

    -- (2) process input parameters
    local explicit = {}
    if cellargs then
        for name, value in pairs(cellargs) do
            assert(P[name] ~= nil,
                string.format("argument '%s' has no matching parameter in cell '%s', maybe it was spelled wrong?", name, cellname))
            P[name] = value
            explicit[name] = true
        end
    end

    -- (3) handle followers
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

    -- (4) run parameter checks
    for _, entry in ipairs(cellparams) do
        paramlib.check_constraints(entry, P[entry.name])
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

local function _set_property(state, cellname, property, value)
    local cell = _get_cell(state, cellname)
    cell.properties[property] = value
end

local function _add_parameter(state, cellname, name, value, opt)
    if not name then
        error("pcell.add_parameter: no parameter name given")
    end
    opt = opt or {}
    local cell = _get_cell(state, cellname)
    _add_parameter_internal(cell, name, value, opt.argtype, opt.posvals, opt.info, opt.follow, opt.readonly)
end

local function _add_parameters(state, cellname, ...)
    local cell = _get_cell(state, cellname)
    for i, parameter in ipairs({ ... }) do
        local name, value = parameter[1], parameter[2]
        if not name then
            error(string.format("pcell.add_parameters: no parameter name given (entry %d)", i))
        end
        _add_parameter_internal(
            cell,
            name, value,
            parameter.argtype, parameter.posvals, parameter.info, parameter.follow, parameter.readonly
        )
    end
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
    internal_state = nil
}

pcell = {}

function pcell.register_pcell_state(internal_state)
    state.internal_state = internal_state
end

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
            set_property                    = bindstatecell(_set_property),
            add_parameter                   = bindstatecell(_add_parameter),
            add_parameters                  = bindstatecell(_add_parameters),
            -- the following functions don't not need cell binding as they are called for other cells
            inherit_parameters              = bindstatecell(_inherit_parameters),
            create_layout                   = pcell.create_layout,
            create_layout_env               = pcell.create_layout_env,
            create_layout_in_object         = pcell.create_layout_in_object,
            create_layout_env_in_object     = pcell.create_layout_env_in_object,
        },
        technology = {
            get_dimension = technology.get_dimension,
            get_optional_dimension = technology.get_optional_dimension,
            has_layer = technology.has_layer,
            has_metal = technology.has_metal,
            resolve_metal = technology.resolve_metal,
            has_multiple_patterning = technology.has_multiple_patterning,
            multiple_patterning_number = technology.multiple_patterning_number,
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
        layouthelpers = layouthelpers,
        math = math,
        enable = function(bool, val) return (bool and 1 or 0) * (val or 1) end,
        evenodddiv2 = function(num) if num % 2 == 0 then return num / 2, num / 2 else return num // 2, num // 2 + 1 end end,
        divevendown = function(num, div) while (num / div % 2) ~= 0 do num = num - 1 end return num / div end,
        divevenup = function(num, div) while (num / div % 2) ~= 0 do num = num + 1 end return num / div end,
        string = string,
        table = table,
        marker = marker,
        transformationmatrix = transformationmatrix,
        dprint = function(...) state.internal_state.dprint(state.internal_state, ...) end,
        moderror = moderror,
        tonumber = tonumber,
        type = type,
        ipairs = ipairs,
        pairs = pairs,
        pcall = pcall,
        xpcall = xpcall,
        cellerror = moderror,
        fulltraceback = fulltraceback,
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

function pcell.enable_debug(d)
    state.debug = d
end

local function _create_layout_internal(state, obj, cellname, cellargs, env)
    local libpart, cellpart = string.match(cellname, "([^/]+)/(.+)")
    if not libpart then
        error(string.format("pcell.create_layout: malformed cellname. Expected library/cell, got '%s'", cellname))
    end
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

    local parameters = _get_parameters(state, cellname, cellargs)

    -- check parameters
    if cell.funcs.check then
        local ret, msg = cell.funcs.check(parameters)
        if not ret then
            if not msg then
                moderror(string.format("parameter check for cell '%s' failed, but no message was returned. If present, the 'check' function has to return true on success", cellname))
            else
                moderror(string.format("parameter check for cell '%s' failed: %s", cellname, msg))
            end
        end
    end

    cell.funcs.layout(obj, parameters, env)
    if explicitlib then
        state.libnamestacks:pop()
    end
end

local _globalenv
function pcell.create_layout(cellname, name, cellargs, ...)
    if not cellname or type(cellname) ~= "string" then
        error("pcell.create_layout: expected cellname (a string) as first argument")
    end
    if not name or type(name) ~= "string" then
        error("pcell.create_layout: expected object name (a string) as second argument")
    end
    if select("#", ...) > 0 then
        error("pcell.create_layout was called with more three two arguments. If you wanted to pass an environment, use pcell.create_layout_env")
    end
    local obj = object.create(name)
    _create_layout_internal(state, obj, cellname, cellargs)
    return obj
end

function pcell.create_layout_env(cellname, name, cellargs, env)
    if not cellname or type(cellname) ~= "string" then
        error("pcell.create_layout_env: expected cellname as first argument")
    end
    if not name or type(name) ~= "string" then
        error("pcell.create_layout_env: expected object name (a string) as second argument")
    end
    -- cellargs can be nil
    if not env then
        error("pcell.create_layout_env: expected environment as fourth argument")
    end
    local oldenv = _globalenv
    _globalenv = env
    local obj = object.create(name)
    _create_layout_internal(state, obj, cellname, cellargs, _globalenv)
    _globalenv = oldenv
    return obj
end

function pcell.create_layout_in_object(obj, cellname, cellargs, ...)
    if not obj or not object.is_object(obj) then
        error("pcell.create_layout_in_object: expected an object as first argument")
    end
    if not cellname or type(cellname) ~= "string" then
        error("pcell.create_layout: expected cellname (a string) as second argument")
    end
    if select("#", ...) > 0 then
        error("pcell.create_layout was called with more three two arguments. If you wanted to pass an environment, use pcell.create_layout_env")
    end
    _create_layout_internal(state, obj, cellname, cellargs)
end

function pcell.create_layout_env_in_object(obj, cellname, cellargs, env)
    if not obj or not object.is_object(obj) then
        error("pcell.create_layout_in_object: expected an object as first argument")
    end
    if not cellname or type(cellname) ~= "string" then
        error("pcell.create_layout_env: expected cellname as second argument")
    end
    -- cellargs can be nil
    if not env then
        error("pcell.create_layout_env: expected environment as fourth argument")
    end
    local oldenv = _globalenv
    _globalenv = env
    _create_layout_internal(state, obj, cellname, cellargs, _globalenv)
    _globalenv = oldenv
end

function pcell.create_layout_from_script(scriptpath, args)
    local reader = _get_reader(scriptpath)
    if reader then
        local env = _ENV
        local path, name = aux.split_path(scriptpath)
        env.CURRENT_SCRIPT_PATH = path
        env.CURRENT_SCRIPT_NAME = name
        -- save args and then replace them
        local savedargs = env.args
        env.args = args
        -- run script
        local cell = _dofile(reader, string.format("@%s", scriptpath), nil, env)
        if not cell then
            error(string.format("cellscript '%s' did not return an object", scriptpath))
        end
        env.args = savedargs
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

-- custom table.concat, as the original does not handle boolean entries
local function _tconcat(t, sep)
    local result = {}
    for i, e in ipairs(t) do
        table.insert(result, tostring(e))
    end
    return table.concat(result, sep)
end

local function _collect_parameters(cell, ptype, parent, str)
    for _, entry in ipairs(cell.parameters.values) do
        local val = entry.value
        if type(val) == "table" and not val.isgenerictechparameter then
            if #val == 0 then
                val = " "
            else
                val = "{ " .. _tconcat(val, ",") .. " }"
            end
        else
            val = tostring(val)
        end
        local ptype = ptype
        table.insert(str, {
            parent = parent,
            name = entry.name,
            display = entry.display,
            value = val,
            ptype = ptype,
            argtype = tostring(entry.argtype),
            info = entry.info,
            readonly = entry.readonly,
            posvals = entry.posvals
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
    --local parameters = _get_parameters(state, cellname, cellargs, true) -- cellname needs to be passed twice
    local str = {}
    _collect_parameters(cell, "N", cellname, str)
    
    -- FIXME: implement parameter collection from layout functions
    -- execute the 'layout' function without creating any layouts to collect all used parameters
    -- this is required in order to get the actual transparent parameters of subcells
    -- (that is, parameters that are not overwritten on higher levels)
    -- UPDATE: overwrites don't exist any more, this is probably much simpler now
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

function pcell.anchors(cellname)
    local cell = _get_cell(state, cellname)
    --for k, v in pairs(
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
    for _, parameter in ipairs(cell.parameters.values) do
        if parameter.argtype == "number" or parameter.argtype == "integer" then
            if not parameter.posvals then
                _perform_cell_check(cellname, parameter.name, { 1, 2 })
            elseif parameter.posvals.type == "even" then
                _perform_cell_check(cellname, parameter.name, { 2 })
            elseif parameter.posvals.type == "odd" then
                _perform_cell_check(cellname, parameter.name, { 1 })
            elseif parameter.posvals.type == "set" then
                _perform_cell_check(cellname, parameter.name, parameter.posvals.values)
            elseif parameter.posvals.type == "interval" then
                local values = { parameter.posvals.values.lower, parameter.posvals.values.upper }
                if parameter.posvals.values.upper == math.huge then
                    values[2] = 1000
                end
                _perform_cell_check(cellname, parameter.name, values)
            end
        end
    end
end

