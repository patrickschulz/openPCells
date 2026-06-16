local M = {}

local function _get_blockages(circuit, reference)
    for i, instance in ipairs(circuit.instances) do
        if instance.reference == reference then
            return instance.blockages
        end
    end
    return nil
end

local function _prepare_routing_nets(circuit, rows, numinnerroutes, pnumtracks, nnumtracks)
    local netpositions = {}
    local blockages = {}
    for i, net in ipairs(circuit.nets) do
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
                            local blockblockages = _get_blockages(circuit, column.reference)
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

    -- remove nets with only one port
    for i = #netpositions, 1, -1 do
        local pos = netpositions[i]
        if #pos.positions < 2 then
            table.remove(netpositions, i)
        end
    end
    return netpositions, blockages
end

function M.basic(circuit, rows, numinnerroutes, pnumtracks, nnumtracks, floorplan)
    local netpositions, blockages = _prepare_routing_nets(circuit, rows, numinnerroutes, pnumtracks, nnumtracks)
    -- call router here
    -- per full row insert one powerrail (except for the first row)
    local height = floorplan.floorplan_height * (pnumtracks + nnumtracks + numinnerroutes)
    height = height + math.floor(height / (pnumtracks + nnumtracks + numinnerroutes)) - 1

    local routerstate = router.initialize(netpositions, blockages, floorplan.floorplan_width, height)
    local routednets = router.resolve_routes(routerstate)
    return routednets
end

function M.legalize(circuit, rows, numinnerroutes, pnumtracks, nnumtracks, floorplan)
    local netpositions, blockages = _prepare_routing_nets(circuit, rows, numinnerroutes, pnumtracks, nnumtracks)
    -- call router here
    -- per full row insert one powerrail (except for the first row)
    local height = floorplan.floorplan_height * (pnumtracks + nnumtracks + numinnerroutes)
    height = height + math.floor(height / (pnumtracks + nnumtracks + numinnerroutes)) - 1

    local routerstate = router.initialize(netpositions, blockages, floorplan.floorplan_width, height)
    router.route(routerstate)
    local routednets = router.resolve_routes(routerstate)
    return routednets
end

local function _finish_route_path(state)
    if #state.current.pts > 1 and (state.current.pts[1] ~= state.current.pts[2]) then
        geometry.path(state.cell, generics.metal(state.current.metal), state.current.pts, state.width)
    end
    -- clear pts
    for i = 1, #state.current.pts do
        state.current.pts[i] = nil
    end
end

local function _insert_or_update(state, x, y)
    if state.current.movement.nodraw then
        _finish_route_path(state)
    end
    table.insert(state.current.pts, point.create(x, y))
end

local function _do_point(state)
    local x, y = state.current.movement.where:unwrap()
    _insert_or_update(state, x, y)
end

