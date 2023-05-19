-- read parameters from pfile and merge with command line parameters
local cellargs = {}
if not args.noparamfile or args.isscript then -- cellscripts don't support pfiles; FIXME: why not? they could accept parent parameter overwrites
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
-- for cellscripts, only parent parameters are evaluated
local toevaluate = {} -- will be evaluated if a cell is created from a cell definition, not a cell script
local toevaluateparent = {}
local additionalargs = {}
for _, arg in ipairs(args.cellargs) do
    local key, value = string.match(arg, "([%w_/.]+)%s*=%s*(%S+)")
    if not key then -- argument is not a key-value-pair, don't parse and pass it as additional argument (FIXME: only relevant for cell scripts?)
        table.insert(additionalargs, arg)
    else
        if string.match(key, "%.") then -- parent-cell parameter
            local parent, param = string.match(key, "(%w+%/%w+)%.(.+)")
            if not toevaluateparent[parent] then
                toevaluateparent[parent] = {}
            end
            toevaluateparent[parent][param] = value
        else
            toevaluate[key] = value
        end
    end
end

-- evaluate parent cell parameters (also relevant for cell scripts)
for parent, paramstrings in pairs(toevaluateparent) do
    local parameters = pcell.evaluate_parameters(parent, paramstrings)
    pcell.push_overwrites(parent, parameters)
end

-- create cell
pcell.enable_debug(args.debugcell)
pcell.enable_dprint(args.enabledprint)
local cell
if args.isscript then
    cell = pcell.create_layout_from_script(args.cell, additionalargs)
else
    if #additionalargs > 0 then
        error("creating a cell from a cell definition, but additional positional arguments (non-key-value pairs) are present")
    end
    -- evaluate cell parameters (also overwrite parameters from pfiles)
    local parameters = pcell.evaluate_parameters(args.cell, toevaluate)
    for k, v in pairs(parameters) do
        cellargs[k] = v
    end
    cell = pcell.create_layout_env(args.cell, args.toplevelname, cellargs, args.cellenv)
end

for parent in pairs(toevaluateparent) do
    pcell.pop_overwrites(parent)
end

return cell
