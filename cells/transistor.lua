function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                      "nmos" },
        { "oxidetype(Oxide Thickness Type)",                1 },
        { "vthtype(Threshold Voltage Type)",                1 },
        { "fingers(Number of Fingers)",                     4, "integer", "1-..." },
        { "fwidth(Finger Width)",                           1.0 },
        { "gatelength(Gate Length)",                        0.15 },
        { "fspace(Gate Spacing)",                           0.27 },
        { "actext(Active Extension)",                       0.03 },
        { "sdwidth(Source/Drain Metal Width)",              0.2 },
        { "sdconnwidth(Source/Drain Rails Metal Width)",    0.2 },
        { "sdconnspace(Source/Drain Rails Metal Space)",    0.2 },
        { "gtopext(Gate Top Extension)",                    0.0 },
        { "gbotext(Gate Bottom Extension)",                 0.0 },
        { "typext(Type Marker Extension)",                  0.1 },
        { "cliptop(Clip Top Marker Layers)",                false },
        { "clipbot(Clip Bottom Marker Layers)",             false },
        { "drawtopgate(Draw Top Gate Strap)",               false },
        { "topgatestrwidth(Top Gate Strap Width)",          0.12 },
        { "topgatestrext(Top Gate Strap Extension)",        1 },
        { "topgatestrspace(Top Gate Strap Space)",          0.2 },
        { "drawbotgate(Draw Bottom Gate Strap)",            false },
        { "botgatestrwidth(Bottom Gate Strap Width)",       0.12 },
        { "botgatestrext(Bottom Gate Strap Extension)",     1 },
        { "botgatestrspace(Bottom Gate Strap Space)",       0.2 },
        { "topgcut(Draw Top Gate Cut)",                     false },
        { "botgcut(Draw Bottom Gate Cut)",                  false },
        { "connectsource(Connect Source)",                  false },
        { "connectdrain(Connect Drain)",                    false }
    )
end

