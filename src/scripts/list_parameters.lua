-- FIXME: output cell parameters AFTER parameters have been processed in order to respect value changes in pfiles
-- FIXME: is args.generictech currently used and supported?

-- get cell parameters
local params = pcell.parameters(args.cell, cellargs, args.generictech)

-- configure format
local paramformat = args.parametersformat or "%n (%a) (default: %v)\t\t%i"

-- gather parameters to be printed (initially all of them, then apply name filter)
local printlist = {}
for _, P in ipairs(params) do
    table.insert(printlist, P)
end
if args.parameternames then -- filter for matching parameters
    local matched = false
    if #args.parameternames == 1 then -- look for exact match
        local fmt = string.format("^%s$", args.parameternames[1])
        local index
        for i, P in ipairs(printlist) do
            if string.match(P.name, fmt) then
                matched = true
                index = i
            end
        end
        if matched then
            for i = #printlist, 1, -1 do -- iterate backwards for easier element removal
                if i ~= index then
                    table.remove(printlist, i)
                end
            end
        end
    end
    if not matched then -- exact match failed or multiple names
        for _, name in ipairs(args.parameternames) do
            for i = #printlist, 1, -1 do -- iterate backwards for easier element removal
                if not string.match(printlist[i].name, name) then
                    table.remove(printlist, i)
                end
            end
        end
    end
end

-- print parameters according to format
if #printlist == 1 then -- only one parameter, list additional info
    local P = printlist[1]
    local t = {}
    table.insert(t, string.format("%s", P.name))
    local vt = {}
    table.insert(vt, string.format("%s", P.argtype))
    table.insert(vt, string.format("%q", P.value))
    if P.posvals then
        table.insert(vt, string.format("%s(%s)", P.posvals.type, util.tconcatfmt(P.posvals.values, ", ", "\"%s\"")))
    end
    table.insert(t, " (" .. table.concat(vt, ", ") .. ")")
    if P.info then
        table.insert(t, string.format("\n-> %s", P.info))
    end
    print(table.concat(t))
else
    for _, P in ipairs(printlist) do
        local paramstr = string.gsub(paramformat, "%%%a", { 
            ["%n"] = P.name, 
            ["%d"] = P.display or "_NONE_", 
            ["%v"] = P.value,
            ["%a"] = P.argtype,
            ["%i"] = P.info or "",
            ["%r"] = tostring(P.readonly),
            ["%o"] = P.posvals and P.posvals.type or "everything",
            ["%p"] = (P.posvals and P.posvals.values) and table.concat(P.posvals.values, ";") or ""
        })
        print(paramstr)
    end
end
