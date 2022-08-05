function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                              "nmos", posvals = set("nmos", "pmos") },
        { "oxidetype(Oxide Thickness Type)",                             1, argtype = "integer", posvals = interval(1, inf) },
        { "vthtype(Threshold Voltage Type)",                             1, argtype = "integer", posvals = interval(1, inf) },
        { "gatemarker(Gate Marking Layer Index)",                        1, argtype = "integer", posvals = interval(1, inf) },
        { "flippedwell(Flipped Well)",                                 false },
        { "fingers(Number of Fingers)",                                  1, argtype = "integer", posvals = interval(1, inf) },
        { "fwidth(Finger Width)",                                      tech.get_dimension("Minimum Gate Width"), argtype = "integer", posvals = even() },
        { "gatelength(Gate Length)",                                   tech.get_dimension("Minimum Gate Length"), argtype = "integer", posvals = even() },
        { "gatespace(Gate Spacing)",                                   tech.get_dimension("Minimum Gate Space"), argtype = "integer", posvals = even() },
        { "actext(Active Extension)",                                     30 },
        { "specifyactext(Specify Active Extension)",                   false },
        { "sdwidth(Source/Drain Metal Width)",                         tech.get_dimension("Minimum M1 Width"), argtype = "integer", posvals = even() },
        { "gtopext(Gate Top Extension)",                               tech.get_dimension("Minimum Gate Extension") },
        { "gbotext(Gate Bottom Extension)",                            tech.get_dimension("Minimum Gate Extension") },
        { "cliptop(Clip Top Marker Layers)",                           false },
        { "clipbot(Clip Bottom Marker Layers)",                        false },
        { "drawtopgate(Draw Top Gate Contact)",                        false },
        { "topgatecompsd(Compensate for Source/Drain Connection)",      true },
        { "drawtopgatestrap(Draw Top Gate Strap)",                     false, follow = "drawtopgate" },
        { "topgatestrwidth(Top Gate Strap Width)",                     tech.get_dimension("Minimum M1 Width"), argtype = "integer", posvals = even() },
        { "topgatestrspace(Top Gate Strap Space)",                     tech.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "topgatemetal(Top Gate Strap Metal)",                            1 },
        { "topgateextendhalfspace(Top Gate Strap Extend Half Space)",  false },
        { "drawbotgate(Draw Bottom Gate Contact)",                     false },
        { "drawbotgatestrap(Draw Bot Gate Strap)",                     false, follow = "drawbotgate" },
        { "botgatecompsd(Compensate for Source/Drain Connection)",      true },
        { "botgatestrwidth(Bottom Gate Strap Width)",                  tech.get_dimension("Minimum M1 Width"), argtype = "integer", posvals = even() },
        { "botgatestrspace(Bottom Gate Strap Space)",                  tech.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "botgatemetal(Bottom Gate Strap Metal)",                         1 },
        { "botgateextendhalfspace(Bottom Gate Strap Extend Half Space)",  false },
        { "drawtopgcut(Draw Top Gate Cut)",                            false },
        { "drawbotgcut(Draw Bottom Gate Cut)",                         false },
        { "topgcutoffset(Top Gate Cut Y Offset)",                          0 },
        { "botgcutoffset(Bottom Gate Cut Y Offset)",                       0 },
        { "cutheight",                                                  60, posvals = even() },
        { "drawsourcedrain(Draw Source/Drain Contacts)",              "both", posvals = set("both", "source", "drain", "none") },
        { "sourcesize(Source Size)",                                  tech.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fwidth" },
        { "drainsize(Drain Size)",                                    tech.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fwidth" },
        { "sourcealign(Source Alignement)",                          "bottom", posvals = set("top", "bottom") },
        { "drainalign(Drain Alignement)",                            "top", posvals = set("top", "bottom") },
        { "drawsourcevia(Draw Source Via)",                            false },
        { "connectsource(Connect Source)",                             false },
        { "connsourcewidth(Source Rails Metal Width)",               tech.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connsourcespace(Source Rails Metal Space)",               tech.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connsourcemetal(Source Connection Metal)",                      1 },
        { "connsourceinline(Connect Source Inline of Transistor)",     false },
        { "connectsourceinverse(Invert Source Strap Locations)",       false },
        { "connectdrain(Connect Drain)",                               false },
        { "conndrainwidth(Drain Rails Metal Width)",               tech.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "conndrainspace(Drain Rails Metal Space)",               tech.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "extendsourceconnection(Extend Source Connection)",          false },
        { "extenddrainconnection(Extend Drain Connection)",            false },
        { "connectdraininverse(Invert Drain Strap Locations)",         false },
        { "drawdrainvia(Draw Drain Via)",                              false },
        { "conndrainmetal(Drain Connection Metal)",                        1 },
        { "conndraininline(Connect Drain Inline of Transistor)",       false },
        { "drawtopactivedummy",                                        false },
        { "topactivedummywidth",                                          80 },
        { "topactivedummysep",                                            80 },
        { "drawbotactivedummy",                                        false },
        { "botactivedummywidth",                                          80 },
        { "botactivedummysep",                                            80 },
        { "drawactive",                                                 true },
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
        { "drawtopwelltap",                                            false },
        { "topwelltapwidth",                                           tech.get_dimension("Minimum M1 Width") },
        { "topwelltapspace",                                           tech.get_dimension("Minimum M1 Space") },
        { "topwelltapextendleft",                                          0 },
        { "topwelltapextendright",                                         0 },
        { "drawbotwelltap",                                            false },
        { "botwelltapwidth",                                           tech.get_dimension("Minimum M1 Width") },
        { "botwelltapspace",                                           tech.get_dimension("Minimum M1 Space") },
        { "botwelltapextendleft",                                          0 },
        { "botwelltapextendright",                                         0 },
        { "drawleftstopgate",                                              false },
        { "drawrightstopgate",                                             false },
        { "drawstopgatetopgcut",                                           false },
        { "drawstopgatebotgcut",                                           false },
        { "numleftpolylines",                                              0 },
        { "numrightpolylines",                                             0 }
    )
end

function layout(transistor, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    local activewidth = _P.specifyactext and 
        _P.fingers * gatepitch + _P.sdwidth + 2 * _P.actext
        or
        (_P.fingers + 1) * gatepitch

    local virtualactiveleftext = enable(_P.drawleftstopgate, gatepitch) + _P.numleftpolylines * gatepitch
    local virtualactiverightext = enable(_P.drawrightstopgate, gatepitch) + _P.numrightpolylines * gatepitch

    local topgateshift = enable(_P.drawtopgate, _P.topgatestrspace + _P.topgatestrwidth)
    local botgateshift = enable(_P.drawbotgate, _P.botgatestrspace + _P.botgatestrwidth)
    local gateaddtop = math.max(_P.gtopext, topgateshift)
    local gateaddbot = math.max(_P.gbotext, botgateshift)

    local drainshift = enable(_P.connectdrain, _P.conndrainwidth + _P.conndrainspace)
    local sourceshift = enable(_P.connectsource, _P.connsourcewidth + _P.connsourcespace)
    if _P.channeltype == "pmos" then
        drainshift, sourceshift = sourceshift, drainshift
    end

    local hasgatecut = tech.has_layer(generics.other("gatecut"))

    local cutext = _P.gatespace / 2
    local cutwidth = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + 2 * cutext
    -- FIXME: this is probably wrong if connectsourceinverse or connectdraininverse is used
    local topgatecompsd = _P.topgatecompsd and not ((_P.channeltype == "nmos") and _P.conndraininline or _P.connsourceinline)
    local botgatecompsd = _P.botgatecompsd and not ((_P.channeltype == "nmos") and _P.connsourceinline or _P.conndraininline)
    if hasgatecut then
        -- gates
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(-_P.gatelength / 2, -_P.fwidth / 2 - gateaddbot - enable(_P.drawbotgate and botgatecompsd, sourceshift)),
            point.create( _P.gatelength / 2,  _P.fwidth / 2 + gateaddtop + enable(_P.drawtopgate and topgatecompsd, drainshift)),
            _P.fingers, 1, gatepitch, 0
        )

        -- gate cut
        if _P.drawtopgcut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(-cutwidth / 2, _P.fwidth / 2 + gateaddtop - _P.cutheight / 2 + _P.topgcutoffset),
                point.create( cutwidth / 2, _P.fwidth / 2 + gateaddtop + _P.cutheight / 2 + _P.topgcutoffset)
            )
        end
        if _P.drawbotgcut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(-cutwidth / 2, -_P.fwidth / 2 - gateaddbot - _P.cutheight / 2 + _P.botgcutoffset),
                point.create( cutwidth / 2, -_P.fwidth / 2 - gateaddbot + _P.cutheight / 2 + _P.botgcutoffset)
            )
        end
    else -- not hasgatecut
        local lowerpt  = point.create(-_P.gatelength / 2, -_P.fwidth / 2 - gateaddbot - enable(_P.drawbotgate and botgatecompsd, sourceshift))
        local higherpt = point.create( _P.gatelength / 2,  _P.fwidth / 2 + gateaddtop + enable(_P.drawtopgate and topgatecompsd, drainshift))
        if _P.drawtopgcut then
            higherpt:translate(0, -enable(_P.drawtopgate and topgatecompsd, drainshift) - _P.cutheight / 2 + _P.topgcutoffset)
        end
        if _P.drawbotgcut then
            lowerpt:translate(0, enable(_P.drawbotgate and _P.botgatecompsd and not _P.connsourceinline, sourceshift) + _P.cutheight / 2 - _P.botgcutoffset)
        end
        -- gates
        geometry.rectanglebltr(transistor, 
            generics.other("gate"),
            lowerpt, higherpt,
            _P.fingers, 1, gatepitch, 0
        )
    end
    -- gate marker
    geometry.rectanglebltr(transistor,
        generics.other(string.format("gatemarker%d", _P.gatemarker)),
        point.create(-_P.gatelength / 2, -_P.fwidth / 2),
        point.create( _P.gatelength / 2,  _P.fwidth / 2),
        _P.fingers, 1, gatepitch, 0
    )
    
    -- left and right polylines
    for i = 1, _P.numleftpolylines do
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(-_P.gatelength / 2 - (_P.fingers + 1 + 2 * i) / 2 * gatepitch, -_P.fwidth / 2 - gateaddbot - enable(_P.drawbotgate, sourceshift)),
            point.create( _P.gatelength / 2 - (_P.fingers + 1 + 2 * i) / 2 * gatepitch,  _P.fwidth / 2 + gateaddtop + enable(_P.drawtopgate, drainshift))
        )
    end
    for i = 1, _P.numrightpolylines do
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(-_P.gatelength / 2 + (_P.fingers + 1 + 2 * i) / 2 * gatepitch, -_P.fwidth / 2 - gateaddbot - enable(_P.drawbotgate, sourceshift)),
            point.create( _P.gatelength / 2 + (_P.fingers + 1 + 2 * i) / 2 * gatepitch,  _P.fwidth / 2 + gateaddtop + enable(_P.drawtopgate, drainshift))
        )
    end

    -- stop gates
    if _P.drawleftstopgate then
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(-_P.gatelength / 2 - (_P.fingers + 1) / 2 * gatepitch, -_P.fwidth / 2 - gateaddbot - enable(_P.drawbotgate, sourceshift)),
            point.create( _P.gatelength / 2 - (_P.fingers + 1) / 2 * gatepitch,  _P.fwidth / 2 + gateaddtop + enable(_P.drawtopgate, drainshift))
        )
        geometry.rectanglebltr(transistor,
            generics.other("diffusionbreakgate"),
            point.create(-_P.gatelength / 2 - (_P.fingers + 1) / 2 * gatepitch, -_P.fwidth / 2 - gateaddbot - enable(_P.drawbotgate, sourceshift)),
            point.create( _P.gatelength / 2 - (_P.fingers + 1) / 2 * gatepitch,  _P.fwidth / 2 + gateaddtop + enable(_P.drawtopgate, drainshift))
        )
        -- gate cut
        if _P.drawstopgatetopgcut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(-cutwidth / 2 - (_P.fingers + 1) / 2 * gatepitch, _P.fwidth / 2 + gateaddtop - _P.cutheight / 2 + _P.topgcutoffset),
                point.create( cutwidth / 2 - (_P.fingers + 1) / 2 * gatepitch, _P.fwidth / 2 + gateaddtop + _P.cutheight / 2 + _P.topgcutoffset)
            )
        end
        if _P.drawstopgatebotgcut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(-cutwidth / 2 - (_P.fingers + 1) / 2 * gatepitch, -_P.fwidth / 2 - gateaddbot - _P.cutheight / 2 + _P.botgcutoffset),
                point.create( cutwidth / 2 - (_P.fingers + 1) / 2 * gatepitch, -_P.fwidth / 2 - gateaddbot + _P.cutheight / 2 + _P.botgcutoffset)
            )
        end
    end
    if _P.drawrightstopgate then
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(-_P.gatelength / 2 + (_P.fingers + 1) / 2 * gatepitch, -_P.fwidth / 2 - gateaddbot - enable(_P.drawbotgate, sourceshift)),
            point.create( _P.gatelength / 2 + (_P.fingers + 1) / 2 * gatepitch,  _P.fwidth / 2 + gateaddtop + enable(_P.drawtopgate, drainshift))
        )
        geometry.rectanglebltr(transistor,
            generics.other("diffusionbreakgate"),
            point.create(-_P.gatelength / 2 + (_P.fingers + 1) / 2 * gatepitch, -_P.fwidth / 2 - gateaddbot - enable(_P.drawbotgate, sourceshift)),
            point.create( _P.gatelength / 2 + (_P.fingers + 1) / 2 * gatepitch,  _P.fwidth / 2 + gateaddtop + enable(_P.drawtopgate, drainshift))
        )
        -- gate cut
        if _P.drawstopgatetopgcut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(-cutwidth / 2 + (_P.fingers + 1) / 2 * gatepitch, _P.fwidth / 2 + gateaddtop - _P.cutheight / 2 + _P.topgcutoffset),
                point.create( cutwidth / 2 + (_P.fingers + 1) / 2 * gatepitch, _P.fwidth / 2 + gateaddtop + _P.cutheight / 2 + _P.topgcutoffset)
            )
        end
        if _P.drawstopgatebotgcut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(-cutwidth / 2 + (_P.fingers + 1) / 2 * gatepitch, -_P.fwidth / 2 - gateaddbot - _P.cutheight / 2 + _P.botgcutoffset),
                point.create( cutwidth / 2 + (_P.fingers + 1) / 2 * gatepitch, -_P.fwidth / 2 - gateaddbot + _P.cutheight / 2 + _P.botgcutoffset)
            )
        end
    end

    -- active
    if _P.drawactive then
        geometry.rectangle(transistor, generics.other("active"), activewidth, _P.fwidth)
        if _P.drawtopactivedummy then
            geometry.rectanglebltr(transistor, generics.other("active"), 
                point.create(-activewidth / 2,                           _P.fwidth / 2 + _P.topactivedummysep),
                point.create( activewidth / 2,  _P.topactivedummywidth + _P.fwidth / 2 + _P.topactivedummysep)
            )
        end
        if _P.drawbotactivedummy then
            geometry.rectanglebltr(transistor, generics.other("active"), 
                point.create(-activewidth / 2, -_P.botactivedummywidth -_P.fwidth / 2 - _P.botactivedummysep),
                point.create( activewidth / 2,  -_P.fwidth / 2 - _P.botactivedummysep)
            )
        end
    end

    -- threshold voltage
    geometry.rectanglebltr(transistor,
        generics.vthtype(_P.channeltype, _P.vthtype),
        point.create(-activewidth / 2 - virtualactiveleftext  - _P.extendvthleft, -_P.fwidth / 2 - gateaddbot - enable(not _P.clipbot, _P.extendvthbot)),
        point.create( activewidth / 2 + virtualactiverightext + _P.extendvthright, _P.fwidth / 2 + gateaddtop + enable(not _P.cliptop, _P.extendvthtop))
    )

    -- implant
    geometry.rectanglebltr(transistor,
        generics.implant(_P.channeltype),
        point.create(-activewidth / 2 - virtualactiveleftext  - _P.extendimplantleft, -_P.fwidth / 2 - gateaddbot - enable(not _P.clipbot, _P.extendimplantbot)),
        point.create( activewidth / 2 + virtualactiverightext + _P.extendimplantright, _P.fwidth / 2 + gateaddtop + enable(not _P.cliptop, _P.extendimplanttop))
    )

    -- well
    geometry.rectanglebltr(transistor,
        generics.other(_P.flippedwell and
            (_P.channeltype == "nmos" and "nwell" or "pwell") or
            (_P.channeltype == "nmos" and "pwell" or "nwell")
        ),
        point.create(
            -activewidth / 2 - virtualactiveleftext - _P.extendwellleft,
            -_P.fwidth / 2 - math.max(gateaddbot, enable(_P.drawbotwelltap, _P.botwelltapspace + _P.botwelltapwidth))- sourceshift - _P.extendwellbot
        ),
        point.create(
            activewidth / 2 + virtualactiverightext + _P.extendwellright,
            _P.fwidth / 2 + math.max(gateaddtop, enable(_P.drawtopwelltap, _P.topwelltapspace + _P.topwelltapwidth)) + drainshift + _P.extendwelltop
        )
    )
    -- well taps
    if _P.drawtopwelltap then
        geometry.contact(transistor,
            "active",
            activewidth + _P.topwelltapextendleft + _P.topwelltapextendright,
            _P.topwelltapwidth,
            -- shifts
            (_P.topwelltapextendright - _P.topwelltapextendleft) / 2,
            _P.fwidth / 2 + drainshift + topgateshift + _P.topwelltapspace + _P.topwelltapwidth / 2,
            1, 1, 0, 0,
            { xcontinuous = true }
        )
    end
    if _P.drawbotwelltap then
        geometry.contact(transistor,
            "active",
            activewidth + _P.botwelltapextendleft + _P.botwelltapextendright,
            _P.botwelltapwidth,
            -- shifts
            (_P.botwelltapextendright - _P.botwelltapextendleft) / 2,
            -_P.fwidth / 2 - sourceshift - botgateshift - _P.botwelltapspace - _P.botwelltapwidth / 2,
            1, 1, 0, 0,
            { xcontinuous = true }
        )
    end

    -- oxide thickness
    geometry.rectanglebltr(transistor,
        generics.oxide(_P.oxidetype),
        point.create(-activewidth / 2 - _P.extendoxideleft, -_P.fwidth / 2 - gateaddbot - enable(_P.clipbot, _P.extendoxidebot)),
        point.create( activewidth / 2 + _P.extendoxideright, _P.fwidth / 2 + gateaddtop + enable(_P.cliptop, _P.extendoxidetop))
    )

    -- gate contacts
    if _P.drawtopgate then
        geometry.contactbltr(transistor, "gate", 
            point.create(-_P.gatelength / 2,                      _P.fwidth / 2 + _P.topgatestrspace + enable(topgatecompsd, drainshift)),
            point.create( _P.gatelength / 2, _P.topgatestrwidth + _P.fwidth / 2 + _P.topgatestrspace + enable(topgatecompsd, drainshift)),
            _P.fingers, 1, gatepitch, 0
        )
        for i = 1, _P.fingers do
            transistor:add_anchor_area(string.format("topgate%d", i), 
                _P.gatelength,
                _P.topgatestrwidth,
                (i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2,
                _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2 + enable(topgatecompsd, drainshift)
            )
        end
    end
    if _P.drawtopgatestrap then
        local extend = _P.topgateextendhalfspace and _P.gatespace or 0
        local width = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend
        local height = _P.topgatestrwidth
        local xshift = 0
        local yshift = _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2 + enable(topgatecompsd, drainshift)
        geometry.rectangle(transistor, generics.metal(1), width, height, xshift, yshift)
        transistor:add_anchor_area("topgatestrap", width, height, xshift, yshift)
        if _P.topgatemetal > 1 then
            geometry.via(transistor, 1, _P.topgatemetal, width, height, xshift, yshift)
        end
    end
    if _P.drawbotgate then
        geometry.contactbltr(transistor, "gate", 
            point.create(-_P.gatelength / 2, -_P.botgatestrwidth - _P.fwidth / 2 - _P.botgatestrspace - enable(botgatecompsd, sourceshift)),
            point.create( _P.gatelength / 2,                     - _P.fwidth / 2 - _P.botgatestrspace - enable(botgatecompsd, sourceshift)),
            _P.fingers, 1, gatepitch, 0
        )
        for i = 1, _P.fingers do
            transistor:add_anchor_area(string.format("botgate%d", i), 
                _P.gatelength,
                _P.botgatestrwidth,
                (i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2,
                -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2 - enable(botgatecompsd, sourceshift)
            )
        end
    end
    if _P.drawbotgatestrap then
        local extend = _P.botgateextendhalfspace and _P.gatespace or 0
        local width = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace
        local height = _P.botgatestrwidth
        local xshift = 0
        local yshift = -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2 - enable(botgatecompsd, sourceshift)
        geometry.rectangle(transistor, generics.metal(1), width, height, xshift, yshift)
        transistor:add_anchor_area("botgatestrap", width, height, xshift, yshift)
        if _P.botgatemetal > 1 then
            geometry.via(transistor, 1, _P.botgatemetal, width, height, xshift, yshift)
        end
    end

    -- source/drain contacts and vias
    local sourceoffset = 0
    if _P.sourcealign == "top" then
        sourceoffset = (_P.fwidth - _P.sourcesize) / 2
    elseif _P.sourcealign == "bottom" then
        sourceoffset = (-_P.fwidth + _P.sourcesize) / 2
    end
    local drainoffset = 0
    if _P.drainalign == "top" then
        drainoffset = (_P.fwidth - _P.drainsize) / 2
    elseif _P.drainalign == "bottom" then
        drainoffset = (-_P.fwidth + _P.drainsize) / 2
    end
    local shift = _P.fingers % 2 == 1 and gatepitch / 2 or 0
    if _P.drawsourcedrain ~= "none" then
        -- source
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "source" then
            geometry.contact(transistor,
                "sourcedrain", 
                _P.sdwidth, _P.sourcesize,
                shift, sourceoffset,
                math.floor(_P.fingers / 2) + 1, 1, 2 * gatepitch, 0
            )
            if _P.drawsourcevia and _P.connsourcemetal > 1 then
                geometry.via(transistor,
                    1, _P.connsourcemetal,
                    _P.sdwidth, _P.sourcesize,
                    shift, sourceoffset,
                    math.floor(_P.fingers / 2) + 1, 1, 2 * gatepitch, 0
                )
            end
            -- anchors
            for i = 1, 2 * (math.floor(_P.fingers / 2) + 1), 2 do
                transistor:add_anchor_area(string.format("sourcedrain%d", i), 
                    _P.sdwidth,
                    _P.sourcesize,
                    2 * shift + (-_P.fingers / 2 + (i - 1)) * gatepitch,
                    sourceoffset
                )
            end
        end
        -- drain
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "drain" then
            geometry.contact(transistor,
                "sourcedrain", 
                _P.sdwidth, _P.drainsize,
                -shift, drainoffset,
                math.floor((_P.fingers - 1) / 2) + 1, 1, 2 * gatepitch, 0
            )
            if _P.drawdrainvia and _P.conndrainmetal > 1 then
                geometry.via(transistor,
                    1, _P.conndrainmetal,
                    _P.sdwidth, _P.drainsize,
                    -shift, drainoffset,
                    math.floor((_P.fingers - 1) / 2) + 1, 1, 2 * gatepitch, 0
                )
            end
            -- anchors
            for i = 2, 2 * (math.floor((_P.fingers - 1) / 2) + 1), 2 do
                transistor:add_anchor_area(string.format("sourcedrain%d", i), 
                    _P.sdwidth,
                    _P.drainsize,
                    -2 * shift + (-_P.fingers / 2 + (i - 1)) * gatepitch,
                    drainoffset
                )
            end
        end
    end

    -- source/drain connections
    local ysign = (_P.channeltype == "nmos" and -1 or 1)
    if _P.connectsource then
        local invert = _P.connectsourceinverse and -1 or 1
        if _P.connsourceinline then
            geometry.rectangle(transistor, generics.metal(_P.connsourcemetal),
                _P.fingers * gatepitch + _P.sdwidth, _P.connsourcewidth
            )
        else
            -- FIXME: extendsourceconnection is not perfect, it draws too much
            local width = (2 * math.floor(_P.fingers / 2) + (_P.extendsourceconnection and 1 or 0)) * gatepitch + _P.sdwidth
            local height = _P.connsourcewidth
            local yoffset = invert * ysign * (_P.fwidth + _P.connsourcewidth + 2 * _P.connsourcespace) / 2
            geometry.rectangle(transistor, generics.metal(_P.connsourcemetal),
                width, height,
                shift, yoffset
            )
            geometry.rectanglepoints(transistor, generics.metal(_P.connsourcemetal), 
                point.create(shift - _P.sdwidth / 2, invert * ysign * _P.fwidth / 2),
                point.create(shift + _P.sdwidth / 2, invert * ysign * (_P.fwidth / 2 + _P.connsourcespace)),
                math.floor(_P.fingers / 2) + 1, 1, 2 * gatepitch, 0
            )
            -- anchors
            transistor:add_anchor_area("sourcestrap", 
                width, height,
                shift, yoffset
            )
        end
    end
    if _P.connectdrain then
        local invert = _P.connectdraininverse and -1 or 1
        if _P.conndraininline then
            geometry.rectangle(transistor, generics.metal(_P.conndrainmetal),
                (_P.fingers - 2) * gatepitch + _P.sdwidth, _P.conndrainwidth
            )
        else
            -- FIXME: extenddrainconnection is not perfect, it draws too much
            local width = (2 * math.floor((_P.fingers - 1) / 2) + (_P.extenddrainconnection and 1 or 0)) * gatepitch + _P.sdwidth
            local height = _P.conndrainwidth
            local yoffset = -invert * ysign * (_P.fwidth + _P.conndrainwidth + 2 * _P.conndrainspace) / 2
            geometry.rectangle(transistor, generics.metal(_P.conndrainmetal),
                width, height,
                -shift, yoffset
            )
            geometry.rectanglepoints(transistor, generics.metal(_P.conndrainmetal), 
                point.create(-shift - _P.sdwidth / 2, -invert * ysign * _P.fwidth / 2),
                point.create(-shift + _P.sdwidth / 2, -invert * ysign * (_P.fwidth / 2 + _P.conndrainspace)),
                math.floor((_P.fingers - 1) / 2) + 1, 1, 2 * gatepitch, 0
            )
            -- anchors
            transistor:add_anchor_area("drainstrap", 
                (math.floor((_P.fingers - 1) / 2) + 1) * gatepitch + _P.sdwidth,
                _P.conndrainwidth,
                -shift, yoffset
            )
        end
    end

    -- anchors for source drain active regions
    for i = 1, _P.fingers + 1 do
        transistor:add_anchor_area(string.format("sourcedrainactive%d", i), 
            _P.sdwidth, _P.fwidth,
            -shift + (-math.floor(_P.fingers / 2) + (i - 1)) * gatepitch, 0
        )
    end

    -- alignmentbox (FIXME, perhaps a simpler one is better)
    local y1 =  _P.fwidth / 2 + math.max(_P.gtopext, enable(_P.drawtopgate, _P.topgatestrspace + _P.topgatestrwidth / 2))
    local y2 = -_P.fwidth / 2 - math.max(_P.gbotext, enable(_P.drawbotgate, _P.botgatestrspace + _P.botgatestrwidth / 2))
    if _P.connectsource and not _P.connsourceinline then
        y1 = ysign * (_P.fwidth + _P.connsourcewidth + 2 * _P.connsourcespace) / 2
    end
    if _P.connectdrain and not _P.conndraininline then
        y2 = -ysign * (_P.fwidth + _P.conndrainwidth + 2 * _P.conndrainspace) / 2
    end
    transistor:set_alignment_box(
        point.create(
            -_P.fingers / 2 * gatepitch, 
            math.min(y1, y2)
        ),
        point.create( 
            _P.fingers / 2 * gatepitch, 
            math.max(y1, y2)
        )
    )

    transistor:add_anchor("sourcedrainleftll", transistor:get_anchor("sourcedrainactive1ll"))
    transistor:add_anchor("sourcedrainleftcl", transistor:get_anchor("sourcedrainactive1cl"))
    transistor:add_anchor("sourcedrainleftul", transistor:get_anchor("sourcedrainactive1ul"))
    transistor:add_anchor("sourcedrainleftlc", transistor:get_anchor("sourcedrainactive1lc"))
    transistor:add_anchor("sourcedrainleftcc", transistor:get_anchor("sourcedrainactive1cc"))
    transistor:add_anchor("sourcedrainleftuc", transistor:get_anchor("sourcedrainactive1uc"))
    transistor:add_anchor("sourcedrainleftlr", transistor:get_anchor("sourcedrainactive1lr"))
    transistor:add_anchor("sourcedrainleftcr", transistor:get_anchor("sourcedrainactive1cr"))
    transistor:add_anchor("sourcedrainleftur", transistor:get_anchor("sourcedrainactive1ur"))

    transistor:add_anchor("sourcedrainrightll", transistor:get_anchor(string.format("sourcedrainactive%dll", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainrightcl", transistor:get_anchor(string.format("sourcedrainactive%dcl", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainrightul", transistor:get_anchor(string.format("sourcedrainactive%dul", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainrightlc", transistor:get_anchor(string.format("sourcedrainactive%dlc", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainrightcc", transistor:get_anchor(string.format("sourcedrainactive%dcc", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainrightuc", transistor:get_anchor(string.format("sourcedrainactive%duc", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainrightlr", transistor:get_anchor(string.format("sourcedrainactive%dlr", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainrightcr", transistor:get_anchor(string.format("sourcedrainactive%dcr", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainrightur", transistor:get_anchor(string.format("sourcedrainactive%dur", _P.fingers + 1)))
end
