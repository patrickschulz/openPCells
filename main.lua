-- parse command line arguments
argparse:load_options("cmdoptions")
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

-- check for script firsts, nothing gets defined for scripts
if args.script then
    dofile(args.script)
    return 0
end

if args.profile then
    profiler.start()
end

-- for random shuffle
math.randomseed(os.time())

-- load user configuration
if not args.nouserconfig then
    if not config.load_user_config() then
        return 1
    end
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

if args.listpaths then
    pcell.list_cellpaths()
    return 0
end

-- set environment variables
envlib.set("humannotmachine", true) -- default is --human
if args.machine then
    envlib.set("humannotmachine", false)
end
envlib.set("verbose", args.verbose)

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

if not args.cell then
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

-- read parameters from pfile and merge with command line parameters
local cellargs = {}
if args.paramfile then
    local t = dofile(args.paramfile)
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

-- output cell parameters AFTER parameters have been processed in order to respect value changes in pfiles
if args.params then
    local sep = args.separator or "\n"
    local params = pcell.parameters(args.cell, cellargs, not args.technology)
    io.write(table.concat(params, sep) .. sep)
    return 0
end

-- create cell
local status, cell = pcall(pcell.create_layout, args.cell, cellargs, true)
if not status then
    errprint(cell)
    return 1
end

-- move origin
if args.origin then
    local dx, dy = string.match(args.origin, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not dx then
        errprint(string.format("could not parse origin (%s)", args.origin))
        return 1
    end
    local cx, cy = cell.origin:unwrap()
    cell:translate(dx - cx, dy - cy)
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
        errprint(string.format("unknown orientation: %s", args.orientation))
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
    cell:merge_into(geometry.rectanglebltr(generics.special(), point.create(-5, factor * miny), point.create(5, factor * maxy)))
    cell:merge_into(geometry.rectanglebltr(generics.special(), point.create(factor * minx, -5), point.create(factor * maxx, 5)))
end

if args.drawanchor then
    for _, da in ipairs(args.drawanchor) do
        local anchor = cell:get_anchor(da)
        local x, y = anchor:unwrap()
        cell:merge_into(geometry.rectanglebltr(generics.special(), point.create(x - 5, y - 100), point.create(x + 5, y + 100)))
        cell:merge_into(geometry.rectanglebltr(generics.special(), point.create(x - 100, y - 5), point.create(x + 100, y + 5)))
    end
end

-- add drawing of alignment box
if args.drawalignmentbox then
    local ab = cell.alignmentbox
    if ab then
        local box = geometry.rectanglebltr(generics.special(), ab.bl, ab.tr)
        cell:merge_into(box)
    end
end

-- filter layers
if args.layerfilter then
    postprocess.filter(cell, args.layerfilter)
end

if not args.export then
    errprint("no export type given")
    return 1
end
export.load(args.export)

local techintf = export.get_techexport() or args.export
if not args.notech then
    technology.translate_metals(cell)
    technology.split_vias(cell)
    technology.place_via_conductors(cell, techintf)
    technology.translate(cell, techintf)
    technology.fix_to_grid(cell)
end

if not args.noexport then
    local filename = args.filename or "openPCells"
    export.set_options(args.export_options)
    export.write_cell(filename, cell, args.dryrun)
end

if args.profile then
    profiler.stop()
    profiler.display()
end

-- vim: ft=lua
