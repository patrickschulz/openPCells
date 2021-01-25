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
    local displaywidth <const> = 80
    local optwidth = 0
    for _, opt in ipairs(self.optionsdef) do
        if opt.short and not opt.long then
            optwidth = math.max(optwidth, string.len(string.format("%s", opt.short)))
        elseif not opt.short and opt.long then
            optwidth = math.max(optwidth, string.len(string.format("%s", opt.long)))
        else
            optwidth = math.max(optwidth, string.len(string.format("%s,%s", opt.short, opt.long)))
        end
    end
    local fmt = string.format("    %%-%ds    %%s", optwidth)
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

        -- break long help strings into lines
        local helpstrtab = {}
        local line = {}
        local linewidth = 0
        for word in string.gmatch(opt.help, "(%S+)") do
            local width = string.len(word)
            linewidth = linewidth + width
            if linewidth > displaywidth then
                table.insert(helpstrtab, table.concat(line, " "))
                line = {}
                linewidth = 0
            end
            table.insert(line, word)
        end
        -- insert remaining part of the line
        table.insert(helpstrtab, table.concat(line, " "))

        local helpstr = table.concat(helpstrtab, string.format("\n%s", string.rep(" ", optwidth + 8))) -- +8 to compensate for spaces in format string

        print(string.format(fmt, cmdstr, helpstr))
    end
    os.exit(0)
end

local function _display_version(self)
    print("openPCells (opc) 0.1.0")
    print("Copyright 2020-2021 Patrick Kurth")
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
    table.insert(self.optionsdef, 1, { short = "-h", long = "--help", help = "display this help and exit" })
    -- install version
    self.actions["-v"] = _display_version
    self.actions["--version"] = _display_version
    table.insert(self.optionsdef, 1, { short = "-v", long = "--version", help = "display version and exit" })
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
