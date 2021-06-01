local M = {}

function M.get_extension()
    return "mag"
end

function M.get_layer(shape)
    return shape.lpp:get().layer
end

function M.at_begin(file, technology)
    file:write(string.format("%s\n", "magic"))
    file:write(string.format("tech %s\n", technology))
    file:write(string.format("timestamp %s\n", os.time()))
end

function M.at_end(file)
    file:write(string.format("%s\n", "<< end >>"))
end

function M.write_rectangle(file, layer, bl, tr)
    local grid = 1000
    local xbot, ybot = bl:unwrap()
    xbot = xbot * grid
    ybot = ybot * grid
    local xtop, ytop = tr:unwrap()
    xtop = xtop * grid
    ytop = ytop * grid
    file:write(string.format("<< %s >>\n", layer))
    file:write(string.format("rect %d %d %d %d\n", math.floor(xbot), math.floor(ybot), math.floor(xtop), math.floor(ytop)))
end

-- TODO
function M.write_polygon(file, layer, pts)
end

return M
