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

local function _section(lines, what)
    table.insert(lines, string.format("-- %s", what))
end

local function _newline(lines)
    table.insert(lines, "")
end

function M.analog(file, devices, placement, nets)
    local lines = {}
    -- start cellscript
    _section(lines, "top-level cell")
    table.insert(lines, "local cell = object.create(\"cell\")")
    -- device creation
    _newline(lines)
    _section(lines, "devices")
    for _, device in ipairs(devices) do
        table.insert(lines, "-- nets:")
        for k, v in pairs(device.connections) do
            table.insert(lines, string.format("--  %s = %s", k, v))
        end
        local paramt = {}
        for k, v in pairs(device.parameters) do
            if type(v) == "number" then
                table.insert(paramt, string.format("%s = %d", k, math.floor(v + 0.5)))
            else
                table.insert(paramt, string.format("%s = %q", k, v))
            end
        end
        local fmt = "local %s = pcell.create_layout(\"basic/mosfet\", \"_%s\", {\n    %s\n})"
        table.insert(lines, string.format(fmt, device.name, device.name, table.concat(paramt, ",\n    ")))
    end
    -- placement
    _newline(lines)
    _section(lines, "placement")
    table.insert(lines, "local placementskip = technology.get_optional_dimension(\"Placementskip\")")
    local group = stack.create()
    local allgroups = 0
    local groupcontent = stack.create()
    for _, entry in ipairs(placement) do
        if entry.what == "initial" then
            -- do nothing, initial placement can be anywhere
            -- FIXME: perhaps provide an option to specify placement?
            if groupcontent:peek() then
                table.insert(groupcontent:top(), entry.object)
            end
        elseif entry.what == "abut" then
            local x
            local y
            local xskip
            local yskip
            if entry.where == "top" then
                x = "align_center_x"
                y = "abut_top"
                xskip = "placementskip"
                yskip = "0"
            elseif entry.where == "bottom" then
                x = "align_center_x"
                y = "abut_bottom"
                xskip = "-placementskip"
                yskip = "0"
            elseif entry.where == "left" then
                x = "abut_left"
                y = "align_center_y"
                xskip = "0"
                yskip = "-placementskip"
            elseif entry.where == "right" then
                x = "abut_right"
                y = "align_center_y"
                xskip = "0"
                yskip = "placementskip"
            else
                error(string.format("generator.analog: placement entry has unknown 'where' type: '%s'", entry.where))
            end
            table.insert(lines, string.format("%s:%s(%s)", entry.object, x, entry.reference))
            table.insert(lines, string.format("%s:%s(%s)", entry.object, y, entry.reference))
            table.insert(lines, string.format("%s:translate(%s, %s)", entry.object, xskip, yskip))
            if groupcontent:peek() then
                table.insert(groupcontent:top(), entry.object)
            end
        elseif entry.what == "place" then
            local x
            local y
            if entry.where == "top" then
                x = "align_center_x"
                y = "place_top"
            elseif entry.where == "bottom" then
                x = "align_center_x"
                y = "place_bottom"
            elseif entry.where == "left" then
                x = "place_left"
                y = "align_center_y"
            elseif entry.where == "right" then
                x = "place_right"
                y = "align_center_y"
            else
                error(string.format("generator.analog: placement entry has unknown 'where' type: '%s'", entry.where))
            end
            table.insert(lines, string.format("%s:%s(%s)", entry.object, x, entry.reference))
            table.insert(lines, string.format("%s:%s(%s)", entry.object, y, entry.reference))
            if groupcontent:peek() then
                table.insert(groupcontent:top(), entry.object)
            end
        elseif entry.what == "startgroup" then
            allgroups = allgroups + 1
            group:push(string.format("ag%d", allgroups))
            table.insert(lines, string.format("local %s = alignmentgroup.create()", group:top()))
            groupcontent:push({})
        elseif entry.what == "endgroup" then
            local groupname = group:top()
            for _, member in ipairs(groupcontent:top()) do
                table.insert(lines, string.format("%s:add(%s)", groupname, member))
            end
            group:pop()
            groupcontent:pop()
            if groupcontent:peek() then
                table.insert(groupcontent:top(), groupname)
            end
        else
            error(string.format("generator.analog: placement entry has unknown 'what' type: '%s'", entry.what))
        end
    end
    -- placement for unspecified devices
    _newline(lines)
    _section(lines, "placement (unspecified devices)")
    do
        local lastdevice
        for _, device in ipairs(devices) do
            if lastdevice then
                table.insert(lines, string.format("%s:place_right(%s)", device.name, lastdevice.name))
                table.insert(lines, string.format("%s:translate(%s, %s)", device.name, "placementskip", 0))
            end
            lastdevice = device
        end
    end
    -- merging
    _newline(lines)
    _section(lines, "merging")
    for _, device in ipairs(devices) do
        table.insert(lines, string.format("cell:merge_into(%s)", device.name))
    end
    --[[
    for _, device in ipairs(devices) do
        table.insert(lines, string.format("cell:merge_into(%s)", device.name))
    end
    --]]
    _newline(lines)
    _section(lines, "routing")
    -- end cellscript
    _newline(lines)
    _section(lines, "final return")
    table.insert(lines, "return cell")
    file:write(table.concat(lines, '\n'))
end

return M
