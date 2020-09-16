function parameters()
    pcell.inherit_and_bind_parameter("transistor", "fwidth")
    pcell.inherit_and_bind_parameter("transistor", "gatelength")
    pcell.inherit_and_bind_parameter("transistor", "gatespace")
    pcell.inherit_and_bind_parameter("transistor", "sdwidth")
    pcell.bind_parameter("gatestrapwidth", "transistor", "topgatestrwidth")
    pcell.bind_parameter("gatestrapwidth", "transistor", "botgatestrwidth")
    pcell.bind_parameter("sourcemetal", "transistor", "connsourcemetal")
    pcell.bind_parameter("outmetal", "transistor", "conndrainmetal")
    pcell.add_parameters(
        { "ifingers", 4 },
        { "ofingers", 4 },
        { "gatestrapwidth", 0.2 },
        { "gatestrapspace", 0.2 },
        { "sourcemetal", 2 },
        { "outmetal", 3 }
    )
end

function layout(currentmirror, _P)
    local options = pcell.make_options({ 
        fingers = _P.ifingers + _P.ofingers,
        drawtopgate = true, drawbotgate = true, connectsource = true, connectdrain = true,
        topgatestrspace = _P.gatestrapspace,
        sdconnwidth = 0.2,
        gtopext = 0.5, gbotext = 0.5,
    })

    -- transistor (one for both)
    local mosdiode = celllib.create_layout("transistor", options)
    currentmirror:merge_into(mosdiode)

    -- diode drain connections
    currentmirror:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), _P.sdwidth, _P.gatestrapspace),
        math.floor(0.25 * (_P.ifingers + _P.ofingers)), 1, 4 * (_P.gatelength + _P.gatespace), 0
    ):translate(-_P.gatelength - _P.gatespace, 0.5 * (_P.fwidth + _P.gatestrapspace)))
    
    --[[
    -- mirror drain connections
    currentmirror:merge_into(geometry.multiple(
        geometry.rectangle(generics.via(1, 3), _P.sdwidth, _P.fwidth),
        math.floor(0.25 * (_P.ifingers + _P.ofingers)), 1, 4 * (_P.gatelength + _P.gatespace), 0
    ):translate(_P.gatelength + _P.gatespace, 0))
    currentmirror:merge_into(geometry.rectangle(generics.metal(3), 2, 0.2))
    --]]

    --[[
    -- guard ring (?)
    local w, h = mosdiode:width_height()
    currentmirror:merge_into(celllib.create_layout("guardring", { width = 1.5 * w, height = 1.5 * h }))
    --]]
end
