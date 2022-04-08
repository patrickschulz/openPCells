-- load API
_load_module("main.modules")

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
for k, v in string.gmatch(table.concat(args.cellargs, " "), "(%w+)%s*=%s*(%S+)") do
    cellargs[k] = v
end

if args.isscript then
    -- create cell
    pcell.enable_debug(args.debugcell)
    pcell.enable_dprint(args.enabledprint)
    pcell.update_other_cell_parameters(cellargs, true)
    local reader = _get_reader(args.cell)
    if reader then
        local cell = _dofile(reader, string.format("@%s", args.cell), nil, env)
        if not cell then
            print("cellscript did not return an object")
            return nil
        end
        return cell
    else
        print(string.format("cellscript '%s' could not be opened", args.cell))
        return nil
    end
else
    pcell.enable_debug(args.debugcell)
    pcell.enable_dprint(args.enabledprint)
    local cell = pcell.create_layout(args.cell, cellargs, nil, true) -- nil: no environment, true: evaluate parameters
    return cell
end
