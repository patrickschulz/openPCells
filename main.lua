-- parse command line arguments
local argparse = _load_module("argparse")
argparse:load_options("cmdoptions")
local args = argparse:parse(arg)
-- check command line options sanity
if args.human and args.machine then
    errprint("you can't specify --human and --machine at the same time")
    return 1
end

-- check for script firsts, nothing gets defined for scripts
if args.script then
    dofile(args.script)
    --print("executing script... (not yet implemented)")
    return 0
end

-- for random shuffle
math.randomseed(os.time())

-- load user configuration
config.get_user_config()


if args.profile then
    profiler.start()
end

-- set environment variables
envlib.set("humannotmachine", true) -- default is --human
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
    for _, entry in ipairs(cells) do
        print(string.format("%s:", entry.path))
        for _, cellname in ipairs(entry.cells) do
            print(string.format("  %s", cellname))
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
    else 
        technology.load(args.technology)
    end
end

-- output cell parameters
if args.params then
    local sep = args.separator or "\n"
    local params = pcell.parameters(args.cell, not args.technology)
    io.write(table.concat(params, sep) .. sep)
    return 0
end

-- create cell
local cell = pcell.create_layout(args.cell, args.cellargs, true)

-- move origin
if args.origin then
    local dx, dy = string.match(args.origin, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not dx then
        errprint(string.format("could not parse origin (%s)", args.origin))
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

if not args.interface then
    errprint("no interface given")
    return 1
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
