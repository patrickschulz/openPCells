local M = {}

local __baseunit = 1000 -- virtuoso is micrometer-based

function M.get_extension()
    return "il"
end

local __content = {}

function M.finalize()
    return table.concat(__content, "\n")
end

local __group = false
local __groupname = "opcgroup"
local __labelsize = 0.1
local __splitlets = true
local __counter = 0
local __maxletlimit = 65536
local __istoplevel = false
function M.set_options(opt)
    local i = 1
    while i < #opt do
        local arg = opt[i]
        if arg == "-L" or arg == "--label-size" then
            if i < #opt then
                __labelsize = opt[i + 1]
            else
                error("SKILL export: --label-size: argument expected")
            end
            i = i + 1
        elseif arg == "-g" or arg == "--group" then
            __group = true
        elseif arg == "-n" or arg == "--group-name" then
            if i < #opt then
                __groupname = opt[i + 1]
            else
                error("SKILL export: --group-name: argument expected")
            end
            i = i + 1
        elseif arg == "--no-let-splits" then
            __splitlets = false
        elseif arg == "--max-let-splits" then
            if i < #opt then
                __maxletlimit = tonumber(opt[i + 1])
            else
                error("SKILL export: --max-let-splits: argument expected")
            end
            i = i + 1
        else
            error(string.format("SKILL export: unknown option '%s'", arg))
        end
        i = i + 1
    end
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

local function _format_number(num)
    local fmt = string.format("%%s%%u.%%0%uu", intlog10(__baseunit))
    local sign = "";
    if num < 0 then
        sign = "-"
        num = -num
    end
    local ipart = num // __baseunit;
    local fpart = num - __baseunit * ipart;
    return string.format(fmt, sign, ipart, fpart)
end

local function _format_point(pt, sep)
    local sx = _format_number(pt.x)
    local sy = _format_number(pt.y)
    return string.format("%s%s%s", sx, sep, sy)
end

local function _get_shape_fmt(shapetype)
    return string.format("dbCreate%s(cv %%s)", shapetype)
end

local function _prepare_shape_for_group(c)
    if __group then
        table.insert(c, "    dbAddFigToFigGroup(group ")
    else
        table.insert(c, "    ")
    end
end

local function _finish_shape_for_group(c)
    if __group then
        table.insert(c, ")")
    end
end

local function _start_let(initial)
    table.insert(__content, "let(")
    table.insert(__content, "    (")
    if __istoplevel then
        table.insert(__content, '        (cv geGetEditCellView())')
    else
        if initial then
            table.insert(__content, string.format('        (cv dbOpenCellViewByType(libname "%s" "layout" "maskLayout" "w"))', __cellname))
        else
            table.insert(__content, string.format('        (cv dbOpenCellViewByType(libname "%s" "layout" "maskLayout" "a"))', __cellname))
        end
    end
    if __group then
        table.insert(__content, string.format('        (group if(dbGetFigGroupByName(cv "%s") then dbGetFigGroupByName(cv "%s") else dbCreateFigGroup(cv "%s" t 0:0 "R0")))', __groupname, __groupname, __groupname))
    end
    table.insert(__content, "    )")
end

local function _close_let()
    table.insert(__content, ") ; let")
    __counter = 0
end

local function _ensure_legal_limit()
    if __splitlets then
        __counter = __counter + 1
        --print(__counter, __maxletlimit)
        if __counter > __maxletlimit then
            _close_let() -- resets the counter
            _start_let()
        end
    end
end

function M.write_rectangle(layer, bl, tr)
    local fmt = _get_shape_fmt("Rect")
    local c = {}
    _prepare_shape_for_group(c)
    table.insert(c,
        string.format(fmt, 
            string.format("%s list(%s %s)", 
                _format_lpp(layer), 
                _format_point(bl, ":"), 
                _format_point(tr, ":")
            )
        )
    )
    _finish_shape_for_group(c)
    _ensure_legal_limit()
    table.insert(__content, table.concat(c))
end

function M.write_polygon(layer, pts)
    local ptrstr = {}
    for _, pt in ipairs(pts) do
        table.insert(ptrstr, _format_point(pt, ":"))
    end
    local fmt = _get_shape_fmt("Polygon")
    local c = {}
    _prepare_shape_for_group(c)
    table.insert(c, string.format(fmt, string.format("%s list(%s)", _format_lpp(layer), table.concat(ptrstr, " "))))
    _finish_shape_for_group(c)
    _ensure_legal_limit()
    table.insert(__content, table.concat(c))
