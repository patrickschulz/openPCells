function parameters()
    pcell.add_parameters(
        { "metal", -1 },
        { "inductor_tracewidth", 0 },
        { "inductor_separation", 0 },
        { "trace_separation", 0, follow = "inductor_separation" },
        { "trace_tracewidth", 0 },
        { "extension", 0 },
        { "drawfillexcludes", true }
    )
end

function layout(connector, _P)
    local y1 = -math.abs(_P.inductor_separation / 2 - _P.trace_separation / 2)
    local y2 = -math.abs(_P.inductor_separation / 2 + _P.inductor_tracewidth - _P.trace_separation / 2 - _P.trace_tracewidth)

    -- left line
    geometry.polygon(connector, generics.metal(_P.metal), {
            point.create(-_P.inductor_separation / 2, 0),
            point.create(-_P.trace_separation / 2, y1),
            point.create(-_P.trace_separation / 2, -_P.extension),
            point.create(-_P.trace_separation / 2 - _P.trace_tracewidth, -_P.extension),
            point.create(-_P.trace_separation / 2 - _P.trace_tracewidth, y2),
            point.create(-_P.inductor_separation / 2 - _P.inductor_tracewidth, 0),
        }
    )
    
    -- right line
    geometry.polygon(connector, generics.metal(_P.metal), {
            point.create(_P.inductor_separation / 2, 0),
            point.create(_P.trace_separation / 2, y1),
            point.create(_P.trace_separation / 2, -_P.extension),
            point.create(_P.trace_separation / 2 + _P.trace_tracewidth, -_P.extension),
            point.create(_P.trace_separation / 2 + _P.trace_tracewidth, y2),
            point.create(_P.inductor_separation / 2 + _P.inductor_tracewidth, 0),
        }
    )

    connector:set_alignment_box(
        point.create(-_P.trace_separation / 2 - _P.trace_tracewidth, -_P.extension),
        point.create( _P.trace_separation / 2 + _P.trace_tracewidth,             0)
    )
    --[[
    connector:set_boundary_rectangular(
        point.create(-env.oscillator.gridfactor * env.decap.cellsize, -_P.extension),
        point.create( env.oscillator.gridfactor * env.decap.cellsize,             0)
    )

    -- excludes
    if _P.drawfillexcludes then
        for metal = 1, technology.resolve_metal(-1) do
            geometry.rectanglebltr(connector, generics.metalexclude(metal),
                point.create(-env.SSPLL.decapopeningnum / 2 * env.decap.cellsize, -_P.extension),
                point.create( env.SSPLL.decapopeningnum / 2 * env.decap.cellsize,             0)
            )
        end
    end
    --]]

    -- anchors
    connector:add_area_anchor_bltr("leftline",
        point.create(-_P.trace_separation / 2 - _P.trace_tracewidth, -_P.extension),
        point.create(-_P.trace_separation / 2 - _P.trace_tracewidth + _P.trace_tracewidth, 0)
    )
    connector:add_area_anchor_bltr("rightline",
        point.create( _P.trace_separation / 2 + _P.trace_tracewidth - _P.trace_tracewidth, -_P.extension),
        point.create( _P.trace_separation / 2 + _P.trace_tracewidth, 0)
    )
end
