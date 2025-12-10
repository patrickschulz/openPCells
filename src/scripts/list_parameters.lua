-- FIXME: output cell parameters AFTER parameters have been processed in order to respect value changes in pfiles
-- FIXME: is args.generictech currently used and supported?
local params = pcell.parameters(args.cell, cellargs, args.generictech)
local paramformat = args.parametersformat or "%n (%a) (default: %v)\t\t%i"
local printlist = {}
for _, P in ipairs(params) do
    table.insert(printlist, P)
end
if args.parameternames then -- filter for matching parameters
    for _, name in ipairs(args.parameternames) do
        for i = #printlist, 1, -1 do -- iterate backwards for easier element removal
            if not string.match(printlist[i].name, name) then
                table.remove(printlist, i)
            end
        end
    end
end
for _, P in ipairs(printlist) do
    local paramstr = string.gsub(paramformat, "%%%a", { 
        ["%n"] = P.name, 
        ["%d"] = P.display or "_NONE_", 
        ["%v"] = P.value,
        ["%a"] = P.argtype,
        ["%i"] = P.info or "",
        ["%r"] = tostring(P.readonly),
        ["%o"] = P.posvals and P.posvals.type or "everything",
        ["%s"] = (P.posvals and P.posvals.values) and table.concat(P.posvals.values, ";") or ""
    })
    print(paramstr)
end
return 0
