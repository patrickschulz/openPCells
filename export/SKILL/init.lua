local M = {}

local baseunit = 1000 -- virtuoso is micrometer-based

function M.get_extension()
    return "il"
end

local __group = false
local __let = true
function M.set_options(opt)
    if opt.group then
        __group = true
    end
    if opt.nolet then
        __let = false
    end
end

function M.at_begin(file)
    if __let then
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
end

function M.at_end(file)
    if __let then
        file:write(") ; let\n")
    end
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
    return str
end

local function _format_lpp(layer)
    return string.format("list(%s %s)", _format(layer.layer), _format(layer.purpose))
end

local function _get_shape_fmt(shapetype)
    if __let then
        return string.format("    shape = dbCreate%s(cv %%s)\n", shapetype)
    else
        return string.format("dbCreate%s(geGetEditCellView() %%s)\n", shapetype)
    end
end

function M.write_rectangle(file, layer, bl, tr)
    local fmt = _get_shape_fmt("Rect")
    file:write(string.format(fmt, string.format("%s list(%s %s)", _format_lpp(layer), bl:format(1000, ":"), tr:format(1000, ":"))))
    if __group then
        file:write("    dbAddFigToFigGroup(group shape)\n")
    end
end

function M.write_polygon(file, layer, pts)
    local ptrstr = {}
    for _, pt in ipairs(pts) do
        table.insert(ptrstr, pt:format(1000, ":"))
    end
    local fmt = _get_shape_fmt("Polygon")
    file:write(string.format(fmt, string.format("%s list(%s)", _format_lpp(layer), table.concat(ptrstr, " "))))
    if __group then
        file:write("    dbAddFigToFigGroup(group shape)\n")
    end
end

function M.write_port(file, name, layer, where)
    local fmt = _get_shape_fmt("Label")
    file:write(string.format(fmt, string.format('%s %s "%s" "centerCenter" "R0" "roman" 0.1', _format_lpp(layer), where:format(baseunit, ":"), name)))
    if __group then
        file:write("    dbAddFigToFigGroup(group shape)\n")
    end
end

return M
