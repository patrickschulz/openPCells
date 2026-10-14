function parameters()
    pcell.add_parameters(
        { "channeltype", "nmos", posvals = set("nmos", "pmos") },
        { "flippedwell", false },
        { "oxidetype", 1 },
        { "vthtype", 1 },
        { "gatelength", technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space") },
        { "gtopext", technology.get_dimension("Minimum Gate Extension") },
        { "gbotext", technology.get_dimension("Minimum Gate Extension") },
        { "fingers", 8, posvals = even() },
        { "fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "gatelandingwidth", technology.get_dimension("Minimum M4 Width") },
        { "gatelandingspace", technology.get_dimension("Minimum M4 Space") },
        { "sdwidth", technology.get_dimension("Minimum M2 Width") },
        { "sdstrapwidth", technology.get_dimension("Minimum M3 Width") },
        { "sdstrapspace", technology.get_dimension("Minimum M3 Space") },
        { "gatemetal", 4 },
        { "sourceconnmetal", 2 },
        { "sourcemetal", 3 },
        { "drainconnmetal", 2 },
        { "drainmetal", 3 },
        { "minviayspace", 0 },
        { "guardringwidth", technology.get_dimension("Minimum Active Contact Region Size") },
        { "guardringxspace", technology.get_dimension("Minimum Active Space") },
        { "guardringyspace", technology.get_dimension("Minimum Active Space") },
        { "outerguardring_deepwelloffset", 0 },
        { "drawactivedummies", true },
        { "activedummywidth", technology.get_optional_dimension("Minimum Active Width", 0) },
        { "activedummyspace", technology.get_optional_dimension("Minimum Active Space", 0) },
        { "drawleftstopgate", false },
        { "drawrightstopgate", false },
        { "polylines", {} },
        { "sourcemarker", 1 },
        { "drainmarker", 1 }
    )
end

function layout(mosfet, _P)
    local base = pcell.create_layout("basic/mosfet", "_base", {
        channeltype = _P.channeltype,
        flippedwell = _P.flippedwell,
        drawimplant = false, -- drawn later with the guard rings
        oxidetype = _P.oxidetype,
        vthtype = _P.vthtype,
        vthtypealignwithactive = true,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        gtopext = _P.gtopext,
        gbotext = _P.gbotext,
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
        sourcestartmetal = _P.sourceconnmetal,
        sourceendmetal = _P.sourcemetal,
        connectsourcewidth = _P.sdstrapwidth,
        connectsourcespace = _P.sdstrapspace,
        connectdrain = true,
        drainstartmetal = _P.drainconnmetal,
        drainendmetal = _P.drainmetal,
        connectdrainwidth = _P.sdstrapwidth,
        connectdrainspace = _P.sdstrapspace,
        interweavevias = true,
        minviayspace = _P.minviayspace,
        sourcemarker = _P.sourcemarker,
        drainmarker = _P.drainmarker,
        drawleftstopgate = _P.drawleftstopgate,
        drawrightstopgate = _P.drawrightstopgate,
        leftpolylines = _P.polylines,
        rightpolylines = _P.polylines,
        coveractivedummieswithstopgates = true,
        drawleftactivedummy = _P.drawactivedummies,
        leftactivedummywidth = _P.gatelength + _P.gatespace,
        leftactivedummyspace = _P.gatelength + _P.gatespace,
        drawrightactivedummy = _P.drawactivedummies,
        rightactivedummywidth = _P.gatelength + _P.gatespace,
        rightactivedummyspace = _P.gatelength + _P.gatespace,
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
        point.create(
            base:get_area_anchor("gate1").l - _P.gatelength - _P.gatespace - _P.gatelandingspace - _P.gatelandingwidth,
            base:get_area_anchor("botgatestrap").b
        ),
        point.create(
            base:get_area_anchor("gate1").l - _P.gatelength - _P.gatespace - _P.gatelandingspace,
            base:get_area_anchor("topgatestrap").t
        )
    )
    mosfet:add_area_anchor_bltr("rightgatelanding",
        point.create(
            base:get_area_anchor("gate-1").r + _P.gatelength + _P.gatespace + _P.gatelandingspace,
            base:get_area_anchor("botgatestrap").b
        ),
        point.create(
            base:get_area_anchor("gate-1").r + _P.gatelength + _P.gatespace + _P.gatelandingspace + _P.gatelandingwidth,
            base:get_area_anchor("topgatestrap").t
        )
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
    local guardringbl = point.create(
        math.min(
            mosfet:get_area_anchor("leftgatelanding").l,
            base:get_area_anchor("leftactivedummy").l
        ),
        math.min(
            mosfet:get_area_anchor("leftgatelanding").b,
            base:get_area_anchor("bottomactivedummy").b
        )
    )
    local guardringtr = point.create(
        math.max(
            mosfet:get_area_anchor("rightgatelanding").r,
            base:get_area_anchor("rightactivedummy").r
        ),
        math.max(
            mosfet:get_area_anchor("rightgatelanding").t,
            base:get_area_anchor("topactivedummy").t
        )
    )
    -- guard rings
    layouthelpers.place_guardrings_to_substrate(mosfet,
        guardringbl, guardringtr,
        _P.guardringxspace,
        _P.guardringyspace,
        _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
        "guardring_",
        {
            ringwidth = _P.guardringwidth,
        }
    )
    -- fill implant
    geometry.rectangleareaanchor(mosfet, generics.implant(_P.channeltype == "nmos" and "n" or "p"), "innerguardring_innerimplant")
    -- RF device marker
    geometry.rectangleareaanchor(mosfet, generics.marker("RF"), "innerguardring_outerboundary")
end
