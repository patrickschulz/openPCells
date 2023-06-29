function parameters()
    pcell.add_parameters(
        { "metalh", 1 },
        { "metalv", 2 },
        { "drawmetalh", true },
        { "drawmetalv", true },
        { "mhwidth", 100 },
        { "mhspace", 100 },
        { "mvwidth", 100 },
        { "mvspace", 100 },
        { "mhlines", 6 },
        { "mvlines", 3 },
        { "mvextb", 0 },
        { "mvextt", 0 },
        { "mhextl", 0 },
        { "mhextr", 0 },
        { "drawvias", true },
        { "centergrid", true },
        { "flatvias", true },
        { "flipvias", false }
    )
end

function check(_P)
    if not ((not _P.centergrid) or ((_P.mhlines % 2 == 1) and (_P.mhwidth % 2 == 0)) or ((_P.mhlines % 2 == 0) and (_P.mhspace % 2 == 0))) then
        return nil, "with 'centergrid': number of lines must be odd and width must be even or number of lines must be even and space must be even (horizontal)"
    end
    if not ((not _P.centergrid) or ((_P.mvlines % 2 == 1) and (_P.mvwidth % 2 == 0)) or ((_P.mvlines % 2 == 0) and (_P.mvspace % 2 == 0))) then
        return nil, "with 'centergrid': number of lines must be odd and width must be even or number of lines must be even and space must be even (vertical)"
    end
    return true
end

function layout(grid, _P)
    local xpitch = _P.mvwidth + _P.mvspace
    local ypitch = _P.mhwidth + _P.mhspace
    -- metal lines
    for i = 1, _P.mhlines do
        local xoffset = _P.centergrid and (-_P.mvlines * xpitch / 2) or 0
        local yoffset = _P.centergrid and (-_P.mhlines * ypitch / 2 + _P.mhspace / 2) or math.floor(_P.mhspace / 2)
        if _P.drawmetalh then
            geometry.rectanglebltr(
                grid, generics.metal(_P.metalh),
                point.create(xoffset - _P.mhextl,                                          (i - 1) * ypitch + yoffset),
                point.create(xoffset + _P.mhextr + _P.mvlines * (_P.mvwidth + _P.mvspace), (i - 1) * ypitch + yoffset + _P.mhwidth)
            )
            grid:add_area_anchor_bltr(string.format("h%d", i),
                point.create(xoffset - _P.mhextl,                                          (i - 1) * ypitch + yoffset),
                point.create(xoffset + _P.mhextr + _P.mvlines * (_P.mvwidth + _P.mvspace), (i - 1) * ypitch + yoffset + _P.mhwidth)
            )
        end
    end
    for i = 1, _P.mvlines do
        local xoffset = _P.centergrid and (-_P.mvlines * xpitch / 2 + _P.mvspace / 2) or math.floor(_P.mvspace / 2)
        local yoffset = _P.centergrid and (-_P.mhlines * ypitch / 2) or 0
        if _P.drawmetalv then
            geometry.rectanglebltr(
                grid, generics.metal(_P.metalv),
                point.create((i - 1) * xpitch + xoffset,              yoffset - _P.mvextb),
                point.create((i - 1) * xpitch + xoffset + _P.mvwidth, yoffset + _P.mvextt + _P.mhlines * (_P.mhwidth + _P.mhspace))
            )
            grid:add_area_anchor_bltr(string.format("v%d", i),
                point.create((i - 1) * xpitch + xoffset,              yoffset - _P.mvextb),
                point.create((i - 1) * xpitch + xoffset + _P.mvwidth, yoffset + _P.mvextt + _P.mhlines * (_P.mhwidth + _P.mhspace))
            )
        end
    end

    -- vias
    if _P.drawvias then
        local viaref = object.create("_via")
        geometry.viabltr(viaref, _P.metalh, _P.metalv,
            point.create(0,          0),
            point.create(_P.mvwidth, _P.mhwidth)
        )
        if not _P.flatvias then
            for i = 1, _P.mhlines do
                for j = 1, _P.mvlines do
                    local xoffset = _P.centergrid and (-_P.mvlines * xpitch / 2 + _P.mvspace / 2) or math.floor(_P.mvspace / 2)
                    local yoffset = _P.centergrid and (-_P.mhlines * ypitch / 2 + _P.mhspace / 2) or math.floor(_P.mhspace / 2)
                    if (i % 2 == (_P.flipvias and 1 or 0)) == (j % 2 == 0) then
                        grid:add_child(viaref, string.format("via_%d_%d", i, j)):translate((j - 1) * xpitch + xoffset, (i - 1) * ypitch + yoffset)
                    end
                end
            end
        else
            for i = 1, _P.mhlines do
                for j = 1, _P.mvlines do
                    local xoffset = _P.centergrid and (-_P.mvlines * xpitch / 2 + _P.mvspace / 2) or math.floor(_P.mvspace / 2)
                    local yoffset = _P.centergrid and (-_P.mhlines * ypitch / 2 + _P.mhspace / 2) or math.floor(_P.mhspace / 2)
                    if (i % 2 == (_P.flipvias and 1 or 0)) == (j % 2 == 0) then
                        grid:merge_into(viaref:copy():translate((j - 1) * xpitch + xoffset, (i - 1) * ypitch + yoffset))
                    end
                end
            end
        end
    end

    -- anchors
    local xoffset = _P.centergrid and (-_P.mvlines * xpitch / 2 + _P.mvspace / 2) or math.floor(_P.mvspace / 2)
    local yoffset = _P.centergrid and (-_P.mhlines * ypitch / 2) or 0
    grid:add_anchor("lowerleftv",
        point.create(xoffset,              yoffset - _P.mvextb),
        point.create(xoffset + _P.mvwidth, yoffset + _P.mvextt + _P.mhlines * (_P.mhwidth + _P.mhspace))
    )

    -- alignment box
    if _P.centergrid then
        grid:set_alignment_box(
            point.create(-_P.mvlines * (_P.mvwidth + _P.mvspace) / 2, -_P.mhlines * (_P.mhwidth + _P.mhspace) / 2),
            point.create(_P.mvlines * (_P.mvwidth + _P.mvspace) / 2, _P.mhlines * (_P.mhwidth + _P.mhspace) / 2)
        )
    else
        grid:set_alignment_box(
            point.create(0, 0),
            point.create(_P.mvlines * (_P.mvwidth + _P.mvspace), _P.mhlines * (_P.mhwidth + _P.mhspace))
        )
    end
end
