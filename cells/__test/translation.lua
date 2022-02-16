function parameters()
end

function layout(cell, _P)
    cell:merge_into_shallow(geometry.rectangle(generics.metal(1), 50, 50))
    cell:translate(200, 0)
    cell:merge_into_shallow(geometry.rectangle(generics.metal(2), 50, 50))
end
