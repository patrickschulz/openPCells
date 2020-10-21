-- horizontal piece
do
    local pathpts = {
        point.create(    0, 0),
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
    report("horizontal piece", status, msg)
end

-- vertical piece
do
    local pathpts = {
        point.create(0,     0),
        point.create(0, 10000)
    }

    local obj = geometry.path(generics.metal(1), pathpts, 1000)
    local pts = obj.shapes[1].points
    local ref = {
        point.create(  500, 0),
        point.create(  500, 10000),
        point.create( -500, 10000),
        point.create( -500, 0),
    }

    local status, msg = check_points(pts, ref)
    report("vertical piece", status, msg)
end

-- diagonal piece
do
    local pathpts = {
        point.create(0,     0),
        point.create(10000, 10000)
    }

    local obj = geometry.path(generics.metal(1), pathpts, 1000)
    local pts = obj.shapes[1].points
    local ref = {
        point.create(  354, -354),
        point.create(10354, 9646),
        point.create( 9646, 10354),
        point.create( -354,  354),
    }

    local status, msg = check_points(pts, ref)
    report("diagonal piece", status, msg)
end

-- "L" piece
do
    local pathpts = {
        point.create(0, 0),
        point.create(10000, 0),
        point.create(10000, 10000)
    }

    local obj = geometry.path(generics.metal(1), pathpts, 1000, true)
    local pts = obj.shapes[1].points
    local ref = {
        point.create(    0,  -500),
        point.create(10500,  -500),
        point.create(10500, 10000),
        point.create( 9500, 10000),
        point.create( 9500,   500),
        point.create(    0,   500),
    }

    local status, msg = check_points(pts, ref)
    report("'L' piece", status, msg)
end

-- straight piece followed by diagonal piece (with miter join)
do
    local pathpts = {
        point.create(    0,     0),
        point.create(10000,     0),
        point.create(20000, 10000),
    }

    local obj = geometry.path(generics.metal(1), pathpts, 1000, true)
    local pts = obj.shapes[1].points
    local ref = {
        point.create(    0,  -500),
        point.create(10208,  -500),
        point.create(20354,  9646),
        point.create(19646, 10354),
        point.create( 9792,   500),
        point.create(    0,   500),
    }

    local status, msg = check_points(pts, ref)
    report("straight piece followed by diagonal piece (with miter join)", status, msg)
end

-- straight piece followed by diagonal piece (with bevel join)
do
    local pathpts = {
        point.create(    0,     0),
        point.create(10000,     0),
        point.create(20000, 10000),
    }

    local obj = geometry.path(generics.metal(1), pathpts, 1000)
    local pts = obj.shapes[1].points
    local ref = {
        point.create(    0,  -500),
        point.create(10000,  -500),
        point.create(10354,  -354),
        point.create(20354,  9646),
        point.create(19646, 10354),
        point.create( 9792,   500),
        point.create(    0,   500),
    }

    local status, msg = check_points(pts, ref)
    report("straight piece followed by diagonal piece (with bevel join)", status, msg)
end

-- if all test ran positively, we reach this point
return true
