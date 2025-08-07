local M = {}

local function _write_module(rows, routes, numinnerroutes, pnumtracks, nnumtracks)
    local lines = {}
    table.insert(lines, 'function layout(toplevel)')
    --[[
    table.insert(lines, '    pcell.push_overwrites("stdcells/base", {')
    table.insert(lines, string.format('        pnumtracks = %i,', pnumtracks))
    table.insert(lines, string.format('        nnumtracks = %i,', nnumtracks))
    table.insert(lines, string.format('        numinnerroutes= %i,', numinnerroutes))
    table.insert(lines, string.format('        drawtopbotwelltaps = %s,', 'false'))
    table.insert(lines, '    })')
    --]]

    -- placement
    if rows then
        table.insert(lines, '    local cellnames = {')
        for _, row in ipairs(rows) do
            table.insert(lines, '        {')
            for _, column in ipairs(row) do
                table.insert(lines, string.format('            { instance = "%s", reference = "stdcells/%s" },',
                column.instance,
                column.reference
                ))
            end
            table.insert(lines, '        },')
        end
        table.insert(lines, '    }')
        -- FIXME: remove hard-coded values (values are for opc tech)
        table.insert(lines, '    local baseopt = {')
        table.insert(lines, '        sdwidth = 200,')
        table.insert(lines, '        gatelength = 500,')
        table.insert(lines, '        gatespace = 320,')
        table.insert(lines, '        routingwidth = 200,')
        table.insert(lines, '        routingspace = 200,')
        table.insert(lines, '        pnumtracks = 3,')
        table.insert(lines, '        nnumtracks = 3,')
        table.insert(lines, '        numinnerroutes = 3,')
        table.insert(lines, '    }')
        table.insert(lines, '    local xpitch = 820')
        table.insert(lines, '    local rows = placement.create_reference_rows(cellnames, xpitch, baseopt)')
        table.insert(lines, string.format('    local cells = placement.rowwise(toplevel, rows)'))
    else
        print("no placement information found")
    end

    -- routes
    if routes then
        table.insert(lines, '    local routes = {')
        for _, route in ipairs(routes) do
            table.insert(lines, '        {')
            table.insert(lines, string.format('            name = "%s",', route.name))
            for _, moves in ipairs(route) do
                local entry = {}
                for k, v in pairs(moves) do
                    if k == "where" or k == "nodraw" then
                        table.insert(entry, string.format("%s = %s", k, v))
                    else
                        table.insert(entry, string.format("%s = %q", k, v))
                    end

                end
                table.insert(lines, string.format('            { %s },', table.concat(entry, ", ")))
            end
            table.insert(lines, '        },')
        end
        table.insert(lines, '    }')
        table.insert(lines, '    local width = 200 -- routingwidth')
        table.insert(lines, '    local xgrid = 500 + 320 -- gatelength + gatespace')
        table.insert(lines, '    local ygrid = 200 + 200 -- routingwidth + routingspace')
        table.insert(lines, '    local pnumtracks = 3')
        table.insert(lines, '    local nnumtracks = 3')
        table.insert(lines, '    local numinnerroutes = 3')
        table.insert(lines, string.format('    routing.route(toplevel, routes, width, numinnerroutes, pnumtracks, nnumtracks, xgrid, ygrid)'))
    else
        print("no routing information found")
    end

    table.insert(lines, "end") -- close 'layout' function
    return lines
end

function M.get_cell_filename(prefix, libname, cellname)
    if not prefix then
        moderror("generator.get_cell_filename: not path prefix specified")
    end
    if not libname then
        moderror("generator.get_cell_filename: not library name specified")
    end
    if not cellname then
        moderror("generator.get_cell_filename: not cell name specified")
    end
    local basename = string.format("%s/%s", prefix, libname)
    if not filesystem.exists(basename) then
        local created = filesystem.mkdir(basename)
        if not created then
            moderror(string.format("generator.get_cell_filename: could not create directory '%s/%s'", prefix, libname))
        end
    end
    return string.format("%s/%s.lua", basename, cellname)
end

function M.digital(file, rows, routes, numinnerroutes, pnumtracks, nnumtracks)
    local lines = _write_module(rows, routes, numinnerroutes, pnumtracks, nnumtracks)
    file:write(table.concat(lines, '\n'))
end

function M.analog(file, devices, nets)
    local lines = {}
    -- start cellscript
    table.insert(lines, "local cell = object.create(\"cell\")")
    -- device creation
    for _, device in ipairs(devices) do
        local paramt = {}
        for k, v in pairs(device.parameters) do
            table.insert(paramt, string.format("%s = %s", k, v))
        end
        local fmt = "local %s = pcell.create_layout(\"basic/mosfet\", \"_%s\", {%s})"
        table.insert(lines, string.format(fmt, device.name, device.name, table.concat(paramt, ", ")))
    end
    -- placement
    for i, device in ipairs(devices) do
        if i ~= 1 then
            table.insert(lines, string.format("%s:place_top(%s)", device.name, devices[i - 1].name))
            table.insert(lines, string.format("%s:align_center_x(%s)", device.name, devices[i - 1].name))
        end
    end
    -- merging
    for _, device in ipairs(devices) do
        table.insert(lines, string.format("cell:merge_into(%s)", device.name))
    end
    -- end cellscript
    table.insert(lines, "return cell")
    file:write(table.concat(lines, '\n'))
end

return M
