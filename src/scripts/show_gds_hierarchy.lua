local tree = gdsparser.get_hierarchy(filename)
local maxlevel = depth and tonumber(depth) or math.huge
for _, elem in ipairs(tree) do
    if elem.level < maxlevel then
        print(string.format("%s%s", string.rep("  ", elem.level), elem.cell.name))
    end
end
