do
    local pathpts = {
        point.create(0, 0),
        point.create(10000, 0)
    }

    local obj = geometry.path(generics.metal(1), pathpts, 1000)
    local pts = obj.shapes[1].points
    local ref = {
        point.create(    0, -500),
        point.create(10000, -500),
        point.create(10000,  500),
        point.create(    0,  500),
    }

    local status, msg = check_points(pts, ref)
    if not status then
        return nil, msg
    end
end

do
    local pathpts = {
        point.create(0, 0),
        point.create(10000, 0),
        point.create(10000, 10000)
    }

    local obj = geometry.path(generics.metal(1), pathpts, 1000)
    local pts = obj.shapes[1].points
    for _, pt in ipairs(pts) do
        print(pt:unwrap())
    end
    local ref = {
        point.create(    0,  -500),
        point.create(10500,  -500),
        point.create(10500, 10000),
        point.create( 9500, 10000),
        point.create( 9500,   500),
        point.create(    0,   500),
    }

    local status, msg = check_points(pts, ref)
    if not status then
        return nil, msg
    end
end

-- if all test ran positively, we reach this point
return true
