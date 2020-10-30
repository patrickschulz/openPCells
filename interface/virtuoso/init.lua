local M = {}

local baseunit = 1000

function M.get_extension()
    return "il"
end

function M.at_begin(file)
    file:write([[
let(
    ()
]])
end

function M.at_end(file)
    file:write(") ; let\n")
end

function M.write_layer(file, layer, pcol)
    file:write(string.format("    foreach(pts\n        list(\n%s\n        )\n", aux.concat(pcol, "", string.rep(" ", 12), nil, true)))
    file:write(string.format("        %s pts)\n", layer))
    file:write("    )\n")
end

function M.get_layer(shape)
    local st
    if shape.typ == "polygon" then
        st = "Polygon"
    elseif shape.typ == "rectangle" then
        st = "Rect"
    end
    return string.format('dbCreate%s(cv list("%s" "%s")', st, shape.lpp:get().layer, shape.lpp:get().purpose)
end

function M.get_points(shape)
    --local pointlist = shape:concat_points(function(pt) return string.format("%d:%d", pt:unwrap()) end)
    local pointlist = shape:concat_points(function(pt) return pt:format(baseunit, ":") end)
    return string.format("list(%s)", table.concat(pointlist, " "))
end

function M.write_port(file, name, layer, where)
    file:write(string.format('    dbCreateLabel(cv list("%s" "label") %s "%s" "centerCenter" "R0" "roman" 0.2)\n', layer, where:format(baseunit, ":"), name))
end

return M
