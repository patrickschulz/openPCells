local M = {}

function M.print_points(pts)
    local sep = sep or "\n"
    local filename = os.tmpname()
    print(filename)
    local file = io.open(filename, "w")
    for i, pt in ipairs(pts) do
        file:write(string.format("%.1f %.1f%s", pt.x, pt.y, sep))
    end
    file:close()
end

return M
