local M = {}

local baseunit = 1000 -- virtuoso is micrometer-based

function M.get_extension()
    return "il"
end

local __content = {}

function M.finalize()
    return table.concat(__content, "\n")
end

local __group = false
local __groupname = "opcgroup"
local __let = true
local __labelsize = 0.1
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
    if opt.labelsize then
        __labelsize = opt.labelsize
    end
end

function M.at_begin()
    if __let then
        if __group then
            table.insert(__content, string.format([[
let(
    (
        (group if(dbGetFigGroupByName(cv "%s") then dbGetFigGroupByName(cv "%s") else dbCreateFigGroup(cv "%s" t 0:0 "R0")))
        shape
    )]], __groupname, __groupname, __groupname))
        else
            table.insert(__content, [[
let(
    (
        shape
    )]])
        end
    else
        if __group then
            table.insert(__content, string.format('if(dbGetFigGroupByName(cv "%s") then dbGetFigGroupByName(cv "%s") else dbCreateFigGroup(cv "%s" t 0:0 "R0"))', __groupname, __groupname, __groupname))
        end
    end
end

function M.at_end()
    if __let then
        table.insert(__content, ") ; let")
    end
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

local function intlog10(num)
    if num == 0 then return 0 end
    if num == 1 then return 0 end
    local ret = 0
    while num > 1 do
        num = num / 10
        ret = ret + 1
    end
    return ret
end

local function _format_number(num, baseunit)
    local fmt = string.format("%%s%%u.%%0%uu", intlog10(baseunit))
    local sign = "";
    if num < 0 then
        sign = "-"
        num = -num
    end
    local ipart = num // baseunit;
    local fpart = num - baseunit * ipart;
    return string.format(fmt, sign, ipart, fpart)
end

local function _format_point(pt, baseunit, sep)
    local sx = _format_number(pt.x, baseunit)
    local sy = _format_number(pt.y, baseunit)
    return string.format("%s%s%s", sx, sep, sy)
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

local function _prepare_shape_for_group()
    if __group then
        if __let then
            table.insert(__content, "    dbAddFigToFigGroup(group ")
        else
            table.insert(__content, string.format("dbAddFigToFigGroup(dbGetFigGroupByName(cv \"%s\") ", __groupname))
        end
    end
end

local function _finish_shape_for_group()
    if __group then
        table.insert(__content, ")")
    end
end

function M.write_rectangle(layer, bl, tr)
    local fmt = _get_shape_fmt("Rect")
    _prepare_shape_for_group()
    table.insert(__content, 
        string.format(fmt, 
        string.format("%s list(%s %s)", 
        _format_lpp(layer), 
        _format_point(bl, 1000, ":"), 
        _format_point(tr, 1000, ":")))
    )
    _finish_shape_for_group()
end

function M.write_polygon(layer, pts)
    local ptrstr = {}
    for _, pt in ipairs(pts) do
        table.insert(ptrstr, _format_point(pt, 1000, ":"))
    end
    local fmt = _get_shape_fmt("Polygon")
    _prepare_shape_for_group()
    table.insert(__content, string.format(fmt, string.format("%s list(%s)", _format_lpp(layer), table.concat(ptrstr, " "))))
    _finish_shape_for_group()
end

function M.write_path(layer, pts, width, extension)
    local ptrstr = {}
    for _, pt in ipairs(pts) do
        table.insert(ptrstr, _format_point(pt, 1000, ":"))
    end
    local fmt = _get_shape_fmt("Path")
    _prepare_shape_for_group()
    local extstr = ''
    if extension == "butt" then
        extstr = '"squareFlush"'
    elseif extension == "round" then
        extstr = '"roundRound"'
    elseif extension == "cap" then
        extstr = '"extendExtend"'
    end
    table.insert(__content, string.format(fmt, string.format("%s list(%s) %.3f %s", _format_lpp(layer), table.concat(ptrstr, " "), width / 1000, extstr)))
    _finish_shape_for_group()
end

function M.write_port(name, layer, where)
    local fmt = _get_shape_fmt("Label")
    _prepare_shape_for_group()
    table.insert(__content, string.format(fmt, string.format('%s %s "%s" "centerCenter" "R0" "roman" %f', _format_lpp(layer), where:format(baseunit, ":"), name, __labelsize)))
    _finish_shape_for_group()
end

return M
