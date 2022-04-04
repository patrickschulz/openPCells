local function _lexer(content)
    -- create character table
    local characters = {
        index = 1,
        get = function(self)
            if not self[self.index] then
                return nil
            end
            return self[self.index].character, self[self.index].line
        end,
        peek = function(self, offset)
            offset = offset or 1
            if not self[self.index + offset] then
                return nil
            end
            return self[self.index + offset].character, self[self.index + offset].line
        end,
        advance = function(self, offset) 
            offset = offset or 1
            self.index = self.index + offset
        end,
    }
    local line = 1
    for i = 1, string.len(content) do
        characters[i] = { character = string.sub(content, i, i), line = line }
        if string.sub(content, i, i) == "\n" then
            line = line + 1
        end
    end

    -- tokenize string
    local tokens = {}
    while true do
        local ch, line = characters:get()
        if ch then
            if string.match(ch, "[a-zA-Z_]") then -- simple identifier
                local ident = { ch }
                while true do
                    local nch = characters:peek()
                    if nch and string.match(nch, "[a-zA-Z0-9_$]") then
                        table.insert(ident, nch)
                        characters:advance()
                    else
                        break
                    end
                end
                table.insert(tokens, { type = "ident", value = table.concat(ident), line = line })
            elseif string.match(ch, "\\") then -- escaped identifier
                local ident = { ch }
                while true do
                    local nch = characters:peek()
                    if nch and string.match(nch, "%g") then -- %g: all printable characters except space
                        table.insert(ident, nch)
                        characters:advance()
                    else
                        break
                    end
                end
                table.insert(tokens, { type = "ident", value = table.concat(ident), line = line })
            elseif string.match(ch, "[0-9]") then -- number
                local number = { ch }
                while true do
                    local nch = characters:peek()
                    if nch and string.match(nch, "[0-9]") then
                        table.insert(number, nch)
                        characters:advance()
                    else
                        break
                    end
                end
                table.insert(tokens, { type = "number", value = table.concat(number), line = line })
            elseif ch == "/" and characters:peek() == "/" then -- line comment
                characters:advance()
                local comment = { }
                while true do
                    nch = characters:peek()
                    if nch and nch ~= "\n" then
                        table.insert(comment, nch)
                        characters:advance()
                    else
                        break
                    end
                end
                table.insert(tokens, { type = "linecomment", value = table.concat(comment), line = line })
            elseif ch == "/" and characters:peek() == "*" then -- block comment
                characters:advance()
                local comment = { }
                while true do
                    nch = characters:peek()
                    nch2 = characters:peek(2)
                    if not ((nch and nch == "*") and (nch2 and nch2 == "/")) then
                        table.insert(comment, nch)
                        characters:advance()
                    else
                        characters:advance(2)
                        break
                    end
                end
                table.insert(tokens, { type = "blockcomment", value = table.concat(comment), line = line })
            elseif ch == "(" and characters:peek() == "*" then -- attribute (FIXME: this should not be handled at the lexer level)
                characters:advance()
                local attribute = { }
                while true do
                    nch = characters:peek()
                    nch2 = characters:peek(2)
                    if not ((nch and nch == "*") and (nch2 and nch2 == ")")) then
                        table.insert(attribute, nch)
                        characters:advance()
                    else
                        characters:advance(2)
                        break
                    end
                end
                table.insert(tokens, { type = "attribute", value = table.concat(attribute), line = line })
            elseif string.match(ch, "[][{}:()+*/=-]") then -- operators
                table.insert(tokens, { type = "operator", value = ch, line = line })
            elseif ch == ";" or ch == "," or ch == "." or ch == "'" then -- punctuation
                table.insert(tokens, { type = "punct", value = ch, line = line })
            elseif ch == " " or ch == "\t" or ch == "\n" then
                -- whitespace, do nothing
            else
                error(string.format("lexer: unhandled character on line %d: %s", line, ch))
            end
        else 
            break
        end
        characters:advance()
    end
    return tokens
end

