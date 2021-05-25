function parameters()

end

function layout(cell, _P)
    cell:merge_into(geometry.rectangle(generics.metal(2), 500, 500))
    cell:merge_into(geometry.multiple_xy(geometry.rectangle(generics.via(1, 2), 100, 100), 2, 2, 200, 200))
end
