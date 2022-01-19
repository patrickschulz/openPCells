function parameters()
    pcell.add_parameters(
        { "radius(Radius)",                        40000 },
        { "turns(Number of Turns)",                    3 },
        { "width(Width)",                           6000 },
        { "separation(Line Separation)",            6000 },
        { "extension(Line Extension)",             40000 },
        { "extsep(Extension Separation)",           6000 },
        { "metalnum(Conductor Metal)",     -1, "integer" }
    )
end

local function _scale_tanpi8(num)
    return math.floor(num * 5741 / 13860) -- rational approximation of tan(pi / 8)
end

function layout(inductor, _P)
    local pitch = _P.separation + _P.width

    local mainmetal = generics.metal(_P.metalnum)
    local auxmetal = generics.metal(_P.metalnum - 1)
    local via = generics.via(_P.metalnum, _P.metalnum - 1)

    -- draw left and right segments
    local sign = (_P.turns % 2 == 0) and 1 or -1
    for i = 1, _P.turns do
        local radius = _P.radius + (i - 1) * pitch
        local r = _scale_tanpi8(radius)
        sign = -sign

        local pathpts = {}
        local prepend = util.make_insert_xy(pathpts, 1)
        local append = util.make_insert_xy(pathpts)

        append(-r + _scale_tanpi8(_P.width / 2),  sign * radius)
        append(-r,  sign * radius)
        append(-radius,  sign * r)
        append(-radius, -sign * r)
        append(-r, -sign * radius)
        append(-r + _scale_tanpi8(_P.width / 2), -sign * radius)

        -- draw underpass
        if i < _P.turns then
            -- create connection to underpass
            prepend(-(_scale_tanpi8(_P.radius) + pitch / 2) / 2,  sign * radius)
            append(-(_scale_tanpi8(_P.radius) + pitch / 2) / 2, -sign * radius)
            -- create underpass
            local uppts = {}
            -- luacheck: ignore append
            local append = util.make_insert_xy(uppts)
            append(-(_scale_tanpi8(_P.radius) + pitch / 2) / 2, -sign * radius)
            append(-pitch / 2 - _scale_tanpi8(_P.width / 2), -sign * radius)
            append(-pitch / 2, -sign * radius)
            append( pitch / 2, -sign * (radius + pitch))
            append( pitch / 2 + _scale_tanpi8(_P.width / 2), -sign * (radius + pitch))
            append( (_scale_tanpi8(_P.radius) + pitch / 2) / 2, -sign * (radius + pitch))
            inductor:merge_into_shallow(geometry.path(mainmetal, uppts, _P.width, true))
            inductor:merge_into_shallow(geometry.path(auxmetal, util.xmirror(uppts), _P.width, true))
            -- place vias
            inductor:merge_into_shallow(geometry.rectangle(via, _P.width, _P.width):translate(
                -(_scale_tanpi8(_P.radius) + pitch / 2) / 2,
                -sign * (radius + pitch)
            ))
            inductor:merge_into_shallow(geometry.rectangle(via, _P.width, _P.width):translate(
                (_scale_tanpi8(_P.radius) + pitch / 2) / 2,
                -sign * radius
            ))
        end

        -- draw inner connection between left and right
        if i == 1 then
            prepend(0, sign * radius)
        end

        -- draw connector
        if i == _P.turns then
            -- create connection to underpass
            if i > 1 then
                prepend(-(_scale_tanpi8(_P.radius) + pitch / 2) / 2, sign * radius)
            end
            if _P.extsep / 2 + _P.width > r + _scale_tanpi8(_P.width / 2) then
                append(-(_P.extsep + _P.width) / 2, -r - radius + (_P.extsep + _P.width) / 2)
                append(-(_P.extsep + _P.width) / 2, -r - radius + (_P.extsep + _P.width) / 2 - _P.extension)
            else
                append(-(_P.extsep + _P.width) / 2, -radius)
                append(-(_P.extsep + _P.width) / 2, -(radius + _P.extension))
            end
        end

        inductor:merge_into_shallow(
            geometry.path(mainmetal, pathpts, _P.width, true)
        )
        inductor:merge_into_shallow(
            geometry.path(mainmetal, util.xmirror(pathpts), _P.width, true)
        )
    end
end
