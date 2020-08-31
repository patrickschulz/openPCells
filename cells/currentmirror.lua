function parameters()
    pcell.inherit_and_bind_parameter("transistor", "gatelength")
    pcell.add_parameters(
        { "ifingers", 4 },
        { "ofingers", 4 },
        { "gatestrapspace", 0.2 }
    )
end

function layout()
    local currentmirror = object.create()

    local options = pcell.make_options({ 
        fingers = _P.ifingers + _P.ofingers,
        drawtopgate = true, connectsource = true,
        topgatestrwidth = 0.2, topgatestrspace = _P.gatestrapspace,
        sdconnwidth = 0.2,
        gtopext = 0.5, gbotext = 0.5,
    })

    local mosdiode = celllib.create_layout("transistor", options)
    currentmirror:merge_into(mosdiode)

    -- diode connections
    currentmirror:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), 0.2, _P.gatestrapspace),
        _P.ifingers, 1, 1, 0
    ):translate(0, 1))

    return currentmirror
end
