function parameters()
    pcell.add_parameters(
        { "channeltype", "nmos", posvals = set("nmos", "pmos") },
        { "flippedwell", false },
        { "gatelength", 0 },
        { "gatespace", 0 },
        { "fingers", 2, posvals = even() },
        { "fingerwidth", 0 },
        { "gatestrapwidth", 0 },
        { "gatestrapspace", 0 },
        { "gatelandingwidth", 0 },
        { "gatelandingspace", 0 },
        { "sdwidth", 0 },
        { "sdstrapwidth", 0 },
        { "gatemetal", 5 },
        { "sourcemetal", 3 },
        { "drainmetal", 4 },
        { "guardringwidth", 0 },
        { "guardringxspace", 0 },
        { "guardringyspace", 0 },
        { "outerguardring_deepwelloffset", 0 },
        { "drawactivedummies", true },
        { "activedummywidth", 0 },
        { "activedummyspace", 0 }
    )
end

function layout(mosfet, _P)
    local base = pcell.create_layout("basic/mosfet", "_base", {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        fingers = _P.fingers,
        fingerwidth = _P.fingerwidth,
        sdwidth = _P.sdwidth,
        drawtopgate = true,
        topgatemetal = 1,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        drawbotgate = true,
        botgatemetal = 1,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.gatestrapspace,
        connectsource = true,
        sourcemetal = _P.sourcemetal,
        connectsourcewidth = _P.sdstrapwidth,
        connectdrain = true,
        drainmetal = _P.drainmetal,
        connectdrainwidth = _P.sdstrapwidth,
        drawleftactivedummy = _P.drawactivedummies,
        leftactivedummywidth = _P.activedummywidth,
        leftactivedummyspace = _P.activedummyspace,
        drawrightactivedummy = _P.drawactivedummies,
        rightactivedummywidth = _P.activedummywidth,
        rightactivedummyspace = _P.activedummyspace,
        drawtopactivedummy = _P.drawactivedummies,
        topactivedummywidth = _P.activedummywidth,
        topactivedummyspace = _P.activedummyspace,
        drawbottomactivedummy = _P.drawactivedummies,
        bottomactivedummywidth = _P.activedummywidth,
        bottomactivedummyspace = _P.activedummyspace,
    })
    mosfet:merge_into(base)
    -- inherit source/drain strap anchors
    mosfet:inherit_area_anchor(base, "sourcestrap")
    mosfet:inherit_area_anchor(base, "drainstrap")
    -- left/right gate landings
    mosfet:add_area_anchor_bltr("leftgatelanding",
        base:get_area_anchor("botgatestrap").bl:translate_x(-_P.gatelandingspace - _P.gatelandingwidth),
        base:get_area_anchor("topgatestrap").tl:translate_x(-_P.gatelandingspace)
    )
    mosfet:add_area_anchor_bltr("rightgatelanding",
        base:get_area_anchor("botgatestrap").br:translate_x(_P.gatelandingspace),
        base:get_area_anchor("topgatestrap").tr:translate_x(_P.gatelandingspace + _P.gatelandingwidth)
    )
    geometry.viabltr(mosfet, 1, _P.gatemetal,
        mosfet:get_area_anchor("leftgatelanding").bl,
        mosfet:get_area_anchor("leftgatelanding").tr,
        string.format("left gate landing:\n    x parameters: gatelandingwidth (%d)\n    y parameters: gatestrapwidth (%d)", _P.gatelandingwidth, _P.gatestrapwidth)
    )
    geometry.viabltr(mosfet, 1, _P.gatemetal,
        mosfet:get_area_anchor("rightgatelanding").bl,
        mosfet:get_area_anchor("rightgatelanding").tr,
        string.format("right gate landing:\n    x parameters: gatelandingwidth (%d)\n    y parameters: gatestrapwidth (%d)", _P.gatelandingwidth, _P.gatestrapwidth)
    )
    geometry.rectanglebltr(mosfet, generics.metal(1),
        mosfet:get_area_anchor("leftgatelanding").br,
        mosfet:get_area_anchor("rightgatelanding").bl:translate_y(_P.gatestrapwidth)
    )
    geometry.rectanglebltr(mosfet, generics.metal(1),
        mosfet:get_area_anchor("leftgatelanding").tr:translate_y(-_P.gatestrapwidth),
        mosfet:get_area_anchor("rightgatelanding").tl
    )
    -- inner guard ring
    layouthelpers.place_guardring(mosfet,
        mosfet:get_area_anchor("leftgatelanding").bl,
        mosfet:get_area_anchor("rightgatelanding").tr,
        _P.guardringxspace,
        _P.guardringyspace,
        "innerguardring_",
        {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            ringwidth = _P.guardringwidth,
        }
    )
    -- outer guard ring
    layouthelpers.place_guardring(mosfet,
        mosfet:get_area_anchor("innerguardring_outerboundary").bl,
        mosfet:get_area_anchor("innerguardring_outerboundary").tr,
        _P.guardringxspace,
        _P.guardringyspace,
        "outerguardring_",
        {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "p" or "n") or (_P.channeltype == "nmos" and "n" or "p"),
            ringwidth = _P.guardringwidth,
            fillwell = false,
            drawdeepwell = true,
            deepwelloffset = _P.outerguardring_deepwelloffset,
        }
    )
end
