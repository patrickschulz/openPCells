--[[
-- reduce results to lowest-resistance
if not args.all then
    local solution = { res = math.huge }
    for _, sol in ipairs(solutions) do
        if solution.res > sol.res then
            solution = sol
        end
    end
    if solution.res ~= math.huge then
        solutions = { solution }
    end
end
--]]

return {
    fit = function(size, cutsize, space, encl)
        local xrep = math.floor((size + space - 2 * encl) / (cutsize + space))
        return xrep, space
    end,
    --[[
    fit2 = function(size, cutsize, minspace, enclosure)
        local Nres
        for N = 1, math.huge do
            local r = (size - N * cutsize - (N - 1) * minspace) / 2
            if r < enclosure then
                break
            end
            Nres = N
        end
        if Nres then
            return Nres, (size - Nres * cutsize - (Nres - 1) * minspace) / 2
        end
    end,
    --]]
    continuous = function(size, cutsize, minspace, enclosure)
        local Nres = 0
        for N = 1, math.huge do                   
            if size % N == 0 then
                local S = size / N - cutsize                                                                                                                              
                if S < minspace then
                    break
                end
                if S % 2 == 0 then
                    Nres = N
                end
            end
        end
        return Nres, size / Nres - cutsize
    end,
    continuous_halfvia = function(size, cutsize, minspace)
        local Nres                             
        for N = 1, math.huge do                   
            if size % (N + 1) == 0 then
                local S = size / (N + 1) - cutsize                                                                                                                              
                if S < minspace then
                    break
                end
                if S % 2 == 0 then
                    Nres = N
                end
            end
        end
        if Nres then
            return Nres, size / (Nres + 1) - cutsize
        end
    end
}
