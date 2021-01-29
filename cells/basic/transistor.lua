function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                              "nmos", posvals = set("nmos", "pmos") },
        { "oxidetype(Oxide Thickness Type)",                             1, "integer", posvals = interval(1, inf) },
        { "vthtype(Threshold Voltage Type)",                             1, "integer", posvals = interval(1, inf) },
        { "fingers(Number of Fingers)",                                  1, "integer", posvals = interval(1, inf) },
        { "fwidth(Finger Width)",                                      tech.get_dimension("Minimum Gate Width"), "integer" },
        { "gatelength(Gate Length)",                                   tech.get_dimension("Minimum Gate Length"), "integer" },
        { "gatespace(Gate Spacing)",                                   tech.get_dimension("Minimum Gate Space"), "integer" },
        { "actext(Active Extension)",                                   30 },
        { "sdwidth(Source/Drain Metal Width)",                         tech.get_dimension("Minimum M1 Width"), "integer" },
        { "sdconnwidth(Source/Drain Rails Metal Width)",               tech.get_dimension("Minimum M1 Width"), "integer" },
        { "sdconnspace(Source/Drain Rails Metal Space)",               tech.get_dimension("Minimum M1 Width"), "integer" },
        { "gtopext(Gate Top Extension)",                               tech.get_dimension("Minimum Gate Extension") },
        { "gbotext(Gate Bottom Extension)",                            tech.get_dimension("Minimum Gate Extension") },
        { "cliptop(Clip Top Marker Layers)",                         false },
        { "clipbot(Clip Bottom Marker Layers)",                      false },
        { "drawtopgate(Draw Top Gate Contact)",                      false },
        { "drawtopgatestrap(Draw Top Gate Strap)",                   false, follow = "drawtopgate" },
        { "topgatestrwidth(Top Gate Strap Width)",                     tech.get_dimension("Minimum M1 Width"), "integer" },
        { "topgatestrspace(Top Gate Strap Space)",                     tech.get_dimension("Minimum M1 Space"), "integer" },
        { "topgatemetal(Top Gate Strap Metal)",                          1 },
        { "drawbotgate(Draw Bottom Gate Contact)",                   false },
        { "drawbotgatestrap(Draw Bot Gate Strap)",                   false, follow = "drawbotgate" },
        { "drawbotgatestrap(Draw Bot Gate Strap)",                   false },
        { "botgatestrwidth(Bottom Gate Strap Width)",                  tech.get_dimension("Minimum M1 Width"), "integer" },
        { "botgatestrspace(Bottom Gate Strap Space)",                  tech.get_dimension("Minimum M1 Space"), "integer" },
        { "botgatemetal(Bottom Gate Strap Metal)",                       1 },
        { "drawtopgcut(Draw Top Gate Cut)",                          false },
        { "drawbotgcut(Draw Bottom Gate Cut)",                       false },
        { "drawinnersourcedrain(Draw Inner Source/Drain Contacts)", "both", posvales = { "both", "source", "drain", "none" } },
        { "drawoutersourcedrain(Draw Outer Source/Drain Contacts)", "both", posvales = { "both", "source", "drain", "none" } },
        { "sourcesize(Source Size)",                                  1000, follow = "fwidth" },
        { "drainsize(Drain Size)",                                    1000, follow = "fwidth" },
        { "sourcealign(Source Alignement)",                          "top" },
        { "drainalign(Drain Alignement)",                            "top" },
        { "drawsourcevia(Draw Source Via)",                          false },
        { "connectsource(Connect Source)",                           false },
        { "connsourcemetal(Source Connection Metal)",                    1 },
        { "connectdrain(Connect Drain)",                             false },
        { "drawdrainvia(Draw Drain Via)",                            false },
        { "conndrainmetal(Drain Connection Metal)",                      1 }
    )
end

