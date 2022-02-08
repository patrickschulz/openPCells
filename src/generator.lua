local M = {}

local function _map_cellname(cellname)
    local lut = {
        opcinv = "not_gate",
        opcnand = "nand_gate",
        opcnor = "nor_gate",
        opcxor = "xor_gate",
        opcxnor = "xor_gate", -- FIXME
        opcdffq = "dffp",
        opcdffnq = "dffn",
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

local function _get_pin_offset(name, port)
    local lut = {
        opcinv = { I = 0, O = 1 },
        opcnand = { A = 0, B = 1, O = 2 },
        opcnor = { A = 0, B = 1, O = 2 },
        opcxor = { A = 0, B = 1, O = 10 },
        opcxnor = { A = 0, B = 1, O = 10 },
        opcdffq = { CLK = 0, D = 0, Q = 20, },
        opcdffnq = { CLK = 0, D = 0, Q = 20, },
    }
    if not lut[name] then
        moderror(string.format("unknown stdcell '%s'", name))
    end
    if not lut[name][port] then
        moderror(string.format("unknown port '%s' for stdcell '%s'", port, name))
    end
    return lut[name][port]
end

local function _get_geometry(content)
    local total_width = 0
    local required_width = 0
    for module in content:modules() do
        for instance in module:instances() do
            -- calculate total width
            local width = _get_cell_width(instance.reference)
            total_width = total_width + width
            required_width = math.max(required_width, width)
        end
    end
    return required_width, total_width
end

local function _collect_nets_cells(content, excluded_nets)
    local maxnet = 0
    local nets = {}
    local instances = {}
    local reflookup = {}
    local instlookup = {}
    local maxrefnum = 0
    local maxinstnum = 0
    for module in content:modules() do
        for instance in module:instances() do
            -- create reference index
            if not reflookup[instance.reference] then 
                -- store regular and inverse pair
                -- since instance.reference is a string and maxrefnum an integer, these should never collide
                reflookup[instance.reference] = maxrefnum
                reflookup[maxrefnum] = instance.reference
                maxrefnum = maxrefnum + 1
            end

            -- create nets
            local ct = {}
            local po = {}
            for _, c in ipairs(instance.connections) do
                if (not aux.any_of(function(v) return v == c.net end, module:get_ports())) and
                   (not aux.any_of(function(v) return v == c.net end, excluded_nets)) then
                    if not nets[c.net] then
                        nets[c.net] = { index = maxnet, connections = {} }
                        maxnet = maxnet + 1
                    end
                    table.insert(nets[c.net].connections, { instance = instance.name, port = c.port })
                    table.insert(ct, { index = nets[c.net].index + 1, pinoffset = _get_pin_offset(instance.reference, c.port) })
                end
            end
            -- store regular and inverse pair
            -- since instance.reference is a string and maxrefnum an integer, these should never collide
            instlookup[instance.name] = maxinstnum
            instlookup[maxinstnum] = instance.name
            maxinstnum = maxinstnum + 1
            table.insert(instances, { 
                instance = instlookup[instance.name], 
                reference = reflookup[instance.reference],
                nets = ct, 
                pin_offsets = po,
                width = _get_cell_width(instance.reference)
            })
        end
    end
    return maxnet, instances, nets, instlookup, reflookup
end

local function _prepare_routing_nets(nets, rows, instlookup, reflookup)
    local netpositions = {}
    local numnets = 0
    for name, net in pairs(nets) do
        for _, n in pairs(net.connections) do
            for r, row in ipairs(rows) do
                for c, column in ipairs(row) do
                    if instlookup[column.instance] == n.instance then
                        if not netpositions[name] then
                            netpositions[name] = {}
                            numnets = numnets + 1
                        end
                        local offset = _get_pin_offset(reflookup[column.reference], n.port)
                        table.insert(netpositions[name], { x = c + offset, y = r })
                    end
                end
            end
        end
    end
    return netpositions, numnets
end

local function _write_module(rows, nets, rowwidth, instlookup, reflookup)
    local lines = {}
    table.insert(lines, "function layout(toplevel)")

    -- cellnames
    table.insert(lines, '    local cellnames = {')
    for _, row in ipairs(rows) do
        table.insert(lines, '        {')
        for _, column in ipairs(row) do
            table.insert(lines, string.format('            { instance = "%s", reference = "%s" },', 
                instlookup[column.instance], 
                _map_cellname(reflookup[column.reference])
            ))
        end
        table.insert(lines, '        },')
    end
    table.insert(lines, '    }')

    -- placement
    table.insert(lines, '    local rows = placement.create_reference_rows(cellnames)')
    table.insert(lines, string.format('    local cells = placement.digital(toplevel, rows, %d)',
        rowwidth
    ))

    -- nets
    for name, net in pairs(nets) do
        if #net.connections > 1 then
            table.insert(lines, "    toplevel:merge_into_shallow(geometry.path(generics.metal(3), {")
            for _, n in pairs(net.connections) do
                table.insert(lines, string.format('        cells["%s"]:get_anchor("%s"),', n.instance, n.port))
            end
            table.insert(lines, "    }, 100))")
        end
    end

    table.insert(lines, "end") -- close 'layout' function
    return lines
end

local function _create_options(fixedrows, required_width, total_width, utilization, aspectratio)
    local height = 7
    local area = total_width * height
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
        moderror("desired row width must be smaller than floorplan width")
    end
    return options
end

local function _read_parse_verilog(filename)
    local file = io.open(filename, "r")
    if not file then
        moderror(string.format("generator.from_verilog: could not open file '%s'", filename))
    end
    local str = file:read("a")
    local content = verilog_parser.parse(str)
    file:close()
    return content
end

function M.from_verilog(filename, utilization, aspectratio, excluded_nets, report)
    local content = _read_parse_verilog(filename)

    -- collect nets and cells
    local maxnet, instances, nets, instlookup, reflookup = _collect_nets_cells(content, excluded_nets)

    -- placer options
    local required_width, total_width = _get_geometry(content)
    local options = _create_options(fixedrows, required_width, total_width, utilization, aspectratio)

    -- run placement
    local rows = placer.place_simulated_annealing(maxnet, instances, options)

    -- run routing
    --local netpositions, numnets = _prepare_routing_nets(nets, rows, instlookup, reflookup)
    --router.route(netpositions, numnets)

    return {
        content = content,
        width = options.floorplan_width,
        instlookup = instlookup,
        reflookup = reflookup,
        rows = rows,
        nets = nets,
    }
end

function M.write_from_verilog(content, prefix, libname)
    local path
    if prefix and prefix ~= "" then
        path = string.format("%s/%s", prefix, libname)
    else
        path = string.format("%s/%s", dirname, libname)
    end
    if not filesystem.exists(path) then
        local created = filesystem.mkdir(path)
        if not created then
            moderror(string.format("generator.verilog_routing: could not create directory '%s/%s'", prefix, libname))
        end
    end
    local basename = string.format("%s/%s", prefix, libname)
    for module in content.content:modules() do
        local lines = _write_module(content.rows, content.nets, content.width, content.instlookup, content.reflookup)
        print(string.format("writing to file '%s/%s.lua'", basename, module.name))
        local file = io.open(string.format("%s/%s.lua", basename, module.name), "w")
        file:write(table.concat(lines, '\n'))
        file:close()
    end
end

return M
