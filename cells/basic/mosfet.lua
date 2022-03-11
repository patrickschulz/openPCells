function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                              "nmos", posvals = set("nmos", "pmos") },
        { "oxidetype(Oxide Thickness Type)",                             1, argtype = "integer", posvals = interval(1, inf) },
        { "vthtype(Threshold Voltage Type)",                             1, argtype = "integer", posvals = interval(1, inf) },
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
        { "drawactive",                                                 true }
    )
end

function layout(transistor, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    local actwidth = _P.specifyactext and 
        _P.fingers * gatepitch + _P.sdwidth + 2 * _P.actext
        or
        (_P.fingers + 1) * gatepitch

    local gateaddtop = math.max(_P.gtopext, enable(_P.drawtopgate, _P.topgatestrspace + _P.topgatestrwidth))
    local gateaddbot = math.max(_P.gbotext, enable(_P.drawbotgate, _P.botgatestrspace + _P.botgatestrwidth))

    -- gates
    transistor:merge_into_shallow(geometry.multiple_x(
        geometry.rectanglebltr(generics.other("gate"), 
            point.create(-_P.gatelength / 2, -_P.fwidth / 2 - gateaddbot),
            point.create( _P.gatelength / 2,  _P.fwidth / 2 + gateaddtop)
        ),
        _P.fingers, gatepitch
    ))

    -- active
    if _P.drawactive then
        transistor:merge_into_shallow(geometry.rectangle(generics.other("active"), actwidth, _P.fwidth))
        if _P.drawtopactivedummy then
            transistor:merge_into_shallow(geometry.rectangle(generics.other("active"), actwidth, _P.topactivedummywidth)
            :translate(0, _P.fwidth / 2 + _P.topactivedummywidth / 2 + _P.topactivedummysep))
        end
        if _P.drawbotactivedummy then
            transistor:merge_into_shallow(geometry.rectangle(generics.other("active"), actwidth, _P.botactivedummywidth)
            :translate(0, -_P.fwidth / 2 - _P.botactivedummywidth / 2 - _P.botactivedummysep))
        end
    end

    -- threshold voltage
    transistor:merge_into_shallow(geometry.rectanglebltr(
        generics.vthtype(_P.channeltype, _P.vthtype),
        point.create(-actwidth / 2, -_P.fwidth / 2 - gateaddbot),
        point.create( actwidth / 2,  _P.fwidth / 2 + gateaddtop)
    ))

    -- implant
    transistor:merge_into_shallow(geometry.rectanglebltr(
        generics.implant(_P.channeltype),
        point.create(-actwidth / 2, -_P.fwidth / 2 - gateaddbot),
        point.create( actwidth / 2,  _P.fwidth / 2 + gateaddtop)
    ))

    -- well
    transistor:merge_into_shallow(geometry.rectanglebltr(
        generics.other(_P.flippedwell and (_P.channeltype == "nmos" and "nwell" or "pwell") or (_P.channeltype == "nmos" and "pwell" or "nwell")),
        point.create(-actwidth / 2, -_P.fwidth / 2 - gateaddbot),
        point.create( actwidth / 2,  _P.fwidth / 2 + gateaddtop)
    ))

    -- oxide thickness
    transistor:merge_into_shallow(geometry.rectanglebltr(
        generics.oxide(_P.oxidetype),
        point.create(-actwidth / 2, -_P.fwidth / 2 - gateaddbot),
        point.create( actwidth / 2,  _P.fwidth / 2 + gateaddtop)
    ))

    -- gate contacts
    if _P.drawtopgate then
        transistor:merge_into_shallow(geometry.multiple_x(
            geometry.contact("gate", _P.gatelength, _P.topgatestrwidth),
            _P.fingers, gatepitch
        ):translate(0, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
    end
    if _P.drawtopgatestrap then
        local extend = _P.topgateextendhalfspace and _P.gatespace or 0
        transistor:merge_into_shallow(
            geometry.rectangle(
            generics.metal(1), _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend, _P.topgatestrwidth
        ):translate(0, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
        if _P.topgatemetal > 1 then
            transistor:merge_into_shallow(geometry.via(
                1, _P.topgatemetal, _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend, _P.topgatestrwidth
            ):translate(0, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
        end
    end
    if _P.drawbotgate then
        transistor:merge_into_shallow(geometry.multiple_x(
            geometry.contact("gate", _P.gatelength, _P.botgatestrwidth),
            _P.fingers, gatepitch
        ):translate(0, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
    end
    if _P.drawbotgatestrap then
        local extend = _P.botgateextendhalfspace and _P.gatespace or 0
        transistor:merge_into_shallow(geometry.rectangle(
            generics.metal(1), _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend, _P.botgatestrwidth
        ):translate(0, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
        if _P.botgatemetal > 1 then
            transistor:merge_into_shallow(geometry.rectangle(
                generics.via(1, _P.botgatemetal), _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + extend, _P.botgatestrwidth
            ):translate(0, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
        end
    end

    -- gate cut
    local cutext = _P.gatespace / 2
    local cutwidth = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + 2 * cutext
    if _P.drawtopgcut then
        transistor:merge_into_shallow(geometry.rectanglebltr(
            generics.other("gatecut"),
            point.create(-cutwidth / 2, _P.fwidth / 2 + gateaddtop - _P.cutheight / 2 - _P.topgcutoffset),
            point.create( cutwidth / 2, _P.fwidth / 2 + gateaddtop + _P.cutheight / 2 - _P.topgcutoffset)
        ))
    end
    if _P.drawbotgcut then
        transistor:merge_into_shallow(geometry.rectanglebltr(
            generics.other("gatecut"),
            point.create(-cutwidth / 2, -_P.fwidth / 2 - gateaddbot - _P.cutheight / 2 + _P.botgcutoffset),
            point.create( cutwidth / 2, -_P.fwidth / 2 - gateaddbot + _P.cutheight / 2 + _P.botgcutoffset)
        ))
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
            transistor:merge_into_shallow(geometry.multiple_x(
                geometry.contactbltr("sourcedrain", 
                    point.create(-_P.sdwidth / 2, -_P.fwidth / 2 + sourcesubbot),
                    point.create( _P.sdwidth / 2,  _P.fwidth / 2 - sourcesubtop)
                ),
                math.floor((_P.fingers - 1) / 2), 2 * gatepitch
            ):translate(shift, 0))
            if _P.drawsourcevia and _P.connsourcemetal > 1 then
                transistor:merge_into_shallow(geometry.multiple_x(
                    geometry.rectanglebltr(generics.via(1, _P.connsourcemetal), 
                        point.create(-_P.sdwidth / 2, -_P.fwidth / 2 + sourcesubbot),
                        point.create( _P.sdwidth / 2,  _P.fwidth / 2 - sourcesubtop)
                    ),
                    math.floor((_P.fingers - 1) / 2), 2 * gatepitch
                ):translate(shift, 0))
            end
        end
        -- drain
        if _P.drawinnersourcedrain == "both" or _P.drawinnersourcedrain == "drain" then
            transistor:merge_into_shallow(geometry.multiple_x(
                geometry.contactbltr("sourcedrain", 
                    point.create(-_P.sdwidth / 2, -_P.fwidth / 2 + drainsubbot),
                    point.create( _P.sdwidth / 2,  _P.fwidth / 2 - drainsubtop)
                ),
                math.floor(_P.fingers / 2), 2 * gatepitch
            ):translate(-shift, 0))
            if _P.drawdrainvia and _P.conndrainmetal > 1 then
                transistor:merge_into_shallow(geometry.multiple_x(
                    geometry.rectanglebltr(generics.via(1, _P.conndrainmetal), 
                        point.create(-_P.sdwidth / 2, -_P.fwidth / 2 + drainsubbot),
                        point.create( _P.sdwidth / 2,  _P.fwidth / 2 - drainsubtop)
                    ),
                    math.floor(_P.fingers / 2), 2 * gatepitch
                ):translate(-shift, 0))
            end
        end
    end
    if _P.drawoutersourcedrain ~= "none" then
        -- left (source)
        if _P.drawoutersourcedrain == "both" or _P.drawoutersourcedrain == "source" then
            transistor:merge_into_shallow(geometry.contactbltr(
                    "sourcedrain",
                    point.create(-_P.sdwidth / 2, -_P.fwidth / 2 + sourcesubbot),
                    point.create( _P.sdwidth / 2,  _P.fwidth / 2 - sourcesubtop)
            ):translate(-math.floor(_P.fingers / 2) * gatepitch - shift, 0))
            if _P.drawsourcevia and _P.connsourcemetal > 1 then
                transistor:merge_into_shallow(geometry.rectanglebltr(
                        generics.via(1, _P.connsourcemetal),
                        point.create(-_P.sdwidth / 2, -_P.fwidth / 2 + sourcesubbot),
                        point.create( _P.sdwidth / 2,  _P.fwidth / 2 - sourcesubtop)
                ):translate(-math.floor(_P.fingers / 2) * gatepitch - shift, 0))
            end
        end
        -- right (source or drain)
        if _P.fingers % 2 == 0 then -- source
            if _P.drawoutersourcedrain == "both" or _P.drawoutersourcedrain == "source" then
                transistor:merge_into_shallow(geometry.contactbltr(
                        "sourcedrain",
                        point.create(-_P.sdwidth / 2, -_P.fwidth / 2 + sourcesubbot),
                        point.create( _P.sdwidth / 2,  _P.fwidth / 2 - sourcesubtop)
                ):translate(math.floor(_P.fingers / 2) * gatepitch + shift, 0))
                if _P.drawsourcevia and _P.connsourcemetal > 1 then
                    transistor:merge_into_shallow(geometry.rectanglebltr(
                            generics.via(1, _P.connsourcemetal), 
                            point.create(-_P.sdwidth / 2, -_P.fwidth / 2 + sourcesubbot),
                            point.create( _P.sdwidth / 2,  _P.fwidth / 2 - sourcesubtop)
                    ):translate(math.floor(_P.fingers / 2) * gatepitch + shift, 0))
                end
            end
        else -- drain
            if _P.drawoutersourcedrain == "both" or _P.drawoutersourcedrain == "drain" then
                transistor:merge_into_shallow(geometry.contactbltr(
                        "sourcedrain",
                        point.create(-_P.sdwidth / 2, -_P.fwidth / 2 + drainsubbot),
                        point.create( _P.sdwidth / 2,  _P.fwidth / 2 - drainsubtop)
                ):translate(math.floor(_P.fingers / 2) * gatepitch + shift, 0))
                if _P.drawdrainvia and _P.conndrainmetal > 1 then
                    transistor:merge_into_shallow(geometry.rectanglebltr(
                            generics.via(1, _P.conndrainmetal), 
                            point.create(-_P.sdwidth / 2, -_P.fwidth / 2 + drainsubbot),
                            point.create( _P.sdwidth / 2,  _P.fwidth / 2 - drainsubtop)
                    ):translate(math.floor(_P.fingers / 2) * gatepitch + shift, 0))
                end
            end
        end
    end

    -- source/drain connections
    local ysign = (_P.channeltype == "nmos" and -1 or 1) * (_P.connectinverse and -1 or 1)
    if _P.connectsource then
        if _P.connsourceinline then
            transistor:merge_into_shallow(geometry.rectangle(generics.metal(_P.connsourcemetal),
                _P.fingers * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.connsourcewidth
            ))
        else
            transistor:merge_into_shallow(geometry.rectangle(generics.metal(_P.connsourcemetal),
                _P.fingers * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.connsourcewidth
            ):translate(0, ysign * (_P.fwidth + _P.connsourcewidth + 2 * _P.connsourcespace) / 2))
            --transistor:merge_into_shallow(geometry.multiple_x(
            --    geometry.rectangle(generics.metal(_P.connsourcemetal), _P.sdwidth, _P.connsourcespace),
            --    math.floor(0.5 * _P.fingers) + 1, 2 * (_P.gatelength + _P.gatespace)
            --):translate(0, ysign * (_P.fwidth + _P.connsourcespace) / 2))
            transistor:merge_into_shallow(geometry.multiple_x(
                geometry.rectanglepoints(generics.metal(_P.connsourcemetal), 
                    point.create(-_P.sdwidth / 2, 0),
                    point.create( _P.sdwidth / 2, ysign * _P.connsourcespace)
                ),
                math.floor(0.5 * _P.fingers) + 1, 2 * (_P.gatelength + _P.gatespace)
            ):translate(0, ysign * _P.fwidth / 2))
        end
    end
    if _P.connectdrain then
        if _P.conndraininline then
            transistor:merge_into_shallow(geometry.rectangle(generics.metal(_P.conndrainmetal),
                (_P.fingers - 2) * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.conndrainwidth
            ))
        else
            local diff = _P.extenddrainconnection and 0 or 2
            transistor:merge_into_shallow(geometry.rectangle(generics.metal(_P.conndrainmetal),
                (_P.fingers - diff) * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.conndrainwidth
            ):translate(0, -ysign * (_P.fwidth + _P.conndrainwidth + 2 * _P.conndrainspace) / 2))
            transistor:merge_into_shallow(geometry.multiple_x(
                geometry.rectanglepoints(generics.metal(_P.conndrainmetal), 
                    point.create(-_P.sdwidth / 2, 0),
                    point.create( _P.sdwidth / 2, -ysign * _P.conndrainspace)
                ),
                math.floor(0.5 * _P.fingers), 2 * (_P.gatelength + _P.gatespace)
            ):translate(0, -ysign * _P.fwidth / 2))
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