function layout(transistor, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    local actwidth = _P.fingers * gatepitch + _P.sdwidth + 2 * _P.actext

    local gateaddtop = math.max(_P.gtopext, enable(_P.drawtopgate, _P.topgatestrspace + _P.topgatestrwidth))
    local gateaddbot = math.max(_P.gbotext, enable(_P.drawbotgate, _P.botgatestrspace + _P.botgatestrwidth))

    -- gates
    transistor:merge_into(geometry.multiple(
        geometry.rectanglebltr(generics.other("gate"), 
            point.create(-_P.gatelength / 2, -_P.fwidth / 2 - gateaddbot),
            point.create( _P.gatelength / 2,  _P.fwidth / 2 + gateaddtop)
        ),
        _P.fingers, 1, gatepitch, 0
    ))

    -- active
    transistor:merge_into(geometry.rectangle(generics.other("active"), actwidth, _P.fwidth))

    -- boundary for feol implant/well etc. layers
    transistor:merge_into(geometry.rectanglebltr(
        generics.feol(
            {
                channeltype = _P.channeltype,
                vthtype = _P.vthtype,
                oxidetype = _P.oxidetype,
                expand = {
                    left = true,
                    right = true,
                    top = not _P.cliptop,
                    bottom = not _P.clipbot,
                },
            }
        ), 
        point.create(-actwidth / 2, -_P.fwidth / 2 - gateaddbot),
        point.create( actwidth / 2,  _P.fwidth / 2 + gateaddtop)
    ))

    -- gate contacts
    if _P.drawtopgate then
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), _P.gatelength, _P.topgatestrwidth),
            _P.fingers, 1, gatepitch, 0
        ):translate(0, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
    end
    if _P.drawtopgatestrap then
        transistor:merge_into(
            geometry.rectangle(
            generics.metal(1), _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace, _P.topgatestrwidth
        ):translate(0, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
        if _P.topgatemetal > 1 then
            transistor:merge_into(geometry.rectangle(
                generics.via(1, _P.topgatemetal), _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace, _P.topgatestrwidth
            ):translate(0, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
        end
    end
    if _P.drawbotgate then
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), _P.gatelength, _P.botgatestrwidth),
            _P.fingers, 1, gatepitch, 0
        ):translate(0, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
    end
    if _P.drawbotgatestrap then
        transistor:merge_into(geometry.rectangle(
            generics.metal(1), _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace, _P.botgatestrwidth
        ):translate(0, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
        if _P.botgatemetal > 1 then
            transistor:merge_into(geometry.rectangle(
                generics.via(1, _P.botgatemetal), _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace, _P.botgatestrwidth
            ):translate(0, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
        end
    end

    -- gate cut
    local cutext = _P.gatespace / 2
    local cuthalfheight = 60
    local cutwidth = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + 2 * cutext
    if _P.drawtopgcut then
        transistor:merge_into(geometry.rectanglebltr(
            generics.other("gatecut"),
            point.create(-cutwidth / 2, _P.fwidth / 2 + gateaddtop + cuthalfheight),
            point.create( cutwidth / 2, _P.fwidth / 2 + gateaddtop - cuthalfheight)
        ))
    end
    if _P.drawbotgcut then
        transistor:merge_into(geometry.rectanglebltr(
            generics.other("gatecut"),
            point.create(-cutwidth / 2, -_P.fwidth / 2 - gateaddbot + cuthalfheight),
            point.create( cutwidth / 2, -_P.fwidth / 2 - gateaddbot - cuthalfheight)
        ))
    end

    -- source/drain contacts and vias
    local sourcealign = 0
    if _P.sourcealign == "top" then
        sourcealign = (_P.fwidth - _P.sourcesize) / 2
    elseif _P.sourcealign == "bottom" then
        sourcealign = -(_P.fwidth - _P.sourcesize) / 2
    end
    local drainalign = 0
    if _P.drainalign == "top" then
        drainalign = (_P.fwidth - _P.drainsize) / 2
    elseif _P.drainalign == "bottom" then
        drainalign = -(_P.fwidth - _P.drainsize) / 2
    end
    local shift = _P.fingers % 2 == 1 and gatepitch / 2 or 0
    -- drain/source contacts
    if _P.drawinnersourcedrain ~= "none" and _P.fingers > 1 then -- inner contacts
        -- source
        if _P.drawinnersourcedrain == "both" or _P.drawinnersourcedrain == "source" then
            transistor:merge_into(geometry.multiple(
                geometry.rectangle(generics.contact("active"), _P.sdwidth, _P.sourcesize),
                math.floor((_P.fingers - 1) / 2), 1, 2 * gatepitch, 0
            ):translate(shift, sourcealign))
            if _P.drawsourcevia and _P.connsourcemetal > 1 then
                transistor:merge_into(geometry.multiple(
                    geometry.rectangle(generics.via(1, _P.connsourcemetal), _P.sdwidth, _P.sourcesize),
                    math.floor((_P.fingers - 1) / 2), 1, 2 * gatepitch, 0
                ):translate(shift, sourcealign))
            end
        end
        -- drain
        if _P.drawinnersourcedrain == "both" or _P.drawinnersourcedrain == "drain" then
            transistor:merge_into(geometry.multiple(
                geometry.rectangle(generics.contact("active"), _P.sdwidth, _P.drainsize),
                math.floor(_P.fingers / 2), 1, 2 * gatepitch, 0
            ):translate(-shift, drainalign))
            if _P.drawdrainvia and _P.conndrainmetal > 1 then
                transistor:merge_into(geometry.multiple(
                    geometry.rectangle(generics.via(1, _P.conndrainmetal), _P.sdwidth, _P.drainsize),
                    math.floor(_P.fingers / 2), 1, 2 * gatepitch, 0
                ):translate(-shift, drainalign))
            end
        end
    end
    if _P.drawoutersourcedrain ~= "none" then
        -- left (source)
        if _P.drawoutersourcedrain == "both" or _P.drawoutersourcedrain == "source" then
            transistor:merge_into(geometry.rectangle(
                generics.contact("active"), _P.sdwidth, _P.sourcesize
            ):translate(-math.floor(_P.fingers / 2) * gatepitch - shift, sourcealign))
            if _P.drawsourcevia and _P.connsourcemetal > 1 then
                transistor:merge_into(geometry.rectangle(
                    generics.via(1, _P.connsourcemetal), _P.sdwidth, _P.sourcesize
                ):translate(-math.floor(_P.fingers / 2) * gatepitch - shift, sourcealign))
            end
        end
        -- right (source or drain)
        if _P.fingers % 2 == 0 then -- source
            if _P.drawoutersourcedrain == "both" or _P.drawoutersourcedrain == "source" then
                transistor:merge_into(geometry.rectangle(
                    generics.contact("active"), _P.sdwidth, _P.sourcesize
                ):translate(math.floor(_P.fingers / 2) * gatepitch + shift, sourcealign))
                if _P.drawsourcevia and _P.connsourcemetal > 1 then
                    transistor:merge_into(geometry.rectangle(
                        generics.via(1, _P.connsourcemetal), _P.sdwidth, _P.sourcesize
                    ):translate(math.floor(_P.fingers / 2) * gatepitch + shift, sourcealign))
                end
            end
        else -- drain
            if _P.drawoutersourcedrain == "both" or _P.drawoutersourcedrain == "drain" then
                transistor:merge_into(geometry.rectangle(
                    generics.contact("active"), _P.sdwidth, _P.sourcesize
                ):translate(math.floor(_P.fingers / 2) * gatepitch + shift, drainalign))
                if _P.drawdrainvia and _P.conndrainmetal > 1 then
                    transistor:merge_into(geometry.rectangle(
                        generics.via(1, _P.conndrainmetal), _P.sdwidth, _P.drainsize
                    ):translate(math.floor(_P.fingers / 2) * gatepitch + shift, drainalign))
                end
            end
        end
    end

    -- source/drain connections
    if _P.connectsource then
        transistor:merge_into(geometry.rectangle(generics.metal(_P.connsourcemetal),
            _P.fingers * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.sdconnwidth
        ):translate(0, -_P.fwidth / 2 - _P.sdconnwidth / 2 - _P.sdconnspace))
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(_P.connsourcemetal), _P.sdwidth, _P.sdconnspace),
            math.floor(0.5 * _P.fingers) + 1, 1, 2 * (_P.gatelength + _P.gatespace), 0
        ):translate(0, -0.5 * (_P.fwidth + _P.sdconnspace)))
    end
    if _P.connectdrain then
        transistor:merge_into(geometry.rectangle(generics.metal(_P.conndrainmetal),
            (_P.fingers - 2) * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.sdconnwidth
        ):translate(0, 0.5 * _P.fwidth + 0.5 * _P.sdconnwidth + _P.sdconnspace))
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(_P.conndrainmetal), _P.sdwidth, _P.sdconnspace),
            math.floor(0.5 * _P.fingers), 1, 2 * (_P.gatelength + _P.gatespace), 0
        ):translate(0, 0.5 * (_P.fwidth + _P.sdconnspace)))
    end

    -- anchors
    transistor:add_anchor("topgate", point.create(0,  _P.fwidth / 2 + gateaddtop - _P.topgatestrwidth / 2))
    transistor:add_anchor("botgate", point.create(0, -_P.fwidth / 2 - gateaddbot + _P.botgatestrwidth / 2))

    transistor:add_anchor("topgatestrapleft", point.create(
        -_P.fingers * _P.gatelength / 2 - (_P.fingers - 1) * _P.gatespace / 2,
        _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2
    ))
    transistor:add_anchor("topgatestrapright", point.create(
        _P.fingers * _P.gatelength / 2 + (_P.fingers - 1) * _P.gatespace / 2,
        _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2
    ))
    transistor:add_anchor("botgatestrapleft", point.create(
        -_P.fingers * _P.gatelength / 2 - (_P.fingers - 1) * _P.gatespace / 2,
        -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2
    ))
    transistor:add_anchor("botgatestrapright", point.create(
        _P.fingers * _P.gatelength / 2 + (_P.fingers - 1) * _P.gatespace / 2,
        -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2
    ))

    transistor:add_anchor("leftdrainsource",  point.create(-_P.fingers / 2 * (_P.gatelength + _P.gatespace), 0))
    transistor:add_anchor("rightdrainsource", point.create( _P.fingers / 2 * (_P.gatelength + _P.gatespace), 0))
    transistor:add_anchor("lefttopgate", transistor:get_anchor("topgate") + transistor:get_anchor("leftdrainsource"))
    transistor:add_anchor("righttopgate", transistor:get_anchor("topgate") + transistor:get_anchor("rightdrainsource"))
    transistor:add_anchor("leftbotgate", transistor:get_anchor("botgate") + transistor:get_anchor("leftdrainsource"))
    transistor:add_anchor("rightbotgate", transistor:get_anchor("botgate") + transistor:get_anchor("rightdrainsource"))
end
