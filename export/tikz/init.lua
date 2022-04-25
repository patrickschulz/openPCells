local M = {}

local baseunit = 100

local __standalone

function M.get_extension()
    return "tikz"
end

function M.set_options(opt)
    for i = 1, #opt do
        local arg = opt[i]
        if arg == "-s" or arg == "--standalone" then
            __standalone = true
        end
    end
end

local __content = {}

function M.finalize()
    return table.concat(__content, "\n")
end

function M.at_begin()
    if __standalone then
        table.insert(__content, '\\documentclass{standalone}')
        table.insert(__content, '\\usepackage{tikz}')
        table.insert(__content, '\\usetikzlibrary{patterns}')
        table.insert(__content, '\\begin{document}')
    end
    table.insert(__content, '\\begin{tikzpicture}[x = 5, y = 5]')
end

function M.at_end()
    table.insert(__content, '\\end{tikzpicture}')
    if __standalone then
        table.insert(__content, '\\end{document}')
    end
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

local function _insert_appearance(layer)
    if layer.order then
    else
        if layer.nofill then
            table.insert(__content, string.format("\\path[draw = %s]", layer.color))
        else
            if not layer.pattern then
                table.insert(__content, string.format("\\path[draw = %s, pattern = crosshatch, pattern color = %s]", layer.color, layer.color))
            else
                table.insert(__content, string.format("\\path[fill = %s]", layer.color, layer.color))
            end
        end
    end
end

function M.write_rectangle(layer, bl, tr)
    _insert_appearance(layer)
    table.insert(__content, string.format("(%s) rectangle (%s);", _format_point(bl, baseunit, ", "), _format_point(tr, baseunit, ", ")))
end

function M.write_polygon(layer, pts)
    _insert_appearance(layer)
    local ptstream = {}
    for _, pt in ipairs(pts) do
        table.insert(ptstream, string.format("(%s)", _format_point(pt, baseunit, ", ")))
    end
    table.insert(__content, table.concat(ptstream, " -- ") .. ";")
end

return M
