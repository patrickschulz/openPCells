local gdslib = gdsparser.read_stream(filename)
local cells = gdslib.cells
local tree = gdsparser.resolve_hierarchy(cells)
local maxlevel = depth and tonumber(depth) or math.huge
for _, elem in ipairs(tree) do
    if elem.level < maxlevel then
        print(string.format("%s%s", string.rep("  ", elem.level), elem.cell.name))
    end
end
