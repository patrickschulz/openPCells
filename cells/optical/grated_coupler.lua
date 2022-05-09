function parameters()

    pcell.add_parameters(
        { "metalnum", -1 },
        { "angle", 40 },
        { "numsegments", 14 },
        { "segmentwidth", 500 },
        { "segmentspace", 500 },
        { "baseradius", 10000 },
        { "linelength", 5000 },
        { "linewidth", 1000 },
        { "grid", 100 }
    )
end

function layout(coupler, _P)
    local allow45 = true

    local pitch = _P.segmentwidth + _P.segmentspace
    local startangle = -_P.angle / 2
    local endangle = _P.angle / 2

    local cos = math.cos(_P.angle / 2 * math.pi / 180)
    local sin = math.sin(_P.angle / 2 * math.pi / 180)

    -- FIXME: calculate intersection of horizontal feed line and angled line from main segment
    -- main segment (with feed line)
    geometry.curve(coupler, generics.metal(_P.metalnum), point.create(-_P.linelength, 0), {
        curve.lineto(point.create(-_P.linelength, _P.linewidth / 2)),
        curve.lineto(point.create(math.floor(_P.linewidth / 2 * math.tan(math.pi / 2 - _P.angle / 2 * math.pi / 180)), _P.linewidth / 2):fix(_P.grid)),
        curve.lineto(point.create(
            math.floor(math.cos(_P.angle / 2 * math.pi / 180) * _P.baseradius),
            math.floor(math.sin(_P.angle / 2 * math.pi / 180) * _P.baseradius)
        ):fix(_P.grid)),
        curve.arcto(_P.angle / 2, -_P.angle / 2, _P.baseradius, true),
        curve.lineto(point.create(math.floor(_P.linewidth / 2 * math.tan(math.pi / 2 - _P.angle / 2 * math.pi / 180)), -_P.linewidth / 2):fix(_P.grid)),
        curve.lineto(point.create(-_P.linelength, -_P.linewidth / 2)),
    }, _P.grid, true)

    -- circle segments
    for i = 1, _P.numsegments do
        geometry.curve(coupler, generics.metal(_P.metalnum), 
            point.create(
                math.floor(cos * (_P.baseradius + _P.segmentspace + (i - 1) * pitch)),
                math.floor(sin * (_P.baseradius + _P.segmentspace + (i - 1) * pitch))
            ):fix(_P.grid), {
            curve.arcto(_P.angle / 2, -_P.angle / 2, _P.baseradius + _P.segmentspace + (i - 1) * pitch, true),
            curve.lineto(point.create(
                 math.floor(cos * (_P.baseradius + _P.segmentspace + (i - 1) * pitch + _P.segmentwidth)),
                -math.floor(sin * (_P.baseradius + _P.segmentspace + (i - 1) * pitch + _P.segmentwidth))
            ):fix(_P.grid)),
            curve.arcto(-_P.angle / 2, _P.angle / 2, _P.baseradius + _P.segmentspace + (i - 1) * pitch + _P.segmentwidth, false),
        }, _P.grid, true)
    end
end
