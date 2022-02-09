local M = {}

function M.show_gds_data(filename, flags, depth, raw)
    local status, msg = gdsparser.show_records(filename, flags, raw, depth)
    if not status then
        moderror(msg)
    end
end

function M.show_gds_hierarchy(filename, depth)
    local gdslib = gdsparser.read_stream(filename)
    local cells = gdslib.cells
    local tree = gdsparser.resolve_hierarchy(cells)
    local maxlevel = depth and tonumber(depth) or math.huge
    for _, elem in ipairs(tree) do
        if elem.level < maxlevel then
            print(string.format("%s%s", string.rep("  ", elem.level), elem.cell.name))
        end
    end
end

function M.read_gds(filename, layermap, ignorelpp, gdsalignmentbox)
    local gdslib = gdsparser.read_stream(filename, gdsignorelpp)
    local cells = gdslib.cells
    local alignmentboxinfo
    if args.gdsalignmentboxlayer and args.gdsalignmentboxpurpose then
        alignmentboxinfo = { layer = tonumber(args.gdsalignmentboxlayer), purpose = tonumber(args.gdsalignmentboxpurpose) }
    end
    local libname
    if args.gdsusestreamlibname then
        libname = gdslib.libname
    elseif args.importlibname then
        libname = args.importlibname
    else
        libname = string.gsub(filename, "%.gds", "")
    end
    local namepattern = "(.+)"
    if args.importnamepattern then
        namepattern = args.importnamepattern
    end
    import.translate_cells(cells, args.importprefix, libname, layermap, alignmentboxinfo, args.importoverwrite, args.importflatpattern, namepattern)
end

function M.list_cells(listformat, listallcells)
    local cells = pcell.list_tree(listallcells)
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
end

return M
