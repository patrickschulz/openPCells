-- for random shuffle
math.randomseed(os.time())

-- load user configuration
config.get_user_config()

-- parse command line arguments
local argparse = _load_module("argparse")
local cmdopt = _load_module("cmdoptions")
argparse:register_options(cmdopt)
local args = argparse:parse(arg)

if args.profile then
    profiler.start()
end

-- list available cells
if args.listcells then
    local sep = args.separator or "\n"
    local cells = pcell.list()
    io.write(table.concat(cells, sep) .. sep)
    os.exit(0)
end

if not args.cell then
    error("no cell type given")
end

-- show technology constraints for this cell
if args.constraints then
    local sep = args.separator or "\n"
    local params = pcell.constraints(args.cell)
    io.write(table.concat(params, sep) .. sep)
    os.exit(0)
end

-- check and load technology
if not args.notech and not args.technology then
    error("no technology given")
end
if not args.notech then
    technology.load(args.technology)
end

-- output cell parameters
if args.params then
    local sep = args.separator or "\n"
    local params = pcell.parameters(args.cell)
    io.write(table.concat(params, sep) .. sep)
    os.exit(0)
end

-- prepare cell arguments
-- the gmatch/pattern expression splits expressions like 'foo=bar' into 'foo' and 'bar'
local cellargs = {}
for k, v in string.gmatch(table.concat(args.cellargs, " "), "([%w/._]+)%s*=%s*(%S+)") do
    cellargs[k] = v
end
local cell, msg = pcell.create_layout(args.cell, cellargs, true)
if not cell then
    error(string.format("error while creating cell, received: %s", msg))
end

-- move origin
if args.origin then
    local dx, dy = string.match(args.origin, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not dx then
        error(string.format("could not parse origin (%s)", args.origin))
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
        error(string.format("unknown orientation: %s", args.orientation))
    end
    f()
end

if not args.interface then
    error("no interface given")
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
