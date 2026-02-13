function parameters()
    pcell.add_parameters(
        { "metalh", 1 },
        { "metalv", 2 },
        { "drawmetalh", true },
        { "drawmetalv", true },
        { "mhwidth", technology.get_dimension("Minimum M1M2 Viawidth") },
        { "mhspace", technology.get_dimension("Minimum M1 Space") },
        { "mvwidth", technology.get_dimension("Minimum M1M2 Viawidth") },
        { "mvspace", technology.get_dimension("Minimum M2 Space") },
        --{ "mhlines", 2 },
        --{ "mvlines", 2 },
        { "hnets", { "vdd", "vss" } },
        { "vnets", { "vdd", "vss" } },
        { "mvextb", 0 },
        { "mvextt", 0 },
        { "mhextl", 0 },
        { "mhextr", 0 },
        { "mvoddextb", 0, follow = "mvextb" },
        { "mvoddextt", 0, follow = "mvextt" },
        { "mhoddextl", 0, follow = "mhextl" },
        { "mhoddextr", 0, follow = "mhextr" },
        { "mvevenextb", 0, follow = "mvextb" },
        { "mvevenextt", 0, follow = "mvextt" },
        { "mhevenextl", 0, follow = "mhextl" },
        { "mhevenextr", 0, follow = "mhextr" },
        { "drawvias", true },
        { "forcevias", false},
        { "continuousvias", false },
        { "centergrid", true },
        { "flatvias", true },
        { "drawfillexclude", false },
        { "addlabels", true },
        { "addvlabels", true, follow = "addlabels" },
        { "addhlabels", true, follow = "addlabels" },
        --{ "label_sizehint", technology.get_optional_dimension("Default Label Size", 0) }
        { "label_sizehint", 50 }
    )
end

function prepare(_P)
    local state = {}
    state.mhlines = #_P.hnets
    state.mvlines = #_P.vnets
    state.unique_hnets = #util.uniq(_P.hnets)
    state.unique_vnets = #util.uniq(_P.vnets)
    return state
end

function check(_P, state)
    if not ((not _P.centergrid) or ((state.mhlines % 2 == 1) and (_P.mhwidth % 2 == 0)) or ((state.mhlines % 2 == 0) and (_P.mhspace % 2 == 0))) then
        return false, "with 'centergrid': number of lines must be odd and width must be even or number of lines must be even and space must be even (horizontal)"
    end
    if not ((not _P.centergrid) or ((state.mvlines % 2 == 1) and (_P.mvwidth % 2 == 0)) or ((state.mvlines % 2 == 0) and (_P.mvspace % 2 == 0))) then
        return false, "with 'centergrid': number of lines must be odd and width must be even or number of lines must be even and space must be even (vertical)"
    end
    if state.unique_hnets ~= state.unique_vnets then
        return false, "'hnets' and 'vnets' contain nets that are not present in both specifications"
    end
    return true
end

