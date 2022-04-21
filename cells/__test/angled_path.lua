function parameters()

end

function layout(cell)
    geometry.any_angle_path(cell, generics.metal(1), {
        point.create(0, 0),
        point.create(10000, 100000),
        point.create(15000, 100000),
    }, 5000, 100, true, true)
end
