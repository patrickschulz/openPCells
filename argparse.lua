local M = {}

local function _advance(state, num)
    local num = num or 1
    state.i = state.i + num
end

local function _next_arg(args, state)
    _advance(state)
    return args[state.i]
end

local function _next_args(args, state, num)
    _advance(state, num)
    local t = {}
    for i = state.i - num + 1, state.i do
        table.insert(t, args[i])
    end
    return t
end

local function _consume_until_hyphen(args, state)
    local t = {}
    while true do
        local arg = args[state.i + 1]
        if not arg or string.match(arg, "^-") then break end
        table.insert(t, arg)
        _advance(state)
    end
    return table.concat(t, " ")
end

local function _parse_key_value_pairs(str)
    local t = {}
    for k, v in string.gmatch(str, "(%w+)%s*=%s*(%S+)") do
        t[k] = v
    end
    return t
end

local function _store_func(name)
    return function(res, state, args)
        res[name] = _next_arg(args, state)
    end
end

local function _switch_func(name)
    return function(res)
        res[name] = true
    end
end

local function _consumer_string_func(name)
    return function(res, state, args)
        res[name] = _consume_until_hyphen(args, state)
    end
end

local function _consumer_table_func(name)
    return function(res, state, args)
        res[name] = _parse_key_value_pairs(_consume_until_hyphen(args, state))
    end
end

local actions = {
    ["-P"]           = _switch_func("params"),
    ["--parameters"] = _switch_func("params"),
    ["-T"]           = _store_func("technology"),
    ["--technology"] = _store_func("technology"),
    ["-I"]           = _store_func("interface"),
    ["--interface"]  = _store_func("interface"),
    ["-C"]           = _store_func("cell"),
    ["--cell"]       = _store_func("cell"),
    ["-f"]           = _store_func("filename"),
    ["--filename"]   = _store_func("filename"),
    ["--origin"]     = _consumer_string_func("origin"),
    ["--iopt"]       = _consumer_table_func("interface_options"),
}

--local positional = _consumer_table_func("cellargs")
local positional = function(res, state, args)
    table.insert(res["cellargs"], args[state.i])
end

function M.parse(args)
    local state = { i = 1 }
    local res = { cellargs = {} }
    while state.i <= #args do
        local arg = args[state.i]
        local action = actions[arg]
        if not action then
            positional(res, state, args)
        else
            action(res, state, args)
        end
        _advance(state)
    end
    return res
end

return M
