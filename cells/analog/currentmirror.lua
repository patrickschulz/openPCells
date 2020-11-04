function parameters()
    pcell.inherit_and_bind_parameter("basic/transistor", "fwidth")
    pcell.inherit_and_bind_parameter("basic/transistor", "gatelength")
    pcell.inherit_and_bind_parameter("basic/transistor", "gatespace")
    pcell.inherit_and_bind_parameter("basic/transistor", "sdwidth")
    pcell.inherit_and_bind_parameter_as("gatestrapwidth", "basic/transistor", "topgatestrwidth")
    pcell.inherit_and_bind_parameter_as("gatestrapwidth", "basic/transistor", "botgatestrwidth")
    pcell.inherit_and_bind_parameter_as("sourcemetal", "basic/transistor", "connsourcemetal")
    pcell.inherit_and_bind_parameter_as("outmetal", "basic/transistor", "conndrainmetal")
    pcell.add_parameters(
        { "ifingers", 4 },
        { "ofingers", 4 },
        { "gatestrapwidth", 200 },
        { "gatestrapspace", 200 },
        { "sourcemetal", 2 },
        { "outmetal", 3 }
    )
end

function layout(currentmirror, _P)
    --[[
    local options = pcell.make_options({
        fingers = _P.ifingers + _P.ofingers,
        drawtopgate = true, drawbotgate = true, connectsource = true, connectdrain = true,
        topgatestrspace = _P.gatestrapspace,
        sdconnwidth = 200,
        gtopext = 500, gbotext = 500,
    })

    -- transistor (one for both)
    local mosdiode = pcell.create_layout("basic/transistor", options)
    currentmirror:merge_into(mosdiode)

    -- diode drain connections
    currentmirror:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), _P.sdwidth, _P.gatestrapspace),
        math.floor((_P.ifingers + _P.ofingers) / 4), 1, 4 * (_P.gatelength + _P.gatespace), 0
    ):translate(-_P.gatelength - _P.gatespace, (_P.fwidth + _P.gatestrapspace) / 2))

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
