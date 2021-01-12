--[[
This file is part of the openPCells project.

This module provides a simple argument parser for the main program
--]]

local M = {}

local lut = {}

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

local function _store_func(name)
    if not lut[string.format("_store(%s)", name)] then
        lut[string.format("_store(%s)", name)] = 
            function(self, res, args)
                res[name] = _next_arg(args, self.state)
            end
    end
    return lut[string.format("_store(%s)", name)]
end

local function _switch_func(name)
    if not lut[string.format("_switch(%s)", name)] then
        lut[string.format("_switch(%s)", name)] = 
            function(self, res)
                res[name] = true
            end
    end
    return lut[string.format("_switch(%s)", name)]
end

local function _consumer_string_func(name)
    if not lut[string.format("_consumer_string(%s)", name)] then
        lut[string.format("_consumer_string(%s)", name)] =
            function(self, res, args)
                res[name] = _consume_until_hyphen(args, self.state)
            end
    end
    return lut[string.format("_consumer_string(%s)", name)]
end

local function _consumer_table_func(name)
    if not lut[string.format("_consumer_table(%s)", name)] then
        lut[string.format("_consumer_table(%s)", name)] =
            function(self, res, args)
                res[name] = _parse_key_value_pairs(_consume_until_hyphen(args, self.state))
            end
    end
    return lut[string.format("_consumer_table(%s)", name)]
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

self = {}

self.optionsdef = {
    { 
        short = "-h",
        long  = "--help",
        func  = _display_help,
        help  = "display this help"
    },
    { 
        short = "-p",
        long  = "--profile",
        func  = _display_help,
        help  = "display this help"
    },
    { 
        short = "-P",
        long  = "--parameters",
        func  = _switch_func("params"),
        help  = "display available cell parameters and exit"
    },
    { 
        short = "-L",
        long  = "--list",
        func  = _switch_func("listcells"),
        help  = "list available cells"
    },
    { 
        long  = "--constraints",
        func  = _switch_func("constraints"),
        help  = "show required technology parameter (needs --cell and --technology)"
    },
    { 
        long  = "--separator",
        func  = _store_func("separator"),
        help  = "cell parameter separator (default \\n)"
    },
    { 
        short = "-T",
        long  = "--technology",
        func  = _store_func("technology"),
        help  = "specify technology"
    },
    { 
        short = "-I",
        long  = "--interface",
        func  = _store_func("interface"),
        help  = "specify interface"
    },
    { 
        short = "-C",
        long  = "--cell",
        func  = _store_func("cell"),
        help  = "specify cell"
    },
    --[[
    { 
        short = "-E",
        long  = "--export",
        func  = _store_func("export"),
        help  = "specify export"
    },
    --]]
    { 
        short = "-f",
        long  = "--filename",
        func  = _store_func("filename"),
        help  = "specify output filename for interface and export"
    },
    { 
        long  = "--origin",
        func  = _consumer_string_func("origin"),
        help  = "origin of cell (move (0, 0))"
    },
    { 
        long  = "--orientation",
        func  = _consumer_string_func("orientation"),
        help  = "orientation of cell (possible values: 0 (regular), fx (flip x), fy (flip y), fxy (flip x and y))"
    },
    { 
        long  = "--iopt",
        func  = _consumer_table_func("interface_options"),
        help  = "pass special options to interface"
    },
    { 
        long  = "--check",
        func  = _switch_func("check"),
        help  = "check cell code"
    },
    { 
        long  = "--notech",
        func  = _switch_func("notech"),
        help  = "disable all technology translation functions (metal translation, via arrayzation, layer mapping grid fixing)"
    },
    { 
        long  = "--nointerface",
        func  = _switch_func("nointerface"),
        help  = "disable all interface/export functions. This is different from --dryrun, which calls the interface translation, but does not write any files. Both options are mostly related to profiling, if interfaces should be profiled --dryrun must be used"
    },
    { 
        long  = "--dryrun",
        func  = _switch_func("dryrun"),
        help  = "perform all calculations, but don't actually write any files. This is useful for profiling, where the program should run normally but should not produce any output"
    },
    { 
        short = "-D",
        long  = "--debug",
        func  = _store_func("debug"),
        help  = "enable debugging output (specify modules separated by commas)"
    },
}

self.actions = {}
for _, opt in ipairs(self.optionsdef) do
    if opt.short then
        self.actions[opt.short] = opt.func
    end
    if opt.long then
        self.actions[opt.long] = opt.func
    end
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

function M.parse(args)
    self.state = { i = 1 }
    local res = { cellargs = {} }
    while self.state.i <= #args do
        local action = _get_action(self, args)
        action(self, res, args)
        _advance(self.state)
    end
    return res
end

return M
