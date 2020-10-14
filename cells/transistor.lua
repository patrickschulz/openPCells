function parameters()
    pcell.add_parameters({ "fingers(Number of Fingers)", 4, "integer", "1-..." })
    pcell.inherit_and_bind_all_parameters("single_transistor")
end

function layout(transistor, _P)
    local singlefinger = pcell.create_layout("single_transistor")
    transistor:merge_into(geometry.multiple(
        singlefinger,
        _P.fingers, 1, _P.gatelength + _P.gatespace, 0
    ))
    if _P.drawtopgate then
        transistor:merge_into(
            geometry.rectangle(
                generics.metal(1), _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace, _P.topgatestrwidth
            ):translate(0, _P.fwidth / 2 + _P.topgatestrspace + _P.topgatestrwidth / 2))
    end
    if _P.drawbotgate then
        transistor:merge_into(
            geometry.rectangle(
                generics.metal(1), _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace, _P.botgatestrwidth
            ):translate(0, -_P.fwidth / 2 - _P.botgatestrspace - _P.botgatestrwidth / 2))
    end
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
    transistor:add_anchor("topgate", singlefinger:get_anchor("topgate"))
    transistor:add_anchor("botgate", singlefinger:get_anchor("botgate"))
    transistor:add_anchor("leftdrainsource",  point.create(-0.5 * _P.fingers * (_P.gatelength + _P.gatespace), 0))
    transistor:add_anchor("rightdrainsource", point.create( 0.5 * _P.fingers * (_P.gatelength + _P.gatespace), 0))
    transistor:add_anchor("lefttopgate", singlefinger:get_anchor("topgate") + transistor:get_anchor("leftdrainsource"))
    transistor:add_anchor("righttopgate", singlefinger:get_anchor("topgate") + transistor:get_anchor("rightdrainsource"))
    transistor:add_anchor("leftbotgate", singlefinger:get_anchor("botgate") + transistor:get_anchor("leftdrainsource"))
    transistor:add_anchor("rightbotgate", singlefinger:get_anchor("botgate") + transistor:get_anchor("rightdrainsource"))
end
