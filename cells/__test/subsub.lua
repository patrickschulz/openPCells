function parameters()

end

function layout(cell, _P)
    cell:merge_into_shallow(geometry.rectangle(generics.via(1, 2), 100, 100))
end
