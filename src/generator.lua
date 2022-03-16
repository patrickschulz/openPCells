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
                        print("instance", instlookup[column.instance])
                        table.insert(netpositions[name], { x = c + offset, y = r, z = 0, port = n.port, instance = instlookup[column.instance] })
                    end
                end
            end
        end
    end
    return netpositions, numnets
end

local function _write_module(rows, nets, rowwidth, instlookup, reflookup,
        routednets, numroutednets)
    local lines = {}

    table.insert(lines, 'function parameters()')
    table.insert(lines, '    pcell.reference_cell("stdcells/base")')
    table.insert(lines, 'end')
    table.insert(lines, '')

    table.insert(lines, 'function layout(toplevel)')

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
    table.insert(lines, '')

    -- get base gatepitch and ypitch
    table.insert(lines, '    local bp = pcell.get_parameters("stdcells/base")')
    table.insert(lines, '    local xpitch = bp.glength + bp.gspace')
    table.insert(lines, '    local ypitch = bp.pwidth + bp.nwidth + bp.powerwidth + 2 * bp.powerspace + bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace -- ypitch')
    table.insert(lines, '')
    table.insert(lines, "    local routes = {")

    -- routed nets
    local netname
    local startinstance
    local startport
    for i, net in ipairs(routednets) do

        local xdist = 0
        local ydist = 0
        -- start at metal 3
        local currmetal = 3
        local x = 0
        local y = 0
        local z = 0
        local xpre = 0
        local ypre = 0

        for j, entry in ipairs(net) do
                if j == 1 then
                        -- put name of net into file as a comment
                        netname = entry
                        startinstance = net["firstinstance"]
                        startport = net["firstport"]
                        table.insert(lines, "        {")
                        table.insert(lines, "            endpoints = {")
                        table.insert(lines, string.format('                { cellname = "%s", anchor = "%s" },', startinstance, startport))
                        table.insert(lines, "            },")
                        table.insert(lines, "            deltas = {")
                else
                        xpre = x
                        ypre = y

                        -- reverse coordinates because of backtrace
                        x = entry[1] * -1
                        y = entry[2] * -1
                        z = entry[3] * -1

                        xdist = xdist + x
                        ydist = ydist + y

                        -- generate deltas
                        if xpre ~= x and ypre ~= y then
                              table.insert(lines, string.format('                { x = %i * xpitch, y = %i * ypitch, metal = %i },',
                                xdist - x, ydist - y, currmetal))
                        end

                        -- generate vias
                        if z == -1 then
                              table.insert(lines, string.format('                { x = %i * xpitch, y = %i * ypitch, isvia = true, from = %i, to = %i, metal = %i},',
                                xdist - x, ydist - y, currmetal + z, currmetal, currmetal))
                            currmetal = currmetal + z
                        elseif z == 1 then
                              table.insert(lines, string.format('                { x = %i * xpitch, y = %i * ypitch, isvia = true, from = %i, to = %i, metal = %i},',
                                xdist - x, ydist - y, currmetal, currmetal + z, currmetal))
                            currmetal = currmetal + z
                        end
                end
        end
          table.insert(lines, string.format('                { x = %i * xpitch, y = %i * ypitch, metal = %i },',
            xdist, ydist, currmetal))
        table.insert(lines, '            },')
        table.insert(lines, '        },')
    end
    table.insert(lines, '    }')

    table.insert(lines, '    routingwidth = 100')
    table.insert(lines, '    routing.route(toplevel, routes, cells, routingwidth)')

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
    local netpositions, numnets = _prepare_routing_nets(nets, rows, instlookup, reflookup)


    for name, net in pairs(netpositions) do
        print(name)
        for i, pt in ipairs(net) do
            print(string.format("coord %i: %i %i %i", i, pt.x, pt.y, pt.z))
        end
    end
    print(string.format("width: %u, height: %u", options.floorplan_width,
        options.floorplan_height))

    local routednets, numroutednets = router.route(netpositions, numnets, options.floorplan_width,
        options.floorplan_height)

    return {
        content = content,
        width = options.floorplan_width,
        instlookup = instlookup,
        reflookup = reflookup,
        rows = rows,
        nets = nets,
        routednets = routednets,
        numroutednets = numroutednets,
    }
end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))
    else
      print(formatting .. v)
    end
  end
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
        local lines = _write_module(content.rows, content.nets, content.width, content.instlookup, content.reflookup,
        content.routednets, content.numroutednets)
        print(string.format("writing to file '%s/%s.lua'", basename, module.name))
        local file = io.open(string.format("%s/%s.lua", basename, module.name), "w")
        file:write(table.concat(lines, '\n'))
        file:close()
    end
end

return M
