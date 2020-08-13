return function(args)
    pcell.setup(args)

    local radius       = pcell.process_args("radius",       40.0)
    local cornerradius = pcell.process_args("cornerradius", 14.0)
    local width        = pcell.process_args("width",         6.0)
    local separation   = pcell.process_args("separation",    6.0)
    local extension    = pcell.process_args("extension",    40.0)
    local grid         = pcell.process_args("grid",          0.2)

    pcell.check_args()

    -- calculate center of auxiliary circle
    local xc = -0.5 * separation - cornerradius
    local yc = -grid * math.floor(math.sqrt((radius + cornerradius)^2 - xc^2) / grid)

    -- ** Inner part **
    -- calculate meeting point
    local xm = xc * radius / (cornerradius + radius)
    local ym = yc * radius / (cornerradius + radius)

    local main = graphics.quartercircle(3, 0, 0, radius, grid)
    local aux  = graphics.quartercircle(1, xc, yc, cornerradius, grid)

    local inner = util.reverse(graphics.quartercircle(2, 0, 0, radius, grid)) -- start with topleft quarter circle
    util.merge(inner, util.filter_forward(main, function(pt) return pt.x < xm end))
    util.merge(inner, util.filter_backward(aux, function(pt) return pt.x >= xm end))
    -- mirror points and append
    inner = util.reverse(inner)
    util.merge(inner, util.reverse(util.xmirror(inner)))

    -- ** Outer part **
    -- calculate meeting point
    xm = xc * (radius + width) / (cornerradius + radius)
    ym = yc * (radius + width) / (cornerradius + radius)

    main  = graphics.quartercircle(3, 0, 0, radius + width, grid)
    aux   = graphics.quartercircle(1, xc, yc, cornerradius - width, grid)

    local outer = util.reverse(graphics.quartercircle(2, 0, 0, radius + width, grid)) -- start with topleft quarter circle
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
