function parameters()
    pcell.add_parameters(
        { "width", 40 },
        { "length", 500 },
        { "xspace", 120 },
        { "yspace", 400 },
        { "extension", 400 },
        { "contactheight", 200 },
        { "nxfingers", 4 },
        { "nyfingers", 4 },
        { "dummies", 2 }
    )
end

function layout(res, _P)
    local polyheight = _P.nyfingers * _P.length + (_P.nyfingers - 1) * _P.yspace + 2 * _P.extension
    -- poly strips
    res:merge_into_shallow(geometry.multiple_x(geometry.rectangle(generics.other("gate"), _P.width, polyheight), _P.nxfingers + 2 * _P.dummies, _P.width + _P.xspace))
    -- contacts
    res:merge_into_shallow(geometry.multiple_xy(geometry.rectangle(generics.contact("gate"), _P.width, _P.contactheight), _P.nxfingers, _P.nyfingers + 1, _P.width + _P.xspace, _P.length + 2 * _P.extension - _P.contactheight))
    -- poly marker layer
    res:merge_into_shallow(geometry.multiple_y(geometry.rectangle(generics.other("polyres"), (_P.nxfingers + 2 * _P.dummies) * (_P.width + _P.xspace), _P.length), _P.nyfingers, _P.length + _P.yspace))
    -- implant
    res:merge_into_shallow(geometry.rectangle(generics.other("nimpl"), (_P.nxfingers + 2 * _P.dummies) * (_P.width + _P.xspace), polyheight))
    -- well
    res:merge_into_shallow(geometry.rectangle(generics.other("nwell"), (_P.nxfingers + 2 * _P.dummies) * (_P.width + _P.xspace), polyheight))

    res:set_alignment_box(
        point.create(-(_P.nxfingers + 2 * _P.dummies) * (_P.width + _P.xspace) / 2, -_P.length / 2 - _P.extension - _P.contactheight),
        point.create( (_P.nxfingers + 2 * _P.dummies) * (_P.width + _P.xspace) / 2,  _P.length / 2 + _P.extension + _P.contactheight)
    )
end
