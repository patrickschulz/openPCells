local M = {}

local function _prepare_routing_nets(nets, rows)
    local netpositions = {}
    for i, net in ipairs(nets) do
        for r, row in ipairs(rows) do
            for c, column in ipairs(row) do
                if column.nets then
                    for _, n in ipairs(column.nets) do
                        if net == n.name then
                            if not netpositions[i] then
                                netpositions[i] = { name = net, positions = {} }
                            end
                            local offset = column.pinoffsets[n.port]
                            if not offset then
                                error(string.format("cell '%s' has no pin offset data on port '%s'", column.reference, n.port))
                            end
                            table.insert(netpositions[i].positions, { instance = column.instance, port = n.port, x = c + offset.x, y = r + offset.y })
                        end
                    end
                end
            end
        end
    end
    return netpositions
end

function M.legalize(nets, rows, options)
    local netpositions = _prepare_routing_nets(nets, rows)
    for _, pos in ipairs(netpositions) do
        print(pos.name)
        for _, p in ipairs(pos.positions) do
            print(string.format("x = %d, y = %d (instance: '%s', port: '%s')", p.x, p.y, p.instance, p.port))
        end
        print()
    end
    -- call router here
    local routednets, numroutednets = router.route(netpositions,
        options.floorplan_width, options.floorplan_height)
    return routednets
end

function M.route(cell, routes, cells, width, xgrid, ygrid)
    local xgrid = xgrid or 1
    local ygrid = ygrid or 1
    for r, route in ipairs(routes) do
        if not (route[1].type == "anchor" or route[1].type == "point") then
            moderror(string.format("routing.route: route #%d: first movement needs to be of type 'anchor' or 'point'", r))
        end
        local startpt
        if route[1].type == "anchor" then
            startpt = cells[route[1].name]:get_anchor(route[1].anchor)
        else
            startpt = route[1].where
        end
        local pts = {}
        local currmetal = route.startmetal or 1
        local x, y = startpt:unwrap()
        for i = 2, #route do
            local movement = route[i]
            if movement.type == "point" then
                local pt = movement.where
                x, y = pt:unwrap()
                table.insert(pts, pt)
            elseif movement.type == "anchor" then
                local pt = cells[movement.name]:get_anchor(movement.anchor)
                x, y = pt:unwrap()
                table.insert(pts, pt)
            elseif movement.type == "switchdirection" then
                table.insert(pts, 0)
            elseif movement.type == "delta" then
                if movement.x and movement.y then
                    table.insert(pts, xgrid * movement.x)
                    table.insert(pts, ygrid * movement.y)
                elseif movement.x then
                    table.insert(pts, xgrid * movement.x)
                elseif movement.y then
                    table.insert(pts, 0)
                    table.insert(pts, ygrid * movement.y)
                end
                x = x + xgrid * (movement.x or 0)
                y = y + ygrid * (movement.y or 0)
            elseif movement.type == "via" then
                if movement.z then
                    geometry.via(cell, currmetal, currmetal + movement.z, width, width, x, y)
                    if #pts > 0 then
                        geometry.path(cell, generics.metal(currmetal), 
                            geometry.path_points_xy(startpt, pts), width)
                    end
                    startpt = point.create(x, y)
                    pts = {}
                    currmetal = currmetal + movement.z
                else
                    geometry.via(cell, currmetal, movement.metal, width, width, x, y)
                    if #pts > 0 then
                        geometry.path(cell, generics.metal(currmetal), 
                            geometry.path_points_xy(startpt, pts), width)
                    end
                    startpt = point.create(x, y)
                    pts = {}
                    currmetal = movement.metal
                end
            else
                error(string.format("routing.route: unknown movement type '%s'", movement.type))
            end
        end
        if #pts > 0 then
            geometry.path(cell, generics.metal(currmetal), 
                geometry.path_points_xy(startpt, pts), width)
        end
    end
end

return M
