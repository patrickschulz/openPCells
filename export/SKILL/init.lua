local M = {}

local baseunit = 1000 -- virtuoso is micrometer-based

function M.get_extension()
    return "il"
end

function M.at_begin(file)
    file:write([[
letseq(
    (
        (cv geGetEditCellView())
        (group dbCreateFigGroup(cv "Group0" t 0:0 "R0"))
        shape
    )
]])
end

function M.at_end(file)
    file:write(") ; let\n")
end

function M.get_layer(S)
    return { layer = S.lpp:get().layer, purpose = S.lpp:get().purpose }
end

function M.write_rectangle(file, layer, bl, tr)
    file:write(string.format('    shape = dbCreateRect(cv list("%s" "%s") list(%s %s))\n', layer.layer, layer.purpose, bl:format(1000, ":"), tr:format(1000, ":")))
    file:write("    dbAddFigToFigGroup(group shape)\n")
end

function M.write_polygon(file, layer, pts)
    local ptrstr = {}
    for _, pt in ipairs(pts) do
        table.insert(ptrstr, pt:format(1000, ":"))
    end
    file:write(string.format('    shape = dbCreatePolygon(cv list("%s" "%s") list(%s))\n', layer.layer, layer.purpose, table.concat(ptrstr, " ")))
    file:write("    dbAddFigToFigGroup(group shape)\n")
end

function M.write_port(file, name, layer, where)
    file:write(string.format('    shape = dbCreateLabel(cv list("%s" "%s") %s "%s" "centerCenter" "R0" "roman" 0.1)\n', 
        layer.layer, layer.purpose, where:format(baseunit, ":"), name))
    file:write("    dbAddFigToFigGroup(group shape)\n")
end

return M
