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
    check_points(pts, ref)
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
    check_points(pts, ref)
end

-- if all test ran positively, we reach this point
return true
