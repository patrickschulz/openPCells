local M = {}

function M.get_extension()
    return "tikz"
end

local function _write_shape(file, shape)
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
    file:write('\\begin{tikzpicture}\n')
end

function M.at_end(file)
    file:write('\\end{tikzpicture}\n')
end

function M.get_layer(shape)
    return "unused"
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
        file:write(string.format('    \\draw %s rectangle %s;\n', pts.first, pts.second))
    end
end

return M
