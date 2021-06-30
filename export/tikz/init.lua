local M = {}

local baseunit = 100

local __standalone

function M.get_extension()
    return "tikz"
end

function M.get_techexport()
    return "svg"
end

function M.set_options(opt)
    if opt.standalone then
        __standalone = true
    end
end

function M.at_begin(file)
    if __standalone then
        file:write('\\documentclass{standalone}\n')
        file:write('\\usepackage{tikz}\n')
        file:write('\\begin{document}\n')
    end
    file:write('\\begin{tikzpicture}\n')
end

function M.at_end(file)
    file:write('\\end{tikzpicture}\n')
    if __standalone then
        file:write('\\end{document}\n')
    end
end

function M.get_layer(S)
    return S.lpp:get().color
end

--[[
function M.get_points(shape)
    if shape.typ == "polygon" then
        local pointlist = shape:concat_points(function(pt) return string.format("(%s)", pt:format(baseunit, ", ")) end)
        return table.concat(pointlist, " -- ")
    else
    end
end
--]]

function M.write_layer(file, layer, pcol)
    for _, pts in ipairs(pcol) do
        file:write(string.format('    \\fill[%s] %s;\n', layer, pts))
    end
end

function M.write_rectangle(file, layer, bl, tr)
    file:writenl(string.format("\\fill[%s] (%s) rectangle (%s);", layer, bl:format(baseunit, ", "), tr:format(baseunit, ", ")))
end

function M.write_polygon(file, layer, pts)
end

return M
