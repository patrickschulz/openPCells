local M = {}

local function rect_order(bl1, tr1, bl2, tr2)
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

local function rect_xorder(rect1, rect2)
    local bl1x = rect1.bl:getx()
    local tr1x = rect1.tr:getx()
    local bl2x = rect2.bl:getx()
    local tr2x = rect2.tr:getx()
    return rect_order(bl1x, tr1x, bl2x, tr2x)
end

local function rect_yorder(rect1, rect2)
    local bl1y = rect1.bl:gety()
    local tr1y = rect1.tr:gety()
    local bl2y = rect2.bl:gety()
    local tr2y = rect2.tr:gety()
    return rect_order(bl1y, tr1y, bl2y, tr2y)
end

local function rectangle_union(rect1, rect2)
    local xorder = rect_xorder(rect1, rect2)
    local yorder = rect_yorder(rect1, rect2)
    if xorder == "NOINTERSECTION" or yorder == "NOINTERSECTION" then
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
        blx = rect1.bl:getx()
        trx = rect2.tr:getx()
    elseif xorder == "HALFEQUALLEFTINVERSE" then
        blx = rect1.bl:getx()
        trx = rect1.tr:getx()
    elseif xorder == "HALFEQUALRIGHTREGULAR" then
        blx = rect1.bl:getx()
        trx = rect1.tr:getx()
    elseif xorder == "HALFEQUALRIGHTINVERSE" then
        blx = rect2.bl:getx()
        trx = rect1.tr:getx()
    elseif xorder == "EQUAL" then
        blx = rect1.bl:getx()
        trx = rect1.tr:getx()
    elseif xorder == "OUTER" then
        blx = rect1.bl:getx()
        trx = rect1.tr:getx()
    elseif xorder == "INNER" then
        blx = rect2.bl:getx()
        trx = rect2.tr:getx()
    elseif xorder == "REGULAR" then
        blx = rect1.bl:getx()
        trx = rect2.tr:getx()
    else
        blx = rect2.bl:getx()
        trx = rect1.tr:getx()
    end
    if yorder == "HALFEQUALLEFTREGULAR" then
        bly = rect1.bl:gety()
        try = rect2.tr:gety()
    elseif yorder == "HALFEQUALLEFTINVERSE" then
        bly = rect1.bl:gety()
        try = rect1.tr:gety()
    elseif yorder == "HALFEQUALRIGHTREGULAR" then
        bly = rect1.bl:gety()
        try = rect1.tr:gety()
    elseif yorder ==  "HALFEQUALRIGHTINVERSE" then
        bly = rect2.bl:gety()
        try = rect1.tr:gety()
    elseif yorder == "EQUAL" then
        bly = rect1.bl:gety()
        try = rect1.tr:gety()
    elseif yorder == "OUTER" then
        bly = rect1.bl:gety()
        try = rect1.tr:gety()
    elseif yorder == "INNER" then
        bly = rect2.bl:gety()
        try = rect2.tr:gety()
    elseif yorder == "REGULAR" then
        bly = rect1.bl:gety()
        try = rect2.tr:gety()
    else
        bly = rect2.bl:gety()
        try = rect1.tr:gety()
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