end

function M.write_path(layer, pts, width, extension)
    local ptrstr = {}
    for _, pt in ipairs(pts) do
        table.insert(ptrstr, _format_point(pt, ":"))
    end
    local fmt = _get_shape_fmt("Path")
    local c = {}
    _prepare_shape_for_group(c)
    local extstr = ''
    if extension == "butt" then
        extstr = '"squareFlush"'
    elseif extension == "round" then
        extstr = '"roundRound"'
    elseif extension == "cap" then
        extstr = '"extendExtend"'
    end
    table.insert(c, string.format(fmt, string.format("%s list(%s) %.3f %s", _format_lpp(layer), table.concat(ptrstr, " "), width / __baseunit, extstr)))
    _finish_shape_for_group(c)
    _ensure_legal_limit()
    table.insert(__content, table.concat(c))
end

function M.write_port(name, layer, where, sizehint)
    local fmt = _get_shape_fmt("Label")
    local c = {}
    _prepare_shape_for_group(c)
    table.insert(c, string.format(fmt, string.format('%s %s "%s" "centerCenter" "R0" "roman" %f', _format_lpp(layer), _format_point(where, ":"), name, sizehint and (sizehint / __baseunit) or __labelsize)))
    _finish_shape_for_group(c)
    _ensure_legal_limit()
    table.insert(__content, table.concat(c))
end

function M.at_begin_cell(cellname, istoplevel)
    __istoplevel = istoplevel
    __cellname = cellname
    _start_let(true) -- true: initial let for this cell
end

function M.at_end_cell(istoplevel)
    if not istoplevel then
        table.insert(__content, "    dbSave(cv)")
        table.insert(__content, "    dbPurge(cv)")
    end
    _close_let()
end

function M.write_cell_reference(identifier, instname, origin, orientation)
    local orientstr
    if orientation[1] >= 0 and orientation[5] >= 0 then
        if orientation[2] < 0 then
            orientstr = "R90"
        else
            orientstr = "R0"
        end
    elseif orientation[1] <  0 and orientation[5] >= 0 then
        orientstr = "MY"
    elseif orientation[1] >= 0 and orientation[5] <  0 then
        orientstr = "MX"
    else
        orientstr = "R180"
    end
    -- FIXME: R270?
    local fmt = _get_shape_fmt("InstByMasterName")

    local c = {}
    _prepare_shape_for_group(c)
    if instname then
        table.insert(c, string.format(fmt, string.format('libname "%s" "layout" "%s" %s "%s"', identifier, instname, _format_point(origin, ":"), orientstr)))
    else
        table.insert(c, string.format(fmt, string.format('libname "%s" "layout" nil %s "%s"', identifier, _format_point(origin, ":"), orientstr)))
    end
    _finish_shape_for_group(c)
    _ensure_legal_limit()
    table.insert(__content, table.concat(c))
end

function M.write_cell_array(identifier, instbasename, origin, orientation, xrep, yrep, xpitch, ypitch)
    local orientstr
    if orientation[1] >= 0 and orientation[5] >= 0 then
        if orientation[2] < 0 then
            orientstr = "R90"
        else
            orientstr = "R0"
        end
    elseif orientation[1] <  0 and orientation[5] >= 0 then
        orientstr = "MY"
    elseif orientation[1] >= 0 and orientation[5] <  0 then
        orientstr = "MX"
    else
        orientstr = "R180"
    end
    -- FIXME: R270?
    local fmt = _get_shape_fmt("ParamSimpleMosaicByMasterName")

    local c = {}
    _prepare_shape_for_group(c)
    if instbasename then
        table.insert(c, string.format(fmt, string.format('libname "%s" "layout" "%s" %s "%s" %d %d %s %s nil', identifier, instbasename, _format_point(origin, ":"), orientstr, yrep, xrep, _format_number(ypitch), _format_number(xpitch))))
    else
        table.insert(c, string.format(fmt, string.format('libname "%s" "layout" nil %s "%s" %d %d %s %s nil', identifier, _format_point(origin, ":"), orientstr, yrep, xrep, _format_number(ypitch), _format_number(xpitch))))
    end
    _finish_shape_for_group(c)
    _ensure_legal_limit()
    table.insert(__content, table.concat(c))
end

return M
