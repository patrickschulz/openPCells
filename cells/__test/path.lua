function parameters()

end

function layout(cell)
    cell:merge_into_shallow(geometry.path(generics.metal(1), { point.create(-100, 0), point.create(100, 0) }, 20))
end
