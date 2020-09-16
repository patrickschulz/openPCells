function parameters()
    pcell.add_parameters(
        { "turns",         3 },
        { "width",         6.0 },
        { "spacing",       6.0 },
        { "innerdiameter", 10 },
        { "points",        8 },
        { "metalnum",      -1 },
        { "grid",          0.1 }
    )
end

function layout(inductor, _P)
    local pitch = _P.width + _P.spacing
    local pathpts = {}
    local append = util.make_insert_xy(pathpts)
    local angle = 2 * math.pi / _P.points
    local numpoints = _P.turns * _P.points

    for i = 1, numpoints + 1 do
        local r = _P.turns * i / numpoints
        local a = (i - 1) * angle-- + 0.5 * angle
        local x = pitch * (r + 2) *  math.cos(a)
        local y = pitch * (r + 2) * math.sin(a)
        append(x, y)
    end
    inductor:merge_into(geometry.any_angle_path(generics.metal(_P.metalnum), pathpts, _P.width, _P.grid))
end
