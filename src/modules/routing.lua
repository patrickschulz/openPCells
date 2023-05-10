local M = {}

local function _get_blockages(instances, reference)
    for i, instance in ipairs(instances) do
        if instance.reference == reference then
            return instance.blockages
        end
    end
    return nil
end

local function _prepare_routing_nets(nets, rows, numinnerroutes, pnumtracks, nnumtracks, instances)
    local netpositions = {}
    local blockages = {}
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
                            local flip = (r - 1) % 2 == 0 and 1 or -1
                            if not offset then
                                error(string.format("cell '%s' has no pin offset data on port '%s'", column.reference, n.port))
                            end
                            table.insert(netpositions[i].positions, {
                                instance = column.instance,
                                port = n.port,
                                x = math.floor(curwidth + offset.x + 1),
                                y = math.floor((r - 1) * (nnumtracks + pnumtracks + numinnerroutes) + flip * offset.y + ((nnumtracks + pnumtracks + numinnerroutes) - 1) / 2 + (r - 1)),
                                row = r
                            })
                            -- calc blockage coordinates
                            local blockblockages = _get_blockages(instances, column.reference)
                            if blockblockages then
                                for h, blockageroute in ipairs(blockblockages) do
                                    route = {}
                                    for u, delta in ipairs(blockageroute) do
                                        table.insert(route, {
                                            -- x = c + blockageroute[u].x + curwidth,
                                            -- FIXME: doesnt work with assymetric track numbers
                                            x = curwidth + blockageroute[u].x + 1,
                                            y = (r - 1) * (nnumtracks + pnumtracks + numinnerroutes) + flip * blockageroute[u].y + ((nnumtracks + pnumtracks + numinnerroutes) - 1) / 2 + (r - 1),
                                            z = blockageroute[u].z,
                                            row = r
                                        })
                                    end
                                    table.insert(blockages, route)
                                end
                            end
                        end
                    end
                end
                curwidth = curwidth + column.width
            end
        end
    end
    return netpositions, blockages
end

function M.legalize(nets, rows, numinnerroutes, pnumtracks, nnumtracks, floorplan, instances)
    local netpositions, blockages = _prepare_routing_nets(nets, rows, numinnerroutes, pnumtracks, nnumtracks, instances)
    -- call router here
    -- per full row insert one powerrail (except for the first row)
    local height = floorplan.floorplan_height * (pnumtracks + nnumtracks + numinnerroutes)
    height = height + math.floor(height / (pnumtracks + nnumtracks + numinnerroutes)) - 1
    print(floorplan.floorplan_height)

    local routednets, numroutednets = router.route(netpositions, blockages, floorplan.floorplan_width, height)
    return routednets
end

local function _finish_route_path(cell, pts, currmetal, width)
    if #pts > 1 and (pts[1] ~= pts[2]) then
        geometry.path(cell, generics.metal(currmetal), pts, width)
    end
    -- clear pts
    for i = 1, #pts do
        pts[i] = nil
    end
end

local function _insert_or_update(cell, currmetal, pts, x, y, width, draw)
    if draw then
        table.insert(pts, point.create(x, y))
    else
        _finish_route_path(cell, pts, currmetal, width)
        pts[1] = point.create(x, y)
    end
end

function M.route(cell, routes, width, numinnerroutes, pnumtracks, nnumtracks, xgrid, ygrid)
    if not xgrid then
        moderror("routing.route: 'xgrid' must be given")
    end
    if not ygrid then
        moderror("routing.route: 'ygrid' must be given")
    end
    for r, route in ipairs(routes) do
        if not (route[1].type == "anchor" or route[1].type == "point") then
            moderror(string.format("routing.route: route #%d: first movement needs to be of type 'anchor' or 'point'", r))
        end
        local startpt = route[1].where
        local pts = { startpt }
        local currmetal = route.startmetal or 1
        for i = 2, #route do
            local movement = route[i]
            if movement.type == "point" then
                local x, y = movement.where:unwrap()
                _insert_or_update(cell, currmetal, pts, x, y, width, not movement.nodraw)
            elseif movement.type == "delta" then
                if movement.x and movement.y then
                    error("routing delta movement must not specify both x and y")
                end
                local lastpt = pts[#pts]
                local x, y = lastpt:unwrap()
                x = x + xgrid * (movement.x or 0)
                y = y + ygrid * (movement.y or 0)
                _insert_or_update(cell, currmetal, pts, x, y, width, not movement.nodraw)
            elseif movement.type == "rowshift" then
                local lastpt = pts[#pts]
                local x, y = lastpt:unwrap()
                local yoffset = (nnumtracks + numinnerroutes / 2) * ygrid
                local rowheight = ygrid * (pnumtracks + nnumtracks + numinnerroutes + 1)
                local currentrow = math.ceil((y + yoffset) / rowheight)
                local updown = movement.rows < 0 and -1 or 1
                local steps = math.abs(movement.rows)
                local target = y
                while steps > 1 do
                    target = target + updown * ygrid * 2 * (pnumtracks + 1 + nnumtracks + numinnerroutes)
                    steps = steps - 2
                end
                if steps > 0 then
                    local shift
                    if ((currentrow % 2 == 0) and (updown < 0)) or ((currentrow % 2 == 1) and (updown > 0)) then
                        shift = pnumtracks
                    else
                        shift = nnumtracks
                    end
                    target = target + ygrid * updown * (2 * shift + 1 + numinnerroutes)
                end
                target = target + ygrid * (movement.offset or 0)
                _insert_or_update(cell, currmetal, pts, x, target, width, not movement.nodraw)
            elseif movement.type == "via" then
                local targetmetal
                if movement.z then
                    targetmetal = currmetal + movement.z
                else
                    targetmetal = movement.metal
                end
                local lastpt = pts[#pts]
                local x, y = lastpt:unwrap()
                if not movement.nodraw then
                    geometry.viabltr(cell, currmetal, targetmetal, 
                        point.create(x - width / 2, y - width / 2),
                        point.create(x + width / 2, y + width / 2)
                    )
                end
                _finish_route_path(cell, pts, currmetal, width)
                pts[1] = lastpt
                currmetal = targetmetal
            else
                error(string.format("routing.route: unknown movement type '%s'", movement.type))
            end
        end
        -- draw remaining points
        _finish_route_path(cell, pts, currmetal, width)
    end
end

return M