local function _convert_to_symbols(tokens)
    local symbols = {
        index = 1,
        identindex = 0,
        numberindex = 0,
        identifiers = {},
        numbers = {},
        lineinfo = {},
        current = function(self)
            return self[self.index]
        end,
        advance = function(self)
            self.index = self.index + 1
        end,
        accept = function(self, symbol)
            if self[self.index] == symbol then
                if symbol == "ident" then
                    self.identindex = self.identindex + 1
                end
                if symbol == "number" then
                    self.numberindex = self.numberindex + 1
                end
                self:advance()
                return true
            else
                return false
            end
        end,
        expect = function (self, symbol)
            if self:accept(symbol) then
                return true
            end
            error(string.format("expected '%s', got '%s' (source line %d)", symbol, self[self.index], self.lineinfo[self.index]))
        end,
        check = function(self, symbol) -- like accept, but don't advance state
            if self[self.index] == symbol then
                return true
            else
                return false
            end
        end,
        next_identifier = function(self)
            return self.identifiers[self.identindex]
        end,
        next_number = function(self)
            return self.numbers[self.numberindex]
        end,
    }
    for _, token in ipairs(tokens) do
        local value
        if token.type == "ident" then
            if token.value == "module" then
                value = "beginmodule"
            elseif token.value == "endmodule" then
                value = "endmodule"
            elseif token.value == "wire" then
                value = "wire"
            elseif token.value == "assign" then
                value = "assign"
            elseif token.value == "input" then
                value = "input"
            elseif token.value == "output" then
                value = "output"
            elseif token.value == "inout" then
                value = "inout"
            else
                value = "ident"
                local idt = string.gsub(token.value, "([\\])", {
                    ["\\"] = "_",
                })
                table.insert(symbols.identifiers, idt)
            end
        elseif token.type == "number" then
            value = "number"
            table.insert(symbols.numbers, token.value)
        elseif token.type == "operator" then
            if token.value == "(" then
                value = "lparen"
            elseif token.value == ")" then
                value = "rparen"
            elseif token.value == "[" then
                value = "lsqbracket"
            elseif token.value == "]" then
                value = "rsqbracket"
            elseif token.value == "{" then
                value = "lbrace"
            elseif token.value == "}" then
                value = "rbrace"
            elseif token.value == ":" then
                value = "colon"
            elseif token.value == "+" then
                value = "plus"
            elseif token.value == "-" then
                value = "minus"
            elseif token.value == "*" then
                value = "star"
            elseif token.value == "/" then
                value = "slash"
            elseif token.value == "=" then
                value = "equalsign"
            end
        elseif token.type == "punct" then
            if token.value == ";" then
                value = "semicolon"
            elseif token.value == "," then
                value = "comma"
            elseif token.value == "'" then
                value = "singlequote"
            else
                value = "dot"
            end
        elseif token.type == "attribute" then
            --value = "attribute"
        elseif token.type == "blockcomment" then
            --value = "blockcomment"
        elseif token.type == "linecomment" then
            --value = "linecomment"
        else
            moderror(string.format("lexer: _convert_to_symbols: unknown token type '%s'", token.type))
        end
        if value then
            if envlib.get("verbose") then
                print(string.format("verilog lexer: found symbol: %s", value))
            end
            table.insert(symbols, value)
            table.insert(symbols.lineinfo, token.line)
        end
    end
    return symbols
end

local function _identifier(symbols)
    symbols:expect("ident")
    return symbols:next_identifier()
end

local function _optbusaccess(symbols)
    local num = {}
    while symbols:accept("lsqbracket") do
        symbols:expect("number")
        local n = symbols:next_number()
        if symbols:accept("colon") then
            symbols:expect("number")
        end
        symbols:expect("rsqbracket")
        table.insert(num, n)
    end
    return num
end

local function _instancename(symbols)
    symbols:expect("ident")
    local name = symbols:next_identifier()
    return name
end

--[[
local function _decimal_number(symbols)
    local sign = 1
    symbols:accept("plus")
    if symbols:accept("minus") then
        sign = -1
    end
end
--]]

local function _number(symbols)
    symbols:expect("number")
    symbols:expect("singlequote")
    symbols:expect("ident")
end

local function _portconnection(symbols)
    if symbols:accept("dot") then -- named port
        -- FIXME: handle bus nets/ports
        local connection = {}
        symbols:expect("ident")
        connection.port = symbols:next_identifier()
        _optbusaccess(symbols)
        symbols:expect("lparen")
        if symbols:check("number") then
            _number(symbols)
            connection.net = "_FIXEDLEVEL_" -- FIXME
        else
            symbols:expect("ident")
            local num = _optbusaccess(symbols)
            connection.net = symbols:next_identifier()
            for _, n in ipairs(num) do
                connection.net = string.format("%s_%d", connection.net, n)
            end
        end
        symbols:expect("rparen")
        return connection
    end
end

local function _wirename(symbols)
    symbols:expect("ident")
    local num = _optbusaccess(symbols)
    local name = symbols:next_identifier()
    for _, n in ipairs(num) do
        name = string.format("%s_%d", name, n)
    end
    return name
end

local function _range(symbols)
    symbols:expect("lsqbracket")
    symbols:expect("number")
    local msb = symbols:next_number()
    symbols:expect("colon")
    symbols:expect("number")
    local lsb = symbols:next_number()
    symbols:expect("rsqbracket")
    return msb, lsb
end

local function _list_of_net_identifiers(symbols)
    local names = {}
    _identifier(symbols)
    table.insert(names, symbols:next_identifier())
    while symbols:accept("comma") do -- other names
        _identifier(symbols)
        table.insert(names, symbols:next_identifier())
    end
    return names
end

