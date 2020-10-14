do
    local pt1 = point.create(10, 0)
    local pt2 = point.create(10, 0)
    local status, msg = check_point(pt1 + pt2, point.create(20, 0))
    report("horizontal piece", status, msg)
end

return true
