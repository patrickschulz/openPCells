function layout(cell, _P, env)
    local filler = pcell.create_layout("auxiliary/decap", "_filler", {
        cellsize = env.decap.cellsize,
        meshmetals = { 8 },
        meshmetalwidths = { 1250 },
        drawgrid = false,
        drawmoscap = false,
    })
    --cell:merge_into(filler:copy():move_to(point.create(-60000, -15000)))
    --cell:merge_into(filler:copy():move_to(point.create(-60000, -25000)))
end
