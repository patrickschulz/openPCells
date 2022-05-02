local M = {}

function M.get_extension()
    return "mag"
end

local __technology = "DUMMYTECH"

function M.set_options(opt)
    for i = 1, #opt do
        local arg = opt[i]
        if arg == "-T" or arg == "--technology" then
            if i < #opt then
                __technology = opt[i + 1]
            else
                error("magic export: --technology: argument expected")
            end
            i = i + 1
        end
    end
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

function M.write_triangle(layer, pt1, pt2, pt3)
    print("write_triangle is not finished, as at that time I did not know the exact required format. This should be trivial to fix")
end

return M
