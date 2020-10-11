do
    local pathpts = {
        point.create(    0, 0),
        point.create(10000, 2000)
    }
    local grid = 100

    local obj = geometry.any_angle_path(generics.metal(1), pathpts, 1000, grid)
    local pts = obj.shapes[1].points
    for _, pt in ipairs(pts) do print(pt:unwrap()) end
    local ref = {
        point.create(    0, -500),
        point.create(10000, -500),
        point.create(10000,  500),
        point.create(    0,  500),
    }

    local status, msg = check_points(pts, ref)
    report("horizontal piece", status, msg)
end

-- if all test ran positively, we reach this point
return true
