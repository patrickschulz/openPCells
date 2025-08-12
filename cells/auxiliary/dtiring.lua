function parameters()
    pcell.add_parameters(
        { "breakringsegments", true },
        { "ringwidths", { 1000 } },
        { "ringspaces", { 1000 } },
        { "innerareawidth", 10000 },
        { "innerareaheight", 10000 }
    )
end

function layout(cell, _P)
    local numsegments = #_P.ringwidths
    if _P.breakringsegments then
        local maxwidth = _P.innerareawidth
        local maxheight = _P.innerareaheight
        for i = 1, numsegments do
            maxwidth = maxwidth + 2 * _P.ringwidths[i] + 2 * (_P.ringspaces[i] or 0)
            maxheight = maxheight + 2 * _P.ringwidths[i] + 2 * (_P.ringspaces[i] or 0)
        end
        local xshift = _P.innerareawidth / 2
        local yshift = _P.innerareaheight / 2
        for i = 1, numsegments do
            geometry.rectanglebltr(cell, generics.other("deeptrenchisolation"),
                point.create(-xshift - _P.ringwidths[i], -maxheight / 2),
                point.create(-xshift, maxheight / 2)
            )
            geometry.rectanglebltr(cell, generics.other("deeptrenchisolation"),
                point.create(xshift, -maxheight / 2),
                point.create(xshift + _P.ringwidths[i], maxheight / 2)
            )
            geometry.rectanglebltr(cell, generics.other("deeptrenchisolation"),
                point.create(-maxwidth / 2, -yshift - _P.ringwidths[i]),
                point.create(maxwidth / 2, -yshift)
            )
            geometry.rectanglebltr(cell, generics.other("deeptrenchisolation"),
                point.create(-maxwidth / 2, yshift),
                point.create(maxwidth / 2, yshift + _P.ringwidths[i])
            )
            xshift = xshift + _P.ringwidths[i] + (_P.ringspaces[i] or 0)
            yshift = yshift + _P.ringwidths[i] + (_P.ringspaces[i] or 0)
        end
    else -- true rings
        local shift = 2 * _P.ringwidths[1]
        for i = 1, numsegments do
            geometry.ring(cell, generics.other("deeptrenchisolation"),
                point.create(0, 0),
                _P.innerareawidth + shift, _P.innerareaheight + shift,
                _P.ringwidths[i]
            )
            shift = shift + 2 * _P.ringwidths[i] + 2 * (_P.ringspaces[i] or 0)
            -- the space is guarded by 'or 0' as the last space is not strictly required
        end
    end
end
