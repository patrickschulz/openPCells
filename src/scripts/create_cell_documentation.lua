-- list_cells.lua

local function _collect_cells_tree(path)
    local children = {}
    for _, entry in ipairs(dir.walk(path)) do
        if entry.name:sub(1, 1) ~= "." then
            local elem = { name = entry.name }
            if entry.type == "directory" then
                elem.children = _collect_cells_tree(string.format("%s/%s", path, entry.name))
            end
            table.insert(children, elem)
        end
    end
    return children
end

local function _dirtree(path)
    return { name = path, children = _collect_cells_tree(path) }
end

local function _traverse_tree(tree)
    if tree.children then
        local elements = {}
        for _, child in ipairs(tree.children) do
            local t = _traverse_tree(child)
            for _, tt in ipairs(t) do
                local elem = { tree.name }
                for _, e in ipairs(tt) do
                    table.insert(elem, e)
                end
                table.insert(elements, elem)
            end
        end
        return elements
    else
        return { { tree.name } }
    end
end

-- the behaviour changes when cellnames as filter are present
local cells = {}
for _, path in ipairs(args.cellpaths) do
    local baseinfo = {}
    local tree = _dirtree(path)
    for _, base in ipairs(tree.children) do
        local cellinfo = {}
        for _, info in ipairs(_traverse_tree(base)) do
            table.remove(info, 1) -- remove base
            table.insert(cellinfo, table.concat(info, "/"))
        end
        table.sort(cellinfo)
        table.insert(baseinfo, { name = base.name, cellinfo = cellinfo })
    end
    table.sort(baseinfo, function(l, r) return l.name < r.name end)
    table.insert(cells, { name = path, baseinfo = baseinfo })
end
table.sort(cells, function(l, r) return l.name < r.name end)

for _, path in ipairs(cells) do
    for _, base in ipairs(path.baseinfo) do
        for _, cellname in ipairs(base.cellinfo) do
            local fullpath = string.format("%s/%s/%s", path.name, base.name, cellname)
            local env = {
                string = string,
                table = table,
            }
            local chunk, msg = loadfile(fullpath, "t", env)
            if not chunk then
                error(msg)
            end
            chunk()
            if env.info then
                local info = env.info()
                print(string.format("%s:", cellname))
                print()
                print(info)
                print()
            end
        end
    end
end
