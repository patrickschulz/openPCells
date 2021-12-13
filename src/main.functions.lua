local M = {}

function M.show_gds_data(filename, flags, depth, raw)
    gdsparser.show_records(filename, flags, raw, depth)
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

return M
