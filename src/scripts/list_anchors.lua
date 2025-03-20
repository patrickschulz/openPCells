local anchors = pcell.anchors(args.cell, cellargs)
local sorted = {}
for k, v in pairs(anchors) do
    table.insert(sorted, { name = k, info = v.info, conditions = v.conditions })
end
table.sort(sorted, function(a, b) return a.name < b.name end)

for _, entry in ipairs(sorted) do
    local doprint = true
    if args.anchornames then
        doprint = util.any_of(function(name) return string.match(entry.name, name) end, args.anchornames or {})
    end
    if doprint then
        print(string.format("anchor: %s\n  info: %s\n  conditions: %s", entry.name, entry.info, entry.conditions or "none"))
    end
end
