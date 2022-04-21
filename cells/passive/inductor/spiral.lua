function parameters()
    pcell.add_parameters(
        { "turns",             3 },
        { "width",          6000 },
        { "spacing",        6000 },
        { "innerradius",   50000 },
        { "pointsperturn",     8 },
        { "metalnum",         -1 },
        { "grid",            100 }
    )
end

local function fix_to_grid(val, grid)
    if val < 0 then
        return grid * math.ceil(val / grid)
    else
        return grid * math.floor(val / grid)
    end
end

function layout(inductor, _P)
    local pitch = _P.width + _P.spacing
    local pathpts = {}
    local append = util.make_insert_xy(pathpts)
    local startangle = -math.pi / 4
    local numpoints = _P.turns * _P.pointsperturn

    local dir = math.pi / 2
    local x = fix_to_grid(_P.innerradius * math.cos(startangle), _P.grid)
    local y = fix_to_grid(_P.innerradius * math.sin(startangle), _P.grid)
    local addr = math.sqrt(1) * _P.innerradius
    for i = 1, numpoints do
        append(x, y)
        --addr = addr + pitch / 2
        --addr = addr + pitch / 10
        dprint(addr)
        local dx = addr * math.cos(dir)
        local dy = addr * math.sin(dir)
        x = fix_to_grid(x + dx, _P.grid)
        y = fix_to_grid(y + dy, _P.grid)
        dir = dir + 2 * math.pi / _P.pointsperturn
    end
    --inductor:merge_into_shallow(geometry.any_angle_path(generics.metal(_P.metalnum), pathpts, _P.width, _P.grid))
    geometry.path(inductor, generics.metal(_P.metalnum), pathpts, _P.width)
    --inductor:merge_into_shallow(geometry.rectangle(generics.metal(-2), 
    --    fix_to_grid(math.sqrt(2) * (_P.innerradius + 0 * pitch), _P.grid),
    --    fix_to_grid(math.sqrt(2) * (_P.innerradius + 0 * pitch), _P.grid)
    --))
    --inductor:merge_into_shallow(geometry.rectangle(generics.metal(-3), 
    --    fix_to_grid(math.sqrt(2) * _P.innerradius + 2 * pitch, _P.grid),
    --    fix_to_grid(math.sqrt(2) * _P.innerradius + 2 * pitch, _P.grid)
    --))
end
