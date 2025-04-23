function parameters()
    pcell.add_parameters(
        { "fingers",                        2, posvals = even() },
        { "fingerwidth",                    0 },
        { "channeltype",                    "nmos", posvals = set("nmos", "pmos") },
        { "gatelength",                     0 },
        { "gatestrapwidth",                 0 },
        { "gatestrapspace",                 0 },
        { "gatemetal",                      1 },
        { "sourcemetal",                    1 },
        { "sourcewidth",                    0 },
        { "sourcespace",                    0 },
        { "sourceskip",                     0 },
        { "drainmetal",                     1 },
        { "drainwidth",                     0 },
        { "drainspace",                     0 },
        { "gtopext",                        0 },
        { "gbotext",                        0 },
        { "subblocksourceextension",        0 },
        { "subblockdrainextension",         0 },
        { "subblocktopbottomextension",     0 },
        { "subblocktopextension",           0, follow = "subblocktopbottomextension" },
        { "subblockbottomextension",        0, follow = "subblocktopbottomextension" },
        { "drawinnerguardring",             true },
        { "guardringwidth",                 0 },
        { "guardringtopsep",                0 },
        { "guardringbottomsep",             0 },
        { "guardringleftsep",               0 },
        { "guardringrightsep",              0 },
        { "drainwellextendleftright",       0 },
        { "drainwellextendtopbottom",       0 },
        { "extendall",                      0 },
        { "extendalltop",                   0, follow = "extendall" },
        { "extendallbottom",                0, follow = "extendall" },
        { "extendallleft",                  0, follow = "extendall" },
        { "extendallright",                 0, follow = "extendall" },
        { "extendoxidetypetop",             0, follow = "extendalltop" },
        { "extendoxidetypebottom",          0, follow = "extendallbottom" },
        { "extendoxidetypeleft",            0, follow = "extendallleft" },
        { "extendoxidetyperight",           0, follow = "extendallright" },
        { "extendvthtypetop",               0, follow = "extendalltop" },
        { "extendvthtypebottom",            0, follow = "extendallbottom" },
        { "extendvthtypeleft",              0, follow = "extendallleft" },
        { "extendvthtyperight",             0, follow = "extendallright" },
        { "extendimplanttop",               0, follow = "extendalltop" },
        { "extendimplantbottom",            0, follow = "extendallbottom" },
        { "extendimplantleft",              0, follow = "extendallleft" },
        { "extendimplantright",             0, follow = "extendallright" },
        { "extendwelltop",                  0, follow = "extendalltop" },
        { "extendwellbottom",               0, follow = "extendallbottom" },
        { "extendwellleft",                 0, follow = "extendallleft" },
        { "extendwellright",                0, follow = "extendallright" },
        { "extendsoiopentop",               0, follow = "extendalltop" },
        { "extendsoiopenbottom",            0, follow = "extendallbottom" },
        { "extendsoiopenleft",              0, follow = "extendallleft" },
        { "extendsoiopenright",             0, follow = "extendallright" }
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

    -- gate straps
    geometry.rectanglebltr(ldmos, generics.metal(1),
        point.create(
            (1 - 1) * xpitch + _P.sourcewidth + _P.sourcespace,
            _P.fingerwidth + _P.gatestrapspace
        ),
        point.create(
            (_P.fingers / 2 - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + 2 * _P.drainspace + _P.drainwidth + _P.gatelength,
            _P.fingerwidth + _P.gatestrapspace + _P.gatestrapwidth
        )
    )
    geometry.rectanglebltr(ldmos, generics.metal(1),
        point.create(
            (1 - 1) * xpitch + _P.sourcewidth + _P.sourcespace,
            - _P.gatestrapspace - _P.gatestrapwidth
        ),
        point.create(
            (_P.fingers / 2 - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + 2 * _P.drainspace + _P.drainwidth + _P.gatelength,
            - _P.gatestrapspace
        )
    )
    if _P.gatemetal > 1 then
        geometry.viabltr(ldmos, 1, _P.gatemetal,
            point.create(
                (1 - 1) * xpitch + _P.sourcewidth + _P.sourcespace,
                _P.fingerwidth + _P.gatestrapspace
            ),
            point.create(
                (_P.fingers / 2 - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + 2 * _P.drainspace + _P.drainwidth + _P.gatelength,
                _P.fingerwidth + _P.gatestrapspace + _P.gatestrapwidth
            )
        )
        geometry.viabltr(ldmos, 1, _P.gatemetal,
            point.create(
                (1 - 1) * xpitch + _P.sourcewidth + _P.sourcespace,
                - _P.gatestrapspace - _P.gatestrapwidth
            ),
            point.create(
                (_P.fingers / 2 - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + 2 * _P.drainspace + _P.drainwidth + _P.gatelength,
                - _P.gatestrapspace
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
        if _P.sourcemetal > 1 then
            geometry.viabltr(ldmos, 1, _P.sourcemetal,
                point.create(
                    (i - 1) * xpitch,
                    0
                ),
                point.create(
                    (i - 1) * xpitch + _P.sourcewidth,
                    _P.fingerwidth
                )
            )
            geometry.viabltr(ldmos, 1, _P.sourcemetal,
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
        if _P.drainmetal > 1 then
            geometry.viabltr(ldmos, 1, _P.drainmetal,
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
    end

    -- drain well
    for i = 1, _P.fingers / 2 do
        geometry.rectanglebltr(ldmos, generics.other("nwell"),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + _P.drainspace - _P.drainwellextendleftright,
                -_P.drainwellextendtopbottom
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + _P.drainspace + _P.drainwidth + _P.drainwellextendleftright,
                _P.fingerwidth + _P.drainwellextendtopbottom
            )
        )
    end

    -- soi open
    if not _P.drawinnerguardring then
        geometry.rectanglebltr(ldmos, generics.other("soiopen"),
            point.create(
                - _P.extendsoiopenleft + _P.sourcewidth,
                - _P.gatestrapspace - _P.gatestrapwidth - _P.gbotext - _P.extendsoiopenbottom
            ),
            point.create(
                (_P.fingers / 2 - 1) * xpitch + _P.sourcewidth + _P.sourcespace + 2 * _P.drainspace + _P.drainwidth + 2 * _P.gatelength + _P.sourcespace + _P.sourcewidth + _P.extendsoiopenright,
                _P.fingerwidth + _P.gatestrapspace + _P.gatestrapwidth + _P.gtopext + _P.extendsoiopentop
            )
        )
    end

    -- substrate doping blocker
    for i = 1, _P.fingers / 2 do
        geometry.rectanglebltr(ldmos, generics.other("subblock"),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace - _P.subblocksourceextension,
                -_P.subblockbottomextension
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.gatelength + _P.subblockdrainextension,
                _P.fingerwidth + _P.subblocktopextension
            )
        )
        geometry.rectanglebltr(ldmos, generics.other("subblock"),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace - _P.subblockdrainextension + _P.gatelength + 2 * _P.drainspace + _P.drainwidth,
                -_P.subblockbottomextension
            ),
            point.create(
                (i - 1) * xpitch + _P.sourcewidth + _P.sourcespace + _P.subblocksourceextension + _P.gatelength + 2 * _P.drainspace + _P.drainwidth + _P.gatelength,
                _P.fingerwidth + _P.subblocktopextension
            )
        )
    end

    -- guard ring
    if _P.drawinnerguardring then
        local guardring = pcell.create_layout("auxiliary/guardring", "_guardring", {
            contype = _P.channeltype == "nmos" and "p" or "n",
            ringwidth = _P.guardringwidth,
            holewidth = (_P.fingers / 2 - 1) * xpitch + 2 * _P.sourcewidth + 2 * _P.sourcespace + 2 * _P.drainspace + _P.drainwidth + 2 * _P.gatelength  + _P.guardringleftsep + _P.guardringrightsep,
            holeheight = _P.fingerwidth + 2 * (_P.gatestrapwidth + _P.gatestrapspace) + _P.gtopext + _P.gbotext + _P.guardringtopsep + _P.guardringbottomsep,
            fillwell = false,
            fillsoiopen = true,
            fillinnerimplant = true,
            innerimplantpolarity = _P.channeltype == "nmos" and "n" or "p",
        })
        guardring:move_point(guardring:get_area_anchor("innerboundary").bl, point.create(0, -_P.gatestrapspace - _P.gatestrapwidth - _P.gbotext))
        guardring:translate(-_P.guardringleftsep, -_P.guardringbottomsep)
        ldmos:merge_into(guardring)
        ldmos:set_alignment_box(
            guardring:get_area_anchor("outerboundary").bl,
            guardring:get_area_anchor("outerboundary").tr,
            guardring:get_area_anchor("innerboundary").bl,
            guardring:get_area_anchor("innerboundary").tr
        )
    end
end
