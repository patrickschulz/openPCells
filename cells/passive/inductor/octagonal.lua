function parameters()
    pcell.add_parameters(
        { "topmetal(Top Conductor Metal)",                                   -1 },
        { "turns(Number of Turns)",                                           3 },
        { "radius(Radius)",                                               40000 },
        { "cornerradius(Corner Radius)",                                  14000 },
        { "width(Width)",                                                  6000 },
        { "separation(Line Separation)",                                   6000 },
        { "viashift(Via Shift)",                                              0 },
        { "viaoverlapextension(Via Overlap Extension)",                       0 },
        { "extension(Line Extension)",                                    40000 },
        { "extsep(Extension Separation)",                                  6000 },
        { "allow45(Allow Angles with 45 Degrees)",                         true },
        { "drawlvsresistor(Draw LVS Resistor)",                           false },
        { "lvsreswidth(LVS Resistor Width)",                               1000 },
        { "boundaryouterextension(Boundary Outer Extension)",              3000 },
        { "boundaryinnerextension(Boundary Inner Extension)",              3000 },
        { "fillboundary(Fill Boundary)",                                   true },
        { "rectangularboundary(Rectangular Boundary)",                    false },
        { "breaklines(Break Conductor Lines)",                            false },
        { "includeextensioninboundary(Include Extension in Boundary)",     true },
        { "drawoutline",                                                  false },
        { "outlineextension",                                                 0 },
        { "drawlvsmarker",                                                false },
        { "drawinductormarker",                                           false },
        { "inductormarkerextension",                                          0 },
        { "drawlowsubstratedopingmarker",                                 false },
        { "dopingmarkerextension",                                            0 },
        { "alignmentboxincludefeedlines",                                 false },
        { "alignmentboxextension",                                            0 }
    )
end

local function _scale_tanpi8(num)
    return math.floor(num * 5741 / 13860) -- rational approximation of tan(pi / 8)
end

