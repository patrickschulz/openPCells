function parameters()
    pcell.add_parameters(
        { "fingers", 2, posvals = even() },
        { "fingerwidth", 0 },
        { "channeltype", "nmos", posvals = set("nmos", "pmos") },
        { "gatelength", 0 },
        { "sourcespace", 0 },
        { "drainspace", 0 },
        { "sourcewidth", 0 },
        { "drainwidth", 0 }
    )
end

function layout(ldmos, _P)
    geometry.rectanglebltr(ldmos, generics.active(),
        point.create(0, 0),
        point.create(
            _P.sourcewidth + _P.sourcespace + _P.gatelength + _P.drainspace + _P.drainwidth,
            _P.fingerwidth
        )
    )
    geometry.rectanglebltr(ldmos, generics.implant(_P.channeltype),
        point.create(0, 0),
        point.create(
            _P.sourcewidth + _P.sourcespace + _P.gatelength + _P.drainspace + _P.drainwidth,
            _P.fingerwidth
        )
    )
    geometry.rectanglebltr(ldmos, generics.gate(),
        point.create(
            _P.sourcewidth + _P.sourcespace,
            0
        ),
        point.create(
            _P.sourcewidth + _P.sourcespace + _P.gatelength,
            _P.fingerwidth
        )
    )
    geometry.contactbltr(ldmos, "active",
        point.create(
            0,
            0
        ),
        point.create(
            _P.sourcewidth,
            _P.fingerwidth
        )
    )
    geometry.contactbltr(ldmos, "active",
        point.create(
            _P.sourcewidth + _P.sourcespace + _P.gatelength + _P.drainspace,
            0
        ),
        point.create(
            _P.sourcewidth + _P.sourcespace + _P.gatelength + _P.drainspace + _P.drainwidth,
            _P.fingerwidth
        )
    )
end
