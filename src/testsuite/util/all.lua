-- luacheck: globals check_points report
do
    local pts = {
        point.create(0, 0),
        point.create(10, 10),
    }
    local ref = {
        point.create(0, 0),
        point.create(-10, 10),
    }
    local status, msg = check_points(util.xmirror(pts), ref)
    report("xmirror without argument", status, msg)
end

do
    local pts = {
        point.create(0, 0),
        point.create(10, 10),
    }
    local ref = {
        point.create(10, 0),
        point.create(0, 10),
    }
    local status, msg = check_points(util.xmirror(pts, 5), ref)
    report("xmirror with argument", status, msg)
end

do
    local pts = {
        point.create(0, 0),
        point.create(10, 10),
    }
    local ref = {
        point.create(0, 0),
        point.create(10, -10),
    }
    local status, msg = check_points(util.ymirror(pts), ref)
    report("ymirror without argument", status, msg)
end

do
    local pts = {
        point.create(0, 0),
        point.create(10, 10),
    }
    local ref = {
        point.create(0, 10),
        point.create(10, 0),
    }
    local status, msg = check_points(util.ymirror(pts, 5), ref)
    report("ymirror with argument", status, msg)
end
