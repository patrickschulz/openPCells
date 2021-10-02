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

function M.write_layer(layer, pcol)
    for _, pts in ipairs(pcol) do
        table.insert(__content, string.format('    \\fill[%s] %s;', layer, pts))
    end
end

function M.write_rectangle(layer, bl, tr)
    table.insert(__content, string.format("\\fill[%s] (%s) rectangle (%s);", layer, bl:format(baseunit, ", "), tr:format(baseunit, ", ")))
end

function M.write_polygon(layer, pts)
end

return M
