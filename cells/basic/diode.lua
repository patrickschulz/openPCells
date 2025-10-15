function parameters()
    pcell.add_parameters(
        { "diodetype", "pn", posvals = set("pn", "np") },
        { "width", technology.get_dimension("Minimum Active Contact Region Size") },
        { "height", technology.get_dimension("Minimum Active Contact Region Size") },
        { "implantextension", technology.get_dimension("Minimum Implant Extension") },
        { "wellextension", technology.get_dimension("Minimum Well Extension") },
        { "soiopenextension", 0 }
    )
end

function layout(diode, _P)
    -- active diffusion
    geometry.rectanglebltr(diode, generics.active(),
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    -- contacts
    geometry.contactbarebltr(diode, "active",
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    -- metal 1
    geometry.rectanglebltr(diode, generics.metal(1),
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    -- implant
    geometry.rectanglebltr(diode, generics.implant(string.sub(_P.diodetype, 1)),
        point.create(-_P.implantextension, -_P.implantextension),
        point.create(_P.width + _P.implantextension, _P.height + _P.implantextension)
    )
    -- well
    geometry.rectanglebltr(diode, generics.well(string.sub(_P.diodetype, 2)),
        point.create(-_P.wellextension, -_P.wellextension),
        point.create(_P.width + _P.wellextension, _P.height + _P.wellextension)
    )
    -- soiopen
    geometry.rectanglebltr(diode, generics.feol("soiopen"),
        point.create(-_P.soiopenextension, -_P.soiopenextension),
        point.create(_P.width + _P.soiopenextension, _P.height + _P.soiopenextension)
    )
    -- diodetype (marker)
    --geometry.rectanglebltr(diode, generics.diode(_P.diodetype),
    --    point.create(-_P.extension, -_P.extension),
    --    point.create(_P.width + _P.extension, _P.height + _P.extension)
    --)
end
