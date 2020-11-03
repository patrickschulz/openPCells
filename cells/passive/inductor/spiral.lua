function parameters()
    pcell.add_parameters(
        { "turns",             3 },
        { "width",          6000 },
        { "spacing",        6000 },
        { "innerdiameter", 10000 },
        { "points",            8 },
        { "metalnum",         -1 },
        { "grid",            100 }
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
        local a = (i - 1) * angle + 0.5 * angle
        local x = _P.grid * math.floor(pitch * (r + 2) * math.cos(a) / _P.grid)
        local y = _P.grid * math.floor(pitch * (r + 2) * math.sin(a) / _P.grid)
        append(x, y)
    end
    --inductor:merge_into(geometry.any_angle_path(generics.metal(_P.metalnum), pathpts, _P.width, _P.grid))
    inductor:merge_into(geometry.path(generics.metal(_P.metalnum), pathpts, _P.width))
end
