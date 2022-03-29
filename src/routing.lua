local M = {}

local function _prepare_routing_nets(nets, rows)
    local netpositions = {}
    local numnets = 0
    for name, net in pairs(nets) do
        for _, n in pairs(net.connections) do
            for r, row in ipairs(rows) do
                for c, column in ipairs(row) do
                    if column.instance == n.instance then
                        if not netpositions[name] then
                            netpositions[name] = {}
                            numnets = numnets + 1
                        end
                        --local offset = _get_pin_offset(column.reference, n.port)
                        local offset = 0
                        table.insert(netpositions[name], { x = c + offset, y = r })
                    end
                end
            end
        end
    end
    return netpositions, numnets
end

function M.legalize(nets, rows)
    local routes = {}
    local netpositions, numnets = _prepare_routing_nets(nets, rows)
    return routes
end

function M.route(cell, routes, cells, width)
    for r, route in ipairs(routes) do
        if route[1].type ~= "anchor" then
            moderror(string.format("routing.route: route #%d: first movement needs to be of type 'anchor'", r))
        end
        local startpt = cells[route[1].name]:get_anchor(route[1].anchor)
        local pts = {}
        local currmetal = 1
        local x, y = startpt:unwrap()
        for i = 2, #route do
            local movement = route[i]
            if movement.type == "anchor" then
                local pt = cells[movement.name]:get_anchor(movement.anchor)
                x, y = pt:unwrap()
                table.insert(pts, pt)
            elseif movement.type == "switchdirection" then
                table.insert(pts, 0)
            elseif movement.type == "delta" then
                if movement.x and movement.y then
                    table.insert(pts, movement.x)
                    table.insert(pts, movement.y)
                elseif movement.x then
                    table.insert(pts, movement.x)
                elseif movement.y then
                    table.insert(pts, 0)
                    table.insert(pts, movement.y)
                end
                x = x + (movement.x or 0)
                y = y + (movement.y or 0)
            elseif movement.type == "via" then
                geometry.via(cell, currmetal, movement.metal, width, width, x, y)
                if #pts > 1 then
                    geometry.path(cell, generics.metal(currmetal), 
                        geometry.path_points_xy(startpt, pts), width)
                end
                startpt = point.create(x, y)
                pts = {}
                currmetal = movement.metal
            end
        end
        geometry.path(cell, generics.metal(currmetal), 
            geometry.path_points_xy(startpt, pts), width)
    end
end

return M
