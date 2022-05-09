local M = {}

function M.get_extension()
    return "tikz"
end

function M.get_techexport()
    return "svg"
end

local __standalone = false
local __drawpatterns = false
local __resizebox = false
local __externaldisable
local __baseunit = 1
local __expressionscale = false

function M.set_options(opt)
    for i = 1, #opt do
        local arg = opt[i]
        if arg == "-S" or arg == "--standalone" then
            __standalone = true
        end
        if arg == "-p" or arg == "--pattern" then
            __drawpatterns = true
        end
        if arg == "-e" or arg == "--expression-scale" then
            print("expressionsscale")
            __expressionscale = true
        end
        if arg == "-b" or arg == "--base-unit" then
            if i < #opt then
                __baseunit = tonumber(opt[i + 1])
            else
                error("tikz export: --base-unit: argument (a number) expected")
            end
            i = i + 1
        end
        if arg == "-r" or arg == "--resize-box" then
            __resizebox = true
        end
        if arg == "-x" or arg == "--disable-externalize" then
            __externaldisable = true
        end
        if arg == "-c" or arg == "--color" then
            if i < #opt then
                __color = opt[i + 1]
            else
                error("tikz export: --color: argument (a HTML color string) expected")
            end
            i = i + 1
        end
    end
end

local __header = {}
local __before = {}
local __options = {}
local __after = {}
local __content = {}

function M.finalize()
    local t = {}
    for _, entry in ipairs(__header) do
        table.insert(t, entry)
    end
    for _, entry in ipairs(__before) do
        table.insert(t, entry)
    end
    if #__options > 0 then
        table.insert(t, "[")
        for i, entry in ipairs(__options) do
            if i ~= #__options then
                table.insert(t, string.format("    %s,", entry))
            else
                table.insert(t, string.format("    %s", entry))
            end
        end
        table.insert(t, "]")
    end
    table.sort(__content, function(lhs, rhs) return lhs.order < rhs.order end)
    for _, entry in ipairs(__content) do
        table.insert(t, string.format("    %s", entry.content))
    end
    for _, entry in ipairs(__after) do
        table.insert(t, entry)
    end
    return table.concat(t, "\n") .. "\n"
end

function M.at_begin()
    if __standalone then
        table.insert(__header, '\\documentclass{standalone}')
        table.insert(__header, '\\usepackage{tikz}')
        table.insert(__header, '\\usetikzlibrary{patterns}')
        if __resizebox then
            table.insert(__header, '\\usepackage{adjustbox}')
        end
        table.insert(__before, '\\begin{document}')
    end
    if __externaldisable then
        table.insert(__before, '\\tikzexternaldisable')
    end
    if __resizebox then
        table.insert(__before, '\\begin{adjustbox}{width=\\linewidth}')
    end
    if __expressionscale then
        table.insert(__before, '\\def\\opclayoutscale{1}')
    end
    table.insert(__before, '\\begin{tikzpicture}')
    --table.insert(__options, "x = 5, y = 5")
end

function M.at_end()
    table.insert(__after, '\\end{tikzpicture}')
    if __resizebox then
        table.insert(__after, '\\end{adjustbox}')
    end
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

local function _format_number(num)
    local fmt
    if __expressionscale then
        fmt = string.format("%%s%%u.%%0%uu * \\opclayoutscale", intlog10(__baseunit))
    else
        fmt = string.format("%%s%%u.%%0%uu", intlog10(__baseunit))
    end
    local sign = "";
    if num < 0 then
        sign = "-"
        num = -num
    end
    local ipart = num // __baseunit;
    local fpart = num - __baseunit * ipart;
    return string.format(fmt, sign, ipart, fpart)
end

local function _format_point(pt)
    local sx = _format_number(pt.x)
    local sy = _format_number(pt.y)
    if __expressionscale then
        return string.format("{ %s, %s }", sx, sy)
    else
        return string.format("%s, %s", sx, sy)
    end
end

local colors = {}
local numcolors = 0
local function _get_layer_style(layer)
    local color
    if __color then
        local colorstring = "layoutcolor"
        table.insert(__header, string.format("\\definecolor{%s}{HTML}{%s}", colorstring, __color))
        color = colorstring
    else
        if not colors[layer.color] then
            local colorname
            if layer.style then
                colorname = string.format("%scolor", layer.style)
            else
                colorname = string.format("layoutcolor%d", numcolors + 1)
                numcolors = numcolors + 1
            end
            table.insert(__header, string.format("\\definecolor{%s}{HTML}{%s}", colorname, layer.color))
            colors[layer.color] = colorname
        end
        color = colors[layer.color]
    end
    if layer.nofill then
        return string.format("draw = %s", color)
    else
        if layer.pattern then
            return string.format("draw = %s, pattern = crosshatch, pattern color = %s", color, color)
        else
            return string.format("fill = %s, draw = %s", color, color)
        end
    end
end

local styles = {}
local function _format_layer(layer)
    if layer.style then
        if not styles[layer.style] then
            styles[layer.style] = true
            table.insert(__options, string.format("%s/.style = { %s }", layer.style, _get_layer_style(layer)))
        end
        return string.format("\\path[%s]", layer.style)
    end
    return string.format("\\path[%s]", _get_layer_style(layer))
end

function M.write_rectangle(layer, bl, tr)
    table.insert(__content, {
        order = layer.order or 0,
        content = string.format("%s (%s) rectangle (%s);", _format_layer(layer), _format_point(bl), _format_point(tr))
    })
end

function M.write_polygon(layer, pts)
    local ptstream = {}
    for _, pt in ipairs(pts) do
        table.insert(ptstream, string.format("(%s)", _format_point(pt)))
    end
    table.insert(__content, {
        order = layer.order or 0,
        content = string.format("%s %s;", _format_layer(layer), table.concat(ptstream, " -- "))
    })
end

local curveorder
local curvecontent
function M.setup_curve(layer, origin)
    curvecontent = {}
    curveorder = layer.order or 0
    table.insert(curvecontent, string.format("%s (%s)", _format_layer(layer), _format_point(origin)))
end

function M.curve_add_line_segment(pt)
    table.insert(curvecontent, string.format("-- (%s)", _format_point(pt)))
end

function M.curve_add_arc_segment(startpt, startangle, endangle, radius, clockwise)
    local pt = {
        x = math.floor(startpt.x + (math.cos(endangle * math.pi / 180) - math.cos(startangle * math.pi / 180)) * radius),
        y = math.floor(startpt.y + (math.sin(endangle * math.pi / 180) - math.sin(startangle * math.pi / 180)) * radius)
    }
    clockwise = clockwise and 0 or 1
    --table.insert(curvecontent, string.format("A %d %d 0 0 %d %s", __scale * radius, __scale * radius, clockwise, _format_point(pt)))
    table.insert(curvecontent, string.format("arc[start angle = %d, end angle = %d, radius = %s]", startangle, endangle, _format_number(radius)))
end

function M.close_curve()
    table.insert(curvecontent, "-- cycle;")
    table.insert(__content, {
        order = curveorder,
        content = table.concat(curvecontent, ' ')
    })
end

return M
