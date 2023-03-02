function layout(cell)
    geometry.ring(cell, generics.metal(1), 1000, 1000, 100)
    cell:set_alignment_box(
        point.create(-500, -500),
        point.create(500, 500),
        point.create(-400, -400),
        point.create(400, 400)
    )
end
