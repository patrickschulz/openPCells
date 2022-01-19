function parameters()
    pcell.add_parameters(
        { "turns(Number of Turns)",                        3 },
        { "width(Width)",                               6000 },
        { "spacing(Line Spacing)",                      6000 },
        { "innerdiameter(Inner Diameter)",             10000 },
        { "metalnum(Conductor Metal)",         -1, "integer" },
        { "method(Method)",                  "rectangularyx" }
    )
end

function layout(inductor, _P)
    local pathpts = {}
    local append = util.make_insert_xy(pathpts)
    local pitch = _P.width + _P.spacing
    for i = 1, _P.turns do
        local xy = (_P.innerdiameter + _P.width) / 2 + (i - 1) * pitch
        append( xy + 0.00 * pitch, -xy + 0.00 * pitch)
        append( xy + 0.00 * pitch,  xy + 0.50 * pitch)
        append(-xy - 0.50 * pitch,  xy + 0.50 * pitch)
        append(-xy - 0.50 * pitch, -xy - 1.00 * pitch)
    end
    inductor:merge_into_shallow(geometry.path_midpoint(generics.metal(_P.metalnum), pathpts, _P.width, _P.method, true))
    inductor:merge_into_shallow(geometry.rectangle(generics.metal(-2), 2 * math.floor(math.sqrt(2) * _P.innerdiameter / 2 / 2), 2 * math.floor(math.sqrt(2) * _P.innerdiameter / 2 / 2)))
end
