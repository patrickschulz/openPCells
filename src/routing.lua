local M = {}

function M.route(cell, routes, cells, width)
    for _, route in ipairs(routes) do
        local pts = {}
        table.insert(pts, cells[route.endpoints[1].cellname]:get_anchor(route.endpoints[1].anchor))
        for _, delta in ipairs(route.deltas) do
            print(delta.x, delta.y)
            table.insert(pts, cells[route.endpoints[1].cellname]:get_anchor(route.endpoints[1].anchor) + point.create(delta.x, delta.y))
        end
        cell:merge_into_shallow(geometry.path(generics.metal(3), pts, width))
    end
end

return M
