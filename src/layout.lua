local M = {}

function M.rectanglebltr(layer, bl, tr)
    local obj = object.create()
    obj:add_raw_shape(shape.create_rectangle_bltr(layer, bl, tr))
    return obj
end

function M.rectangle(layer, width, height)
    if width % 2 ~= 0 then 
        moderror(string.format("layout.rectangle: width (%d) must be a multiple of 2. Use rectanglebltr if you need odd coordinates", width))
    end
    if height % 2 ~= 0 then 
        moderror(string.format("layout.rectangle: height (%d) must be a multiple of 2. Use rectanglebltr if you need odd coordinates", height))
    end
    return M.rectanglebltr(
        layer,
        point.create(-width / 2, -height / 2),
        point.create( width / 2,  height / 2)
    )
end

local arrayzation_strategies = {
    fit = function(size, cutsize, space, encl)
        local xrep = math.floor((size + space - 2 * encl) / (cutsize + space))
        return xrep, space
    end,
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
    continuous_half = function(size, cutsize, minspace)
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

function M.get_rectangular_arrayzation(regionwidth, regionheight, entry, options)
    if entry.fallback then
        return {
            width = entry.width,
            height = entry.height,
            xpitch = 0,
            ypitch = 0,
            xrep = 1,
            yrep = 1,
        }
    end
    local xstrat = arrayzation_strategies[options.xcontinuous and "continuous" or "fit"]
    local ystrat = arrayzation_strategies[options.ycontinuous and "continuous" or "fit"]

    local xrep, xspace = xstrat(regionwidth, entry.width, entry.xspace, entry.xenclosure)
    local yrep, yspace = ystrat(regionheight, entry.height, entry.yspace, entry.yenclosure)
    if entry.noneedtofit then
        xrep = math.max(1, xrep)
        yrep = math.max(1, yrep)
    end
    return {
        width = entry.width,
        height = entry.height,
        xpitch = entry.width + xspace,
        ypitch = entry.height + yspace,
        xrep = xrep,
        yrep = yrep,
    }
end

function M.rectangle_array(layer, entry, where)
    local blx = -entry.width // 2
    local trx =  entry.width // 2
    local bly = -entry.height // 2
    local try =  entry.height // 2
    local cut = geometry.multiple_xy(
        M.rectanglebltr(layer, 
            point.create(blx, bly), point.create(trx, try)
        ),
        entry.xrep, entry.yrep, entry.xpitch, entry.ypitch
    )
    return cut
end

return M
