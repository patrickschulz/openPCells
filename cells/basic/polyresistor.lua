function parameters()
    pcell.add_parameters(
        { "width", 40 },
        { "length", 500 },
        { "xspace", 120 },
        { "yspace", 400 },
        { "extension", 400 },
        { "contactheight", 200 },
        { "nxfingers", 40 },
        { "nyfingers", 5 },
        { "dummies", 2 },
        { "nonresdummies", 2 },
        { "extraextension", 200 }
    )
end

function layout(res, _P)
    local polyheight = _P.nyfingers * _P.length + (_P.nyfingers - 1) * _P.yspace + 2 * _P.extension
    -- poly strips
    res:merge_into_shallow(geometry.multiple_x(geometry.rectangle(generics.other("gate"), _P.width, polyheight), _P.nxfingers + 2 * _P.dummies + 2 * _P.nonresdummies, _P.width + _P.xspace))
    -- contacts
    res:merge_into_shallow(geometry.multiple_xy(geometry.rectangle(generics.contact("gate"), _P.width, _P.contactheight), _P.nxfingers, _P.nyfingers + 1, _P.width + _P.xspace, _P.length + _P.yspace))
    -- poly marker layer
    res:merge_into_shallow(geometry.multiple_y(geometry.rectangle(generics.other("polyres"), (_P.nxfingers + 2 * _P.dummies) * (_P.width + _P.xspace), _P.length), _P.nyfingers, _P.length + _P.yspace))
    -- implant
    res:merge_into_shallow(geometry.rectangle(generics.other("nimpl"), (_P.nxfingers + 2 * _P.dummies + 2 * _P.nonresdummies) * (_P.width + _P.xspace) + 2 * _P.extraextension, polyheight + 2 * _P.extraextension))
    -- well
    res:merge_into_shallow(geometry.rectangle(generics.other("nwell"), (_P.nxfingers + 2 * _P.dummies + 2 * _P.nonresdummies) * (_P.width + _P.xspace) + 2 * _P.extraextension, polyheight + 2 * _P.extraextension))

    -- connections
    for i = 1, _P.nxfingers - 1 do
        if i % 2 == 1 then
            res:merge_into_shallow(geometry.rectangle(generics.metal(1), _P.xspace, 40)
            :translate(-(_P.nxfingers - 2 * i) * (_P.width + _P.xspace) / 2, _P.nyfingers * (_P.length + _P.yspace) / 2))
        else
            res:merge_into_shallow(geometry.rectangle(generics.metal(1), _P.xspace, 40)
            :translate(-(_P.nxfingers - 2 * i) * (_P.width + _P.xspace) / 2, -_P.nyfingers * (_P.length + _P.yspace) / 2))
        end
    end

    res:set_alignment_box(
        point.create(-(_P.nxfingers + 2 * _P.dummies + 2 * _P.nonresdummies - 1) * (_P.width + _P.xspace) / 2, -polyheight / 2),
        point.create( (_P.nxfingers + 2 * _P.dummies + 2 * _P.nonresdummies - 1) * (_P.width + _P.xspace) / 2,  polyheight / 2)
    )
end
