local M = {}

function M.route(cell, routes, cells, width)
    for _, route in ipairs(routes) do
        local pts = {}
        local metals = {}
        table.insert(pts, cells[route.endpoints[1].cellname]:get_anchor(route.endpoints[1].anchor))
        for _, delta in ipairs(route.deltas) do
            if not delta.isvia then
                table.insert(pts, cells[route.endpoints[1].cellname]:get_anchor(route.endpoints[1].anchor) + point.create(delta.x, delta.y))
            else
                cell:merge_into_shallow(geometry.rectangle(generics.via(delta.from, delta.to), 100, 100):
                    translate( cells[route.endpoints[1].cellname]:get_anchor(route.endpoints[1].anchor) + point.create(delta.x, delta.y)))
            end
        end
        cell:merge_into_shallow(geometry.path(generics.metal(3), pts, width))
    end
end

return M
