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
    "verilog_parser",
    "generator",
    "import",
    "pcell",
    "placement",
    "input",
    "assistant",
}
for _, module in ipairs(modules) do
    local path = module
    local name = module
    if string.match(module, "/") then
        name = string.match(module, "/([^/]+)$")
    end
    local mod = _load_module(path)
    if mod then
        _ENV[name] = mod
    end
end

-- call testsuite when called with 'test' as first argument
if arg[1] == "test" then
    table.remove(arg, 1)
    dofile(string.format("%s/src/testsuite/main.lua", _get_opc_home()))
    return 0
end

-- parse command line arguments
local argparse = cmdparser()
argparse:load_options_from_file(string.format("%s/src/%s.lua", _get_opc_home(), "cmdoptions"))
argparse:prepend_to_help_message([[
openPCells layout generator (opc) - Patrick Kurth 2020 - 2021

Generate layouts of integrated circuit geometry
opc supports technology-independent descriptions of parametric layout cells (pcells), 
which can be translated into a physical technology and exported to a file via a specific export.
]])
argparse:append_to_help_message([[

Most common usage examples:
   get cell parameter information:             opc --cell logic/dff --parameters
   create a cell:                              opc --technology TECH --export gds --cell logic/dff
   create a cell from a foreign collection:    opc --add-cellpath /path/to/collection --technology TECH --export gds --cell other/somecell
   create a cell by using a cellscript:        opc --technology TECH --export gds --cellscript celldef.lua
   read a GDS stream file and create cells:    opc --read-GDS stream.gds]])
local args, msg = argparse:parse(arg)
if not args then
    moderror(msg)
end
-- check command line options sanity
if args.human and args.machine then
    moderror("you can't specify --human and --machine at the same time")
end

if args.techassistant then
    assistant.techfile()
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
envlib.set("usefallbackvias", args.usefallbackvias)

-- gds info functions
if args.showgdsdata then
    local maxlevel = args.showgdsdatadepth and tonumber(args.showgdsdatadepth) or math.huge
    gdsparser.show_records(args.showgdsdata, args.showgdsdataflags or "all", args.showgdsdataraw, maxlevel)
    return 0
end
if args.showgdshierarchy then
    local gdslib = gdsparser.read_stream(args.showgdshierarchy)
    local cells = gdslib.cells
    local tree = gdsparser.resolve_hierarchy(cells)
    local maxlevel = args.showgdsdatadepth and tonumber(args.showgdsdatadepth) or math.huge
    for _, elem in ipairs(tree) do
        if elem.level < maxlevel then
            print(string.format("%s%s", string.rep("  ", elem.level), elem.cell.name))
        end
    end
    return 0
end

if args.readgds then
    local layermap = {}
    if args.gdslayermap then
        layermap = dofile(args.gdslayermap)
    end
    local gdslib = gdsparser.read_stream(args.readgds, args.gdsignorelpp)
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
        libname = string.gsub(args.readgds, "%.gds", "")
    end
    local namepattern = "(.+)"
    if args.importnamepattern then
        namepattern = args.importnamepattern
    end
    import.translate_cells(cells, args.importprefix, libname, layermap, alignmentboxinfo, args.importoverwrite, args.importflatpattern, namepattern)
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

-- list available cells
if args.listcells or args.listallcells then
    local cells = pcell.list_tree(args.listallcells)
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
    return 0
end

if args.readverilog then
    local excluded_nets = args.verilogexcludednets
    generator.from_verilog(
        args.readverilog, 
        args.readverilogdontcreatewires, 
        args.importprefix or "verilogimport", 
        "verilogimport", 
        true,
        args.verilogstdcelllib or "stdcell",
        args.verilogplacerutilization or 0.5,
        args.verilogplaceraspectratio or 1,
        args.verilogplacercellmovements or 1,
        args.verilogplacercoolingfactor or 0.95,
        args.verilogexcludednets or {},
        args.verilogreportplacement or false
    )
    return 0
