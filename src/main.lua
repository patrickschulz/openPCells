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
