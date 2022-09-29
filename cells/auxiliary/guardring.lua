function parameters()
    pcell.add_parameters(
        { "contype",            "p" },
        { "topmetal",             1 },
        { "holewidth",         5000 },
        { "holeheight",        5000 },
        { "ringwidth",          200 },
        { "drawsegments",      { "left", "right", "top", "bottom" } },
        { "wellextension",       50 },
        { "soiopenextension",    50 },
        { "implantextension",    50 },
        { "fillwell",          true },
        { "drawdeepwell",     false },
        { "deepwelloffset",       0 }
    )
end

function layout(guardring, _P)
    local topmetal = tech.resolve_metal(_P.topmetal)
    if util.any_of("top", _P.drawsegments) then
        geometry.contactbarebltr(guardring, "active", 
            point.create(-_P.holewidth / 2, _P.holeheight / 2),
            point.create( _P.holewidth / 2, _P.holeheight / 2 + _P.ringwidth)
        )
        for i = 1, topmetal do
            geometry.rectanglebltr(guardring, generics.metal(i),
                point.create(-_P.holewidth / 2 - _P.ringwidth, _P.holeheight / 2),
                point.create( _P.holewidth / 2 + _P.ringwidth, _P.holeheight / 2 + _P.ringwidth)
            )
        end
        if topmetal ~= 1 then
            geometry.viabltr(guardring, 1, topmetal,
                point.create(-_P.holewidth / 2, _P.holeheight / 2),
                point.create( _P.holewidth / 2, _P.holeheight / 2 + _P.ringwidth)
            )
        end
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(-_P.holewidth / 2 - _P.ringwidth, _P.holeheight / 2),
            point.create( _P.holewidth / 2 + _P.ringwidth, _P.holeheight / 2 + _P.ringwidth)
        )
        geometry.rectanglebltr(guardring, generics.implant(_P.contype),
            point.create(-_P.holewidth / 2 - _P.ringwidth - _P.implantextension, _P.holeheight / 2 - _P.implantextension),
            point.create( _P.holewidth / 2 + _P.ringwidth + _P.implantextension, _P.holeheight / 2 + _P.ringwidth + _P.implantextension)
        )
        geometry.rectanglebltr(guardring, generics.other("soiopen"),
            point.create(-_P.holewidth / 2 - _P.ringwidth - _P.soiopenextension, _P.holeheight / 2 - _P.soiopenextension),
            point.create( _P.holewidth / 2 + _P.ringwidth + _P.soiopenextension, _P.holeheight / 2 + _P.ringwidth + _P.soiopenextension)
        )
    end
    if util.any_of("bottom", _P.drawsegments) then
        geometry.contactbarebltr(guardring, "active", 
            point.create(-_P.holewidth / 2, -_P.holeheight / 2 - _P.ringwidth),
            point.create( _P.holewidth / 2, -_P.holeheight / 2)
        )
        for i = 1, topmetal do
            geometry.rectanglebltr(guardring, generics.metal(i),
                point.create(-_P.holewidth / 2 - _P.ringwidth, -_P.holeheight / 2 - _P.ringwidth),
                point.create( _P.holewidth / 2 + _P.ringwidth, -_P.holeheight / 2)
            )
        end
        if topmetal ~= 1 then
            geometry.viabltr(guardring, 1, topmetal,
                point.create(-_P.holewidth / 2, -_P.holeheight / 2 - _P.ringwidth),
                point.create( _P.holewidth / 2, -_P.holeheight / 2)
            )
        end
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(-_P.holewidth / 2 - _P.ringwidth, -_P.holeheight / 2 - _P.ringwidth),
            point.create( _P.holewidth / 2 + _P.ringwidth, -_P.holeheight / 2)
        )
        geometry.rectanglebltr(guardring, generics.implant(_P.contype),
            point.create(-_P.holewidth / 2 - _P.ringwidth - _P.implantextension, -_P.holeheight / 2 - _P.implantextension - _P.ringwidth),
            point.create( _P.holewidth / 2 + _P.ringwidth + _P.implantextension, -_P.holeheight / 2 + _P.implantextension)
        )
        geometry.rectanglebltr(guardring, generics.other("soiopen"),
            point.create(-_P.holewidth / 2 - _P.ringwidth - _P.soiopenextension, -_P.holeheight / 2 - _P.ringwidth - _P.soiopenextension),
            point.create( _P.holewidth / 2 + _P.ringwidth + _P.soiopenextension, -_P.holeheight / 2 + _P.soiopenextension)
        )
    end
    if util.any_of("left", _P.drawsegments) then
        geometry.contactbarebltr(guardring, "active", 
            point.create(-_P.holewidth / 2 - _P.ringwidth, -_P.holeheight / 2),
            point.create(-_P.holewidth / 2,  _P.holeheight / 2)
        )
        for i = 1, topmetal do
            geometry.rectanglebltr(guardring, generics.metal(i),
                point.create(-_P.holewidth / 2 - _P.ringwidth, -_P.holeheight / 2 - _P.ringwidth),
                point.create(-_P.holewidth / 2,  _P.holeheight / 2 + _P.ringwidth)
            )
        end
        if topmetal ~= 1 then
            geometry.viabltr(guardring, 1, topmetal,
                point.create(-_P.holewidth / 2 - _P.ringwidth, -_P.holeheight / 2),
                point.create(-_P.holewidth / 2,  _P.holeheight / 2)
            )
        end
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(-_P.holewidth / 2 - _P.ringwidth, -_P.holeheight / 2 - _P.ringwidth),
            point.create(-_P.holewidth / 2,  _P.holeheight / 2 + _P.ringwidth)
        )
        geometry.rectanglebltr(guardring, generics.implant(_P.contype),
            point.create(-_P.holewidth / 2 - _P.implantextension - _P.ringwidth, -_P.holeheight / 2 - _P.implantextension - _P.ringwidth),
            point.create(-_P.holewidth / 2 + _P.implantextension,  _P.holeheight / 2 + _P.implantextension + _P.ringwidth)
        )
        geometry.rectanglebltr(guardring, generics.other("soiopen"),
            point.create(-_P.holewidth / 2 - _P.soiopenextension - _P.ringwidth, -_P.holeheight / 2 - _P.soiopenextension - _P.ringwidth),
            point.create(-_P.holewidth / 2 + _P.soiopenextension,  _P.holeheight / 2 + _P.soiopenextension + _P.ringwidth)
        )
    end
    if util.any_of("right", _P.drawsegments) then
        geometry.contactbarebltr(guardring, "active", 
            point.create( _P.holewidth / 2, -_P.holeheight / 2),
            point.create( _P.holewidth / 2 + _P.ringwidth,  _P.holeheight / 2)
        )
        for i = 1, topmetal do
            geometry.rectanglebltr(guardring, generics.metal(1),
                point.create( _P.holewidth / 2, -_P.holeheight / 2 - _P.ringwidth),
                point.create( _P.holewidth / 2 + _P.ringwidth,  _P.holeheight / 2 + _P.ringwidth)
            )
        end
        if topmetal ~= 1 then
            geometry.viabltr(guardring, 1, topmetal,
                point.create( _P.holewidth / 2, -_P.holeheight / 2),
                point.create( _P.holewidth / 2 + _P.ringwidth,  _P.holeheight / 2)
            )
        end
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create( _P.holewidth / 2, -_P.holeheight / 2 - _P.ringwidth),
            point.create( _P.holewidth / 2 + _P.ringwidth,  _P.holeheight / 2 + _P.ringwidth)
        )
        geometry.rectanglebltr(guardring, generics.implant(_P.contype),
            point.create( _P.holewidth / 2 - _P.implantextension, -_P.holeheight / 2 - _P.implantextension - _P.ringwidth),
            point.create( _P.holewidth / 2 + _P.implantextension + _P.ringwidth,  _P.holeheight / 2 + _P.implantextension + _P.ringwidth)
        )
        geometry.rectanglebltr(guardring, generics.other("soiopen"),
            point.create( _P.holewidth / 2 - _P.soiopenextension, -_P.holeheight / 2 - _P.soiopenextension - _P.ringwidth),
            point.create( _P.holewidth / 2 + _P.soiopenextension + _P.ringwidth,  _P.holeheight / 2 + _P.soiopenextension + _P.ringwidth)
        )
    end

    -- well
    if _P.fillwell then
        geometry.rectangle(guardring, generics.other(string.format("%swell", _P.contype)), _P.holewidth + _P.ringwidth + 2 * _P.wellextension, _P.holeheight + _P.ringwidth + 2 * _P.wellextension)
    else
        geometry.ring(guardring, generics.other(string.format("%swell", _P.contype)), _P.holewidth - 2 * _P.wellextension, _P.holeheight - 2 * _P.wellextension, _P.ringwidth + 2 * _P.wellextension)
    end
    -- draw deep n/p-well
    if _P.drawdeepwell then
        geometry.rectangle(guardring, generics.other(string.format("deep%swell", _P.contype)), _P.holewidth + _P.ringwidth - 2 * _P.deepwelloffset, _P.holeheight + _P.ringwidth - 2 * _P.deepwelloffset)
    end

    -- alignment box
    guardring:set_alignment_box(
        point.create(-(_P.holewidth + _P.ringwidth) / 2, -(_P.holeheight + _P.ringwidth) / 2),
        point.create( (_P.holewidth + _P.ringwidth) / 2,  (_P.holeheight + _P.ringwidth) / 2)
    )
end
