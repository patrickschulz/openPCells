function parameters()
    pcell.add_parameters(
        { "width", 40 },
        { "length", 500 },
        { "space", 120 },
        { "extension", 400 },
        { "contactheight", 200 },
        { "nfingers", 4 }
    )
end

function layout(res, _P)
    -- poly strips
    res:merge_into_shallow(geometry.multiple_x(geometry.rectangle(generics.other("gate"), _P.width, _P.length + 2 * _P.extension + 2 * _P.contactheight), _P.nfingers, _P.width + _P.space))
    -- contacts
    res:merge_into_shallow(geometry.multiple_xy(geometry.rectangle(generics.contact("gate"), _P.width, _P.contactheight), _P.nfingers, 2, _P.width + _P.space, _P.length + 2 * _P.extension + _P.contactheight))
    -- poly marker layer
    res:merge_into_shallow(geometry.rectangle(generics.other("polyres"), _P.nfingers * (_P.width + _P.space), _P.length))
end
