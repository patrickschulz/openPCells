local M = {}

function M.route(cell, routes, cells, width)
    for _, route in ipairs(routes) do
        local pts = {}
        local currmetal = 3
        table.insert(pts, cells[route.endpoints[1].cellname]:get_anchor(route.endpoints[1].anchor))
        for _, delta in ipairs(route.deltas) do
            if not delta.isvia then
                currmetal = delta.metal
                table.insert(pts, cells[route.endpoints[1].cellname]:get_anchor(route.endpoints[1].anchor) + point.create(delta.x, delta.y))
            else
                -- we have a via
                table.insert(pts, cells[route.endpoints[1].cellname]:get_anchor(route.endpoints[1].anchor) + point.create(delta.x, delta.y))
                cell:merge_into_shallow(geometry.path(generics.metal(currmetal), pts, width))
                pts = {}
                table.insert(pts, cells[route.endpoints[1].cellname]:get_anchor(route.endpoints[1].anchor))
                cell:merge_into_shallow(geometry.rectangle(generics.via(delta.from, delta.to), 100, 100):
                    translate( cells[route.endpoints[1].cellname]:get_anchor(route.endpoints[1].anchor) + point.create(delta.x, delta.y)))
            end
        end
        cell:merge_into_shallow(geometry.path(generics.metal(currmetal), pts, width))
    end
end

return M
