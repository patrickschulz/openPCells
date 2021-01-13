--[[
This file is part of the openPCells project.

This module provides a simple argument parser for the main program
--]]

local function _advance(state, num)
    num = num or 1
    state.i = state.i + num
end

local function _next_arg(args, state)
    _advance(state)
    return args[state.i]
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

local function _display_help(self)
    local maxwidth = 0
    for _, opt in ipairs(self.optionsdef) do
        if opt.short and not opt.long then
            maxwidth = math.max(maxwidth, string.len(string.format("%s", opt.short)))
        elseif not opt.short and opt.long then
            maxwidth = math.max(maxwidth, string.len(string.format("%s", opt.long)))
        else
            maxwidth = math.max(maxwidth, string.len(string.format("%s,%s", opt.short, opt.long)))
        end
    end
    local fmt = string.format("    %%-%ds    %%s", maxwidth)
    print("openPCells generator")
    for _, opt in ipairs(self.optionsdef) do
        local cmdstr
        if opt.short and not opt.long then
            cmdstr = string.format("%s", opt.short)
        elseif not opt.short and opt.long then
            cmdstr = string.format("%s", opt.long)
        else
            cmdstr = string.format("%s,%s", opt.short, opt.long)
        end
        print(string.format(fmt, cmdstr, opt.help))
    end
    os.exit(0)
end


--local positional = _consumer_table_func("cellargs")
local positional = function(self, res, args)
    table.insert(res["cellargs"], args[self.state.i])
end

local function _get_action(self, args)
    local action = self.actions[args[self.state.i]]
    if not action then
        return positional
    else
        return action
    end
end

local meta = {}
meta.__index = meta

local function _resolve_func(name, funcname)
    if funcname == "store" then
        return function(self, res, args)
            res[name] = _next_arg(args, self.state)
        end
    elseif funcname == "switch" then
        return function(self, res, args)
            res[name] = true
        end
    elseif funcname == "consumer_string" then
        return function(self, res, args)
            res[name] = _consume_until_hyphen(args, self.state)
        end
    elseif funcname == "consumer_table" then
        return function(self, res, args)
            res[name] = _parse_key_value_pairs(_consume_until_hyphen(args, self.state))
        end
    else
        error(string.format("unknown action '%s'", funcname))
    end
end

function meta.register_options(self, optdef)
    self.optionsdef = optdef
    self.actions = {}
    for _, opt in ipairs(self.optionsdef) do
        local func = _resolve_func(opt.name, opt.func)
        if opt.short then
            self.actions[opt.short] = func
        end
        if opt.long then
            self.actions[opt.long] = func
        end
    end

    -- install help
    self.actions["-h"] = _display_help
    self.actions["--help"] = _display_help
    table.insert(self.optionsdef, 1, { short = "-h", long = "--help", help = "display this help" })
end

function meta.parse(self, args)
    local res = { cellargs = {} }
    while self.state.i <= #args do
        local action = _get_action(self, args)
        action(self, res, args)
        _advance(self.state)
    end
    return res
end

local self = {
    state = { i = 1 }
}
setmetatable(self, meta)
return self
