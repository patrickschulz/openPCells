local M = {}

local baseunit = 1000 -- virtuoso is micrometer-based

function M.get_extension()
    return "il"
end

local __group = false
local __groupname = "opcgroup"
local __let = true
function M.set_options(opt)
    if opt.group then
        __group = true
    end
    if opt.nolet then
        __let = false
    end
    if opt.groupname then
        __groupname = opt.groupname
    end
end

function M.at_begin(file)
    if __let then
        if __group then
            file:write(string.format([[
let(
    (
        (group if(dbGetFigGroupByName(cv "%s") then dbGetFigGroupByName(cv "%s") else dbCreateFigGroup(cv "%s" t 0:0 "R0")))
        shape
    )
]], __groupname, __groupname, __groupname))
        else
            file:write([[
let(
    (
        shape
    )
]])
        end
    else
        if __group then
            file:write(string.format('if(dbGetFigGroupByName(cv "%s") then dbGetFigGroupByName(cv "%s") else dbCreateFigGroup(cv "%s" t 0:0 "R0"))\n', __groupname, __groupname, __groupname))
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
        if __group then
            return string.format("dbCreate%s(cv %%s)", shapetype)
        else
            return string.format("    dbCreate%s(cv %%s)", shapetype)
        end
    else
        return string.format("dbCreate%s(cv %%s)", shapetype)
    end
end

local function _prepare_shape_for_group(file)
    if __group then
        if __let then
            file:write("    dbAddFigToFigGroup(group ")
        else
            file:write(string.format("dbAddFigToFigGroup(dbGetFigGroupByName(cv \"%s\") ", __groupname))
        end
    end
end

local function _finish_shape_for_group(file)
    if __group then
        file:write(")")
    end
end

function M.write_rectangle(file, layer, bl, tr)
    local fmt = _get_shape_fmt("Rect")
    _prepare_shape_for_group(file)
    file:write(string.format(fmt, string.format("%s list(%s %s)", _format_lpp(layer), bl:format(1000, ":"), tr:format(1000, ":"))))
    _finish_shape_for_group(file)
    file:write("\n")
end

function M.write_polygon(file, layer, pts)
    local ptrstr = {}
    for _, pt in ipairs(pts) do
        table.insert(ptrstr, pt:format(1000, ":"))
    end
    local fmt = _get_shape_fmt("Polygon")
    _prepare_shape_for_group(file)
    file:write(string.format(fmt, string.format("%s list(%s)", _format_lpp(layer), table.concat(ptrstr, " "))))
    _finish_shape_for_group(file)
    file:write("\n")
end

function M.write_port(file, name, layer, where)
    local fmt = _get_shape_fmt("Label")
    _prepare_shape_for_group(file)
    file:write(string.format(fmt, string.format('%s %s "%s" "centerCenter" "R0" "roman" 0.1', _format_lpp(layer), where:format(baseunit, ":"), name)))
    _finish_shape_for_group(file)
    file:write("\n")
end

return M
