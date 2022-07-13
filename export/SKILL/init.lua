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
local __incell = false
local __groupname = "opcgroup"
local __labelsize = 0.1
function M.set_options(opt)
    for i = 1, #opt do
        local arg = opt[i]
        if arg == "-L" or arg == "--label-size" then
            if i < #opt then
                __labelsize = opt[i + 1]
            else
                error("SKILL export: --label-size: argument expected")
            end
            i = i + 1
        end
        if arg == "-g" or arg == "--group" then
            __group = true
        end
        if arg == "-c" or arg == "--in-cell" then
            __incell = true
        end
        if arg == "-n" or arg == "--group-name" then
            if i < #opt then
                __groupname = opt[i + 1]
            else
                error("SKILL export: --group-name: argument expected")
            end
            i = i + 1
        end
    end
end

function M.at_begin()
    if __incell and not __group then
        return
    end
    local c = { "let(", "    (" }
    if not __incell then
        table.insert(c, "        cv")
    end
    if __group and __incell then
        table.insert(c, string.format('        (group if(dbGetFigGroupByName(cv "%s") then dbGetFigGroupByName(cv "%s") else dbCreateFigGroup(cv "%s" t 0:0 "R0")))', __groupname, __groupname, __groupname))
    end
    table.insert(c, "    )")
    table.insert(__content, table.concat(c, "\n"))
end

function M.at_end()
    if __incell and not __group then
        return
    end
    table.insert(__content, ") ; let")
end

local function _format(l)
    local str
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

local function _format_xy(x, y, baseunit, sep)
    local sx = _format_number(x, baseunit)
    local sy = _format_number(y, baseunit)
    return string.format("%s%s%s", sx, sep, sy)
end

local function _get_indent()
    if __group and __incell then
        return "        "
    elseif not __incell then
        return "    "
    else
        return ""
    end
end

local function _get_shape_fmt(shapetype)
    return string.format("%sdbCreate%s(cv %%s)", _get_indent(), shapetype)
end

local function _prepare_shape_for_group()
    if __group and __incell then
        table.insert(__content, "    dbAddFigToFigGroup(group ")
    end
end

local function _finish_shape_for_group()
    if __group and __incell then
        --table.insert(__content, "    )")
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
    table.insert(__content, string.format(fmt, string.format('%s %s "%s" "centerCenter" "R0" "roman" %f', _format_lpp(layer), _format_point(where, baseunit, ":"), name, __labelsize)))
    _finish_shape_for_group()
end

function M.at_begin_cell(cellname, istoplevel)
    if not __incell then
        table.insert(__content, string.format('%scv = dbOpenCellViewByType(libname "%s" "layout" "maskLayout" "w")', _get_indent(), cellname))
    end
end
function M.at_end_cell(istoplevel)
    if not istoplevel then
        if not __incell then
            table.insert(__content, "    dbSave(cv)")
            table.insert(__content, "    dbPurge(cv)")
        end
    end
end

function M.write_cell_reference(identifier, x, y, orientation)
    local fmt = _get_shape_fmt("InstByMasterName")
    table.insert(__content, string.format(fmt, string.format('libname "%s" "layout" nil %s "%s"', identifier, _format_xy(x, y, 1000, ":"), "R0")))
end

return M
