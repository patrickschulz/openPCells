function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                                              "nmos", posvals = set("nmos", "pmos") },
        { "implantalignwithactive",                                                 false },
        { "oxidetype(Oxide Thickness Type)",                                        1, argtype = "integer", posvals = interval(1, inf) },
        { "oxidetypealignwithactive",                                               false },
        { "vthtype(Threshold Voltage Type)",                                        1, argtype = "integer", posvals = interval(1, inf) },
        { "vthtypealignwithactive",                                                 false },
        { "gatemarker(Gate Marking Layer Index)",                                   1, argtype = "integer", posvals = interval(1, inf) },
        { "mosfetmarker(MOSFET Marking Layer Index)",                               1, argtype = "integer", posvals = interval(1, inf) },
        { "mosfetmarkeralignatsourcedrain(Align MOSFET Marker at Source/Drain)",    false },
        { "flippedwell(Flipped Well)",                                              false },
        { "fingers(Number of Fingers)",                                             1, argtype = "integer", posvals = interval(0, inf) },
        { "fwidth(Finger Width)",                                                   technology.get_dimension("Minimum Gate Width"), argtype = "integer" },
        { "gatelength(Gate Length)",                                                technology.get_dimension("Minimum Gate Length"), argtype = "integer" },
        { "gatespace(Gate Spacing)",                                                technology.get_dimension("Minimum Gate XSpace"), argtype = "integer" },
        { "actext(Active Extension)",                                               0 },
        { "sdwidth(Source/Drain Contact Width)",                                    technology.get_dimension("Minimum M1 Width"), argtype = "integer" }, -- FIXME: rename
        { "sdviawidth(Source/Drain Metal Width for Vias)",                          technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth" },
        { "sdmetalwidth(Source/Drain Metal Width)",                                 technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdviawidth" },
        { "gtopext(Gate Top Extension)",                                            technology.get_dimension("Minimum Gate Extension") },
        { "gbotext(Gate Bottom Extension)",                                         technology.get_dimension("Minimum Gate Extension") },
        { "gtopextadd(Gate Additional Top Extension)",                              0 },
        { "gbotextadd(Gate Additional Bottom Extension)",                           0 },
        { "cliptop(Clip Top Marker Layers)",                                        false },
        { "clipbot(Clip Bottom Marker Layers)",                                     false },
        { "drawleftstopgate(Draw Left Stop Gate)",                                  false },
        { "drawrightstopgate(Draw Right Stop Gate)",                                false },
        { "endleftwithgate(End Left Side With Gate)",                               false, follow = "drawleftstopgate" },
        { "endrightwithgate(End Right Side With Gate)",                             false, follow = "drawrightstopgate" },
        { "drawtopgate(Draw Top Gate Contact)",                                     false },
        { "drawtopgatestrap(Draw Top Gate Strap)",                                  false, follow = "drawtopgate" },
        { "topgatewidth(Top Gate Width)",                                           technology.get_dimension("Minimum M1 Width"), argtype = "integer", posvals = even() },
        { "topgateleftextension(Top Gate Left Extension)",                          0 },
        { "topgaterightextension(Top Gate Right Extension)",                        0 },
        { "topgatespace(Top Gate Space)",                                           technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "topgatemetal(Top Gate Strap Metal)",                                     1 },
        { "drawtopgatevia(Draw Top Gate Via)",                                      false },
        { "topgatecontinuousvia(Top Gate Continuous Via)",                          false },
        { "drawbotgate(Draw Bottom Gate Contact)",                                  false },
        { "drawbotgatestrap(Draw Bot Gate Strap)",                                  false, follow = "drawbotgate" },
        { "botgatewidth(Bottom Gate Width)",                                        technology.get_dimension("Minimum M1 Width"), argtype = "integer", posvals = even() },
        { "botgatespace(Bottom Gate Space)",                                        technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "botgateleftextension(Bottom Gate Left Extension)",                       0 },
        { "botgaterightextension(Bottom Gate Right Extension)",                     0 },
        { "botgatemetal(Bottom Gate Strap Metal)",                                  1 },
        { "drawbotgatevia(Draw Bot Gate Via)",                                      false },
        { "botgatecontinuousvia(Bot Gate Continuous Via)",                          false },
        { "botgateviatarget(Metal Target of Bot Gate Via)",                         2 },
        { "drawtopgcut(Draw Top Gate Cut)",                                         false },
        { "topgcutwidth(Top Gate Cut Y Width)",                                     technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace") },
        { "topgcutspace(Top Gate Cut Y Space)",                                     0 },
        { "topgcutleftext(Top Gate Cut Left Extension)",                            0 },
        { "topgcutrightext(Top Gate Cut Right Extension)",                          0 },
        { "drawbotgcut(Draw Bottom Gate Cut)",                                      false },
        { "botgcutwidth(Bottom Gate Cut Y Width)",                                  technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace") },
        { "botgcutspace(Bottom Gate Cut Y Space)",                                  0 },
        { "botgcutleftext(Bottom Gate Cut Left Extension)",                         0 },
        { "botgcutrightext(Bottom Gate Cut Right Extension)",                       0 },
        { "simulatemissinggatecut",                                                 false },
        { "drawsourcedrain(Draw Source/Drain Contacts)",                            "both", posvals = set("both", "source", "drain", "none") },
        { "excludesourcedraincontacts(Exclude Source/Drain Contacts)",              {}, argtype = "table" },
        { "sourcesize(Source Size)",                                                technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fwidth" },
        { "sourceviasize(Source Via Size)",                                         technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "sourcesize" },
        { "drainsize(Drain Size)",                                                  technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fwidth" },
        { "drainviasize(Drain Via Size)",                                           technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "drainsize" },
        { "sourcealign(Source Alignement)",                                         "bottom", posvals = set("top", "bottom") },
        { "sourceviaalign(Source Via Alignement)",                                  "bottom", posvals = set("top", "bottom"), follow = "sourcealign" },
        { "drainalign(Drain Alignement)",                                           "top", posvals = set("top", "bottom") },
        { "drainviaalign(Drain Via Alignement)",                                    "top", posvals = set("top", "bottom"), follow = "drainalign" },
        { "drawsourcevia(Draw Source Via)",                                         true },
        { "drawfirstsourcevia(Draw First Source Via)",                              true },
        { "drawlastsourcevia(Draw Last Source Via)",                                true },
        { "connectsource(Connect Source)",                                          false },
        { "drawsourcestrap(Draw Source Strap)",                                     false, follow = "connectsource" },
        { "drawsourceconnections(Draw Source Connections)",                         false, follow = "connectsource" },
        { "connectsourceboth(Connect Source on Both Sides)",                        false },
        { "connectsourcewidth(Source Rails Metal Width)",                           technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth" },
        { "connectsourcespace(Source Rails Metal Space)",                           technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connectsourceleftext(Source Rails Metal Left Extension)",                0 },
        { "connectsourcerightext(Source Rails Metal Right Extension)",              0 },
        { "connectsourceotherwidth(Other Source Rails Metal Width)",                technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectsourcewidth" },
        { "connectsourceotherspace(Other Source Rails Metal Space)",                technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectsourcespace" },
        { "connectsourceotherleftext(Other Source Rails Metal Left Extension)",     0, follow = "connectsourceleftext", },
        { "connectsourceotherrightext(Other Source Rails Metal Right Extension)",   0, follow = "connectsourcerightext", },
        { "sourcemetal(Source Connection Metal)",                                   1 },
        { "sourceviametal(Source Via Metal)",                                       1, follow = "sourcemetal" },
        { "connectsourceinline(Connect Source Inline of Transistor)",               false },
        { "connectsourceinlineoffset(Offset for Inline Source Connection)",         0 },
        { "connectsourceinverse(Invert Source Strap Locations)",                    false },
        { "connectdrain(Connect Drain)",                                            false },
        { "drawdrainstrap(Draw Drain Strap)",                                       false, follow = "connectdrain" },
        { "drawdrainconnections(Draw Drain Connections)",                           false, follow = "connectdrain" },
        { "connectdrainboth(Connect Drain on Both Sides)",                          false },
        { "connectdrainwidth(Drain Rails Metal Width)",                             technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth" },
        { "connectdrainspace(Drain Rails Metal Space)",                             technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connectdrainleftext(Drain Rails Metal Left Extension)",                  0 },
        { "connectdrainrightext(Drain Rails Metal Right Extension)",                0 },
        { "connectdraininverse(Invert Drain Strap Locations)",                      false },
        { "connectdrainotherwidth(Other Drain Rails Metal Width)",                  technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectdrainwidth" },
        { "connectdrainotherspace(Other Drain Rails Metal Space)",                  technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectdrainspace" },
        { "connectdrainotherleftext(Other Drain Rails Metal Left Extension)",       0, follow = "connectdrainleftext" },
        { "connectdrainotherrightext(Other Drain Rails Metal Right Extension)",     0, follow = "connectdrainrightext" },
        { "drawdrainvia(Draw Drain Via)",                                           true },
        { "drawfirstdrainvia(Draw First Drain Via)",                                true },
        { "drawlastdrainvia(Draw Last Drain Via)",                                  true },
        { "drainmetal(Drain Connection Metal)",                                     1 },
        { "drainviametal(Drain Via Metal)",                                         1, follow = "drainmetal" },
        { "connectdraininline(Connect Drain Inline of Transistor)",                 false },
        { "connectdraininlineoffset(Offset for Inline Drain Connection)",           0 },
        { "diodeconnected(Diode Connected Transistor)",                             false },
        { "drawextrabotstrap(Draw Extra Bottom Strap)",                             false },
        { "extrabotstrapwidth(Width of Extra Bottom Strap)",                        technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "extrabotstrapspace(Space of Extra Bottom Strap)",                        technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "extrabotstrapmetal(Metal Layer for Extra Bottom Strap)",                 1 },
        { "extrabotstrapleftalign(Left Alignment for Extra Bottom Strap)",          1 },
        { "extrabotstraprightalign(Right Alignment for Extra Bottom Strap)",        1, follow = "fingers" },
        { "drawextratopstrap(Draw Extra Top Strap)",                                false },
        { "extratopstrapwidth(Width of Extra Top Strap)",                           technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "extratopstrapspace(Space of Extra Top Strap)",                           technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "extratopstrapmetal(Metal Layer for Extra Top Strap)",                    1 },
        { "extratopstrapleftalign(Left Alignment for Extra Top Strap)",             1 },
        { "extratopstraprightalign(Right Alignment for Extra Top Strap)",           1, follow = "fingers" },
        { "shortdevice(Short Transistor)",                                          false },
        { "shortdeviceleftoffset(Short Transistor Left Offset)",                    0 },
        { "shortdevicerightoffset(Short Transistor Right Offset)",                  0 },
        { "shortlocation",                                                          "inline", posvals = set("inline", "top", "bottom") },
        { "shortspace",                                                             technology.get_dimension("Minimum M1 Space") },
        { "shortwidth",                                                             technology.get_dimension("Minimum M1 Width") },
        { "drawtopactivedummy",                                                     false },
        { "topactivedummywidth",                                                    80 },
        { "topactivedummysep",                                                      80 },
        { "drawbotactivedummy",                                                     false },
        { "botactivedummywidth",                                                    80 },
        { "botactivedummysep",                                                      80 },
        { "leftfloatingdummies",                                                    0 },
        { "rightfloatingdummies",                                                   0 },
        { "drawactive",                                                             true },
        { "lvsmarker",                                                              1 },
        { "lvsmarkeralignwithactive",                                               false },
        { "extendalltop",                                                           0 },
        { "extendallbot",                                                           0 },
        { "extendallleft",                                                          0 },
        { "extendallright",                                                         0 },
        { "extendoxidetop",                                                         0, follow = "extendalltop" },
        { "extendoxidebot",                                                         0, follow = "extendallbot" },
        { "extendoxideleft",                                                        0, follow = "extendallleft" },
        { "extendoxideright",                                                       0, follow = "extendallright" },
        { "extendvthtop",                                                           0, follow = "extendalltop" },
        { "extendvthbot",                                                           0, follow = "extendallbot" },
        { "extendvthleft",                                                          0, follow = "extendallleft" },
        { "extendvthright",                                                         0, follow = "extendallright" },
        { "extendimplanttop",                                                       0, follow = "extendalltop" },
        { "extendimplantbot",                                                       0, follow = "extendallbot" },
        { "extendimplantleft",                                                      0, follow = "extendallleft" },
        { "extendimplantright",                                                     0, follow = "extendallright" },
        { "extendwelltop",                                                          0, follow = "extendalltop" },
        { "extendwellbot",                                                          0, follow = "extendallbot" },
        { "extendwellleft",                                                         0, follow = "extendallleft" },
        { "extendwellright",                                                        0, follow = "extendallright" },
        { "extendwelltop",                                                          0, follow = "extendalltop" },
        { "extendwellbot",                                                          0, follow = "extendallbot" },
        { "extendwellleft",                                                         0, follow = "extendallleft" },
        { "extendwellright",                                                        0, follow = "extendallright" },
        { "extendlvsmarkertop",                                                     0, follow = "extendalltop" },
        { "extendlvsmarkerbot",                                                     0, follow = "extendallbot" },
        { "extendlvsmarkerleft",                                                    0, follow = "extendallleft" },
        { "extendlvsmarkerright",                                                   0, follow = "extendallright" },
        { "extendrotationmarkertop",                                                0, follow = "extendalltop" },
        { "extendrotationmarkerbot",                                                0, follow = "extendallbot" },
        { "extendrotationmarkerleft",                                               0, follow = "extendallleft" },
        { "extendrotationmarkerright",                                              0, follow = "extendallright" },
        { "drawwell",                                                               true },
        { "drawtopwelltap",                                                         false },
        { "topwelltapwidth",                                                        technology.get_dimension("Minimum M1 Width") },
        { "topwelltapspace",                                                        technology.get_dimension("Minimum M1 Space") },
        { "topwelltapextendleft",                                                   0 },
        { "topwelltapextendright",                                                  0 },
        { "drawbotwelltap",                                                         false },
        { "drawguardring",                                                          false },
        { "guardringwidth",                                                         technology.get_dimension("Minimum M1 Width") },
        { "guardringxsep",                                                          0 },
        { "guardringysep",                                                          0 },
        { "guardringsegments",                                                      { "left", "right", "top", "bottom" } },
        { "botwelltapwidth",                                                        technology.get_dimension("Minimum M1 Width") },
        { "botwelltapspace",                                                        technology.get_dimension("Minimum M1 Space") },
        { "botwelltapextendleft",                                                   0 },
        { "botwelltapextendright",                                                  0 },
        { "drawstopgatetopgcut",                                                    false },
        { "drawstopgatebotgcut",                                                    false },
        { "leftpolylines",                                                          {} },
        { "rightpolylines",                                                         {} },
        { "drawrotationmarker",                                                     false }
    )
end

function check(_P)
    if (_P.gatespace % 2) ~= (_P.sdwidth % 2) then
        return false, "gatespace and sdwidth must both be even or odd"
    end
    if (_P.sdmetalwidth % 2) ~= (_P.sdwidth % 2) then
        return false, string.format("sdmetalwidth and sdwidth must both be even or odd (%d vs %d)", _P.sdmetalwidth, _P.sdwidth)
    end
    if _P.sdviawidth < _P.sdwidth then
        return false, "sdviawidth must not be smaller than sdwidth"
    end
    if _P.sdmetalwidth < _P.sdviawidth then
        return false, "sdmetalwidth must not be smaller than sdviawidth"
    end
    if _P.shortdevice and ((_P.sourcesize % 2) ~= (_P.sdwidth % 2)) then
        return false, "gatespace and sdwidth must both be even or odd when shortdevice is true"
    end
    if not (not _P.endleftwithgate or (_P.gatelength % 2 == 0)) then
        return false, "gatelength must be even when endleftwithgate is true"
    end
    if not (not _P.endrightwithgate or (_P.gatelength % 2 == 0)) then
        return false, "gatelength must be even when endrightwithgate is true"
    end
    if
        (_P.shortdeviceleftoffset > 0 or _P.shortdevicerightoffset > 0) and
        (_P.fingers - _P.shortdevicerightoffset - _P.shortdeviceleftoffset <= 0) then
        return false, "can't short device with zero fingers and non-zero short offsets"
    end
    return true
end

function layout(transistor, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    --local leftactext
    --if _P.endleftwithgate then
    --    leftactext = _P.gatespace + _P.gatelength / 2
    --else
    --    leftactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    --end
    --local rightactext
    --if _P.endrightwithgate then
    --    rightactext = _P.gatespace + _P.gatelength / 2
    --else
    --    rightactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    --end
    local leftactauxext = _P.endleftwithgate and 0 or 0
    local rightactauxext = _P.endleftwithgate and 0 or 0
    local leftactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    local rightactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    local leftactauxext = _P.endleftwithgate and _P.gatelength / 2 - _P.sdwidth / 2 + _P.gatespace / 2 or 0
    local rightactauxext = _P.endrightwithgate and _P.gatelength / 2 - _P.sdwidth / 2 + _P.gatespace / 2 or 0
    local activewidth = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + _P.leftfloatingdummies * gatepitch + _P.rightfloatingdummies * gatepitch

    local topgateshift = enable(_P.drawtopgate, _P.topgatespace + _P.topgatewidth)
    local botgateshift = enable(_P.drawbotgate, _P.botgatespace + _P.botgatewidth)
    local gateaddtop = math.max(_P.gtopext, topgateshift) + _P.gtopextadd
    local gateaddbot = math.max(_P.gbotext, botgateshift) + _P.gbotextadd

    local drainshift = enable(_P.connectdrain, _P.connectdrainwidth + _P.connectdrainspace)
    local sourceshift = enable(_P.connectsource, _P.connectsourcewidth + _P.connectsourcespace)
    if _P.channeltype == "pmos" then
        drainshift, sourceshift = sourceshift, drainshift
    end

    local hasgatecut = not _P.simulatemissinggatecut and technology.has_layer(generics.other("gatecut"))

    -- active
    if _P.drawactive then
        geometry.rectanglebltr(transistor, generics.other("active"),
            point.create(-leftactauxext, 0),
            point.create(activewidth + leftactext + rightactext + rightactauxext, _P.fwidth)
        )
        transistor:add_area_anchor_bltr("active",
            point.create(-leftactauxext, 0),
            point.create(activewidth + leftactext + rightactext + rightactauxext, _P.fwidth)
        )
        if _P.drawtopactivedummy then
            geometry.rectanglebltr(transistor, generics.other("active"),
                point.create(-leftactauxext, _P.fwidth + _P.topactivedummysep),
                point.create(activewidth + leftactext + rightactext + rightactauxext, _P.fwidth + _P.topactivedummysep + _P.topactivedummywidth)
            )
        end
        if _P.drawbotactivedummy then
            geometry.rectanglebltr(transistor, generics.other("active"),
                point.create(-leftactauxext, -_P.botactivedummysep - _P.botactivedummywidth),
                point.create(activewidth + leftactext + rightactext + rightactauxext, -_P.botactivedummysep)
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
    if _P.vthtypealignwithactive then
        geometry.rectanglebltr(transistor,
            generics.vthtype(_P.channeltype, _P.vthtype),
            point.create(
                -leftactauxext - _P.extendvthleft,
                -_P.extendvthbot
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendvthright,
                _P.fwidth + _P.extendvthtop
            )
        )
    else
        geometry.rectanglebltr(transistor,
            generics.vthtype(_P.channeltype, _P.vthtype),
            point.create(
                -leftactauxext - _P.extendvthleft,
                gatebly - _P.extendvthbot
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendvthright,
                gatetry + _P.extendvthtop
            )
        )
    end

    -- implant
    if _P.implantalignwithactive then
        geometry.rectanglebltr(transistor,
            generics.implant(_P.channeltype),
            point.create(
                -leftactauxext - _P.extendimplantleft,
                -_P.extendimplantbot
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendimplantright,
                _P.fwidth + _P.extendimplanttop
            )
        )
    else
        geometry.rectanglebltr(transistor,
            generics.implant(_P.channeltype),
            point.create(
                -leftactauxext - _P.extendimplantleft,
                gatebly - _P.extendimplantbot
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendimplantright,
                gatetry + _P.extendimplanttop
            )
        )
    end

    -- oxide thickness
    if _P.oxidetypealignwithactive then
        geometry.rectanglebltr(transistor,
            generics.oxide(_P.oxidetype),
            point.create(
                -leftactauxext - _P.extendoxideleft,
                -_P.extendoxidebot
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendoxideright,
                _P.fwidth + _P.extendoxidetop
            )
        )
    else
        geometry.rectanglebltr(transistor,
            generics.oxide(_P.oxidetype),
            point.create(
                -leftactauxext - _P.extendoxideleft,
                gatebly - _P.extendoxidebot
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendoxideright,
                gatetry + _P.extendoxidetop
            )
        )
    end

    -- rotation marker
    if _P.drawrotationmarker then
        geometry.rectanglebltr(transistor,
            generics.other("rotationmarker"),
            point.create(-leftactauxext - _P.extendrotationmarkerleft, -_P.extendrotationmarkerbot),
            point.create(activewidth + leftactext + rightactext + rightactauxext + _P.extendrotationmarkerright, _P.fwidth + _P.extendrotationmarkertop)
        )

    end

    -- lvs marker
    if _P.lvsmarkeralignwithactive then
        geometry.rectanglebltr(transistor,
            generics.other(string.format("lvsmarker%d", _P.lvsmarker)),
            point.create(
                -leftactauxext - _P.extendlvsleft,
                -_P.extendlvsbot
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendlvsright,
                _P.fwidth + _P.extendlvstop
            )
        )
    else
        geometry.rectanglebltr(transistor,
            generics.other(string.format("lvsmarker%d", _P.lvsmarker)),
            point.create(
                -leftactauxext - _P.extendlvsmarkerleft,
                gatebly - _P.extendlvsmarkerbot
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendlvsmarkerright,
                gatetry + _P.extendlvsmarkertop
            )
        )
    end

    -- well
    if _P.drawwell then
        geometry.rectanglebltr(transistor,
            generics.other(_P.flippedwell and
                (_P.channeltype == "nmos" and "nwell" or "pwell") or
                (_P.channeltype == "nmos" and "pwell" or "nwell")
            ),
            point.create(
                -leftactauxext - _P.extendwellleft,
                -math.max(_P.extendwellbot, enable(_P.drawbotwelltap, _P.botwelltapspace + _P.botwelltapwidth))
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendwellright,
                _P.fwidth + math.max(_P.extendwelltop, enable(_P.drawtopwelltap, _P.topwelltapspace + _P.topwelltapwidth))
            )
        )
    end
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
            holewidth = activewidth + leftactauxext + leftactext + rightactext + rightactauxext + 2 * _P.guardringxsep,
            holeheight = _P.fwidth + 2 * _P.guardringysep,
            fillwell = true,
            drawsegments = _P.guardringsegments
        })
        guardring:move_point(guardring:get_anchor("innerbottomleft"), point.create(-leftactauxext, 0))
        guardring:translate(-_P.guardringxsep, -_P.guardringysep)
        transistor:merge_into(guardring)
        transistor:add_area_anchor_bltr("outerguardring",
            guardring:get_anchor("outerbottomleft"),
            guardring:get_anchor("outertopright")
        )
        transistor:add_area_anchor_bltr("innerguardring",
            guardring:get_anchor("innerbottomleft"),
            guardring:get_anchor("innertopright")
        )
    end

    -- gate contacts
    if _P.drawtopgate then
        for i = 1, _P.fingers do
            local contactfun = _P.drawtopgatestrap and geometry.contactbarebltr or geometry.contactbltr
            contactfun(transistor,
                "gate",
                point.create(gateblx + (i - 1) * gatepitch, _P.fwidth + _P.topgatespace),
                point.create(gatetrx + (i - 1) * gatepitch, _P.fwidth + _P.topgatespace + _P.topgatewidth)
            )
            transistor:add_area_anchor_bltr(string.format("topgate%d", i),
                point.create(gateblx + (i - 1) * gatepitch, _P.fwidth + _P.topgatespace),
                point.create(gatetrx + (i - 1) * gatepitch, _P.fwidth + _P.topgatespace + _P.topgatewidth)
            )
        end
    end
    if _P.fingers > 0 and _P.drawtopgatestrap then
        local bl = point.create(gateblx + (1 - 1) * gatepitch - _P.topgateleftextension, _P.fwidth + _P.topgatespace)
        local tr = point.create(gatetrx + (_P.fingers - 1) * gatepitch + _P.topgaterightextension, _P.fwidth + _P.topgatespace + _P.topgatewidth)
        geometry.rectanglebltr(transistor, generics.metal(1), bl, tr)
        transistor:add_area_anchor_bltr("topgatestrap", bl, tr)
        if _P.drawtopgatevia and _P.topgatemetal > 1 then
            if _P.topgatecontinuousvia then
                geometry.viabltr_xcontinuous(transistor, 1, _P.topgatemetal, bl, tr)
            else
                geometry.viabltr(transistor, 1, _P.topgatemetal, bl, tr)
            end
        end
    end
    if _P.drawbotgate then
        for i = 1, _P.fingers do
            local contactfun = _P.drawbotgatestrap and geometry.contactbarebltr or geometry.contactbltr
            contactfun(transistor,
                "gate",
                point.create(gateblx + (i - 1) * gatepitch, -_P.botgatespace - _P.botgatewidth),
                point.create(gatetrx + (i - 1) * gatepitch, -_P.botgatespace)
            )
            transistor:add_area_anchor_bltr(string.format("botgate%d", i),
                point.create(gateblx + (i - 1) * gatepitch, -_P.botgatespace - _P.botgatewidth),
                point.create(gatetrx + (i - 1) * gatepitch, -_P.botgatespace)
            )
        end
    end
    if _P.fingers > 0 and _P.drawbotgatestrap then
        local bl = point.create(gateblx + (1 - 1) * gatepitch - _P.botgateleftextension, -_P.botgatespace - _P.botgatewidth)
        local tr = point.create(gatetrx + (_P.fingers - 1) * gatepitch + _P.botgaterightextension, -_P.botgatespace)
        geometry.rectanglebltr(transistor, generics.metal(1), bl, tr)
        transistor:add_area_anchor_bltr("botgatestrap", bl, tr)
        if _P.drawbotgatevia and _P.botgatemetal > 1 then
            if _P.botgatecontinuousvia then
                geometry.viabltr_xcontinuous(transistor, 1, _P.botgatemetal, bl, tr)
            else
                geometry.viabltr(transistor, 1, _P.botgatemetal, bl, tr)
            end
        end
    end

    local sdviashift = (_P.sdviawidth - _P.sdwidth) / 2
    local sdmetalshift = (_P.sdmetalwidth - _P.sdwidth) / 2

    -- source/drain contacts and vias
    local sourceoffset = _P.sourcealign == "top" and _P.fwidth - _P.sourcesize or 0
    local sourceviaoffset = _P.sourceviaalign == "top" and _P.fwidth - _P.sourceviasize or 0
    local drainoffset = _P.drainalign == "top" and _P.fwidth - _P.drainsize or 0
    local drainviaoffset = _P.drainviaalign == "top" and _P.fwidth - _P.drainviasize or 0
    if _P.drawsourcedrain ~= "none" then
        -- source
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "source" then
            for i = 1, _P.fingers + 1, 2 do
                local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                local bl = point.create(shift, sourceoffset)
                local tr = point.create(shift + _P.sdwidth, sourceoffset + _P.sourcesize)
                if not aux.any_of(i, _P.excludesourcedraincontacts) then
                    geometry.contactbarebltr(transistor, "sourcedrain", bl, tr)
                end
                if _P.drawsourcevia and _P.sourceviametal > 1 and
                   not (i == 1 and not _P.drawfirstsourcevia or
                    i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                    geometry.viabarebltr(transistor, 1, _P.sourceviametal,
                        point.create(shift - sdviashift, sourceviaoffset),
                        point.create(shift + _P.sdviawidth - sdviashift, sourceviaoffset + _P.sourceviasize)
                    )
                end
                geometry.rectanglebltr(transistor, generics.metal(1),
                    point.create(shift - sdmetalshift, sourceoffset),
                    point.create(shift + _P.sdmetalwidth - sdmetalshift, sourceoffset + _P.sourcesize)
                )
                for metal = 2, _P.sourceviametal do
                    geometry.rectanglebltr(transistor, generics.metal(metal),
                        point.create(shift - sdmetalshift, sourceviaoffset),
                        point.create(shift + _P.sdmetalwidth - sdmetalshift, sourceviaoffset + _P.sourceviasize)
                    )
                end
                -- anchors
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i), bl, tr)
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i - _P.fingers - 2), bl, tr)
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i),
                    point.create(shift - sdmetalshift, sourceviaoffset),
                    point.create(shift + _P.sdmetalwidth - sdmetalshift, sourceviaoffset + _P.sourceviasize)
                )
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i - _P.fingers - 2),
                    point.create(shift - sdmetalshift, sourceviaoffset),
                    point.create(shift + _P.sdmetalwidth - sdmetalshift, sourceviaoffset + _P.sourceviasize)
                )
            end
        end
        -- drain
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "drain" then
            for i = 2, _P.fingers + 1, 2 do
                local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                local bl = point.create(shift, drainoffset)
                local tr = point.create(shift + _P.sdwidth, drainoffset + _P.drainsize)
                if not aux.any_of(i, _P.excludesourcedraincontacts) then
                    geometry.contactbarebltr(transistor, "sourcedrain", bl, tr)
                end
                if _P.drawdrainvia and _P.drainviametal > 1 and
                   not (i == 2 and not _P.drawfirstdrainvia or
                    i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                    geometry.viabarebltr(transistor, 1, _P.drainviametal,
                        point.create(shift - sdviashift, drainviaoffset),
                        point.create(shift + _P.sdviawidth - sdviashift, drainviaoffset + _P.drainviasize)
                    )
                end
                geometry.rectanglebltr(transistor, generics.metal(1),
                    point.create(shift - sdmetalshift, drainoffset),
                    point.create(shift + _P.sdmetalwidth - sdmetalshift, drainoffset + _P.drainsize)
                )
                for metal = 2, _P.drainviametal do
                    geometry.rectanglebltr(transistor, generics.metal(metal),
                        point.create(shift - sdmetalshift, drainviaoffset),
                        point.create(shift + _P.sdmetalwidth - sdmetalshift, drainviaoffset + _P.drainviasize)
                    )
                end
                -- anchors
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i), bl, tr)
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i - _P.fingers - 2), bl, tr)
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i),
                point.create(shift - sdmetalshift, drainviaoffset),
                point.create(shift + _P.sdmetalwidth - sdmetalshift, drainviaoffset + _P.drainviasize)
            )
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i - _P.fingers - 2),
                    point.create(shift - sdmetalshift, drainviaoffset),
                    point.create(shift + _P.sdmetalwidth - sdmetalshift, drainviaoffset + _P.drainviasize)
                )
            end
        end
    end

    -- diode connected
    if _P.diodeconnected then
        for i = 2, _P.fingers + 1, 2 do
            if _P.drawtopgatestrap then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tl:translate_x(-sdmetalshift),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tr:translate_x(sdmetalshift) ..
                    transistor:get_area_anchor(string.format("topgatestrap", i)).br
                )
            end
            if _P.drawbotgatestrap then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).bl:translate_x(-sdmetalshift) ..
                    transistor:get_area_anchor(string.format("botgatestrap", i)).tl,
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).br:translate_x(sdmetalshift)
                )
            end
        end
    end

    -- source connections
    if _P.drawsourceconnections and not _P.connectsourceinline then
        -- connections to strap
        local sourceinvert = (_P.channeltype == "pmos")
        if _P.connectsourceinverse then
            sourceinvert = not sourceinvert
        end
        for i = 1, _P.fingers + 1, 2 do
            local shift = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch - sdmetalshift
            if sourceinvert then
                if sourceoffset + _P.sourcesize < _P.fwidth + _P.connectsourcespace then -- don't draw connections if they are malformed
                    if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                        geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                            point.create(shift, sourceoffset + _P.sourcesize),
                            point.create(shift + _P.sdmetalwidth, _P.fwidth + _P.connectsourcespace)
                        )
                    end
                end
                if _P.connectsourceboth then
                    if -_P.connectsourceotherspace < sourceoffset then -- don't draw connections if they are malformed
                        if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                            geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                                point.create(shift, -_P.connectsourceotherspace),
                                point.create(shift + _P.sdmetalwidth, sourceoffset)
                            )
                        end
                    end
                end
            else
                if -_P.connectsourcespace < sourceoffset then -- don't draw connections if they are malformed
                    if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                        geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                            point.create(shift, -_P.connectsourcespace),
                            point.create(shift + _P.sdmetalwidth, sourceoffset)
                        )
                    end
                end
                if _P.connectsourceboth then
                    if sourceoffset + _P.sourcesize < _P.fwidth + _P.connectsourceotherspace then -- don't draw connections if they are malformed
                        if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                            geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                                point.create(shift, sourceoffset + _P.sourcesize),
                                point.create(shift + _P.sdmetalwidth, _P.fwidth + _P.connectsourceotherspace)
                            )
                        end
                    end
                end
            end
        end
    end

    -- source strap
    if _P.fingers > 0 then
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2
        local trx = blx + 2 * (_P.fingers // 2) * gatepitch + _P.sdmetalwidth
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
            if _P.drawsourcestrap then
                geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                    point.create(blx - _P.connectsourceleftext, bly),
                    point.create(trx + _P.connectsourcerightext, bly + _P.connectsourcewidth)
                )
            end
            transistor:add_area_anchor_bltr("sourcestrap",
                point.create(blx - _P.connectsourceleftext, bly),
                point.create(trx + _P.connectsourcerightext, bly + _P.connectsourcewidth)
            )
        else
            local bly1, bly2
            if _P.channeltype == "nmos" then
                if _P.connectsourceinverse then
                    bly1 = _P.fwidth + _P.connectsourcespace
                    bly2 = -_P.connectsourceotherspace - _P.connectsourceotherwidth
                else
                    bly1 = -_P.connectsourcespace - _P.connectsourcewidth
                    bly2 = _P.fwidth + _P.connectsourceotherspace
                end
            else
                if _P.connectsourceinverse then
                    bly1 = -_P.connectsourcespace - _P.connectsourcewidth
                    bly2 = _P.fwidth + _P.connectsourceotherspace
                else
                    bly1 = _P.fwidth + _P.connectsourcespace
                    bly2 = -_P.connectsourceotherspace - _P.connectsourceotherwidth
                end
            end
            -- main strap
            if _P.drawsourcestrap then
                geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                    point.create(blx - _P.connectsourceleftext, bly1),
                    point.create(trx + _P.connectsourcerightext, bly1 + _P.connectsourcewidth)
                )
                if _P.connectsourceboth then
                    -- other strap
                    geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                        point.create(blx - _P.connectsourceotherleftext, bly2),
                        point.create(trx + _P.connectsourceotherrightext, bly2 + _P.connectsourceotherwidth)
                    )
                end
            end
            -- main anchor
            transistor:add_area_anchor_bltr("sourcestrap",
                point.create(blx - _P.connectsourceleftext, bly1),
                point.create(trx + _P.connectsourcerightext, bly1 + _P.connectsourcewidth)
            )
            if _P.connectsourceboth then
                -- other anchor
                transistor:add_area_anchor_bltr("othersourcestrap",
                    point.create(blx - _P.connectsourceotherleftext, bly2),
                    point.create(trx + _P.connectsourceotherrightext, bly2 + _P.connectsourceotherwidth)
                )
            end
        end
    end

    -- drain connections
    local draininvert = (channeltype == "pmos")
    if _P.connectdraininverse then
        draininvert = not draininvert
    end
    if _P.drawdrainconnections and not _P.connectdraininline then
        -- connections to strap
        local draininvert = (_P.channeltype == "pmos")
        if _P.connectdraininverse then
            draininvert = not draininvert
        end
        for i = 2, _P.fingers + 1, 2 do
            local shift = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch - sdmetalshift
            local conndrainoffset = _P.drainmetal > 1 and drainviaoffset or drainoffset
            local conndraintop = _P.drainmetal > 1 and _P.drainviasize or _P.drainsize
            if draininvert then
                if -_P.connectdrainspace < conndrainoffset then -- don't draw connections if they are malformed
                    if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                        geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                            point.create(shift, -_P.connectdrainspace),
                            point.create(shift + _P.sdmetalwidth, conndrainoffset)
                        )
                    end
                end
                if _P.connectdrainboth then
                    if conndrainoffset + conndraintop < _P.fwidth + _P.connectdrainotherspace then -- don't draw connections if they are malformed
                       if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                            geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                                point.create(shift, conndrainoffset + conndraintop),
                                point.create(shift + _P.sdmetalwidth, _P.fwidth + _P.connectdrainotherspace)
                            )
                        end
                    end
                end
            else
                if conndrainoffset + conndraintop < _P.fwidth + _P.connectdrainspace then -- don't draw connections if they are malformed
                   if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                        geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                            point.create(shift, conndrainoffset + conndraintop),
                            point.create(shift + _P.sdmetalwidth, _P.fwidth + _P.connectdrainspace)
                        )
                    end
                end
                if _P.connectdrainboth then
                    if -_P.connectdrainotherspace < conndrainoffset then -- don't draw connections if they are malformed
                        if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                            geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                                point.create(shift, -_P.connectdrainotherspace),
                                point.create(shift + _P.sdmetalwidth, conndrainoffset)
                            )
                        end
                    end
                end
            end
        end
    end

    -- drain strap
    if _P.fingers > 0 then
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + (2 - 1) * gatepitch
        local trx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + (2 * ((_P.fingers + 1) // 2) - 1) * gatepitch + _P.sdmetalwidth
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
            if _P.drawdrainstrap then
                geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                    point.create(blx - _P.connectdrainleftext, bly),
                    point.create(trx + _P.connectdrainrightext, bly + _P.connectdrainwidth)
                )
            end
            transistor:add_area_anchor_bltr("drainstrap",
                point.create(blx - _P.connectdrainleftext, bly),
                point.create(trx + _P.connectdrainrightext, bly + _P.connectdrainwidth)
            )
        else
            local bly1, bly2
            if _P.channeltype == "nmos" then
                if _P.connectdraininverse then
                    bly1 = -_P.connectdrainspace - _P.connectdrainwidth
                    bly2 = _P.fwidth + _P.connectdrainotherspace
                else
                    bly1 = _P.fwidth + _P.connectdrainspace
                    bly2 = -_P.connectdrainotherspace - _P.connectdrainotherwidth
                end
            else
                if _P.connectdraininverse then
                    bly1 = _P.fwidth + _P.connectdrainspace
                    bly2 = -_P.connectdrainotherspace - _P.connectdrainotherwidth
                else
                    bly1 = -_P.connectdrainspace - _P.connectdrainwidth
                    bly2 = _P.fwidth + _P.connectdrainotherspace
                end
            end
            if _P.drawdrainstrap then
                -- main strap
                geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                    point.create(blx - _P.connectdrainleftext, bly1),
                    point.create(trx + _P.connectdrainrightext, bly1 + _P.connectdrainwidth)
                )
                if _P.connectdrainboth then
                    -- other strap
                    geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                        point.create(blx - _P.connectdrainotherleftext, bly2),
                        point.create(trx + _P.connectdrainotherrightext, bly2 + _P.connectdrainotherwidth)
                    )
                end
            end
            -- main anchor
            transistor:add_area_anchor_bltr("drainstrap",
                point.create(blx - _P.connectdrainleftext, bly1),
                point.create(trx + _P.connectdrainrightext, bly1 + _P.connectdrainwidth)
            )
            -- other anchor
            if _P.connectdrainboth then
                transistor:add_area_anchor_bltr("otherdrainstrap",
                    point.create(blx - _P.connectdrainotherleftext, bly2),
                    point.create(trx + _P.connectdrainotherrightext, bly2 + _P.connectdrainotherwidth)
                )
            end
        end
    end

    -- extra source/drain straps (unconnected, useful for arrays)
    if _P.drawextrabotstrap then
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + (_P.extrabotstrapleftalign - 1) * gatepitch
        local trx = blx + 2 * (_P.fingers // 2) * gatepitch + (_P.extrabotstraprightalign - _P.fingers) * gatepitch + _P.sdmetalwidth
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
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + (_P.extrabotstrapleftalign - 1) * gatepitch
        local trx = blx + 2 * (_P.fingers // 2) * gatepitch + (_P.extrabotstraprightalign - _P.fingers) * gatepitch + _P.sdmetalwidth
        geometry.rectanglebltr(transistor, generics.metal(_P.extrabotstrapmetal),
            point.create(blx, _P.fwidth + _P.extratopstrapspace),
            point.create(trx, _P.fwidth + _P.extratopstrapspace + _P.extratopstrapwidth)
        )
        -- anchors
        transistor:add_area_anchor_bltr("extratopstrap",
            point.create(blx, _P.fwidth + _P.extratopstrapspace),
            point.create(trx, _P.fwidth + _P.extratopstrapspace + _P.extratopstrapwidth)
        )
    end

    -- short transistor
    if _P.shortdevice then
        if _P.shortlocation == "inline" then
            geometry.rectanglebltr(transistor, generics.metal(1),
                transistor:get_area_anchor(string.format("sourcedrain%d", 1 + _P.shortdeviceleftoffset)).br:translate(0, (_P.sourcesize - _P.sdwidth) / 2),
                transistor:get_area_anchor(string.format("sourcedrain%d", _P.fingers + 1 - _P.shortdevicerightoffset)).bl:translate(0, (_P.sourcesize + _P.sdwidth) / 2)
            )
        elseif _P.shortlocation == "top" then
            geometry.rectanglebltr(transistor, generics.metal(1),
                transistor:get_area_anchor(string.format("sourcedrain%d", 1 + _P.shortdeviceleftoffset)).tl:translate_y(_P.shortspace),
                transistor:get_area_anchor(string.format("sourcedrain%d", _P.fingers + 1 - _P.shortdevicerightoffset)).tr:translate_y(_P.shortspace + _P.shortwidth)
            )
            for i = 1 + _P.shortdeviceleftoffset, _P.fingers - _P.shortdevicerightoffset + 1 do
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tl,
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tr:translate_y(_P.shortspace)
                )
            end
        elseif _P.shortlocation == "bottom" then
            geometry.rectanglebltr(transistor, generics.metal(1),
                transistor:get_area_anchor(string.format("sourcedrain%d", 1 + _P.shortdeviceleftoffset)).bl:translate_y(-_P.shortspace - _P.shortwidth),
                transistor:get_area_anchor(string.format("sourcedrain%d", _P.fingers + 1 - _P.shortdevicerightoffset)).br:translate_y(-_P.shortspace)
            )
            for i = 1 + _P.shortdeviceleftoffset, _P.fingers - _P.shortdevicerightoffset + 1 do
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).bl:translate_y(-_P.shortspace),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).br
                )
            end
        else
            -- can not happen
        end
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
