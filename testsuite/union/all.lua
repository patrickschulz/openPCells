-- luacheck: globals report
do
    local rectangles = {
        { bl = point.create(-10, 0), tr = point.create(10, 10) },
        { bl = point.create(-5, 0), tr = point.create(5, 10) }
    }
    local status, msg = pcall(union.rectangle_all, rectangles)
    if status then
        local result = rectangles[1]
        local blx, bly = result.bl:unwrap()
        local trx, try = result.tr:unwrap()
        local s = blx == -10 and bly == 0 and trx == 10 and try == 10
        report("all", s, string.format("merged result is wrong ((%d, %d) and (%d, %d))", blx, bly, trx, try))
    else
        report("all", nil, msg)
    end
end
