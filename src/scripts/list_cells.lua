local listformat -- parameter
local listallcells -- parameter

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
local cells = {}
for _, path in ipairs(args.cellpaths) do
    local baseinfo = {}
    local tree = support.dirtree(path)
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

local listformat = listformat or '::%p\n::  %b\n::    %c\n'
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
