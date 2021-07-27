function parameters()
    pcell.add_parameters(
        { "width", 40 },
        { "length", 500 },
        { "space", 120 },
        { "extension", 400 },
        { "contactheight", 200 },
        { "nfingers", 4 },
        { "dummies", 2 }
    )
end

function layout(res, _P)
    -- poly strips
    res:merge_into_shallow(geometry.multiple_x(geometry.rectangle(generics.other("gate"), _P.width, _P.length + 2 * _P.extension), _P.nfingers + 2 * _P.dummies, _P.width + _P.space))
    -- contacts
    res:merge_into_shallow(geometry.multiple_xy(geometry.rectangle(generics.contact("gate"), _P.width, _P.contactheight), _P.nfingers, 2, _P.width + _P.space, _P.length + 2 * _P.extension - _P.contactheight))
    -- poly marker layer
    res:merge_into_shallow(geometry.rectangle(generics.other("polyres"), (_P.nfingers + 2 * _P.dummies) * (_P.width + _P.space), _P.length))
    -- implant
    res:merge_into_shallow(geometry.rectangle(generics.other("nimpl"), (_P.nfingers + 2 * _P.dummies) * (_P.width + _P.space), _P.length + 2 * _P.extension + 2 * _P.contactheight))
    -- well
    res:merge_into_shallow(geometry.rectangle(generics.other("nwell"), (_P.nfingers + 2 * _P.dummies) * (_P.width + _P.space), _P.length + 2 * _P.extension + 2 * _P.contactheight))

    res:set_alignment_box(
        point.create(-(_P.nfingers + 2 * _P.dummies) * (_P.width + _P.space) / 2, -_P.length / 2 - _P.extension - _P.contactheight),
        point.create( (_P.nfingers + 2 * _P.dummies) * (_P.width + _P.space) / 2,  _P.length / 2 + _P.extension + _P.contactheight)
    )
end
