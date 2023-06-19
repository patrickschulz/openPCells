function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                              "nmos", posvals = set("nmos", "pmos") },
        { "oxidetype(Oxide Thickness Type)",                             1, argtype = "integer", posvals = interval(1, inf) },
        { "vthtype(Threshold Voltage Type)",                             1, argtype = "integer", posvals = interval(1, inf) },
        { "gatemarker(Gate Marking Layer Index)",                        1, argtype = "integer", posvals = interval(1, inf) },
        { "mosfetmarker(MOSFET Marking Layer Index)",                    1, argtype = "integer", posvals = interval(1, inf) },
        { "mosfetmarkeralignatsourcedrain(Align MOSFET Marker at Source/Drain)",  false },
        { "flippedwell(Flipped Well)",                                 false },
        { "fingers(Number of Fingers)",                                  1, argtype = "integer", posvals = interval(0, inf) },
        { "fwidth(Finger Width)",                                      technology.get_dimension("Minimum Gate Width"), argtype = "integer" },
        { "gatelength(Gate Length)",                                   technology.get_dimension("Minimum Gate Length"), argtype = "integer" },
        { "gatespace(Gate Spacing)",                                   technology.get_dimension("Minimum Gate XSpace"), argtype = "integer" },
        { "actext(Active Extension)",                                     30 },
        { "sdwidth(Source/Drain Metal Width)",                         technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "gtopext(Gate Top Extension)",                               technology.get_dimension("Minimum Gate Extension") },
        { "gbotext(Gate Bottom Extension)",                            technology.get_dimension("Minimum Gate Extension") },
        { "cliptop(Clip Top Marker Layers)",                           false },
        { "clipbot(Clip Bottom Marker Layers)",                        false },
        { "drawleftstopgate(Draw Left Stop Gate)",                     false },
        { "drawrightstopgate(Draw Right Stop Gate)",                   false },
        { "endleftwithgate(End Left Side With Gate)",                  false, follow = "drawleftstopgate" },
        { "endrightwithgate(End Right Side With Gate)",                false, follow = "drawrightstopgate" },
        { "drawtopgate(Draw Top Gate Contact)",                        false },
        { "drawtopgatestrap(Draw Top Gate Strap)",                     false, follow = "drawtopgate" },
        { "topgatestrwidth(Top Gate Strap Width)",                     technology.get_dimension("Minimum M1 Width"), argtype = "integer", posvals = even() },
        { "topgatestrapextendleft(Top Gate Strap Extend Left)",            0 },
        { "topgatestrapextendright(Top Gate Strap Extend Right)",          0 },
        { "topgatestrspace(Top Gate Strap Space)",                     technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "topgatemetal(Top Gate Strap Metal)",                            1 },
        { "drawtopgatevia(Draw Top Gate Via)",                         false },
        { "topgateviatarget(Metal Target of Top Gate Via)",                2 },
        { "drawbotgate(Draw Bottom Gate Contact)",                     false },
        { "drawbotgatestrap(Draw Bot Gate Strap)",                     false, follow = "drawbotgate" },
        { "botgatestrwidth(Bottom Gate Strap Width)",                  technology.get_dimension("Minimum M1 Width"), argtype = "integer", posvals = even() },
        { "botgatestrspace(Bottom Gate Strap Space)",                  technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "botgatestrapextendleft(Bottom Gate Strap Extend Left)",         0 },
        { "botgatestrapextendright(Bottom Gate Strap Extend Right)",       0 },
        { "botgatemetal(Bottom Gate Strap Metal)",                         1 },
        { "drawbotgatevia(Draw Bot Gate Via)",                         false },
        { "botgateviatarget(Metal Target of Bot Gate Via)",                2 },
        { "drawtopgcut(Draw Top Gate Cut)",                            false },
        { "topgcutwidth(Top Gate Cut Y Width)",                            technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace") },
        { "topgcutspace(Top Gate Cut Y Space)",                            0 },
        { "topgcutleftext(Top Gate Cut Left Extension)",                   0 },
        { "topgcutrightext(Top Gate Cut Right Extension)",                 0 },
        { "drawbotgcut(Draw Bottom Gate Cut)",                            false },
        { "botgcutwidth(Bottom Gate Cut Y Width)",                         technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace") },
        { "botgcutspace(Bottom Gate Cut Y Space)",                         0 },
        { "botgcutleftext(Bottom Gate Cut Left Extension)",                0 },
        { "botgcutrightext(Bottom Gate Cut Right Extension)",              0 },
        { "simulatemissinggatecut",                                       false },
        { "drawsourcedrain(Draw Source/Drain Contacts)",              "both", posvals = set("both", "source", "drain", "none") },
        { "sourcesize(Source Size)",                                  technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fwidth" },
        { "sourceviasize(Source Via Size)",                           technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "sourcesize" },
        { "drainsize(Drain Size)",                                    technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fwidth" },
        { "drainviasize(Drain Via Size)",                             technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "drainsize" },
        { "sourcealign(Source Alignement)",                          "bottom", posvals = set("top", "bottom") },
        { "sourceviaalign(Source Via Alignement)",                   "bottom", posvals = set("top", "bottom"), follow = "sourcealign" },
        { "drainalign(Drain Alignement)",                            "top", posvals = set("top", "bottom") },
        { "drainviaalign(Drain Via Alignement)",                     "top", posvals = set("top", "bottom"), follow = "drainalign" },
        { "drawsourcevia(Draw Source Via)",                            true },
        { "connectsource(Connect Source)",                             false },
        { "connectsourceboth(Connect Source on Both Sides)",           false },
        { "connectsourcewidth(Source Rails Metal Width)",               technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth" },
        { "connectsourcespace(Source Rails Metal Space)",               technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connectsourceleftext(Source Rails Metal Left Extension)",    0 },
        { "connectsourcerightext(Source Rails Metal Right Extension)",  0 },
        { "connectsourcemetal(Source Connection Metal)",                      1 },
        { "sourceviametal(Source Via Metal)",                              1, follow = "connectsourcemetal" },
        { "connectsourceinline(Connect Source Inline of Transistor)",     false },
        { "connectsourceinlineoffset(Offset for Inline Source Connection)",   0 },
        { "connectsourceinverse(Invert Source Strap Locations)",       false },
        { "connectdrain(Connect Drain)",                               false },
        { "connectdrainboth(Connect Drain on Both Sides)",             false },
        { "connectdrainwidth(Drain Rails Metal Width)",               technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth" },
        { "connectdrainspace(Drain Rails Metal Space)",               technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connectdrainleftext(Drain Rails Metal Left Extension)",      0 },
        { "connectdrainrightext(Drain Rails Metal Right Extension)",    0 },
        { "connectdraininverse(Invert Drain Strap Locations)",         false },
        { "drawdrainvia(Draw Drain Via)",                              true },
        { "connectdrainmetal(Drain Connection Metal)",                        1 },
        { "drainviametal(Drain Via Metal)",                                1, follow = "connectdrainmetal" },
        { "connectdraininline(Connect Drain Inline of Transistor)",       false },
        { "connectdraininlineoffset(Offset for Inline Drain Connection)",     0 },
        { "diodeconnected(Diode Connected Transistor)",                false },
        { "drawextrabotstrap(Draw Extra Bottom Strap)",             false },
        { "extrabotstrapwidth(Width of Extra Bottom Strap)",        technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "extrabotstrapspace(Space of Extra Bottom Strap)",        technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "extrabotstrapmetal(Metal Layer for Extra Bottom Strap)",     1 },
        { "extrabotstrapleftalign(Left Alignment for Extra Bottom Strap)", 1 },
        { "extrabotstraprightalign(Right Alignment for Extra Bottom Strap)", 1, follow = "fingers" },
        { "drawextratopstrap(Draw Extra Top Strap)",               false },
        { "extratopstrapwidth(Width of Extra Top Strap)",          technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "extratopstrapspace(Space of Extra Top Strap)",          technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "extratopstrapmetal(Metal Layer for Extra Top Strap)",       1 },
        { "extratopstrapalign(Alignment for Extra Top Strap)",         "source", posvals = set("source", "drain") },
        { "shortdevice(Short Transistor)",                             false },
        { "drawtopactivedummy",                                        false },
        { "topactivedummywidth",                                          80 },
        { "topactivedummysep",                                            80 },
        { "drawbotactivedummy",                                        false },
        { "botactivedummywidth",                                          80 },
        { "botactivedummysep",                                            80 },
        { "leftfloatingdummies",                                           0 },
        { "rightfloatingdummies",                                          0 },
        { "drawactive",                                                 true },
        { "lvsmarker",                                                     1 },
        { "extendoxidetop",                                                0 },
        { "extendoxidebot",                                                0 },
        { "extendoxideleft",                                               0 },
        { "extendoxideright",                                              0 },
        { "extendvthtop",                                                  0 },
        { "extendvthbot",                                                  0 },
        { "extendvthleft",                                                 0 },
        { "extendvthright",                                                0 },
        { "extendimplanttop",                                              0 },
        { "extendimplantbot",                                              0 },
        { "extendimplantleft",                                             0 },
        { "extendimplantright",                                            0 },
        { "extendwelltop",                                                 0 },
        { "extendwellbot",                                                 0 },
        { "extendwellleft",                                                0 },
        { "extendwellright",                                               0 },
        { "extendwelltop",                                                 0 },
        { "extendwellbot",                                                 0 },
        { "extendwellleft",                                                0 },
        { "extendwellright",                                               0 },
        { "extendlvsmarkertop",                                            0 },
        { "extendlvsmarkerbot",                                            0 },
        { "extendlvsmarkerleft",                                           0 },
        { "extendlvsmarkerright",                                          0 },
        { "extendrotationmarkertop",                                       0 },
        { "extendrotationmarkerbot",                                       0 },
        { "extendrotationmarkerleft",                                      0 },
        { "extendrotationmarkerright",                                     0 },
        { "drawtopwelltap",                                            false },
        { "topwelltapwidth",                                           technology.get_dimension("Minimum M1 Width") },
        { "topwelltapspace",                                           technology.get_dimension("Minimum M1 Space") },
        { "topwelltapextendleft",                                          0 },
        { "topwelltapextendright",                                         0 },
        { "drawbotwelltap",                                            false },
        { "drawguardring",                                             false },
        { "guardringwidth",                                            technology.get_dimension("Minimum M1 Width") },
        { "guardringxsep",                                             0 },
        { "guardringysep",                                             0 },
        { "guardringsegments",                                         { "left", "right", "top", "bottom" } },
        { "botwelltapwidth",                                           technology.get_dimension("Minimum M1 Width") },
        { "botwelltapspace",                                           technology.get_dimension("Minimum M1 Space") },
        { "botwelltapextendleft",                                          0 },
        { "botwelltapextendright",                                         0 },
        { "drawstopgatetopgcut",                                           false },
        { "drawstopgatebotgcut",                                           false },
        { "leftpolylines",                                                 {} },
        { "rightpolylines",                                                {} },
        { "drawrotationmarker",                                            false }
    )
end

function check(_P)
    if (_P.gatespace % 2) ~= (_P.sdwidth % 2) then
        return nil, "gatespace and sdwidth must both be even or odd"
    end
    if not (not _P.endleftwithgate or (_P.gatelength % 2 == 0)) then
        return nil, "gatelength must be even when endleftwithgate is true"
    end
    if not (not _P.endrightwithgate or (_P.gatelength % 2 == 0)) then
        return nil, "gatelength must be even when endrightwithgate is true"
    end
    return true
end

function layout(transistor, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    local leftactext = (_P.gatespace + _P.sdwidth) / 2
    if not _P.endleftwithgate then
        leftactext = leftactext + _P.actext
    end
    local rightactext = (_P.gatespace + _P.sdwidth) / 2
    if not _P.endrightwithgate then
        rightactext = rightactext + _P.actext
    end
    local activewidth = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + _P.leftfloatingdummies * gatepitch + _P.rightfloatingdummies * gatepitch

    local topgateshift = enable(_P.drawtopgate, _P.topgatestrspace + _P.topgatestrwidth)
    local botgateshift = enable(_P.drawbotgate, _P.botgatestrspace + _P.botgatestrwidth)
    local gateaddtop = math.max(_P.gtopext, topgateshift)
    local gateaddbot = math.max(_P.gbotext, botgateshift)

    local drainshift = enable(_P.connectdrain, _P.connectdrainwidth + _P.connectdrainspace)
    local sourceshift = enable(_P.connectsource, _P.connectsourcewidth + _P.connectsourcespace)
    if _P.channeltype == "pmos" then
        drainshift, sourceshift = sourceshift, drainshift
    end

    local hasgatecut = not _P.simulatemissinggatecut and technology.has_layer(generics.other("gatecut"))

    -- active
    if _P.drawactive then
        geometry.rectanglebltr(transistor, generics.other("active"),
            point.create(0, 0),
            point.create(activewidth + leftactext + rightactext, _P.fwidth)
        )
        transistor:add_area_anchor_bltr("active",
            point.create(0, 0),
            point.create(activewidth + leftactext + rightactext, _P.fwidth)
        )
        if _P.drawtopactivedummy then
            geometry.rectanglebltr(transistor, generics.other("active"),
                point.create(0, _P.fwidth + _P.topactivedummysep),
                point.create(activewidth + leftactext + rightactext, _P.fwidth + _P.topactivedummysep + _P.topactivedummywidth)
            )
        end
        if _P.drawbotactivedummy then
            geometry.rectanglebltr(transistor, generics.other("active"),
                point.create(0, -_P.botactivedummysep - _P.botactivedummywidth),
                point.create(activewidth + leftactext + rightactext, -_P.botactivedummysep)
            )
        end
    end

    -- gates
    -- base coordinates of a gate
    -- needed throughout the cell by various drawings
    local gateblx = leftactext + _P.leftfloatingdummies * gatepitch
    local gatebly = -gateaddbot
    local gatetrx = gateblx + _P.gatelength
    local gatetry = _P.fwidth + gateaddtop

    if hasgatecut then
        -- gate cut
        if _P.drawtopgcut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx - _P.topgcutleftext,
                    _P.fwidth + _P.topgcutspace
                ),
                point.create(
                    gatetrx + (_P.fingers - 1) * gatepitch + _P.topgcutrightext,
                    _P.fwidth + _P.topgcutspace + _P.topgcutwidth
                )
            )
        end
        if _P.drawbotgcut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx - _P.botgcutleftext,
                    -_P.botgcutspace - _P.botgcutwidth
                ),
                point.create(
                    gatetrx + (_P.fingers - 1) * gatepitch + _P.botgcutrightext,
                    -_P.botgcutspace
                )
            )
        end
    else -- not hasgatecut
        if _P.drawtopgcut then
            gatetry = _P.fwidth + _P.topgcutspace
        end
        if _P.drawbotgcut then
            gatebly = -_P.botgcutspace
        end
    end

    -- main gates
    for i = 1, _P.fingers do
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(gateblx + (i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (i - 1) * gatepitch, gatetry)
        )
        -- generic always-available gate anchors
        transistor:add_area_anchor_bltr(
            string.format("gate%d", i),
            point.create(gateblx + (i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (i - 1) * gatepitch, gatetry)
        )
        transistor:add_area_anchor_bltr(
            string.format("gate-%d", i),
            point.create(gateblx + (_P.fingers - i) * gatepitch, gatebly),
            point.create(gatetrx + (_P.fingers - i) * gatepitch, gatetry)
        )
    end
    transistor:add_area_anchor_bltr(
        "leftgate",
        point.create(gateblx + (1 - 1) * gatepitch, gatebly),
        point.create(gatetrx + (1 - 1) * gatepitch, gatetry)
    )
    transistor:add_area_anchor_bltr(
        "rightgate",
        point.create(gateblx + (_P.fingers - 1) * gatepitch, gatebly),
        point.create(gatetrx + (_P.fingers - 1) * gatepitch, gatetry)
    )

    -- gate marker
    for i = 1, _P.fingers do
        geometry.rectanglebltr(transistor,
            generics.other(string.format("gatemarker%d", _P.gatemarker)),
            point.create(gateblx + (i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (i - 1) * gatepitch, gatetry)
        )
    end

    -- left/right gates
    if _P.endleftwithgate then
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(gateblx - gatepitch, gatebly),
            point.create(gatetrx - gatepitch, gatetry)
        )
        transistor:add_area_anchor_bltr(
            "endleftgate",
            point.create(gateblx - gatepitch, gatebly),
            point.create(gatetrx - gatepitch, gatetry)
        )
    end
    if _P.endrightwithgate then
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(gateblx + _P.fingers * gatepitch, gatebly),
            point.create(gatetrx + _P.fingers * gatepitch, gatetry)
        )
        transistor:add_area_anchor_bltr(
            "endrightgate",
            point.create(gateblx + _P.fingers * gatepitch, gatebly),
            point.create(gatetrx + _P.fingers * gatepitch, gatetry)
        )
    end

    -- mosfet marker
    -- FIXME: check proper alignment after source/drain contacts are placed
    if _P.fingers > 0 then
        if _P.mosfetmarkeralignatsourcedrain then
            geometry.rectanglebltr(transistor,
                generics.other(string.format("mosfetmarker%d", _P.mosfetmarker)),
                point.create(0, 0),
                point.create(_P.fingers * gatepitch, _P.fwidth)
            )
        else
            geometry.rectanglebltr(transistor,
                generics.other(string.format("mosfetmarker%d", _P.mosfetmarker)),
                point.create(leftactext, 0),
                point.create(leftactext + _P.fingers * gatepitch - _P.gatespace,  _P.fwidth)
            )
        end
    end

    -- left and right polylines
    -- FIXME: probably wrong without endleftwithgate == true and endrightwithgate == true
    local leftpolyoffset = gateblx - gatepitch
    for _, polyline in ipairs(_P.leftpolylines) do
        if not polyline.length then
            cellerror("basic/mosfet: leftpolyline entry does not have a 'length' field")
        end
        if not polyline.space then
            cellerror("basic/mosfet: leftpolyline entry does not have a 'space' field")
        end
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(leftpolyoffset - polyline.space - polyline.length, gatebly),
            point.create(leftpolyoffset - polyline.space, gatetry)
        )
        leftpolyoffset = leftpolyoffset - polyline.length - polyline.space
    end
    local rightpolyoffset = gatetrx + _P.fingers * gatepitch
    for _, polyline in ipairs(_P.rightpolylines) do
        if not polyline.length then
            cellerror("basic/mosfet: rightpolyline entry does not have a 'length' field")
        end
        if not polyline.space then
            cellerror("basic/mosfet: rightpolyline entry does not have a 'space' field")
        end
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(rightpolyoffset + polyline.space, gatebly),
            point.create(rightpolyoffset + polyline.space + polyline.length, gatetry)
        )
        rightpolyoffset = rightpolyoffset + polyline.length + polyline.space
    end

    -- stop gates
    if _P.drawleftstopgate then
        local bly = gatebly
        local try = gatetry
        if _P.drawstopgatetopgcut then
            try = _P.fwidth + _P.topgcutspace
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx - (_P.leftfloatingdummies + 1) * gatepitch - _P.topgcutleftext,
                    _P.fwidth + _P.topgcutspace
                ),
                point.create(
                    gatetrx - (_P.leftfloatingdummies + 1) * gatepitch + _P.topgcutrightext,
                    _P.fwidth + _P.topgcutspace + _P.topgcutwidth
                )
            )
        end
        if _P.drawstopgatebotgcut then
            bly = -_P.botgcutspace
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx - (_P.leftfloatingdummies + 1) * gatepitch - _P.botgcutleftext,
                    -_P.botgcutspace - _P.botgcutwidth
                ),
                point.create(
                    gatetrx - (_P.leftfloatingdummies + 1) * gatepitch + _P.botgcutrightext,
                    -_P.botgcutspace
                )
            )
        end
        geometry.rectanglebltr(transistor,
            generics.other("diffusionbreakgate"),
            point.create(gateblx - (_P.leftfloatingdummies + 1) * gatepitch, bly),
            point.create(gatetrx - (_P.leftfloatingdummies + 1) * gatepitch, try)
        )
        transistor:add_area_anchor_bltr("leftstopgate",
            point.create(gateblx - (_P.leftfloatingdummies + 1) * gatepitch, bly),
            point.create(gatetrx - (_P.leftfloatingdummies + 1) * gatepitch, try)
        )
    end

    if _P.drawrightstopgate then
        local bly = gatebly
        local try = gatetry
        if _P.drawstopgatetopgcut then
            try = _P.fwidth + _P.topgcutspace
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx + (_P.fingers + _P.rightfloatingdummies) * gatepitch - _P.topgcutleftext,
                    _P.fwidth + _P.topgcutspace
                ),
                point.create(
                    gatetrx + (_P.fingers + _P.rightfloatingdummies) * gatepitch + _P.topgcutrightext,
                    _P.fwidth + _P.topgcutspace + _P.topgcutwidth
                )
            )
        end
        if _P.drawstopgatebotgcut then
            bly = -_P.botgcutspace
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx + (_P.fingers + _P.rightfloatingdummies) * gatepitch - _P.botgcutleftext,
                    -_P.botgcutspace - _P.botgcutwidth
                ),
                point.create(
                    gatetrx + (_P.fingers + _P.rightfloatingdummies) * gatepitch + _P.botgcutrightext,
                    -_P.botgcutspace
                )
            )
        end
        geometry.rectanglebltr(transistor,
            generics.other("diffusionbreakgate"),
            point.create(gateblx + (_P.fingers + _P.rightfloatingdummies) * gatepitch, bly),
            point.create(gatetrx + (_P.fingers + _P.rightfloatingdummies) * gatepitch, try)
        )
        transistor:add_area_anchor_bltr("rightstopgate",
            point.create(gateblx + (_P.fingers + _P.rightfloatingdummies) * gatepitch, bly),
            point.create(gatetrx + (_P.fingers + _P.rightfloatingdummies) * gatepitch, try)
        )
    end

    -- floating dummy gates
    for i = 1, _P.leftfloatingdummies do
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(gateblx - i * gatepitch, gatebly),
            point.create(gatetrx - i * gatepitch, gatetry)
        )
        geometry.rectanglebltr(transistor,
            generics.other("floatinggatemarker"),
            point.create(gateblx - i * gatepitch, gatebly),
            point.create(gatetrx - i * gatepitch, gatetry)
        )
    end
    for i = 1, _P.rightfloatingdummies do
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(gateblx + (_P.fingers + i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (_P.fingers + i - 1) * gatepitch, gatetry)
        )
        geometry.rectanglebltr(transistor,
            generics.other("floatinggatemarker"),
            point.create(gateblx + (_P.fingers + i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (_P.fingers + i - 1) * gatepitch, gatetry)
        )
    end

    -- threshold voltage
    geometry.rectanglebltr(transistor,
        generics.vthtype(_P.channeltype, _P.vthtype),
        point.create(
            -_P.extendvthleft,
            gatebly - _P.extendvthbot
        ),
        point.create(
            activewidth + leftactext + rightactext + _P.extendvthright,
            gatetry + _P.extendvthtop
        )
    )

    -- implant
    geometry.rectanglebltr(transistor,
        generics.implant(_P.channeltype),
        point.create(
            -_P.extendimplantleft,
            gatebly - _P.extendimplantbot
        ),
        point.create(
            activewidth + leftactext + rightactext + _P.extendimplantright,
            gatetry + _P.extendimplanttop
        )
    )

    -- oxide thickness
    geometry.rectanglebltr(transistor,
        generics.oxide(_P.oxidetype),
        point.create(
            -_P.extendoxideleft,
            gatebly - _P.extendoxidebot
        ),
        point.create(
            activewidth + leftactext + rightactext + _P.extendoxideright,
            gatetry + _P.extendoxidetop
        )
    )

    -- rotation marker
    if _P.drawrotationmarker then
        geometry.rectanglebltr(transistor,
            generics.other("rotationmarker"),
            point.create(-_P.extendrotationmarkerleft, -_P.extendrotationmarkerbot),
            point.create(activewidth + leftactext + rightactext + _P.extendrotationmarkerright, _P.fwidth + _P.extendrotationmarkertop)
        )

    end

    -- lvs marker
    geometry.rectanglebltr(transistor,
        generics.other(string.format("lvsmarker%d", _P.lvsmarker)),
        point.create(
            -_P.extendlvsmarkerleft,
            gatebly - _P.extendlvsmarkerbot
        ),
        point.create(
            activewidth + leftactext + rightactext + _P.extendlvsmarkerright,
            gatetry + _P.extendlvsmarkertop
        )
    )

    -- well
    geometry.rectanglebltr(transistor,
        generics.other(_P.flippedwell and
            (_P.channeltype == "nmos" and "nwell" or "pwell") or
            (_P.channeltype == "nmos" and "pwell" or "nwell")
        ),
        point.create(
            -_P.extendwellleft,
            -math.max(_P.extendwellbot, enable(_P.drawbotwelltap, _P.botwelltapspace + _P.botwelltapwidth))
        ),
        point.create(
            activewidth + leftactext + rightactext + _P.extendwellright,
            _P.fwidth + math.max(_P.extendwelltop, enable(_P.drawtopwelltap, _P.topwelltapspace + _P.topwelltapwidth))
        )
    )
    -- well taps
    if _P.drawtopwelltap then
        transistor:merge_into(pcell.create_layout("auxiliary/welltap", "topwelltap", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            width = activewidth + _P.topwelltapextendleft + _P.topwelltapextendright,
            height = _P.topwelltapwidth,
        }):translate(
            (_P.topwelltapextendright - _P.topwelltapextendleft) / 2,
            _P.fwidth + _P.topwelltapspace
        ))
    end
    if _P.drawbotwelltap then
        transistor:merge_into(pcell.create_layout("auxiliary/welltap", "botwelltap", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            width = activewidth + _P.botwelltapextendleft + _P.botwelltapextendright,
            height = _P.botwelltapwidth,
        }):translate(
            (_P.topwelltapextendright - _P.topwelltapextendleft) / 2,
            _P.fwidth + _P.topwelltapspace
        ))
    end

    local guardring -- variable needs to be visible for alignment box setting
    if _P.drawguardring then
        guardring = pcell.create_layout("auxiliary/guardring", "guardring", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            ringwidth = _P.guardringwidth,
            holewidth = activewidth + leftactext + rightactext + 2 * _P.guardringxsep,
            holeheight = _P.fwidth + 2 * _P.guardringysep,
            fillwell = true,
            drawsegments = _P.guardringsegments
        })
        guardring:move_point(guardring:get_anchor("innerbottomleft"), point.create(0, 0))
        guardring:translate(-_P.guardringxsep, -_P.guardringysep)
        transistor:merge_into(guardring)
        transistor:add_area_anchor_bltr("guardring",
            guardring:get_anchor("outerbottomleft"),
            guardring:get_anchor("outertopright"),
            guardring:get_anchor("innerbottomleft"),
            guardring:get_anchor("innertopright")
        )
    end

    -- gate contacts
    if _P.drawtopgate then
        for i = 1, _P.fingers do
            geometry.contactbltr(transistor,
                "gate",
                point.create(gateblx + (i - 1) * gatepitch, _P.fwidth + _P.topgatestrspace),
                point.create(gatetrx + (i - 1) * gatepitch, _P.fwidth + _P.topgatestrspace + _P.topgatestrwidth)
            )
            transistor:add_area_anchor_bltr(string.format("topgate%d", i),
                point.create(gateblx + (i - 1) * gatepitch, _P.fwidth + _P.topgatestrspace),
                point.create(gatetrx + (i - 1) * gatepitch, _P.fwidth + _P.topgatestrspace + _P.topgatestrwidth)
            )
        end
        if _P.drawtopgatevia then
            geometry.viabltr(transistor, 1, _P.topgateviatarget,
                point.create(gateblx + (i - 1) * gatepitch, _P.fwidth + _P.topgatestrspace),
                point.create(gatetrx + (i - 1) * gatepitch, _P.fwidth + _P.topgatestrspace + _P.topgatestrwidth)
            )
        end
    end
    if _P.fingers > 0 and _P.drawtopgatestrap then
        local bl = point.create(gateblx + (1 - 1) * gatepitch - _P.topgatestrapextendleft, _P.fwidth + _P.topgatestrspace)
        local tr = point.create(gatetrx + (_P.fingers - 1) * gatepitch + _P.topgatestrapextendright, _P.fwidth + _P.topgatestrspace + _P.topgatestrwidth)
        geometry.rectanglebltr(transistor, generics.metal(1), bl, tr)
        transistor:add_area_anchor_bltr("topgatestrap", bl, tr)
        if _P.topgatemetal > 1 then
            geometry.viabltr(transistor, 1, _P.topgatemetal, bl, tr)
        end
    end
    if _P.drawbotgate then
        for i = 1, _P.fingers do
            geometry.contactbltr(transistor,
                "gate",
                point.create(gateblx + (i - 1) * gatepitch, -_P.botgatestrspace - _P.botgatestrwidth),
                point.create(gatetrx + (i - 1) * gatepitch, -_P.botgatestrspace)
            )
            transistor:add_area_anchor_bltr(string.format("botgate%d", i),
                point.create(gateblx + (i - 1) * gatepitch, -_P.botgatestrspace - _P.botgatestrwidth),
                point.create(gatetrx + (i - 1) * gatepitch, -_P.botgatestrspace)
            )
        end
        if _P.drawbotgatevia then
            geometry.viabltr(transistor, 1, _P.botgateviatarget,
                point.create(gateblx + (i - 1) * gatepitch, -_P.botgatestrspace - _P.botgatestrwidth),
                point.create(gatetrx + (i - 1) * gatepitch, -_P.botgatestrspace)
            )
        end
    end
    if _P.fingers > 0 and _P.drawbotgatestrap then
        local bl = point.create(gateblx + (1 - 1) * gatepitch - _P.botgatestrapextendleft, -_P.botgatestrspace - _P.botgatestrwidth)
        local tr = point.create(gatetrx + (_P.fingers - 1) * gatepitch + _P.botgatestrapextendright, -_P.botgatestrspace)
        geometry.rectanglebltr(transistor, generics.metal(1), bl, tr)
        transistor:add_area_anchor_bltr("botgatestrap", bl, tr)
        if _P.botgatemetal > 1 then
            geometry.viabltr(transistor, 1, _P.botgatemetal, bl, tr)
        end
    end

    -- source/drain contacts and vias
    local sourceoffset = _P.sourcealign == "top" and _P.fwidth - _P.sourcesize or 0
    local sourceviaoffset = _P.sourceviaalign == "top" and _P.sourcesize - _P.sourceviasize or 0
    local drainoffset = _P.drainalign == "top" and _P.fwidth - _P.drainsize or 0
    local drainviaoffset = _P.drainviaalign == "top" and _P.drainsize - _P.drainviasize or 0
    if _P.drawsourcedrain ~= "none" then
        -- source
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "source" then
            for i = 1, _P.fingers + 1, 2 do
                local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                local bl = point.create(shift, sourceoffset)
                local tr = point.create(shift + _P.sdwidth, sourceoffset + _P.sourcesize)
                geometry.contactbltr(transistor, "sourcedrain", bl, tr)
                if _P.drawsourcevia and _P.sourceviametal > 1 then
                    geometry.viabltr(transistor, 1, _P.sourceviametal,
                        point.create(shift, sourceviaoffset),
                        point.create(shift + _P.sdwidth, sourceviaoffset + _P.sourceviasize)
                    )
                end
                -- anchors
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i), bl, tr)
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i - _P.fingers - 2), bl, tr)
            end
        end
        -- drain
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "drain" then
            for i = 2, _P.fingers + 1, 2 do
                local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                local bl = point.create(shift, drainoffset)
                local tr = point.create(shift + _P.sdwidth, drainoffset + _P.drainsize)
                geometry.contactbltr(transistor, "sourcedrain", bl, tr)
                if _P.drawdrainvia and _P.drainviametal > 1 then
                    geometry.viabltr(transistor, 1, _P.drainviametal,
                        point.create(shift, drainviaoffset),
                        point.create(shift + _P.sdwidth, drainviaoffset + _P.drainviasize)
                    )
                end
                -- anchors
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i), bl, tr)
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i - _P.fingers - 2), bl, tr)
            end
        end
    end

    -- diode connected
    if _P.diodeconnected then
        for i = 2, _P.fingers + 1, 2 do
            if _P.drawtopgatestrap then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tl,
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tr ..
                    transistor:get_area_anchor(string.format("topgatestrap", i)).br
                )
            end
            if _P.drawbotgatestrap then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).bl ..
                    transistor:get_area_anchor(string.format("botgatestrap", i)).tl,
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).br
                )
            end
        end
    end

    -- source connections
    if _P.connectsource then
        local blx = leftactext - (_P.gatespace + _P.sdwidth) / 2
        local trx = blx + 2 * (_P.fingers // 2) * gatepitch + _P.sdwidth
        if _P.connectsourceinline then
            local bly
            if _P.channeltype == "nmos" then
                if _P.connectsourceinverse then
                    bly = _P.fwidth - _P.connectsourcewidth - _P.connectsourceinlineoffset
                else
                    bly = _P.connectsourceinlineoffset
                end
            else
                if _P.connectsourceinverse then
                    bly = _P.connectsourceinlineoffset
                else
                    bly = _P.fwidth - _P.connectsourcewidth - _P.connectsourceinlineoffset
                end
            end
            geometry.rectanglebltr(transistor, generics.metal(_P.connectsourcemetal),
                point.create(blx - _P.connectsourceleftext, bly),
                point.create(trx + _P.connectsourcerightext, bly + _P.connectsourcewidth)
            )
            transistor:add_area_anchor_bltr("sourcestrap",
                point.create(blx - _P.connectsourceleftext, bly),
                point.create(trx + _P.connectsourcerightext, bly + _P.connectsourcewidth)
            )
        else
            local bly1, bly2
            if _P.channeltype == "nmos" then
                if _P.connectsourceinverse then
                    bly1 = _P.fwidth + _P.connectsourcespace
                    bly2 = -_P.connectsourcespace - _P.connectsourcewidth
                else
                    bly1 = -_P.connectsourcespace - _P.connectsourcewidth
                    bly2 = _P.fwidth + _P.connectsourcespace
                end
            else
                if _P.connectsourceinverse then
                    bly1 = -_P.connectsourcespace - _P.connectsourcewidth
                    bly2 = _P.fwidth + _P.connectsourcespace
                else
                    bly1 = _P.fwidth + _P.connectsourcespace
                    bly2 = -_P.connectsourcespace - _P.connectsourcewidth
                end
            end
            -- main strap
            geometry.rectanglebltr(transistor, generics.metal(_P.connectsourcemetal),
                point.create(blx - _P.connectsourceleftext, bly1),
                point.create(trx + _P.connectsourcerightext, bly1 + _P.connectsourcewidth)
            )
            -- main anchor
            transistor:add_area_anchor_bltr("sourcestrap",
                point.create(blx - _P.connectsourceleftext, bly1),
                point.create(trx + _P.connectsourcerightext, bly1 + _P.connectsourcewidth)
            )
            if _P.connectsourceboth then
                -- other strap
                geometry.rectanglebltr(transistor, generics.metal(_P.connectsourcemetal),
                    point.create(blx - _P.connectsourceleftext, bly2),
                    point.create(trx + _P.connectsourcerightext, bly2 + _P.connectsourcewidth)
                )
                -- other anchor
                transistor:add_area_anchor_bltr("othersourcestrap",
                    point.create(blx - _P.connectsourceleftext, bly2),
                    point.create(trx + _P.connectsourcerightext, bly2 + _P.connectsourcewidth)
                )
            end
            -- connections to strap
            local sourceinvert = (_P.channeltype == "pmos")
            if _P.connectsourceinverse then
                sourceinvert = not sourceinvert
            end
            for i = 1, _P.fingers + 1, 2 do
                local shift = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                if not sourceinvert or _P.connectsourceboth then
                    geometry.rectanglebltr(transistor, generics.metal(_P.connectsourcemetal),
                        point.create(shift, -_P.connectsourcespace),
                        point.create(shift + _P.sdwidth, sourceoffset)
                    )
                end
                if sourceinvert or _P.connectsourceboth then
                    geometry.rectanglebltr(transistor, generics.metal(_P.connectsourcemetal),
                        point.create(shift, sourceoffset + _P.sourcesize),
                        point.create(shift + _P.sdwidth, _P.fwidth + _P.connectsourcespace)
                    )
                end
            end
        end
    end

    -- drain connections
    local draininvert = (channeltype == "pmos")
    if _P.connectdraininverse then
        draininvert = not draininvert
    end
    if _P.connectdrain then
        local blx = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (2 - 1) * gatepitch
        local trx = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (2 * ((_P.fingers + 1) // 2) - 1) * gatepitch + _P.sdwidth
        if _P.connectdraininline then
            local bly
            if _P.channeltype == "nmos" then
                if _P.connectdraininverse then
                    bly = _P.connectdraininlineoffset
                else
                    bly = _P.fwidth - _P.connectdrainwidth - _P.connectdraininlineoffset
                end
            else
                if _P.connectdraininverse then
                    bly = _P.fwidth - _P.connectdrainwidth - _P.connectdraininlineoffset
                else
                    bly = _P.connectdraininlineoffset
                end
            end
            geometry.rectanglebltr(transistor, generics.metal(_P.connectdrainmetal),
                point.create(blx - _P.connectdrainleftext, bly),
                point.create(trx + _P.connectdrainrightext, bly + _P.connectdrainwidth)
            )
            transistor:add_area_anchor_bltr("drainstrap",
                point.create(blx - _P.connectdrainleftext, bly),
                point.create(trx + _P.connectdrainrightext, bly + _P.connectdrainwidth)
            )
        else
            local bly1, bly2
            if _P.channeltype == "nmos" then
                if _P.connectdraininverse then
                    bly1 = -_P.connectdrainspace - _P.connectdrainwidth
                    bly2 = _P.fwidth + _P.connectdrainspace
                else
                    bly1 = _P.fwidth + _P.connectdrainspace
                    bly2 = -_P.connectdrainspace - _P.connectdrainwidth
                end
            else
                if _P.connectdraininverse then
                    bly1 = _P.fwidth + _P.connectdrainspace
                    bly2 = -_P.connectdrainspace - _P.connectdrainwidth
                else
                    bly1 = -_P.connectdrainspace - _P.connectdrainwidth
                    bly2 = _P.fwidth + _P.connectdrainspace
                end
            end
            -- main strap
            geometry.rectanglebltr(transistor, generics.metal(_P.connectdrainmetal),
                point.create(blx - _P.connectdrainleftext, bly1),
                point.create(trx + _P.connectdrainrightext, bly1 + _P.connectdrainwidth)
            )
            -- main anchor
            transistor:add_area_anchor_bltr("drainstrap",
                point.create(blx - _P.connectdrainleftext, bly1),
                point.create(trx + _P.connectdrainrightext, bly1 + _P.connectdrainwidth)
            )
            if _P.connectdrainboth then
                -- other strap
                geometry.rectanglebltr(transistor, generics.metal(_P.connectdrainmetal),
                    point.create(blx - _P.connectdrainleftext, bly2),
                    point.create(trx + _P.connectdrainrightext, bly2 + _P.connectdrainwidth)
                )
                -- other anchor
                transistor:add_area_anchor_bltr("otherdrainstrap",
                    point.create(blx - _P.connectdrainleftext, bly2),
                    point.create(trx + _P.connectdrainrightext, bly2 + _P.connectdrainwidth)
                )
            end
            -- connections to strap
            local draininvert = (_P.channeltype == "pmos")
            if _P.connectdraininverse then
                draininvert = not draininvert
            end
            for i = 2, _P.fingers + 1, 2 do
                local shift = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                if not draininvert or _P.connectdrainboth then
                    geometry.rectanglebltr(transistor, generics.metal(_P.connectdrainmetal),
                        point.create(shift, drainoffset + _P.drainsize),
                        point.create(shift + _P.sdwidth, _P.fwidth + _P.connectdrainspace)
                    )
                end
                if draininvert or _P.connectdrainboth then
                    geometry.rectanglebltr(transistor, generics.metal(_P.connectdrainmetal),
                        point.create(shift, -_P.connectdrainspace),
                        point.create(shift + _P.sdwidth, drainoffset)
                    )
                end
            end
        end
    end

    -- extra source/drain straps (unconnected, useful for arrays)
    if _P.drawextrabotstrap then
        local blx = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (_P.extrabotstrapleftalign - 1) * gatepitch
        local trx = blx + 2 * (_P.fingers // 2) * gatepitch + (_P.extrabotstraprightalign - _P.fingers) * gatepitch + _P.sdwidth
        geometry.rectanglebltr(transistor, generics.metal(_P.extrabotstrapmetal),
            point.create(blx, -_P.extrabotstrapspace - _P.extrabotstrapwidth),
            point.create(trx, -_P.extrabotstrapspace)
        )
        -- anchors
        transistor:add_area_anchor_bltr("extrabotstrap",
            point.create(blx, -_P.extrabotstrapspace - _P.extrabotstrapwidth),
            point.create(trx, -_P.extrabotstrapspace)
        )
    end
    if _P.drawextratopstrap then
        local align = _P.extratopstrapalign == "source" and 0 or 1
        geometry.rectanglebltr(transistor, generics.metal(_P.extratopstrapmetal),
            point.create(align * gatepitch, _P.fwidth + _P.extratopstrapspace),
            point.create((_P.fingers - align) * gatepitch + _P.sdwidth, _P.fwidth + _P.extratopstrapspace + _P.extratopstrapwidth)
        )
        -- anchors
        transistor:add_area_anchor_bltr("extratopstrap",
            point.create(align * gatepitch, _P.fwidth + _P.extratopstrapspace),
            point.create((_P.fingers - align) * gatepitch + _P.sdwidth, _P.fwidth + _P.extratopstrapspace + _P.extratopstrapwidth)
        )
    end

    -- short transistor
    -- FIXME: find better options to draw this
    --        the main problem is proper alignment in cases involving odd parameters for sdwidth and sourcesize
    if _P.shortdevice then
        geometry.rectanglebltr(transistor, generics.metal(1),
            transistor:get_area_anchor("sourcedrain1").br:translate(0, _P.sourcesize // 2),
            transistor:get_area_anchor(string.format("sourcedrain%d", _P.fingers + 1)).bl:translate(0, _P.sourcesize // 2 + _P.sdwidth)
        )
    end

    -- anchors for source drain active regions
    for i = 1, _P.fingers + 1 do
        local shift = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
        transistor:add_area_anchor_bltr(string.format("sourcedrainactive%d", i),
            point.create(shift, 0),
            point.create(shift + _P.sdwidth, _P.fwidth)
        )
    end

    -- alignmentbox
    if _P.drawguardring then
        transistor:inherit_alignment_box(guardring)
    else
        transistor:set_alignment_box(
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2, 0),
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2 + (_P.fingers + 1 - 1) * gatepitch, _P.fwidth),
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2 + _P.sdwidth, 0),
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2 + (_P.fingers + 1 - 1) * gatepitch + _P.sdwidth, _P.fwidth)
        )
    end

    -- special anchors for easier left/right alignment
    transistor:add_area_anchor_bltr(
        "sourcedrainactiveleft",
        transistor:get_area_anchor("sourcedrainactive1").bl,
        transistor:get_area_anchor("sourcedrainactive1").tr
    )
    transistor:add_area_anchor_bltr(
        "sourcedrainactiveright",
        transistor:get_area_anchor(string.format("sourcedrainactive%d", _P.fingers + 1)).bl,
        transistor:get_area_anchor(string.format("sourcedrainactive%d", _P.fingers + 1)).tr
    )
end
