local M = {}

local function _write_module(file, module, positions, noconnections)
    -- set up lookup tables
    local references = {}
    file:write('    local references = {\n')
    for _, statement in ipairs(module.statements) do
        local name = statement.name
        local instname = statement.instname
        if statement.type == "moduleinstantiation" then
            if not references[name] then
                references[name] = true
                file:write(string.format('        ["%s"] = pcell.add_cell_reference(pcell.create_layout("GF22FDX_SC8T_104CPP_BASE_CSC20SL/%s"), "%s"),\n', name, name, name))
            end
        end
    end
    file:write('    }\n')

    -- place cells and collect connections
    file:write('    local cells = {\n')
    local connections = {}
    for _, statement in ipairs(module.statements) do
        local name = statement.name
        local instname = statement.instname
        if statement.type == "moduleinstantiation" then
            file:write(string.format('        ["%s"] = toplevel:add_child(references["%s"], "%s")', instname, name, instname))
            if positions[instname] then
                file:write(string.format(':translate(%d, %d)', positions[instname].x, positions[instname].y))
            end
            file:write(",\n")
            for _, connection in ipairs(statement.connections) do
                if not connections[connection.net] then connections[connection.net] = {} end
                table.insert(connections[connection.net], { instance = instname, port = connection.port })
            end
        end
    end
    file:write('    }\n')
    --file:write('    placement.digital_auto(toplevel, 104, 400 * 104, cellnames, {}, 0.8)\n')

    --[[
    -- place connections
    if not noconnections then
        for net, connection in pairs(connections) do
            if #connection == 2 then
                file:write("    toplevel:merge_into_shallow(geometry.path(generics.metal(1), {\n")
                file:write(string.format('        children["%s"]:get_anchor("%s"),\n        children["%s"]:get_anchor("%s")\n    }, cwidth))\n', 
                    connection[1].instance, connection[1].port, connection[2].instance, connection[2].port))
            end
        end
    end
    --]]
end

local function _generate_from_ast(basename, tree, positions, noconnections)
    for _, module in ipairs(tree.modules) do
        print(string.format("writing to file '%s/%s.lua'", basename, module.name))
        local file = io.open(string.format("%s/%s.lua", basename, module.name), "w")
        file:write("function parameters()\nend\n\n")
        file:write("function layout(toplevel)\n")
        _write_module(file, module, positions, noconnections)
        file:write("end")
        file:close()
    end
end

function M.from_verilog(filename, noconnections, prefix, libname, overwrite, stdlibname)
    local file = io.open(filename, "r")
    if not file then
        moderror(string.format("generator.verilog_routing: could not open file '%s'", filename))
    end
    local content = file:read("a")
    local tree = verilog_parser.parse(content)
    local nets = { set = {} }
    local instances = {}
    local widths = {}
    local excluded_nets = { "clk", "VDD", "VSS" }
    for _, module in ipairs(tree.modules) do
        for _, statement in ipairs(module.statements) do
            local name = statement.name
            local instname = statement.instname
            if statement.type == "moduleinstantiation" then
                local ct = {}
                for _, c in ipairs(statement.connections) do
                    if not aux.any_of(function(v) return v == c.net end, excluded_nets) then
                        if not nets.set[c.net] then
                            table.insert(nets, c.net)
                            nets.set[c.net] = true
                        end
                        for i, net in ipairs(nets) do
                            if c.net == net then
                                table.insert(ct, i)
                                break
                            end
                        end
                    end
                end
                if not widths[name] then
                    local cell = pcell.create_layout(string.format("%s/%s", stdlibname, name))
                    widths[name] = cell:width_height_alignmentbox()
                    print(name, widths[name])
                end
                table.insert(instances, { instance_name = instname, ref_name = name, net_conn = ct, width = widths[name] })
            end
        end
    end
    local positions = placer.place(nets, instances)
    for name, position in pairs(positions) do
        print(name, position.x, position.y)
    end

    local path
    if prefix and prefix ~= "" then
        path = string.format("%s/%s", prefix, libname)
    else
        path = string.format("%s/%s", dirname, libname)
    end
    if not filesystem.exists(path) or overwrite then
        local created = filesystem.mkdir(path)
        if created then
            local file = io.open(filename, "r")
            if not file then
                moderror(string.format("generator.verilog_routing: could not open file '%s'", filename))
            end
            local content = file:read("a")
            local tree = verilog_parser.parse(content)
            _generate_from_ast(string.format("%s/%s", prefix, libname), tree, positions, noconnections)
        else
            moderror(string.format("generator.verilog_routing: could not create directory '%s/%s'", prefix, libname))
        end
    end
end

return M