local function _statement(symbols)
    local s = {}
    if symbols:accept("wire") or symbols:accept("input") or symbols:accept("output") or symbols:accept("inout") then
        s.width = 1
        if symbols:check("lsqbracket") then
            local msb, lsb = _range(symbols)
            s.width = msb - lsb + 1
        end
        s.names = _list_of_net_identifiers(symbols)
        symbols:expect("semicolon")
        s.type = "wireportdef"
    elseif symbols:accept("assign") then -- assign statement
        s.lhs = _wirename(symbols)
        symbols:expect("equalsign")
        if symbols:accept("lbrace") then
            _wirename(symbols)
            while symbols:accept("comma") do
                _wirename(symbols)
            end
            symbols:expect("rbrace")
        else
            if symbols:check("number") then
                _number(symbols)
            else
                _wirename(symbols)
            end
        end
        symbols:expect("semicolon")
        s.type = "wireassignment"
    elseif symbols:accept("ident") then -- module instantiation
        s.name = symbols:next_identifier()
        s.instname = _instancename(symbols)
        symbols:expect("lparen") -- port list
        s.connections = {}
        table.insert(s.connections, _portconnection(symbols)) -- minimum one port
        while symbols:accept("comma") do -- other ports
            table.insert(s.connections, _portconnection(symbols))
        end
        symbols:expect("rparen")
        symbols:expect("semicolon")
        s.type = "moduleinstantiation"
    else
        moderror("unknown statement")
    end
    return s
end

local function _statements(symbols)
    local S = {}
    while symbols:check("wire") or 
          symbols:check("input") or 
          symbols:check("output") or 
          symbols:check("inout") or
          symbols:check("assign") or
          symbols:check("ident") do
        table.insert(S, _statement(symbols))
    end
    return S
end

local function _module(symbols)
    symbols:expect("beginmodule")
    symbols:expect("ident") -- module name
    local name = symbols:next_identifier()
    local ports = {}
    if symbols:accept("lparen") then -- port list
        symbols:expect("ident") -- minimum one port
        table.insert(ports, symbols:next_identifier())
        while symbols:accept("comma") do -- other ports
            symbols:expect("ident")
            table.insert(ports, symbols:next_identifier())
        end
        symbols:expect("rparen") -- end port list
    end
    symbols:expect("semicolon") -- end module header
    local S = _statements(symbols)
    symbols:expect("endmodule")
    return { type = "moduledeclaration", name = name, ports = ports, statements = S }
end

local function _modules(symbols)
    local M = {}
    while symbols:check("beginmodule") do
        table.insert(M, _module(symbols))
    end
    return M
end

local function _parser(symbols)
    return { type = "toplevel", modules = _modules(symbols) }
end

local M = {}

function M.parse_raw(content)
    local tokens = _lexer(content)
    local symbols = _convert_to_symbols(tokens)
    return _parser(symbols)
end

local function _collect_module(module)
    local instances = {}
    local connections = {}
    for _, statement in ipairs(module.statements) do
        local refname = statement.name
        local instname = statement.instname
        if statement.type == "moduleinstantiation" then
            local iconn = {}
            for _, connection in ipairs(statement.connections) do
                local c = { port = connection.port, net = connection.net }
                table.insert(iconn, c)
            end
            local instance = { name = instname, reference = refname, connections = iconn }
            table.insert(instances, instance)
        end
    end
    return instances
end

local meta = {}
meta.__index = meta

function meta.instances(self)
    local i = 0
    return function()
        i = i + 1
        return self._instances[i]
    end
end

function meta.references(self)
    local i = 0
    local t = {}
    local set = {}
    for instance in self:instances() do
        if not set[instance.reference] then
            set[instance.reference] = true
            table.insert(t, instance.reference)
        end
    end
    return function()
        i = i + 1
        return t[i]
    end
end

function meta.nets(self)

end

function meta.get_ports(self)
    return self.ports
end

local function _collect_modules(tree)
    local modules = {}
    for _, module in ipairs(tree.modules) do
        local instances = _collect_module(module)
        local m = { name = module.name, ports = module.ports, _instances = instances }
        setmetatable(m, meta)
        table.insert(modules, m)
    end
    return modules
end

function M.parse(content)
    local tree = M.parse_raw(content)
    local content = _collect_modules(tree)
    content.modules = function()
        local i = 0
        return function()
            i = i + 1
            return content[i]
        end
    end
    return content
end

function M.read_parse_file(filename)
    local file = io.open(filename, "r")
    if not file then
        moderror(string.format("generator.from_verilog: could not open file '%s'", filename))
    end
    local str = file:read("a")
    local content = M.parse(str)
    file:close()
    return content
end

function M.filter_excluded_nets(netlist, excluded_nets)
    for module in netlist:modules() do
        for instance in module:instances() do
            local ct = {}
            local po = {}
            for i = #instance.connections, 1, -1 do
                local c = instance.connections[i]
                if aux.any_of(function(v) return v == c.net end, excluded_nets) then
                    table.remove(instance.connections, i)
                end
            end
        end
    end
end


return M

