local M = {}

local options = {}

function M.get_extension()
    return "tikz"
end

function M.print_object(file, cell)
    file:write("[\n")
    for layer in pairs(_collect_shapes(cell, function(s) return s.lpp:get().virtuoso.layer end)) do
        file:write(string.format("    %s/.style = {},\n", layer))
    end
    file:write("]\n")
    for shape in cell:iter() do
        _write_shape(file, shape)
    end
end

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
    return shape.lpp:get().virtuoso.layer
end

function M.get_points(shape)
    local xbot, ybot = shape.points.bl:unwrap()
    local xtop, ytop = shape.points.tr:unwrap()
    return { 
        first = string.format("(%f, %f)", xbot, ybot),
        second = string.format("(%f, %f)", xtop, ytop)
    }
end

function M.write_layer(file, layer, pcol)
    for _, pts in ipairs(pcol) do
        file:write(string.format('    \\draw[%s] %s rectangle %s;\n', layer, pts.first, pts.second))
    end
end

function M.set_options(opt)
    if opt then
        options = opt
    end
end

return M
