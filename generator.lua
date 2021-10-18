local M = {}

local function _write_module(file, module)
    -- place cells and collect connections
    local connections = {}
    for _, statement in ipairs(module.statements) do
        local name = statement.name
        local instname = statement.instname
        if statement.type == "moduleinstantiation" then
            file:write(string.format('    local %sref = pcell.create_layout("%s")\n', instname, name))
            file:write(string.format('    local %sname = pcell.add_cell_reference(%sref, "%s")\n', instname, instname, instname))
            file:write(string.format('    local %s = toplevel:add_child(%sname, "%s")\n', instname, instname, instname))
            for _, connection in ipairs(statement.connections) do
                if not connections[connection.net] then connections[connection.net] = {} end
                table.insert(connections[connection.net], { instance = instname, port = connection.port })
            end
        end
    end
    -- place connections
    for net, connection in pairs(connections) do
        if #connection == 2 then
            file:write("    toplevel:merge_into_shallow(geometry.path(generics.metal(1), {\n")
            file:write(string.format('        %s:get_anchor("%s"),\n        %s:get_anchor("%s")\n    }, cwidth))\n', 
                connection[1].instance, connection[1].port, connection[2].instance, connection[2].port))
        end
    end
end

local function _generate_from_ast(tree)
    for _, module in ipairs(tree.modules) do
        print(string.format("writing to file '__%s.lua'", module.name))
        local file = io.open(string.format("__%s.lua", module.name), "w")
        file:write("function parameters()\nend\n\n")
        file:write("function layout(toplevel)\n")
        _write_module(file, module)
        file:write("end")
        file:close()
    end
end

function M.from_verilog(filename)
    local file = io.open(filename, "r")
    if not file then
        moderror(string.format("generator.verilog_routing: could not open file '%s'", filename))
    end
    local content = file:read("a")
    local tree = verilog_parser.parse(content)
    _generate_from_ast(tree)
end

return M
