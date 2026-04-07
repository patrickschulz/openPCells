-- list_cells.lua
if not args.basepath or type(args.basepath) ~= "string" then
    error("did not receive any basepath (either nil or not a string)")
end

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

local function _write_html_start(file, header)
    file:write("<!doctype html>\n")
    file:write("<html lang=\"en\">\n")
    file:write("    @make_header OpenPCells Documentation\n")
    file:write("    <body>\n")
    file:write(string.format("        @make_topbar %s\n", header))
end

local function _write_html_end(file)
    file:write("        @include footer.html\n")
    file:write("    </body>\n")
    file:write("</html>\n")
end

local function _write_html_file(basepath, cellbase, cellname, info)
    local dirname = string.format("%s/%s", basepath, cellbase)
    filesystem.mkdir(dirname)
    local path = string.format("%s/%s.htmlpre", dirname, cellname)
    local file = io.open(path, "w")
    if not file then
        error(string.format("could not open file '%s'", path))
    end
    _write_html_start(file, string.format("Cell Information for '%s/%s'", cellbase, cellname))
    file:write(info)
    file:write("\n")
    _write_html_end(file)
    file:close()
end

-- write index file
local indexfile = io.open(args.indexfilename, "w")
if not indexfile then
    error(string.format("could not open index file '%s'", args.indexfilename))
end
_write_html_start(indexfile, "Cell Information Index")
local index = {}
for _, path in ipairs(cells) do
    for _, base in ipairs(path.baseinfo) do
        for _, cellfilename in ipairs(base.cellinfo) do
            local fullpath = string.format("%s/%s/%s", path.name, base.name, cellfilename)
            local cellname = string.match(cellfilename, "(.+)%.lua$")
            if cellname then
                indexfile:write(
                    string.format("        <p><a href=%s/%s/%s.html>Cell %s/%s</a></p>\n",
                        args.basepath, base.name, cellname, base.name, cellname
                    )
                )
            end
        end
    end
end
_write_html_end(indexfile)
indexfile:close()

-- write cell information
for _, path in ipairs(cells) do
    for _, base in ipairs(path.baseinfo) do
        for _, cellfilename in ipairs(base.cellinfo) do
            local fullpath = string.format("%s/%s/%s", path.name, base.name, cellfilename)
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
                local cellname = string.match(cellfilename, "(.+)%.lua$")
                if cellname then
                    _write_html_file(args.basepath, base.name, cellname, info)
                end
            end
        end
    end
end
