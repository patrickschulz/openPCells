function parameters()
    pcell.add_parameters(
        { "fingers",                2, posvals = even() },
        { "fingerwidth",            0 },
        { "channeltype",            "nmos", posvals = set("nmos", "pmos") },
        { "gatelength",             0 },
        { "gatestrapwidth",         0 },
        { "gatestrapspace",         0 },
        { "sourcemetal",            1 },
        { "sourcewidth",            0 },
        { "sourcespace",            0 },
        { "sourceskip",             0 },
        { "drainmetal",             1 },
        { "drainwidth",             0 },
        { "drainspace",             0 },
        { "gtopext",                0 },
        { "gbotext",                0 },
        { "drawguardring",          true },
        { "guardringwidth",         0 },
        { "guardringtopsep",        0 },
        { "guardringbottomsep",     0 },
        { "guardringleftsep",       0 },
        { "guardringrightsep",      0 },
        { "extendall",              0 },
        { "extendalltop",           0, follow = "extendall" },
        { "extendallbottom",        0, follow = "extendall" },
        { "extendallleft",          0, follow = "extendall" },
        { "extendallright",         0, follow = "extendall" },
        { "extendoxidetypetop",     0, follow = "extendalltop" },
        { "extendoxidetypebottom",  0, follow = "extendallbottom" },
        { "extendoxidetypeleft",    0, follow = "extendallleft" },
        { "extendoxidetyperight",   0, follow = "extendallright" },
        { "extendvthtypetop",       0, follow = "extendalltop" },
        { "extendvthtypebottom",    0, follow = "extendallbottom" },
        { "extendvthtypeleft",      0, follow = "extendallleft" },
        { "extendvthtyperight",     0, follow = "extendallright" },
        { "extendimplanttop",       0, follow = "extendalltop" },
        { "extendimplantbottom",    0, follow = "extendallbottom" },
        { "extendimplantleft",      0, follow = "extendallleft" },
        { "extendimplantright",     0, follow = "extendallright" },
        { "extendwelltop",          0, follow = "extendalltop" },
        { "extendwellbottom",       0, follow = "extendallbottom" },
        { "extendwellleft",         0, follow = "extendallleft" },
        { "extendwellright",        0, follow = "extendallright" }
    )
end

function layout(ldmos, _P)
    local xpitch = 2 * _P.sourcewidth + 2 * _P.sourcespace + 2 * _P.drainspace + _P.drainwidth + 2 * _P.gatelength + _P.sourceskip

    -- active region
    geometry.rectanglebltr(ldmos, generics.active(),
        point.create(0, 0),
        point.create(
            (_P.fingers / 2 - 1) * xpitch + 2 * _P.sourcewidth + 2 * _P.sourcespace + 2 * _P.drainspace + _P.drainwidth + 2 * _P.gatelength,
            _P.fingerwidth
        )
    )

    -- implant
    geometry.rectanglebltr(ldmos, generics.implant(_P.channeltype),
        point.create(
            -_P.extendimplantleft,
            -_P.gatestrapspace - _P.gatestrapwidth - _P.gbotext - _P.extendimplantbottom
        ),
        point.create(
            (_P.fingers / 2 - 1) * xpitch + 2 * _P.sourcewidth + 2 * _P.sourcespace + 2 * _P.drainspace + _P.drainwidth + 2 * _P.gatelength + _P.extendallright,
            _P.fingerwidth + _P.gatestrapspace + _P.gatestrapwidth + _P.gtopext + _P.extendimplanttop
        )
    )

    -- gates
    for i = 1, _P.fingers / 2 do
        geometry.rectanglebltr(ldmos, generics.gate(),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace,
                - _P.gatestrapspace - _P.gatestrapwidth - _P.gbotext
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength,
                _P.fingerwidth + _P.gatestrapspace + _P.gatestrapwidth + _P.gtopext
            )
        )
        geometry.rectanglebltr(ldmos, generics.gate(),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + 2 * _P.drainspace + _P.drainwidth,
                - _P.gatestrapspace - _P.gatestrapwidth - _P.gbotext
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + 2 * _P.drainspace + _P.drainwidth + _P.gatelength,
                _P.fingerwidth + _P.gatestrapspace + _P.gatestrapwidth + _P.gtopext
            )
        )
    end

    -- gate contacts
    for i = 1, _P.fingers / 2 do
        geometry.contactbltr(ldmos, "gate",
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace,
                _P.fingerwidth + _P.gatestrapspace
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength,
                _P.fingerwidth + _P.gatestrapspace + _P.gatestrapwidth
            )
        )
        geometry.contactbltr(ldmos, "gate",
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace,
                - _P.gatestrapspace - _P.gatestrapwidth
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength,
                - _P.gatestrapspace
            )
        )
        geometry.contactbltr(ldmos, "gate",
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + 2 * _P.drainspace + _P.drainwidth,
                - _P.gatestrapspace - _P.gatestrapwidth
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + 2 * _P.drainspace + _P.drainwidth + _P.gatelength,
                - _P.gatestrapspace
            )
        )
        geometry.contactbltr(ldmos, "gate",
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + 2 * _P.drainspace + _P.drainwidth,
                _P.fingerwidth + _P.gatestrapspace
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + 2 * _P.drainspace + _P.drainwidth + _P.gatelength,
                _P.fingerwidth + _P.gatestrapspace + _P.gatestrapwidth
            )
        )
    end

    -- source contacts
    for i = 1, _P.fingers / 2 do
        geometry.contactbltr(ldmos, "active",
            point.create(
                (i - 1) * xpitch,
                0
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth,
                _P.fingerwidth
            )
        )
        geometry.contactbltr(ldmos, "active",
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + 2 * _P.sourcespace + 2 * _P.drainspace + _P.drainwidth + 2 * _P.gatelength,
                0
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + 2 * _P.drainspace + _P.drainwidth + 2 * _P.gatelength + _P.sourcespace + _P.sourcewidth,
                _P.fingerwidth
            )
        )
    end

    -- drain contacts
    for i = 1, _P.fingers / 2 do
        geometry.contactbltr(ldmos, "active",
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + _P.drainspace,
                0
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + _P.drainspace + _P.drainwidth,
                _P.fingerwidth
            )
        )
    end

    -- guard ring
    if _P.drawguardring then
        local guardring = pcell.create_layout("auxiliary/guardring", "_guardring", {
            contype = _P.channeltype == "nmos" and "p" or "n",
            ringwidth = _P.guardringwidth,
            holewidth = (_P.fingers / 2 - 1) * xpitch + 2 * _P.sourcewidth + 2 * _P.sourcespace + 2 * _P.drainspace + _P.drainwidth + 2 * _P.gatelength  + _P.guardringleftsep + _P.guardringrightsep,
            holeheight = _P.fingerwidth + 2 * (_P.gatestrapwidth + _P.gatestrapspace) + _P.gtopext + _P.gbotext + _P.guardringtopsep + _P.guardringbottomsep,
            fillwell = true,
            --drawsegments = _P.guardringsegments,
            --fillimplant = _P.guardringfillimplant,
            --wellextension = _P.guardringwellextension,
            --implantextension = _P.guardringimplantextension,
            --soiopenextension = _P.guardringsoiopenextension,
        })
        guardring:move_point(guardring:get_area_anchor("innerboundary").bl, point.create(0, -_P.gatestrapspace - _P.gatestrapwidth - _P.gbotext))
        guardring:translate(-_P.guardringleftsep, -_P.guardringbottomsep)
        ldmos:merge_into(guardring)
    end
end
