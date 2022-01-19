-- luacheck: globals report check_points
-- horizontal piece
do
    local startpt = point.create(0, 0)
    local pathpts = {
        point.create(1000, 1000),
        1000,
        1000
    }

    local pts = geometry.path_points_xy(startpt, pathpts)
    local ref = {
        point.create(    0,   0),
        point.create(1000,    0),
        point.create(1000, 1000),
        point.create(2000, 1000),
        point.create(2000, 2000),
    }

    local status, msg = check_points(pts, ref)
    report("main", status, msg)
end

-- if all test ran positively, we reach this point
return true
