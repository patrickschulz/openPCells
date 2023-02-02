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

-- process input (cmdline) parameters
local toevaluate = {}
local toevaluateparent = {}
for k, v in string.gmatch(table.concat(args.cellargs, " "), "([%w_/.]+)%s*=%s*(%S+)") do
    if string.match(k, "%.") then
        local parent, param = string.match(k, "(%w+%/%w+)%.(.+)")
        if not toevaluateparent[parent] then
            toevaluateparent[parent] = {}
        end
        toevaluateparent[parent][param] = v
    else
        toevaluate[k] = v
    end
end
local parameters = pcell.evaluate_parameters(args.cell, toevaluate)
for k, v in pairs(parameters) do
    cellargs[k] = v
end

for parent, paramstrings in pairs(toevaluateparent) do
    local parameters = pcell.evaluate_parameters(parent, paramstrings)
    pcell.push_overwrites(parent, parameters)
end

-- create cell
-- FIXME: create_layout_from_script does not take any cellargs
--        either put all cellargs-related processing in the 'else' clause and do proper error checking
--        or allow cellargs for cellscripts (not sure if useful)
pcell.enable_debug(args.debugcell)
pcell.enable_dprint(args.enabledprint)
local cell
if args.isscript then
    cell = pcell.create_layout_from_script(args.cell)
else
    cell = pcell.create_layout_env(args.cell, args.toplevelname, cellargs, args.cellenv)
end

for parent in pairs(toevaluateparent) do
    pcell.pop_overwrites(parent)
end

return cell
