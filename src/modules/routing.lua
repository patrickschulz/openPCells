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

return M
