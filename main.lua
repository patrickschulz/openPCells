-- exit and write a short helpful message if called without any arguments
if #arg == 0 then
    print("This is the openPCell layout generator.")
    print("To generate a layout, you need to pass the technology, the export type and a cellname.")
    print("Example:")
    print("         opc --technology skywater130 --export gds --cell logic/not_gate")
    print()
    print("You can find out more about the available command line options by running 'opc -h'.")
    return 1
end

-- load API
local modules = {
    "profiler",
    "cmdparser",
    "lpoint",
    "technology",
    "postprocess",
    "export",
    "config",
    "object",
    "transformationmatrix",
    "shape",
    "geometry",
    "graphics",
    "generics",
    "stringfile",
    "util",
    "aux",
    "reduce",
    "stack",
    "support",
    "envlib",
    "globals",
    "union",
    "marker",
    "support/gdstypetable",
    "gdsparser",
    "import",
    "pcell",
}
for _, module in ipairs(modules) do
    local path = module
    local name = module
    if string.match(module, "/") then
        name = string.match(module, "/([^/]+)$")
    end
    _ENV[name] = _load_module(path)
end

-- call testsuite when called with 'test' as first argument
if arg[1] == "test" then
    table.remove(arg, 1)
    dofile(string.format("%s/testsuite/main.lua", _get_opc_home()))
    return 0
end

-- parse command line arguments
local argparse = cmdparser()
argparse:load_options_from_file("cmdoptions")
argparse:append_to_help_message("")
argparse:append_to_help_message("Most common usage examples:")
argparse:append_to_help_message("   get cell parameter information:             opc --cell logic/dff --parameters")
argparse:append_to_help_message("   create a cell:                              opc --technology TECH --export gds --cell logic/dff")
argparse:append_to_help_message("   create a cell from a foreign collection:    opc --add-cellpath /path/to/collection --technology TECH --export gds --cell other/somecell")
argparse:append_to_help_message("   create a cell by using a cellscript:        opc --technology TECH --export gds --cellscript celldef.lua")
argparse:append_to_help_message("   read a GDS stream file and create cells:    opc --read-GDS stream.gds")
local args, msg = argparse:parse(arg)
if not args then
    errprint(msg)
    return 1
end
-- check command line options sanity
if args.human and args.machine then
    errprint("you can't specify --human and --machine at the same time")
    return 1
end

-- gds info functions
if args.showgdsdata then
    gdsparser.show_records(args.showgdsdata, args.showgdsdataflags or "all")
    return 0
end
if args.showgdshierarchy then
    local cells = gdsparser.read_cells(args.showgdshierarchy)
    local tree = gdsparser.resolve_hierarchy(cells)
    for _, elem in ipairs(tree) do
        print(string.format("%s%s", string.rep("  ", elem.level), elem.cell.name))
    end
    return 0
end

if args.readgds then
    local layermap = {}
    if args.gdslayermap then
        layermap = dofile(args.gdslayermap)
    end
    local cells = gdsparser.read_cells(args.readgds)
    import.translate_cells(cells, string.gsub(args.readgds, "%.gds", ""), layermap)
    return 0
end

-- check for script firsts, nothing gets defined for scripts
if args.script then
    dofile(args.script)
    return 0
end

if args.profile then
    profiler.start()
end

if args.watch then
    print("sorry, watch mode is currently not implemented")
    return 1
end

-- for random shuffle
if args.seed then
    math.randomseed(args.seed)
else
    math.randomseed(os.time())
end

-- set default path for pcells
pcell.append_cellpath(string.format("%s/cells", _get_opc_home()))
-- add user-defined cellpaths
if args.cellpath then
    for _, path in ipairs(args.cellpath) do
        pcell.append_cellpath(path)
    end
end
if args.prependcellpath then
    for _, path in ipairs(args.prependcellpath) do
        pcell.prepend_cellpath(path)
    end
end

-- set default path for exports
export.add_path(string.format("%s/export", _get_opc_home()))

-- load user configuration
if not args.nouserconfig then
    if not config.load_user_config(argparse) then
        return 1
    end
end

if args.listcellpaths then
    pcell.list_cellpaths()
    return 0
end

-- set default path for technology files
technology.add_techpath(string.format("%s/tech", _get_opc_home()))
-- add user-defined cellpaths
if args.techpath then
    for _, path in ipairs(args.techpath) do
        technology.add_techpath(path)
    end
end

if args.listtechpaths then
    technology.list_techpaths()
    return 0
end

-- set environment variables
envlib.set("debug", args.debug)
envlib.set("humannotmachine", true) -- default is --human
if args.machine then
    envlib.set("humannotmachine", false)
end
envlib.set("verbose", args.verbose)
if args.ignoremissinglayers then
    envlib.set("ignoremissinglayers", true)
end
if args.ignoremissingexport then
    envlib.set("ignoremissingexport", true)
end

-- list available cells
if args.listcells or args.listallcells then
    local sep = args.separator or "\n"
    local cells = pcell.list(args.listallcells)
    for _, entry in ipairs(cells) do
        infoprint(string.format("%s:", entry.path))
        for _, cellname in ipairs(entry.cells) do
            infoprint(string.format("  %s", cellname))
        end
    end
    return 0
end

if not args.cell and not args.cellscript then
    errprint("no cell type given")
    return 1
end

if args.check then
    pcell.check(args.cell)
    return 0
end

-- show technology constraints for this cell
if args.constraints then
    local sep = args.separator or "\n"
    local params = pcell.constraints(args.cell)
    io.write(table.concat(params, sep) .. sep)
    return 0
end

