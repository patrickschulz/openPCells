function parameters()
    pcell.add_parameters(
        { "width", 100 },
        { "space", 100 },
        { "regionwidth", 10000 }
    )
end

function layout(shield, _P)
    local pitch = _P.width + _P.space
    local numlines = _P.regionwidth // (2 * pitch)

    -- assemble quarter layout
    local quarter = object.create("quarter")
    for i = 1, numlines do
        geometry.rectanglebltr(quarter, generics.metal(3),
            point.create(-numlines * pitch + _P.space / 2 + (i - 1) * pitch, -numlines * pitch),
            point.create(-numlines * pitch + _P.space / 2 + (i - 1) * pitch + _P.width, -numlines * pitch + (i - 1) * pitch + _P.width + _P.space / 2)
        )
    end

    -- assemble half layout
    local half = object.create("half")
    half:merge_into(quarter)
    half:merge_into(quarter:mirror_at_yaxis())

    -- assemble full layout
    shield:merge_into(half)
    shield:merge_into(half:rotate_90_left())
    shield:merge_into(half:rotate_90_left())
    shield:merge_into(half:rotate_90_left())
end
