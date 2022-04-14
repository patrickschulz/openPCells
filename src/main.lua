-- load API
_load_module("main.modules")
local functions = _load_module("main.functions")

-- call testsuite when called with 'test' as first argument
if arg[1] == "test" then
    table.remove(arg, 1)
    dofile(string.format("%s/src/testsuite/main.lua", _get_opc_home()))
    return 0
end

-- for random shuffle
if args.seed then
    math.randomseed(args.seed)
else
    math.randomseed(os.time())
end

-- list available cells
if args.listcells or args.listallcells then
    functions.list_cells(args.listformat, args.listallcells)
    return 0
end

if args.readverilog then
    local excluded_nets = args.verilogexcludednets

    local content = generator.from_verilog(
        args.readverilog, 
        args.verilogplacerutilization or 0.5,
        args.verilogplaceraspectratio or 1,
        args.verilogexcludednets or {},
        args.verilogreportplacement or false
    )
    local prefix = args.importprefix or "verilogimport"
    local libname = "verilogimport"
    local path = string.format("%s/%s", prefix, libname)
    if not filesystem.exists(path) or args.importoverwrite then
        generator.write_from_verilog(content, path)
    end
    return 0
end

if not args.cell and not args.cellscript then
    moderror("no cell type given")
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

--[[
if args.checktech then
    return 0
end
--]]

-- output cell parameters AFTER parameters have been processed in order to respect value changes in pfiles
if args.params then
    local params = pcell.parameters(args.cell, cellargs, not args.technology)
    local paramformat = args.parametersformat or "%n (%d) %v"
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
end