-- check and load technology
if not args.notech then
    if not args.technology and not args.params then
        errprint("no technology given")
        return 1
    elseif not args.technology and args.params then
        -- ok, don't load technology but also don't raise an error
        -- this enables pcell.parameters to display the cell parameters with generic technology expressions
        -- this empty elseif clause is left to express intent
    else 
        technology.load(args.technology)
    end
end

--[[
if args.checktech then
    return 0
end
--]]

-- read parameters from pfile and merge with command line parameters
local cellargs = {}
if args.paramfile and not args.noparamfile then
    local status, t = pcall(_dofile, args.paramfile)
    if not status then
        print(string.format("could not load parameter file '%s', error: %s", args.paramfile, t))
        return 1
    end
    for cellname, params in pairs(t) do
        if type(params) == "table" then
            for n, p in pairs(params) do
                cellargs[string.format("%s.%s", cellname, n)] = p
            end
        else -- direct parameter for the cell, cellname == parameter name
            cellargs[cellname] = params
        end
    end
end
for k, v in pairs(args.cellargs) do
    cellargs[k] = v
end
if envlib.get("debug") then
    aux.print_tabular(cellargs)
end

-- output cell parameters AFTER parameters have been processed in order to respect value changes in pfiles
if args.params then
    local sep = args.separator or "\n"
    local params = pcell.parameters(args.cell, cellargs, not args.technology)
    io.write(table.concat(params, sep) .. sep)
    return 0
end

-- create cell
pcell.enable_debug(args.debugcell)
local cell
if args.cellscript then
    pcell.update_other_cell_parameters(cellargs, true)
    local status, c = pcall(_dofile, args.cellscript)
    if not status then
        errprint(c)
        return 1
    end
    if not c then
        errprint("cellscript did not return an object")
        return 1
    end
    cell = c
else
    local status, c = pcall(pcell.create_layout, args.cell, cellargs, true)
    if not status then
        errprint(c)
        return 1
    end
    cell = c
end

-- move origin
if args.origin then
    local dx, dy = string.match(args.origin, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not dx then
        errprint(string.format("could not parse origin (%s)", args.origin))
        return 1
    end
    --local cx, cy = cell.origin:unwrap()
    --cell:translate(dx - cx, dy - cy)
    -- FIXME: get origin from cell
    cell:translate(dx, dy)
end

-- translate
if args.translate then
    local dx, dy = string.match(args.translate, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not dx then
        errprint(string.format("could not parse translation (%s)", args.translate))
        return 1
    end
    cell:translate(dx, dy)
end

-- orientation
if args.orientation then
    local lut = {
        ["0"] = function() end, -- do nothing, but allow this as command line option
        ["fx"] = function() cell:flipx() end,
        ["fy"] = function() cell:flipy() end,
        ["fxy"] = function() cell:flipx(); cell:flipy() end,
    }
    local f = lut[args.orientation]
    if not f then
        errprint(string.format("unknown orientation: '%s'", args.orientation))
        return 1
    end
    f()
end

-- add axes
if args.drawaxes then
    local bb = cell:bounding_box()
    local minx, miny = bb.bl:unwrap()
    local maxx, maxy = bb.tr:unwrap()
    local factor = 2
    cell:merge_into_shallow(geometry.rectanglebltr(generics.special(), point.create(-5, factor * miny), point.create(5, factor * maxy)))
    cell:merge_into_shallow(geometry.rectanglebltr(generics.special(), point.create(factor * minx, -5), point.create(factor * maxx, 5)))
end

if args.drawanchor then
    for _, da in ipairs(args.drawanchor) do
        local anchor = cell:get_anchor(da)
        cell:merge_into_shallow(marker.cross(anchor))
    end
end

-- add drawing of alignment box
if args.drawalignmentbox then
    if cell.alignmentbox then
        local bl = cell:get_anchor("bottomleft")
        local tr = cell:get_anchor("topright")
        local box = geometry.rectanglebltr(generics.special(), bl, tr)
        cell:merge_into_shallow(box)
    end
end

technology.prepare(cell)

-- filter layers (pre)
if args.prelayerfilter then
    -- filter toplevel (flat shapes)
    postprocess.filter(cell, args.prelayerfilter, args.prelayerfilterlist or "black")
    -- filter children
    pcell.foreach_cell_references(postprocess.filter, args.prelayerfilter, args.prelayerfilterlist or "black")
end

if not args.export then
    errprint("no export type given")
    return 1
end
export.load(args.export)

local techintf = export.get_techexport() or args.export
if not args.notech and techintf ~= "raw" then
    technology.translate(cell, techintf)
end

-- filter layers (post)
if args.postlayerfilter then
    -- filter toplevel (flat shapes)
    postprocess.filter(cell, args.postlayerfilter, args.postlayerfilterlist or "black")
    -- filter children
    pcell.foreach_cell_references(postprocess.filter, args.postlayerfilter, args.postlayerfilterlist or "black")
end

if args.flatten then
    cell:flatten()
end

if args.mergerectangles then
    -- merge toplevel (flat shapes)
    reduce.merge_shapes(cell)
    -- merge children
    pcell.foreach_cell_references(reduce.merge_shapes)
end

if not args.noexport then
    export.set_options(args.export_options)
    export.check()
    local filename = args.filename or "openPCells"
    export.write_toplevel(filename, args.technology, cell, args.dryrun)
end

if args.cellinfo then
    print(string.format("number of shapes: %d", #cell.shapes))
    print("used layers:")
    for _, lpp in cell:layers() do
        print(string.format("  %s", lpp:str()))
    end
end

if args.profile then
    profiler.stop()
    profiler.display()
end

-- vim: ft=lua
