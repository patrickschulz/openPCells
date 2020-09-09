function parameters()
    pcell.add_parameters({ "fingers(Number of Fingers)", 4, "integer", "1-..." })
    pcell.inherit_and_bind_all_parameters("single_transistor")
end

function layout(transistor, _P)
    transistor:merge_into(geometry.multiple(
        celllib.create_layout("single_transistor"),
        _P.fingers, 1, _P.gatelength + _P.gatespace, 0
    ))
    if _P.connectsource then
        transistor:merge_into(geometry.rectangle(generics.metal(_P.connsourcemetal),
            _P.fingers * (_P.gatelength + _P.gatespace) + _P.sdwidth, _P.sdconnwidth
        ):translate(0, -0.5 * _P.fwidth - 0.5 * _P.sdconnwidth - _P.sdconnspace))
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
    transistor:add_anchor("topgate", point.create(0,  0.5 * _P.fwidth + _P.gtopext - 0.5 * _P.topgatestrwidth))
    transistor:add_anchor("botgate", point.create(0, -0.5 * _P.fwidth - _P.gbotext + 0.5 * _P.botgatestrwidth))
    transistor:add_anchor("leftdrainsource",  point.create(-0.5 * _P.fingers * (_P.gatelength + _P.gatespace), 0))
    transistor:add_anchor("rightdrainsource", point.create( 0.5 * _P.fingers * (_P.gatelength + _P.gatespace), 0))
end
