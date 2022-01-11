local M = {}

function M.readpfile(pfile, cellargs)
    local status, t = pcall(_dofile, pfile)
    if not status then
        print(string.format("could not load parameter file '%s', error: %s", pfile, t))
        return 1
    end
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

return M
