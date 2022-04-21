local M = {}

local __technology = "DUMMYTECH"

function M.get_extension()
    return "mag"
end

local __content = {}

function M.finalize()
    return table.concat(__content, "\n")
end

function M.at_begin()
    table.insert(__content, string.format("%s", "magic"))
    table.insert(__content, string.format("tech %s", __technology))
    table.insert(__content, string.format("timestamp %s", os.time()))
end

function M.at_end()
    table.insert(__content, string.format("%s", "<< end >>"))
end

function M.write_rectangle(layer, bl, tr)
    local grid = 1000
    bl.x = bl.x * grid
    bl.y = bl.y * grid
    tr.x = tr.x * grid
    tr.y = tr.y * grid
    table.insert(__content, string.format("<< %s >>", layer.layer))
    table.insert(__content, string.format("rect %d %d %d %d", math.floor(bl.x), math.floor(bl.y), math.floor(tr.x), math.floor(tr.y)))
end

-- TODO: needs polygon triangulation
function M.write_polygon(layer, pts)
end

return M
