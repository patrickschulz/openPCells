local M = {}

function M.readpfile(pfile, cellargs)
    local reader = _get_reader(pfile)
    local t
    if reader then
        t = _dofile2(reader, chunkname, nil, env)
    else
        moderror(string.format("could not open parameter file '%s'", pfile))
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
