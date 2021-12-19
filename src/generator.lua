local M = {}

local function _map_cellname(cellname)
    local lut = {
        opcinv = "not_gate",
        opcnand = "nand_gate",
        opcnor = "nor_gate",
        opcxor = "xor_gate",
        opcxnor = "xor_gate", -- FIXME
        opcdffq = "dff",
        opcdffnq = "dff", -- FIXME (needs layout options)
    }
    return lut[cellname]
end

local function _get_cell_width(name)
    local lut = {
        opcinv = 1,
        opcnand = 2,
        opcnor = 2,
        opcxor = 10,
        opcxnor = 11,
        opcdffq = 21,
        opcdffnq = 24,
    }
    if not lut[name] then
        moderror(string.format("unknown stdcell '%s'", name))
    end
    return lut[name]
end

function M.from_verilog(filename, noconnections, prefix, libname, overwrite, stdlibname, utilization, aspectratio, movespercell, coolingfactor, excluded_nets, report)
    local file = io.open(filename, "r")
    if not file then
        moderror(string.format("generator.verilog_routing: could not open file '%s'", filename))
    end
    local str = file:read("a")
    local content = verilog_parser.parse(str)

    -- calculate total width and core area
    local total_width = 0
    local required_width = 0
    local area = 0
    local height = 7
    for module in content:modules() do
        for instance in module:instances() do
            local width = _get_cell_width(instance.reference)
            area = area + width * height
            total_width = total_width + width
            required_width = math.max(required_width, width)
        end
    end

    local nets = { set = {} }
    local instances = {}
    for module in content:modules() do
        for instance in module:instances() do
            local ct = {}
            for _, c in ipairs(instance.connections) do
                if not aux.any_of(function(v) return v == c.net end, excluded_nets) then
                    if not nets.set[c.net] then
                        table.insert(nets, c.net)
                        nets.set[c.net] = {}
                    end
                    table.insert(nets.set[c.net], { instance = instance.name, port = c.port })
                    for i, net in ipairs(nets) do
                        if c.net == net then
                            table.insert(ct, i)
                            break
                        end
                    end
                end
            end
            table.insert(instances, { 
                instance_name = instance.name, 
                reference_name = instance.reference, 
                net_conn = ct, 
                width = _get_cell_width(instance.reference)
            })
        end
    end

    local fixedrows = 4
    local floorplan_width, floorplan_height
    if fixedrows then
        floorplan_height = fixedrows
        floorplan_width = total_width / utilization / fixedrows
    else
        floorplan_width = math.sqrt(area / utilization * aspectratio)
        floorplan_height = math.sqrt(area / utilization / aspectratio)

        -- check for too narrow floorplan
        if floorplan_width < required_width then
            floorplan_width = required_width / math.sqrt(utilization)
            floorplan_height = area / utilization / floorplan_width
            print("Floorplan width is smaller than required width, this will be fixed.")
            print(string.format("The actual aspect ratio (%.2f) will differ from the specified aspect ratio (%.2f)", floorplan_width / floorplan_height, aspectratio))
        end

        -- normalize
        floorplan_height = math.ceil(floorplan_height / height)
    end

    local options = {
        floorplan_width = math.ceil(floorplan_width),
        floorplan_height = math.ceil(floorplan_height),
        desired_row_width = math.ceil(total_width / floorplan_height * utilization),
        movespercell = movespercell,
        coolingfactor = coolingfactor,
        report = report
    }

    -- check floorplan options
    if options.floorplan_width == 0 then
        moderror("floorplan width is zero")
    end
    if options.floorplan_height == 0 then
        moderror("floorplan height is zero")
    end
    if options.desired_row_width == 0 then
        moderror("desired row width is zero")
    end
    if options.desired_row_width >= options.floorplan_width then
        --moderror("desired row width must be smaller than floorplan width")
    end

    local rows = placer.place(nets, instances, options)

    -- clean up (FIXME: this should not be necessary, if the placement did not leave empty rows)
    for i = #rows, 1, -1 do
        if #(rows[i]) == 0 then
            table.remove(rows, i)
        end
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
            local basename = string.format("%s/%s", prefix, libname)
            for module in content:modules() do
                print(string.format("writing to file '%s/%s.lua'", basename, module.name))
                local file = io.open(string.format("%s/%s.lua", basename, module.name), "w")
                file:write("function parameters()\nend\n\n")
                file:write("function layout(toplevel)\n")
                file:write('    local rows = {\n')
                for _, row in ipairs(rows) do
                    file:write('        {\n')
                    for _, column in ipairs(row) do
                        file:write(string.format('            { instance = "%s", reference = "%s" },\n', column.instance, _map_cellname(column.reference)))
                    end
                    file:write('        },\n')
                end
                file:write('    }\n')
                local cellpitch = 130
                file:write(string.format('    local cells = placement.digital(toplevel, %d, rows, %f)\n',
                    options.floorplan_width,
                    utilization
                ))
                for name, net in pairs(nets.set) do
                    if #net > 1 then
                        file:write("    toplevel:merge_into_shallow(geometry.path(generics.metal(3), {\n")
                        for _, n in pairs(net) do
                            file:write(string.format('        cells["%s"]:get_anchor("%s"),\n', n.instance, n.port))
                        end
                        file:write("    }, 100))\n")
                    end
                end
                file:write("end")
                file:close()
            end
        else
            moderror(string.format("generator.verilog_routing: could not create directory '%s/%s'", prefix, libname))
        end
    end
end

return M