function layout(grid, _P, _unused, state)
    local xpitch = _P.mvwidth + _P.mvspace
    local ypitch = _P.mhwidth + _P.mhspace
    local mhlines = state.mhlines
    local mvlines = state.mvlines
    -- metal lines
    for i = 1, mhlines do
        local xoffset = _P.centergrid and (-mvlines * xpitch / 2) or 0
        local yoffset = _P.centergrid and (-mhlines * ypitch / 2 + _P.mhspace / 2) or math.floor(_P.mhspace / 2)
        local mhextl = (i % 2 == 0) and _P.mhevenextl or _P.mhoddextl
        local mhextr = (i % 2 == 0) and _P.mhevenextr or _P.mhoddextr
        if _P.drawmetalh then
            geometry.rectanglebltr(
                grid, generics.metal(_P.metalh),
                point.create(xoffset - mhextl,                                          (i - 1) * ypitch + yoffset),
                point.create(xoffset + mhextr + mvlines * (_P.mvwidth + _P.mvspace), (i - 1) * ypitch + yoffset + _P.mhwidth)
            )
            grid:add_area_anchor_bltr(string.format("h%d", i),
                point.create(xoffset - mhextl,                                          (i - 1) * ypitch + yoffset),
                point.create(xoffset + mhextr + mvlines * (_P.mvwidth + _P.mvspace), (i - 1) * ypitch + yoffset + _P.mhwidth)
            )
        end
    end
    for i = 1, mvlines do
        local xoffset = _P.centergrid and (-mvlines * xpitch / 2 + _P.mvspace / 2) or math.floor(_P.mvspace / 2)
        local yoffset = _P.centergrid and (-mhlines * ypitch / 2) or 0
        local mvextt = (i % 2 == 0) and _P.mvevenextt or _P.mvoddextt
        local mvextb = (i % 2 == 0) and _P.mvevenextb or _P.mvoddextb
        if _P.drawmetalv then
            geometry.rectanglebltr(
                grid, generics.metal(_P.metalv),
                point.create((i - 1) * xpitch + xoffset,              yoffset - mvextb),
                point.create((i - 1) * xpitch + xoffset + _P.mvwidth, yoffset + mvextt + mhlines * (_P.mhwidth + _P.mhspace))
            )
            grid:add_area_anchor_bltr(string.format("v%d", i),
                point.create((i - 1) * xpitch + xoffset,              yoffset - mvextb),
                point.create((i - 1) * xpitch + xoffset + _P.mvwidth, yoffset + mvextt + mhlines * (_P.mhwidth + _P.mhspace))
            )
        end
    end

    -- vias
    if (_P.drawmetalh and _P.drawmetalv and _P.drawvias) or _P.forcevias then
        local viaref = object.create("_via")
        if _P.continuousvias then
            geometry.viabarebltr_continuous(viaref, _P.metalh, _P.metalv,
                point.create(0,          0),
                point.create(_P.mvwidth, _P.mhwidth)
            )
        else
            geometry.viabarebltr(viaref, _P.metalh, _P.metalv,
                point.create(0,          0),
                point.create(_P.mvwidth, _P.mhwidth)
            )
        end
        for i = 1, mhlines do
            for j = 1, mvlines do
                local xoffset = _P.centergrid and (-mvlines * xpitch / 2 + _P.mvspace / 2) or math.floor(_P.mvspace / 2)
                local yoffset = _P.centergrid and (-mhlines * ypitch / 2 + _P.mhspace / 2) or math.floor(_P.mhspace / 2)
                if _P.flatvias then
                    if _P.hnets[i] == _P.vnets[j] then
                        local v = viaref:copy()
                        v:translate_x((j - 1) * xpitch + xoffset)
                        v:translate_y((i - 1) * ypitch + yoffset)
                        grid:merge_into(v)
                    end
                else
                    if _P.hnets[i] == _P.vnets[j] then
                        local v = grid:add_child(viaref, string.format("via_%d_%d", i, j))
                        v:translate_x((j - 1) * xpitch + xoffset)
                        v:translate_y((i - 1) * ypitch + yoffset)
                    end
                end
            end
        end
    end

    -- labels
    if _P.addhlabels then
        for i = 1, mhlines do
            local xoffset = _P.centergrid and (-mvlines * xpitch / 2) or math.floor(_P.mvspace / 2)
            local yoffset = _P.centergrid and (-mhlines * ypitch / 2 + _P.mhspace / 2 + _P.mhwidth / 2) or math.floor(_P.mhspace / 2)
            grid:add_label(_P.hnets[i], generics.metal(_P.metalh), point.create(xoffset, (i - 1) * ypitch + yoffset), _P.label_sizehint)
        end
    end
    if _P.addvlabels then
        for i = 1, mvlines do
            local xoffset = _P.centergrid and (-mvlines * xpitch / 2 + _P.mvspace / 2 + _P.mvwidth / 2) or math.floor(_P.mvspace / 2)
            local yoffset = _P.centergrid and (-mhlines * ypitch / 2) or math.floor(_P.mhspace / 2)
            grid:add_label(_P.vnets[i], generics.metal(_P.metalv), point.create((i - 1) * xpitch + xoffset, yoffset), _P.label_sizehint)
        end
    end

    -- fill excludes
    if _P.drawfillexclude then
        if _P.drawmetalh then
            if _P.centergrid then
                geometry.rectanglebltr(grid, generics.metalexclude(_P.metalh),
                    point.create(-mvlines * (_P.mvwidth + _P.mvspace) / 2, -mhlines * (_P.mhwidth + _P.mhspace) / 2),
                    point.create(mvlines * (_P.mvwidth + _P.mvspace) / 2, mhlines * (_P.mhwidth + _P.mhspace) / 2)
                )
            else
                geometry.rectanglebltr(grid, generics.metalexclude(_P.metalh),
                    point.create(0, 0),
                    point.create(mvlines * (_P.mvwidth + _P.mvspace), mhlines * (_P.mhwidth + _P.mhspace))
                )
            end
        end
        if _P.drawmetalv then
            if _P.centergrid then
                geometry.rectanglebltr(grid, generics.metalexclude(_P.metalv),
                    point.create(-mvlines * (_P.mvwidth + _P.mvspace) / 2, -mhlines * (_P.mhwidth + _P.mhspace) / 2),
                    point.create(mvlines * (_P.mvwidth + _P.mvspace) / 2, mhlines * (_P.mhwidth + _P.mhspace) / 2)
                )
            else
                geometry.rectanglebltr(grid, generics.metalexclude(_P.metalv),
                    point.create(0, 0),
                    point.create(mvlines * (_P.mvwidth + _P.mvspace), mhlines * (_P.mhwidth + _P.mhspace))
                )
            end
        end
    end

    -- anchors
    local xoffset = _P.centergrid and (-mvlines * xpitch / 2 + _P.mvspace / 2) or math.floor(_P.mvspace / 2)
    local yoffset = _P.centergrid and (-mhlines * ypitch / 2) or 0
    grid:add_anchor("lowerleftv", point.create(xoffset, yoffset - _P.mvextb))

    -- alignment box
    if _P.centergrid then
        grid:set_alignment_box(
            point.create(-mvlines * (_P.mvwidth + _P.mvspace) / 2, -mhlines * (_P.mhwidth + _P.mhspace) / 2),
            point.create(mvlines * (_P.mvwidth + _P.mvspace) / 2, mhlines * (_P.mhwidth + _P.mhspace) / 2)
        )
    else
        grid:set_alignment_box(
            point.create(0, 0),
            point.create(mvlines * (_P.mvwidth + _P.mvspace), mhlines * (_P.mhwidth + _P.mhspace))
        )
    end
end
