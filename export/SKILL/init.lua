local M = {}

local baseunit = 1000 -- virtuoso is micrometer-based

function M.get_extension()
    return "il"
end

local __group = false
function M.set_options(opt)
    if opt.group then
        __group = true
    end
end

function M.at_begin(file)
    if __group then
        file:write([[
letseq(
    (
        (cv geGetEditCellView())
        (group dbCreateFigGroup(cv "Group0" t 0:0 "R0"))
        shape
    )
]])
    else
        file:write([[
let(
    (
        (cv geGetEditCellView())
        shape
    )
]])
    end
end

function M.at_end(file)
    file:write(") ; let\n")
end

function M.get_layer(S)
    return { layer = S.lpp:get().layer, purpose = S.lpp:get().purpose }
end

local function _format(l)
    local str
    if type(l) == "number" then
        str = tostring(l)
    else
        str = string.format('"%s"', l)
    end
    if type(l) == "number" then
        str = tostring(l)
    else
        str = string.format('"%s"', l)
    end
end

local function _format_lpp(layer)
    return string.format("list(%s %s)", _format(layer.layer), _format(layer.purpose))
end

function M.write_rectangle(file, layer, bl, tr)
    file:write(string.format('    shape = dbCreateRect(cv %s list(%s %s))\n', _format_lpp(layer), bl:format(1000, ":"), tr:format(1000, ":")))
    if __group then
        file:write("    dbAddFigToFigGroup(group shape)\n")
    end
end

function M.write_polygon(file, layer, pts)
    local ptrstr = {}
    for _, pt in ipairs(pts) do
        table.insert(ptrstr, pt:format(1000, ":"))
    end
    file:write(string.format('    shape = dbCreatePolygon(cv %s list(%s))\n', _format_lpp(layer), table.concat(ptrstr, " ")))
    if __group then
        file:write("    dbAddFigToFigGroup(group shape)\n")
    end
end

function M.write_port(file, name, layer, where)
    file:write(string.format('    shape = dbCreateLabel(cv %s %s "%s" "centerCenter" "R0" "roman" 0.1)\n', 
        _format_lpp(layer), where:format(baseunit, ":"), name))
    if __group then
        file:write("    dbAddFigToFigGroup(group shape)\n")
    end
end

return M
