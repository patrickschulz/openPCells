function parameters()
    pcell.add_parameters(
        { "radius",       40.0 },
        { "cornerradius", 14.0 },
        { "width",         6.0 },
        { "separation",    6.0 },
        { "extension",    40.0 },
        { "grid",          0.2 }
    )
end

function layout()
    local P = pcell.get_params()

    -- calculate center of auxiliary circle
    local xc = -0.5 * P.separation - P.cornerradius
    local yc = -P.grid * math.floor(math.sqrt((P.radius + P.cornerradius)^2 - xc^2) / P.grid)

    -- ** Inner part **
    -- calculate meeting point
    local xm = xc * P.radius / (P.cornerradius + P.radius)
    local ym = yc * P.radius / (P.cornerradius + P.radius)

    local main = graphics.quartercircle(3, 0, 0, P.radius, P.grid)
    local aux  = graphics.quartercircle(1, xc, yc, P.cornerradius, P.grid)

    local inner = util.reverse(graphics.quartercircle(2, 0, 0, P.radius, P.grid)) -- start with topleft quarter circle
    util.merge(inner, util.filter_forward(main, function(pt) return pt.x < xm end))
    util.merge(inner, util.filter_backward(aux, function(pt) return pt.x >= xm end))
    -- mirror points and append
    inner = util.reverse(inner)
    util.merge(inner, util.reverse(util.xmirror(inner)))

    -- ** Outer part **
    -- calculate meeting point
    xm = xc * (P.radius + P.width) / (P.cornerradius + P.radius)
    ym = yc * (P.radius + P.width) / (P.cornerradius + P.radius)

    main  = graphics.quartercircle(3, 0, 0, P.radius + P.width, P.grid)
    aux   = graphics.quartercircle(1, xc, yc, P.cornerradius - P.width, P.grid)

    local outer = util.reverse(graphics.quartercircle(2, 0, 0, P.radius + P.width, P.grid)) -- start with topleft quarter circle
    util.merge(outer, util.filter_forward(main, function(pt) return pt.x < xm end))
    util.merge(outer, util.filter_backward(aux, function(pt) return pt.x >= xm end))
    -- mirror points and append
    outer = util.reverse(outer)
    util.merge(outer, util.reverse(util.xmirror(outer)))

    -- ** assemble final path **
    local s = shape.create_polygon(generics.metal(-1))
    s.points = util.reverse(inner)
    util.merge(s.points, outer)

    return object.make_from_shape(s)
end
