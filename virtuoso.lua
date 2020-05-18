local M = {}

function M.print_points(pts, sep)
    local sep = sep or "\n"
    local max = 1000
    for i, pt in ipairs(pts) do
        if i > max then break end
        io.write(string.format("list(%.1f %.1f)%s", pt.x, pt.y, sep))
    end
end

return M
