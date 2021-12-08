local M = {}

function M.from_verilog(filename, noconnections, prefix, libname, overwrite, stdlibname, utilization, aspectratio, movespercell, coolingfactor, excluded_nets, report)
    local file = io.open(filename, "r")
    if not file then
        moderror(string.format("generator.verilog_routing: could not open file '%s'", filename))
    end
    local str = file:read("a")
    local content = verilog_parser.parse(str)

    -- calculate cell pitch and height
    local references = {}
    local cellpitch, cellheight
    for module in content.modules() do
        for cellname in module:references() do
            if not references[cellname] then
                local p = string.format("%s/%s", stdlibname, cellname)
                local cell = pcell.create_layout(p)
                local width, height = cell:width_height_alignmentbox()
                references[cellname] = { width = width, height = height }
            end
            local width, height = references[cellname].width, references[cellname].height
            -- width (GCD of all widths)
            if not cellpitch then
                cellpitch = width
            else
                while width > 0 do
                    cellpitch, width = width, (cellpitch % width)
                end
            end
            -- height (height of any cell, but they all must be equal)
            if not cellheight then
                cellheight = height
            else
                if cellheight ~= height then
                    moderror("cellheight must be equal for all cells")
                end
            end
        end
    end

    -- calculate total width and core area
    local total_width = 0
    local required_width = 0
    local area = 0
    for module in content:modules() do
        for instance in module:instances() do
            local width, height = references[instance.reference].width, references[instance.reference].height
            area = area + width * height
            --area = area + width / cellpitch -- normalized height of all cells is 1
            total_width = total_width + width / cellpitch
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
            table.insert(instances, { 
                instance_name = instance.name, 
                ref_name = instance.reference, 
                net_conn = ct, 
                width = references[instance.reference].width / cellpitch
            })
        end
    end
    local floorplan_width = math.sqrt(area / utilization * aspectratio)
    local floorplan_height = math.sqrt(area / utilization / aspectratio)

    -- check for too narrow floorplan
    if floorplan_width < required_width then
        floorplan_width = required_width / math.sqrt(utilization)
        floorplan_height = area / utilization / floorplan_width
        print("floorplan width is smaller than required with, this will be fixed. The aspect ratio won't be es specified")
        print(string.format("new aspect ratio is %.2f", floorplan_width / floorplan_height))
    end

    -- normalize
    floorplan_width = math.ceil(floorplan_width / cellpitch)
    floorplan_height = math.ceil(floorplan_height / cellheight)

    local options = {
        floorplan_width = floorplan_width,
        floorplan_height = floorplan_height,
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
        moderror("desired row width must be smaller than floorplan width")
    end

    local rows = placer.place(nets, instances, options)

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
                local references = {}
                print(string.format("writing to file '%s/%s.lua'", basename, module.name))
                local file = io.open(string.format("%s/%s.lua", basename, module.name), "w")
                file:write("function parameters()\nend\n\n")
                file:write("function layout(toplevel)\n")
                file:write('    local references = {\n')
                for cellname in module:references() do
                    if not references[cellname] then
                        references[cellname] = true
                        file:write(string.format('        ["%s"] = pcell.add_cell_reference(pcell.create_layout("GF22FDX_SC8T_104CPP_BASE_CSC20SL/%s"), "%s"),\n', cellname, cellname, cellname))
                    end
                end
                file:write('    }\n')
                file:write('    local rows = {\n')
                for _, row in ipairs(rows) do
                    file:write('        {\n')
                    for _, column in ipairs(row) do
                        file:write(string.format('            references["%s"],\n', column))
                    end
                    file:write('        },\n')
                end
                file:write('    }\n')
                file:write('    local fillers = {\n')
                file:write('        pcell.add_cell_reference(pcell.create_layout("GF22FDX_SC8T_104CPP_BASE_CSC20SL/FILLX1"), "FILLX1"),\n')
                file:write('        pcell.add_cell_reference(pcell.create_layout("GF22FDX_SC8T_104CPP_BASE_CSC20SL/FILLX2"), "FILLX2"),\n')
                file:write('        pcell.add_cell_reference(pcell.create_layout("GF22FDX_SC8T_104CPP_BASE_CSC20SL/FILLX3"), "FILLX3"),\n')
                file:write('        pcell.add_cell_reference(pcell.create_layout("GF22FDX_SC8T_104CPP_BASE_CSC20SL/FILLX4"), "FILLX4"),\n')
                file:write('        pcell.add_cell_reference(pcell.create_layout("GF22FDX_SC8T_104CPP_BASE_CSC20SL/FILLX5"), "FILLX5"),\n')
                file:write('        nil,\n')
                file:write('        nil,\n')
                file:write('        pcell.add_cell_reference(pcell.create_layout("GF22FDX_SC8T_104CPP_BASE_CSC20SL/FILLX8"), "FILLX8"),\n')
                file:write('    }\n')
                file:write(string.format('    placement.digital(toplevel, %d, %d, rows, fillers, %f)\n',
                    cellpitch,
                    (floorplan_width + 1) * cellpitch,
                    utilization
                ))
                file:write("end")
                file:close()
            end
        else
            moderror(string.format("generator.verilog_routing: could not create directory '%s/%s'", prefix, libname))
        end
    end
end

return M
