local M = {}

local function rect_order(bl1, tr1, bl2, tr2)
    if bl1 > tr2 or bl2 > tr2 then return "NOINTERSECTION" end
    if bl1  < bl2 and tr1  > tr2 then return "OUTER" end
    if bl2  < bl1 and tr2  > tr1 then return "INNER" end
    if bl1 == bl2 and tr1 == tr2 then return "EQUAL" end
    if bl1 == bl2 and tr1  < tr2 then return "HALFEQUALLEFTREGULAR" end
    if bl1 == bl2 and tr1  > tr2 then return "HALFEQUALLEFTINVERSE" end
    if tr1 == tr2 and bl1  < bl2 then return "HALFEQUALRIGHTREGULAR" end
    if tr1 == tr2 and bl1  > bl2 then return "HALFEQUALRIGHTINVERSE" end
    if tr1 >= bl2 and bl1  < bl2 then return "REGULAR" end
    if tr2 >= bl1 and bl2  < bl1 then return "INVERSE" end
    return "NOINTERSECTION"
end

local function rectangle_union(rect1, rect2)
    local bl1x, bl1y = rect1.bl:unwrap()
    local tr1x, tr1y = rect1.tr:unwrap()
    local bl2x, bl2y = rect2.bl:unwrap()
    local tr2x, tr2y = rect2.tr:unwrap()
    local xorder = rect_order(bl1x, tr1x, bl2x, tr2x)
    if xorder == "NOINTERSECTION" then
        return nil
    end
    local yorder = rect_order(bl1y, tr1y, bl2y, tr2y)
    if yorder == "NOINTERSECTION" then
        return nil
    end
    if xorder == "OUTER" and (yorder == "HALFEQUALLEFTINVERSE" or yorder == "HALFEQUALRIGHTREGULAR") then
        return { bl = rect1.bl:copy(), tr = rect1.tr:copy() }
    end
    if xorder ~= "EQUAL" and yorder ~= "EQUAL" then -- polygon union, one order has to be EQUAL for rectangle union
        return nil
    end
    local blx, bly, trx, try = 0, 0, 0, 0
    if xorder == "HALFEQUALLEFTREGULAR" then
        blx = bl1x
        trx = tr2x
    elseif xorder == "HALFEQUALLEFTINVERSE" then
        blx = bl1x
        trx = tr1x
    elseif xorder == "HALFEQUALRIGHTREGULAR" then
        blx = bl1x
        trx = tr1x
    elseif xorder == "HALFEQUALRIGHTINVERSE" then
        blx = bl2x
        trx = tr1x
    elseif xorder == "EQUAL" then
        blx = bl1x
        trx = tr1x
    elseif xorder == "OUTER" then
        blx = bl1x
        trx = tr1x
    elseif xorder == "INNER" then
        blx = bl2x
        trx = tr2x
    elseif xorder == "REGULAR" then
        blx = bl1x
        trx = tr2x
    else
        blx = bl2x
        trx = tr1x
    end
    if yorder == "HALFEQUALLEFTREGULAR" then
        bly = bl1y
        try = tr2y
    elseif yorder == "HALFEQUALLEFTINVERSE" then
        bly = bl1y
        try = tr1y
    elseif yorder == "HALFEQUALRIGHTREGULAR" then
        bly = bl1y
        try = tr1y
    elseif yorder ==  "HALFEQUALRIGHTINVERSE" then
        bly = bl2y
        try = tr1y
    elseif yorder == "EQUAL" then
        bly = bl1y
        try = tr1y
    elseif yorder == "OUTER" then
        bly = bl1y
        try = tr1y
    elseif yorder == "INNER" then
        bly = bl2y
        try = tr2y
    elseif yorder == "REGULAR" then
        bly = bl1y
        try = tr2y
    else
        bly = bl2y
        try = tr1y
    end
    return { bl = point.create(blx, bly), tr = point.create(trx, try) }
end

function M.rectangle_all(rectangles)
    local i = 1
    local j = 2
    while #rectangles > 1 do
        if i == #rectangles and j == #rectangles + 1 then break end
        local rect1 = rectangles[i]
        local rect2 = rectangles[j]
        local result = rectangle_union(rect1, rect2)
        if result then
            rectangles[i] = result
            table.remove(rectangles, j)
            -- restart iteration
            i = 1
            j = 2
        else
            j = j + 1
            if j > #rectangles then
                i = i + 1
                j = i + 1
            end
        end
    end
end

return M
