function parameters()
    pcell.add_parameters(
        { "turns",             3 },
        { "width",          6000 },
        { "spacing",        6000 },
        { "innerdiameter", 10000 }
    )
end

function layout(inductor, _P)
    local pathpts = {}
    local append = util.make_insert_xy(pathpts)
    for i = 1, _P.turns do
        local xy = 0.5 * _P.innerdiameter + 0.5 * _P.width + (i - 1) * (_P.width + _P.spacing)
        append( xy + 0.00 * (_P.width + _P.spacing), -xy + 0.00 * (_P.width + _P.spacing))
        append( xy + 0.00 * (_P.width + _P.spacing),  xy + 0.50 * (_P.width + _P.spacing))
        append(-xy - 0.50 * (_P.width + _P.spacing),  xy + 0.50 * (_P.width + _P.spacing))
        append(-xy - 0.50 * (_P.width + _P.spacing), -xy - 1.00 * (_P.width + _P.spacing))
    end
    --inductor:merge_into(geometry.path_midpoint("lastmetal", pathpts, _P.width, "halfangle", true))
    inductor:merge_into(geometry.path(generics.metal(-1), pathpts, _P.width, true))
end
