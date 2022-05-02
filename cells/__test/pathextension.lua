function parameters()

end

function layout(cell, _P)
    geometry.path(cell, generics.metal(1), { point.create(0, 0), point.create(1000, 0) }, 100, "square")
end
