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

local __before = {}
local __after = {}
local __content = {}

function M.finalize()
    local t = {}
    for _, entry in ipairs(__before) do
        table.insert(t, entry)
    end
    table.sort(__content, function(lhs, rhs) return lhs.order < rhs.order end)
    for _, entry in ipairs(__content) do
        table.insert(t, entry.content)
    end
    for _, entry in ipairs(__after) do
        table.insert(t, entry)
    end
    return table.concat(t, "\n")
end

function M.at_begin()
    if __standalone then
        table.insert(__before, '\\documentclass{standalone}')
        table.insert(__before, '\\usepackage{tikz}')
        table.insert(__before, '\\usetikzlibrary{patterns}')
        table.insert(__before, '\\begin{document}')
    end
    table.insert(__before, '\\begin{tikzpicture}[x = 5, y = 5]')
end

function M.at_end()
    table.insert(__after, '\\end{tikzpicture}')
    if __standalone then
        table.insert(__after, '\\end{document}')
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

local function _format_layer(layer)
    if false and layer.order then
    else
        if layer.nofill then
            return string.format("\\path[draw = %s]", layer.color)
        else
            if layer.pattern then
                return string.format("\\path[draw = %s, pattern = crosshatch, pattern color = %s]", layer.color, layer.color)
            else
                return string.format("\\path[fill = %s]", layer.color, layer.color)
            end
        end
    end
end

function M.write_rectangle(layer, bl, tr)
    --_insert_appearance(layer)
    table.insert(__content, { order = layer.order or 0, content = string.format("%s (%s) rectangle (%s);", _format_layer(layer), _format_point(bl, baseunit, ", "), _format_point(tr, baseunit, ", ")) })
end

function M.write_polygon(layer, pts)
    --_insert_appearance(layer)
    --local ptstream = {}
    --for _, pt in ipairs(pts) do
    --    table.insert(ptstream, string.format("(%s)", _format_point(pt, baseunit, ", ")))
    --end
    --table.insert(__content, table.concat(ptstream, " -- ") .. ";")
end

return M
