function parameters()
    pcell.add_parameters(
        { "contype",                                       "p" },
        { "topmetal",                                        1 },
        { "holewidth",                                    5000 },
        { "holeheight",                                   5000 },
        { "ringwidth",                                     200 },
        { "drawsegments", { "left", "right", "top", "bottom" } },
        { "wellextension",                                  50 },
        { "soiopenextension",                               50 },
        { "implantextension",                               50 },
        { "fillwell",                                     true },
        { "fillwelldrawhole",                            false },
        { "fillwellholeoffsettop",                           0 },
        { "fillwellholeoffsetbottom",                           0 },
        { "fillwellholeoffsetleft",                          0 },
        { "fillwellholeoffsetright",                         0 },
        { "drawdeepwell",                                false },
        { "deepwelloffset",                                  0 },
        { "fit",                                         false },
        { "fixextensions",                                true }
    )
end

function layout(guardring, _P)
    local contactbase
    local xrep, yrep
    local holewidth, holeheight
    local extfixx = 0
    local extfixy = 0
    if _P.fit then
        xrep = math.ceil(_P.holewidth / _P.ringwidth)
        yrep = math.ceil(_P.holeheight / _P.ringwidth)
        holewidth = _P.ringwidth * xrep
        holeheight = _P.ringwidth * yrep
        contactbase = object.create("_contact")
        geometry.contactbare(contactbase, "active", _P.ringwidth, _P.ringwidth, 0, 0, 1, 1, 0, 0, { xcontinuous = true, ycontinuous = true })
        if _P.fixextensions then
            extfixx = holewidth - _P.holewidth
            extfixy = holeheight - _P.holeheight
        end
    else
        holewidth = _P.holewidth
        holeheight = _P.holeheight
    end

    local topmetal = technology.resolve_metal(_P.topmetal)
    if aux.any_of("top", _P.drawsegments) then
        if _P.fit then
            for i = 1, xrep + 2 do
                guardring:merge_into(contactbase:move_to((i - xrep / 2 - 1.5) * _P.ringwidth, (holeheight + _P.ringwidth) / 2))
            end
        else
            geometry.contactbarebltr(guardring, "active",
                point.create(0, holeheight),
                point.create(holewidth, holeheight + _P.ringwidth)
            )
        end
        for i = 1, topmetal do
            geometry.rectanglebltr(guardring, generics.metal(i),
                point.create(-_P.ringwidth, holeheight),
                point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
            )
        end
        if topmetal ~= 1 then
            geometry.viabltr(guardring, 1, topmetal,
                point.create(0, holeheight),
                point.create(holewidth, holeheight + _P.ringwidth)
            )
        end
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(-_P.ringwidth, holeheight),
            point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
        )
        geometry.rectanglebltr(guardring, generics.implant(_P.contype),
            point.create(-_P.ringwidth - _P.implantextension - extfixx / 2, holeheight - _P.implantextension - extfixy / 2),
            point.create(holewidth + _P.ringwidth + _P.implantextension + extfixx / 2, holeheight + _P.ringwidth + _P.implantextension + extfixy / 2)
        )
        geometry.rectanglebltr(guardring, generics.other("soiopen"),
            point.create(-_P.ringwidth - _P.soiopenextension - extfixx / 2, holeheight - _P.soiopenextension - extfixy / 2),
            point.create(holewidth + _P.ringwidth + _P.soiopenextension + extfixx / 2, holeheight + _P.ringwidth + _P.soiopenextension + extfixy / 2)
        )
    end
    if aux.any_of("bottom", _P.drawsegments) then
        if _P.fit then
            for i = 1, xrep + 2 do
                guardring:merge_into(contactbase:move_to((i - xrep / 2 - 1.5) * _P.ringwidth, -(holeheight + _P.ringwidth) / 2))
            end
        else
            geometry.contactbarebltr(guardring, "active",
                point.create(0, -_P.ringwidth),
                point.create(holewidth, 0)
            )
        end
        for i = 1, topmetal do
            geometry.rectanglebltr(guardring, generics.metal(i),
                point.create(-_P.ringwidth, -_P.ringwidth),
                point.create(holewidth + _P.ringwidth, 0)
            )
        end
        if topmetal ~= 1 then
            geometry.viabltr(guardring, 1, topmetal,
                point.create(0, -_P.ringwidth),
                point.create(holewidth, 0)
            )
        end
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(-_P.ringwidth, -_P.ringwidth),
            point.create(holewidth + _P.ringwidth, 0)
        )
        geometry.rectanglebltr(guardring, generics.implant(_P.contype),
            point.create(-_P.ringwidth - _P.implantextension - extfixx / 2, -_P.implantextension - _P.ringwidth - extfixy / 2),
            point.create(holewidth + _P.ringwidth + _P.implantextension + extfixx / 2, _P.implantextension + extfixy / 2)
        )
        geometry.rectanglebltr(guardring, generics.other("soiopen"),
            point.create(-_P.ringwidth - _P.soiopenextension - extfixx / 2, -_P.ringwidth - _P.soiopenextension - extfixy / 2),
            point.create(holewidth + _P.ringwidth + _P.soiopenextension + extfixx / 2, _P.soiopenextension + extfixy / 2)
        )
    end
    if aux.any_of("left", _P.drawsegments) then
        if _P.fit then
            for i = 1, yrep + 2 do
                guardring:merge_into(contactbase:move_to(-(holewidth + _P.ringwidth) / 2, (i - yrep / 2 - 1.5) * _P.ringwidth))
            end
        else
            geometry.contactbarebltr(guardring, "active",
                point.create(-_P.ringwidth, 0),
                point.create(0,  holeheight)
            )
        end
        for i = 1, topmetal do
            geometry.rectanglebltr(guardring, generics.metal(i),
                point.create(-_P.ringwidth, -_P.ringwidth),
                point.create(0,  holeheight + _P.ringwidth)
            )
        end
        if topmetal ~= 1 then
            geometry.viabltr(guardring, 1, topmetal,
                point.create(-_P.ringwidth, 0),
                point.create(0,  holeheight)
            )
        end
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(-_P.ringwidth, -_P.ringwidth),
            point.create(0,  holeheight + _P.ringwidth)
        )
        geometry.rectanglebltr(guardring, generics.implant(_P.contype),
            point.create(-_P.implantextension - _P.ringwidth - extfixx / 2, -_P.implantextension - _P.ringwidth - extfixy / 2),
            point.create(_P.implantextension + extfixx / 2,  holeheight + _P.implantextension + _P.ringwidth + extfixy / 2)
        )
        geometry.rectanglebltr(guardring, generics.other("soiopen"),
            point.create(-_P.soiopenextension - extfixx / 2 - _P.ringwidth, -_P.soiopenextension - extfixy / 2 - _P.ringwidth),
            point.create(_P.soiopenextension + extfixx / 2,  holeheight + _P.soiopenextension + extfixy / 2 + _P.ringwidth)
        )
    end
    if aux.any_of("right", _P.drawsegments) then
        if _P.fit then
            for i = 1, yrep + 2 do
                guardring:merge_into(contactbase:move_to((holewidth + _P.ringwidth) / 2, (i - yrep / 2 - 1.5) * _P.ringwidth))
            end
        else
            geometry.contactbarebltr(guardring, "active",
                point.create(holewidth, 0),
                point.create(holewidth + _P.ringwidth, holeheight)
            )
        end
        for i = 1, topmetal do
            geometry.rectanglebltr(guardring, generics.metal(1),
                point.create(holewidth, -_P.ringwidth),
                point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
            )
        end
        if topmetal ~= 1 then
            geometry.viabltr(guardring, 1, topmetal,
                point.create(holewidth, 0),
                point.create(holewidth + _P.ringwidth,  holeheight)
            )
        end
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(holewidth, -_P.ringwidth),
            point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
        )
        geometry.rectanglebltr(guardring, generics.implant(_P.contype),
            point.create(holewidth - _P.implantextension - extfixx / 2, -_P.implantextension - _P.ringwidth - extfixy / 2),
            point.create(holewidth + _P.implantextension + extfixx / 2 + _P.ringwidth, holeheight + _P.implantextension + _P.ringwidth + extfixy / 2)
        )
        geometry.rectanglebltr(guardring, generics.other("soiopen"),
            point.create(holewidth - _P.soiopenextension - extfixx / 2, -_P.soiopenextension - extfixy / 2 - _P.ringwidth),
            point.create(holewidth + _P.soiopenextension + extfixx / 2 + _P.ringwidth, holeheight + _P.soiopenextension + extfixy / 2 + _P.ringwidth)
        )
    end

    ---- well
    --if _P.fillwell then
    --    if _P.fillwelldrawhole then
    --        geometry.unequal_ring(guardring, generics.other(string.format("%swell", _P.contype)),
    --            holewidth + 2 * _P.ringwidth + 2 * _P.wellextension,
    --            holeheight + 2 * _P.ringwidth + 2 * _P.wellextension,
    --            _P.ringwidth + _P.wellextension + _P.fillwellholeoffsetleft,
    --            _P.ringwidth + _P.wellextension + _P.fillwellholeoffsetright,
    --            _P.ringwidth + _P.wellextension + _P.fillwellholeoffsettop,
    --            _P.ringwidth + _P.wellextension + _P.fillwellholeoffsetbottom
    --        )
    --    else
    --        geometry.rectangle(guardring, generics.other(string.format("%swell", _P.contype)),
    --            holewidth + 2 * _P.ringwidth + 2 * _P.wellextension,
    --            holeheight + 2 * _P.ringwidth + 2 * _P.wellextension
    --        )
    --    end
    --else
    --    geometry.ring(guardring, generics.other(string.format("%swell", _P.contype)),
    --        holewidth + 2 * _P.ringwidth + 2 * _P.wellextension,
    --        holeheight + 2 * _P.ringwidth + 2 * _P.wellextension,
    --        _P.ringwidth + 2 * _P.wellextension
    --    )
    --end
    ---- draw deep n/p-well
    --if _P.drawdeepwell then
    --    geometry.rectangle(guardring, generics.other(string.format("deep%swell", _P.contype)), holewidth + _P.ringwidth - 2 * _P.deepwelloffset, holeheight + _P.ringwidth - 2 * _P.deepwelloffset)
    --end

    guardring:set_alignment_box(
        point.create(-_P.ringwidth, -_P.ringwidth),
        point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth),
        point.create(0, 0),
        point.create(holewidth, holeheight)
    )
end