end

if not args.cell and not args.cellscript then
    moderror("no cell type given")
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
        moderror("no technology given")
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
local function _readpfile(pfile)
    local status, t = pcall(_dofile, pfile)
    if not status then
        print(string.format("could not load parameter file '%s', error: %s", pfile, t))
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
if not args.noparamfile then
    if args.prependparamfile then
        for _, pfile in ipairs(args.prependparamfile) do
            _readpfile(pfile)
        end
    end
    if args.appendparamfile then
        for _, pfile in ipairs(args.appendparamfile) do
            _readpfile(pfile)
        end
    end
end
for k, v in pairs(args.cellargs) do
    cellargs[k] = v
end
if envlib.get("showcellargs") then
    aux.print_tabular(cellargs)
end

-- output cell parameters AFTER parameters have been processed in order to respect value changes in pfiles
if args.params then
    local params = pcell.parameters(args.cell, cellargs, not args.technology)
    local paramformat = args.parametersformat or "%n (%d) %v"
    for _, P in ipairs(params) do
        local paramstr = string.gsub(paramformat, "%%%a", { 
            ["%p"] = P.parent, 
            ["%t"] = P.ptype, 
            ["%n"] = P.name, 
            ["%d"] = P.display or "_NONE_", 
            ["%v"] = P.value,
            ["%a"] = P.argtype,
            ["%r"] = tostring(P.readonly),
            ["%o"] = P.posvals and P.posvals.type or "everything",
            ["%s"] = (P.posvals and P.posvals.values) and table.concat(P.posvals.values, ";") or ""
        })
        print(paramstr)
    end
    return 0
end

-- create cell
pcell.enable_debug(args.debugcell)
pcell.enable_dprint(args.enabledprint)
local cell
if args.cellscript then
    pcell.update_other_cell_parameters(cellargs, true)
    local status, c = pcall(_dofile, args.cellscript)
    if not status then
        moderror(string.format("cellscript has an error: %s", c))
    end
    if not c then
        moderror("cellscript did not return an object")
    end
    cell = c
else
    local status, c = pcall(pcell.create_layout, args.cell, cellargs, nil, true) -- nil: no environment, true: evaluate parameters
    if not status then
        moderror(c)
    end
    cell = c
end

-- move origin
if args.origin then
    local dx, dy = string.match(args.origin, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not dx then
        moderror(string.format("could not parse origin (%s)", args.origin))
    end
    dx, dy = tonumber(dx), tonumber(dy)
    --local cx, cy = cell.origin:unwrap()
    --cell:translate(dx - cx, dy - cy)
    -- FIXME: get origin from cell
    cell:translate(dx, dy)
end

-- translate
if args.translate then
    local dx, dy = string.match(args.translate, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not dx then
        moderror(string.format("could not parse translation (%s)", args.translate))
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
        moderror(string.format("unknown orientation: '%s'", args.orientation))
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
if args.drawallalignmentboxes then
    pcell.foreach_cell_references(function(cell)
        if cell.alignmentbox then
            local bl = cell:get_anchor("bottomleft")
            local tr = cell:get_anchor("topright")
            local box = geometry.rectanglebltr(generics.special(), bl, tr)
            cell:merge_into_shallow(box)
        end
    end)
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
    moderror("no export type given")
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
    cell:flatten(args.flattenports)
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
    local leftdelim, rightdelim = "", ""
    if args.busdelimiters then
        leftdelim, rightdelim = string.match(args.busdelimiters, "^(.)(.)$")
        if not leftdelim then
            moderror(string.format("--bus-delimiters: parse error. Expected two characters, got: '%s'", args.busdelimiters))
        end
    end
    export.set_bus_delimiters(leftdelim, rightdelim)
    export.write_toplevel(filename, args.technology, cell, args.toplevelname or "opctoplevel", args.writechildrenports, args.dryrun)
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
