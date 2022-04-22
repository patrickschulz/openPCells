-- read parameters from pfile and merge with command line parameters
local cellargs = {}
if not args.noparamfile or args.isscript then -- cellscripts don't support pfiles; FIXME: why not?
    for _, pfilename in ipairs(args.pfilenames) do
        local chunk, msg = loadfile(pfilename)
        if not chunk then
            print(msg)
            -- print error message but continue
        else
            local t = chunk()
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
    end
end
for k, v in string.gmatch(table.concat(args.cellargs, " "), "([%w_]+)%s*=%s*(%S+)") do
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