function layout(inductor, _P)
    local pitch = _P.separation + _P.width

    local mainmetal = generics.metal(_P.topmetal)
    local auxmetal = generics.metal(_P.topmetal - 1)

    -- draw left and right segments
    local sign = (_P.turns % 2 == 0) and 1 or -1
    for i = 1, _P.turns do
        local radius = _P.radius + (i - 1) * pitch
        local radiustanpi8 = _scale_tanpi8(radius)
        sign = -sign

        local pathpts = {}
        local prepend = util.make_insert_xy(pathpts, 1)
        local append = util.make_insert_xy(pathpts)

        --append(-radiustanpi8 + _scale_tanpi8(_P.width / 2),  sign * radius)
        append(-radiustanpi8,  sign * radius)
        append(-radius,  sign * radiustanpi8)
        append(-radius, -sign * radiustanpi8)
        append(-radiustanpi8, -sign * radius)
        --append(-radiustanpi8 + _scale_tanpi8(_P.width / 2), -sign * radius)

        -- connect main lines to underpass
        if i < _P.turns then
            if radiustanpi8 > pitch / 2 + _scale_tanpi8(_P.width / 2) then
                prepend(-pitch / 2 - _scale_tanpi8(_P.width / 2),  sign * radius)
                append(-pitch / 2 - _scale_tanpi8(_P.width / 2), -sign * radius)
            else
                --prepend(-_scale_tanpi8(_P.radius / 2) - pitch / 4,  sign * radius)
                --append(-_scale_tanpi8(_P.radius / 2) - pitch / 4, -sign * radius)
            end
        end

        -- draw underpass
        if i < _P.turns then
            -- create underpass
            local up1pts = {}
            local up2pts = {}
            local append1 = util.make_insert_xy(up1pts)
            local append2 = util.make_insert_xy(up2pts)
            local via1bl, via1tr
            local via2bl, via2tr
            if radiustanpi8 > pitch / 2 + _scale_tanpi8(_P.width / 2) then
                append1(-pitch / 2 - _scale_tanpi8(_P.width / 2), -sign * radius)
                append1(-pitch / 2, -sign * radius)
                append1( pitch / 2, -sign * (radius + pitch))
                append1( pitch / 2 + _scale_tanpi8(_P.width / 2), -sign * (radius + pitch))
                append2(-pitch / 2 - _scale_tanpi8(_P.width / 2) - _P.viashift - _P.viaoverlapextension, -sign * radius)
                append2(-pitch / 2, -sign * radius)
                append2( pitch / 2, -sign * (radius + pitch))
                append2( pitch / 2 + _scale_tanpi8(_P.width / 2) + _P.viashift + _P.viaoverlapextension, -sign * (radius + pitch))
                -- via points
                via1bl = point.create(-pitch / 2 - _scale_tanpi8(_P.width / 2) - _P.viashift - _P.width / 2, -sign * (radius + pitch) - _P.width / 2)
                via1tr = point.create(-pitch / 2 - _scale_tanpi8(_P.width / 2) - _P.viashift + _P.width / 2, -sign * (radius + pitch) + _P.width / 2)
                via2bl = point.create( pitch / 2 + _scale_tanpi8(_P.width / 2) + _P.viashift - _P.width / 2, -sign * radius - _P.width / 2)
                via2tr = point.create( pitch / 2 + _scale_tanpi8(_P.width / 2) + _P.viashift + _P.width / 2, -sign * radius + _P.width / 2)
            else
                append1(-radiustanpi8, -sign * radius)
                append1(-radiustanpi8 + pitch, -sign * (radius + pitch))
                append1(-radiustanpi8 + pitch + _scale_tanpi8(_P.width / 2), -sign * (radius + pitch))
                append2(-radiustanpi8 - _P.viashift - _P.viaoverlapextension, -sign * radius + sign * (_P.viashift + _P.viaoverlapextension))
                append2(-radiustanpi8 + pitch, -sign * (radius + pitch))
                append2( pitch / 2 + _scale_tanpi8(_P.width / 2) + _P.viashift, -sign * (radius + pitch))
                append2( pitch / 2 + _scale_tanpi8(_P.width / 2) + _P.viashift + _P.viaoverlapextension, -sign * (radius + pitch))
                -- via points
                via1bl = point.create(
                    -pitch / 2 - _scale_tanpi8(_P.width / 2) - _P.viashift - _P.width / 2,
                    -sign * (radius + pitch) - _P.width / 2
                )
                via1tr = point.create(
                    -pitch / 2 - _scale_tanpi8(_P.width / 2) - _P.viashift + _P.width / 2,
                    -sign * (radius + pitch) + _P.width / 2
                )
                via2bl = point.create(
                    radiustanpi8 + _P.viashift - _P.width / 2,
                    -sign * radius + sign * _P.viashift - _P.width / 2
                )
                via2tr = point.create(
                    radiustanpi8 + _P.viashift + _P.width / 2,
                    -sign * radius + sign * _P.viashift + _P.width / 2
                )
            end
            geometry.path_polygon(inductor, mainmetal, up1pts, _P.width, true)
            geometry.path_polygon(inductor, auxmetal, util.xmirror(up2pts), _P.width, true)
            -- place vias
            geometry.viabarebltr(inductor, _P.topmetal, _P.topmetal - 1, via1bl, via1tr)
            geometry.viabarebltr(inductor, _P.topmetal, _P.topmetal - 1, via2bl, via2tr)
        end

        -- draw inner connection between left and right
        if i == 1 and not _P.breaklines then
            prepend(0, sign * radius)
        end

        -- draw connection to underpass of last turn
        if i == _P.turns then
            prepend(_scale_tanpi8(_P.radius + (_P.turns - 2) * pitch) - pitch - _scale_tanpi8(_P.width / 2), sign * radius)
        end

        -- draw connector
        if i == _P.turns then
            if _P.extsep / 2 + _P.width > radiustanpi8 + _scale_tanpi8(_P.width / 2) then
                append(-(_P.extsep + _P.width) / 2, -radiustanpi8 - radius + (_P.extsep + _P.width) / 2)
                append(-(_P.extsep + _P.width) / 2, -radiustanpi8 - radius + (_P.extsep + _P.width) / 2 - _P.extension)
            else
                append(-(_P.extsep + _P.width) / 2, -radius)
                append(-(_P.extsep + _P.width) / 2, -(radius + _P.width / 2))
                append(-(_P.extsep + _P.width) / 2, -(radius + _P.width / 2 + _P.extension))
            end
        end

        geometry.path_polygon(inductor, mainmetal, pathpts, _P.width, true)
        geometry.path_polygon(inductor, mainmetal, util.xmirror(pathpts), _P.width, true)
    end

    local lastradius = _P.radius + (_P.turns - 1) * pitch
    local lastr = _scale_tanpi8(lastradius)

    -- lvs resistor
    if _P.drawlvsresistor then
        geometry.rectanglebltr(inductor, generics.other(string.format("M%dlvsresistor", technology.resolve_metal(_P.metalnum))),
            inductor:get_area_anchor("leftline").bl,
            inductor:get_area_anchor("leftline").br:translate_y(_P.lvsreswidth)
        )
        geometry.rectanglebltr(inductor, generics.other(string.format("M%dlvsresistor", technology.resolve_metal(_P.metalnum))),
            inductor:get_area_anchor("rightline").bl,
            inductor:get_area_anchor("rightline").br:translate_y(_P.lvsreswidth)
        )
    end

    -- inductor marker
    if _P.drawinductormarker then
        geometry.rectanglebltr(inductor, generics.other("inductormarker"),
            point.create(-_P.radius - (_P.turns - 1) * pitch - _P.width / 2 - _P.inductormarkerextension, -_P.radius - (_P.turns - 1) * pitch - _P.width / 2 - _P.extension - _P.inductormarkerextension),
            point.create( _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.inductormarkerextension,  _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.inductormarkerextension)
        )
    end

    -- LVS marker
    if _P.drawlvsmarker then
        local pathpts = {}
        local append = util.make_insert_xy(pathpts)
        local radius = _P.radius + (_P.turns - 1) * pitch + _P.width / 2
        local radiustanpi8 = _scale_tanpi8(radius)
        append(-radiustanpi8 + _scale_tanpi8(_P.width / 2),  sign * radius)
        append(-radiustanpi8,  sign * radius)
        append(-radius,  sign * radiustanpi8)
        append(-radius, -sign * radiustanpi8)
        append(-radiustanpi8, -sign * radius)
        append(-radiustanpi8 + _scale_tanpi8(_P.width / 2), -sign * radius)
        append( radiustanpi8 + _scale_tanpi8(_P.width / 2), -sign * radius)
        append( radiustanpi8, -sign * radius)
        append( radius, -sign * radiustanpi8)
        append( radius,  sign * radiustanpi8)
        append( radiustanpi8,  sign * radius)
        --append( radiustanpi8 + _scale_tanpi8(_P.width / 2),  sign * radius)
        geometry.polygon(
            inductor, 
            generics.other("inductorlvsmarker"),
            pathpts
        )
    end

    -- outline
    if _P.drawoutline then
        geometry.rectanglebltr(inductor, generics.outline(),
            point.create(-_P.radius - (_P.turns - 1) * pitch - _P.width / 2 - _P.outlineextension, -_P.radius - (_P.turns - 1) * pitch - _P.width / 2 - _P.extension - _P.outlineextension),
            point.create( _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.outlineextension,  _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.outlineextension)
        )
    end

    -- low substrat doping marker
    if _P.drawlowsubstratedopingmarker then
        geometry.rectanglebltr(inductor, generics.other("subblock"),
            point.create(-_P.radius - (_P.turns - 1) * pitch - _P.width / 2 - _P.dopingmarkerextension, -_P.radius - (_P.turns - 1) * pitch - _P.width / 2 - _P.extension - _P.dopingmarkerextension),
            point.create( _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.dopingmarkerextension,  _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.dopingmarkerextension)
        )
    end

    -- input lines anchors
    if _P.extsep / 2 + _P.width > lastr + _scale_tanpi8(_P.width / 2) then
        -- FIXME
        --inductor:add_area_anchor_bltr("leftline",
        --    point.create(-(_P.extsep + _P.width) / 2, -lastr - lastradius + (_P.extsep + _P.width) / 2),
        --    point.create(-(_P.extsep + _P.width) / 2, -lastr - lastradius + (_P.extsep + _P.width) / 2 - _P.extension)
        --)
    else
        inductor:add_area_anchor_bltr("leftline",
            point.create(-_P.extsep / 2 - _P.width, -(lastradius + _P.width / 2 + _P.extension)),
            point.create(-_P.extsep / 2, -lastradius - _P.width / 2)
        )
    end
    if _P.extsep / 2 + _P.width > lastr + _scale_tanpi8(_P.width / 2) then
        -- FIXME
        --inductor:add_area_anchor_bltr("rightline",
        --    point.create( (_P.extsep + _P.width) / 2, -lastr - lastradius + (_P.extsep + _P.width) / 2),
        --    point.create( (_P.extsep + _P.width) / 2, -lastr - lastradius + (_P.extsep + _P.width) / 2 - _P.extension)
        --)
    else
        inductor:add_area_anchor_bltr("rightline",
            point.create( _P.extsep / 2, -(lastradius + _P.width / 2 + _P.extension)),
            point.create( _P.extsep / 2 + _P.width, -lastradius - _P.width / 2)
        )
    end

    -- alignment box
    if _P.alignmentboxincludefeedlines then
        inductor:set_alignment_box(
            point.create(-_P.radius - (_P.turns - 1) * pitch - _P.width / 2 - _P.alignmentboxextension, -_P.radius - (_P.turns - 1) * pitch - _P.width / 2 - _P.alignmentboxextension - _P.extension),
            point.create( _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.alignmentboxextension,  _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.alignmentboxextension)
        )
    else
        inductor:set_alignment_box(
            point.create(-_P.radius - (_P.turns - 1) * pitch - _P.width / 2 - _P.alignmentboxextension, -_P.radius - (_P.turns - 1) * pitch - _P.width / 2 - _P.alignmentboxextension),
            point.create( _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.alignmentboxextension,  _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.alignmentboxextension)
        )
    end

    -- boundary
    if _P.rectangularboundary then
        inductor:set_boundary_rectangular(
            point.create(-_P.radius + (_P.turns - 1) * pitch - _P.width / 2 - _P.boundaryouterextension, -_P.radius + (_P.turns - 1) * pitch - _P.width / 2 - _P.boundaryouterextension),
            point.create( _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.boundaryouterextension,  _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.boundaryouterextension)
        )
    else
        local outerradius = _P.radius + (_P.turns - 1) * pitch + _P.width / 2 + _P.boundaryouterextension
        local outerr = _scale_tanpi8(outerradius)
        local innerradius = _P.radius + (_P.turns - 1) * pitch - _P.width / 2 - _P.boundaryinnerextension
        local innerr = _scale_tanpi8(innerradius)
        local outerpathpts = {}
        local outerappend = util.make_insert_xy(outerpathpts)
        -- left
        outerappend(-outerr + _scale_tanpi8(_P.width / 2),  outerradius)
        outerappend(-outerr,  outerradius)
        outerappend(-outerradius,  outerr)
        outerappend(-outerradius, -outerr)
        outerappend(-outerr, -outerradius)
        outerappend(-outerr + _scale_tanpi8(_P.width / 2), -outerradius)
        if _P.includeextensioninboundary then -- FIXME: if separation is large, the point order could be wrong
            outerappend(-_P.separation / 2 - _P.width - _P.boundaryouterextension, -outerradius)
            outerappend(-_P.separation / 2 - _P.width - _P.boundaryouterextension, -outerradius - _P.extension)
        end
        --if not _P.fillboundary then
        --    outerappend(0, -outerradius)
        --    outerappend(0, -innerradius)
        --    outerappend(-innerr + _scale_tanpi8(_P.width / 2), -innerradius)
        --    outerappend(-innerr, -innerradius)
        --    outerappend(-innerradius, -innerr)
        --    outerappend(-innerradius,  innerr)
        --    outerappend(-innerr,  innerradius)
        --end
        ---- right
        --if not _P.fillboundary then
        --    outerappend( innerr,  innerradius)
        --    outerappend( innerradius,  innerr)
        --    outerappend( innerradius, -innerr)
        --    outerappend( innerr, -innerradius)
        --    outerappend(0, -innerradius)
        --    outerappend(0, -outerradius)
        --end
        if _P.includeextensioninboundary then -- FIXME: if separation is large, the point order could be wrong
            outerappend( _P.separation / 2 + _P.width + _P.boundaryouterextension, -outerradius - _P.extension)
            outerappend( _P.separation / 2 + _P.width + _P.boundaryouterextension, -outerradius)
        end
        outerappend( outerr - _scale_tanpi8(_P.width / 2), -outerradius)
        outerappend( outerr, -outerradius)
        outerappend( outerradius, -outerr)
        outerappend( outerradius,  outerr)
        outerappend( outerr,  outerradius)
        outerappend( outerr - _scale_tanpi8(_P.width / 2),  outerradius)
        inductor:set_boundary(outerpathpts)
        -- add layer boundaries (taken from circular inductor, this might need some adapting (for instance, the number of turns is not used))
        -- the correction factor for the circle radius is 1 / cos(pi / 8). This is required since the start angle for the circle calculation distorts the radius
        -- it's basic trigonometry, if it's unclear draw a triangle at the corners of the inductor
        local innerlayerboundary = graphics.coarse_circle(1.08239 * (_P.radius - _P.width / 2 - _P.boundaryinnerextension), 8, -math.pi / 8)
        local outerlayerboundary = graphics.coarse_circle(1.08239 * (_P.turns * _P.radius + _P.width / 2 + _P.boundaryouterextension), 8, -math.pi / 8)
        local layerboundary = {}
        if not _P.fillboundary then
            util.merge_forwards(layerboundary, innerlayerboundary)
        end
        util.merge_backwards(layerboundary, outerlayerboundary)
        inductor:add_layer_boundary(generics.metal(_P.topmetal), layerboundary)
    end
end
