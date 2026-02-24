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



-- list_parameters.lua
-- FIXME: output cell parameters AFTER parameters have been processed in order to respect value changes in pfiles
-- FIXME: is args.generictech currently used and supported?

-- get cell parameters
local params = pcell.parameters(args.cell, cellargs, args.generictech)

-- configure format
local paramformat = args.parametersformat or "%n (%a) (default: %v)\t\t%i"

-- gather parameters to be printed (initially all of them, then apply name filter)
local printlist = {}
for _, P in ipairs(params) do
    table.insert(printlist, P)
end
if args.parameternames then -- filter for matching parameters
    local matched = false
    if #args.parameternames == 1 then -- look for exact match
        local fmt = string.format("^%s$", args.parameternames[1])
        local index
        for i, P in ipairs(printlist) do
            if string.match(P.name, fmt) then
                matched = true
                index = i
            end
        end
        if matched then
            for i = #printlist, 1, -1 do -- iterate backwards for easier element removal
                if i ~= index then
                    table.remove(printlist, i)
                end
            end
        end
    end
    if not matched then -- exact match failed or multiple names
        for _, name in ipairs(args.parameternames) do
            for i = #printlist, 1, -1 do -- iterate backwards for easier element removal
                if not string.match(printlist[i].name, name) then
                    table.remove(printlist, i)
                end
            end
        end
    end
end

-- print parameters according to format
if #printlist == 1 then -- only one parameter, list additional info
    local P = printlist[1]
    local t = {}
    table.insert(t, string.format("%s", P.name))
    local vt = {}
    table.insert(vt, string.format("%s", P.argtype))
    table.insert(vt, string.format("%q", P.value))
    if P.posvals then
        table.insert(vt, string.format("%s(%s)", P.posvals.type, util.tconcatfmt(P.posvals.values, ", ", "\"%s\"")))
    end
    table.insert(t, " (" .. table.concat(vt, ", ") .. ")")
    if P.info then
        table.insert(t, string.format("\n-> %s", P.info))
    end
    print(table.concat(t))
else
    for _, P in ipairs(printlist) do
        local paramstr = string.gsub(paramformat, "%%%a", { 
            ["%n"] = P.name, 
            ["%d"] = P.display or "_NONE_", 
            ["%v"] = P.value,
            ["%a"] = P.argtype,
            ["%i"] = P.info or "",
            ["%r"] = tostring(P.readonly),
            ["%o"] = P.posvals and P.posvals.type or "everything",
            ["%p"] = (P.posvals and P.posvals.values) and table.concat(P.posvals.values, ";") or ""
        })
        print(paramstr)
    end
end
