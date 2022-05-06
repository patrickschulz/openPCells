local M = {}

local function _prepare_routing_nets(nets, rows, numtracks)
    local netpositions = {}
    for i, net in ipairs(nets) do
        for r, row in ipairs(rows) do
            local curwidth = 0
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
                            table.insert(netpositions[i].positions, { instance = column.instance, port = n.port, x = c + offset.x + curwidth, y = r * numtracks + offset.y - (numtracks  - 1) // 2 })
                        end
                    end
                end
                curwidth = curwidth + column.width - 1
            end
        end
    end
    return netpositions
end

function M.legalize(nets, rows, numtracks, floorplan)
    local netpositions = _prepare_routing_nets(nets, rows, numtracks)
    for _, pos in ipairs(netpositions) do
        print(pos.name)
        for _, p in ipairs(pos.positions) do
            print(string.format("x = %d, y = %d (instance: '%s', port: '%s')", p.x, p.y, p.instance, p.port))
        end
        print()
    end
    -- call router here
    local routednets, numroutednets = router.route(netpositions,
        floorplan.floorplan_width, floorplan.floorplan_height * numtracks)
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
        local pts = { startpt }
        local currmetal = route.startmetal or 1
        for i = 2, #route do
            local movement = route[i]
            if movement.type == "point" then
                table.insert(pts, movement.where)
            elseif movement.type == "anchor" then
                local pt = cells[movement.name]:get_anchor(movement.anchor)
                table.insert(pts, pt)
<<<<<<< HEAD
            elseif movement.type == "switchdirection" then
                -- FIXME: remove this elseif in the future
                --error("routing: use of deprecated movement 'switchdirection'")
                --table.insert(pts, 0)
=======
>>>>>>> 2e57e77f47857b8c9a618f1086e211a629541c6c
            elseif movement.type == "delta" then
                local lastpt = pts[#pts]
                local x, y = lastpt:unwrap()
                if movement.x and movement.y then
                    error("routing movement must not specify both x and y")
                elseif movement.x then
                    table.insert(pts, point.create(
                        x + xgrid * movement.x,
<<<<<<< HEAD
                        pts[#pts]:gety()
                    ))
                    x = x + xgrid * movement.x
                elseif movement.y then
                    table.insert(pts, point.create(
                        pts[#pts]:getx(),
                        y + ygrid * movement.y
                    ))
                    y = y + ygrid * movement.y
=======
                        y
                    ))
                elseif movement.y then
                    table.insert(pts, point.create(
                        x,
                        y + ygrid * movement.y
                    ))
>>>>>>> 2e57e77f47857b8c9a618f1086e211a629541c6c
                end
            elseif movement.type == "via" then
                local targetmetal
                if movement.z then
<<<<<<< HEAD
                    geometry.via(cell, currmetal, currmetal + movement.z, width, width, x, y)
                    if #pts > 0 then
                        geometry.path(cell, generics.metal(currmetal), pts,
                            width)
                    end
                    startpt = point.create(x, y)
                    pts = { startpt }
                    currmetal = currmetal + movement.z
                else
                    geometry.via(cell, currmetal, movement.metal, width, width, x, y)
                    if #pts > 0 then
                        geometry.path(cell, generics.metal(currmetal), pts,
                            width)
                    end
                    startpt = point.create(x, y)
                    pts = { startpt }
                    currmetal = movement.metal
=======
                    targetmetal = currmetal + movement.z
                else
                    targetmetal = movement.metal
>>>>>>> 2e57e77f47857b8c9a618f1086e211a629541c6c
                end
                local lastpt = pts[#pts]
                local x, y = lastpt:unwrap()
                geometry.via(cell, currmetal, targetmetal, width, width, x, y)
                if #pts > 0 then
                    geometry.path(cell, generics.metal(currmetal), pts, width)
                end
                pts = { lastpt }
                currmetal = targetmetal
            else
                error(string.format("routing.route: unknown movement type '%s'", movement.type))
            end
        end
        if #pts > 0 then
            geometry.path(cell, generics.metal(currmetal), pts, width)
        end
    end
end

return M
