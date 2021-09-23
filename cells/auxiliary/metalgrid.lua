function parameters()
    pcell.add_parameters(
        { "metalh", 1 },
        { "metalv", 2 },
        { "mhwidth", 100 },
        { "mhspace", 100, posvals = even() },
        { "mvwidth", 100 },
        { "mvspace", 100, posvals = even() },
        { "mhlines", 6 },
        { "mvlines", 3 },
        { "centergrid", true }
    )
    pcell.check_expression("(not centergrid) or ((mhlines % 2 == 1) and (mhwidth % 2 == 0)) or ((mhlines % 2 == 0) and (mhspace % 2 == 0))")
    pcell.check_expression("(not centergrid) or ((mvlines % 2 == 1) and (mvwidth % 2 == 0)) or ((mvlines % 2 == 0) and (mvspace % 2 == 0))")
end

function layout(grid, _P)
    local xpitch = _P.mvwidth + _P.mvspace
    local ypitch = _P.mhwidth + _P.mhspace
    -- metal lines
    for i = 1, _P.mhlines do
        local xoffset = _P.centergrid and (-_P.mvlines * xpitch / 2) or 0
        local yoffset = _P.centergrid and (-_P.mhlines * ypitch / 2 + _P.mhspace / 2) or math.floor(_P.mhspace / 2)
        grid:merge_into_shallow(geometry.rectanglebltr(generics.metal(_P.metalh),
            point.create(xoffset,                                          (i - 1) * ypitch + yoffset),
            point.create(xoffset + _P.mvlines * (_P.mvwidth + _P.mvspace), (i - 1) * ypitch + yoffset + _P.mhwidth)
        ))
    end
    for i = 1, _P.mvlines do
        local xoffset = _P.centergrid and (-_P.mvlines * xpitch / 2 + _P.mvspace / 2) or math.floor(_P.mvspace / 2)
        local yoffset = _P.centergrid and (-_P.mhlines * ypitch / 2) or 0
        grid:merge_into_shallow(geometry.rectanglebltr(generics.metal(_P.metalv),
            point.create((i - 1) * xpitch + xoffset,              yoffset),
            point.create((i - 1) * xpitch + xoffset + _P.mvwidth, yoffset + _P.mhlines * (_P.mhwidth + _P.mhspace))
        ))
    end

    -- vias
    for i = 1, _P.mhlines do
        for j = 1, _P.mvlines do
            local xoffset = _P.centergrid and (-_P.mvlines * xpitch / 2 + _P.mvspace / 2) or math.floor(_P.mvspace / 2)
            local yoffset = _P.centergrid and (-_P.mhlines * ypitch / 2 + _P.mhspace / 2) or math.floor(_P.mhspace / 2)
            if (i % 2 == 0) == (j % 2 == 0) then
                grid:merge_into_shallow(geometry.rectanglebltr(generics.via(_P.metalh, _P.metalv, { bare = true }),
                    point.create((j - 1) * xpitch + xoffset,              (i - 1) * ypitch + yoffset),
                    point.create((j - 1) * xpitch + xoffset + _P.mvwidth, (i - 1) * ypitch + yoffset + _P.mhwidth)
                ))
            end
        end
    end
end
