return function(args)
    pcell.setup(args)

    local radius       = pcell.process_args("radius", "number", 40.0)
    local cornerradius = pcell.process_args("cornerradius", "number", 14.0)
    local width        = pcell.process_args("width", "number", 6.0)
    local separation   = pcell.process_args("separation", "number", 6.0)
    local extension    = pcell.process_args("extension", "number", 40.0)
    local grid         = pcell.process_args("grid", "number", 0.2)

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

    local inner = graphics.quartercircle(2, 0, 0, radius, grid):reverse() -- start with topleft quarter circle
    inner:merge_append(main:filter_forward(function(pt) return pt.x < xm end))
    inner:merge_append(aux:filter_backward(function(pt) return pt.x >= xm end))
    -- mirror points and append
    inner:reverse_inline()
    inner:merge_append(inner:xmirror(0):reverse())

    -- ** Outer part **
    -- calculate meeting point
    xm = xc * (radius + width) / (cornerradius + radius)
    ym = yc * (radius + width) / (cornerradius + radius)

    main  = graphics.quartercircle(3, 0, 0, radius + width, grid)
    aux   = graphics.quartercircle(1, xc, yc, cornerradius - width, grid)

    local outer = graphics.quartercircle(2, 0, 0, radius + width, grid):reverse() -- start with topleft quarter circle
    outer:merge_append(main:filter_forward(function(pt) return pt.x < xm end))
    outer:merge_append(aux:filter_backward(function(pt) return pt.x >= xm end))
    -- mirror points and append
    outer:reverse_inline()
    outer:merge_append(outer:xmirror(0):reverse())

    -- ** assemble final path **
    local s = shape.create("lastmetal")
    s.points:merge_append(inner:reverse())
    s.points:merge_append(outer)
    s.points:close()

    local inductor = object.create()

    inductor:add_shape(s)

    return inductor
end
