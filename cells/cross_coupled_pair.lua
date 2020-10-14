function parameters()
    pcell.add_parameters({ "fingers(Number of Fingers)", 4 })
    pcell.inherit_and_bind_all_parameters("single_transistor")
end

function layout(oscillator, _P)
    --local gatepitch = _P.gatelength + _P.gatespace
    --local numtransistors = #_P.fingers
    --local numfingers = aux.sum(_P.fingers)
    --local gatestrspace = 0.2

    oscillator:merge_into(geometry.multiple(
        celllib.create_layout("single_transistor"),
        1, 1, 0, 0)
    )
end