local function _do_delta(state)
    if state.current.movement.x and state.current.movement.y then
        error("routing delta movement must not specify both x and y")
    end
    local lastpt = state.current.pts[#state.current.pts]
    local x, y = lastpt:unwrap()
    x = x + state.grid.x * (state.current.movement.x or 0)
    y = y + state.grid.y * (state.current.movement.y or 0)
    _insert_or_update(state, x, y)
end

local function _do_rowshift(state)
    local lastpt = state.current.pts[#state.current.pts]
    local x, y = lastpt:unwrap()
    local yoffset = (state.nnumtracks + state.numinnerroutes / 2) * state.grid.y
    local rowheight = state.grid.y * (state.pnumtracks + state.nnumtracks + state.numinnerroutes + 1)
    local currentrow = math.ceil((y + yoffset) / rowheight)
    local updown = state.current.movement.rows < 0 and -1 or 1
    local steps = math.abs(state.current.movement.rows)
    local target = y
    while steps > 1 do
        target = target + updown * state.grid.y * 2 * (state.pnumtracks + 1 + state.nnumtracks + state.numinnerroutes)
        steps = steps - 2
    end
    if steps > 0 then
        local shift
        if ((currentrow % 2 == 0) and (updown < 0)) or ((currentrow % 2 == 1) and (updown > 0)) then
            shift = state.pnumtracks
        else
            shift = state.nnumtracks
        end
        target = target + state.grid.y * updown * (2 * shift + 1 + state.numinnerroutes)
    end
    target = target + state.grid.y * (state.current.movement.offset or 0)
    _insert_or_update(state, x, target)
end

local function _do_via(state)
    local targetmetal
    if state.current.movement.z then
        targetmetal = state.current.metal + state.current.movement.z
    else
        targetmetal = state.current.movement.metal
    end
    local lastpt = state.current.pts[#state.current.pts]
    local x, y = lastpt:unwrap()
    if not state.current.movement.nodraw then
        -- FIXME: should not be width / 2, but this is impossible with the current path-based router
        geometry.viabltr(state.cell, state.current.metal, targetmetal, 
            point.create(x - state.width / 2, y - state.width / 2),
            point.create(x + state.width / 2, y + state.width / 2)
        )
    end
    _finish_route_path(state)
    state.current.pts[1] = lastpt
    state.current.metal = targetmetal
end

function M.route(cell, routes, width, numinnerroutes, pnumtracks, nnumtracks, xgrid, ygrid)
    if not xgrid then
        moderror("routing.route: 'xgrid' must be given")
    end
    if not ygrid then
        moderror("routing.route: 'ygrid' must be given")
    end
    local state = {
        cell = cell,
        numinnerroutes = numinnerroutes,
        pnumtracks = pnumtracks,
        nnumtracks = nnumtracks,
        grid = {
            x = xgrid,
            y = ygrid,
        },
        width = width,
    }
    for r, route in ipairs(routes) do
        if not (route[1].type == "anchor" or route[1].type == "point") then
            moderror(string.format("routing.route: route #%d: first movement needs to be of type 'anchor' or 'point'", r))
        end
        state.current = {
            startpt = route[1].where,
            pts = { route[1].where },
            metal = route.startmetal or 1
        }
        for i = 2, #route do
            state.current.movement = route[i]
            if state.current.movement.type == "point" then
                _do_point(state)
            elseif state.current.movement.type == "delta" then
                _do_delta(state)
            elseif state.current.movement.type == "rowshift" then
                _do_rowshift(state)
            elseif state.current.movement.type == "via" then
                _do_via(state)
            else
                error(string.format("routing.route: unknown movement type '%s'", state.current.movement.type))
            end
        end
        -- draw remaining points
        _finish_route_path(state)
    end
end

function M.route_custom(cell, routes)
    for _, route in ipairs(routes) do
        geometry.path_3x(cell, generics.metal(route.startmetal), route.startpt, route.endpt, route.width, 0.5)
    end
end

local function _get_next_x(blocked_lines, xgrid)
    local row = blocked_lines[xgrid]
    local xline = 3
    while row[xline] do
        xline = xline + 1
    end
    row[xline] = true
    return xline
end

local function _get_next_y(blocked_lines, ygrid)
    local row = blocked_lines[ygrid]
    local yline = -1
    while row[yline] do
        yline = yline + 1
    end
    row[yline] = true
    return yline
end

local function _insert_horizontal_line(routes, net, blocked_lines, xgrid1, xgrid2, pin1, pin2, ygrid)
    local xlineend
    if xgrid1 == xgrid2 then
        --xlineend = _get_next_x(blocked_lines, xgrid1)
        xlineend = 3
    else
        xlineend = 2
    end
    local y = _get_next_y(blocked_lines, ygrid)
    table.insert(routes.horizontal, {
        net = net.net,
        xgridstart = xgrid1,
        xgridend = xgrid2,
        xlinestart = pin1,
        xlineend = pin2,
        ygrid = ygrid,
        yline = y,
    })
end

local function _insert_vertical_line(routes, net, blocked_lines, ygrid1, ygrid2, pin1, pin2, xgrid)
    local ylineend
    if ygrid1 == ygrid2 then
        --ylineend = _get_next_y(blocked_lines, ygrid1)
        ylineend = 3
    else
        ylineend = 2
    end
    local x = _get_next_x(blocked_lines, xgrid)
    table.insert(routes.vertical, {
        net = net.net,
        xgrid = xgrid,
        xline = x,
        ygridstart = ygrid1,
        ygridend = ygrid2,
        ylinestart = pin1,
        ylineend = pin2,
    })
end

-- FIXME: this is taken from analog/circuit, but this should be resolved in the cell, not here
local function _map_pin_index(pin)
    local map = { 
        bulk   = -2,
        source = -1,
        gate   = 1,
        drain  = 2,
    }
    return map[pin]
end

function M.route_analog(devices, places, dontroute)
    local routes = {
        horizontal = {},
        vertical = {},
    }
    local nets = {}
    for _, device in ipairs(devices) do
        for pin, net in pairs(device.connections) do
            if not util.any_of(net, dontroute or {}) then
                local _, entry = util.find_predicate(nets, function(entry) return entry.net == net end)
                if not entry then
                    entry = {
                        net = net,
                        devices = {}
                    }
                    table.insert(nets, entry)
                end
                table.insert(entry.devices, {
                    device = device,
                    pin = pin,
                })
            end
        end
    end
    for _, net in ipairs(nets) do
        print(net.net, #net.devices)
        for _, device in ipairs(net.devices) do
            print(device.device.name, device.pin)
        end
        print()
    end
    -- prepare blocked-line table
    local blocked_lines = {
        x = {},
        y = {}
    }
    local xmaxgrid = 0
    local ymaxgrid = 0
    for _, place in pairs(places) do
        xmaxgrid = math.max(xmaxgrid, place.x)
        ymaxgrid = math.max(ymaxgrid, place.y)
    end
    for x = 1, xmaxgrid do
        blocked_lines[x] = {}
    end
    for y = 1, ymaxgrid do
        blocked_lines[y] = {}
    end
    -- perform routing
    for _, net in ipairs(nets) do
        for i = 1, #net.devices - 1 do
            local device1 = net.devices[i].device
            local device2 = net.devices[i].device
            local p1 = places[device1.name]
            local p2 = places[device2.name]
            local pin1 = _map_pin_index(net.devices[i].pin)
            local pin2 = _map_pin_index(net.devices[i + 1].pin)
            print(p1.x, p2.x, p1.y, p2.y, pin1, pin2)
            if p1.y == p2.y then
                _insert_horizontal_line(routes, net, blocked_lines, p1.x, p2.x, pin1, pin2, p1.y)
            else
                --_insert_horizontal_line(routes, net, blocked_lines, p1.x, p1.x, -2, 3, p1.y)
                --_insert_vertical_line(routes, net, blocked_lines, p1.x, p1.x, -2, 3, p1.y)
                --table.insert(routes.vertical, {
                --    net = net.net,
                --    xgrid = p1.x,
                --    xline = 3,
                --    ygridstart = p1.y,
                --    ygridend = p2.y,
                --    ylinestart = -2,
                --    ylineend = 2,
                --})
                --table.insert(routes.horizontal, {
                --    net = net.net,
                --    xgridstart = p2.x,
                --    xgridend = p2.x,
                --    xlinestart = -2,
                --    xlineend = 3,
                --    ygrid = p2.y,
                --    yline = -1,
                --})
            end
        end
    end
    return routes
end

return M