function layout()
    local actwidth = _P.fingers * (_P.gatelength + _P.fspace) + _P.sdwidth + 2 * _P.actext
    local gatepitch = _P.gatelength + _P.fspace
    local gateheight = _P.fwidth + _P.gtopext + _P.gbotext
    --[[ FIXME
    local gateheight = _P.fwidth + math.max(
        _P.gtopext + _P.gbotext, 
        enable(_P.drawtopgate, _P.topgatestrspace) + enable(_P.drawbotgate, _P.botgatestrspace) + _P.topgatestrwidth + _P.botgatestrwidth
    )
    --]]
    local gateoffset = 0.5 * (_P.gtopext - _P.gbotext)
    local clipshift = (_P.cliptop and 0 or 1) - (_P.clipbot and 0 or 1)

    local transistor = object.create()

    -- gates
    transistor:merge_into(geometry.multiple(
        geometry.rectangle(generics.other("gate"), _P.gatelength, gateheight),
        _P.fingers, 1, gatepitch, 0
    ):translate(0, gateoffset))

    -- oxide type
    transistor:merge_into(geometry.rectangle(
        generics.other(string.format("oxthick%d", _P.oxidetype)),
        _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.fspace + 2 * _P.actext, _P.fwidth
    ))
    
    -- threshold voltage
    transistor:merge_into(geometry.rectangle(
        generics.other(string.format("vthtype%d", _P.vthtype)),
        _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.fspace + 2 * _P.actext, _P.fwidth
    ))

    -- active
    transistor:merge_into(geometry.rectangle(
        generics.other("active"), 
        actwidth, _P.fwidth
    ))
    transistor:merge_into(geometry.rectangle(
        (_P.channeltype == "nmos") and generics.other("nimpl") or generics.other("pimpl"), 
        actwidth + 2 * _P.typext, gateheight + _P.typext * clipshift
    ):translate(0, gateoffset + 0.5 * _P.typext * clipshift))

    -- well
    transistor:merge_into(geometry.rectangle(
        (_P.channeltype == "nmos") and generics.other("pwell") or generics.other("nwell"), 
        actwidth + 2 * _P.typext, gateheight + _P.typext
    ):translate(0, gateoffset))

    -- drain/source contacts
    transistor:merge_into(geometry.multiple(
        geometry.rectangle(generics.contact("active"), _P.sdwidth, _P.fwidth),
        _P.fingers + 1, 1,
        gatepitch, 0
    ))

    -- gate contacts
    if _P.drawtopgate then
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), _P.gatelength, _P.topgatestrwidth),
            _P.fingers, 1, gatepitch, 0)
            :translate(0, 0.5 * _P.fwidth + _P.topgatestrspace + 0.5 * _P.topgatestrwidth)
        )
        if _P.fingers > 1 then
            transistor:merge_into(geometry.rectangle(
                generics.metal(1), 
                (_P.fingers - 1 + _P.topgatestrext) * gatepitch, _P.topgatestrwidth
            ):translate(0, 0.5 * _P.fwidth + _P.topgatestrspace + 0.5 * _P.topgatestrwidth))
        end
    end
    if _P.drawbotgate then
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.contact("gate"), _P.gatelength, _P.botgatestrwidth),
            _P.fingers, 1, gatepitch, 0)
            :translate(0, -0.5 * _P.fwidth - _P.gbotext + 0.5 * _P.botgatestrwidth)
        )
        if _P.fingers > 1 then
            transistor:merge_into(geometry.rectangle(
                generics.metal(1), 
                (_P.fingers - 1 + _P.botgatestrext) * gatepitch, _P.botgatestrwidth
            ):translate(0, -0.5 * _P.fwidth - _P.gbotext - 0.5 * _P.botgatestrwidth))
        end
    end

    -- gate cut
    local cutext = 0.5 * _P.fspace
    local cutheight = 0.12
    local cwidth = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.fspace + 2 * cutext
    if _P.topgcut then
        transistor:merge_into(geometry.rectangle(
            generics.other("gatecut"), 
            cwidth, cutheight
        ):translate(0, 0.5 * _P.fwidth + _P.gtopext))
    end
    if _P.botgcut then
        transistor:merge_into(geometry.rectangle(
            generics.other("gatecut"), 
            cwidth, cutheight
        ):translate(0, -0.5 * _P.fwidth - _P.gbotext))
    end

    if _P.connectsource then
        transistor:merge_into(geometry.rectangle(generics.metal(1),
            _P.fingers * (_P.gatelength + _P.fspace) + _P.sdwidth, _P.sdconnwidth
        ):translate(0, -0.5 * _P.fwidth - 0.5 * _P.sdconnwidth - _P.sdconnspace))
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), _P.sdwidth, _P.sdconnspace),
            math.floor(0.5 * _P.fingers) + 1, 1, 2 * (_P.gatelength + _P.fspace), 0
        ):translate(0, -0.5 * (_P.fwidth + _P.sdconnspace)))
    end
    if _P.connectdrain then
        transistor:merge_into(geometry.rectangle(generics.metal(1),
            (_P.fingers - 2) * (_P.gatelength + _P.fspace) + _P.sdwidth, _P.sdconnwidth
        ):translate(0, 0.5 * _P.fwidth + 0.5 * _P.sdconnwidth + _P.sdconnspace))
        transistor:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), _P.sdwidth, _P.sdconnspace),
            math.floor(0.5 * _P.fingers), 1, 2 * (_P.gatelength + _P.fspace), 0
        ):translate(0, 0.5 * (_P.fwidth + _P.sdconnspace)))
    end

    -- add anchors
    transistor:add_anchor("topgate", point.create(0,  0.5 * _P.fwidth + _P.gtopext - 0.5 * _P.topgatestrwidth))
    transistor:add_anchor("botgate", point.create(0, -0.5 * _P.fwidth - _P.gbotext + 0.5 * _P.botgatestrwidth))
    transistor:add_anchor("leftdrainsource",  point.create(-0.5 * _P.fingers * (_P.gatelength + _P.fspace), 0))
    transistor:add_anchor("rightdrainsource", point.create( 0.5 * _P.fingers * (_P.gatelength + _P.fspace), 0))

    return transistor
end
