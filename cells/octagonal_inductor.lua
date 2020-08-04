
return function(args)
    pcell.setup(args)

    local initradius = pcell.process_args("radius",     "number", 30.0)
    local turns      = pcell.process_args("turns",      "number", 3.0)
    local separation = pcell.process_args("separation", "number", 6.0)
    local width      = pcell.process_args("width",      "number", 6.0)
    local extension  = pcell.process_args("extension",  "number", 10.0)
    local extsep     = pcell.process_args("extsep",     "number", 6.0)

    pcell.check_args()

    local inductor = object.create()

    local tanpi8 = math.tan(math.pi / 8)

    -- draw left and right segments
    local sign = (turns % 2 == 0) and 1 or -1
    for i = 1, turns do
        local radius = initradius + (i - 1) * (separation + width)
        local r = radius * tanpi8
        sign = -sign

        local pathpts = pointarray.create()

        pathpts:append(point.create(-r + 0.5 * tanpi8 * width,  sign * radius))
        pathpts:append(point.create(-r,  sign * radius))
        pathpts:append(point.create(-radius,  sign * r))
        pathpts:append(point.create(-radius, -sign * r))
        pathpts:append(point.create(-r, -sign * radius))
        pathpts:append(point.create(-r + 0.5 * tanpi8 * width, -sign * radius))
        
        -- draw underpass
        if i < turns then
            -- create connection to underpass
            pathpts:prepend(point.create(-0.5 * (initradius * tanpi8 + 0.5 * (separation + width)), sign * radius))
            pathpts:append(point.create(-0.5 * (initradius * tanpi8 + 0.5 * (separation + width)), -sign * radius))
            -- create underpass
            local uppts = pointarray.create()
            uppts:append(point.create(-0.5 * (initradius * tanpi8 + 0.5 * (separation + width)), -sign * radius))
            uppts:append(point.create(-0.5 * (separation + width) - 0.5 * tanpi8 * width, -sign * radius))
            uppts:append(point.create(-0.5 * (separation + width), -sign * radius))
            uppts:append(point.create( 0.5 * (separation + width), -sign * (radius + separation + width)))
            uppts:append(point.create( 0.5 * (separation + width) + 0.5 * tanpi8 * width, -sign * (radius + separation + width)))
            uppts:append(point.create( 0.5 * (initradius * tanpi8 + 0.5 * (separation + width)), -sign * (radius + separation + width)))
            inductor:merge_into(layout.path("lastmetal", uppts, width, true))
            inductor:merge_into(layout.path("M9", uppts:xmirror(), width, true))
            -- place vias
            inductor:merge_into(layout.via("M9->M10", width, width):translate(
                -0.5 * (initradius * tanpi8 + 0.5 * (separation + width)), 
                -sign * (radius + separation + width)
            ))
            inductor:merge_into(layout.via("M9->M10", width, width):translate(
                0.5 * (initradius * tanpi8 + 0.5 * (separation + width)), 
                -sign * radius
            ))
        end
        
        -- draw inner connection between left and right
        if i == 1 then
            pathpts:prepend(point.create( 0, sign * radius))
        end

        -- draw connector
        if i == turns then
            -- create connection to underpass
            pathpts:prepend(point.create(-0.5 * (initradius * tanpi8 + 0.5 * (separation + width)), sign * radius))
            if 0.5 * extsep + width > r + 0.5 * width * tanpi8 then
                pathpts:append(point.create(-0.5 * (extsep + width), -r - radius + 0.5 * (extsep + width)))
                pathpts:append(point.create(-0.5 * (extsep + width), -r - radius + 0.5 * (extsep + width) - extension))
            else
                pathpts:append(point.create(-0.5 * (extsep + width), -radius))
                pathpts:append(point.create(-0.5 * (extsep + width), -(radius + extension)))
            end
        end

        inductor:merge_into(layout.path("lastmetal", pathpts, width, true))
        inductor:merge_into(layout.path("lastmetal", pathpts:xmirror(), width, true))
    end

    return inductor
end
