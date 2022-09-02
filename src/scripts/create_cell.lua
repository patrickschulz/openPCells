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
for k, v in string.gmatch(table.concat(args.cellargs, " "), "([%w_/.]+)%s*=%s*(%S+)") do
    cellargs[k] = v
end

-- create cell
pcell.enable_debug(args.debugcell)
pcell.enable_dprint(args.enabledprint)
local parameters = pcell.evaluate_parameters(args.cell, cellargs)
if args.isscript then
    local cell = pcell.create_layout_from_script(args.cell, parameters)
    return cell
else
    local cell = pcell.create_layout(args.cell, parameters)
    return cell
end
