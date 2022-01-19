local M = {}

local __content = {}

function M.finalize()
    return table.concat(__content, "\n")
end

function M.get_extension()
    return "mag"
end

function M.get_layer(shape)
    return shape.lpp:get().layer
end

function M.at_begin(technology)
    table.insert(__content, string.format("%s", "magic"))
    table.insert(__content, string.format("tech %s", technology))
    table.insert(__content, string.format("timestamp %s", os.time()))
end

function M.at_end()
    table.insert(__content, string.format("%s", "<< end >>"))
end

function M.write_rectangle(layer, bl, tr)
    local grid = 1000
    local xbot, ybot = bl:unwrap()
    xbot = xbot * grid
    ybot = ybot * grid
    local xtop, ytop = tr:unwrap()
    xtop = xtop * grid
    ytop = ytop * grid
    table.insert(__content, string.format("<< %s >>", layer))
    table.insert(__content, string.format("rect %d %d %d %d", math.floor(xbot), math.floor(ybot), math.floor(xtop), math.floor(ytop)))
end

-- TODO
function M.write_polygon(layer, pts)
end

return M
