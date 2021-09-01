function parameters()

end

function layout(cell)
    cell:merge_into_shallow(geometry.any_angle_path(generics.metal(1), { point.create(0, 0), point.create(10000, 100000) }, 100, 100, true, true))
end
