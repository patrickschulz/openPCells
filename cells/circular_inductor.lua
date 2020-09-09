function parameters()
    pcell.add_parameters(
        { "radius",       40.0 },
        { "cornerradius", 14.0 },
        { "width",         6.0 },
        { "separation",    6.0 },
        { "extension",    40.0 },
        { "grid",          0.2 },
        { "metalnum",  -1, "integer" }
    )
end

function layout(inductor, _P)
    -- calculate center of auxiliary circle
    local xc = -0.5 * _P.separation - _P.cornerradius
    local yc = -_P.grid * math.floor(math.sqrt((_P.radius + _P.cornerradius)^2 - xc^2) / _P.grid)

    -- ** Inner part **
    -- calculate meeting point
    local xm = xc * _P.radius / (_P.cornerradius + _P.radius)
    local ym = yc * _P.radius / (_P.cornerradius + _P.radius)

    local main = graphics.quartercircle(3, 0, 0, _P.radius, _P.grid)
    local aux  = graphics.quartercircle(1, xc, yc, _P.cornerradius, _P.grid)

    local inner = util.reverse(graphics.quartercircle(2, 0, 0, _P.radius, _P.grid)) -- start with topleft quarter circle
    util.merge(inner, util.filter_forward(main, function(pt) return pt.x < xm end))
    util.merge(inner, util.filter_backward(aux, function(pt) return pt.x >= xm end))
    -- mirror points and append
    inner = util.reverse(inner)
    util.merge(inner, util.reverse(util.xmirror(inner)))

    -- ** Outer part **
    -- calculate meeting point
    xm = xc * (_P.radius + _P.width) / (_P.cornerradius + _P.radius)
    ym = yc * (_P.radius + _P.width) / (_P.cornerradius + _P.radius)

    main  = graphics.quartercircle(3, 0, 0, _P.radius + _P.width, _P.grid)
    aux   = graphics.quartercircle(1, xc, yc, _P.cornerradius - _P.width, _P.grid)

    local outer = util.reverse(graphics.quartercircle(2, 0, 0, _P.radius + _P.width, _P.grid)) -- start with topleft quarter circle
    util.merge(outer, util.filter_forward(main, function(pt) return pt.x < xm end))
    util.merge(outer, util.filter_backward(aux, function(pt) return pt.x >= xm end))
    -- mirror points and append
    outer = util.reverse(outer)
    util.merge(outer, util.reverse(util.xmirror(outer)))

    -- ** assemble final path **
    local s = shape.create_polygon(generics.metal(_P.metalnum))
    s.points = util.reverse(inner)
    util.merge(s.points, outer)

    inductor:add_shape(s)
end
