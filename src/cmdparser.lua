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
    local displaywidth <const> = 70
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
    for _, msg in ipairs(self.prehelpmsg) do
        print(msg)
    end
    print("list of command line options:\n")
    for _, opt in ipairs(self.optionsdef) do
        if opt.issection then
            print(opt.name)
        else
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
    end
    for _, msg in ipairs(self.posthelpmsg) do
        print(msg)
    end
    os.exit(0)
end

local function _display_version(self)
    print("openPCells (opc) 0.1.0")
    print("Copyright 2020-2021 Patrick Kurth")
    os.exit(0)
end

local positional = function(self, arg)
    table.insert(self.res.cellargs, arg)
end

local meta = {}
meta.__index = meta

local function _load_options(filename)
    if not filename then
        error("no commandline options filename name given")
    end
    local chunkname = string.format("@%s", filename)

    local reader, msg = _get_reader(filename)
    if not reader then
        error(msg)
    end

    local env = {
        switch = function(t)
            t.func = function(self)
                self.res[t.name] = true
            end
            t.parser = function() end
            return t
        end,
        store = function(t)
            t.func = function(self, arg)
                self.res[t.name] = arg
            end
            t.parser = function(self, args) return _next_arg(args, self.state) end
            return t
        end,
        store_multiple = function(t)
            t.func = function(self, arg)
                if not self.res[t.name] then self.res[t.name] = {} end
                table.insert(self.res[t.name], arg)
            end
            t.parser = function(self, args) return _next_arg(args, self.state) end
            return t
        end,
        store_multiple_string = function(t)
            t.func = function(self, arg)
                if not self.res[t.name] then self.res[t.name] = "" end
                self.res[t.name] = string.format("%s %s", self.res[t.name], arg)
            end
            t.parser = function(self, args) return _next_arg(args, self.state) end
            return t
        end,
        consumer_string = function(t)
            t.func = function(self, arg)
                self.res[t.name] = arg
            end
            t.parser = function(self, args) return _consume_until_hyphen(args, self.state) end
            return t
        end,
        consumer_table = function(t)
            t.func = function(self, arg)
                self.res[t.name] = arg
            end
            t.parser = function(self, args) return _parse_key_value_pairs(_consume_until_hyphen(args, self.state)) end
            return t
        end,
        section = function(name)
            return { issection = true, name = name }
        end
    }
    return _generic_load(reader, chunkname, nil, nil, env)
end

function meta.load_options_from_file(self, filename)
    meta.load_options(self, _load_options(filename))
end

function meta.load_options(self, options)
    self.optionsdef = options
    table.insert(self.optionsdef, 1, { name = "help", short = "-h", long = "--help", help = "display this help and exit", func = _display_help, parser = function() end })
    table.insert(self.optionsdef, 2, { name = "version", short = "-v", long = "--version", help = "display version and exit", func = _display_version, parser = function() end })
    for key, opt in ipairs(self.optionsdef) do
        if not opt.issection then
            if opt.short then
                self.nameresolve[opt.short] = opt.name
            end
            if opt.long then
                self.nameresolve[opt.long] = opt.name
            end
            self.parsers[opt.name] = opt.parser
            self.actions[opt.name] = opt.func
            self.defaults[opt.name] = opt.default
        end
    end
end

local function _get_parser(self, args)
    local name = self.nameresolve[args[self.state.i]]
    local parser = self.parsers[name]
    if not parser then
        return function(self, args) return args[self.state.i] end -- dummy parser for positional arguments
    end
    return parser
end

local function _get_action(self, args)
    local name = self.nameresolve[args[self.state.i]]
    local action = self.actions[name]
    if not action then
        if string.match(args[self.state.i], "^-") then
            return nil, string.format("commandline arguments: unknown option '%s'", args[self.state.i])
        end
        return positional
    else
        return action
    end
end

function meta.parse(self, args)
    while self.state.i <= #args do
        local parser = _get_parser(self, args)
        local action, msg = _get_action(self, args)
        local arg = parser(self, args)
        if not action then
            return nil, msg
        end
        action(self, arg)
        _advance(self.state)
    end
    -- split key=value pairs (positional parameters, which are k-v-pairs in opc)
    -- TODO: put this in a separate function?
    local cellargs = {}
    local text = table.concat(self.res.cellargs, " ")
    local idx = 1
    local search = not not string.match(text, "=")
    while search do
        local s1, s2, k = string.find(text, "([%w/._]+)%s*=%s*", idx)
        local s3 = string.find(text, "([%w/._]+)%s*=", s2 + 1)
        if not s3 then search = false end
        local v = string.match(string.sub(text, s2 + 1, s3 and (s3 - 1) or nil), "(.-)%s*$")
        v = string.gsub(v, "\\n", "\n") -- replace escape sequences (FIXME: only new line currently supported)
        idx = s3
        cellargs[k] = v
    end
    self.res.cellargs = cellargs
    return self.res
end

function meta.set_defaults(self, args)
    local visited = {}
    for name in pairs(args) do
        visited[name] = true
    end
    for name in pairs(self.defaults) do
        if not visited[name] then
            args[name] = self.defaults[name]
        end
    end
end

function meta.set_option(self, param, arg)
    local action = self.actions[param]
    action(self, arg)
end

function meta.prepend_to_help_message(self, msg)
    table.insert(self.prehelpmsg, 1, msg)
end

function meta.append_to_help_message(self, msg)
    table.insert(self.posthelpmsg, msg)
end

return function()
    local self = {
        state = { i = 1 },
        parsers = {},
        actions = {},
        defaults = {},
        nameresolve = {},
        res = { cellargs = {} },
        prehelpmsg = {},
        posthelpmsg = {},
    }
    setmetatable(self, meta)
    return self
end
