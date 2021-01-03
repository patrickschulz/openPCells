--[[
This file is part of the openPCells project.

This module provides a simple argument parser for the main program
--]]

local M = {}

local function _advance(state, num)
    num = num or 1
    state.i = state.i + num
end

local function _next_arg(args, state)
    _advance(state)
    return args[state.i]
end

--[[
local function _next_args(args, state, num)
    _advance(state, num)
    local t = {}
    for i = state.i - num + 1, state.i do
        table.insert(t, args[i])
    end
    return t
end
--]]

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

local function _display_help()
    print([[openPCells generator
    -h, --help           display this help
    -C, --cell           specify cell
    -P, --parameters     display available cell parameters and exit
    -T, --technology     specify technology
    -I, --interface      specify interface
    --filename           output filename
    --origin             origin of cell (move (0, 0))
    --orientation        orientation of cell (possible values: 0 (regular), fx (flip x), fy (flip y), fxy (flip x and y))
    --iopt               pass special options to interface
    --check              check cell code
    --notech             disable all technology translation functions (metal translation, via arrayzation, layer mapping grid fixing)
    -D, --debug          enable debugging output (specify modules separated by commas)]])
    os.exit(0)
end

local actions = {
    ["-P"]             = _switch_func("params"),
    ["--parameters"]   = _switch_func("params"),
    ["-L"]             = _switch_func("listcells"),
    ["--list"]         = _switch_func("listcells"),
    ["--separator"]    = _store_func("separator"),
    ["-T"]             = _store_func("technology"),
    ["--technology"]   = _store_func("technology"),
    ["-I"]             = _store_func("interface"),
    ["--interface"]    = _store_func("interface"),
    ["-E"]             = _store_func("export"),
    ["--export"]       = _store_func("export"),
    ["-C"]             = _store_func("cell"),
    ["--cell"]         = _store_func("cell"),
    ["-f"]             = _store_func("filename"),
    ["--filename"]     = _store_func("filename"),
    ["--origin"]       = _consumer_string_func("origin"),
    ["--orientation"]  = _consumer_string_func("orientation"),
    ["--iopt"]         = _consumer_table_func("interface_options"),
    ["--check"]        = _switch_func("check"),
    ["--notech"]       = _switch_func("notech"),
    ["-D"]             = _store_func("debug"),
    ["--debug"]        = _store_func("debug"),
    ["-h"]             = _display_help,
    ["--help"]         = _display_help,
}

--local positional = _consumer_table_func("cellargs")
local positional = function(res, state, args)
    table.insert(res["cellargs"], args[state.i])
end

local function _get_action(state, args)
    if not actions[args[state.i]] then
        return positional
    else
        return actions[args[state.i]]
    end
end

function M.parse(args)
    local state = { i = 1 }
    local res = { cellargs = {} }
    while state.i <= #args do
        local action = _get_action(state, args)
        action(res, state, args)
        _advance(state)
    end
    return res
end

return M
