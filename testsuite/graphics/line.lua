-- vertical test
do
    local pt1 = point.create(0, 0)
    local pt2 = point.create(0, 500)
    local grid = 100
    local pts = graphics.line(pt1, pt2, grid)
    local ref = {
        point.create(0,    0),
        point.create(0,  500),
    }
    local status, msg = check_points(pts, ref)
    if not status then
        return nil, msg
    end
end

-- diagonal test
do
    local pt1 = point.create(0, 0)
    local pt2 = point.create(500, 500)
    local grid = 100
    local pts = graphics.line(pt1, pt2, grid)
    local ref = {
        point.create(   0,    0),
        point.create( 500,  500),
    }
    local status, msg = check_points(pts, ref)
    if not status then
        return nil, msg
    end
end

-- other test
do
    local pt1 = point.create(0, 0)
    local pt2 = point.create(1000, 500)
    local grid = 100
    local allow45 = true

    local pts = graphics.line(pt1, pt2, grid, allow45)
    local ref = {
        point.create(   0,    0),
        point.create( 100,    0),
        point.create( 200,  100),
        point.create( 300,  100),
        point.create( 400,  200),
        point.create( 500,  200),
        point.create( 600,  300),
        point.create( 700,  300),
        point.create( 800,  400),
        point.create( 900,  400),
        point.create(1000,  500),
    }

    local status, msg = check_points(pts, ref)
    if not status then
        return nil, msg
    end
end

-- if all test ran positively, we reach this point
return true
