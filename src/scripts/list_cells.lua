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
if args.cellnames then -- filter for matching parameters
    local cells = {}
    local function _gather_cells(path, indent)
        local indentstr = string.rep("  ", indent)
        local files = dir.walk(path)
        for _, file in ipairs(files) do
            if file.type == "directory" then
                if file.name ~= "." and file.name ~= ".." then
                    local subpath = string.format("%s/%s", path, file.name)
                    _gather_cells(subpath, indent + 1)
                end
            else
                local name = string.sub(file.name, 1, -5) -- strip '.lua'
                local dirname, basename = string.match(path, "(.+)/([^/]+)$")
                table.insert(cells, {
                    parent = basename,
                    name = name,
                })
            end
        end
    end

    for _, path in ipairs(args.cellpaths) do
        _gather_cells(path, 0)
    end
    for _, cell in ipairs(cells) do
        local show
        if not args.cellnames then
            show = true
        else
            for _, cellname in ipairs(args.cellnames) do
                if string.match(cell.parent, cellname) or string.match(cell.name, cellname) then
                    show = true
                end
            end
        end
        if show then
            print(string.format("%s/%s", cell.parent, cell.name))
        end
    end
else
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

    local listformat = args.listformat or '::%p\n::  %b\n::    %c\n'
    -- replace \\n with \n
    listformat = string.gsub(listformat, "\\n", "\n")
    local prefmt, postfmt, prepathfmt, postpathfmt, prebasefmt, postbasefmt, cellfmt = table.unpack(aux.strsplit(listformat, ":"))
    io.write(prefmt)
    for _, path in ipairs(cells) do
        local prepathstr = string.gsub(prepathfmt, "%%%a", { ["%p"] = path.name })
        io.write(prepathstr)
        for _, base in ipairs(path.baseinfo) do
            local prebasestr = string.gsub(prebasefmt, "%%%a", { ["%p"] = path.name, ["%b"] = base.name })
            io.write(prebasestr)
            for _, cellname in ipairs(base.cellinfo) do
                local cellstr = string.gsub(cellfmt, "%%%a", { ["%p"] = path.name, ["%b"] = base.name, ["%c"] = string.match(cellname, "^([%w_/]+)%.lua$") })
                io.write(cellstr)
            end
            local postbasestr = string.gsub(postbasefmt, "%%%a", { ["%p"] = path.name, ["%b"] = base.name })
            io.write(postbasestr)
        end
        local postpathstr = string.gsub(postpathfmt, "%%%a", { ["%p"] = path.name })
        io.write(postpathstr)
    end
    io.write(postfmt)

    --[[ FIXME: much simpler approach, but does not support arbitrary formatting. Adapt.
    local function _list_cells(path, indent)
        local indentstr = string.rep("  ", indent)
        local files = dir.walk(path)
        for _, file in ipairs(files) do
            if file.type == "directory" then
                if file.name ~= "." and file.name ~= ".." then
                    print(string.format("%s%s", indentstr, file.name))
                    local subpath = string.format("%s/%s", path, file.name)
                    _list_cells(subpath, indent + 1)
                end
            else
                local name = string.sub(file.name, 1, -5) -- strip '.lua'
                print(string.format("%s%s", indentstr, name))
            end
        end
    end

    for _, path in ipairs(args.cellpaths) do
        _list_cells(path, 0)
    end
    --]]
end
