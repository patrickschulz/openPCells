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
        { "drawtopgatestrap(Draw Top Gate Strap)",                     false, follow = "drawtopgate" },
        { "topgatestrwidth(Top Gate Strap Width)",                     tech.get_dimension("Minimum M1 Width"), argtype = "integer", posvals = even() },
        { "topgatestrspace(Top Gate Strap Space)",                     tech.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "topgatemetal(Top Gate Strap Metal)",                            1 },
        { "topgateextendhalfspace(Top Gate Strap Extend Half Space)",  false },
        { "drawbotgate(Draw Bottom Gate Contact)",                     false },
        { "drawbotgatestrap(Draw Bot Gate Strap)",                     false, follow = "drawbotgate" },
        { "botgatestrwidth(Bottom Gate Strap Width)",                  tech.get_dimension("Minimum M1 Width"), argtype = "integer", posvals = even() },
        { "botgatestrspace(Bottom Gate Strap Space)",                  tech.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "botgatemetal(Bottom Gate Strap Metal)",                         1 },
        { "botgateextendhalfspace(Bottom Gate Strap Extend Half Space)",  false },
        { "drawtopgcut(Draw Top Gate Cut)",                            false },
        { "drawbotgcut(Draw Bottom Gate Cut)",                         false },
        { "topgcutoffset(Top Gate Cut Y Offset)",                          0 },
        { "botgcutoffset(Bottom Gate Cut Y Offset)",                       0 },
        { "cutheight",                                                  60, posvals = even() },
        { "drawinnersourcedrain(Draw Inner Source/Drain Contacts)", "both", posvals = set("both", "source", "drain", "none") },
        { "drawoutersourcedrain(Draw Outer Source/Drain Contacts)", "both", posvals = set("both", "source", "drain", "none") },
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
        { "connectdrain(Connect Drain)",                               false },
        { "conndrainwidth(Drain Rails Metal Width)",               tech.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "conndrainspace(Drain Rails Metal Space)",               tech.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "extenddrainconnection(Extend Drain Connection)",            false },
        { "connectinverse(Invert Source/Drain Strap Locations)",       false },
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
        { "botwelltapextendright",                                         0 }
    )
end

