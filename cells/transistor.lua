function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                            "nmos" },
        { "oxidetype(Oxide Thickness Type)",                           1 },
        { "vthtype(Threshold Voltage Type)",                           1 },
        { "fingers(Number of Fingers)",                                1 },
        { "fwidth(Finger Width)",                                   1000 },
        { "gatelength(Gate Length)",                                 150 },
        { "gatespace(Gate Spacing)",                                 270 },
        { "actext(Active Extension)",                                 30 },
        { "sdwidth(Source/Drain Metal Width)",                       200 },
        { "sdconnwidth(Source/Drain Rails Metal Width)",             200 },
        { "sdconnspace(Source/Drain Rails Metal Space)",             200 },
        { "gtopext(Gate Top Extension)",                               0 },
        { "gbotext(Gate Bottom Extension)",                            0 },
        { "typext(Type Marker Extension)",                           100 },
        { "cliptop(Clip Top Marker Layers)",                       false },
        { "clipbot(Clip Bottom Marker Layers)",                    false },
        { "drawtopgate(Draw Top Gate Contact)",                    false },
        { "drawtopgatestrap(Draw Top Gate Strap)",                 false },
        { "topgatestrwidth(Top Gate Strap Width)",                   120 },
        { "topgatestrspace(Top Gate Strap Space)",                   200 },
        { "drawbotgate(Draw Bottom Gate Contact)",                 false },
        { "drawbotgatestrap(Draw Bot Gate Strap)",                 false },
        { "botgatestrwidth(Bottom Gate Strap Width)",                120 },
        { "botgatestrspace(Bottom Gate Strap Space)",                200 },
        { "topgcut(Draw Top Gate Cut)",                            false },
        { "botgcut(Draw Bottom Gate Cut)",                         false },
        { "drawinnersourcedrain(Draw Inner Source/Drain Contacts)", true },
        { "drawoutersourcedrain(Draw Outer Source/Drain Contacts)", true },
        { "connectsource(Connect Source)",                         false },
        { "connsourcemetal(Source Connection Metal)",                  1 },
        { "connectdrain(Connect Drain)",                           false },
        { "conndrainmetal(Drain Connection Metal)",                    1 }
    )
end

function layout(transistor, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    local actwidth = _P.fingers * gatepitch + _P.sdwidth + 2 * _P.actext
    local gateheight = _P.fwidth + math.max(_P.gtopext, enable(_P.drawtopgate, _P.topgatestrspace) + _P.topgatestrwidth)
                                 + math.max(_P.gbotext, enable(_P.drawbotgate, _P.botgatestrspace) + _P.botgatestrwidth)
    local gateoffset = (math.max(_P.gtopext, enable(_P.drawtopgate, _P.topgatestrspace) + _P.topgatestrwidth)
                             - math.max(_P.gbotext, enable(_P.drawbotgate, _P.botgatestrspace) + _P.botgatestrwidth)) / 2
    local clipshift = (_P.cliptop and 0 or 1) - (_P.clipbot and 0 or 1)

    -- gates
    transistor:merge_into(geometry.multiple(
        geometry.rectangle(generics.other("gate"), _P.gatelength, gateheight),
        _P.fingers, 1, gatepitch, 0
    ):translate(0, gateoffset))

    -- oxide type
    transistor:merge_into(geometry.rectangle(generics.other(string.format("oxthick%d", _P.oxidetype)), _P.gatelength + 2 * _P.actext, _P.fwidth))
    
    -- threshold voltage
    transistor:merge_into(geometry.rectangle(generics.other(string.format("vthtype%d", _P.oxidetype)), _P.gatelength + 2 * _P.actext, _P.fwidth))

    -- active
    transistor:merge_into(geometry.rectangle(generics.other("active"), actwidth, _P.fwidth))
    transistor:merge_into(geometry.rectangle( (_P.channeltype == "nmos") and generics.other("nimpl") or generics.other("pimpl"), 
        actwidth + 2 * _P.typext, gateheight
    ):translate(0, gateoffset + _P.typext / 2 * clipshift))

    -- well
    transistor:merge_into(geometry.rectangle(
        (_P.channeltype == "nmos") and generics.other("pwell") or generics.other("nwell"), 
        actwidth + 2 * _P.typext, gateheight + _P.typext
    ):translate(0, gateoffset))

    -- drain/source contacts
    if _P.drawinnersourcedrain and _P.fingers > 1 then
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("active"), _P.sdwidth, _P.fwidth),
            _P.fingers - 1, 1, gatepitch, 0
        ))
    end
    if _P.drawoutersourcedrain then
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("active"), _P.sdwidth, _P.fwidth),
            2, 1, _P.fingers * gatepitch, 0
        ))
    end
    transistor:merge_into(geometry.rectangle(generics.via(1, _P.connsourcemetal), _P.sdwidth, _P.fwidth):translate(-gatepitch / 2, 0))
    transistor:merge_into(geometry.rectangle(generics.via(1, _P.conndrainmetal), _P.sdwidth, _P.fwidth):translate(gatepitch / 2, 0))

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
    end
    if _P.drawbotgate then
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), _P.gatelength, _P.botgatestrwidth),
            _P.fingers, 1, gatepitch, 0
        ):translate(0, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
    end
    if _P.drawbotgatestrap then
        transistor:merge_into(
            geometry.rectangle(
                generics.metal(1), _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace, _P.botgatestrwidth
            ):translate(0, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
    end

    -- gate cut
    local cutext = _P.gatespace / 2
    local cutheight = 120
    local cwidth = _P.gatelength + 2 * cutext
    if _P.topgcut then
        transistor:merge_into(geometry.rectangle(
            generics.other("gatecut"), 
            cwidth, cutheight
        ):translate(0, gateheight / 2 + gateoffset))
    end
    if _P.botgcut then
        transistor:merge_into(geometry.rectangle(
            generics.other("gatecut"), 
            cwidth, cutheight
        ):translate(0, -gateheight / 2 + gateoffset))
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

    -- add anchors
    transistor:add_anchor("topgate", point.create(0,  gateheight / 2 + gateoffset - _P.topgatestrwidth / 2))
    transistor:add_anchor("botgate", point.create(0, -gateheight / 2 + gateoffset + _P.botgatestrwidth / 2))
    transistor:add_anchor("leftdrainsource",  point.create(-_P.fingers / 2 * (_P.gatelength + _P.gatespace), 0))
    transistor:add_anchor("rightdrainsource", point.create( _P.fingers / 2 * (_P.gatelength + _P.gatespace), 0))
    transistor:add_anchor("lefttopgate", transistor:get_anchor("topgate") + transistor:get_anchor("leftdrainsource"))
    transistor:add_anchor("righttopgate", transistor:get_anchor("topgate") + transistor:get_anchor("rightdrainsource"))
    transistor:add_anchor("leftbotgate", transistor:get_anchor("botgate") + transistor:get_anchor("leftdrainsource"))
    transistor:add_anchor("rightbotgate", transistor:get_anchor("botgate") + transistor:get_anchor("rightdrainsource"))
end
