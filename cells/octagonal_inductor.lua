function parameters()
    pcell.add_parameters(
        { "radius",    30.0 },
        { "turns",      3.0 },
        { "separation", 6.0 },
        { "width",      6.0 },
        { "extension", 10.0 },
        { "extsep",     6.0 },
        { "metalnum",  -1, "integer" }
    )
end

function layout()
    local P = pcell.get_params()

    local inductor = object.create()

    local tanpi8 = math.tan(math.pi / 8)
    local pitch = P.separation + P.width

    local mainmetal = generics.metal(P.metalnum)
    local auxmetal = generics.metal(P.metalnum - 1)
    local via = generics.via(P.metalnum, P.metalnum - 1)

    -- draw left and right segments
    local sign = (P.turns % 2 == 0) and 1 or -1
    for i = 1, P.turns do
        local radius = P.radius + (i - 1) * pitch
        local r = radius * tanpi8
        sign = -sign

        local pathpts = {}

        table.insert(pathpts, point.create(-r + 0.5 * tanpi8 * P.width,  sign * radius))
        table.insert(pathpts, point.create(-r,  sign * radius))
        table.insert(pathpts, point.create(-radius,  sign * r))
        table.insert(pathpts, point.create(-radius, -sign * r))
        table.insert(pathpts, point.create(-r, -sign * radius))
        table.insert(pathpts, point.create(-r + 0.5 * tanpi8 * P.width, -sign * radius))
        
        -- draw underpass
        if i < P.turns then
            -- create connection to underpass
            table.insert(pathpts, 1, point.create(-0.5 * (P.radius * tanpi8 + 0.5 * pitch),  sign * radius))
            table.insert(pathpts, point.create(-0.5 * (P.radius * tanpi8 + 0.5 * pitch), -sign * radius))
            -- create underpass
            local uppts = {}
            table.insert(uppts, point.create(-0.5 * (P.radius * tanpi8 + 0.5 * pitch), -sign * radius))
            table.insert(uppts, point.create(-0.5 * pitch - 0.5 * tanpi8 * P.width, -sign * radius))
            table.insert(uppts, point.create(-0.5 * pitch, -sign * radius))
            table.insert(uppts, point.create( 0.5 * pitch, -sign * (radius + pitch)))
            table.insert(uppts, point.create( 0.5 * pitch + 0.5 * tanpi8 * P.width, -sign * (radius + pitch)))
            table.insert(uppts, point.create( 0.5 * (P.radius * tanpi8 + 0.5 * pitch), -sign * (radius + pitch)))
            inductor:merge_into(geometry.path(mainmetal, uppts, P.width, true))
            inductor:merge_into(geometry.path(auxmetal, util.xmirror(uppts), P.width, true))
            -- place vias
            inductor:merge_into(geometry.rectangle(via, P.width, P.width):translate(
                -0.5 * (P.radius * tanpi8 + 0.5 * pitch), 
                -sign * (radius + pitch)
            ))
            inductor:merge_into(geometry.rectangle(via, P.width, P.width):translate(
                0.5 * (P.radius * tanpi8 + 0.5 * pitch), 
                -sign * radius
            ))
        end
        
        -- draw inner connection between left and right
        if i == 1 then
            table.insert(pathpts, 1, point.create( 0, sign * radius))
        end

        -- draw connector
        if i == P.turns then
            -- create connection to underpass
            table.insert(pathpts, 1, point.create(-0.5 * (P.radius * tanpi8 + 0.5 * pitch), sign * radius))
            if 0.5 * P.extsep + P.width > r + 0.5 * P.width * tanpi8 then
                table.insert(pathpts, point.create(-0.5 * (P.extsep + P.width), -r - radius + 0.5 * (P.extsep + P.width)))
                table.insert(pathpts, point.create(-0.5 * (P.extsep + P.width), -r - radius + 0.5 * (P.extsep + P.width) - P.extension))
            else
                table.insert(pathpts, point.create(-0.5 * (P.extsep + P.width), -radius))
                table.insert(pathpts, point.create(-0.5 * (P.extsep + P.width), -(radius + P.extension)))
            end
        end

        inductor:merge_into(geometry.path(mainmetal, pathpts, P.width, true))
        inductor:merge_into(geometry.path(mainmetal, util.xmirror(pathpts), P.width, true))
    end

    return inductor
end
