local M = {}

local options = {}

local baseunit = 100000

function M.get_extension()
    return "tikz"
end

function M.techinterface()
    return "svg"
end

--[[
function M.print_object(file, cell)
    file:write("[\n")
    for layer in pairs(_collect_shapes(cell, function(s) return s.lpp:get().layer end)) do
        file:write(string.format("    %s/.style = {},\n", layer))
    end
    file:write("]\n")
    for shape in cell:iter() do
        _write_shape(file, shape)
    end
end
--]]

function M.at_begin(file)
    if options.standalone then
        file:write('\\documentclass{standalone}\n')
        file:write('\\usepackage{tikz}\n')
        file:write('\\begin{document}\n')
    end
    file:write('\\begin{tikzpicture}\n')
end

function M.at_end(file)
    file:write('\\end{tikzpicture}\n')
    if options.standalone then
        file:write('\\end{document}\n')
    end
end

function M.get_layer(shape)
    return shape.lpp:get().color
end

function M.get_points(shape)
    if shape.typ == "polygon" then
        local pointlist = shape:concat_points(function(pt) return string.format("(%s)", pt:format(baseunit, ", ")) end)
        return table.concat(pointlist, " -- ")
    else
        return string.format("(%s) rectangle (%s)", shape.points.bl:format(baseunit, ", "), shape.points.tr:format(baseunit, ", "))
    end
end

function M.write_layer(file, layer, pcol)
    for _, pts in ipairs(pcol) do
        file:write(string.format('    \\fill[%s] %s;\n', layer, pts))
    end
end

function M.set_options(opt)
    if opt then
        options = opt
    end
end

return M
