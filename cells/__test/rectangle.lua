function parameters()
    pcell.add_parameters(
        { "width", 500 },
        { "height", 500 }
    )
end

function layout(cell, _P)
    geometry.rectanglebltr(cell, generics.metal(1), point.create(0, 0), point.create(_P.width, _P.height))
    cell:set_alignment_box(
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
end
