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
_load_module("main.modules")
local functions = _load_module("main.functions")

-- call testsuite when called with 'test' as first argument
if arg[1] == "test" then
    table.remove(arg, 1)
    dofile(string.format("%s/src/testsuite/main.lua", _get_opc_home()))
    return 0
end

-- parse command line arguments
local args = _load_module("main.arguments")

-- technology file assistant
if args.techassistant then
    assistant.techfile()
    return 0
end

-- gds info functions
if args.showgdsdata then
    functions.show_gds_data(args.showgdsdata, args.showgdsdataflags, args.showgdsdatadepth, args.showgdsdataraw)
    return 0
end
if args.showgdshierarchy then
    functions.show_gds_hierarchy(args.showgdshierarchy, args.showgdsdatadepth)
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
    local filename = args.script
    local chunkname = string.format("@%s", filename)

    local reader = _get_reader(filename)
    if reader then
        local env = {
            arg = args.scriptargs or {}
        }
        _G.__index = _G
        setmetatable(env, _G)
        _dofile(reader, chunkname, nil, env)
    else
        moderror(string.format("opc --script: could not open script file '%s'", filename))
    end
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
    functions.list_cells(args.listformat, args.listallcells)
    return 0
end

if args.readverilog then
    local excluded_nets = args.verilogexcludednets

    local content = generator.from_verilog(
        args.readverilog, 
        args.verilogplacerutilization or 0.5,
        args.verilogplaceraspectratio or 1,
        args.verilogexcludednets or {},
        args.verilogreportplacement or false
    )
    local prefix = args.importprefix or "verilogimport"
    local libname = "verilogimport"
    local path = string.format("%s/%s", prefix, libname)
    if not filesystem.exists(path) or args.importoverwrite then
        generator.write_from_verilog(content, path)
    end
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
if not args.noparamfile then
    if args.prependparamfile then
        for _, pfile in ipairs(args.prependparamfile) do
            public.readpfile(pfile, cellargs)
        end
    end
    if args.appendparamfile then
        for _, pfile in ipairs(args.appendparamfile) do
            public.readpfile(pfile, cellargs)
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
    local reader = _get_reader(args.cellscript)
    if reader then
        cell = _dofile(reader, string.format("@%s", args.cellscript), nil, env)
        if not cell then
            print("cellscript did not return an object")
            return 1
        end
    else
        print(string.format("cellscript '%s' could not be opened", args.cellscript))
        return 1
    end
else
    cell = pcell.create_layout(args.cell, cellargs, nil, true) -- nil: no environment, true: evaluate parameters
end

-- move origin
if args.origin then
    local x, y = string.match(args.origin, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not x then
        moderror(string.format("could not parse origin (%s)", args.origin))
    end
    x, y = tonumber(x), tonumber(y)
    cell:move_to(x, y)
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

if args.drawanchor then
    for _, da in ipairs(args.drawanchor) do
        local anchor = cell:get_anchor(da)
        cell:merge_into_shallow(marker.cross(anchor))
    end
end

-- add drawing of alignment box
if args.drawalignmentbox or args.drawallalignmentboxes then
    local bl = cell:get_anchor("bottomleft")
    local tr = cell:get_anchor("topright")
    if bl and tr then
        geometry.rectanglebltr(cell, generics.special(), bl, tr)
    end
end
if args.drawallalignmentboxes then
    pcell.foreach_cell_references(function(cell)
        local bl = cell:get_anchor("bottomleft")
        local tr = cell:get_anchor("topright")
        if bl and tr then
            geometry.rectanglebltr(cell, generics.special(), bl, tr)
        end
    end)
end

-- filter layers
if args.layerfilter then
    postprocess.filter(cell, args.layerfilter, args.layerfilterlist)
end

if args.flatten then
    cell:flatten(args.flattenports)
end

if args.mergerectangles then
    postprocess.merge_shapes(cell)
end

if not args.export then
    moderror("no export type given")
end
if not args.noexport then
    --export.set_options(args.export_options)
    --export.check()
    if not generics.resolve_premapped_layers(args.exportlayers or args.export) then
        moderror(string.format("no layer data for export type '%s' found", args.exportlayers or args.export))
    end
    local filename = args.filename or "openPCells"
    local leftdelim, rightdelim = "", ""
    if args.busdelimiters then
        leftdelim, rightdelim = string.match(args.busdelimiters, "^(.)(.)$")
        if not leftdelim then
            moderror(string.format("--bus-delimiters: parse error. Expected two characters, got: '%s'", args.busdelimiters))
        end
    end
    export.set_bus_delimiters(leftdelim, rightdelim)
    export.write_toplevel(args.export, cell, filename, args.toplevelname or "opctoplevel", args.export_options, args.writechildrenports, args.dryrun)
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
