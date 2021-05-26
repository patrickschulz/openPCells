function parameters()

end

function layout(cell, _P)
    cell:merge_into(geometry.rectangle(generics.via(1, 2), 100, 100))
    cell:merge_into(geometry.rectangle(generics.metal(1), 100, 20):translate(0, -100))
end
