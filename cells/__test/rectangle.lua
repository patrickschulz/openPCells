function parameters()
end

function layout(cell, _P)
    cell:merge_into_shallow(geometry.rectangle(generics.metal(1), 50, 50):translate(0,  50))
    cell:merge_into_shallow(geometry.rectangle(generics.metal(1), 50, 50):translate(0, -50))
    cell:add_anchor("A", point.create(0, 75))
end
