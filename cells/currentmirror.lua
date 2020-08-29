function parameters()
    --pcell.inherit_transparent_parameters("transistor", "gatelength")
    pcell.inherit_parameters("transistor", "gatelength")
    pcell.add_parameters(
        { "ifingers", 4 },
        { "ofingers", 4 },
        { "gatestrapspace", 0.2 }
    )
end

function layout()
    local P = pcell.get_params()

    local currentmirror = object.create()
    
    pcell.override_defaults("transistor", { "gatelength", P["gatelength"] })

    local options = pcell.make_options({ 
        fingers = P.ifingers + P.ofingers,
        drawtopgate = true, connectsource = true,
        topgatestrwidth = 0.2, topgatestrspace = P.gatestrapspace,
        sdconnwidth = 0.2,
        gtopext = 0.5, gbotext = 0.5,
    })

    local mosdiode = celllib.create_layout("transistor", options)
    currentmirror:merge_into(mosdiode)

    -- diode connections
    currentmirror:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), 0.2, P.gatestrapspace),
        P.ifingers, 1, 1, 0
    ):translate(0, 1))

    return currentmirror
end
