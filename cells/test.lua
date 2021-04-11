function parameters()
end

function layout(cell, _P)
    cell:merge_into(geometry.rectanglebltr(generics.metal(1), point.create(0, 0), point.create(10, 10)))
    cell:merge_into(geometry.rectanglebltr(generics.metal(1), point.create(5, 0), point.create(15, 10)))
end
