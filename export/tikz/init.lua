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
        table.insert(__content, '\\begin{document}')
    end
    table.insert(__content, '\\begin{tikzpicture}')
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

function M.write_rectangle(layer, bl, tr)
    table.insert(__content, string.format("\\fill[%s, opacity = 0.3] (%s) rectangle (%s);", layer.color, _format_point(bl, baseunit, ", "), _format_point(tr, baseunit, ", ")))
end

function M.write_polygon(layer, pts)
end

return M