function layout(transistor, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    local actwidth = _P.specifyactext and 
        _P.fingers * gatepitch + _P.sdwidth + 2 * _P.actext
        or
        (_P.fingers + 1) * gatepitch

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

    if hasgatecut then
        -- gates
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(-_P.gatelength / 2, -_P.fwidth / 2 - gateaddbot - enable(_P.drawbotgate, sourceshift)),
            point.create( _P.gatelength / 2,  _P.fwidth / 2 + gateaddtop + enable(_P.drawtopgate, drainshift)),
            _P.fingers, 1, gatepitch, 0
        )

        -- gate cut
        local cutext = _P.gatespace / 2
        local cutwidth = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + 2 * cutext
        if _P.drawtopgcut then
            geometry.rectanglebltr(
                transistor,
                generics.other("gatecut"),
                point.create(-cutwidth / 2, _P.fwidth / 2 + gateaddtop - _P.cutheight / 2 - _P.topgcutoffset),
                point.create( cutwidth / 2, _P.fwidth / 2 + gateaddtop + _P.cutheight / 2 - _P.topgcutoffset)
            )
        end
        if _P.drawbotgcut then
            geometry.rectanglebltr(
                transistor,
                generics.other("gatecut"),
                point.create(-cutwidth / 2, -_P.fwidth / 2 - gateaddbot - _P.cutheight / 2 + _P.botgcutoffset),
                point.create( cutwidth / 2, -_P.fwidth / 2 - gateaddbot + _P.cutheight / 2 + _P.botgcutoffset)
            )
        end
    else -- not hasgatecut
        local lowerpt = point.create(-_P.gatelength / 2, -_P.fwidth / 2 - gateaddbot - enable(_P.drawbotgate, sourceshift))
        local higherpt = point.create( _P.gatelength / 2,  _P.fwidth / 2 + gateaddtop + enable(_P.drawtopgate, drainshift))
        if _P.drawtopgcut then
            higherpt:translate(0, -enable(_P.drawtopgate, drainshift) - _P.cutheight / 2 + _P.topgcutoffset)
        end
        if _P.drawbotgcut then
            lowerpt:translate(0, enable(_P.drawbotgate, sourceshift) + _P.cutheight / 2 - _P.botgcutoffset)
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

    -- active
    if _P.drawactive then
        geometry.rectangle(transistor, generics.other("active"), actwidth, _P.fwidth)
        if _P.drawtopactivedummy then
            geometry.rectanglebltr(transistor, generics.other("active"), 
                point.create(-actwidth / 2,                           _P.fwidth / 2 + _P.topactivedummysep),
                point.create( actwidth / 2,  _P.topactivedummywidth + _P.fwidth / 2 + _P.topactivedummysep)
            )
        end
        if _P.drawbotactivedummy then
            geometry.rectanglebltr(transistor, generics.other("active"), 
                point.create(-actwidth / 2, -_P.botactivedummywidth -_P.fwidth / 2 - _P.botactivedummysep),
                point.create( actwidth / 2,  -_P.fwidth / 2 - _P.botactivedummysep)
            )
        end
    end

    -- threshold voltage
    geometry.rectanglebltr(transistor,
        generics.vthtype(_P.channeltype, _P.vthtype),
        point.create(-actwidth / 2 - _P.extendvthleft, -_P.fwidth / 2 - gateaddbot - _P.extendvthbot),
        point.create( actwidth / 2 + _P.extendvthright, _P.fwidth / 2 + gateaddtop + _P.extendvthtop)
    )

    -- implant
    geometry.rectanglebltr(transistor,
        generics.implant(_P.channeltype),
        point.create(-actwidth / 2 - _P.extendimplantleft, -_P.fwidth / 2 - gateaddbot - _P.extendimplantbot),
        point.create( actwidth / 2 + _P.extendimplantright, _P.fwidth / 2 + gateaddtop + _P.extendimplanttop)
    )

    -- well
    geometry.rectanglebltr(transistor,
        generics.other(_P.flippedwell and
            (_P.channeltype == "nmos" and "nwell" or "pwell") or
            (_P.channeltype == "nmos" and "pwell" or "nwell")
        ),
        point.create(
            -actwidth / 2 - _P.extendwellleft,
            -_P.fwidth / 2 - math.max(gateaddbot, enable(_P.drawbotwelltap, _P.botwelltapspace + _P.botwelltapwidth))- sourceshift - _P.extendwellbot
        ),
        point.create(
            actwidth / 2 + _P.extendwellright,
            _P.fwidth / 2 + math.max(gateaddtop, enable(_P.drawtopwelltap, _P.topwelltapspace + _P.topwelltapwidth)) + drainshift + _P.extendwelltop
        )
    )
    -- well taps
    if _P.drawtopwelltap then
        geometry.contact(transistor,
            "active",
            actwidth + _P.topwelltapextendleft + _P.topwelltapextendright,
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
            actwidth + _P.botwelltapextendleft + _P.botwelltapextendright,
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
        point.create(-actwidth / 2, -_P.fwidth / 2 - gateaddbot),
        point.create( actwidth / 2,  _P.fwidth / 2 + gateaddtop)
    )

    -- gate contacts
    if _P.drawtopgate then
        geometry.contactbltr(transistor, "gate", 
            point.create(-_P.gatelength / 2,                      _P.fwidth / 2 + _P.topgatestrspace + drainshift),
            point.create( _P.gatelength / 2, _P.topgatestrwidth + _P.fwidth / 2 + _P.topgatestrspace + drainshift),
            _P.fingers, 1, gatepitch, 0
        )
    end
    if _P.drawtopgatestrap then
        local extend = _P.topgateextendhalfspace and _P.gatespace or 0
        geometry.rectanglebltr(
            transistor,
            generics.metal(1), 
            point.create(-(_P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend) / 2, drainshift + _P.fwidth / 2 + _P.topgatestrspace),
            point.create( (_P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend) / 2, drainshift + _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth)
        )
        if _P.topgatemetal > 1 then
            geometry.viabltr(
                transistor,
                1, _P.topgatemetal, 
                point.create(-(_P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend) / 2, drainshift + _P.fwidth / 2 + _P.topgatestrspace),
                point.create( (_P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend) / 2, drainshift + _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth)
            )
        end
    end
    if _P.drawbotgate then
        geometry.contactbltr(transistor, "gate", 
            point.create(-_P.gatelength / 2, -_P.botgatestrwidth - _P.fwidth / 2 - _P.botgatestrspace),
            point.create( _P.gatelength / 2,                     - _P.fwidth / 2 - _P.botgatestrspace),
            _P.fingers, 1, gatepitch, 0
        )
    end
    if _P.drawbotgatestrap then
        local extend = _P.botgateextendhalfspace and _P.gatespace or 0
        geometry.rectanglebltr(
            transistor,
            generics.metal(1), 
            point.create(-(_P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend) / 2, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth),
            point.create( (_P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend) / 2, -_P.fwidth / 2 - _P.botgatestrspace)
        )
        if _P.botgatemetal > 1 then
            geometry.viabltr(
                transistor,
                1, _P.botgatemetal, 
                point.create(-(_P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend) / 2, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth),
                point.create( (_P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend) / 2, -_P.fwidth / 2 - _P.botgatestrspace)
            )
        end
    end

    -- source/drain contacts and vias
    local sourcesubtop, sourcesubbot = 0, 0
    if _P.sourcealign == "top" then
        sourcesubbot = _P.fwidth - _P.sourcesize
    elseif _P.sourcealign == "bottom" then
        sourcesubtop = _P.fwidth - _P.sourcesize
    end
    local drainsubtop, drainsubbot = 0, 0
    if _P.drainalign == "top" then
        drainsubbot = _P.fwidth - _P.drainsize
    elseif _P.drainalign == "bottom" then
        drainsubtop = _P.fwidth - _P.drainsize
    end
    local shift = _P.fingers % 2 == 1 and gatepitch / 2 or 0
    -- drain/source contacts
    if _P.drawinnersourcedrain ~= "none" and _P.fingers > 1 then -- inner contacts
        -- source
        if _P.drawinnersourcedrain == "both" or _P.drawinnersourcedrain == "source" then
            geometry.contactbltr(
                transistor,
                "sourcedrain", 
                point.create(shift - _P.sdwidth / 2, -_P.fwidth / 2 + sourcesubbot),
                point.create(shift + _P.sdwidth / 2,  _P.fwidth / 2 - sourcesubtop),
                math.floor((_P.fingers - 1) / 2), 1, 2 * gatepitch, 0
            )
            if _P.drawsourcevia and _P.connsourcemetal > 1 then
                geometry.viabltr(
                    transistor,
                    1, _P.connsourcemetal,
                    point.create(shift - _P.sdwidth / 2, -_P.fwidth / 2 + sourcesubbot),
                    point.create(shift + _P.sdwidth / 2,  _P.fwidth / 2 - sourcesubtop),
                    math.floor((_P.fingers - 1) / 2), 1, 2 * gatepitch, 0
                )
            end
        end
        -- drain
        if _P.drawinnersourcedrain == "both" or _P.drawinnersourcedrain == "drain" then
            geometry.contactbltr(
                transistor,
                "sourcedrain", 
                point.create(-shift - _P.sdwidth / 2, -_P.fwidth / 2 + drainsubbot),
                point.create(-shift + _P.sdwidth / 2,  _P.fwidth / 2 - drainsubtop),
                math.floor(_P.fingers / 2), 1, 2 * gatepitch, 0
            )
            if _P.drawdrainvia and _P.conndrainmetal > 1 then
                geometry.viabltr(
                    transistor,
                    1, _P.conndrainmetal, 
                    point.create(-shift - _P.sdwidth / 2, -_P.fwidth / 2 + drainsubbot),
                    point.create(-shift + _P.sdwidth / 2,  _P.fwidth / 2 - drainsubtop),
                    math.floor(_P.fingers / 2), 1, 2 * gatepitch, 0
                )
            end
        end
    end
    if _P.drawoutersourcedrain ~= "none" then
        -- left (source)
        if _P.drawoutersourcedrain == "both" or _P.drawoutersourcedrain == "source" then
            geometry.contactbltr(
                transistor,
                "sourcedrain",
                point.create(-_P.sdwidth / 2 - math.floor(_P.fingers / 2) * gatepitch - shift, -_P.fwidth / 2 + sourcesubbot),
                point.create( _P.sdwidth / 2 - math.floor(_P.fingers / 2) * gatepitch - shift,  _P.fwidth / 2 - sourcesubtop)
            )
            if _P.drawsourcevia and _P.connsourcemetal > 1 then
                geometry.viabltr(
                    transistor,
                    1, _P.connsourcemetal,
                    point.create(-_P.sdwidth / 2 - math.floor(_P.fingers / 2) * gatepitch - shift, -_P.fwidth / 2 + sourcesubbot),
                    point.create( _P.sdwidth / 2 - math.floor(_P.fingers / 2) * gatepitch - shift,  _P.fwidth / 2 - sourcesubtop)
                )
            end
        end
        -- right (source or drain)
        if _P.fingers % 2 == 0 then -- source
            if _P.drawoutersourcedrain == "both" or _P.drawoutersourcedrain == "source" then
                geometry.contactbltr(
                    transistor,
                    "sourcedrain",
                    point.create(-_P.sdwidth / 2 + math.floor(_P.fingers / 2) * gatepitch + shift, -_P.fwidth / 2 + sourcesubbot),
                    point.create( _P.sdwidth / 2 + math.floor(_P.fingers / 2) * gatepitch + shift,  _P.fwidth / 2 - sourcesubtop)
                )
                if _P.drawsourcevia and _P.connsourcemetal > 1 then
                    geometry.viabltr(
                        transistor,
                        1, _P.connsourcemetal,
                        point.create(-_P.sdwidth / 2 + math.floor(_P.fingers / 2) * gatepitch + shift, -_P.fwidth / 2 + sourcesubbot),
                        point.create( _P.sdwidth / 2 + math.floor(_P.fingers / 2) * gatepitch + shift,  _P.fwidth / 2 - sourcesubtop)
                    )
                end
            end
        else -- drain
            if _P.drawoutersourcedrain == "both" or _P.drawoutersourcedrain == "drain" then
                geometry.contactbltr(
                    transistor,
                    "sourcedrain",
                    point.create(-_P.sdwidth / 2 + math.floor(_P.fingers / 2) * gatepitch + shift, -_P.fwidth / 2 + drainsubbot),
                    point.create( _P.sdwidth / 2 + math.floor(_P.fingers / 2) * gatepitch + shift,  _P.fwidth / 2 - drainsubtop)
                )
                if _P.drawdrainvia and _P.conndrainmetal > 1 then
                    geometry.viabltr(
                        transistor,
                        1, _P.conndrainmetal,
                        point.create(-_P.sdwidth / 2 + math.floor(_P.fingers / 2) * gatepitch + shift, -_P.fwidth / 2 + drainsubbot),
                        point.create( _P.sdwidth / 2 + math.floor(_P.fingers / 2) * gatepitch + shift,  _P.fwidth / 2 - drainsubtop)
                    )
                end
            end
        end
    end

    -- source/drain connections
    local ysign = (_P.channeltype == "nmos" and -1 or 1) * (_P.connectinverse and -1 or 1)
    if _P.connectsource then
        if _P.connsourceinline then
            geometry.rectangle(
                transistor, generics.metal(_P.connsourcemetal),
                _P.fingers * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.connsourcewidth
            )
        else
            geometry.rectangle(
                transistor, generics.metal(_P.connsourcemetal),
                _P.fingers * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.connsourcewidth,
                0, ysign * (_P.fwidth + _P.connsourcewidth + 2 * _P.connsourcespace) / 2
            )
            geometry.rectanglepoints(
                transistor, generics.metal(_P.connsourcemetal), 
                point.create(-_P.sdwidth / 2, ysign * _P.fwidth / 2),
                point.create( _P.sdwidth / 2, ysign * (_P.fwidth / 2 + _P.connsourcespace)),
                math.floor(0.5 * _P.fingers) + 1, 1, 2 * (_P.gatelength + _P.gatespace), 0
            )
        end
    end
    if _P.connectdrain then
        if _P.conndraininline then
            geometry.rectangle(
                transistor, generics.metal(_P.conndrainmetal),
                (_P.fingers - 2) * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.conndrainwidth
            )
        else
            local diff = _P.extenddrainconnection and 0 or 2
            geometry.rectangle(
                transistor, generics.metal(_P.conndrainmetal),
                (_P.fingers - diff) * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.conndrainwidth,
                0, -ysign * (_P.fwidth + _P.conndrainwidth + 2 * _P.conndrainspace) / 2
            )
            geometry.rectanglepoints(
                transistor, generics.metal(_P.conndrainmetal), 
                point.create(-_P.sdwidth / 2, -ysign * _P.fwidth / 2),
                point.create( _P.sdwidth / 2, -ysign * (_P.fwidth / 2 + _P.conndrainspace)),
                math.floor(0.5 * _P.fingers), 1, 2 * (_P.gatelength + _P.gatespace), 0
            )
        end
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
            -_P.fingers / 2 * (_P.gatelength + _P.gatespace), 
            math.min(y1, y2)
        ),
        point.create( 
            _P.fingers / 2 * (_P.gatelength + _P.gatespace), 
            math.max(y1, y2)
        )
    )

    -- anchors
    -- source/drain regions
    for i = 1, _P.fingers + 1 do
        transistor:add_anchor(string.format("sourcedrainlowerleft%d", i), 
            point.create((-_P.fingers / 2 + (i - 1)) * (_P.gatelength + _P.gatespace) - _P.sdwidth / 2, -_P.fwidth / 2))
        transistor:add_anchor(string.format("sourcedrainmiddleleft%d", i), 
            point.create((-_P.fingers / 2 + (i - 1)) * (_P.gatelength + _P.gatespace) - _P.sdwidth / 2, 0))
        transistor:add_anchor(string.format("sourcedrainupperleft%d", i), 
            point.create((-_P.fingers / 2 + (i - 1)) * (_P.gatelength + _P.gatespace) - _P.sdwidth / 2, _P.fwidth / 2))
        transistor:add_anchor(string.format("sourcedrainlowercenter%d", i), 
            point.create((-_P.fingers / 2 + (i - 1)) * (_P.gatelength + _P.gatespace), -_P.fwidth / 2))
        transistor:add_anchor(string.format("sourcedrainmiddlecenter%d", i), 
            point.create((-_P.fingers / 2 + (i - 1)) * (_P.gatelength + _P.gatespace), 0))
        transistor:add_anchor(string.format("sourcedrainuppercenter%d", i), 
            point.create((-_P.fingers / 2 + (i - 1)) * (_P.gatelength + _P.gatespace), _P.fwidth / 2))
        transistor:add_anchor(string.format("sourcedrainlowerright%d", i), 
            point.create((-_P.fingers / 2 + (i - 1)) * (_P.gatelength + _P.gatespace) + _P.sdwidth / 2, -_P.fwidth / 2))
        transistor:add_anchor(string.format("sourcedrainmiddleright%d", i), 
            point.create((-_P.fingers / 2 + (i - 1)) * (_P.gatelength + _P.gatespace) + _P.sdwidth / 2, 0))
        transistor:add_anchor(string.format("sourcedrainupperright%d", i), 
            point.create((-_P.fingers / 2 + (i - 1)) * (_P.gatelength + _P.gatespace) + _P.sdwidth / 2, _P.fwidth / 2))
    end
    transistor:add_anchor("sourcedrainlowerleftleft", transistor:get_anchor("sourcedrainlowerleft1"))
    transistor:add_anchor("sourcedrainmiddleleftleft", transistor:get_anchor("sourcedrainmiddleleft1"))
    transistor:add_anchor("sourcedrainupperleftleft", transistor:get_anchor("sourcedrainupperleft1"))
    transistor:add_anchor("sourcedrainlowercenterleft", transistor:get_anchor("sourcedrainlowercenter1"))
    transistor:add_anchor("sourcedrainmiddlecenterleft", transistor:get_anchor("sourcedrainmiddlecenter1"))
    transistor:add_anchor("sourcedrainuppercenterleft", transistor:get_anchor("sourcedrainuppercenter1"))
    transistor:add_anchor("sourcedrainlowerrightleft", transistor:get_anchor("sourcedrainlowerright1"))
    transistor:add_anchor("sourcedrainmiddlerightleft", transistor:get_anchor("sourcedrainmiddleright1"))
    transistor:add_anchor("sourcedrainupperrightleft", transistor:get_anchor("sourcedrainupperright1"))

    transistor:add_anchor("sourcedrainlowerleftright", transistor:get_anchor(string.format("sourcedrainlowerleft%d", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainmiddleleftright", transistor:get_anchor(string.format("sourcedrainmiddleleft%d", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainupperleftright", transistor:get_anchor(string.format("sourcedrainupperleft%d", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainlowercenterright", transistor:get_anchor(string.format("sourcedrainlowercenter%d", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainmiddlecenterright", transistor:get_anchor(string.format("sourcedrainmiddlecenter%d", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainuppercenterright", transistor:get_anchor(string.format("sourcedrainuppercenter%d", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainlowerrightright", transistor:get_anchor(string.format("sourcedrainlowerright%d", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainmiddlerightright", transistor:get_anchor(string.format("sourcedrainmiddleright%d", _P.fingers + 1)))
    transistor:add_anchor("sourcedrainupperrightright", transistor:get_anchor(string.format("sourcedrainupperright%d", _P.fingers + 1)))

    -- source/drain straps
    transistor:add_anchor("sourcestrapinnerleft",  point.create((-_P.fingers / 2 + (1 - 1)) * (_P.gatelength + _P.gatespace), ysign * (_P.fwidth / 2 + _P.connsourcespace)))
    transistor:add_anchor("sourcestrapmiddleleft", point.create((-_P.fingers / 2 + (1 - 1)) * (_P.gatelength + _P.gatespace), ysign * (_P.fwidth / 2 + _P.connsourcespace + _P.connsourcewidth / 2)))
    transistor:add_anchor("sourcestrapouterleft",  point.create((-_P.fingers / 2 + (1 - 1)) * (_P.gatelength + _P.gatespace), ysign * (_P.fwidth / 2 + _P.connsourcespace + _P.connsourcewidth)))
    transistor:add_anchor("drainstrapinnerleft",  point.create((-_P.fingers / 2 + (1 - 1)) * (_P.gatelength + _P.gatespace), -ysign * (_P.fwidth / 2 + _P.conndrainspace)))
    transistor:add_anchor("drainstrapmiddleleft", point.create((-_P.fingers / 2 + (1 - 1)) * (_P.gatelength + _P.gatespace), -ysign * (_P.fwidth / 2 + _P.conndrainspace + _P.conndrainwidth / 2)))
    transistor:add_anchor("drainstrapouterleft",  point.create((-_P.fingers / 2 + (1 - 1)) * (_P.gatelength + _P.gatespace), -ysign * (_P.fwidth / 2 + _P.conndrainspace + _P.conndrainwidth)))
    transistor:add_anchor("sourcestrapinnercenter",  point.create(0, ysign * (_P.fwidth / 2 + _P.connsourcespace)))
    transistor:add_anchor("sourcestrapmiddlecenter", point.create(0, ysign * (_P.fwidth / 2 + _P.connsourcespace + _P.connsourcewidth / 2)))
    transistor:add_anchor("sourcestrapoutercenter",  point.create(0, ysign * (_P.fwidth / 2 + _P.connsourcespace + _P.connsourcewidth)))
    transistor:add_anchor("drainstrapinnercenter",  point.create(0, -ysign * (_P.fwidth / 2 + _P.conndrainspace)))
    transistor:add_anchor("drainstrapmiddlecenter", point.create(0, -ysign * (_P.fwidth / 2 + _P.conndrainspace + _P.conndrainwidth / 2)))
    transistor:add_anchor("drainstrapoutercenter",  point.create(0, -ysign * (_P.fwidth / 2 + _P.conndrainspace + _P.conndrainwidth)))
    transistor:add_anchor("sourcestrapinnerright",  point.create((-_P.fingers / 2 + (_P.fingers + 1 - 1)) * (_P.gatelength + _P.gatespace), ysign * (_P.fwidth / 2 + _P.connsourcespace)))
    transistor:add_anchor("sourcestrapmiddleright", point.create((-_P.fingers / 2 + (_P.fingers + 1 - 1)) * (_P.gatelength + _P.gatespace), ysign * (_P.fwidth / 2 + _P.connsourcespace + _P.connsourcewidth / 2)))
    transistor:add_anchor("sourcestrapouterright",  point.create((-_P.fingers / 2 + (_P.fingers + 1 - 1)) * (_P.gatelength + _P.gatespace), ysign * (_P.fwidth / 2 + _P.connsourcespace + _P.connsourcewidth)))
    transistor:add_anchor("drainstrapinnerright",  point.create((-_P.fingers / 2 + (_P.fingers + 1 - 1)) * (_P.gatelength + _P.gatespace), -ysign * (_P.fwidth / 2 + _P.conndrainspace)))
    transistor:add_anchor("drainstrapmiddleright", point.create((-_P.fingers / 2 + (_P.fingers + 1 - 1)) * (_P.gatelength + _P.gatespace), -ysign * (_P.fwidth / 2 + _P.conndrainspace + _P.conndrainwidth / 2)))
    transistor:add_anchor("drainstrapouterright",  point.create((-_P.fingers / 2 + (_P.fingers + 1 - 1)) * (_P.gatelength + _P.gatespace), -ysign * (_P.fwidth / 2 + _P.conndrainspace + _P.conndrainwidth)))

    -- gates
    for i = 1, _P.fingers do
        transistor:add_anchor(string.format("topgatell%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 - _P.gatelength / 2, _P.fwidth / 2 + _P.topgatestrspace))
        transistor:add_anchor(string.format("topgateml%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 - _P.gatelength / 2, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
        transistor:add_anchor(string.format("topgateul%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 - _P.gatelength / 2, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth))
        transistor:add_anchor(string.format("topgatelc%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2, _P.fwidth / 2 + _P.topgatestrspace))
        transistor:add_anchor(string.format("topgatemc%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
        transistor:add_anchor(string.format("topgateuc%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth))
        transistor:add_anchor(string.format("topgatelr%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 + _P.gatelength / 2, _P.fwidth / 2 + _P.topgatestrspace))
        transistor:add_anchor(string.format("topgatemr%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 + _P.gatelength / 2, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
        transistor:add_anchor(string.format("topgateur%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 + _P.gatelength / 2, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth))
        transistor:add_anchor(string.format("botgatell%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 - _P.gatelength / 2, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth))
        transistor:add_anchor(string.format("botgateml%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 - _P.gatelength / 2, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
        transistor:add_anchor(string.format("botgateul%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 - _P.gatelength / 2, -_P.fwidth / 2 - _P.botgatestrspace))
        transistor:add_anchor(string.format("botgatelc%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth))
        transistor:add_anchor(string.format("botgatemc%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
        transistor:add_anchor(string.format("botgateuc%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2, -_P.fwidth / 2 - _P.botgatestrspace))
        transistor:add_anchor(string.format("botgatelr%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 + _P.gatelength / 2, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth))
        transistor:add_anchor(string.format("botgatemr%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 + _P.gatelength / 2, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
        transistor:add_anchor(string.format("botgateur%d", i), point.create((i - 1) * gatepitch - (_P.fingers - 1) * gatepitch / 2 + _P.gatelength / 2, -_P.fwidth / 2 - _P.botgatestrspace))
    end
    transistor:add_anchor("topgate", point.create(0,  _P.fwidth / 2 + math.max(_P.gtopext, enable(_P.drawtopgate, _P.topgatestrspace + _P.topgatestrwidth / 2))))
    transistor:add_anchor("botgate", point.create(0, -_P.fwidth / 2 - math.max(_P.gbotext, enable(_P.drawbotgate, _P.botgatestrspace + _P.botgatestrwidth / 2))))
    transistor:add_anchor("lefttopgate", transistor:get_anchor("topgate") + transistor:get_anchor("sourcedrainmiddlecenterleft"))
    transistor:add_anchor("righttopgate", transistor:get_anchor("topgate") + transistor:get_anchor("sourcedrainmiddlecenterright"))
    transistor:add_anchor("leftbotgate", transistor:get_anchor("botgate") + transistor:get_anchor("sourcedrainmiddlecenterleft"))
    transistor:add_anchor("rightbotgate", transistor:get_anchor("botgate") + transistor:get_anchor("sourcedrainmiddlecenterright"))
    transistor:add_anchor("topgatestrap", point.create(0, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
    transistor:add_anchor("botgatestrap", point.create(0, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
    transistor:add_anchor("topgatestrapmiddle", point.create(
        0,
        _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2
    ))
    transistor:add_anchor("topgatestraplowermiddle", point.create(
        0,
        _P.fwidth / 2 + _P.topgatestrspace
    ))
    transistor:add_anchor("topgatestrapuppermiddle", point.create(
        0,
        _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth
    ))
    transistor:add_anchor("topgatestrapleft", point.create(
        -_P.fingers * _P.gatelength / 2 - (_P.fingers - 1) * _P.gatespace / 2,
        _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2
    ))
    transistor:add_anchor("topgatestraplowerleft", point.create(
        -_P.fingers * _P.gatelength / 2 - (_P.fingers - 1) * _P.gatespace / 2,
        _P.fwidth / 2 + _P.topgatestrspace
    ))
    transistor:add_anchor("topgatestrapupperleft", point.create(
        -_P.fingers * _P.gatelength / 2 - (_P.fingers - 1) * _P.gatespace / 2,
        _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth
    ))
    transistor:add_anchor("topgatestrapright", point.create(
        _P.fingers * _P.gatelength / 2 + (_P.fingers - 1) * _P.gatespace / 2,
        _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2
    ))
    transistor:add_anchor("topgatestraplowerright", point.create(
        _P.fingers * _P.gatelength / 2 + (_P.fingers - 1) * _P.gatespace / 2,
        _P.fwidth / 2 + _P.topgatestrspace
    ))
    transistor:add_anchor("topgatestrapupperright", point.create(
        _P.fingers * _P.gatelength / 2 + (_P.fingers - 1) * _P.gatespace / 2,
        _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth
    ))
    transistor:add_anchor("botgatestrapmiddle", point.create(
        0,
        -_P.fwidth / 2 - _P.botgatestrspace + _P.botgatestrwidth / 2
    ))
    transistor:add_anchor("botgatestraplowermiddle", point.create(
        0,
        -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth
    ))
    transistor:add_anchor("botgatestrapuppermiddle", point.create(
        0,
        -_P.fwidth / 2 - _P.botgatestrspace
    ))
    transistor:add_anchor("botgatestrapleft", point.create(
        -_P.fingers * _P.gatelength / 2 - (_P.fingers - 1) * _P.gatespace / 2,
        -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2
    ))
    transistor:add_anchor("botgatestraplowerleft", point.create(
        -_P.fingers * _P.gatelength / 2 - (_P.fingers - 1) * _P.gatespace / 2,
        -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth
    ))
    transistor:add_anchor("botgatestrapupperleft", point.create(
        -_P.fingers * _P.gatelength / 2 - (_P.fingers - 1) * _P.gatespace / 2,
        -_P.fwidth / 2 - _P.botgatestrspace
    ))
    transistor:add_anchor("botgatestrapright", point.create(
        _P.fingers * _P.gatelength / 2 + (_P.fingers - 1) * _P.gatespace / 2,
        -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2
    ))
    transistor:add_anchor("botgatestraplowerright", point.create(
        _P.fingers * _P.gatelength / 2 + (_P.fingers - 1) * _P.gatespace / 2,
        -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth
    ))
    transistor:add_anchor("botgatestrapupperright", point.create(
        _P.fingers * _P.gatelength / 2 + (_P.fingers - 1) * _P.gatespace / 2,
        -_P.fwidth / 2 - _P.botgatestrspace
    ))
end
