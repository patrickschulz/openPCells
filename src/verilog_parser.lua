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
            offset = offset or 0
            if not self[self.index + 1 + offset] then
                return nil
            end
            return self[self.index + 1 + offset].character, self[self.index + 1 + offset].line
        end,
        advance = function(self) 
            self.index = self.index + 1
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
            if string.match(ch, "[a-zA-Z_\\]") then -- identifier
                local ident = { ch }
                while true do
                    local nch = characters:peek()
                    if nch and string.match(nch, "[a-zA-Z0-9_\\!/]") then
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
                    nch2 = characters:peek(1)
                    if not ((nch and nch == "*") and (nch2 and nch2 == "/")) then
                        table.insert(comment, nch)
                        characters:advance()
                    else
                        break
                    end
                end
                table.insert(tokens, { type = "blockcomment", value = table.concat(comment), line = line })
            elseif string.match(ch, "[][:()+*/=-]") then -- operators
                table.insert(tokens, { type = "operator", value = ch, line = line })
            elseif ch == ";" or ch == "," or ch == "." then -- punctuation
                table.insert(tokens, { type = "punct", value = ch, line = line })
            elseif ch == " " or ch == "\t" or ch == "\n" then
                -- whitespace, do nothing
            else
                error(string.format("lexer: unhandled character: %s", ch))
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
            if symbol == "ident" then
                self.identindex = self.identindex + 1
            end
            if symbol == "number" then
                self.numberindex = self.numberindex + 1
            end
            if self[self.index] == symbol then
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
        check = function(self, symbol)
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
        if token.type == "ident" then
            if token.value == "module" then
                table.insert(symbols, "beginmodule")
            elseif token.value == "endmodule" then
                table.insert(symbols, "endmodule")
            elseif token.value == "wire" then
                table.insert(symbols, "wire")
            elseif token.value == "assign" then
                table.insert(symbols, "assign")
            elseif token.value == "input" then
                table.insert(symbols, "input")
            elseif token.value == "output" then
                table.insert(symbols, "output")
            elseif token.value == "inout" then
                table.insert(symbols, "inout")
            else
                table.insert(symbols, "ident")
                local value = string.gsub(token.value, "([\\])", {
                    ["\\"] = "\\\\",
                })
                table.insert(symbols.identifiers, value)
            end
        end
        if token.type == "number" then
            table.insert(symbols, "number")
            table.insert(symbols.numbers, token.value)
        end
        if token.type == "operator" then
            if token.value == "(" then
                table.insert(symbols, "lparen")
            elseif token.value == ")" then
                table.insert(symbols, "rparen")
            elseif token.value == "[" then
                table.insert(symbols, "lsqbracket")
            elseif token.value == "]" then
                table.insert(symbols, "rsqbracket")
            elseif token.value == ":" then
                table.insert(symbols, "colon")
            elseif token.value == "+" then
                table.insert(symbols, "plus")
            elseif token.value == "-" then
                table.insert(symbols, "minus")
            elseif token.value == "*" then
                table.insert(symbols, "star")
            elseif token.value == "/" then
                table.insert(symbols, "slash")
            elseif token.value == "=" then
                table.insert(symbols, "equalsign")
            end
        end
        if token.type == "punct" then
            if token.value == ";" then
                table.insert(symbols, "semicolon")
            elseif token.value == "," then
                table.insert(symbols, "comma")
            else
                table.insert(symbols, "dot")
            end
        end
        table.insert(symbols.lineinfo, token.line)
    end
    return symbols
end

local function optbusaccess(symbols)
    if symbols:accept("lsqbracket") then
        symbols:expect("number")
        local num = symbols:next_number()
        symbols:expect("rsqbracket")
        return num
    end
end

local function _instancename(symbols)
    symbols:expect("ident")
    local name = symbols:next_identifier()
    -- FIXME: handle bus names
    local num = optbusaccess(symbols)
    if num then
        name = string.format("%s_%d", name, num)
    end
    return name
end

local function _portconnection(symbols)
    if symbols:accept("dot") then -- named port
        -- FIXME: handle bus nets/ports
        local connection = {}
        symbols:expect("ident")
        connection.port = symbols:next_identifier()
        optbusaccess(symbols)
        symbols:expect("lparen")
        symbols:expect("ident")
        local num = optbusaccess(symbols)
        if num then
            connection.net = string.format("%s_%d", symbols:next_identifier(), num)
        else
            connection.net = symbols:next_identifier()
        end
        symbols:expect("rparen")
        return connection
    end
end

local function _wirename(symbols)
    symbols:expect("ident")
    local num = optbusaccess(symbols)
    if num then
        name = string.format("%s_%d", name, num)
    end
    return name
end

local function _statement(symbols)
    local s = {}
    if symbols:accept("wire") or symbols:accept("input") or symbols:accept("output") or symbols:accept("inout") then
        if symbols:accept("lsqbracket") then
            symbols:expect("number")
            symbols:expect("colon")
            symbols:expect("number")
            symbols:expect("rsqbracket")
        end
        _wirename(symbols)
        while symbols:accept("comma") do -- other names
            _wirename(symbols)
        end
        symbols:expect("semicolon")
        s.type = "wireportdef"
    elseif symbols:accept("assign") then -- assign statement
        _wirename(symbols)
        symbols:expect("equalsign")
        _wirename(symbols)
        symbols:expect("semicolon")
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

function M.parse(content)
    local tokens = _lexer(content)
    local symbols = _convert_to_symbols(tokens)
    return _parser(symbols)
end

return M
