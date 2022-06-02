function parameters()

    pcell.add_parameters(
        { "metalnum", -1 },
        { "angle", 40 },
        { "numsegments", 20 },
        { "segmentwidth", 1000 },
        { "segmentspace", 1000 },
        { "baseradius", 20000 },
        { "linelength", 10000 },
        { "linewidth", 1000 },
        { "grid", 100 }
    )
end

function layout(coupler, _P)
    local allow45 = true

    local pitch = _P.segmentwidth + _P.segmentspace
    local startangle = -_P.angle / 2
    local endangle = _P.angle / 2

    -- main segment (with feed line)
    local mainpts = graphics.circle(point.create(0, 0), _P.baseradius, startangle, endangle, _P.grid, allow45)
    table.insert(mainpts, point.create(math.floor(_P.linewidth / 2 / math.tan(_P.angle / 2 * math.pi / 180)),  _P.linewidth / 2))
    table.insert(mainpts, point.create(-_P.linelength,  _P.linewidth / 2))
    table.insert(mainpts, point.create(-_P.linelength, -_P.linewidth / 2))
    table.insert(mainpts, point.create(math.floor(_P.linewidth / 2 / math.tan(_P.angle / 2 * math.pi / 180)), -_P.linewidth / 2))
    geometry.polygon(coupler, generics.metal(_P.metalnum), mainpts)

    -- circle segments
    for i = 1, _P.numsegments do
        local inner = graphics.circle(point.create(0, 0), _P.baseradius + _P.segmentspace + (i - 1) * pitch, startangle, endangle, _P.grid, allow45)
        local outer = graphics.circle(point.create(0, 0), _P.baseradius + _P.segmentspace + (i - 1) * pitch + _P.segmentwidth, startangle, endangle, _P.grid, allow45)
        local pts = {}
        for _, pt in ipairs(util.reverse(inner)) do
            table.insert(pts, pt)
        end
        for _, pt in ipairs(outer) do
            table.insert(pts, pt)
        end
        geometry.polygon(coupler, generics.metal(_P.metalnum), pts)
    end
end
