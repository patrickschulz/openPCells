-- for random shuffle
math.randomseed(os.time())

-- load user configuration
config.get_user_config()

-- parse command line arguments
local argparse = _load_module("argparse")
argparse:load_options("cmdoptions")
local args = argparse:parse(arg)
-- check command line options sanity
if args.human and args.machine then
    errprint("you can't specify --human and --machine at the same time")
    os.exit(1)
end

if args.profile then
    profiler.start()
end

-- set environment variables
envlib.set("humannotmachine", true)
if args.human then
    envlib.set("humannotmachine", true)
end
if args.machine then
    envlib.set("humannotmachine", false)
end

-- set default path for pcells
pcell.add_cellpath(string.format("%s/cells", _get_opc_home()))

-- add user-defined cellpaths
if args.cellpath then
    for _, path in ipairs(args.cellpath) do
        pcell.add_cellpath(path)
    end
end

-- list available cells
if args.listcells then
    local sep = args.separator or "\n"
    local cells = pcell.list()
    io.write(table.concat(cells, sep) .. sep)
    os.exit(0)
end

if not args.cell then
    errprint("no cell type given")
    os.exit(1)
end

-- show technology constraints for this cell
if args.constraints then
    local sep = args.separator or "\n"
    local params = pcell.constraints(args.cell)
    io.write(table.concat(params, sep) .. sep)
    os.exit(0)
end

-- check and load technology
if not args.notech then
    if not args.technology and not args.params then
        errprint("no technology given")
        os.exit(1)
    elseif not args.technology and args.params then
        -- ok, don't load technology but also don't raise an error
    else 
        technology.load(args.technology)
    end
end

-- output cell parameters
if args.params then
    local sep = args.separator or "\n"
    local params = pcell.parameters(args.cell, not args.technology)
    io.write(table.concat(params, sep) .. sep)
    os.exit(0)
end

-- create cell
local cell, msg = pcell.create_layout(args.cell, args.cellargs, true)
if not cell then
    errprint(string.format("error while creating cell, received: %s", msg))
    os.exit(1)
end

-- move origin
if args.origin then
    local dx, dy = string.match(args.origin, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not dx then
        errprint(string.format("could not parse origin (%s)", args.origin))
        os.exit(1)
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
        os.exit(1)
    end
    f()
end

if not args.interface then
    errprint("no interface given")
    os.exit(1)
end
interface.load(args.interface)

local techintf = interface.get_techinterface() or args.interface
if not args.notech then
    technology.translate_metals(cell)
    technology.split_vias(cell)
    technology.place_via_conductors(cell, techintf)
    technology.translate(cell, techintf)
    technology.fix_to_grid(cell)
end

if not args.nointerface then
    local filename = args.filename or "openPCells"
    interface.set_options(args.interface_options)
    interface.write_cell(filename, cell, args.dryrun)
end

if args.profile then
    profiler.stop()
    profiler.display()
end

-- vim: ft=lua
