function parameters()
    pcell.add_parameters(
        { "radius(Radius)",                        40000 },
        { "cornerradius(Corner Radius)",           14000 },
        { "width(Width)",                           6000 },
        { "separation(Line Separation)",            6000 },
        { "extension(Line Extension)",             40000 },
        { "grid(Grid)",                              200 },
        { "metalnum(Conductor Metal)",     -1, "integer" },
        { "allow45(Allow Angles with 45 Degrees)",  true }
    )
end

function layout(inductor, _P)
    -- calculate center of auxiliary circle
    local xc = -0.5 * _P.separation - _P.cornerradius
    local yc = -_P.grid * math.floor(math.sqrt((_P.radius + _P.cornerradius)^2 - xc^2) / _P.grid)

    -- ** Inner part **
    -- calculate meeting point
    local xm = xc * _P.radius / (_P.cornerradius + _P.radius)

    local main = graphics.quartercircle(3, point.create(0, 0), _P.radius, _P.grid, _P.allow45)
    local aux  = graphics.quartercircle(1, point.create(xc, yc), _P.cornerradius, _P.grid, _P.allow45)

    local inner = graphics.quartercircle(2, point.create(0, 0), _P.radius, _P.grid, _P.allow45) -- start with topleft quarter circle
    util.merge(inner, util.filter_forward(main, function(pt) return pt:getx() < xm end))
    util.merge(inner, util.filter_backward(aux, function(pt) return pt:getx() >= xm end))
    -- mirror points and append
    inner = util.reverse(inner)
    util.merge(inner, util.reverse(util.xmirror(inner)))

    -- ** Outer part **
    -- calculate meeting point
    xm = xc * (_P.radius + _P.width) / (_P.cornerradius + _P.radius)

    main = graphics.quartercircle(3, point.create(0, 0), _P.radius + _P.width, _P.grid, _P.allow45)
    aux  = graphics.quartercircle(1, point.create(xc, yc), _P.cornerradius - _P.width, _P.grid, _P.allow45)

    local outer = graphics.quartercircle(2, point.create(0, 0), _P.radius + _P.width, _P.grid, _P.allow45) -- start with topleft quarter circle
    util.merge(outer, util.filter_forward(main, function(pt) return pt:getx() < xm end))
    util.merge(outer, util.filter_backward(aux, function(pt) return pt:getx() >= xm end))
    -- mirror points and append
    outer = util.reverse(outer)
    util.merge(outer, util.reverse(util.xmirror(outer)))

    -- ** assemble final path **
    local pts = {}
    for _, pt in ipairs(util.reverse(inner)) do
        table.insert(pts, pt)
    end
    for _, pt in ipairs(outer) do
        table.insert(pts, pt)
    end
    geometry.polygon(inductor, generics.metal(_P.metalnum), pts)
end
