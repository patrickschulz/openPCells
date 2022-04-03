-- load API
_load_module("main.modules")

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

-- create cell
pcell.enable_debug(args.debugcell)
pcell.enable_dprint(args.enabledprint)
pcell.update_other_cell_parameters(cellargs, true)
local reader = _get_reader(args.cellscript)
local cell
if reader then
    cell = _dofile(reader, string.format("@%s", args.cellscript), nil, env)
    if not cell then
        print("cellscript did not return an object")
        return nil
    end
else
    print(string.format("cellscript '%s' could not be opened", args.cellscript))
    return nil
end

return cell
