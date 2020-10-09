do
    local pts = {
        point.create(0, 0),
        point.create(1, 0),
        point.create(2, 0),
        point.create(3, 0),
        point.create(4, 0),
        point.create(5, 1),
        point.create(6, 2),
        point.create(7, 2),
    }
    local ref = {
        point.create(0, 0),
        point.create(4, 0),
        point.create(6, 2),
        point.create(7, 2),
    }

    local reduced = reduce.remove_superfluous_points(pts)
    check_points(reduced, ref)
end

-- if all test ran positively, we reach this point
return true
