-- luacheck: globals report
do
    local rectangles = {
        {
            name = "halfopenright",
            first = { bl = point.create(-10, 0), tr = point.create(10, 10) },
            second = { bl = point.create(-10, 0), tr = point.create(15, 10) },
            result = { bl = point.create(-10, 0), tr = point.create(15, 10) }
        },
        {
            name = "inner",
            first = { bl = point.create(-10, 0), tr = point.create(10, 10) },
            second = { bl = point.create(-5, 0), tr = point.create(5, 10) },
            result = { bl = point.create(-10, 0), tr = point.create(10, 10) }
        },
    }
    for _, entry in ipairs(rectangles) do
        local rects = { entry.first, entry.second }
        local status, msg = pcall(union.rectangle_all, rects)
        if status then
            local result = rects[1]
            local blx, bly = result.bl:unwrap()
            local trx, try = result.tr:unwrap()
            local blxref, blyref = result.bl:unwrap()
            local trxref, tryref = result.tr:unwrap()
            local s = blx == blxref and bly == blyref and trx == trxref and try == tryref
            report(entry.name, s, string.format("merged result is wrong ((%d, %d) and (%d, %d))", blx, bly, trx, try))
        else
            report("all", nil, msg)
        end
    end
end
