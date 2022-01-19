function parameters()

end

function layout(cell, _P)
    cell:merge_into_shallow(geometry.path(generics.metal(1), { point.create(0, 0), point.create(1000, 0) }, 100, "square"))
end
