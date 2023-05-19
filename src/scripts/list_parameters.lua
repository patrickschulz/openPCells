-- FIXME: output cell parameters AFTER parameters have been processed in order to respect value changes in pfiles
-- FIXME: is args.generictech currently used and supported?
local params = pcell.parameters(args.cell, cellargs, args.generictech)
local paramformat = args.parametersformat or "%n %v"
for _, P in ipairs(params) do
    local paramstr = string.gsub(paramformat, "%%%a", { 
        ["%p"] = P.parent, 
        ["%t"] = P.ptype, 
        ["%n"] = P.name, 
        ["%d"] = P.display or "_NONE_", 
        ["%v"] = P.value,
        ["%a"] = P.argtype,
        ["%r"] = tostring(P.readonly),
        ["%o"] = P.posvals and P.posvals.type or "everything",
        ["%s"] = (P.posvals and P.posvals.values) and table.concat(P.posvals.values, ";") or ""
    })
    print(paramstr)
end
return 0
